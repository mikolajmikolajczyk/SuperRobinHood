# NES Reverse Engineering Toolchains

## Emulator-Debuggers

These are your primary tools for interactive analysis. Use an emulator with
debugging features to step through code, set breakpoints, watch memory, and
log code/data access patterns.

### Mesen (Recommended)

- **Platform**: Windows, Linux (via Mono/.NET)
- **URL**: https://github.com/SourMesen/Mesen2
- **Key features**:
  - Integrated debugger with source-level debugging
  - Code/Data Logger (CDL) — automatically tags executed code vs loaded data
  - Symbolic debugging — import/export label files
  - Memory viewer, PPU viewer, sprite viewer, nametable viewer
  - Trace logger (logs every executed instruction)
  - Breakpoints on read/write/execute at any address
  - Watch window for RAM values
  - Performance profiler
  - Script support (Lua)
  - Supports NES 2.0 headers and all common mappers including 71 and 232
- **Best for**: Detailed analysis, CDL generation, label management
- **Tip**: Export CDL and label files from Mesen, then feed them into a
  disassembler for the static analysis phase.

### FCEUX

- **Platform**: Windows, Linux, macOS (SDL build)
- **URL**: https://github.com/TASEmulators/fceux
- **Key features**:
  - Built-in debugger with breakpoints
  - Code/Data Logger (CDL)
  - Symbolic debugging
  - Hex editor with in-place RAM editing
  - PPU viewer, nametable viewer
  - Trace logger
  - Cheat search (RAM search by value change pattern)
  - Lua scripting
  - TAS (Tool-Assisted Speedrun) features (movie recording, rerecording)
  - NES Game Genie decoder
- **Best for**: Quick RAM analysis, cheat search, TAS-related RE
- **Note**: FCEUX emulates bus conflicts by default, which can cause issues
  with some Codemasters games (notably Dreamworld Pogie). Check mapper
  settings if a game misbehaves.

### Nintendulator

- **Platform**: Windows
- **URL**: https://github.com/quietust/Nintendulator
- **Key features**:
  - Cycle-accurate emulation
  - Debugger with breakpoints
  - NES 2.0 support
- **Best for**: Accuracy testing, verifying timing-sensitive behavior

---

## Assemblers

For reassembling modified disassemblies or writing patches/homebrew.

### cc65 Suite (Recommended for RE)

- **Components**: ca65 (assembler), ld65 (linker), da65 (disassembler),
  cc65 (C compiler), ar65 (librarian)
- **URL**: https://github.com/cc65/cc65
- **Install**: `sudo apt install cc65` (Debian/Ubuntu) or build from source
- **Language**: 6502/65C02/65816 assembly + C cross-compiler
- **Key features**:
  - Powerful macro assembler with segments, scopes, structs
  - Linker scripts define memory layout — essential for NES ROM building
  - `.charmap` directive for custom character encoding
  - `.dbg` debug symbol output compatible with Mesen
  - da65 disassembler accepts info files for labeling
- **Best for**: Full disassembly projects, C+ASM hybrid development
- **NES-specific**: Use a linker config that maps segments to NES memory
  layout (PRG banks, CHR, vectors).

### asm6 / asm6f

- **URL**: https://github.com/freem/asm6f (asm6f fork with NES 2.0 support)
- **Language**: 6502 assembly
- **Key features**:
  - Simple, single-pass assembler
  - No linker needed — direct binary output
  - Supports NES 2.0 header generation
  - Lightweight and fast
- **Best for**: Quick patches, small projects, beginners

### NESASM (MagicKit)

- **URL**: Various forks available
- **Language**: 6502 assembly
- **Key features**:
  - NES-specific directives (.bank, .org, .incbin)
  - Used by many older tutorials (Nerdy Nights)
- **Limitation**: Less powerful than ca65, limited macro support
- **Best for**: Following older tutorials

### llvm-mos

- **URL**: https://github.com/llvm-mos/llvm-mos
- **Language**: C/C++ → 6502 (LLVM-based compiler)
- **Key features**:
  - Modern optimizing C compiler targeting 6502
  - Much better code generation than cc65's C compiler
  - LLVM infrastructure (clang frontend, LTO, etc.)
- **Best for**: Writing new C code for NES, not typically for RE

### NESFab

- **URL**: https://github.com/pubby/nesfab
- **Language**: Custom language designed for NES
- **Key features**:
  - Asset management and level editing IDE
  - Designed specifically for NES game development
- **Best for**: New game development, not RE

---

## Disassemblers

For producing assembly source from ROM binaries.

### da65 (from cc65 suite)

- **Best for RE projects**: Output is directly compatible with ca65/ld65
- Accepts info files (.info) to specify:
  - Code vs data regions
  - Labels and comments
  - Address ranges for each segment
- Iterative workflow: disassemble → add labels → re-disassemble → repeat
- Can be fed CDL data (with conversion script) to auto-tag code/data

### nesgodisasm

- **URL**: https://github.com/retroenv/nesgodisasm
- Tracing disassembler (follows code flow from vectors)
- Outputs compatible with asm6, ca65, or nesasm
- Good for initial automated disassembly

### 6502bench / SourceGen

- **URL**: https://github.com/fadden/6502bench
- **Platform**: Windows (.NET/WPF)
- Interactive GUI disassembler
- Point-and-click label editing
- Cross-reference tracking
- Supports NES with platform symbol files
- Exports to ca65, ACME, 64tass, Merlin 32

### Ghidra (with 6502 plugin)

- **URL**: https://ghidra-sre.org/
- General-purpose reverse engineering framework
- Has 6502 processor module
- **Note**: Community consensus is that Ghidra is overkill for 6502/NES RE.
  The 6502 instruction set is simple enough that dedicated NES tools
  (Mesen debugger + da65) are more productive. Ghidra excels at more
  complex architectures.

### IDA Pro (with NES loader)

- Commercial disassembler
- Custom iNES loader plugins exist (support bank separation)
- Powerful cross-reference and function analysis
- Expensive — mostly used by professionals who already have it

### BZK NES Disassembler

- Takes CDL files from FCEUX as input
- Good for automated code/data separation

### clever-disasm (by Bisqwit)

- Part of the nescom assembler suite
- Can simulate CPU execution and track mapper access
- Supports mappers 0, 2, 3, 24
- Iterative: configuration file grows as understanding deepens

---

## Hex Editors

### HxD (Windows)
- Free, fast hex editor
- Good for quick ROM inspection

### ImHex
- Cross-platform pattern-based hex editor
- Can define NES ROM structures for visual parsing

### Built-in Emulator Hex Editors
- FCEUX has a built-in hex editor that shows live RAM/ROM
- Can edit values in real-time for testing

---

## Graphics Tools

### YY-CHR

- **Platform**: Windows
- CHR/tile editor for NES (and other systems)
- Can open .nes files directly and view/edit pattern tables
- Supports 1bpp, 2bpp (NES native), 4bpp, 8bpp
- Essential for understanding tile layout in ROMs

### Tile Layer Pro

- Older tile editor, still widely used
- Can view raw ROM data as tiles in various formats

### NES Screen Tool

- **URL**: https://shiru.untergrund.net/
- Nametable editor — design backgrounds with tile/palette assignments
- Can export to assembly-compatible formats

---

## Audio Tools

### FamiTracker

- NES music tracker / composer
- Can import NSF (NES Sound Format) files
- Useful for understanding music data format in games
- Not directly for RE, but helps understand APU usage

### NSFPlay

- NSF/NSFe player
- Can visualize channel activity
- Useful for identifying which APU channels a game uses

---

## ROM Utilities

### NES Header Tools

- **Quietust's iNES Header Editor**: Edit/fix iNES and NES 2.0 headers
- **MakeINES**: Build .nes files from assembler output
- **NESColumns**: Windows Explorer extension showing mapper/size info

### ROM Comparison

- **diff / hexdiff**: Compare ROM binaries
- Always compare your reassembled ROM against the original to verify 1:1 match

### GoodNES / No-Intro

- ROM verification databases
- Ensure you have correct, clean dumps before starting RE

---

## Workflow Integration

### Recommended RE Workflow (Codemasters games)

```
1. Verify ROM with No-Intro database
   └── Ensure clean dump, correct header (mapper 71 or 232)

2. Initial analysis in Mesen
   ├── Enable CDL logging
   ├── Play through game to maximize code coverage
   ├── Export CDL file
   └── Start naming key addresses (vectors, bank switch, etc.)

3. Static disassembly with da65
   ├── Create info file from CDL data + Mesen labels
   ├── Run da65 to produce .s assembly source
   ├── Reassemble with ca65/ld65 → verify 1:1 match
   └── Iterate: add labels, re-disassemble, verify

4. Deep analysis
   ├── Map RAM layout (zero page vars, object tables)
   ├── Identify main loop, NMI handler, game states
   ├── Trace bank switching (writes to $C000+)
   ├── Document subroutine purposes
   └── Map graphics/audio data structures

5. Modification/patching
   ├── Edit assembly source
   ├── Reassemble → test in emulator
   └── Verify on hardware (if applicable)
```

### Installing cc65 on Common Platforms

```bash
# Debian/Ubuntu/NixOS
sudo apt install cc65
# or: nix-env -iA nixpkgs.cc65

# macOS (Homebrew)
brew install cc65

# From source
git clone https://github.com/cc65/cc65.git
cd cc65
make
sudo make install

# Verify
ca65 --version
ld65 --version
da65 --version
```

### Basic da65 Usage for NES ROM

```bash
# Extract PRG-ROM from .nes file (skip 16-byte header)
dd if=game.nes of=prg.bin bs=1 skip=16 count=$((PRG_BANKS * 16384))

# Disassemble with info file
da65 -i game.info -o game.s prg.bin

# Reassemble and link
ca65 game.s -o game.o
ld65 -C nes.cfg -o game_rebuilt.nes game.o

# Verify
diff <(xxd game.nes) <(xxd game_rebuilt.nes)
```

### Sample da65 Info File for Mapper 71

```
# game.info - da65 configuration for Codemasters game

GLOBAL {
    STARTADDR $8000;
    INPUTSIZE $40000;      # 256 KiB = 16 banks × 16384
};

# Fixed bank (last bank, contains vectors)
RANGE { START $3C000; END $3FFFF; TYPE CODE; };

# Label the vectors
LABEL { ADDR $FFFA; NAME "NMI_VECTOR"; };
LABEL { ADDR $FFFC; NAME "RESET_VECTOR"; };
LABEL { ADDR $FFFE; NAME "IRQ_VECTOR"; };

# Known RAM addresses
LABEL { ADDR $0000; NAME "zp_temp"; };
LABEL { ADDR $0200; NAME "oam_buffer"; };

# PPU registers
LABEL { ADDR $2000; NAME "PPUCTRL"; };
LABEL { ADDR $2001; NAME "PPUMASK"; };
LABEL { ADDR $2002; NAME "PPUSTATUS"; };
LABEL { ADDR $2005; NAME "PPUSCROLL"; };
LABEL { ADDR $2006; NAME "PPUADDR"; };
LABEL { ADDR $2007; NAME "PPUDATA"; };
LABEL { ADDR $4014; NAME "OAMDMA"; };
LABEL { ADDR $4015; NAME "APU_STATUS"; };
LABEL { ADDR $4016; NAME "JOY1"; };
LABEL { ADDR $4017; NAME "JOY2_FRAMECTR"; };
```
