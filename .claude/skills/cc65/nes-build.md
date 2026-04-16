# NES Build Pipeline with cc65

Complete reference for building NES ROMs using the cc65 toolchain, from source
to byte-identical ROM output.

---

## Tool Chain

```
Source (.s)  ──ca65──►  Object (.o)  ──ld65──►  ROM (.nes)
                                        ▲
                                   Config (.cfg)
```

| Step | Tool | Input | Output |
|------|------|-------|--------|
| Assemble | `ca65` | `.s` source | `.o` object |
| Link | `ld65` | `.o` objects + `.cfg` config | `.nes` ROM |
| *(optional)* Disassemble | `da65` | `.bin` binary | `.s` source |
| *(optional)* Compile C | `cc65` | `.c` source | `.s` assembly |
| *(shortcut)* All-in-one | `cl65` | `.s`/`.c` source | `.nes` ROM |

---

## iNES Header

Every NES ROM starts with a 16-byte header:

```asm
.segment "HEADER"
    .byte "NES", $1A            ; magic number (4 bytes)
    .byte PRG_BANKS             ; PRG-ROM size in 16 KiB units
    .byte CHR_BANKS             ; CHR-ROM size in 8 KiB units (0 = CHR-RAM)
    .byte FLAGS_6               ; mapper low nibble, mirroring, battery, trainer
    .byte FLAGS_7               ; mapper high nibble, NES 2.0 flag
    .byte $00                   ; PRG-RAM size (rarely used in iNES 1.0)
    .byte $00                   ; TV system (0 = NTSC)
    .byte $00                   ; TV system / PRG-RAM (rarely used)
    .res 5, $00                 ; padding
```

### Flags 6 Bit Layout

```
76543210
||||||||
||||++++- Mapper low nibble
|||+----- Four-screen VRAM
||+------ Trainer present (512 bytes at $7000-$71FF)
|+------- Battery-backed PRG-RAM at $6000-$7FFF
+-------- Mirroring (0 = horizontal, 1 = vertical)
```

### Flags 7 Bit Layout

```
76543210
||||||||
||||++++- Mapper high nibble
||++----- If bits == $08: NES 2.0 format
++------- VS/Playchoice flags
```

### Mapper 71 Header (Codemasters)

```asm
PRG_BANKS = 8                   ; 128 KiB (8 × 16 KiB)
CHR_BANKS = 0                   ; CHR-RAM

.segment "HEADER"
    .byte "NES", $1A
    .byte PRG_BANKS             ; $08
    .byte CHR_BANKS             ; $00
    .byte $10                   ; mapper low = $1, horizontal mirroring
    .byte $40                   ; mapper high = $4 → mapper = $41 = 65...
```

**Wait — Mapper 71 encoding:**
- Mapper number 71 = $47 in hex
- Low nibble: `$47 & $0F` = $07, shift left 4 → `$70`
- High nibble: `$47 & $F0` = $40
- Flags 6: `$70 | mirroring_bit`
- Flags 7: `$40`

```asm
; Correct Mapper 71 header:
.segment "HEADER"
    .byte "NES", $1A
    .byte 8                     ; 8 × 16 KiB PRG-ROM = 128 KiB
    .byte 0                     ; CHR-RAM
    .byte $70                   ; flags 6: mapper low nibble 7, horiz mirror
    .byte $40                   ; flags 7: mapper high nibble 4
    .res 8, $00
```

---

## Makefile Pattern

```makefile
# Tools
CA65  = ca65
LD65  = ld65

# Flags
CAFLAGS = -g -t nes -I include
LDFLAGS = -C game.cfg

# Sources (one per bank)
SOURCES = src/header.s src/bank00.s src/bank01.s src/bank02.s \
          src/bank03.s src/bank04.s src/bank05.s src/bank06.s \
          src/bank07.s

OBJECTS = $(SOURCES:src/%.s=build/%.o)
TARGET  = build/game.nes

.PHONY: all clean verify

all: $(TARGET)

$(TARGET): $(OBJECTS) game.cfg
	$(LD65) $(LDFLAGS) -o $@ $(OBJECTS) \
		-Ln build/game.lbl --dbgfile build/game.dbg -m build/game.map

build/%.o: src/%.s | build
	$(CA65) $(CAFLAGS) -o $@ $<

build:
	mkdir -p build

clean:
	rm -rf build

# Verify byte-identical to original:
verify: $(TARGET)
	@tail -c +17 $(TARGET) > build/reassembled.bin
	@tail -c +17 original.nes > build/original.bin
	@if cmp -s build/reassembled.bin build/original.bin; then \
		echo "MATCH: ROM is byte-identical!"; \
	else \
		echo "MISMATCH: ROMs differ"; \
		cmp -l build/reassembled.bin build/original.bin | head -20; \
		exit 1; \
	fi
```

---

## justfile Pattern

```just
# NES RE build system

ca65_flags := "-g -t nes -I include"
ld65_flags := "-C game.cfg"

# Build the ROM
build:
    mkdir -p build
    ca65 {{ca65_flags}} -o build/header.o src/header.s
    ca65 {{ca65_flags}} -o build/bank00.o src/bank00.s
    ca65 {{ca65_flags}} -o build/bank01.o src/bank01.s
    ca65 {{ca65_flags}} -o build/bank02.o src/bank02.s
    ca65 {{ca65_flags}} -o build/bank03.o src/bank03.s
    ca65 {{ca65_flags}} -o build/bank04.o src/bank04.s
    ca65 {{ca65_flags}} -o build/bank05.o src/bank05.s
    ca65 {{ca65_flags}} -o build/bank06.o src/bank06.s
    ca65 {{ca65_flags}} -o build/bank07.o src/bank07.s
    ld65 {{ld65_flags}} -o build/game.nes \
        build/header.o build/bank00.o build/bank01.o build/bank02.o \
        build/bank03.o build/bank04.o build/bank05.o build/bank06.o \
        build/bank07.o \
        -Ln build/game.lbl --dbgfile build/game.dbg -m build/game.map

# Verify against original ROM
verify: build
    #!/usr/bin/env bash
    tail -c +17 build/game.nes > build/reassembled.bin
    tail -c +17 original.nes > build/original.bin
    if cmp -s build/reassembled.bin build/original.bin; then
        echo "MATCH: byte-identical"
    else
        echo "MISMATCH:"
        cmp -l build/reassembled.bin build/original.bin | head -20
    fi

# Run in Mesen with debug symbols
run: build
    mesen build/game.nes

# Disassemble a bank (usage: just disasm 0)
disasm bank:
    da65 --cpu 6502 -S '$8000' -m \
        -i info/bank{{bank}}.info \
        -o disasm/bank{{bank}}.s \
        banks/bank{{bank}}.bin

# Clean build artifacts
clean:
    rm -rf build
```

---

## Verification Workflow

### Quick Compare

```bash
# Strip 16-byte iNES headers and compare PRG data:
tail -c +17 build/game.nes > /tmp/new.bin
tail -c +17 original.nes > /tmp/orig.bin
cmp /tmp/new.bin /tmp/orig.bin
```

### Find Differences

```bash
# Show first 20 byte differences:
cmp -l /tmp/new.bin /tmp/orig.bin | head -20

# Side-by-side hex diff:
diff <(xxd /tmp/orig.bin) <(xxd /tmp/new.bin) | head -40

# Visual hex comparison:
hexyl --length 256 --skip 0x4000 /tmp/orig.bin  # bank 1 in original
hexyl --length 256 --skip 0x4000 /tmp/new.bin    # bank 1 in reassembly
```

### Per-Bank Comparison

```bash
# Extract and compare individual banks:
for i in $(seq 0 7); do
    offset=$((16 + i * 16384))
    dd if=original.nes bs=1 skip=$offset count=16384 of=/tmp/orig_bank${i}.bin 2>/dev/null
    dd if=build/game.nes bs=1 skip=$offset count=16384 of=/tmp/new_bank${i}.bin 2>/dev/null
    if cmp -s /tmp/orig_bank${i}.bin /tmp/new_bank${i}.bin; then
        echo "Bank $i: MATCH"
    else
        echo "Bank $i: MISMATCH"
        cmp -l /tmp/orig_bank${i}.bin /tmp/new_bank${i}.bin | wc -l
    fi
done
```

### Map File Analysis

The ld65 map file (`-m`) shows:
- Segment placement (start address, size, memory area)
- Free space per memory area
- Exported symbols and their values

Compare segment sizes against expected bank usage to catch size mismatches
before byte-level comparison.

---

## Debug Symbol Output

### Label File (`-Ln`)

For Mesen/FCEUX symbolic debugging:

```
al 00C000 .reset
al 00C080 .nmi
al 000010 .player_x
```

Load in Mesen: Debug → Labels → Import Labels

### Debug Info (`--dbgfile`)

Full source-level debugging in Mesen. Includes:
- Source file paths and line numbers
- All symbols with types and sizes
- Segment boundaries
- Scope information

Load in Mesen: when opening the ROM, Mesen auto-detects `.dbg` files.

---

## Common Build Issues

### "Segment overflow"

A segment exceeds its memory area size. Check:
1. The linker config `size` matches expected bank size ($4000 = 16 KiB)
2. No duplicate data in the segment
3. All `.res` / `.align` directives produce expected sizes

### "Symbol already defined"

Duplicate label. Common when porting PDS code where case-insensitive names
collide. Use `.proc` scoping or rename.

### "Range error"

A value doesn't fit in the target size:
- Branch target too far (>127 bytes) — need `JMP` instead of branch
- Zero-page reference to absolute address — check `.importzp` vs `.import`
- Byte value > 255 — check expression evaluation

### Bank mismatch in comparison

Usually caused by:
1. Incorrect fill value (`fillval = $00` vs `$FF`)
2. Missing `.res` padding at end of bank
3. Wrong segment order in linker command line (ld65 concatenates in arg order)
4. Swapped `>`/`<` byte operators (most common PDS porting bug)
