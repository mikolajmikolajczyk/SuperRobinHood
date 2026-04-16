# Bank → Source File Mapping

Mapper 71 (Codemasters BF909x): 4 × 16KB PRG banks, 0 CHR-ROM (CHR-RAM).
- $8000–$BFFF: switchable (write value to any $C000–$CFFF address selects physical bank)
- $C000–$FFFF: fixed (always bank3.bin = last 16KB of PRG)

Physical bank selection: write value N → N & 3 = ROM position (0–2 switchable, 3 fixed).

---

## bank0.bin — Maps & Level Data

| | |
|---|---|
| **Mapper write** | `$0C` (via `changebank12rou`) |
| **PDS bank** | BANK12 (confirmed: MD5 match with alpha `ROBINV7.BC`) |
| **da65 range** | `$8000–$BFFF` — entire range is `ByteTable` (pure data, no code) |
| **Auto-labels** | 0 (no jump targets, pure data) |

### Source files

| File | Notes |
|------|-------|
| `MAPDATA.DAT` | Map scroll tables, block definitions, level layout data (3163 lines) |

---

## bank1.bin — Music, Title, Hiscore, Sound FX, Gameplay Extras

| | |
|---|---|
| **Mapper write** | `$0D` (via `changebank13rou`) |
| **PDS bank** | BANK13 (inferred; code matches .ROU sources listed after BANK13.PDS in PRJ) |
| **da65 range** | `$8000–$BFFF` — mixed code and data |
| **Auto-labels** | 280 remaining |

### Source files (in order, confirmed by entry-point addresses)

| File | Entry points | Address |
|------|-------------|---------|
| `MACROS.MUS` | music engine macros | `$8000` (bank header) |
| `JONSBIT.MUS` | music data | — |
| `MUSIC1.MUS` | `START_MUSIC`, `PLAY_MUSIC` | `$8007`, `$8066` |
| `HISCORE.ROU` | `trytoentername`, `copyhiscorestoram` | `$9818`, `$9C71` |
| `TITLE.ROU` | `titlescreen`, `pulsecolour` | `$9D8A`, `$A1B3` |
| `SOUNDFX.ROU` | `fx_setup`, `fx_play` | `$A47E`, `$A52A` |
| `NEWBITS.ROU` | `restupdatecoin`, `putinheartbank`, `floatupnumber`, `print6treasures`, `redefinewater` | `$A6DA`–`$AB6C` |
| `EXPLODE.ROU` | `updatehearts` | `$AD2D` |
| `PRTROBIN.ROU` | `printrobin`, `printrobin1` | `$AF95`, `$AFC5` |

---

## bank2.bin — Codemasters Logo, Self-Test, Character Sets

| | |
|---|---|
| **Mapper write** | `$0E` (direct writes in bank3.s engine code) |
| **PDS bank** | Likely BANK14 switchable portion, or a post-alpha addition (SMILEY.ROU not in ROBIN.PRJ) |
| **da65 range** | `$8000–$BFFF` — code + binary character data |
| **Auto-labels** | 144 remaining |

### Source files (in order, confirmed by entry-point addresses)

| File | Entry points | Address |
|------|-------------|---------|
| `CMLOGO.ROU` | `cm_logo` | `$8000` |
| `SMILEY.ROU` | `smiley` (added post-alpha, not in ROBIN.PRJ) | `$8906` |
| `CHRSETS.CHR` | binary character tile data | ~`$8F60` |

---

## bank3.bin — Fixed Bank: Game Engine (always at $C000–$FFFF)

| | |
|---|---|
| **Mapper write** | N/A (fixed) |
| **PDS bank** | BANK14 (fixed range, `org $C004`) |
| **da65 range** | `$C000–$FFFF` — code + data |
| **Auto-labels** | 121 remaining |

### Source files (in order, from ROBIN.PRJ + BANK14.PDS)

| File | Entry points / description | Address |
|------|--------------------------|---------|
| `TIMINGS.ROU` | `times16lo`, `times32tablelo/hi`, `waterchrs`, `times16hi`, `multstripby16` | `$C01A` |
| `START.ROU` | reset and init code | after timings tables |
| `MAINLOOP.ROU` | main game loop | — |
| `INTERUPT.ROU` | NMI handler | — |
| `CONTROL.ROU` | Robin Hood player control | — |
| `XTRACONT.ROU` | enemy/extra sprite data tables | — |
| `XTRAROUS.ROU` | enemy/extra sprite control routines | — |
| `ONSCREEN.ROU` | on-screen object management | — |
| `SPRITESD.DAT` | sprite layout data | — |
| `SPRITESR.ROU` | sprite rendering routines | — |
| `PRTMESS.ROU` | message printing routine | — |
| `UNPACK.ROU` | character unpacker | — |
| `GENERAL.ROU` | miscellaneous routines | — |
| `MAPSCROL.ROU` | map scrolling / printing | — |
| `ENDCODE.ROU` | end-of-bank marker | — |
| `JUNK` | padding / filler bytes | `$FFxx` area |

### Key bank3 labels (fixed, always available)

| Label | Address | Description |
|-------|---------|-------------|
| `bank3_header` | `$C000` | iNES-style header / bank ID bytes |
| `bank3_entry` | `$C004` | Reset vector target (`JMP pastnops`) |
| `cm_nmi_target` | `$C007` | NMI vector target |
| `bank_table` | `$C00A` | 16-entry bank number lookup |
| `changebank12rou` | `$C274` | Writes `$0C` → selects bank0 at $8000 |
| `changebank13rou` | `$C27C` | Writes `$0D` → selects bank1 at $8000 |

---

## Alpha vs Released

Only `bank0.bin` is byte-identical to the alpha output (`ROBINV7.BC`).
Banks 1–3 differ. The alpha `ROBIN.PRJ` lists music/hiscore/title files under BANK12,
and CMLOGO under BANK13 — the opposite of the released ROM layout. `SMILEY.ROU` was
written after the alpha (dated 3-10-90) and is absent from `ROBIN.PRJ`.

| File | Alpha (.BC/.BD/.BE/.BF) | Released (bank0–3.bin) |
|------|------------------------|------------------------|
| `ROBINV7.BC` (bank12) | = bank0.bin ✓ | same |
| `ROBINV7.BD` (bank13) | ≠ bank1.bin | reorganised |
| `ROBINV7.BE` (bank14) | ≠ bank2.bin | reorganised + SMILEY.ROU added |
| `ROBINV7.BF` (bank15?) | ≠ bank3.bin | reorganised |
