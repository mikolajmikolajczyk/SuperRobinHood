# PDS Transfer Protocol

How PDS transfers assembled code from the host PC to the target computer, and
how the debug/transfer infrastructure appears in source code.

---

## Overview

```
┌────────────┐                    ┌────────────────┐
│  PC (Host) │   assembled code   │ Target Machine │
│            │──────────────────►│                │
│  Assembler │   via ribbon cable │  DL receiver   │
│  Editor    │◄──────────────────│  stub running  │
│  Debugger  │   debug responses  │  in RAM        │
└────────────┘                    └────────────────┘
```

1. Target machine runs a **receiver stub** (DL0, DL1, or DL2) that waits for
   instructions from the PC
2. PC assembles source code with PDS assembler
3. `send computer1` directive triggers transfer of assembled binary over cable
4. Target receives data byte-by-byte via handshake protocol
5. Once transferred, target begins execution at specified entry point

---

## DL0, DL1, DL2 — Receiver Stubs

Source code exists for multiple target platforms:

| Stub | Platforms | Purpose |
|------|-----------|---------|
| DL0 | CPC, C64, BBC, Spectrum | Basic download receiver |
| DL1 | CPC, C64, BBC, Spectrum | Extended receiver (more features) |
| DL2 | CPC, C64, BBC, Spectrum | Further extended receiver |

These stubs are small programs loaded onto the target machine first (typically
from tape or disc). Once running, they wait in a loop polling the hardware
interface for incoming data from the PC.

The receiver handles:
- Receiving assembled binary data
- Writing it to the correct memory addresses
- Starting execution at a specified entry point
- Communicating with the PDS debugger (breakpoints, memory reads, etc.)

---

## The `send computer` Directive

In PDS source code, `send computer1` (or `send computer2`) at the end of a
source file triggers the transfer:

```asm
        ; ... assembled code ...

        send computer1          ; transfer to slave 1
```

- `send computer1` — transfer to first target (connector 1 on ISA card)
- `send computer2` — transfer to second target (connector 2)

### Bank Transfer

When assembling multi-bank ROMs (like NES cartridges), banks are sent
sequentially. The `bank` directive with an entry point triggers transfer with
automatic execution:

```asm
        bank 12,START           ; switch to bank 12, set entry at START
```

vs. plain bank switch without transfer:

```asm
        bank 12                 ; switch to bank 12 (no entry point)
```

---

## The `master` Flag

Codemasters source uses a `master` equate to control build mode:

```asm
master  equ 0                   ; 0 = development (PDS transfer)
                                ; 1 = production (ROM image)
```

### Development Mode (`master equ 0`)

- `send computer1` is active — code transfers to target via cable
- Debug vectors ($FFF2, $FFED, $FFE4) are functional
- `BANK N,LABEL` syntax used for transfer with entry point
- PDS debugger stubs reside in target RAM
- CHECKPDS calls verify debugger presence

### Production Mode (`master equ 1`)

- Transfer directives are skipped or absent
- All banks are wiped and filled, producing a clean ROM image
- Debug vectors are NOPed out or made unreachable via conditional assembly:

```asm
        if master=0
            jsr CHECKPDS        ; only in dev builds
        endif
```

- Output is suitable for EPROM burning or cartridge manufacturing

---

## Debug Vectors

The PDS debugger communicates through fixed vectors in the target's address space:

| Vector | Address | Name | Purpose |
|--------|---------|------|---------|
| CHECKPDS | `$FFF2` | Debugger presence check | Returns to caller if PDS connected, hangs or NOPs otherwise |
| BREAKPOINT | `$FFED` | Debugger breakpoint | Halts execution, transfers control to PC-side debugger |
| ANALYZE | `$FFE4` | Profiler entry | Triggers PC-side profiler/analyzer |

### How Debug Vectors Work

In development mode, these addresses in the target's memory map point to the
DL receiver stub code. When the game calls `JSR $FFF2`, it jumps into the
receiver stub which communicates back to the PC over the cable.

```asm
CHECKPDS    equ $FFF2
BREAKPOINT  equ $FFED
ANALYZE     equ $FFE4

; Usage in game code:
            jsr CHECKPDS        ; verify PDS is connected
            jsr BREAKPOINT      ; halt for debugging
            jmp ANALYZE         ; enter profiler
```

**Alias:** Some files use `testpds = $fff2` instead of the `CHECKPDS` name.

### NES Vector Conflict

On the NES, addresses $FFE4–$FFF2 are in the **fixed PRG-ROM bank** at
$C000–$FFFF, very close to the hardware vectors:

```
$FFE4  ANALYZE (PDS)
$FFED  BREAKPOINT (PDS)
$FFF2  CHECKPDS (PDS)
$FFFA  NMI vector (NES hardware)
$FFFC  RESET vector (NES hardware)
$FFFE  IRQ/BRK vector (NES hardware)
```

In a production ROM, these addresses contain normal game code. In development,
the fixed bank must include PDS debugger stubs at these exact locations. This
means the **last bank** of the ROM has a dual-purpose layout during development.

---

## Bank Transfer for NES (Mapper 71)

For Codemasters NES games using Mapper 71:

- `$8000–$BFFF`: Switchable 16 KiB PRG-ROM bank
- `$C000–$FFFF`: Fixed to last bank

Each `bank N` directive assembles a 16 KiB block. During `send computer1`, banks
are transferred sequentially to the target's PRG-ROM address space. The mapper
hardware (or dev hardware) handles bank switching during the transfer.

```asm
        bank 0                  ; 16K at $8000 (switchable)
        org &8000
        ; ... bank 0 code ...

        bank 1
        org &8000
        ; ... bank 1 code ...

        ; ... more banks ...

        bank 7                  ; last bank, fixed at $C000
        org &C000
        ; ... vectors, PDS stubs, startup code ...
```

---

## Identifying Transfer Code in Disassembly

When examining compiled ROMs or source code, these patterns indicate PDS
transfer infrastructure:

1. **`send computer1`** — direct evidence of PDS toolchain (source only)
2. **`master equ`** — build mode flag
3. **`if master=0`** blocks — conditional debug/transfer code
4. **`BANK N,LABEL`** syntax — bank switch with entry point (dev mode)
5. **References to $FFF2/$FFED/$FFE4** — debug vector calls
6. **DL stub code** in RAM regions — receiver program residue
