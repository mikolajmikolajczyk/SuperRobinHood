---
name: cc65-toolchain
description: >
  Reference for the cc65 development suite — the primary toolchain for NES
  reverse engineering reassembly work. Covers ca65 (assembler), ld65 (linker),
  da65 (disassembler), cc65 (C compiler), and cl65 (build driver). Focus is on
  NES ROM reassembly: translating PDS-originated Codemasters source into
  recompilable ca65 code, producing byte-identical ROMs via ld65 linker configs,
  and using da65 info files to annotate disassembly.
  Use this skill whenever the user mentions ca65, ld65, da65, cc65, cl65, ar65,
  od65, sp65, .segment, .proc, .macro, .byte, .word, .res, .include, .import,
  .export, linker config, linker script, ld65 config, memory config, SEGMENTS,
  MEMORY block, info file, .cfg file, cheap locals, anonymous labels, .feature,
  .struct, .scope, .lobyte, .hibyte, .bankbyte, address size, segment definition,
  NES linker config, iNES header in ca65, or any cc65-related assembler/linker
  topic. Also trigger when porting PDS source to ca65 or building NES ROMs with
  the cc65 suite.
---

# cc65 Toolchain Skill

Reference for reassembling NES ROMs using the cc65 development suite. Optimized
for **Codemasters NES reverse engineering** — porting PDS source to ca65 and
producing byte-identical builds.

> **How to use**: Read this file for quick reference. For deep dives, consult:
>
> | File | Contents |
> |------|----------|
> | `references/ca65-assembler.md` | All ca65 directives, expressions, macros, features |
> | `references/ld65-linker.md` | Linker config syntax, MEMORY/SEGMENTS, NES ROM layout |
> | `references/da65-disassembler.md` | Info file format, RANGE/LABEL types, workflow |
> | `references/pds-to-ca65.md` | Translation guide: PDS syntax → ca65 equivalents |
> | `references/nes-build.md` | Complete NES build pipeline, iNES header, Makefile patterns |
>
> Full cc65 HTML documentation is at `cc65_manual/doc-master/`.

---

## Tool Overview

| Tool | Purpose | Key Use in This Project |
|------|---------|----------------------|
| `ca65` | 6502 macro assembler | Assemble ported source into object files |
| `ld65` | Linker | Link objects into NES ROM with iNES header |
| `da65` | Disassembler | Produce initial disassembly from binary ROM |
| `cc65` | C compiler (→ assembly) | Optional — C modules if needed |
| `cl65` | Compile-and-link driver | One-step build shortcut |
| `ar65` | Archiver | Create .lib static libraries |
| `od65` | Object file dumper | Inspect .o files (debug) |

---

## ca65 Quick Reference

### Expression Operators

| Operator | Alias | Purpose | Example |
|----------|-------|---------|---------|
| `<` | `.LOBYTE` | Low byte | `lda #<label` |
| `>` | `.HIBYTE` | High byte | `lda #>label` |
| `^` | `.BANKBYTE` | Bank byte | `lda #^label` |
| `~` | `.BITNOT` | Bitwise NOT | `~$FF` = 0 |
| `&` | `.BITAND` | Bitwise AND | `$FF & $0F` |
| `\|` | `.BITOR` | Bitwise OR | `$F0 \| $0F` |
| `<<` | `.SHL` | Shift left | `1 << 4` |
| `>>` | `.SHR` | Shift right | `$80 >> 4` |

> **Note:** `<` = low byte, `>` = high byte. This is the **standard** 6502
> convention — **opposite** of PDS where `>` = low and `<` = high.

### Core Directives

| Directive | Example | Purpose |
|-----------|---------|---------|
| `.byte` | `.byte $FF, $00` | Define bytes |
| `.word` | `.word $8000` | Define 16-bit words (little-endian) |
| `.dword` | `.dword $12345678` | Define 32-bit values |
| `.res N [, V]` | `.res 16384, $00` | Reserve N bytes, optionally fill |
| `.asciiz` | `.asciiz "hello"` | Null-terminated string |
| `.align N` | `.align 256` | Align to N-byte boundary |
| `.org` | `.org $C000` | Set program counter (use sparingly) |
| `.segment "NAME"` | `.segment "BANK_0"` | Switch to named segment |
| `.proc NAME` | `.proc main_loop` | Begin named procedure (scoped labels) |
| `.endproc` | | End procedure |
| `.scope` / `.endscope` | | Anonymous scope for label isolation |
| `.include "file"` | `.include "macros.inc"` | Include source file |
| `.incbin "file"` | `.incbin "tiles.chr"` | Include binary data |

### Segments (Predefined)

| Name | Directive | Typical Use |
|------|-----------|-------------|
| `CODE` | `.code` | Program code |
| `DATA` | `.data` | Initialized data |
| `RODATA` | `.rodata` | Read-only data |
| `BSS` | `.bss` | Uninitialized variables |
| `ZEROPAGE` | `.zeropage` | Zero-page variables |

Custom segments via `.segment "BANK_0"`, `.segment "HEADER"`, etc.

### Labels

```asm
global_label:           ; global scope
    @cheap_local:       ; scoped to nearest global label above
        lda #$00
        beq @cheap_local

; Anonymous labels (+ forward, - backward):
:       lda $2002
        bpl :-          ; branch to previous ':'
        bne :+          ; branch to next ':'
:       rts
```

### Macros

```asm
.macro MOVE_W src, dst
    lda src
    sta dst
    lda src+1
    sta dst+1
.endmacro

; Usage:
    MOVE_W player_x, sprite_x
```

- Named parameters (not positional `@1`–`@9` like PDS)
- `.paramcount` — number of parameters passed
- `.ifblank` / `.ifnblank` — test optional parameters

### Conditional Assembly

```asm
.ifdef MASTER
    ; production build
.else
    ; development build
.endif

.if .defined(DEBUG) .and .not .defined(MASTER)
    jsr debug_check
.endif
```

### Features

```asm
.feature c_comments              ; allow /* */ comments
.feature labels_without_colons   ; PDS-style labels (no trailing colon)
.feature underline_in_numbers    ; allow 1_000_000
.feature force_range             ; strict range checking
```

> **Full ca65 reference: `references/ca65-assembler.md`**

---

## ld65 Quick Reference

### Linker Config Structure

```
MEMORY {
    HDR:    start = $0000, size = $0010, type = ro, file = %O, fill = yes;
    PRG_0:  start = $8000, size = $4000, type = ro, file = %O, fill = yes, fillval = $00;
    PRG_7:  start = $C000, size = $4000, type = ro, file = %O, fill = yes, fillval = $00;
}

SEGMENTS {
    HEADER:  load = HDR,   type = ro;
    BANK_0:  load = PRG_0, type = ro;
    BANK_7:  load = PRG_7, type = ro;
}
```

### Key Properties

| Property | Values | Purpose |
|----------|--------|---------|
| `start` | `$address` | Memory area start address |
| `size` | `$size` | Memory area size in bytes |
| `type` | `ro`, `rw`, `bss` | Read-only, read-write, uninitialized |
| `file` | `"name"` or `%O` | Output file (`%O` = default output) |
| `fill` | `yes`/`no` | Pad to full size |
| `fillval` | `$value` | Fill byte (default $00) |
| `define` | `yes`/`no` | Export `__NAME_LOAD__`, `__NAME_RUN__`, `__NAME_SIZE__` |
| `load` | `MEMAREA` | Which memory area holds the segment |
| `run` | `MEMAREA` | Where segment runs (if different from load) |

> **Full linker config reference: `references/ld65-linker.md`**

---

## da65 Quick Reference

### Basic Usage

```bash
da65 --cpu 6502 --start-addr $8000 -i game.info -o game.s game.bin
```

### Info File Example

```
GLOBAL {
    STARTADDR $8000;
    CPU "6502";
    COMMENTS 4;
}

RANGE { START $8000; END $800F; TYPE CODE; }
RANGE { START $8010; END $801F; TYPE BYTETABLE; }
RANGE { START $8020; END $803F; TYPE WORDTABLE; }

LABEL { ADDR $8000; NAME "reset"; }
LABEL { ADDR $FFFA; NAME "vectors"; }
```

### Range Types

| Type | Purpose |
|------|---------|
| `CODE` | 6502 instructions |
| `BYTETABLE` | Byte data table |
| `WORDTABLE` | 16-bit address/data table |
| `DWORDTABLE` | 32-bit data table |
| `ADDRTABLE` | Address table (formatted as addresses) |
| `RTSTABLE` | RTS trick table (addr-1 for RTS dispatch) |
| `TEXTTABLE` | ASCII text strings |
| `SKIP` | Skip — don't disassemble |

> **Full da65 reference: `references/da65-disassembler.md`**

---

## NES Build Pipeline

```
  .s files          .o files              .nes ROM
┌──────────┐     ┌──────────┐     ┌──────────────────┐
│ source.s │────►│ source.o │────►│ 16-byte iNES hdr │
│          │ca65 │          │ld65 │ PRG-ROM banks     │
└──────────┘     └──────────┘     │ CHR-ROM (if any)  │
                      ▲           └──────────────────┘
                      │                    ▲
                 ┌────────┐          ┌─────────┐
                 │ .cfg   │          │ tiles.chr│
                 │ linker │          │ (incbin) │
                 │ config │          └─────────┘
                 └────────┘
```

### iNES Header in ca65

```asm
.segment "HEADER"
    .byte "NES", $1A        ; magic
    .byte 8                 ; 8 × 16KB PRG-ROM = 128KB
    .byte 0                 ; 0 × 8KB CHR-ROM (using CHR-RAM)
    .byte $10               ; flags 6: mapper low nibble (Mapper 71 → $1)
                            ;          + vertical mirroring ($00) or horizontal ($01)
    .byte $40               ; flags 7: mapper high nibble (Mapper 71 → $4)
    .res 8, $00             ; padding
```

> **Full build pipeline: `references/nes-build.md`**

---

## PDS → ca65 Quick Translation

| PDS | ca65 | Notes |
|-----|------|-------|
| `>expr` (low byte) | `<expr` or `.lobyte(expr)` | **Swapped!** |
| `<expr` (high byte) | `>expr` or `.hibyte(expr)` | **Swapped!** |
| `&FF` | `$FF` | Hex prefix |
| `defb` / `db` | `.byte` | |
| `defw` / `dw` | `.word` | |
| `defs N,V` | `.res N, V` | |
| `equ` | `=` or `:=` | |
| `macro` / `endm` | `.macro` / `.endmacro` | Named params instead of `@1`–`@9` |
| `@1`–`@9` | Named params | `@1` → first named param |
| `!1`–`!9` | `@local_label` | Cheap locals |
| `if` / `endif` | `.if` / `.endif` | |
| `bank N` | `.segment "BANK_N"` | Via linker config |
| `org &8000` | Segment start in .cfg | Prefer linker config over `.org` |
| `path` | `-I` flag to ca65 | Include path |
| `send computer1` | *(removed)* | Not applicable |
| Case insensitive | `.feature labels_without_colons` | ca65 is case-sensitive by default |

> **Full translation guide: `references/pds-to-ca65.md`**
