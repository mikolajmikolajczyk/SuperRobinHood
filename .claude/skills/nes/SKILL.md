---
name: nes-reverse-engineering
description: >
  Comprehensive NES/Famicom reverse engineering reference for Claude Code.
  Covers the full CPU and PPU memory maps, all hardware registers, iNES/NES 2.0 ROM
  format, mapper mechanics, the APU, and available toolchains (assemblers,
  disassemblers, emulator-debuggers). Contains deep coverage of Codemasters /
  Camerica unlicensed cartridge hardware (Mapper 71, Mapper 232, BF909x chips,
  Aladdin Deck Enhancer, CIC stun circuit) because the primary use-case is
  reverse-engineering Codemasters NES titles.
  Use this skill whenever the user mentions NES, Famicom, 6502, 2A03, PPU, APU,
  iNES, NES ROM hacking, NES disassembly, NES memory map, Codemasters, Camerica,
  Dizzy, Micro Machines, Game Genie, mapper 71, mapper 232, Aladdin Deck Enhancer,
  or any NES reverse-engineering topic. Also trigger for general 6502 assembly
  questions in an NES context.
---

# NES Reverse Engineering Skill

This skill is a comprehensive reference for reverse-engineering NES (Nintendo
Entertainment System) / Famicom games. It is optimized for working with
**Codemasters / Camerica** unlicensed titles but covers the full NES hardware
stack.

> **How to use**: Read this file top-to-bottom when starting a new RE project.
> For deep dives on specific topics, consult the reference files:
>
> | File | Contents |
> |------|----------|
> `references/cpu-memory-map.md` | Full CPU address space with register details |
> `references/ppu-memory-map.md` | PPU address space, nametables, palettes, OAM |
> `references/apu-registers.md` | APU channel registers and frame counter |
> `references/ines-format.md` | iNES and NES 2.0 header specification |
> `references/mappers.md` | Common mappers with focus on Codemasters hardware |
> `references/codemasters.md` | Complete Codemasters/Camerica game catalog, quirks, RE tips |
> `references/toolchains.md` | Assemblers, disassemblers, emulator-debuggers, utilities |

---

## Quick Architecture Overview

### Hardware Summary

| Component | Chip | Details |
|-----------|------|---------|
| CPU | Ricoh 2A03 (NTSC) / 2A07 (PAL) | Modified MOS 6502, **no decimal mode** |
| Clock | 1.789773 MHz (NTSC) / 1.662607 MHz (PAL) | Master ÷ 12 (NTSC) or ÷ 16 (PAL) |
| CPU RAM | 2 KiB | $0000–$07FF, mirrored 3× to $1FFF |
| PPU | Ricoh 2C02 (NTSC) / 2C07 (PAL) | Separate 14-bit address bus |
| PPU VRAM | 2 KiB (internal CIRAM) | Provides 2 nametables |
| OAM | 256 bytes (internal to PPU) | 64 sprites × 4 bytes |
| Palette | 32 bytes (internal to PPU) | 4 BG + 4 sprite palettes |
| APU | Integrated in 2A03/2A07 | 5 channels |
| Resolution | 256×240 pixels | 262 scanlines (NTSC), 312 (PAL) |

### CPU Registers (6502)

| Register | Width | Purpose |
|----------|-------|---------|
| A | 8-bit | Accumulator |
| X | 8-bit | Index register X |
| Y | 8-bit | Index register Y |
| SP | 8-bit | Stack pointer (page $01) |
| PC | 16-bit | Program counter |
| P | 8-bit | Status: NV-BDIZC |

The 2A03 is a stock 6502 core **without decimal mode** — `SED`/`CLD` are no-ops.
All 151 official opcodes plus all "illegal" opcodes execute identically to a
standard NMOS 6502.

---

## CPU Memory Map (Quick Reference)

```
$0000–$00FF   Zero Page (256 bytes, fast addressing modes)
$0100–$01FF   Stack (grows downward from $01FF)
$0200–$07FF   General-purpose RAM (commonly $0200 = OAM DMA buffer)
$0800–$1FFF   Mirrors of $0000–$07FF (×3)
$2000–$2007   PPU registers (8 regs)
$2008–$3FFF   Mirrors of $2000–$2007 (every 8 bytes)
$4000–$4013   APU registers
$4014         OAM DMA
$4015         APU status (R/W)
$4016         Controller 1 / strobe
$4017         Controller 2 / APU frame counter
$4018–$401F   APU test registers (normally disabled)
$4020–$5FFF   Expansion area (mapper-dependent)
$6000–$7FFF   PRG-RAM / WRAM / battery-backed SRAM (mapper-dependent)
$8000–$BFFF   PRG-ROM lower bank (switchable on most mappers)
$C000–$FFFF   PRG-ROM upper bank (often fixed to last bank)
$FFFA–$FFFB   NMI vector
$FFFC–$FFFD   RESET vector
$FFFE–$FFFF   IRQ/BRK vector
```

> **For the full register-level breakdown, read `references/cpu-memory-map.md`.**

---

## PPU Memory Map (Quick Reference)

```
$0000–$0FFF   Pattern Table 0 (4 KiB, typically CHR-ROM bank 0, "left")
$1000–$1FFF   Pattern Table 1 (4 KiB, typically CHR-ROM bank 1, "right")
$2000–$23BF   Nametable 0 (960 tiles)
$23C0–$23FF   Attribute Table 0 (64 bytes)
$2400–$27BF   Nametable 1
$27C0–$27FF   Attribute Table 1
$2800–$2BBF   Nametable 2 (mirror, depends on cart wiring)
$2BC0–$2BFF   Attribute Table 2
$2C00–$2FBF   Nametable 3
$2FC0–$2FFF   Attribute Table 3
$3000–$3EFF   Mirror of $2000–$2EFF
$3F00–$3F0F   Background palette (16 bytes, 4 palettes × 4 colors)
$3F10–$3F1F   Sprite palette (16 bytes, 4 palettes × 4 colors)
$3F20–$3FFF   Mirrors of $3F00–$3F1F
```

Nametable mirroring depends on cartridge wiring:
- **Horizontal** (vertical arrangement): NT0=NT1, NT2=NT3
- **Vertical** (horizontal arrangement): NT0=NT2, NT1=NT3
- **Single-screen**: All 4 map to same physical page
- **Four-screen**: Requires extra VRAM on cart (rare)

> **For full PPU register details, read `references/ppu-memory-map.md`.**

---

## PPU Registers (CPU-side, $2000–$2007)

| Addr | Name | R/W | Bits | Purpose |
|------|------|-----|------|---------|
| $2000 | PPUCTRL | W | VPHB SINN | NMI enable, sprite size, BG/sprite pattern table, VRAM increment, nametable select |
| $2001 | PPUMASK | W | BGRs bMmG | Color emphasis, sprite/BG enable, left-column clip, greyscale |
| $2002 | PPUSTATUS | R | VSO- ---- | Vblank flag (V), sprite 0 hit (S), sprite overflow (O) |
| $2003 | OAMADDR | W | aaaa aaaa | OAM address |
| $2004 | OAMDATA | R/W | dddd dddd | OAM data read/write |
| $2005 | PPUSCROLL | W×2 | xxxx xxxx | Scroll X (1st write), Scroll Y (2nd write) |
| $2006 | PPUADDR | W×2 | aaaa aaaa | VRAM address high (1st), low (2nd) |
| $2007 | PPUDATA | R/W | dddd dddd | VRAM data read/write (auto-increments) |
| $4014 | OAMDMA | W | pppp pppp | DMA page → OAM (copies 256 bytes, costs 513–514 cycles) |

**Important**: Reading $2002 clears the vblank flag and resets the $2005/$2006
write toggle (the "latch"). This is fundamental to NES programming.

---

## Codemasters / Camerica — Key Facts

Codemasters games for the NES were **unlicensed**. They used custom hardware
to bypass Nintendo's CIC (10NES) lockout chip. Key technical details:

### Mappers Used

| Mapper | iNES # | Chip | Used By |
|--------|--------|------|---------|
| Camerica BF9093 | 71 (sub 0) | BF9093 | Most single-game carts (Micro Machines, Dizzy, Bee 52, etc.) |
| Camerica BF9097 | 71 (sub 1) | BF9097 | Fire Hawk only (mapper-controlled 1-screen mirroring) |
| Camerica BF9096 | 232 | BF9096 | Quattro multicarts |
| Aladdin CCU | 71 | CCU | Aladdin Deck Enhancer compact carts |

### Mapper 71 — How It Works

Functionally a **UNROM clone** without bus conflicts:

- **$C000–$FFFF write**: Select 16 KiB PRG-ROM bank for $8000–$BFFF
  - BF9093: 4-bit bank select (up to 256 KiB)
  - BF9097: 3-bit bank select (128 KiB)
- **$8000–$BFFF**: Fixed to last bank (same as UNROM)
- **CHR**: All carts use 8 KiB CHR-RAM (no CHR-ROM)
- **Mirroring**: Hard-wired H or V on most boards
  - Exception: Fire Hawk (BF9097) has register at $9000 for 1-screen mirroring
- **CIC stun**: Bit 0 of writes to $E000–$FFFF controls the lockout defeat
  circuit (irrelevant for emulation)
- **No bus conflicts**: Unlike real UNROM, Camerica boards don't have bus
  conflicts. This matters — Dreamworld Pogie has a bug if bus conflicts are
  emulated.

### Mapper 232 — Quattro Multicarts

- Same chip family (BF9096)
- $8000–$9FFF: Outer bank select (2 bits → 64 KiB super-banks)
- $C000–$FFFF: Inner bank select (2 bits within super-bank)
- Each Quattro cart contains 4 × 64 KiB games
- NES 2.0 submapper 1 distinguishes swapped bank wiring (some revisions)

### Codemasters Game List (NES)

**Single-game standalone carts (Mapper 71):**
- Bee 52
- Bignose the Caveman
- Bignose Freaks Out
- Cosmic Spacehead (PAL only)
- Dreamworld Pogie
- Fantastic Adventures of Dizzy
- Fantastic Dizzy (PAL only)
- Fire Hawk (Mapper 71 submapper 1)
- Linus Spacehead's Cosmic Crusade
- Micro Machines (multiple revisions)
- MiG 29: Soviet Fighter (uses DMC IRQs — timing-sensitive!)
- Mystery World Dizzy
- Stunt Kids
- Ultimate Stuntman
- Wonderland Dizzy

**Quattro multicarts (Mapper 232):**
- Quattro Adventure (Linus Spacehead, Super Robin Hood, Boomerang Kid, Treasure Island Dizzy)
- Quattro Arcade (CJ's Elephant Antics, Stunt Buggies, F16 Renegade, Go! Dizzy Go!)
- Quattro Sports (Baseball Pros, Soccer Simulator, Pro Tennis, BMX Simulator)

**Aladdin Deck Enhancer (Mapper 71/CCU, compact carts):**
- Dizzy the Adventurer (pack-in)
- Fantastic Adventures of Dizzy
- Linus Spacehead's Cosmic Crusade
- Micro Machines
- Bignose Freaks Out
- Quattro Adventure
- Quattro Sports

### Codemasters Quirks for RE

1. **Smiley test**: All Codemasters NES games have a built-in ROM/RAM test.
   Hold all D-pad + A (PRG) and/or B (CHR) + Start + Select while resetting.
   Green smiley = pass, red frown = fail.

2. **Illegal palette color $0D**: Many Codemasters games use palette value $0D
   ("blacker than black") which causes problems on some TVs. Later PAL versions
   partially fixed this to $0E.

3. **MiG 29 timing**: Uses DMC IRQs and is extremely sensitive to APU timing.
   If your DMC IRQ implementation is off, the game glitches heavily.

4. **Fire Hawk mirroring**: Only Codemasters game using mapper-controlled
   single-screen mirroring. Writes to $9000 to toggle. Other games write $00
   to $8000 on startup — emulators use heuristics to distinguish.

5. **PAL timing**: Some games (Micro Machines v1) have timing bugs that prevent
   them from working on PAL hardware. Later revisions fixed these.

6. **No bus conflicts**: Unlike standard UNROM, Camerica boards have no bus
   conflicts because the BF909x chip decodes addresses instead of relying on
   ROM output. This is critical for accurate emulation of Dreamworld Pogie.

---

## Reverse Engineering Workflow

### Recommended Approach

1. **Identify the ROM**: Parse iNES header → determine mapper, PRG/CHR sizes,
   mirroring type. For Codemasters games, expect Mapper 71 or 232, CHR-RAM,
   and H or V mirroring.

2. **Load in emulator-debugger**: Use **Mesen** or **FCEUX** with Code/Data
   Logger (CDL) enabled. Play through the game to tag code vs data regions.

3. **Export CDL + labels**: Both emulators support symbolic debugging — name
   variables/subroutines as you discover them.

4. **Disassemble**: Use **da65** (from cc65 suite) or **nesgodisasm** with the
   CDL data to produce a recompilable disassembly. Feed the info file with
   known labels.

5. **Iterate**: Reassemble with ca65/ld65, diff against original ROM. Compare
   early and often to catch drift.

6. **Map RAM**: Use the emulator's RAM watch / hex editor. NES games typically
   organize RAM in blocks — see `references/cpu-memory-map.md` for common
   patterns.

### For Codemasters Games Specifically

- Mapper 71 is simple — bank switching is just writes to $C000–$FFFF.
  The switchable bank appears at $8000–$BFFF; the last bank is fixed at
  $C000–$FFFF. Start disassembly from the RESET vector in the fixed bank.

- CHR-RAM means the game copies tile data to VRAM at runtime (during vblank
  or with rendering off). Look for routines that write to PPUDATA ($2007) or
  do large block copies.

- The smiley test code is usually near the RESET vector — it checks a button
  combo, then runs a simple checksum over PRG-ROM and writes test patterns to
  CHR-RAM. You can identify and label this early.

- For Quattro multicarts (Mapper 232), the menu code is in the outer bank 0
  and each sub-game occupies its own 64 KiB super-bank.

> **For complete toolchain details, read `references/toolchains.md`.**
> **For full Codemasters hardware docs, read `references/codemasters.md`.**
> **For mapper details beyond Codemasters, read `references/mappers.md`.**
