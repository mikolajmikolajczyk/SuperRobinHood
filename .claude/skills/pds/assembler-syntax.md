# PDS 6502 Assembler Syntax

Complete reference for the PDS 6502 assembler syntax, directives, macro system,
and comparison with ca65 (the modern assembler used for NES RE reassembly).

---

## Numeric Literals and Operators

### Number Bases

| Prefix | Base | Example | Value |
|--------|------|---------|-------|
| `&` | Hexadecimal | `&FF` | 255 |
| `$` | Hexadecimal (alt) | `$FF` | 255 |
| `%` | Binary | `%10101010` | 170 |
| *(none)* | Decimal | `42` | 42 |

`&` is the primary hex prefix inherited from the Z80 version. The 6502 version
also accepts `$` for compatibility with standard 6502 convention.

### Byte Selection Operators

> **⚠️ CRITICAL — REVERSED FROM STANDARD 6502 CONVENTION:**

| PDS | ca65 equivalent | Meaning | Example |
|-----|-----------------|---------|---------|
| `>` | `<` | **LOW byte** | `lda #>label` → low byte of `label` |
| `<` | `>` | **HIGH byte** | `lda #<label` → high byte of `label` |

This is the **single most confusing** PDS-ism. Every other major 6502 assembler
uses `<` for low byte and `>` for high byte. PDS reverses them.

**Mnemonic:** In PDS, think of `>` as "pointing down" (low) and `<` as
"pointing up" (high). Or just remember: **PDS is backwards.**

### Other Operators

| Operator | Purpose |
|----------|---------|
| `~` | XOR / complement |
| `+` `-` `*` `/` | Arithmetic |
| `=` | Equality test (in conditionals) / re-assignable label |
| `equ` | Permanent equate (cannot be reassigned) |

---

## Directives

### Assembly Control

| Directive | Example | Purpose |
|-----------|---------|---------|
| `org` | `org &8000` | Set program counter / origin |
| `bank` | `bank 12` | Switch to ROM bank N |
| `bank N,LABEL` | `bank 12,START` | Switch to bank N, set entry point (dev transfer) |
| `project` | `project "GAME NAME"` | Declare project name |
| `path` | `path c:\nes\robin` | Set include file search path |
| `asmflag` | `asmflag 0` | Set assembler flags/options |
| `OPTION` | `OPTION 0,0` | Assembler options |
| `LIST ON` / `LIST OFF` | | Toggle assembly listing |
| `free` | `free b13` | Report free bytes in current bank |
| `send computer1` | | Transfer assembled code to target 1 |
| `send computer2` | | Transfer assembled code to target 2 |
| `ASSEMBLER` | *(in .PRJ only)* | Trigger assembly from project file |

### Data Definition

| Directive | Aliases | Example | Purpose |
|-----------|---------|---------|---------|
| `defb` | `db` | `defb &FF,&00,&A5` | Define byte(s) |
| `defw` | `dw` | `defw &8000` | Define word (16-bit, little-endian) |
| `defs` | `ds` | `defs &4000,0` | Define space (fill N bytes with value) |

### Labels and Equates

```asm
LABEL       equ &1234           ; permanent constant (cannot reassign)
counter     = 0                 ; re-assignable label
counter     = counter + 1       ; can be updated

MyRoutine                       ; code label (at column 0)
            lda #&00            ; instructions indented
            rts
```

- Labels are **case insensitive**
- Labels at column 0 (no indentation)
- Instructions must be indented

### Conditional Assembly

```asm
        if master=0
            jsr CHECKPDS        ; only in development builds
        else
            nop
            nop
            nop                 ; pad to same size in production
        endif
```

| Directive | Purpose |
|-----------|---------|
| `if EXPR` | Begin conditional block |
| `else` | Alternate branch |
| `endif` | End conditional block |
| `do` | Begin assemble-time loop |
| `until EXPR` | End loop when expression is true |

---

## Macro System

### Definition

```asm
        macro MOVE_W            ; define macro MOVE_W
            lda >@1             ; low byte of first parameter
            sta >@2             ; low byte of second parameter
            lda <@1             ; high byte of first parameter
            sta <@2             ; high byte of second parameter
        endm
```

### Parameters

| Syntax | Purpose |
|--------|---------|
| `@1`–`@9` | Positional parameters (substituted at expansion) |
| `!1`–`!9` | Local labels (scoped to each macro expansion) |
| `ifs [@N] [block]` | Conditional: execute block if parameter @N was supplied |

### Usage

```asm
        MOVE_W source,dest      ; expands with @1=source, @2=dest
```

### Local Labels

```asm
        macro WAIT_VBLANK
!1      lda $2002               ; !1 is unique per expansion
            bpl !1
        endm
```

Each expansion of the macro generates a unique label for `!1`, preventing
conflicts when the macro is used multiple times.

### Optional Parameters

```asm
        macro LOAD_A
            ifs [@2] [ldy @2]   ; if @2 supplied, load Y with it
            lda @1
        endm

        LOAD_A data             ; expands to: lda data
        LOAD_A data,#&05        ; expands to: ldy #&05 / lda data
```

---

## Common Codemasters Macro Patterns

### Z80-Derived Block Copy Macros

PDS was originally a Z80 tool. These 6502 macros emulate Z80 block operations:

| Macro | Z80 Origin | 6502 Implementation |
|-------|-----------|---------------------|
| `ldir` | `LDIR` (Load, Increment, Repeat) | Block copy forward (incrementing addresses) |
| `lddr` | `LDDR` (Load, Decrement, Repeat) | Block copy backward (decrementing addresses) |
| `sldir` | — | Slow/safe LDIR variant |
| `slddr` | — | Slow/safe LDDR variant |

### 68K-Style Move Macros

| Macro | Purpose | Equivalent |
|-------|---------|------------|
| `move.w SRC,DST` | Copy 16-bit word | LDA/STA low byte + LDA/STA high byte |
| `move.b SRC,DST` | Copy 8-bit byte | LDA SRC / STA DST |

### Variable Allocation Macros

```asm
; Zero-page auto-allocator
zp_ptr  = &00                   ; zero page allocation pointer

        macro zvar NAME,SIZE
NAME    equ zp_ptr
zp_ptr  = zp_ptr + SIZE
        endm

; RAM auto-allocator
ram_ptr = &0300                 ; RAM allocation pointer

        macro var NAME,SIZE
NAME    equ ram_ptr
ram_ptr = ram_ptr + SIZE
        endm
```

Usage:
```asm
        zvar player_x,1         ; allocates 1 byte in zero page
        zvar player_y,1         ; next byte
        zvar scroll_pos,2       ; 2 bytes (word)

        var enemy_table,64      ; allocates 64 bytes in RAM at $0300+
        var map_buffer,256      ; next 256 bytes
```

### Register Pair Macros

| Macro | Z80 Origin | Purpose |
|-------|-----------|---------|
| `ldxy ADDR` | `LD BC,nn` | Load X (low) and Y (high) from address |
| `cphlde` | `CP HL,DE` | Compare 16-bit values using X/Y as pseudo-registers |

---

## PDS vs ca65 Comparison

Quick reference for translating between PDS source and ca65 reassembly:

| Feature | PDS | ca65 |
|---------|-----|------|
| Hex prefix | `&FF` or `$FF` | `$FF` |
| Low byte | `>label` | `<label` or `.lobyte(label)` |
| High byte | `<label` | `>label` or `.hibyte(label)` |
| Define byte | `defb` / `db` | `.byte` |
| Define word | `defw` / `dw` | `.word` |
| Define space | `defs N,VAL` | `.res N, VAL` |
| Equate | `NAME equ VALUE` | `NAME = VALUE` or `NAME := VALUE` |
| Re-assignable | `NAME = VALUE` | `NAME .set VALUE` |
| Macro def | `macro NAME` / `endm` | `.macro NAME` / `.endmacro` |
| Macro params | `@1`–`@9` | Named params or `.paramcount` |
| Local labels | `!1`–`!9` | `@label` (cheap locals) |
| Conditional | `if` / `else` / `endif` | `.if` / `.else` / `.endif` |
| Origin | `org &8000` | `.org $8000` or segments |
| Include | `path c:\dir` | `.include "file"` |
| Bank | `bank N` | `.segment "BANK_N"` (via linker config) |
| Comment | `;` | `;` |
| Case | Insensitive | Sensitive (by default) |

### Key Porting Gotchas

1. **Swap all `>` and `<` byte operators** — this is mandatory
2. **Convert `&` to `$`** for hex literals
3. **Rewrite macros** — ca65 uses named parameters, not `@1`–`@9`
4. **Replace `!N` local labels** with ca65 cheap locals (`@label`)
5. **Replace `defb`/`defw`/`defs`** with `.byte`/`.word`/`.res`
6. **Handle `bank` directives** via ca65 segments + ld65 linker config
7. **Remove `send computer`** — not applicable for ROM image output
8. **Case sensitivity** — ca65 is case-sensitive; PDS is not
