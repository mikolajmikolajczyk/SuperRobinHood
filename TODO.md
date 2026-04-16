# Super Robin Hood — Project TODO

## Status: ~85-90% Complete

The core reverse engineering is substantially done. The ROM reassembles
byte-identically, the music engine and tile compression are fully
reimplemented, and most game logic is annotated. What remains is
documentation polish, a few annotation gaps, and tooling for creators.

---

## Remaining Reverse Engineering

### Annotation Gaps

- [ ] **39 L-labels in bank3.s** — mostly in tight collision/animation
      inner loops and end-of-bank padding. Some may be dead code from
      development. Estimate: 4-8 hours of focused work.
- [ ] **Bank 1 annotation** — music engine is fully understood via
      musictool, but 206 L-labels remain in the raw disassembly.
      Many are music data tables that could be labelled from FORMAT.md.
- [ ] **Bank 2 annotation** — 84 L-labels remain. Logo animation and
      self-test code partially annotated.

### Undocumented Game Logic

- [ ] **Player physics formulas** — gravity constant, jump velocity,
      acceleration curves, wall-slide behavior. The code is annotated
      but the math hasn't been extracted as human-readable formulas.
- [ ] **Enemy AI state machines** — basic movement patterns understood
      (barrels, spiders, bats, cannons) but full state transition
      diagrams not documented. When do enemies change behavior?
      Re-spawn logic? Pursuit vs patrol switching?
- [ ] **Level progression** — map ordering, difficulty scaling. Is the
      map sequence fixed or dynamic? What triggers map transitions?
- [ ] **RNG/entropy** — how random events (barrel spawn timing, enemy
      placement) are seeded. Identified but not fully documented.
- [ ] **Collision edge cases** — pushing enemies off platforms, ladder
      grab zones, ceiling bonk behavior. Mostly understood, a few
      corner cases remain.
- [ ] **Unused/dead code** — some routines near end of bank3 may be
      disabled features or development leftovers. Needs investigation.

---

## Documentation

All documentation items completed:

- [x] **Project README** — [`README.md`](README.md)
- [x] **ARCHITECTURE.md** — [`ARCHITECTURE.md`](ARCHITECTURE.md)
- [x] **Sprite format documentation** — [`tools/spriteview/SPRITE_FORMAT.md`](tools/spriteview/SPRITE_FORMAT.md)

## Done ✓

- [x] Full disassembly of all 4 banks (64 KB)
- [x] Byte-identical ROM reassembly (`make verify`)
- [x] Original PDS source mapped to bank addresses
- [x] Bank3 annotation (434 named labels, 39 remaining)
- [x] PP1 tile compression — format documented, Rust compressor +
      decompressor, roundtrip-verified against all 12 ROM blocks
- [x] PP1 web demo — interactive step-by-step visualiser with
      compress/decompress modes, bitplane viewer, help manual,
      cc65 unpacker download, Docker deployment
- [x] Music engine — format fully documented (FORMAT.md), Rust
      parser + tick-accurate engine + APU synthesis, all 9 songs
      rendered to WAV, validated at 88% against 6502 emulator
- [x] Map data — all 14 maps, 256 blocks, collision attributes
- [x] Build system — make + ca65/ld65, automated annotation pipeline
- [x] Nix development environment (flake.nix)
- [x] Renamed original_source/ directory with updated references
