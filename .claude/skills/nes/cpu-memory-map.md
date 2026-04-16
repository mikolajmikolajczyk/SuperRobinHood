# CPU Memory Map — Full Reference

## Address Space Overview

The NES CPU (Ricoh 2A03) has a 16-bit address bus giving a 64 KiB address space.
The CPU itself contains only 2 KiB of RAM. Everything else is either
memory-mapped I/O or provided by the cartridge.

## $0000–$1FFF: Internal RAM (2 KiB + mirrors)

### $0000–$00FF: Zero Page (256 bytes)
- Fastest addressing modes (fewer bytes, fewer cycles)
- Use for frequently accessed variables, pointers, loop counters
- Games typically divide this among engine subsystems

### $0100–$01FF: Stack (256 bytes)
- Hardware stack, grows downward from $01FF
- SP register points within this page (8-bit, implicitly in page $01)
- JSR pushes 2 bytes (return address - 1), RTI/RTS pops them
- PHA/PHP push accumulator/status

### $0200–$07FF: General RAM (1.5 KiB)
- $0200–$02FF: Almost universally used as OAM shadow buffer
  (copied to PPU OAM via $4014 DMA each vblank)
- $0300–$07FF: Game-specific (enemy tables, level data, sound engine state)

### $0800–$1FFF: RAM Mirrors
- $0800–$0FFF mirrors $0000–$07FF
- $1000–$17FF mirrors $0000–$07FF
- $1800–$1FFF mirrors $0000–$07FF
- Hardware decoding: address bits 11-12 are ignored (addr & $07FF)

### Common RAM Layout Patterns (RE tips)

Most NES games organize RAM in "blocks" of 256 bytes (pages):

| Page | Common Use |
|------|-----------|
| $00xx | Zero page: pointers, counters, temp vars, game state flags |
| $01xx | Stack |
| $02xx | OAM shadow (sprite data for DMA) |
| $03xx | Object/enemy attribute tables (HP, type, state) |
| $04xx | Object/enemy positions (X coords or sprite IDs) |
| $05xx | Object/enemy positions (Y coords or movement data) |
| $06xx | Level/map data or sound engine workspace |
| $07xx | Miscellaneous / sound engine |

**For RE**: If you find one enemy stat (e.g., HP at $0300), check the entire
$03xx row — each column offset likely corresponds to a different entity slot.
Player is typically in column 0 ($0300, $0400, $0500...).

## $2000–$3FFF: PPU Registers (8 regs, mirrored)

| Address | Name | R/W | Description |
|---------|------|-----|-------------|
| $2000 | PPUCTRL | W | Control register 1 |
| $2001 | PPUMASK | W | Control register 2 (rendering) |
| $2002 | PPUSTATUS | R | Status register |
| $2003 | OAMADDR | W | OAM address |
| $2004 | OAMDATA | R/W | OAM data |
| $2005 | PPUSCROLL | W×2 | Scroll position (X then Y) |
| $2006 | PPUADDR | W×2 | VRAM address (high then low) |
| $2007 | PPUDATA | R/W | VRAM data (auto-increments) |

Mirrored every 8 bytes: $2008–$3FFF. Write to $3456 = write to $2006.

### PPUCTRL ($2000) bit fields
```
7654 3210
VPHB SINN
|||| ||||
|||| ||++- Base nametable address (0=$2000, 1=$2400, 2=$2800, 3=$2C00)
|||| |+--- VRAM address increment per PPUDATA R/W (0=+1 across, 1=+32 down)
|||| +---- Sprite pattern table for 8×8 sprites (0=$0000, 1=$1000)
|||+------ Background pattern table address (0=$0000, 1=$1000)
||+------- Sprite size (0=8×8, 1=8×16)
|+-------- PPU master/slave select (unused on NES)
+--------- Generate NMI at start of vblank (0=off, 1=on)
```

### PPUMASK ($2001) bit fields
```
7654 3210
BGRs bMmG
|||| ||||
|||| |||+- Greyscale (0=normal, 1=greyscale)
|||| ||+-- Show background in leftmost 8 pixels (0=clip, 1=show)
|||| |+--- Show sprites in leftmost 8 pixels (0=clip, 1=show)
|||| +---- Show background (0=off, 1=on)
|||+------ Show sprites (0=off, 1=on)
||+------- Emphasize red (green on PAL)
|+-------- Emphasize green (red on PAL)
+--------- Emphasize blue
```

### PPUSTATUS ($2002) bit fields
```
7654 3210
VSO. ....
||+------- Sprite overflow (buggy on real hardware)
|+-------- Sprite 0 hit
+--------- Vblank flag (cleared on read, set at scanline 241)
```

### OAM Entry Format (4 bytes per sprite, 64 sprites)
```
Byte 0: Y position (top of sprite, 1 scanline delay)
Byte 1: Tile index
         - 8×8 mode: tile number in selected pattern table
         - 8×16 mode: bit 0 selects pattern table, bits 7-1 = tile
Byte 2: Attributes
         7654 3210
         VHP. ..PP
         ||+---++-- Palette (4-7)
         |+-------- Priority (0=in front of BG, 1=behind BG)
         +--------- Flip vertically
          +-------- Flip horizontally
Byte 3: X position (left edge of sprite)
```

## $4000–$4017: APU & I/O Registers

| Range | Channel/Function |
|-------|-----------------|
| $4000–$4003 | Pulse 1 (duty, envelope, sweep, timer, length) |
| $4004–$4007 | Pulse 2 |
| $4008–$400B | Triangle (linear counter, timer, length) |
| $400C–$400F | Noise (envelope, mode/period, length) |
| $4010–$4013 | DMC/DPCM (flags/rate, direct load, sample addr, sample length) |
| $4014 | OAM DMA (write page number, triggers 256-byte copy) |
| $4015 | APU Status (R/W: enable/disable channels, read status) |
| $4016 | Controller 1 (W: strobe, R: serial button data) |
| $4017 | Controller 2 (R) / APU Frame Counter (W) |

> See `apu-registers.md` for full APU register bit fields.

### Controller Read Sequence
```
; Strobe controllers
LDA #$01
STA $4016
LDA #$00
STA $4016
; Now read 8 times from $4016 for controller 1
; Each read returns 1 button in bit 0: A, B, Select, Start, Up, Down, Left, Right
```

## $4018–$401F: APU Test Registers
Normally disabled (active only when pin 30 is pulled high on 2A03).
Cartridges should not map readable memory here due to DMA quirk.

## $4020–$5FFF: Expansion Area (8 KiB)
Mapper-dependent. Examples:
- MMC5: ExRAM, expansion audio
- FDS: Disk I/O registers
- Most simple mappers: unmapped (open bus)

## $6000–$7FFF: PRG-RAM / WRAM / SRAM (8 KiB)
- Battery-backed save RAM (e.g., Zelda, Final Fantasy)
- Work RAM for larger games
- Some mappers bank-switch this region
- Not all carts have RAM here — if absent, reads return open bus

## $8000–$FFFF: PRG-ROM (32 KiB window)
- Simplest layout (NROM): $8000–$BFFF = bank 0, $C000–$FFFF = bank 1
  (or mirrored if only 16 KiB)
- Bankswitched mappers: one or both 16 KiB halves can be swapped
- Common convention: $C000–$FFFF fixed to last bank (contains vectors)

### Interrupt Vectors (always in PRG-ROM)
```
$FFFA–$FFFB: NMI handler address (triggered by PPU at vblank if enabled)
$FFFC–$FFFD: RESET handler address (executed on power-on / reset)
$FFFE–$FFFF: IRQ/BRK handler address (triggered by mapper IRQ, APU IRQ, or BRK)
```

**These vectors MUST be present in whichever bank is mapped to $C000–$FFFF.**
For bankswitched games, the fixed bank always contains these vectors plus a
stub that dispatches to the correct bank.

## Open Bus Behavior

Reading from unmapped addresses returns "open bus" — the last value that was
on the data bus. This is usually the high byte of the address being read, but
cartridge hardware can influence it. For RE, if you see reads from unmapped
space, the code may be relying on open bus values (rare but it happens).
