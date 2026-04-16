# PDS to ca65 Translation Guide

Step-by-step reference for converting Codemasters PDS 6502 source code into
reassemblable ca65 code. This is the core workflow for the RE project.

---

## Critical: Byte Operator Swap

**This is the #1 source of bugs when porting PDS to ca65.**

| PDS | Meaning | ca65 Equivalent |
|-----|---------|----------------|
| `>expr` | **LOW** byte | `<expr` or `.lobyte(expr)` |
| `<expr` | **HIGH** byte | `>expr` or `.hibyte(expr)` |

Every `>` and `<` in the PDS source must be **swapped** in ca65. No exceptions.

```
; PDS original:
    lda #>sprite_table          ; LOW byte of sprite_table
    sta $00
    lda #<sprite_table          ; HIGH byte of sprite_table
    sta $01

; ca65 translation:
    lda #<sprite_table          ; LOW byte of sprite_table
    sta $00
    lda #>sprite_table          ; HIGH byte of sprite_table
    sta $01
```

---

## Hex Prefix

| PDS | ca65 |
|-----|------|
| `&FF` | `$FF` |
| `&8000` | `$8000` |
| `$FF` | `$FF` *(already valid)* |

Find-and-replace `&` with `$` in numeric contexts. Be careful not to replace
`&` in `.BITAND` or other non-hex uses (though PDS doesn't use those).

---

## Data Directives

| PDS | ca65 | Notes |
|-----|------|-------|
| `defb $FF, $00` | `.byte $FF, $00` | |
| `db $FF` | `.byte $FF` | `db` alias |
| `defw $8000` | `.word $8000` | |
| `dw $8000` | `.word $8000` | `dw` alias |
| `defs 100, $00` | `.res 100, $00` | Reserve with fill |
| `defs 100` | `.res 100` | Reserve (uninitialized) |

---

## Labels and Equates

```
; PDS:
PPUCTRL     equ &2000
counter     = 0
counter     = counter + 1
MyRoutine
            lda #&00
            rts

; ca65:
PPUCTRL     = $2000
counter     .set 0
counter     .set counter + 1
.proc MyRoutine
            lda #$00
            rts
.endproc
```

| PDS | ca65 | Notes |
|-----|------|-------|
| `NAME equ VALUE` | `NAME = VALUE` | Permanent equate |
| `NAME = VALUE` (reassignable) | `NAME .set VALUE` | Must use `.set` for reassignment |
| Label at column 0 | `label:` or `.proc label` | ca65 requires `:` (unless `.feature labels_without_colons`) |

### Case Sensitivity

PDS is case-insensitive. ca65 is case-sensitive by default.

Options:
1. **Use `-i` flag**: `ca65 -i` makes ca65 case-insensitive (easiest)
2. **Normalize case**: Convert all source to consistent case (cleanest)

---

## Macros

### Basic Conversion

```
; PDS:
    macro MOVE_W
        lda >@1
        sta >@2
        lda <@1
        sta <@2
    endm

; ca65:
.macro MOVE_W src, dst
    lda <src                    ; note: > and < swapped!
    sta <dst
    lda >src
    sta >dst
.endmacro
```

### Parameter Mapping

| PDS | ca65 |
|-----|------|
| `@1` | First named parameter |
| `@2` | Second named parameter |
| ... | ... |
| `@9` | Ninth named parameter |

PDS uses positional `@N`, ca65 uses named parameters. You must name them.

### Local Labels

```
; PDS:
    macro WAIT_VBLANK
!1      lda $2002
        bpl !1
    endm

; ca65:
.macro WAIT_VBLANK
    .local wait
wait:   lda $2002
        bpl wait
.endmacro
```

| PDS | ca65 |
|-----|------|
| `!1`–`!9` | `.local name` + `name:` |

### Optional Parameters

```
; PDS:
    macro LOAD_A
        ifs [@2] [ldy @2]
        lda @1
    endm

; ca65:
.macro LOAD_A addr, index
    .ifnblank index
        ldy index
    .endif
    lda addr
.endmacro
```

| PDS | ca65 |
|-----|------|
| `ifs [@N] [block]` | `.ifnblank param` / `.endif` |

---

## Conditional Assembly

```
; PDS:
    if master=0
        jsr CHECKPDS
    else
        nop : nop : nop
    endif

; ca65:
.if .not .defined(MASTER)
    jsr CHECKPDS
.else
    nop
    nop
    nop
.endif
```

| PDS | ca65 |
|-----|------|
| `if EXPR` | `.if EXPR` |
| `else` | `.else` |
| `endif` | `.endif` |
| `do` / `until` | `.repeat` / `.endrepeat` (different semantics) |

For the `master` flag specifically, use ca65 `-D MASTER=1` on the command line
or `.define MASTER 1` in a config include.

---

## Bank Directives

PDS `bank N` has no direct ca65 equivalent. It maps to segments:

```
; PDS:
    bank 0
    org &8000
    ; ... code ...

; ca65:
.segment "BANK_00"
    ; ... code ...
    ; (origin $8000 is set in ld65 .cfg, not in source)
```

### Key Difference: Origin

In PDS, `org &8000` is in the source. In ca65, the address is in the **linker
config** (`start = $8000` in the MEMORY section). Avoid `.org` in ca65 source
for banked code — let the linker handle it.

The only place `.org` is appropriate in ca65 is for the iNES header:
```asm
.segment "HEADER"
    .byte "NES", $1A    ; no .org needed — segment starts at $0000 per config
```

---

## Common PDS Macros → ca65

### Block Copy (ldir/lddr)

```
; PDS ldir macro (Z80-style forward block copy):
    macro ldir
        ; @1 = source, @2 = dest, @3 = count
        ...
    endm

; ca65 equivalent:
.macro ldir src, dst, count
    .local loop
    ldx #0
loop:
    lda src, x
    sta dst, x
    inx
    cpx #count
    bne loop
.endmacro
```

Or for large copies, use indirect addressing with `(zp),Y`.

### Variable Allocation (zvar/var)

```
; PDS:
zp_ptr = &00
    macro zvar
@1  equ zp_ptr
zp_ptr = zp_ptr + @2
    endm

; ca65:
.pushcharmap                    ; save state
zp_ptr .set $00

.macro zvar name, size
    name := zp_ptr
    zp_ptr .set zp_ptr + size
.endmacro
```

**Note:** ca65 doesn't allow macros to define global labels as cleanly. An
alternative approach is to just define all variables explicitly:

```asm
.zeropage
player_x:   .res 1              ; $00
player_y:   .res 1              ; $01
scroll_lo:  .res 1              ; $02
scroll_hi:  .res 1              ; $03
```

This is often cleaner than trying to replicate the `zvar` macro.

### Move Macros

```
; PDS move.w:
    macro move.w
        lda >@1
        sta >@2
        lda <@1
        sta <@2
    endm

; ca65 (note: dots in macro names not allowed, use underscore):
.macro move_w src, dst
    lda <(src)                  ; LOW byte — swapped from PDS >
    sta <(dst)
    lda >(src)                  ; HIGH byte — swapped from PDS <
    sta >(dst)
.endmacro
```

---

## send computer / PDS-Only Directives

These have no ca65 equivalent and should be removed:

| PDS Directive | Action |
|---------------|--------|
| `send computer1` | Remove entirely |
| `send computer2` | Remove entirely |
| `project "NAME"` | Remove (or convert to comment) |
| `asmflag N` | Remove |
| `path DIR` | Convert to `-I` flag on ca65 command line |
| `CURCOLOUR` | Remove (IDE-only) |
| `WINDOW` | Remove (IDE-only) |
| `CLOCK ON` | Remove (IDE-only) |
| `free` | Convert to `.assert` for size checking |

### Converting `free` to `.assert`

```
; PDS:
    free b0                     ; reports free bytes in bank 0

; ca65:
.segment "BANK_00"
    ; ... code ...
    .out .sprintf("Bank 0 free: %d bytes", $C000 - *)
    .assert * <= $C000, error, "Bank 0 overflow!"
```

---

## File Organization

### PDS → ca65 File Mapping

| PDS File | ca65 Equivalent | Notes |
|----------|----------------|-------|
| `MACROS.PDS` | `include/macros.inc` | Converted macros |
| `VARS.PDS` | `include/vars.inc` | Variable definitions (or in .zeropage/.bss) |
| `BANK0.PDS` + routines | `src/bank00.s` | One .s file per bank |
| `MUSIC1.MUS` | `src/music.s` | Sound engine |
| `CHRSETS.CHR` | `data/tiles.chr` + `.incbin` | Binary include |
| `MAPDATA.DAT` | `data/maps.bin` + `.incbin` | Binary include |
| `ROBIN.PRJ` | `Makefile` or `justfile` | Build system |

### Typical ca65 Project Layout

```
project/
├── Makefile                    ; or justfile
├── game.cfg                    ; ld65 linker config
├── include/
│   ├── macros.inc              ; converted PDS macros
│   ├── vars.inc                ; variable definitions
│   └── nes.inc                 ; NES hardware register constants
├── src/
│   ├── header.s                ; iNES header
│   ├── bank00.s                ; bank 0 code
│   ├── bank01.s                ; bank 1 code
│   ├── ...
│   ├── bank07.s                ; fixed bank (vectors, startup)
│   └── music.s                 ; sound engine
├── data/
│   ├── tiles.chr               ; CHR data (binary)
│   └── maps.bin                ; map data (binary)
└── build/                      ; output directory
    ├── game.nes
    ├── game.map
    └── game.lbl
```

---

## Conversion Checklist

For each PDS source file:

- [ ] Swap all `>` (low) to `<` and `<` (high) to `>`
- [ ] Replace `&` hex prefix with `$`
- [ ] Replace `defb`/`db` with `.byte`
- [ ] Replace `defw`/`dw` with `.word`
- [ ] Replace `defs` with `.res`
- [ ] Replace `equ` with `=`
- [ ] Replace reassignable `=` with `.set`
- [ ] Convert `macro`/`endm` to `.macro`/`.endmacro` with named params
- [ ] Replace `@1`–`@9` with named parameters
- [ ] Replace `!1`–`!9` with `.local` labels
- [ ] Replace `ifs [@N]` with `.ifnblank`
- [ ] Replace `if`/`else`/`endif` with `.if`/`.else`/`.endif`
- [ ] Replace `bank N` with `.segment "BANK_N"`
- [ ] Remove `org` (handled by linker config)
- [ ] Remove `send computer`, `project`, `asmflag`, `path`
- [ ] Remove `CURCOLOUR`, `WINDOW`, `CLOCK ON`
- [ ] Convert `free` to `.assert`
- [ ] Add `.include` for split files
- [ ] Test assembly and compare output to original ROM
