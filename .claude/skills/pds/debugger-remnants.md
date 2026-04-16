# Identifying PDS Artifacts in Compiled ROMs

Guide for recognizing PDS development system fingerprints when reverse
engineering compiled NES ROMs or analyzing original source code.

---

## Debug Vector Fingerprints

The strongest PDS indicators in compiled code are references to the debug
vector addresses:

| Pattern | Bytes | Significance |
|---------|-------|-------------|
| `JSR $FFF2` | `20 F2 FF` | CHECKPDS — debugger presence check |
| `JSR $FFED` | `20 ED FF` | BREAKPOINT — debugger halt |
| `JMP $FFE4` | `4C E4 FF` | ANALYZE — profiler entry |

### Where to Look

- **In production ROMs**: These should be absent. If found, it indicates an
  incomplete cleanup of debug code (the `master` flag was not set, or
  conditional assembly missed a reference).
- **In the fixed bank** ($C000–$FFFF): The addresses $FFE4, $FFED, $FFF2
  themselves will contain normal game code in production builds. In development
  builds, they contain PDS debugger stubs.
- **Near RESET vector**: The smiley test (Codemasters ROM check) is often near
  the RESET handler. Don't confuse it with PDS debug code — the smiley test
  is a separate Codemasters feature.

### The `testpds` Alias

Some source files (particularly music engine code) use an alternative name:

```asm
testpds     equ $FFF2           ; same as CHECKPDS
            jsr testpds
```

Both names map to the same address. When searching disassembly for PDS
references, check for both naming patterns.

---

## Z80 Naming Heritage

PDS was originally a Z80 development system. When the 6502 version was created,
many Z80 conventions carried over as macro names. These are strong indicators
of PDS-originated code:

### Block Copy Macros

| Macro Name | Z80 Origin | 6502 Behavior |
|------------|-----------|---------------|
| `ldir` | `LDIR` (Load, Increment, Repeat) | Forward block copy: copies N bytes from source to dest, incrementing |
| `lddr` | `LDDR` (Load, Decrement, Repeat) | Backward block copy: copies N bytes, decrementing |
| `sldir` | *(PDS custom)* | "Slow" forward copy — safe variant for overlapping regions |
| `slddr` | *(PDS custom)* | "Slow" backward copy — safe variant |

In disassembled code, these expand to loops using `LDA (zp),Y` / `STA (zp),Y`
with increment/decrement. The expanded code is recognizable by its structure
even without macro names.

### 68K-Style Move Macros

| Macro | Expands To |
|-------|-----------|
| `move.w src,dst` | `LDA src` / `STA dst` / `LDA src+1` / `STA dst+1` |
| `move.b src,dst` | `LDA src` / `STA dst` |

The `.w` / `.b` suffix notation comes from the Motorola 68000, not the 6502
world. Finding this pattern in source code is a strong PDS indicator.

### Z80 Register Pair Naming

| Macro | Z80 Analogy | 6502 Purpose |
|-------|------------|-------------|
| `cphlde` | Compare HL with DE | 16-bit comparison using X/Y as pseudo-register pairs |
| `ldxy addr` | `LD BC,nn` | Load X (low) and Y (high) from 16-bit value |

---

## Variable Allocation Pattern

The `zvar` / `var` auto-allocating macro pattern is distinctive:

### In Source

```asm
zp_ptr = &00
        macro zvar
@1      equ zp_ptr
zp_ptr  = zp_ptr + @2
        endm

        zvar player_x,1         ; $00
        zvar player_y,1         ; $01
        zvar scroll_lo,1        ; $02
        zvar scroll_hi,1        ; $03
```

### In Disassembly

The result is **sequential zero-page allocation starting from $00**. If you see
a disassembled ROM where zero-page variables are neatly sequential from $00
upward, with no gaps, this suggests auto-allocation via `zvar`.

Similarly, `var` allocates RAM starting from a base address (typically $0300):

```asm
ram_ptr = &0300
        macro var
@1      equ ram_ptr
ram_ptr = ram_ptr + @2
        endm

        var enemy_table,64      ; $0300
        var map_buffer,256      ; $0340
```

---

## Conditional Master/Debug Build Patterns

### In Source

```asm
master  equ 1                   ; 1 = production ROM

        if master=0
            bank 12,START       ; dev: transfer with entry point
        else
            bank 12             ; prod: just switch bank
        endif

        if master=0
            jsr CHECKPDS
        endif
```

### In Disassembly

In a production ROM, the `if master=0` blocks are absent. However, you may
find:

1. **NOP sleds** where debug calls were replaced with padding
2. **Unreachable code** — dead branches that originally led to debug routines
3. **Inconsistent padding** — extra bytes that don't make sense as code or data,
   leftover from conditional assembly alignment

---

## ROM Layout Clues

PDS-assembled NES ROMs have characteristic layout features:

### Bank Padding

Each bank is padded to exactly 16 KiB with `defs &C000-*,0` (or equivalent).
This fills unused space with `$00` bytes. In a hex dump:

```
0000BFF0: xx xx xx 00 00 00 00 00 00 00 00 00 00 00 00 00
0000C000: [next bank starts here]
```

Long runs of `$00` at the end of each 16 KiB boundary are typical.

### Bank Table in Fixed Bank

A lookup table mapping logical to physical bank numbers, typically in the
last bank:

```
bank_table: .byte $00, $01, $02, $03, $04, $05, $06, $07
```

### Vector Table

The last 6 bytes of the ROM (`$FFFA–$FFFF`) contain the NES hardware vectors.
In PDS source, these are defined explicitly:

```asm
        org &FFFA
        defw NMI                ; $FFFA: NMI vector
        defw RESET              ; $FFFC: RESET vector
        defw IRQ                ; $FFFE: IRQ vector
```

---

## CPC/Spectrum Port Remnants

Some Codemasters NES games were ported from CPC or Spectrum originals that were
also PDS-developed. Watch for:

- **Port addresses $FBEC–$FBEF** appearing in data tables — leftover from
  CPC interface code that was not fully removed during porting
- **Z80-style memory access patterns** — code that looks like it was
  mechanically translated from Z80 to 6502
- **Screen dimension constants** suggesting CPC (320×200) or Spectrum (256×192)
  origins rather than NES (256×240)

These are not PDS artifacts per se, but indicate the game's CPC/Spectrum
heritage and PDS development lineage.

---

## Quick Checklist

When examining a ROM or source code, check for:

- [ ] `JSR $FFF2` / `JSR $FFED` / `JMP $FFE4` in code
- [ ] `20 F2 FF` / `20 ED FF` / `4C E4 FF` byte sequences in ROM
- [ ] `ldir` / `lddr` / `sldir` / `slddr` macro names (source)
- [ ] `move.w` / `move.b` macro names (source)
- [ ] `cphlde` / `ldxy` macro names (source)
- [ ] `zvar` / `var` allocation macros (source)
- [ ] Sequential zero-page variables from $00 (disassembly)
- [ ] `master equ` build flag (source)
- [ ] `send computer1` directive (source)
- [ ] `>` for low byte / `<` for high byte (source — reversed convention)
- [ ] `@1`–`@9` macro parameters (source)
- [ ] `!1`–`!9` local labels (source)
- [ ] `$00` padding at 16 KiB boundaries (ROM)
- [ ] Port $FBEC–$FBEF references in data (ROM — CPC remnant)
