# da65 Disassembler — Complete Reference

The da65 disassembler produces ca65-compatible assembly from binary ROM data.
It uses "info files" to annotate code vs data regions and label addresses.

---

## Command-Line Options

```
da65 [options] file.bin

--cpu type            CPU type: 6502, 65C02, 65816, 6502X, etc.
-S addr, --start-addr Start address (origin) of the binary
-i name, --info name  Info file for annotations
-o name               Output file (default: stdout)
-v, --verbose         Verbose output

--comments n          Comment verbosity level (0–4, default 2)
--hexoffs             Use hex for label offsets
-m, --multi-pass      Multi-pass disassembly (resolves forward references)

--argument-column n   Column for operands (default: 24)
--comment-column n    Column for comments (default: 48)
--mnemonic-column n   Column for mnemonics (default: 9)
--text-column n       Column for text output (default: 40)

-g, --debug-info      Add .DEBUGINFO directive to output
-F, --formfeeds       Add formfeed characters between pages
--label-break n       Insert blank line every N labels
--pagelength n        Lines per page (with -F)
```

### Typical Usage

```bash
# Disassemble a single 16 KiB bank:
da65 --cpu 6502 -S $8000 -i bank0.info -o bank0.s bank0.bin

# Disassemble with high verbosity and multi-pass:
da65 --cpu 6502 -S $C000 -i fixed_bank.info -o fixed_bank.s \
     --comments 4 -m fixed_bank.bin
```

### Multi-Pass Mode (`-m`)

Without `-m`, da65 makes a single forward pass and may misidentify data
following a branch target. Multi-pass mode resolves forward references and
produces cleaner output — **always use it**.

---

## Info File Format

Info files tell da65 what's code, what's data, and what labels to use. This
is where your RE knowledge goes — iteratively refining the info file produces
progressively better disassembly.

### Global Section

```
GLOBAL {
    STARTADDR $8000;            # origin address
    CPU "6502";                 # CPU type
    COMMENTS 4;                 # max comment verbosity
    HEXOFFS;                    # hex offsets in output
    INPUTNAME "bank0.bin";      # input file name
    INPUTOFFS $0000;            # offset into input file
    INPUTSIZE $4000;            # bytes to disassemble
    OUTPUTNAME "bank0.s";       # output file name
}
```

### RANGE Section

Define regions as code or specific data types:

```
# Code region:
RANGE { START $8000; END $80FF; TYPE CODE; }

# Byte table (e.g., tile indices):
RANGE { START $8100; END $813F; TYPE BYTETABLE; }

# Word table (e.g., address table):
RANGE { START $8140; END $815F; TYPE WORDTABLE; }

# Text string:
RANGE { START $8160; END $817F; TYPE TEXTTABLE; }

# Named range:
RANGE { START $8180; END $81FF; TYPE CODE; NAME "enemy_ai"; }

# Range with comment:
RANGE { START $8200; END $82FF; TYPE BYTETABLE; COMMENT "Level 1 map data"; }
```

### Range Types

| Type | Purpose | Output Format |
|------|---------|--------------|
| `CODE` | 6502 instructions | Disassembled mnemonics |
| `BYTETABLE` | Byte data | `.byte $xx, $xx, ...` |
| `WORDTABLE` | 16-bit word data | `.word $xxxx, $xxxx, ...` |
| `DWORDTABLE` | 32-bit data | `.dword $xxxxxxxx, ...` |
| `ADDRTABLE` | Address table | `.addr label, label, ...` |
| `RTSTABLE` | RTS dispatch table | `.word label-1, label-1, ...` |
| `DBYTETABLE` | Double-byte table | `.dbyt $xxxx, ...` (big-endian) |
| `TEXTTABLE` | ASCII text | `.byte "text...", $00` |
| `SKIP` | Skip region | *(no output)* |

### RTSTABLE — RTS Dispatch Pattern

Many NES games use the "RTS trick" for indirect jumps:

```asm
; Push address-1 onto stack, then RTS jumps to it:
    lda jump_table_hi,x
    pha
    lda jump_table_lo,x
    pha
    rts

; The table contains target addresses minus 1:
jump_table:
    .word handler_a - 1
    .word handler_b - 1
```

Mark these tables as `RTSTABLE` so da65 generates correct `addr-1` output.

### LABEL Section

```
LABEL { ADDR $8000; NAME "reset"; }
LABEL { ADDR $8050; NAME "nmi_handler"; }
LABEL { ADDR $80A0; NAME "irq_handler"; COMMENT "unused - just RTI"; }
LABEL { ADDR $0010; NAME "player_x"; SIZE 1; }
LABEL { ADDR $0011; NAME "player_y"; SIZE 1; }
LABEL { ADDR $0300; NAME "enemy_table"; SIZE 64; }
```

| Property | Purpose |
|----------|---------|
| `ADDR` | Address of the label |
| `NAME` | Label name (valid ca65 identifier) |
| `SIZE` | Size in bytes (helps da65 avoid splitting) |
| `COMMENT` | Comment added to output |
| `PARAMSIZE` | For subroutines: bytes of inline parameters after JSR |

### SEGMENT Section

Define output segment names:

```
SEGMENT { START $8000; END $BFFF; NAME "BANK_00"; }
SEGMENT { START $C000; END $FFF9; NAME "BANK_07"; }
SEGMENT { START $FFFA; END $FFFF; NAME "VECTORS"; }
```

This causes da65 to emit `.segment "BANK_00"` directives in the output,
matching your ld65 linker config.

---

## Iterative Disassembly Workflow

### Step 1: Initial Pass

Start with minimal info — just the origin and CPU:

```
GLOBAL { STARTADDR $8000; CPU "6502"; COMMENTS 4; }
```

```bash
da65 --cpu 6502 -S $8000 -m -i minimal.info -o first_pass.s rom.bin
```

### Step 2: Identify Code vs Data

Use emulator CDL (Code/Data Logger) to determine which regions are code.
Both Mesen and FCEUX can export CDL data.

Add RANGE entries for known data regions to prevent misidentification:

```
RANGE { START $8500; END $85FF; TYPE BYTETABLE; COMMENT "tile data"; }
```

### Step 3: Add Labels

From emulator debugging, add labels for known routines and variables:

```
LABEL { ADDR $C000; NAME "reset"; }
LABEL { ADDR $C080; NAME "nmi"; }
LABEL { ADDR $C100; NAME "main_loop"; }
```

### Step 4: Refine and Repeat

Each pass through the emulator reveals more labels and data types. Update the
info file, re-run da65, review the output. Eventually you have a complete,
annotated disassembly ready for conversion to a reassemblable project.

### Step 5: Multi-Bank

For multi-bank ROMs, split the binary and disassemble each bank separately:

```bash
# Extract individual 16 KiB banks (skip 16-byte iNES header):
dd if=game.nes bs=16384 skip=0 count=1 iflag=skip_bytes,count_bytes \
   skip=16 of=bank0.bin
dd if=game.nes bs=16384 skip=1 count=1 iflag=skip_bytes,count_bytes \
   skip=16 of=bank1.bin
# ... etc

# Disassemble each:
da65 --cpu 6502 -S $8000 -m -i bank0.info -o bank0.s bank0.bin
da65 --cpu 6502 -S $C000 -m -i bank7.info -o bank7.s bank7.bin
```

---

## Comment Levels

The `--comments` flag controls output verbosity:

| Level | Output |
|-------|--------|
| 0 | No comments |
| 1 | Only LABEL/RANGE comments |
| 2 | + auto-generated comments for hardware registers |
| 3 | + address in hex for each instruction |
| 4 | + raw bytes for each instruction |

Level 4 is most useful during initial RE — you can see the hex bytes alongside
the disassembly for manual verification.

---

## Tips for NES RE

1. **Use CDL data**: Play the game in Mesen with CDL enabled. Export the CDL
   and convert it to da65 RANGE entries. This dramatically reduces
   code-vs-data misidentification.

2. **Vectors first**: Always label `$FFFA` (NMI), `$FFFC` (RESET), `$FFFE` (IRQ)
   and trace from the RESET handler.

3. **Hardware registers**: da65 with `--comments 2+` auto-comments PPU/APU
   register accesses. But add explicit labels for cleaner output:
   ```
   LABEL { ADDR $2000; NAME "PPUCTRL"; }
   LABEL { ADDR $2001; NAME "PPUMASK"; }
   ```

4. **Bank switching writes**: In Mapper 71, any write to `$C000–$FFFF` is a
   bank switch. Mark these in comments so they stand out.

5. **CHR-RAM copies**: Look for loops writing to `$2007` (PPUDATA) — these are
   CHR-RAM tile uploads. Mark the source data as `BYTETABLE`.
