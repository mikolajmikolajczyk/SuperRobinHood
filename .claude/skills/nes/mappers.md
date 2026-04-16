# NES Mappers Reference

Mappers are cartridge hardware that extends the NES beyond its base address
space limits. They control bank switching, mirroring, IRQ generation, and
sometimes provide extra RAM or audio channels.

## Mapper Identification

The mapper number is stored in the iNES header (bytes 6-7, extended in NES 2.0).
Each mapper defines how the cartridge's PRG-ROM, CHR-ROM/RAM, and other
hardware are mapped into the CPU and PPU address spaces.

## Most Common Mappers

### Mapper 0 — NROM (No mapper)
- PRG: 16 KiB or 32 KiB, no bank switching
- CHR: 8 KiB ROM
- If 16 KiB PRG: $8000–$BFFF = ROM, $C000–$FFFF = mirror
- If 32 KiB PRG: $8000–$BFFF = bank 0, $C000–$FFFF = bank 1
- Examples: Super Mario Bros, Donkey Kong, Excitebike

### Mapper 1 — MMC1 (Nintendo)
- PRG: Up to 256 KiB, switchable in 16 KiB or 32 KiB units
- CHR: Up to 128 KiB, switchable in 4 KiB or 8 KiB units
- PRG-RAM: Up to 32 KiB (battery-backed possible)
- Serial register: write 5 bits one at a time (bit 0 via D0, reset via D7)
- Mirroring: mapper-controlled (H, V, single-screen 0 or 1)
- Examples: Legend of Zelda, Metroid, Mega Man 2

### Mapper 2 — UxROM
- PRG: Up to 256 KiB (4 Mbit), 16 KiB switchable + 16 KiB fixed
- CHR: 8 KiB RAM (no CHR-ROM)
- Bank select: write to $8000–$FFFF, low bits select $8000 bank
- $C000–$FFFF: fixed to last bank
- **Has bus conflicts** on original hardware (CPU write ANDed with ROM output)
- Mirroring: hard-wired
- Examples: Contra, Mega Man, Castlevania, DuckTales

### Mapper 3 — CNROM
- PRG: 16 KiB or 32 KiB, no switching
- CHR: Up to 32 KiB ROM, switchable in 8 KiB units
- Bank select: write to $8000–$FFFF selects CHR bank
- Examples: Solomon's Key, Arkanoid

### Mapper 4 — MMC3 (Nintendo)
- PRG: Up to 512 KiB, 8 KiB switchable banks
- CHR: Up to 256 KiB, 1 KiB and 2 KiB switchable banks
- PRG-RAM: 8 KiB at $6000–$7FFF (optional battery)
- Scanline counter: generates IRQ after N scanlines
- Mirroring: mapper-controlled (H or V)
- Very complex — 8 bank select registers
- Examples: Super Mario Bros. 3, Kirby's Adventure, Mega Man 3-6

### Mapper 7 — AxROM
- PRG: Up to 256 KiB, switchable in 32 KiB units
- CHR: 8 KiB RAM
- Single-screen mirroring (mapper-controlled, selects CIRAM page)
- No bus conflicts on AOROM; has bus conflicts on ANROM
- Examples: Battletoads, Marble Madness, Wizards & Warriors

### Mapper 9 — MMC2 (Nintendo)
- Latch-based CHR switching (triggered by specific tile fetches)
- Used only by Punch-Out!! and Mike Tyson's Punch-Out!!

### Mapper 11 — Color Dreams
- PRG: switchable 32 KiB banks
- CHR: switchable 8 KiB banks
- Write to $8000–$FFFF: bits 0-1 = PRG bank, bits 4-5 = CHR bank
- Bits 2-3 control CIC stun circuit
- Used by Color Dreams and Wisdom Tree unlicensed games

---

## Codemasters / Camerica Mappers (Detailed)

### Mapper 71 — Camerica BF9093/BF9097/CCU

**Used by**: All Codemasters single-game NES carts + Aladdin Deck Enhancer

This is functionally a UNROM clone **without bus conflicts**.

#### Bank Switching Register: $C000–$FFFF
```
7654 3210
xxxx PPPP
     ||||
     ++++- Select 16 KiB PRG-ROM bank at $8000–$BFFF
```
- BF9093: 4 bits → up to 16 banks (256 KiB)
- BF9097: 3 bits → up to 8 banks (128 KiB)
- BF9096: 2 bits (inner bank) — see Mapper 232

$C000–$FFFF is always fixed to the last bank.

#### CIC Stun Register: $E000–$FFFF
Bit 0 of the written value latches as the inverse of CPU A0 to control
the lockout defeat circuit. Irrelevant for emulation.

#### Mirroring Control (Fire Hawk only): $9000–$9FFF
```
7654 3210
xxxx xxMx
         |
         +- Select nametable: 0=CIRAM page 0, 1=CIRAM page 1
```
Only Fire Hawk (BF9097, submapper 1) uses this. All other games on Mapper 71
have hard-wired H or V mirroring.

**Emulator compatibility note**: Micro Machines and Ultimate Stuntman write
$00 to $8000 on startup. FCEUX heuristically ignores mirroring writes to
$8000–$8FFF and only applies them at $9000–$9FFF. NES 2.0 submapper 1
formally distinguishes Fire Hawk.

#### Submappers
| Submapper | Mirroring | Chip | Example Games |
|-----------|-----------|------|---------------|
| 0 | Hard-wired H or V | BF9093, CCU | Most Codemasters games |
| 1 | Mapper-controlled 1-screen | BF9097 | Fire Hawk |

### Mapper 232 — Camerica BF9096 (Quattro)

**Used by**: Quattro Adventure, Quattro Arcade, Quattro Sports

Two-level bank switching for multicarts:

#### Outer Bank: $8000–$9FFF
```
7654 3210
---B B---
   | |
   +-+--- Select 64 KiB super-bank (outer bank)
```

#### Inner Bank: $A000–$FFFF (some docs say $C000–$FFFF)
```
7654 3210
---- --PP
       ||
       ++- Select 16 KiB PRG bank within super-bank
```

The last 16 KiB bank within the selected super-bank is fixed at $C000–$FFFF.

**NES 2.0 submapper 1**: Some Quattro cart revisions have the outer bank bits
wired differently (banks 2 and 3 are swapped). The submapper distinguishes
these revisions.

### BF909x Chip Pinouts

All three chips share the same 20-pin DIP package:

```
        BF9093              BF9096              BF9097
       .--v--.             .--v--.             .--v--.
+5V --|01  20|-- CPU A14  +5V --|01  20|-- CPU A14  +5V --|01  20|-- CPU A14
R/W --|02  19|-- CPU A13  R/W --|02  19|-- CPU A13  R/W --|02  19|-- CPU A13
/CE --|03  18|-- PRG A14  /CE --|03  18|-- PRG A14  /CE --|03  18|-- PRG A14
A14 --|04  17|-- PRG A15  A14 --|04  17|-- A17out   A14 --|04  17|-- A17out
 M2 --|05  16|-- ??        M2 --|05  16|-- ??        M2 --|05  16|-- PRG A15
 A0 --|06  15|-- /ROMSEL   A0 --|06  15|-- /ROMSEL   A0 --|06  15|-- ??
 D0 --|07  14|-- PRG A16   D0 --|07  14|-- A16out    D0 --|07  14|-- /ROMSEL
 D1 --|08  13|-- CIC stun  D1 --|08  13|-- CIC stun  D1 --|08  13|-- CIC stun
 D2 --|09  12|-- D4        D2 --|09  12|-- D4        D2 --|09  12|-- D4
GND --|10  11|-- D3       GND --|10  11|-- D3       GND --|10  11|-- D3
       '------'             '------'             '------'
```

---

## Other Notable Unlicensed Mappers

### Mapper 11 — Color Dreams
Nibble-swapped GNROM variant. Bits 0-1 = PRG bank, bits 4-5 = CHR bank,
bits 2-3 = CIC stun.

### Mapper 79 — AVE NINA-06
Simple 32 KiB PRG + 8 KiB CHR switching.

### Mapper 34 — BxROM / NINA-001
32 KiB PRG switching. NINA-001 also switches CHR.

---

## Mapper RE Tips

1. **Identify mapper writes**: Set write breakpoints on $8000–$FFFF in your
   debugger. Watch what values are written — these are bank switch commands.

2. **Cross-bank references**: When disassembling bankswitched games, beware of
   code in the switchable bank calling code in the fixed bank (and vice versa).
   The fixed bank often has "trampoline" routines that switch banks and JMP.

3. **Bank tables**: Many games store bank numbers in lookup tables. Finding
   these tables helps map out the ROM structure.

4. **CHR-RAM games**: If CHR size in header is 0, the game uses CHR-RAM.
   Look for VRAM write routines that copy tile data during vblank. This is
   the norm for all Codemasters games.

5. **Mirroring changes**: If you see writes to mirroring-control addresses
   during gameplay, the game is doing scroll-direction changes or split-screen
   effects. Fire Hawk does this for its 1-screen mirroring.
