# ca65 Assembler — Complete Reference

The ca65 macro assembler is the core tool for NES reassembly work. It produces
object files (.o) that are linked by ld65 into the final ROM.

---

## Command-Line Options

```
ca65 [options] file.s

-D sym[=val]         Define assembler symbol
-I dir               Add include search directory
-U, --auto-import    Auto-import undefined symbols (link-time resolution)
-d, --debug          Debug mode
-g, --debug-info     Generate debug info for emulator symbol files
-i, --ignore-case    Ignore case in identifiers (useful for PDS ports)
-l name              Create listing file (.lst)
-mm model            Memory model (near, far, huge)
-o name              Output file name (default: input.o)
-s, --smart-mode     Smart mode (default) — optimize branch sizes
-S, --segment-list   Print segment listing after assembly
-t sys, --target sys Target system (nes, c64, none, etc.)
-v, --verbose        Verbose output
-W n                 Warning level (0=no warnings)
-x, --expand-macros  Expand macros in listing output
```

### Key Flags for NES RE

```bash
# Typical invocation for NES reassembly:
ca65 -g -t nes -I include/ -o build/bank0.o src/bank0.s

# With case-insensitive mode (for PDS port):
ca65 -i -g -t nes -I include/ -o build/bank0.o src/bank0.s
```

`-i` (ignore case) is critical when porting PDS source, which is case-insensitive.

---

## Expressions and Operators

### Numeric Literals

| Format | Example | Value |
|--------|---------|-------|
| Decimal | `42` | 42 |
| Hex `$` | `$FF` | 255 |
| Hex `0x` | `0xFF` | 255 |
| Binary `%` | `%10101010` | 170 |
| Character `'` | `'A'` | 65 |

With `.feature underline_in_numbers`: `$FF_00`, `%1010_0101` allowed.

### Operator Precedence (highest to lowest)

| Prec | Operators | Description |
|------|-----------|-------------|
| 1 | `+` `-` `~` `<` `>` `^` `.LOBYTE` `.HIBYTE` `.BANKBYTE` | Unary |
| 2 | `*` `/` `.MOD` `&` `.BITAND` `^` `.BITXOR` `<<` `.SHL` `>>` `.SHR` | Multiplicative / bitwise |
| 3 | `+` `-` `\|` `.BITOR` | Additive / bitwise OR |
| 4 | `=` `<>` `<` `>` `<=` `>=` | Comparison |
| 5 | `&&` `.AND` `.XOR` | Boolean AND/XOR |
| 6 | `\|\|` `.OR` | Boolean OR |
| 7 | `!` `.NOT` | Boolean NOT |

### Byte Selection

| Operator | Alias | Purpose | Example |
|----------|-------|---------|---------|
| `<` | `.LOBYTE()` | Low byte (bits 0–7) | `lda #<$1234` → `lda #$34` |
| `>` | `.HIBYTE()` | High byte (bits 8–15) | `lda #>$1234` → `lda #$12` |
| `^` | `.BANKBYTE()` | Bank byte (bits 16–23) | `lda #^$123456` → `lda #$12` |

### Pseudo Variables

| Variable | Purpose |
|----------|---------|
| `*` | Current program counter |
| `.CPU` | Current CPU instruction set flags |
| `.PARAMCOUNT` | Number of macro parameters (inside macro) |
| `.TIME` | Assembly time in UNIX seconds |
| `.VERSION` | Assembler version number |

### Pseudo Functions

| Function | Returns | Purpose |
|----------|---------|---------|
| `.ADDRSIZE(sym)` | 1/2/3/4 | Address size of symbol (1=ZP, 2=ABS, 3=FAR) |
| `.BANK(expr)` | number | Bank number of expression |
| `.BLANK(arg)` | bool | True if argument is blank |
| `.CONCAT(s1,s2)` | string | Concatenate strings |
| `.CONST(expr)` | bool | True if expression is constant |
| `.DEFINED(sym)` | bool | True if symbol is defined |
| `.DEFINEDMACRO(sym)` | bool | True if macro is defined |
| `.HIBYTE(expr)` | byte | Same as `>` |
| `.HIWORD(expr)` | word | High word of 32-bit value |
| `.IDENT(str)` | ident | Convert string to identifier |
| `.ISMNEMONIC(str)` | bool | True if string is valid mnemonic |
| `.LEFT(n, toks)` | tokens | First N tokens |
| `.LOBYTE(expr)` | byte | Same as `<` |
| `.LOWORD(expr)` | word | Low word of 32-bit value |
| `.MATCH(toks, ...)` | bool | Pattern match on tokens |
| `.MAX(a, b)` | number | Maximum |
| `.MID(s, n, toks)` | tokens | Middle N tokens starting at S |
| `.MIN(a, b)` | number | Minimum |
| `.REFERENCED(sym)` | bool | True if symbol was referenced |
| `.RIGHT(n, toks)` | tokens | Last N tokens |
| `.SIZEOF(type)` | number | Size of struct/union |
| `.SPRINTF(fmt, ...)` | string | Printf-style formatting |
| `.STRAT(str, idx)` | char | Character at index |
| `.STRING(toks)` | string | Convert tokens to string |
| `.STRLEN(str)` | number | String length |
| `.TCOUNT(toks)` | number | Token count |
| `.XMATCH(toks, ...)` | bool | Exact (case-sensitive) pattern match |

---

## Directives — Complete Reference

### Data Definition

```asm
.byte $FF, $00, $A5             ; define bytes
.word $8000, $C000              ; 16-bit words (little-endian)
.dword $12345678                ; 32-bit dwords
.faraddr label                  ; 24-bit far address
.dbyt $1234                     ; define big-endian word ($12, $34)
.asciiz "hello"                 ; null-terminated ASCII string
.res 16, $FF                    ; reserve 16 bytes, filled with $FF
.res 16                         ; reserve 16 bytes, uninitialized
.align 256                      ; align to 256-byte boundary
.align 256, $EA                 ; align with NOP fill
```

### Segments

```asm
.segment "BANK_0"               ; switch to named segment
.code                           ; switch to CODE segment
.data                           ; switch to DATA segment
.rodata                         ; switch to RODATA segment
.bss                            ; switch to BSS segment
.zeropage                       ; switch to ZEROPAGE segment
```

Segment names are defined in the ld65 linker config. Each `.segment` directive
switches output to that segment's area. Code/data from the same segment across
multiple source files is concatenated by the linker.

### Symbol Import/Export

```asm
.import symbol                  ; import (defined elsewhere)
.importzp symbol                ; import as zero-page
.export symbol                  ; export (visible to other objects)
.exportzp symbol                ; export as zero-page
.global symbol                  ; import if undefined, export if defined
.globalzp symbol                ; same, zero-page

; With explicit address size:
.import symbol : zeropage
.export symbol : absolute
```

### Labels and Scoping

```asm
; Global label
reset:
    sei

; Procedure (creates a scope):
.proc main_loop
    lda #$00
    @wait:                      ; cheap local — scoped to main_loop
        lda $2002
        bpl @wait
    rts
.endproc

; Anonymous scope:
.scope
    lda #$01
    @temp:                      ; invisible outside .scope
        nop
.endscope

; Anonymous labels:
:   lda $2002
    bpl :-                      ; branch backward to nearest ':'
    bne :+                      ; branch forward to nearest ':'
:   rts

; Named label with size:
enemy_table:
    .res 64
    .assert * - enemy_table = 64, error, "enemy_table size mismatch"
```

### Macros

```asm
; Basic macro with named parameters:
.macro MOVE_W src, dst
    lda src
    sta dst
    lda src+1
    sta dst+1
.endmacro

; Optional parameters:
.macro LOAD_A addr, index
    .ifnblank index
        ldy index
    .endif
    lda addr
.endmacro

; Variadic (check .paramcount):
.macro PUSH_REGS
    .if .paramcount >= 1
        pha
    .endif
    .if .paramcount >= 2
        txa
        pha
    .endif
.endmacro

; Macro with local labels:
.macro WAIT_VBLANK
    .local wait
wait:
    lda $2002
    bpl wait
.endmacro
```

### Conditional Assembly

```asm
.if EXPR                        ; numeric condition
.elseif EXPR
.else
.endif

.ifdef SYMBOL                   ; symbol defined?
.ifndef SYMBOL                  ; symbol not defined?

.ifblank ARG                    ; macro argument blank?
.ifnblank ARG                   ; macro argument not blank?

.ifref SYMBOL                   ; symbol referenced?
.ifnref SYMBOL                  ; symbol not referenced?

; Complex conditions:
.if .defined(MASTER) .and MASTER = 1
    ; production build
.endif
```

### Repeat

```asm
; Repeat block N times:
.repeat 8, i
    .byte 1 << i                ; generates: $01, $02, $04, $08, ...
.endrepeat
```

### Structs and Unions

```asm
.struct Sprite
    y_pos   .byte
    tile    .byte
    attr    .byte
    x_pos   .byte
.endstruct

; Usage:
    lda oam_buffer + Sprite::tile
    ; .sizeof(Sprite) = 4
```

### Assertions

```asm
.assert * <= $BFFF, error, "Bank overflow!"
.assert .sizeof(Sprite) = 4, error, "Sprite size wrong"
```

### Features

```asm
.feature c_comments              ; /* */ comments
.feature labels_without_colons   ; labels don't need trailing ':'
.feature underline_in_numbers    ; $FF_00 allowed
.feature force_range             ; strict value range checks
.feature line_continuations      ; \ at end of line continues
.feature bracket_as_indirect     ; [addr] for indirect (65816)
```

### Include and Binary Include

```asm
.include "macros.inc"            ; include source file (assembled)
.incbin "tiles.chr"              ; include raw binary data
.incbin "data.bin", 16, 256      ; offset 16, length 256
```

### Listing Control

```asm
.list on                         ; enable listing output
.list off                        ; disable listing
.listbytes 8                     ; show up to 8 bytes per listing line
```

### Misc

```asm
.out "Assembling bank 0..."     ; print message during assembly
.warning "Deprecated feature"    ; emit warning
.error "Fatal: bank overflow"    ; emit error, stop assembly
.fatal "Unrecoverable"           ; immediate abort

.addr label                      ; same as .word but marks as address
.charmap $41, $00                ; remap character codes (for custom fonts)

.pushseg                         ; save current segment
.popseg                          ; restore saved segment
```

---

## Address Sizes

ca65 tracks address sizes to generate correct instructions:

| Size | Name | Instructions Generated |
|------|------|----------------------|
| 1 byte | `zeropage` | Zero-page addressing (e.g., `LDA $xx`) |
| 2 bytes | `absolute` | Absolute addressing (e.g., `LDA $xxxx`) |
| 3 bytes | `far` | Far/long addressing (65816) |

Force address size with:
```asm
    lda z:variable              ; force zero-page
    lda a:variable              ; force absolute
    lda f:variable              ; force far (65816)
```

Or declare at import/export:
```asm
.importzp var_zp                ; zero-page size
.import var_abs : absolute      ; absolute size
```

---

## CPU Selection

```asm
.setcpu "6502"                  ; standard NMOS 6502
.setcpu "65C02"                 ; CMOS 65C02
.setcpu "65816"                 ; 65816
.setcpu "6502X"                 ; 6502 with undocumented opcodes
```

For NES (Ricoh 2A03): use `"6502"` — it's a standard NMOS 6502 without
decimal mode. The 2A03 executes all official and illegal 6502 opcodes.

Use `"6502X"` if the disassembly contains undocumented/illegal opcodes.
