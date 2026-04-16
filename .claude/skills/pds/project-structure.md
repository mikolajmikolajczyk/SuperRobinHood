# PDS Project Structure

How PDS organizes source files, the .PRJ build system, file type conventions,
and bank layout for NES cartridges.

---

## The .PRJ File

The `.PRJ` file is the central build/workspace definition. It serves as both a
**build script** (defining assembly order) and an **IDE workspace** (editor
layout, colors, window sizes).

### Example Structure

```
COMMENT  "Game Title - Build Project"
CLOCK ON
WINDOW 66x19 at 12,29

FILE MACROS.PDS
CURCOLOUR WHITE ON BLUE

FILE VARS.PDS
CURCOLOUR GREEN ON BLACK

FILE BANK0.PDS
FILE MAINLOOP.ROU
FILE CONTROL.ROU
FILE BANK1.PDS
FILE SPRITES.ROU
FILE MUSIC1.MUS
FILE CHRSETS.CHR
FILE MAPDATA.DAT

ASSEMBLER
```

### .PRJ Directives

| Directive | Example | Purpose |
|-----------|---------|---------|
| `FILE` | `FILE MACROS.PDS` | Include source file in build (order matters) |
| `COMMENT` | `COMMENT "notes"` | Annotation (not assembled) |
| `CURCOLOUR` | `CURCOLOUR RED ON GREEN` | Set editor syntax color for following file |
| `WINDOW` | `WINDOW 66x19 at 12,29` | Editor window size and position |
| `CLOCK ON` | | Show assembly timer |
| `ASSEMBLER` | | Trigger assembly of all listed files (must be last) |

### Build Order

**Order of `FILE` directives matters.** Files are assembled sequentially in the
order listed. Typical order:

1. **MACROS** — macro definitions and constants (must be first)
2. **VARS** — variable allocation (uses macros defined above)
3. **Bank files** — `bank N` / `org` directives to set up each ROM bank
4. **Routine files** — game logic, interleaved with bank setup
5. **Data files** — music, graphics, map data
6. **`ASSEMBLER`** — triggers the build (must be last)

If a file references a macro or label defined in a later file, assembly fails.

---

## File Type Conventions

Codemasters PDS projects use file extensions to indicate content type:

| Extension | Purpose | Typical Contents |
|-----------|---------|-----------------|
| `.PDS` | Core assembly | Macros, variables, bank setup, system initialization |
| `.ROU` | Routines | Game logic, engine code, subroutines |
| `.MUS` | Music/sound | Sound engine, music data, SFX definitions |
| `.CHR` | Characters/tiles | Tile set data (CHR-RAM content for NES) |
| `.DAT` | Raw data | Maps, sprite layouts, level data, lookup tables |
| `.PRJ` | Project file | Build script / workspace definition |

### Common File Names

| File | Purpose |
|------|---------|
| `MACROS.PDS` | Core macro library — block copy, move, variable allocation |
| `VARS.PDS` | RAM/zero-page variable definitions using `zvar`/`var` macros |
| `BANK<N>.PDS` | Bank setup — `bank N` directive, `org`, includes |
| `MAINLOOP.ROU` | Main game loop |
| `CONTROL.ROU` | Controller input handling |
| `START.ROU` | Startup / initialization code |
| `MUSIC1.MUS` | Music engine and data |
| `MACROS.MUS` | Music-specific macros |
| `CHRSETS.CHR` | Character/tile graphics data |
| `MAPDATA.DAT` | Level map data |
| `SPRITESD.DAT` | Sprite definition data |

---

## Bank Layout for NES (Mapper 71)

Codemasters NES games using Mapper 71 have this PRG-ROM layout:

```
Bank 0:  $8000–$BFFF  (16 KiB, switchable)
Bank 1:  $8000–$BFFF  (16 KiB, switchable)
...
Bank N-2: $8000–$BFFF (16 KiB, switchable)
Bank N-1: $C000–$FFFF (16 KiB, FIXED — last bank)
```

In PDS source, each bank is set up with:

```asm
        bank 0
        org &8000
        ; ... 16 KiB of code/data ...
        defs &C000-*,0          ; pad remainder with $00

        bank 1
        org &8000
        ; ... next bank ...
```

### The Fixed Bank (Last Bank)

The last bank is mapped to `$C000–$FFFF` and contains:

- **Startup code** (RESET handler)
- **NMI handler** (vblank interrupt)
- **IRQ handler**
- **Bank switching routine** (writes to $C000–$FFFF to select bank at $8000)
- **Hardware vectors** at $FFFA–$FFFF
- **PDS debug vectors** at $FFE4, $FFED, $FFF2 (development builds only)

### Bank Table

A common pattern is a **bank table** in the fixed bank that maps logical bank
numbers to physical bank numbers:

```asm
bank_table
        defb 0,1,2,3,4,5,6,7   ; direct mapping (or remapped)
```

### Free Space Tracking

The `free` directive reports unused bytes:

```asm
        free b0                 ; shows free space in bank 0
```

End-of-data labels (often `ED<N>`) mark where code/data ends in each bank,
with `defs` padding the rest to fill the 16 KiB boundary.

---

## Build Artifacts

### Development Build (`master equ 0`)

- Code is transferred via cable to target hardware
- Debug stubs are included
- No standalone ROM file produced

### Production Build (`master equ 1`)

- Clean ROM image suitable for EPROM burning
- All banks padded to exact size
- Debug vectors replaced with game code or NOPs
- `send computer` directives inactive
- Output is a flat binary matching the iNES PRG-ROM layout (minus the 16-byte header)

### The `path` Directive

```asm
        path c:\nes\robin
```

Sets the include search path, revealing the original DOS directory structure.
When porting to ca65, this maps to your project's source directory layout.

---

## Mapping PDS Project to ca65

When reassembling a PDS project with ca65/ld65:

| PDS Concept | ca65/ld65 Equivalent |
|-------------|---------------------|
| `.PRJ` file | `Makefile` or `justfile` |
| `FILE` directive order | Source file list in Makefile |
| `bank N` | `.segment "BANK_N"` + ld65 linker config |
| `org &8000` | Segment start address in linker config |
| `defs &C000-*,0` | `.align` or `.res` with segment size enforcement |
| `free` | Custom size-checking in linker config |
| `send computer` | *(removed — not applicable)* |
| `CURCOLOUR` | *(removed — IDE-specific)* |
| `path` | `-I` include path flag to ca65 |
