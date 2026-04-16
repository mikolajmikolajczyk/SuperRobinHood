# Super Robin Hood — Reverse Engineering

A complete reverse-engineering project for **Super Robin Hood** (Codemasters /
Camerica, 1990) on the NES. This repository contains a byte-identical
disassembly of the original ROM, modern Rust reimplementations of its asset
formats (tile compression, music engine, sprite/map renderers), and
documentation describing how the game was built.

## What is Super Robin Hood?

Super Robin Hood is an unlicensed NES platformer published by Codemasters
(UK) / Camerica (North America) in 1990 — part of the Quattro Adventure
compilation and the earliest 8-bit game in the Camerica *Robin Hood*
series. It was written in PDS 6502 assembly by the Oliver Twins, with
music by **Gavin Raeburn** ("Mega Music Driver", © 1990).

The cartridge uses the Codemasters BF909x mapper (**iNES mapper 71**) — 4 ×
16 KB PRG banks, no CHR-ROM (tiles are decompressed into CHR-RAM at
runtime using the **PP1** format).

## Status — ~90 % Complete

- ✅ Full disassembly of all 4 PRG banks (64 KB)
- ✅ Byte-identical reassembly via cc65 (`make verify`)
- ✅ PP1 tile compression — format documented + Rust codec, roundtrip-verified
- ✅ Music engine — format documented + tick-accurate Rust engine + WAV renderer (88 % validation vs. 6502 emulator)
- ✅ Map data — all 14 maps rendered as PNG
- ✅ Sprite data — all 66 sprites rendered as PNG via 6502 emulator
- 🟡 Bank 3 annotation (434 named labels, 39 L-labels remaining — mostly data)
- 🟡 Bank 1 / 2 annotation in progress (see [TODO.md](TODO.md))

See [ARCHITECTURE.md](ARCHITECTURE.md) for the big-picture overview.

## Repository Layout

```
srh/
├── README.md             # this file
├── ARCHITECTURE.md       # ROM layout, memory map, subsystem overview
├── TODO.md               # remaining reverse-engineering work
├── flake.nix             # Nix dev environment (cc65, mesen, fceux, rust, node)
│
├── roms/
│   ├── released.nes      # the released ROM (reference, not included)
│   └── prerelease.nes    # pre-release ROM built from recovered PDS source
│
├── original_source/      # near-final PDS source files (from Wireframe magazine leak)
│   ├── src/*.ROU         # 6502 source modules
│   ├── src/*.MUS         # music data
│   ├── src/*.PP1         # compressed CHR data
│   └── src/PP1PACK.EXE   # original compressor (MS-DOS)
│
├── disasm/
│   ├── raw/bank*.s       # output of da65 (regenerable)
│   ├── info/bank*.info   # da65 configuration (byte ranges, data tables)
│   ├── info/bank*.map    # historical annotation directives (reference)
│   ├── info/macros/*.inc # ca65 replacements for data-table macros
│   ├── src/bank*.s       # canonical hand-annotated source
│   ├── banks/            # (gitignored) 16 KB bank dumps, extracted from released.nes
│   ├── BANK_MAP.md       # which PDS source file lives in which bank
│   ├── game.cfg          # ld65 linker config
│   └── Makefile          # disasm, build, verify
│
└── tools/                # Rust tooling
    ├── pp1tool/          # PP1 compress/decompress CLI
    ├── pp1web/           # interactive PP1 teaching demo (React/TypeScript)
    ├── musictool/        # music parser + engine + WAV renderer
    ├── mapview/          # map → PNG renderer
    └── spriteview/       # sprite → PNG renderer (via 6502 emulator)
```

## Quick Start

### With Nix (recommended)

```bash
direnv allow           # or: nix develop
cd disasm
make                   # reassemble ROM from src/
make verify            # confirms byte-identical match
make run               # launches fceux with the built ROM
```

### Without Nix

Install [cc65](https://cc65.github.io) and Rust (stable), then:

```bash
cd disasm && make verify
cd ../tools/musictool && cargo build --release
```

## Building & Verifying the ROM

Place a Super Robin Hood (Camerica, 1990) PRG dump at
`roms/released.nes`. The expected SHA-256 is:

```
ae6c7a412732cba05490a4d355b7a619e201583b7f5b99d0148d888293a88076
```

Then:

```bash
cd disasm
make verify-rom   # check your released.nes has the expected sha256
make              # build/game.nes
make verify       # → "MATCH: byte-identical!"
make verify-banks # per-bank comparison
```

## Regenerating the Raw Disassembly

`src/` is the canonical, hand-annotated source. The pristine `da65`
output in `raw/` and the 16 KB bank dumps in `banks/` are both
**derived from the copyrighted `released.nes`** — they are not
committed. If you need to regenerate them (e.g. after tweaking
`info/*.info`):

```bash
cd disasm
make extract-banks  # banks/bank*.bin ← split released.nes
make disasm         # raw/bank*.s    ← da65 + info/*.info   (reference only)
make                # rebuild ROM from src/
make verify         # confirm still byte-identical
```

Edits to the assembly should be made directly in `src/bankN.s`.

## Tools

| Tool | Purpose |
|------|---------|
| [pp1tool](tools/pp1tool/)       | CLI for PP1 tile compression — used by build scripts and for roundtrip verification |
| [pp1web](tools/pp1web/)         | Interactive React/TypeScript teaching demo — visualises PP1 bit-by-bit |
| [musictool](tools/musictool/)   | Parses Codemasters "Mega Music Driver" songs and renders to WAV |
| [mapview](tools/mapview/)       | Renders any of the 14 in-game maps to PNG |
| [spriteview](tools/spriteview/) | Renders any of the 66 sprite definitions to PNG (runs game code in a 6502 emulator) |

## Format Documentation

- [tools/pp1tool — PP1 tile compression](tools/pp1tool/) — context-based pixel predictor with ROM lookup tables
- [tools/musictool/FORMAT.md](tools/musictool/FORMAT.md) — complete binary layout of songs, instruments, note events
- [tools/spriteview/SPRITE_FORMAT.md](tools/spriteview/SPRITE_FORMAT.md) — hierarchical sprite format (SPRITESD.DAT)
- [disasm/BANK_MAP.md](disasm/BANK_MAP.md) — which PDS source file lives in which physical bank

## Credits

- **The Oliver Twins** (Philip & Andrew Oliver) — original game code
- **Gavin Raeburn** — music engine
- **Codemasters** / **Camerica** — publishers
- **Wireframe Magazine #34** — published the PDS source under CC BY-NC-SA 3.0
  ("Squeezing the NES", pp. 30-35, by Philip & Andrew Oliver;
  [Wireframe-Magazine/Wireframe-34](https://github.com/Wireframe-Magazine/Wireframe-34))

`roms/prerelease.nes` is a clean-build artifact of the recovered PDS
source (shipped with this repo). The commercial `roms/released.nes` is
not included and must be supplied separately.

## License

- All tools, documentation, and reverse-engineering annotations
  written for this project are released under the **MIT License**.
- `original_source/` and `roms/prerelease.nes` are redistributed
  from [Wireframe-Magazine/Wireframe-34](https://github.com/Wireframe-Magazine/Wireframe-34)
  under **CC BY-NC-SA 3.0** (non-commercial, share-alike, attribute
  the Oliver Twins).
- The released ROM itself and the assembled 6502 code it contains
  remain the copyright of Codemasters / Camerica.

See [LICENSE](LICENSE) for the full breakdown.
