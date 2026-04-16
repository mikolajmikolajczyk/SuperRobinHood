# Super Robin Hood — Architecture

The "big picture" view of how the ROM is laid out and how subsystems
communicate. For byte-level bank contents see
[`disasm/BANK_MAP.md`](disasm/BANK_MAP.md); for asset formats see the
per-tool FORMAT.md files.

---

## 1. Cartridge Hardware

| | |
|---|---|
| **Mapper** | Codemasters BF909x (iNES mapper 71) |
| **PRG ROM** | 4 × 16 KB = 64 KB |
| **CHR** | RAM (no CHR-ROM — tiles are decompressed at runtime) |
| **Mirroring** | Vertical |
| **Battery** | None (no saves) |
| **CIC** | Stun circuit (unlicensed bypass) |

### Bank Switching

Mapper 71 gives a single switchable 16 KB window and one fixed 16 KB window:

```
CPU address          PRG ROM source
──────────────────   ──────────────────────
$8000–$BFFF          switchable  (banks 0, 1, 2, or 3)
$C000–$FFFF          fixed       (always bank 3)
```

A write to **any** address in `$C000–$FFFF` selects the switchable bank.
The value written is masked by `& 3`, so bits 0–1 pick the physical bank
(0/1/2). Writing `3` keeps the (already-fixed) bank at both windows.

In the disassembly this happens via the `bank_table` at `$C00A`:

```asm
bank_table:
    .byte $00,$01,…,$0B        ; unused slots
banksel12: .byte $0C            ; +12 → bank 0 at $8000
banksel13: .byte $0D            ; +13 → bank 1 at $8000
banksel14: .byte $0E            ; +14 → bank 2 at $8000
banksel15: .byte $0F            ; +15 → bank 3 (no-op)
```

Helpers live in the fixed bank:

```asm
changebank12rou: lda #$0C ; sta bankno ; sta banksel12 ; rts   ; selects bank0
changebank13rou: lda #$0D ; sta bankno ; sta banksel13 ; rts   ; selects bank1
```

Any inter-bank call therefore follows the pattern:

```asm
jsr changebank13rou     ; bring bank 1 into $8000
jsr b1_printrobin       ; call routine
jsr changebank12rou     ; restore bank 0
```

`bankno` (ZP `$0D`) caches the current bank number so the NMI handler can
restore it after temporarily switching to bank 1 for music playback.

---

## 2. ROM Map

Per-bank source files, entry points, and what each bank owns:

| Bank | Resident at | Role                                       | Source files (PDS)                                                                  |
|------|-------------|--------------------------------------------|-------------------------------------------------------------------------------------|
| 0    | $8000       | **Level data**                             | `MAPDATA.DAT` — 14 maps, 256 block definitions, palettes, scroll tables             |
| 1    | $8000       | **Music, title, hiscore, FX, extras**      | `MACROS.MUS`, `MUSIC1.MUS`, `JONSBIT.MUS`, `HISCORE.ROU`, `TITLE.ROU`, `SOUNDFX.ROU`, `NEWBITS.ROU`, `EXPLODE.ROU`, `PRTROBIN.ROU` |
| 2    | $8000       | **Logos, self-test, CHR sets**             | `CMLOGO.ROU`, `SMILEY.ROU`, `CHRSETS.CHR`                                           |
| 3    | $C000 (fixed) | **Game engine**                          | `TIMINGS.ROU`, `START.ROU`, `MAINLOOP.ROU`, `INTERUPT.ROU`, `CONTROL.ROU`, `XTRACONT.ROU`, `XTRAROUS.ROU`, `ONSCREEN.ROU`, `SPRITESD.DAT`, `SPRITESR.ROU`, `PRTMESS.ROU`, `UNPACK.ROU`, `GENERAL.ROU`, `MAPSCROL.ROU`, `ENDCODE.ROU` |

Bank 3 is fixed because it contains the reset vector target, the NMI
handler, and the bank-switching helpers — any of which may be called at
any time regardless of which switchable bank is currently paged in.

### Key Fixed-Bank Addresses

| Address  | Label              | Purpose |
|----------|--------------------|---------|
| `$C000`  | `bank3_header`     | 2-byte bank ID (unused by mapper; historical) |
| `$C004`  | `bank3_entry`      | `JMP pastnops` — reset vector target |
| `$C007`  | `cm_nmi_target`    | `JMP cm_nmi`   — NMI vector target |
| `$C00A`  | `bank_table`       | Bank-select value lookup |
| `$C274`  | `changebank12rou`  | Pages bank 0 into $8000 |
| `$C27C`  | `changebank13rou`  | Pages bank 1 into $8000 |
| `$ECFF`  | `printspriteposrev`| Sprite → OAM renderer |
| `$FFFA`  | NMI vector         | → $C007 |
| `$FFFC`  | Reset vector       | → $C004 |
| `$FFFE`  | IRQ/BRK vector     | (unused — IRQ disabled) |

---

## 3. Memory Map

### RAM Layout

```
$0000–$00FF   Zero page — all hot variables (scroll, player state, pointers)
$0100–$01FF   Stack + "VRAM buffer" (CPU stack grows down from $01FF,
              VRAM update queue starts at $0100 — the engine relies on
              never nesting deep enough to collide)
$0170–$01FF   blockbuffer     — deferred block writes to be flushed by NMI
$0200–$02FF   spriteblock     — shadow OAM (DMA source)
$0300–$06FF   Game state: robin, arrows, enemies, onscreen objects, score
$0700–$07FF   Partial usage; $07FE cm_flags, $07FF cm_powerup
```

### Zero-Page Variables (Highlights)

| Addr   | Name                    | Role |
|--------|-------------------------|------|
| `$00`  | `cm_frames`             | Incremented every NMI (free-running frame counter) |
| `$01–02`| `control0`/`control1`  | Shadow of `$2000`/`$2001` — NMI writes them to PPU |
| `$03`  | `interon`               | 0 = NMI does minimal work, 1 = full update |
| `$04`  | `seed`                  | RNG state |
| `$07`  | `pad`                   | Current controller bits |
| `$09–0A`| `y_scroll`/`x_scroll`  | Scroll shadow, NMI writes to `$2005` |
| `$0B`  | `flyflag`               | Signals "NMI finished" to main loop |
| `$0D`  | `bankno`                | Currently paged bank (for NMI restore) |
| `$0E`  | `spriteblockpointer`    | Next free OAM slot (sprites are appended) |
| `$0F`  | `blockpointer`          | Head of the VRAM-update queue |
| `$10`  | `counter`               | Per-frame tick (drives animation) |
| `$1B–2E`| `address` / `address1…9` | Indirect pointers (16-bit each) |
| `$2F–3A`| `tempx/y`, `temp1…9`  | Scratch |
| `$3B–3C`| `scrxl`/`scrxh`        | World-scroll position (16-bit) |
| `$3D–41`| mapstrip/attripointer/blockattri/mappointer/mapno | Map rendering state |

See [`disasm/src/bank3.s`](disasm/src/bank3.s) lines 10–187 for the full
equate block.

---

## 4. Startup & Main Loop

### Reset (`pastnops`, $C2F8)

1. Save power-up byte, show Codemasters logo (bank 2 `cm_logo`).
2. Clear RAM `$0000–$06FF`.
3. Copy hiscores from bank 1 into shadow RAM.
4. Initialise PPU control (`$90`), seed RNG, enable NMI.
5. Start title music, fall through to `anewgame`.

### Title → Game (`anewgame`, $C34D)

1. Page bank 1, run title screen, await start.
2. Read extra-lives cheat (Left + A at title = 4 lives).
3. Zero score / hearts, load map 5 (first level), `jsr gointonewmap`.
4. Enter `ingameloop`.

### In-game frame (`ingameloop`, $C393)

Each frame consists of:

```
┌─────────────────────────────────────────────────────────────────┐
│  MAIN LOOP (foreground)                                         │
│                                                                 │
│  finishedloop = 0                                               │
│  wait until NMI sets flyflag (PPU idle)                         │
│  finishedloop = 1                                               │
│                                                                 │
│  doorrou / printlives / printscore / printhearts                │
│  moveman           ← player physics                             │
│  animatelegs                                                    │
│  setxscroll        ← camera follow                              │
│  updatearrows      ← projectiles                                │
│                                                                 │
│  jsr changebank13rou                                            │
│   ├─ b1_printrobin        ← head+body+legs stacking             │
│   └─ b1_floatupnumber     ← score popups                        │
│  jsr changebank12rou                                            │
│                                                                 │
│  updatespitters    ← enemy behaviour                            │
│  every other frame:                                             │
│    updateonscreens / putextrason   ← enemies & items            │
│    jsr changebank13rou                                          │
│      └─ b1_updatehearts                                         │
│    jsr changebank12rou                                          │
│                                                                 │
│  endofmainloop  →  loop back                                    │
└─────────────────────────────────────────────────────────────────┘
```

### NMI (`cm_nmi`, $C493)

The NMI handler is the only code that talks to the PPU. It runs at
60 Hz (NTSC vblank) and handles three jobs:

```
┌──────────────────────────────────────────────────────────────┐
│  NMI                                                         │
│                                                              │
│  if cm_flags bit 7 clear:                                    │
│      cm_frames++                                             │
│      ack vblank, RTI           ← minimal NMI (early boot)    │
│                                                              │
│  else:                                                       │
│      if interon:                                             │
│          fadeupcolours  / emptyprintbuffer                   │
│          emptyblockbuffer        ← flush queued VRAM writes  │
│          $2005 ← x_scroll / y_scroll                         │
│          $2000 ← control0                                    │
│          $2001 ← control1                                    │
│          if not finishedloop:                                │
│              sendspriteblock     ← OAM DMA from $0200        │
│          dointerpause → counter++, random tick               │
│          readkeypads  → pad                                  │
│          page bank 1, jsr b1_fx_play, restore                │
│                                                              │
│      page bank 1, jsr b1_PLAY_MUSIC, restore                 │
│      flyflag = $80               ← signals main loop         │
│      RTI                                                     │
└──────────────────────────────────────────────────────────────┘
```

The `finishedloop` flag and the `flyflag` wait form a hand-shake so
sprites are only DMA'd when the main loop has finished updating them.

Music playback is **invoked from NMI** — this is why the engine runs at
a fixed 60 Hz tick regardless of how long the main loop takes.

---

## 5. Subsystems

### 5.1 Tile Compression (PP1)

Raw CHR tiles are too big; PP1 is a Codemasters-specific format that
compresses 8×8 tiles with a context-based pixel predictor and ROM
lookup tables (FC1 / FC2 / FC3 / F1L / F2H).

- **Decompressor**: `UNPACK.ROU` in bank 3 (`PP1_UNPACK` is a misnomer —
  the actual decompressor is `copyblockofcompactedchrs` at `$F1E0` and
  its helper table `compactedchrstable`).
- **Block index**: 12 blocks are listed in `compactedchrstable`; each
  entry has `(bank, offset, dest_vram, tile_count)`.
- **Flow**: main loop calls `copyblockofcompactedchrs` with a block
  index in A → the routine pages the correct bank, decompresses the
  tiles, and the NMI flushes them to CHR-RAM via the block buffer.

See [`tools/pp1tool/`](tools/pp1tool/) for a Rust codec and
[`tools/pp1web/`](tools/pp1web/) for a step-by-step visualiser.

### 5.2 Map Rendering

Maps live entirely in bank 0. Each map is stored as a 14-row × N-col
grid of **block indices**, where each block is a 2×2 tile group with
its own palette/attribute byte.

- `mapinfo` table (`$FD95` in bank 3) — 14 entries of
  `(data_ptr, offset, height, palette_idx, chr_config)`.
- `blockdefs` in bank 0 — 256 × 5 bytes (4 tiles + attribute byte).
- `MAPSCROL.ROU` scrolls the map by reading blocks ahead of the
  camera (`scrxl/scrxh`) and writing VRAM-updates into `blockbuffer`
  for the NMI to flush.

The 14 maps are vertical corridors (14 rows × varying columns).
Map 0 is the intro, 1–13 are gameplay levels. See
[`tools/mapview/`](tools/mapview/) for a renderer.

### 5.3 Sprite Rendering

Each on-screen entity is described hierarchically in `SPRITESD.DAT`
(bank 3, table at `$E8DB`, 66 × 16-bit pointers). A sprite definition
is a list of *parts*, each part is a rectangular block of 8×8 tiles
with an optional displacement, flip flags, and palette.

- Entry point: `printspriteposrev` at `$ECFF`.
- Inner tile loop: at `$ED9A`.
- Per-part loop: at `$ED28`.

**Robin Hood** is not a single sprite: he is composed every frame from
separate *head* (sprites 0–3), *body* (4–11), and *legs* (17+) sprites,
stacked vertically using the `spriteheights` table in
`PRTROBIN.ROU`. Each part is drawn independently at a Y position that
steps upward as the previous part's height is subtracted.

See [`tools/spriteview/SPRITE_FORMAT.md`](tools/spriteview/SPRITE_FORMAT.md)
for the bit-level format.

### 5.4 Physics & Control

`CONTROL.ROU` (bank 3) owns player physics:

- `moveman` — reads `pad`, applies horizontal velocity / ladder logic.
- `animatelegs` — drives `robinanim` counter for leg sprite frames.
- Gravity / jump / ladder state live in `$0317–$031A`
  (`robinjumping`, `robingravity`, `robinlook`, `robinladder`).
- Ground/wall collision consults map block attributes via
  `solidfound` at `$43`.

Enemy behaviour lives in `XTRAROUS.ROU` (arrows, spiders, bats,
cannons, barrels) and `ONSCREEN.ROU` (one-shot object lifecycles).

### 5.5 Audio

`bank 1` hosts the complete "Mega Music Driver" by Gavin Raeburn:

- `START_MUSIC` at `$8007` — begins a song given its index.
- `PLAY_MUSIC` at `$8066` — per-frame tick, called from NMI.
- `fx_setup`/`fx_play` at `$A47E`/`$A52A` — sound-effects layer
  (effects override music on pulse 1).

The engine is a 4-channel driver (pulse1/pulse2/triangle/noise) with
ADSR envelopes, vibrato, glissando, chord arpeggio, pulse-width
animation, and percussion-style triangle "thuds". It maintains its own
60 Hz tick via NMI.

See [`tools/musictool/FORMAT.md`](tools/musictool/FORMAT.md) for the
complete song binary format and [`tools/musictool/`](tools/musictool/)
for a tick-accurate Rust reimplementation.

---

## 6. Data Flow Summary

```
                 ┌──────────────────────────────┐
    ┌────────────┤        NMI (60 Hz)           ├───────────────┐
    │            └──────────────────────────────┘               │
    │                                                           │
    │  $2005 ← scroll    $2001 ← mask     emptyblockbuffer       │
    │  $4014 ← sprite DMA          b1_fx_play   b1_PLAY_MUSIC    │
    │                                                           │
    └──────┬────────────────────────────────────┬───────────────┘
           │ reads                              │ reads
           ▼                                    ▼
    ┌─────────────┐                      ┌────────────┐
    │ spriteblock │                      │ blockbuffer│
    │   $0200     │                      │   $0170    │
    └─────▲───────┘                      └─────▲──────┘
          │ written by                         │ written by
          │                                    │
    ┌─────┴──────────────────────────────────────┴──────┐
    │              MAIN LOOP (ingameloop)               │
    │                                                   │
    │   moveman / animatelegs / setxscroll              │
    │   printrobin / updatearrows / updateonscreens     │
    │   putextrason / updatehearts                      │
    │                                                   │
    │   reads from:  pad ($07), seed ($04),             │
    │                robin* ($0308…), mapno ($42)       │
    │                map data (bank 0)                  │
    │                sprite defs (bank 3, $E8DB)        │
    │                song data (bank 1)                 │
    └───────────────────────────────────────────────────┘
```

Main loop writes queues (`spriteblock`, `blockbuffer`, PPU scroll
shadow). NMI is a pure consumer — it never writes game state beyond
incrementing `counter` and reading the pad. This discipline is what
makes the engine timing-deterministic: every frame does the same work
in the same order.

---

## 7. PDS → NES Build Pipeline

The original game was written in PDS 6502 assembly on an Apricot PC
cross-development system (PDS = Programmer's Development System, Andy
Glaister, mid-1980s). The PDS assembler produced `.BC` / `.BD` / `.BE`
/ `.BF` bank files which were concatenated into a ROM.

```
    *.ROU (PDS 6502 source) ──┐
    *.MUS (music data)        ├──► PDS assembler ──► ROBINV7.BC / BD / BE / BF
    *.PP1 (compressed CHR)    │         ▲                     │
    *.CHR (raw tiles)         │         │                     │
    ROBIN.PRJ (project file) ─┘    includes bank layout       │
                                                               ▼
                                                       16KB × 4 = 64KB
                                                        NES iNES ROM
```

Our reassembly uses **cc65** (ca65 + ld65) in place of the PDS
assembler. `disasm/game.cfg` replicates the 4-bank layout and
`disasm/Makefile` produces a byte-identical output (`make verify`).

---

## 8. Where to Go Next

- [`disasm/BANK_MAP.md`](disasm/BANK_MAP.md) — per-bank PDS source mapping
- [`tools/pp1tool/`](tools/pp1tool/) — PP1 codec + format docs
- [`tools/musictool/FORMAT.md`](tools/musictool/FORMAT.md) — music binary format
- [`tools/spriteview/SPRITE_FORMAT.md`](tools/spriteview/SPRITE_FORMAT.md) — sprite format
- [TODO.md](TODO.md) — remaining work
