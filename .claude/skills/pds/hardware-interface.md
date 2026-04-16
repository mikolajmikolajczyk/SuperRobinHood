# PDS Hardware Interface

Complete reference for the PDS hardware that connects the host PC to target
computers via ribbon cable.

---

## System Overview

```
┌─────────────────┐    16-pin ribbon    ┌──────────────────┐
│   Apricot PC    │    cable            │  Target Computer │
│   (ISA bus)     │◄──────────────────►│  (CPC/C64/etc)   │
│                 │                     │                  │
│  ┌───────────┐  │                     │  ┌────────────┐  │
│  │ 8255 PPI  │  │                     │  │  Z80 PIO   │  │
│  │ ISA card  │  │                     │  │  interface  │  │
│  └───────────┘  │                     │  └────────────┘  │
└─────────────────┘                     └──────────────────┘
```

The ISA card supports **two 2×8-pin connectors**, allowing connection to
**two slave computers simultaneously** (`send computer1` / `send computer2`).

---

## PC-Side ISA Card

| Component | Purpose |
|-----------|---------|
| 8255 PPI chip | Programmable parallel interface — handles bidirectional data + handshake |
| 5× logic chips | Address decoding, signal conditioning |
| 2× 2×8-pin connectors | Ribbon cable connections to up to 2 target machines |

The 8255 PPI provides three 8-bit ports (A, B, C) in various I/O modes. Port A
is typically used for bidirectional data, Port C for handshake/control signals.

---

## V1 Interface — Z80 PIO Version

The "standard" PDS interface for CPC. Connects to the **CPC Expansion Port**.

### Port Map (CPC Address Space)

| Port | Register | R/W | Purpose |
|------|----------|-----|---------|
| `$FBEC` | Z80 PIO Port A Data | R/W | 8-bit bidirectional data to/from PC |
| `$FBED` | Z80 PIO Port B Data | R/W | Handshake/control signals |
| `$FBEE` | Z80 PIO Port A Control | W | Port A mode configuration |
| `$FBEF` | Z80 PIO Port B Control | W | Port B mode configuration |

### Handshake Bits (Port $FBED)

| Bit | Direction | Purpose |
|-----|-----------|---------|
| 0 | PC → Target | Clock from PC. Data is valid on **both** rising and falling edges |
| 1 | — | Not connected (Spectrum schematic) |
| 2 | — | Not connected |
| 3 | — | Not connected |
| 4 | — | Not connected |
| 5 | Bidirectional? | Unknown — possibly IRQ line to/from PC |
| 6 | Target → 74LS245 | Data direction control for transceiver |
| 7 | Target → PC | Clock/acknowledge. Signals on **both** edges |

### Transfer Timing

Data is clocked on **both edges** (rising AND falling) of the clock signals.
This means each clock cycle transfers **two** data states, effectively doubling
throughput compared to single-edge clocking.

```
PC Clock (bit 0):    ──┐  ┌──┐  ┌──┐  ┌──
                       │  │  │  │  │  │
                       └──┘  └──┘  └──┘

Data valid:           ──X────X────X────X──  (valid on each edge)

Target Ack (bit 7):     ┌──┐  ┌──┐  ┌──┐
                     ───┘  └──┘  └──┘  └──  (acknowledges each transfer)
```

### Board Components

| Chip | Type | Purpose |
|------|------|---------|
| Z80 PIO | Parallel I/O | Bidirectional data + handshake, directly decoded by CPC |
| 74LS245 | Bidirectional buffer | Amplifies/isolates data bus (direction via bit 6) |
| 74LS04 | Hex inverter | Signal inversion for control logic |
| 74LS32 | Quad OR gate | Address decoding / signal combining |

**Note:** The Z80 PIO itself is bidirectional, so the 74LS245 transceiver is
technically redundant. It likely serves as a bus amplifier or protection fuse.

### Physical Connector

- 2×8-pin header on interface board
- 16-pin flat ribbon cable to PC
- **Pin wiring is crossed**: Pin 1–16 on one end maps to Pin 16–1 on the other
- Reset button on the CPC interface board

---

## V2 Interface — Alternate Version (No Z80 PIO)

An alternate interface using the **same port range** but with different register
semantics. No Z80 PIO chip — simpler discrete logic.

### Port Map

| Port | Purpose | Notes |
|------|---------|-------|
| `$FBEC` | Unknown | Possibly configuration register or REQUEST signal to PC |
| `$FBED` | Data TO PC | Write-only data output |
| `$FBEE` | Status | Bit 0 = CLK signal from PC |
| `$FBEF` | Data FROM PC | Read-only data input |

### Stability Issues

The V2 handshake appears **less stable** than the Z80 PIO version:

- Timing seems to require PC software to **disable interrupts** during transfer
- Unless the hardware includes automatic handshaking not visible in the
  disassembled target-side code
- This suggests V2 may be an **older** PDS revision, before the Z80 PIO design
  was adopted

### Games with V2 Remnant Code

These CPC games contain (unused) code fragments accessing ports $FBEC–$FBEF
using V2 semantics:

| Game | Publisher | Notes |
|------|-----------|-------|
| Gremlins | Adventure Soft (UK) | Debug I/O in Spanish version |
| Robin of Sherwood | Adventure Soft (UK) | Port access code present |
| Seablood (Seas of Blood) | Adventure Soft (UK) | Port access code present |
| The Last V8 | Mastertronic | Uses port $FBED for data to PC |

It is unclear whether these games used an alternate version of official PDS
hardware, or a similar devkit from another company.

---

## NES Context

For NES development via PDS, the hardware interface would differ from the CPC
version since the NES uses a cartridge slot rather than an expansion port. The
6502 version of PDS includes its own transfer protocol adapted for 6502 targets.

The relevant interface for this project is the **software protocol** (debug
vectors at $FFF2/$FFED/$FFE4, bank transfer via `send computer`) rather than
the CPC-specific hardware. See `references/transfer-protocol.md` for details.
