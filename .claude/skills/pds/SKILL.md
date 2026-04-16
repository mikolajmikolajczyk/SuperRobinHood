---
name: pds-development-system
description: >
  Reference for the PDS (Programmers Development System) by Andy Glaister /
  PD Systems. A cross-development system from the 1980s running on an Apricot PC
  that connected via hardware interface to target computers (Amstrad CPC, C64,
  MSX, ZX Spectrum, BBC, NES). Includes assembler, debugger, editor, profiler,
  graphics tool, and transfer hardware. ~500 units sold to UK game developers
  including Codemasters.
  Use this skill whenever the user mentions PDS, PD Systems, Programmers
  Development System, Andy Glaister, CHECKPDS, BREAKPOINT vector, send computer,
  .PDS file, .PRJ file, .ROU file, .MUS file, .CHR file, .DAT file, PDS
  assembler, PDS debugger, PDS transfer, PDS hardware interface, cross-development,
  Apricot PC, DL0, DL1, DL2, FBEC, FBEF, Z80 PIO, 8255 PPI, zvar, ldir, lddr,
  master equ, asmflag, CURCOLOUR, or any PDS-related topic. Also trigger when
  encountering $FFF2, $FFED, $FFE4 vectors in NES code, or when analyzing
  original Codemasters source code in original_source/.
---

# PDS Development System Skill

Reference for reverse-engineering code written with the PDS (Programmers
Development System) cross-development toolchain. Optimized for working with
**Codemasters NES titles** but covers the full PDS stack.

> **How to use**: Read this file for quick reference. For deep dives on
> specific topics, consult the reference files:
>
> | File | Contents |
> |------|----------|
> | `references/hardware-interface.md` | Z80 PIO version, alternate version, ISA card, port maps |
> | `references/transfer-protocol.md` | DL0/DL1/DL2, `send computer`, `master` flag, bank transfer |
> | `references/assembler-syntax.md` | PDS 6502 directives, macros, reversed `>`/`<`, ca65 comparison |
> | `references/project-structure.md` | .PRJ files, file types, build order, bank layout |
> | `references/debugger-remnants.md` | Debug vectors, Z80-isms, identifying PDS code in compiled ROMs |

---

## Quick Overview

PDS = **Programmers Development System**, created by **Andy Glaister** in the
mid-1980s. The company **PD Systems** (formed with Jacqui Lyons and Fouad Katan)
sold approximately **500 units** to UK game development studios.

| Component | Details |
|-----------|---------|
| Host machine | Apricot PC (early IBM PC clone, 960K RAM, ISA bus) |
| Targets | Amstrad CPC, C64, MSX, ZX Spectrum, BBC, NES (via 6502 version) |
| Software | Assembler (Z80 + 6502), editor, debugger, profiler, graphics tool |
| Hardware | ISA card in PC + interface board on target, connected by 16-pin ribbon cable |
| Transfer | PC assembles code, sends binary over cable to target for execution/debugging |

---

## PDS in This Project

The `original_source/` directory contains (or will contain) Codemasters source
files written for PDS. Manuals and documentation are at `original_source/docs/`.

### Known PDS Manuals

| Manual | Year | Contents |
|--------|------|----------|
| The PDS Z80 Manual | 1987 | Z80 assembler, debugger, transfer protocol |
| The PDS 6502 Manual | — | 6502 assembler, debugger, transfer protocol |
| The PDS Editor Manual | 1988 | PC-side editor (2nd edition) |
| PDS Guide (early) | — | 4-page quick start |
| P.D.S. Manual | 1987 | Assembler directives, download protocol, debugger (54 pages) |

---

## Hardware Quick Reference

### V1 — Z80 PIO Interface (CPC Expansion Port)

```
$FBEC  Z80 PIO Port A Data    8-bit bidirectional data to/from PC
$FBED  Z80 PIO Port B Data    Handshake signals (see below)
$FBEE  Z80 PIO Port A Control
$FBEF  Z80 PIO Port B Control
```

**Handshake bits (Port $FBED):**

| Bit | Direction | Purpose |
|-----|-----------|---------|
| 0 | From PC | Clock (data on BOTH rising AND falling edges) |
| 1–4 | — | Unknown / not connected (Spectrum schematic) |
| 5 | Bidirectional? | Unknown — possibly IRQ |
| 6 | To target | Data direction for 74LS245 transceiver |
| 7 | To PC | Clock/acknowledge (signals BOTH edges) |

**Components:** Z80 PIO, 74LS245 (bidirectional buffer), 74LS04 (hex inverter),
74LS32 (quad OR), reset button, 2×8-pin connector to PC via flat cable.

### V2 — Alternate Interface (No Z80 PIO)

```
$FBEC  Unknown (config or REQUEST to PC)
$FBED  Data to PC
$FBEE  Bit 0 = CLK signal from PC
$FBEF  Data from PC
```

Less stable handshake — may require PC to disable interrupts during transfer.
Possibly an older PDS revision or third-party remake.

**Games with V2 remnant code:** Gremlins, Robin of Sherwood, Seablood (Seas of
Blood), The Last V8 — all Adventure Soft / Mastertronic UK titles.

> **Full hardware details: `references/hardware-interface.md`**

---

## Assembler Quick Reference

### Key Directives

| Directive | Example | Purpose |
|-----------|---------|---------|
| `project` | `project "SUPER ROBIN HOOD"` | Project name |
| `asmflag` | `asmflag 0` | Assembly flags/options |
| `path` | `path c:\nes\robin` | Include search path |
| `org` | `org &8000` | Set origin address |
| `bank` | `bank 12` | Switch to ROM bank |
| `send computer1` | *(end of file)* | Transfer to target via cable |
| `LIST ON/OFF` | | Toggle listing output |
| `free` | `free b13` | Report free space in bank |
| `CURCOLOUR` | `CURCOLOUR RED ON GREEN` | Editor color for file |
| `OPTION` | `OPTION 0,0` | Assembler options |
| `ASSEMBLER` | *(in .PRJ)* | Trigger build |

### Numeric Syntax

| Syntax | Meaning | Example |
|--------|---------|---------|
| `&` | Hex prefix | `&8000` = $8000 |
| `$` | Also hex (6502 version) | `$FF` |
| `#` | Immediate | `lda #&20` |
| `>` | **LOW byte** | `lda #>label` → low byte of label |
| `<` | **HIGH byte** | `lda #<label` → high byte of label |

> **⚠️ CRITICAL: `>` and `<` are REVERSED from ca65 / standard 6502 convention!**
> In ca65: `<` = low byte, `>` = high byte. In PDS: `>` = low byte, `<` = high byte.
> This is the single most confusing PDS-ism when reading original source.

### Macro System

- `@1`–`@9`: positional parameters
- `!1`–`!9`: local labels (scoped to macro expansion)
- `ifs [@N] []`: test if optional parameter was supplied
- `macro` / `endm`: definition delimiters

> **Full syntax reference: `references/assembler-syntax.md`**

---

## Debug Vectors

| Address | Name | Purpose |
|---------|------|---------|
| `$FFF2` | `CHECKPDS` | Check if PDS debugger is connected |
| `$FFED` | `BREAKPOINT` | Trigger PDS debugger breakpoint |
| `$FFE4` | `ANALYZE` | Trigger PDS profiler/analyzer |

These vectors point to PDS debugger stubs in target RAM. Only functional when
the PDS cable is connected. In production builds (`master equ 1`), these are
NOPed out or unreachable.

**Alias:** Some source files use `testpds = $fff2` instead of `CHECKPDS`.

---

## Identifying PDS Code in Disassembly

When disassembling compiled ROMs, look for these PDS fingerprints:

1. **Debug vectors**: `JSR $FFF2`, `JSR $FFED`, `JMP $FFE4` — leftover debug calls
2. **Z80-ism macros**: `ldir`, `lddr`, `sldir`, `slddr` (Z80 block copy reimplemented for 6502)
3. **68K-style naming**: `move.w`, `move.b`, `add`, `sub` wrappers around 6502 ops
4. **Z80 register naming**: `cphlde` (compare HL vs DE), `ldxy` (load X/Y pair)
5. **`zvar`/`var` pattern**: auto-allocating variable macros for zero page and RAM
6. **Bank padding**: banks filled with `$00` (from `defs &4000,0`)
7. **`send computer1`** in source files — confirms PDS toolchain
8. **Reversed `>`/`<`** in source — `lda #>@1` loads low byte, not high
9. **Port $FBEC–$FBEF** references in data sections — leftover CPC interface code

> **Full identification guide: `references/debugger-remnants.md`**

---

## Known Games with PDS Code Remnants

| Game | Publisher | Platform | Notes |
|------|-----------|----------|-------|
| Gremlins | Adventure Soft | CPC | Spanish version contains debug I/O code |
| Robin of Sherwood | Adventure Soft | CPC | Port FBEC-FBEF access |
| Seablood (Seas of Blood) | Adventure Soft | CPC | Port FBEC-FBEF access |
| The Last V8 | Mastertronic | CPC | Uses port FBED for data to PC |

All use the alternate (V2) interface, not the Z80 PIO version.

> **For Codemasters NES game list and hardware details, see the NES skill.**
