# iNES and NES 2.0 ROM Format

## File Structure

```
[Header]    16 bytes
[Trainer]   512 bytes (optional, if bit 2 of flags 6 is set)
[PRG-ROM]   N × 16384 bytes
[CHR-ROM]   N × 8192 bytes (absent if CHR-RAM)
```

## iNES Header (16 bytes)

| Byte | Content |
|------|---------|
| 0–3 | Magic: `NES\x1A` (ASCII "NES" + MS-DOS EOF) |
| 4 | PRG-ROM size in 16 KiB units |
| 5 | CHR-ROM size in 8 KiB units (0 = uses CHR-RAM) |
| 6 | Flags 6 |
| 7 | Flags 7 |
| 8 | PRG-RAM size in 8 KiB units (0 infers 8 KiB for compat) |
| 9 | Flags 9 (TV system) |
| 10 | Flags 10 (unofficial, rarely used) |
| 11–15 | Padding (should be zero) |

### Flags 6 (byte 6)
```
7654 3210
NNNN FTBM
|||| ||||
|||| |||+- Mirroring: 0=horizontal, 1=vertical
|||| ||+-- Battery-backed PRG-RAM at $6000–$7FFF
|||| |+--- 512-byte trainer at $7000–$71FF
|||| +---- Four-screen VRAM (ignore mirroring bit)
++++------ Lower 4 bits of mapper number
```

### Flags 7 (byte 7)
```
7654 3210
NNNN SSPV
|||| ||||
|||| |||+- VS Unisystem
|||| ||+-- PlayChoice-10
|||| ++--- If == 2 (binary 10): NES 2.0 format
++++------ Upper 4 bits of mapper number
```

### Mapper Number (iNES)
```
mapper = (flags6 >> 4) | (flags7 & 0xF0)
```
8-bit mapper number (0–255).

### Detecting NES 2.0
```
if (flags7 & 0x0C) == 0x08:
    # NES 2.0 format
```

### Flags 9 (byte 9)
```
7654 3210
---- ---T
        +- TV system: 0=NTSC, 1=PAL
```

## NES 2.0 Extensions

NES 2.0 redefines bytes 8–15 for additional information while remaining
backwards-compatible with iNES parsers.

### Byte 8 — Mapper MSB / Submapper
```
7654 3210
SSSS NNNN
|||| ||||
|||| ++++- Mapper number bits 8-11 (extending to 12-bit mapper)
++++------ Submapper number (0-15)
```

Full mapper number (NES 2.0):
```
mapper = (flags6 >> 4) | (flags7 & 0xF0) | ((byte8 & 0x0F) << 8)
```

### Byte 9 — PRG-ROM / CHR-ROM size MSB
```
7654 3210
CCCC PPPP
|||| ||||
|||| ++++- PRG-ROM size MSB (bits 8-11)
++++------ CHR-ROM size MSB (bits 8-11)
```

If MSB nibble is 0-14: total_size = (MSB_nibble << 8 | LSB_byte) × unit_size
If MSB nibble is 15: exponent-multiplier format

### Byte 10 — PRG-RAM / PRG-NVRAM size
```
7654 3210
NNNN RRRR
|||| ||||
|||| ++++- PRG-RAM (volatile) shift count (0=none, else 64 << N bytes)
++++------ PRG-NVRAM / EEPROM shift count (0=none, else 64 << N bytes)
```

### Byte 11 — CHR-RAM / CHR-NVRAM size
```
7654 3210
NNNN RRRR
|||| ||||
|||| ++++- CHR-RAM (volatile) shift count
++++------ CHR-NVRAM shift count
```

### Byte 12 — CPU/PPU Timing
```
7654 3210
---- --TT
       ||
       ++- 0=NTSC, 1=PAL, 2=Multi-region, 3=Dendy
```

### Byte 13 — VS System type (when VS flag is set)
```
7654 3210
MMMM PPPP
|||| ||||
|||| ++++- VS PPU type
++++------ VS hardware type
```

### Byte 14 — Miscellaneous ROMs
```
7654 3210
---- --RR
       ++- Number of miscellaneous ROM areas
```

### Byte 15 — Default Expansion Device
```
7654 3210
--DD DDDD
  || ||||
  ++-++++- Default expansion device
```

## PRG-ROM Layout in File

The PRG-ROM data follows the header (and optional trainer). It is stored
as contiguous 16 KiB banks:

```
Bank 0: bytes 16 through 16+16383      → typically mapped to $8000
Bank 1: bytes 16+16384 through 16+32767 → typically mapped to $C000
... etc.
```

For mapper 71 (Codemasters):
- Last bank is fixed at $C000–$FFFF (contains vectors + reset code)
- Banks 0..N-2 are switchable at $8000–$BFFF

## CHR-ROM Layout in File

CHR-ROM follows PRG-ROM in the file. Stored as contiguous 8 KiB banks.
If CHR-ROM size is 0, the game uses CHR-RAM (common for Codemasters games).

## Practical Header Examples

### Codemasters game (Mapper 71, 256 KiB PRG, CHR-RAM)
```
4E 45 53 1A    NES\x1A magic
10             16 × 16 KiB = 256 KiB PRG-ROM
00             0 = CHR-RAM
70             Flags 6: mapper low nibble = 7, vertical mirroring
40             Flags 7: mapper high nibble = 4 → mapper = 0x47 = 71
00 00 00 00 00 00 00 00    Padding
```

### Quattro multicart (Mapper 232, 256 KiB PRG, CHR-RAM)
```
4E 45 53 1A    NES\x1A magic
10             16 × 16 KiB = 256 KiB PRG-ROM
00             CHR-RAM
80             Flags 6: mapper low nibble = 8
E0             Flags 7: mapper high nibble = E → mapper = 0xE8 = 232
00 00 00 00 00 00 00 00
```

### Simple NROM game (32 KiB PRG, 8 KiB CHR)
```
4E 45 53 1A
02             2 × 16 KiB = 32 KiB PRG-ROM
01             1 × 8 KiB = 8 KiB CHR-ROM
01             Horizontal mirroring, no battery, mapper 0
00             Mapper 0 (NROM)
00 00 00 00 00 00 00 00
```

## Dirty Headers

Many ROMs in the wild have garbage in bytes 7–15 (notably the string
"DiskDude!" from an old ROM management tool). This corrupts the mapper
number. Safe approach:
- If bytes 12–15 are not all zero and NES 2.0 identifier is not present,
  mask off the upper 4 bits of the mapper number (use only flags 6 lower nibble).
