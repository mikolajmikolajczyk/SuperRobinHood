# ld65 Linker — Complete Reference

The ld65 linker combines ca65 object files into the final NES ROM binary,
controlled by a configuration file (.cfg) that defines the memory layout.

---

## Command-Line Options

```
ld65 [options] file.o [file.o ...]

-C name              Linker config file (.cfg)
-D sym=value         Define symbol
-L path              Library search path
-Ln name             Create VICE/Mesen label file (.lbl)
-m name              Create map file (.map)
-o name              Output file
-S addr              Set default start address
-t sys               Target system (nes, c64, none, etc.)
-u sym[:addrsize]    Force import of symbol
-v, --verbose        Verbose output
-vm                  Verbose map file (includes per-module info)
--allow-multiple-definition  Allow multiply defined symbols
--dbgfile name       Create debug info file (.dbg) — for Mesen
--lib file           Link static library
--obj file           Link object file
--cfg-path path      Config file search path
--obj-path path      Object file search path
```

### Key Flags for NES RE

```bash
# Typical invocation:
ld65 -C nes.cfg -o game.nes \
    build/header.o build/bank0.o build/bank1.o ... build/bank7.o \
    -Ln build/game.lbl --dbgfile build/game.dbg -m build/game.map

# -Ln: generates label file for Mesen/FCEUX symbolic debugging
# --dbgfile: detailed debug info for Mesen's debugger
# -m: map file shows segment placement and sizes
```

---

## Configuration File Syntax

The .cfg file has four main sections: `MEMORY`, `SEGMENTS`, `FILES`, `SYMBOLS`.

### MEMORY Section

Defines physical memory areas in the output:

```
MEMORY {
    # iNES header (16 bytes at start of file)
    HDR:      start = $0000, size = $0010, type = ro, file = %O, fill = yes;

    # PRG-ROM banks (each 16 KiB for Mapper 71)
    PRG_00:   start = $8000, size = $4000, type = ro, file = %O, fill = yes, fillval = $00;
    PRG_01:   start = $8000, size = $4000, type = ro, file = %O, fill = yes, fillval = $00;
    PRG_02:   start = $8000, size = $4000, type = ro, file = %O, fill = yes, fillval = $00;
    PRG_03:   start = $8000, size = $4000, type = ro, file = %O, fill = yes, fillval = $00;
    PRG_04:   start = $8000, size = $4000, type = ro, file = %O, fill = yes, fillval = $00;
    PRG_05:   start = $8000, size = $4000, type = ro, file = %O, fill = yes, fillval = $00;
    PRG_06:   start = $8000, size = $4000, type = ro, file = %O, fill = yes, fillval = $00;
    PRG_07:   start = $C000, size = $4000, type = ro, file = %O, fill = yes, fillval = $00;

    # RAM (not written to file)
    ZP:       start = $0000, size = $0100, type = rw;
    RAM:      start = $0200, size = $0600, type = rw;
    OAM:      start = $0200, size = $0100, type = rw;
}
```

### MEMORY Properties

| Property | Values | Required | Purpose |
|----------|--------|----------|---------|
| `start` | `$address` | Yes | Start address of memory area |
| `size` | `$size` | Yes | Size in bytes |
| `type` | `ro`, `rw` | No | Read-only or read-write (default: `rw`) |
| `file` | `"name"` or `%O` | No | Output file (`%O` = default, `""` = none) |
| `fill` | `yes`/`no` | No | Pad area to full size (default: `no`) |
| `fillval` | `$value` | No | Fill byte value (default: `$00`) |
| `define` | `yes`/`no` | No | Export `__NAME_LOAD__`, `__NAME_SIZE__` symbols |
| `bank` | number | No | Bank number for `.BANK()` pseudo-function |

### SEGMENTS Section

Maps ca65 segments to memory areas:

```
SEGMENTS {
    HEADER:    load = HDR,      type = ro;
    BANK_00:   load = PRG_00,   type = ro;
    BANK_01:   load = PRG_01,   type = ro;
    BANK_02:   load = PRG_02,   type = ro;
    BANK_03:   load = PRG_03,   type = ro;
    BANK_04:   load = PRG_04,   type = ro;
    BANK_05:   load = PRG_05,   type = ro;
    BANK_06:   load = PRG_06,   type = ro;
    BANK_07:   load = PRG_07,   type = ro;
    VECTORS:   load = PRG_07,   type = ro, start = $FFFA;
    ZEROPAGE:  load = ZP,       type = zp;
    BSS:       load = RAM,      type = bss;
    OAM:       load = OAM,      type = bss;
}
```

### SEGMENTS Properties

| Property | Values | Required | Purpose |
|----------|--------|----------|---------|
| `load` | `MEMAREA` | Yes | Memory area for LOAD address |
| `run` | `MEMAREA` | No | Memory area for RUN address (if different from load) |
| `type` | `ro`, `rw`, `bss`, `zp` | No | Segment type |
| `start` | `$address` | No | Override start address within memory area |
| `align` | number | No | Alignment requirement |
| `offset` | number | No | Offset within memory area |
| `optional` | `yes`/`no` | No | Don't error if segment is empty |
| `define` | `yes`/`no` | No | Export `__NAME_LOAD__`, `__NAME_RUN__`, `__NAME_SIZE__` |
| `fillval` | `$value` | No | Segment-specific fill value |

### LOAD vs RUN Addresses

For ROM code that gets copied to RAM at runtime:

```
MEMORY {
    PRG:  start = $C000, size = $4000, type = ro, file = %O, fill = yes;
    WRAM: start = $6000, size = $2000, type = rw;
}

SEGMENTS {
    # Stored in ROM at $C000+, but runs at $6000
    RAMCODE: load = PRG, run = WRAM, type = ro, define = yes;
}
```

In code:
```asm
.import __RAMCODE_LOAD__, __RAMCODE_RUN__, __RAMCODE_SIZE__

; Copy RAMCODE from ROM to RAM:
    lda #<__RAMCODE_LOAD__
    ; ... memcpy to __RAMCODE_RUN__, __RAMCODE_SIZE__ bytes
```

### FILES Section (Optional)

```
FILES {
    %O: format = bin;           ; default output is flat binary
}
```

Format options: `bin` (flat binary), `o65` (relocatable), `atari` (Atari binary).
For NES, always use `bin`.

### SYMBOLS Section (Optional)

```
SYMBOLS {
    __NMI_VECTOR__:   type = export, value = $C000;
    __RESET_VECTOR__: type = export, value = $C100;
}
```

---

## NES Mapper 71 — Complete Linker Config

Full example for a Codemasters 128 KiB Mapper 71 game (8 × 16 KiB banks):

```
MEMORY {
    HDR:      start = $0000, size = $0010, type = ro, file = %O, fill = yes;
    PRG_00:   start = $8000, size = $4000, type = ro, file = %O, fill = yes, fillval = $00;
    PRG_01:   start = $8000, size = $4000, type = ro, file = %O, fill = yes, fillval = $00;
    PRG_02:   start = $8000, size = $4000, type = ro, file = %O, fill = yes, fillval = $00;
    PRG_03:   start = $8000, size = $4000, type = ro, file = %O, fill = yes, fillval = $00;
    PRG_04:   start = $8000, size = $4000, type = ro, file = %O, fill = yes, fillval = $00;
    PRG_05:   start = $8000, size = $4000, type = ro, file = %O, fill = yes, fillval = $00;
    PRG_06:   start = $8000, size = $4000, type = ro, file = %O, fill = yes, fillval = $00;
    PRG_07:   start = $C000, size = $4000, type = ro, file = %O, fill = yes, fillval = $00;
    ZP:       start = $0000, size = $0100, type = rw;
    STACK:    start = $0100, size = $0100, type = rw;
    OAM:      start = $0200, size = $0100, type = rw;
    RAM:      start = $0300, size = $0500, type = rw;
}

SEGMENTS {
    HEADER:    load = HDR,      type = ro;
    BANK_00:   load = PRG_00,   type = ro;
    BANK_01:   load = PRG_01,   type = ro;
    BANK_02:   load = PRG_02,   type = ro;
    BANK_03:   load = PRG_03,   type = ro;
    BANK_04:   load = PRG_04,   type = ro;
    BANK_05:   load = PRG_05,   type = ro;
    BANK_06:   load = PRG_06,   type = ro;
    BANK_07:   load = PRG_07,   type = ro;
    VECTORS:   load = PRG_07,   type = ro, start = $FFFA;
    ZEROPAGE:  load = ZP,       type = zp;
    OAM:       load = OAM,      type = bss;
    BSS:       load = RAM,      type = bss;
}
```

### Key Points for Mapper 71

- Banks 0–6 all have `start = $8000` — they're switchable and occupy the same
  address range. The linker writes them sequentially to the output file.
- Bank 7 (last) has `start = $C000` — it's the fixed bank.
- `fill = yes` + `fillval = $00` ensures each bank is exactly 16 KiB, padded
  with `$00` (matching PDS `defs &4000,0`).
- `VECTORS` segment overlays the end of Bank 7 at `$FFFA`.
- ZP, STACK, OAM, RAM have no `file` — they're runtime memory, not in ROM.

---

## Output Files

### Label File (`-Ln`)

```
al 00C000 .reset
al 00C100 .nmi_handler
al 000010 .player_x
```

Format: `al BBAAAA .name` — compatible with Mesen and FCEUX debuggers.

### Map File (`-m`)

Shows segment placement, sizes, and exported symbols. Essential for verifying
that the reassembled ROM has identical layout to the original.

### Debug File (`--dbgfile`)

Comprehensive debug info for Mesen. Includes source file references, line
numbers, symbol types, and segment information. Enables source-level debugging
in Mesen.

---

## Verification Workflow

To verify byte-identical reassembly:

```bash
# Build
ca65 -g -t nes -o build/game.o src/game.s
ld65 -C game.cfg -o build/game.nes build/game.o -m build/game.map

# Strip iNES header from reassembled ROM and compare:
tail -c +17 build/game.nes > build/game_prg.bin
tail -c +17 original.nes > original_prg.bin
cmp build/game_prg.bin original_prg.bin

# Or compare with xxd:
diff <(xxd build/game_prg.bin) <(xxd original_prg.bin)
```

If `cmp` reports differences, check the map file to identify which segment
contains the mismatch, then use `hexyl` or `xxd` to find the exact offset.
