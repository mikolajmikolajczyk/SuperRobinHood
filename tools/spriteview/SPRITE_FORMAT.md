# Super Robin Hood — Sprite Format Reference

Complete specification of the sprite data in `SPRITESD.DAT`, as
implemented by the renderer at `$ECFF` (`printspriteposrev`) and its
inner helpers (`$ED28 eachfrminspritelp`, `$ED9A` sub-sprite block
processor).

## 1. High-Level Model

Each **sprite** is a composite drawable referenced by a single byte
index (0–65). A sprite is rendered by:

1. Looking up its definition pointer in the **sprite table** at `$E8DB`.
2. Reading a **count** byte → number of **parts**.
3. For each part, emitting one or more OAM entries representing an 8 × 8
   tile grid at a position relative to the sprite's base (X, Y).

The renderer works left-to-right, top-to-bottom for each part, and
handles horizontal / vertical flipping by reversing step direction and
shifting the origin.

Robin Hood himself is **three separate sprites** (head, body, legs)
composed every frame by `PRTROBIN.ROU` in bank 1, stacked using a
per-sprite height table. See `ARCHITECTURE.md §5.3`.

## 2. Sprite Table

```
$E8DB  spritetable  .word sprite_0, sprite_1, …, sprite_65      ; 132 bytes
```

66 × 16-bit little-endian pointers into bank 3. Entry N holds the
address of sprite-N's definition.

**Sprite index allocation** (from `SPRITESD.DAT`):

| Index | Group            | Source label          |
|-------|------------------|-----------------------|
| 0–3   | Robin heads (4 frames) | `spr_head0..3`  |
| 4–10  | Robin bodies (7 running/pose frames) | `spr_robinbody0..6` |
| 11    | (duplicate of body 6) | — |
| 12    | Robin standing   | `spr_robinstanding`   |
| 13–16 | Robin firing bow (4 draw frames) | `spr_bodyfire0..3` |
| 17–23 | Legs running (7 frames) | `spr_legsrun0..6` |
| 24    | Legs standing    | `spr_legsstanding`    |
| 25    | Legs jumping     | `spr_legsjumping`     |
| 26–29 | Body/legs variants (on-ladder, crouch) | `spr_bodyonladder`, `spr_legsonladder`, `spr_body/legsfullcrouch` |
| 30    | Legs half-crouch | `spr_legshalfcrouch`  |
| 31–33 | Barrels (3 rotation frames) | `spr_barrel0..2` |
| 34    | Cannon           | `spr_canon`           |
| 35    | Codemasters logo | `spr_codemasterlogo`  |
| 36    | Camerica logo    | `spr_camericalogo`    |
| 37    | Press-start text | `spr_pressstart`      |
| 38–41 | Dead arrow (4 distance frames) | `spr_deadarrow0..3` |
| 42    | Platform         | `spr_platform`        |
| 43–44 | Trampoline (2 frames) | `spr_trampet0..1` |
| 45–46 | Spider (2 frames)| `spr_spider0..1`      |
| 47–48 | Bat (2 frames)   | `spr_bat0..1`         |
| 49–52 | Eyes (4 frames)  | `spr_eye0..3`         |
| 53–58 | Guard (low/high fire + recoil) | `spr_guardlow/high/…` |
| 59–63 | Fire (5 frames)  | `spr_fire0..4`        |
| 64    | Marion           | `spr_marion`          |
| 65    | Pause sprite     | `spr_pausespr`        |

## 3. Sprite Definition

Each definition has the form:

```
byte 0       count       ; number of parts (1..N)
{part 1}
{part 2}
…
```

### 3.1 Part Layout

A part is a variable-length record controlled by its **flags byte**:

```
byte 0     flags               ; see §3.2
{2 bytes   (disp_x, disp_y)    ; present iff bit 5 of flags is set}
{tile-data reference           ; see §3.3}
```

### 3.2 Flags Byte

```
bit 7  vvvvvvv   V-flip  — mirrors tiles vertically AND reverses Y step
bit 6  HHHHHHH   H-flip  — mirrors tiles horizontally AND reverses X step
bit 5  DDDDDDD   has displacement — if set, 2 bytes (disp_x, disp_y) follow
bit 4  SSSSSSS   source mode
                   0 = pointer to sub-sprite block (2 bytes follow)
                   1 = inline — next byte is a single tile index
bit 3  BBBBBBB   when bit 4 = 1 (inline):  1 = 2×2 block, 0 = single tile
                 when bit 4 = 0: unused
bit 2  ­­­­­­­   reserved (written, but masked off by $C3 before OAM)
bits 1-0  PP     NES palette select (0..3)
```

The mask `AND #$C3` applied to the flags byte before it is written to
the OAM attribute byte preserves only bits 7 (V-flip), 6 (H-flip),
and 1–0 (palette) — exactly the shape of the NES OAM attribute byte,
with priority bit 5 always zero.

### 3.3 Tile-Data Reference (after flags / displacement)

#### If flags bit 4 = 0 — pointer mode

```
byte: pointer_lo    (low byte of address in bank 3)
byte: pointer_hi    (high byte)
```

At the pointed address lives a **sub-sprite block**:

```
byte 0    size
             high nibble = width  (cols, in 8×8 tiles)
             low nibble  = height (rows, in 8×8 tiles)
bytes 1+  tile IDs, row-by-row   (cols × rows bytes total)
```

The block is rendered as a `cols × rows` grid of 8 × 8 tiles, with each
tile positioned 8 pixels apart in X and Y (or -8 if flipped).

#### If flags bit 4 = 1 — inline mode

```
byte: tile_id       (index into current CHR pattern table)
```

If flags bit 3 is also set, this becomes a **2 × 2 inline block**: the
four tiles drawn are `tile_id`, `tile_id+1`, `tile_id+2`, `tile_id+3`
arranged as

```
tile_id   tile_id+1
tile_id+2 tile_id+3
```

This is the compact form used for most Robin poses and small sprites.

## 4. Rendering Algorithm (pseudo-6502)

```
printspriteposrev(A = sprite#, X = base_x, Y = base_y, C = mirror_flag):
    temp2 = X           ; base X
    temp3 = Y           ; base Y
    temp1 = C rotated into bit 7   ; whole-sprite mirror override

    ptr = spritetable[A]           ; sprite-N definition
    count = *ptr++
    repeat count times:
        flags = *ptr++
        if (temp1 bit 7 set): flags ^= 0x40    ; toggle H-flip

        attr = flags & 0xC3                    ; OAM attr byte
        y_step = (flags bit 7) ? -8 : +8       ; V-flip → walk up
        x_step = (flags bit 6) ? -8 : +8       ; H-flip → walk left

        if (flags bit 5):
            disp_x = (int8) *ptr++
            disp_y = (int8) *ptr++
        else:
            disp_x = disp_y = 0

        if (flags bit 4):                       ; inline mode
            tile_base = *ptr++
            if (flags bit 3):                   ; 2×2
                cols = rows = 2
                tiles = [tile_base, +1, +2, +3]
            else:                               ; 1×1
                cols = rows = 1
                tiles = [tile_base]
        else:                                   ; pointer mode
            block_ptr = read16(ptr); ptr += 2
            size = *block_ptr++
            cols = (size >> 4) & 0x0F
            rows = (size     ) & 0x0F
            tiles = read cols*rows bytes from block_ptr

        origin_x = base_x + disp_x + (H-flip ? cols*8 : 0)
        origin_y = base_y + (V-flip ? -disp_y : disp_y)

        for row in 0..rows-1:
            for col in 0..cols-1:
                OAM.y    = origin_y + row * y_step_direction
                OAM.tile = next tile from tiles[]
                OAM.attr = attr
                OAM.x    = origin_x + col * x_step
```

- `y_step_direction` is expressed by `toplevvar8` in the original
  code; the net effect is stepping downward through rows normally and
  upward when V-flipped.
- The code uses a zero-terminated OAM write loop — if
  `spriteblockpointer` wraps to `0`, the renderer stops (there are
  only 64 OAM slots).

## 5. Worked Examples

### 5.1 `spr_head0` at `$E9D9`

```
01  3C  FB  F1  01
```

- `01`: 1 part
- flags `$3C` = `0011 1100` →
  - no flip, has displacement, inline mode, 2×2 block, palette 0
- disp = `(-5, -15)`
- tile_base = `$01`

Renders tiles `$01, $02, $03, $04` as a 16 × 16 head image, offset
`(-5, -15)` from Robin's body position.

### 5.2 `spr_head3` (looking right)

```
01  7C  F8  F1  0D
```

- flags `$7C` = `0111 1100` → H-flip + disp + inline + 2×2
- disp = `(-8, -15)`, tile_base = `$0D`

Same structure as head0 but horizontally mirrored.

### 5.3 `spr_barrel0` — 4-part inline sprite

```
04
    31  F8 F8  A8        ; part 1: no flip, disp (-8,-8), tile $A8
    71  00 F8  A8        ; part 2: H-flip, disp (0,-8), tile $A8
    B1  F8 F8  A8        ; part 3: V-flip, disp (-8,-8), tile $A8
    F1  00 F8  A8        ; part 4: V+H flip, disp (0,-8), tile $A8
```

Four 8 × 8 copies of tile `$A8` flipped around both axes form a
16 × 16 symmetric barrel. All palette bits are 01 (green barrel
palette).

### 5.4 `spr_codemasterlogo` — pointer-mode sprite

```
07                                 ; 7 parts
    00  80 E9  20 FD 08             ; part 1: no-flip no-disp, ptr $E980, ...
```

Wait — flags `$00` has bit 5 clear (no displacement) AND bit 4 clear
(pointer mode). So after flags we read the 2-byte pointer
`$E980` (low $80, high $E9). Then the next bytes are for the **next
part** (displacement requires bit 5).

The logo is built from six 1-row strips (`spr_cm_chrdata0..5`) pointed
to from successive parts, giving a 6-row × N-col logo.

## 6. Related Code & Symbols

| Address | Label               | Purpose |
|---------|---------------------|---------|
| `$E8DB` | `spritetable`       | 66 × 16-bit pointers to definitions |
| `$ECF1` | `printspriterev`    | Entry point with mirror-override (sets C before calling posrev) |
| `$ECF4` | `printsprite`       | Entry point (clears C, then falls through) |
| `$ECFF` | `printspriteposrev` | Main renderer — this is the one most code JSRs to |
| `$ED28` | `eachfrminspritelp` | Per-part iteration loop |
| `$ED9A` | `PP1_UNPACK`        | Sub-sprite block processor (misnamed — not PP1) |
| `$EE2C` | `frmtimes8`         | Row-stride lookup table (index × 8) |

Note: `PP1_UNPACK` at `$ED9A` is a confusing legacy label — it has
**nothing to do with PP1 tile compression**. It's the "read a
cols × rows block of tiles and emit OAM entries" inner helper.
The real PP1 unpacker lives in `UNPACK.ROU`.

## 7. CHR Source

Sprite tiles come from **PPU pattern table 0** (`$0000–$0FFF` in VRAM).
The `robinchr` PP1 block (256 tiles) is decompressed into that range
on level init by `copyblockofcompactedchrs` with block index 12
(see `compactedchrstable`). Pattern table 1 (`$1000–$1FFF`) holds the
background tileset and is unrelated to sprite rendering.

## 8. Palettes

Sprite palettes live in bank 0 at `$8696` (per-map palette arrays).
The four 4-color sprite palettes used by the game are roughly:

| Idx | Colors (NES $)        | Typical user |
|-----|-----------------------|--------------|
| 0   | `0D 27 17 06`         | Robin (green/red) |
| 1   | `0D 20 2D 0C`         | White/grey (logos, bats) |
| 2   | `0D 37 15 06`         | Guards, flames |
| 3   | `0D 37 27 06`         | Misc |

(See `tools/spriteview/src/main.rs` `SPRITE_PALETTES` for the exact
values used for PNG rendering.)

## 9. Tools

- [`tools/spriteview`](.) — renders any sprite to PNG. It loads the
  ROM banks, decompresses `robinchr`, runs the real 6502 sprite
  renderer under an emulator, captures OAM, then draws.
- `spriteview render-all <bank2.bin> <bank3.bin> <outdir>` produces
  one PNG per sprite index — see `sprites/` in this directory.
