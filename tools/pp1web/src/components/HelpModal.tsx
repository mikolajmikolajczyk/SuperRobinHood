interface HelpModalProps {
  open: boolean;
  onClose: () => void;
}

/* ── shared styles ── */
const overlay: React.CSSProperties = {
  position: 'fixed', inset: 0, zIndex: 1000,
  background: 'rgba(0,0,0,0.75)', backdropFilter: 'blur(3px)',
  display: 'flex', justifyContent: 'center', alignItems: 'flex-start',
  padding: '30px 16px', overflowY: 'auto',
};
const modal: React.CSSProperties = {
  background: '#16213e', borderRadius: 12, maxWidth: 900, width: '100%',
  padding: '28px 32px', position: 'relative', border: '1px solid #333',
  boxShadow: '0 8px 40px rgba(0,0,0,0.6)', color: '#e0e0e0',
  fontFamily: "'Segoe UI', system-ui, sans-serif", fontSize: '0.95em', lineHeight: 1.7,
};
const closeBtn: React.CSSProperties = {
  position: 'absolute', top: 12, right: 16, background: 'none', border: 'none',
  color: '#999', fontSize: '1.8em', cursor: 'pointer', lineHeight: 1,
};
const h2: React.CSSProperties = { color: '#4fc3f7', margin: '28px 0 10px', fontSize: '1.25em' };
const h3: React.CSSProperties = { color: '#66bb6a', margin: '18px 0 6px', fontSize: '1.05em' };
const pre: React.CSSProperties = {
  background: '#0d0d1a', padding: 14, borderRadius: 6, overflowX: 'auto',
  fontFamily: "'JetBrains Mono','Fira Code',monospace", fontSize: '0.85em',
  lineHeight: 1.6, margin: '8px 0',
};
const note: React.CSSProperties = {
  background: 'rgba(79,195,247,0.08)', borderLeft: '3px solid #4fc3f7',
  padding: '8px 12px', borderRadius: '0 4px 4px 0', margin: '10px 0', fontSize: '0.92em',
};
const warn: React.CSSProperties = {
  background: 'rgba(255,152,0,0.08)', borderLeft: '3px solid #ff9800',
  padding: '8px 12px', borderRadius: '0 4px 4px 0', margin: '10px 0', fontSize: '0.92em',
};
const tbl: React.CSSProperties = {
  borderCollapse: 'collapse', width: '100%', margin: '8px 0',
  fontFamily: 'monospace', fontSize: '0.88em',
};
const th: React.CSSProperties = { color: '#4fc3f7', textAlign: 'left', padding: '4px 10px', borderBottom: '1px solid #444' };
const td: React.CSSProperties = { padding: '4px 10px', borderBottom: '1px solid #222' };
const acc: React.CSSProperties = { color: '#4fc3f7', fontWeight: 'bold' };
const grn: React.CSSProperties = { color: '#66bb6a' };

const HelpModal: React.FC<HelpModalProps> = ({ open, onClose }) => {
  if (!open) return null;

  return (
    <div style={overlay} onClick={onClose}>
      <div style={modal} onClick={e => e.stopPropagation()}>
        <button style={closeBtn} onClick={onClose}>&times;</button>

        <h1 style={{ color: '#4fc3f7', margin: 0, fontSize: '1.4em' }}>PP1 — The Complete Manual</h1>
        <p style={{ color: '#999' }}>Everything you need to understand this NES tile compression format, explained step by step</p>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={{...h2, marginTop: 16}}>What is PP1?</h2>

<p>
  PP1 is a way to make NES tile graphics take up less space in the game cartridge.
  The name comes from the <code>.PP1</code> file extension found in the original
  development source files. We don't know what "PP1" actually stands for.
</p>

<p>
  On the NES, each little graphic tile is 8 pixels wide and 8 pixels tall.
  Each pixel can be one of 4 colours (numbered 0, 1, 2, 3). Normally, one tile
  takes <strong>16 bytes</strong> to store. PP1 can shrink this down to as little as
  <strong>4-5 bytes</strong> per tile — saving precious cartridge space!
</p>

<div style={note}>
  <strong>Where does PP1 come from?</strong> It was found in Codemasters NES games like
  Super Robin Hood, Bee 52, and Linus Spacehead. The original development files include
  a compressor tool called <code>PP1PACK.EXE</code> and compressed data files with
  the <code>.PP1</code> extension.
</div>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={h2}>The Big Idea: Predicting Pixels</h2>

<p>
  Imagine you're describing a picture to a friend over the phone. Instead of saying
  every single pixel colour, you could say:
</p>

<ul style={{ paddingLeft: 20 }}>
  <li>"Start with colour 1"</li>
  <li>"Same colour again" (just 1 word!)</li>
  <li>"Same colour again"</li>
  <li>"Switch to colour 3"</li>
  <li>"Same colour again"</li>
</ul>

<p>
  That's exactly what PP1 does. Instead of storing the raw colour of every pixel,
  it stores <strong>what happened</strong> — did the colour stay the same, or change to
  something else? Since game tiles have lots of areas where the colour stays the same
  (think of a blue sky, or a brown wall), saying "same again" over and over is much
  shorter than repeating the colour value each time.
</p>

<p>
  The clever part: "same colour" costs just <strong>1 bit</strong> (a single 0 or 1).
  That's 16 times smaller than storing the full 2-bit colour value!
</p>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={h2}>NES Tiles: A Quick Primer</h2>

<p>
  Before we dive into PP1, let's understand what we're compressing.
</p>

<h3 style={h3}>Pixels and Colours</h3>
<p>
  Each NES tile is an 8×8 grid of pixels. Each pixel has a value from 0 to 3 —
  that's 4 possible colours. The actual colours you see on screen (red, blue, etc.)
  depend on the palette, but the tile data only stores the numbers 0-3.
</p>

<h3 style={h3}>Bitplanes — Why Two Halves?</h3>
<p>
  Here's something strange about the NES: it doesn't store pixel values directly.
  Instead, each tile is split into two <strong>bitplanes</strong>:
</p>

<ul style={{ paddingLeft: 20 }}>
  <li><strong>Bitplane 0</strong> (bytes 0-7): the "low bit" of each pixel</li>
  <li><strong>Bitplane 1</strong> (bytes 8-15): the "high bit" of each pixel</li>
</ul>

<pre style={pre}>{`To find a pixel's colour, you combine both bits:

  Bitplane 0 bit + (Bitplane 1 bit × 2) = pixel value

  bp0=0, bp1=0 → pixel 0 (often black)
  bp0=1, bp1=0 → pixel 1 (dark grey)
  bp0=0, bp1=1 → pixel 2 (light grey)
  bp0=1, bp1=1 → pixel 3 (often white)

The two bits for the SAME pixel are 8 bytes apart in memory!
Byte 0 and Byte 8 contain bits for the same row of pixels.`}</pre>

<div style={note}>
  <strong>Why so weird?</strong> The NES PPU (Picture Processing Unit) has two internal
  shift registers — one for each bitplane. By storing the planes separately, the PPU
  can load them with simple sequential reads. It's faster for the hardware, even though
  it looks confusing to humans!
</div>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={h2}>PP1 Stream Layout</h2>

<p>A PP1 compressed stream looks like this:</p>

<pre style={pre}>{`┌──────────────┬─────────────────────────────────┐
│ tile_count   │ packed bitstream...              │
│ (1 byte)     │ (variable length)               │
└──────────────┴─────────────────────────────────┘

tile_count: how many tiles are in this stream (1-256)
            Special case: the value 0 means 256 tiles!`}</pre>

<p>
  After the count byte, everything is a <strong>bitstream</strong> — data packed bit
  by bit, not aligned to byte boundaries. Bits are read from the most significant bit
  (leftmost) to the least significant (rightmost). When all 8 bits of a byte are used
  up, the next byte is loaded.
</p>

<div style={note}>
  <strong>Why does 0 mean 256?</strong> It's a trick from 6502 assembly. The decompressor
  uses <code>DEC</code> (subtract 1) then <code>BNE</code> (branch if not zero).
  When you subtract 1 from 0, it wraps around to 255, which isn't zero — so the loop
  runs 256 times. One byte, no special case needed!
</div>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={h2}>How Each Tile is Encoded</h2>

<p>For each tile, the decoder reads:</p>

<pre style={pre}>{`Step 1: Read header flag (1 bit)
        ├── bit = 1 → Reuse the previous tile's prediction table
        └── bit = 0 → Read a new prediction table (the "header")

Step 2: Decode 8 scanlines (rows of 8 pixels each)
        Rows are decoded top-to-bottom: row 0, row 1, ... row 7
        (Internally numbered line 7 down to line 0)`}</pre>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={h2}>The Prediction Table (Header)</h2>

<p>
  The prediction table is the brain of PP1. It tells the decoder:
  "For each colour value (0, 1, 2, 3), what colours can follow it?"
</p>

<p>
  Think of it like a rule book:
</p>

<ul style={{ paddingLeft: 20 }}>
  <li>Colour 0 might only ever appear next to itself → <strong>Type 0</strong></li>
  <li>Colour 1 might switch to colour 3 sometimes → <strong>Type 1</strong></li>
  <li>Colour 2 might switch to either 0 or 3 → <strong>Type 2</strong></li>
  <li>Colour 3 might switch to any other colour → <strong>Type 3</strong></li>
</ul>

<h3 style={h3}>The Four Types</h3>

<table style={tbl}>
  <thead>
    <tr><th style={th}>Type</th><th style={th}>What it means</th><th style={th}>Followers</th><th style={th}>Bits per pixel</th></tr>
  </thead>
  <tbody>
    <tr><td style={td}><strong>0</strong></td><td style={td}>This colour only ever stays the same</td><td style={td}>None</td><td style={td}><span style={grn}>0 bits (free!)</span></td></tr>
    <tr><td style={td}><strong>1</strong></td><td style={td}>Can stay the same OR switch to one specific colour</td><td style={td}>fol1</td><td style={td}>1 bit</td></tr>
    <tr><td style={td}><strong>2</strong></td><td style={td}>Can stay the same OR switch to one of two colours</td><td style={td}>fol1, fol2</td><td style={td}>1-2 bits</td></tr>
    <tr><td style={td}><strong>3</strong></td><td style={td}>Can switch to any of the other three colours</td><td style={td}>fol1, fol2, fol3</td><td style={td}>1-3 bits</td></tr>
  </tbody>
</table>

<p>
  The lower the type number, the fewer bits each pixel costs. The compressor analyses
  each tile and picks the lowest type that covers all the colour transitions in that tile.
</p>

<h3 style={h3}>Header Sharing</h3>
<p>
  The header flag at the start of each tile says whether to read a new prediction
  table or keep using the old one. If consecutive tiles have similar colour patterns,
  they can share the same header — saving 8-20 bits per tile. This is why groups of
  similar tiles (like animation frames) compress especially well together.
</p>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={h2}>Reading the Header: T1 and T3 Trees</h2>

<p>
  When a new header is needed, the decoder reads entries for pixel values 3, 2, 1, 0
  (in that order). For each one, it reads a 2-bit type, then uses special "trees" to
  decode the follower values.
</p>

<h3 style={h3}>The ROM Lookup Tables</h3>
<p>
  The follower values aren't stored directly. Instead, they're encoded using five
  small lookup tables stored in the game ROM:
</p>

<pre style={pre}>{`Table  Values         What it contains
─────  ────────────   ──────────────────────────────────
FC3    [3, 3, 3, *]   * FC3[3] "spills" into FC2[0] = 2
FC2    [2, 2, 1, *]   * FC2[3] "spills" into FC1[0] = 1
FC1    [1, 0, 0, 0]
F1L    [2, -, 0, 0]   "-" means unused (value 0xFF)
F2H    [3, 3, -, 1]   "-" means unused (value 0xFF)

Effective values for each pixel index x:
  x=0: FC1→1  FC2→2  FC3→3  (all values except 0)
  x=1: FC1→0  FC2→2  FC3→3  (all values except 1)
  x=2: FC1→0  FC2→1  FC3→3  (all values except 2)
  x=3: FC1→0  FC2→1  FC3→2  (all values except 3)`}</pre>

<div style={warn}>
  <strong>The spill trick:</strong> FC3 and FC2 are only 3 bytes each, but they're
  sometimes accessed with index 3. When that happens, the read "spills" into the
  next table in memory. FC3[3] reads the first byte of FC2, and FC2[3] reads the
  first byte of FC1. This is <em>intentional</em> — it saves 2 bytes of ROM space.
  Clever and sneaky!
</div>

<p>
  Notice: for any pixel value x, the three tables FC1, FC2, FC3 always give you the
  three values that are NOT x. You never need to encode "same colour" as a follower,
  because that's handled separately by the "repeat" bit.
</p>

<h3 style={h3}>T1 Tree: Pick One Follower</h3>
<p>
  The T1 tree reads 1-2 bits to select a value from the tables:
</p>

<pre style={pre}>{`Read a bit:
  ├── bit = 1 → use FC1[x]    (costs 1 bit — cheapest!)
  └── bit = 0 → read another bit:
       ├── bit = 1 → use FC3[x]    (costs 2 bits)
       └── bit = 0 → use FC2[x]    (costs 2 bits)`}</pre>

<p>
  The compressor puts the most useful value in FC1's position (1 bit) and the less
  useful ones in FC3/FC2 (2 bits each).
</p>

<h3 style={h3}>T3 Tree: Pick Two Followers + Get a Third</h3>
<p>
  T3 first calls T1 to get a value (which becomes fol1), then uses the ROM tables
  to automatically determine fol2, and returns a third value:
</p>

<pre style={pre}>{`v = T1(x)           ← read 1-2 bits
fol1[x] = v         ← this is the primary follower

Then based on v:
  v=0 → fol2 = FC2[x], third = FC3[x]
  v=1 → fol2 = F1L[x], third = FC3[x]
  v=2 → fol2 = FC1[x], third = F2H[x]
  v=3 → fol2 = FC1[x], third = FC2[x]`}</pre>

<h3 style={h3}>Putting it Together: Header Decode per Type</h3>
<pre style={pre}>{`Type 0: Nothing to read! No followers needed.

Type 1: fol1 = T1(x)
        (Just one follower, decoded with the T1 tree)

Type 2: Call T3(x) → sets fol1 and fol2, returns "temp"
        Then read 1 bit:
          bit=0 → keep fol2 as-is
          bit=1 → replace fol2 with temp
        (This override bit gives access to all possible pairs)

Type 3: Call T3(x) → sets fol1 and fol2, returns value
        fol3 = that returned value
        (All three followers are now set)`}</pre>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={h2}>Decoding Scanlines</h2>

<p>
  Each tile has 8 rows (scanlines). They're decoded top to bottom. For each scanline:
</p>

<pre style={pre}>{`Read the repeat flag (1 bit):
  ├── bit = 1 → REPEAT: Copy the previous scanline. Done!
  │             (Only 1 bit for an entire row of 8 pixels!)
  │
  └── bit = 0 → NEW SCANLINE: Decode 8 pixels...
                 Read seed (2 bits): the leftmost pixel's colour
                 Then predict 7 more pixels (see below)`}</pre>

<div style={note}>
  <strong>Cross-tile repeat:</strong> The "previous scanline" for the very first row
  of a tile is the <em>last row of the preceding tile</em>. This means if two tiles
  are similar at their top/bottom borders, those rows compress for free!
</div>

<p>
  A completely solid tile (all one colour, matching the previous tile's last row)
  costs just <strong>8 bits</strong> for all scanlines: 8 repeat flags of '1', with no
  pixel data at all. That's 16× compression!
</p>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={h2}>Pixel Prediction: The Heart of PP1</h2>

<p>
  After the 2-bit seed (the leftmost pixel), each of the next 7 pixels is predicted
  from the previous one. The decoder looks up the current pixel's type and reads bits
  to figure out what comes next:
</p>

<pre style={pre}>{`Type 0: No bits needed! The pixel always stays the same.
        Current pixel = 2 → next pixel = 2, automatically.

Type 1: Read 1 bit:
        ├── bit = 1 → REPEAT: stay the same colour     (1 bit)
        └── bit = 0 → CHANGE: switch to fol1[x]        (1 bit)

Type 2: Read 1 bit:
        ├── bit = 1 → REPEAT: stay the same colour     (1 bit)
        └── bit = 0 → read 1 more bit:
             ├── bit = 0 → switch to fol1[x]            (2 bits)
             └── bit = 1 → switch to fol2[x]            (2 bits)

Type 3: Read 1 bit:
        ├── bit = 1 → REPEAT: stay the same colour     (1 bit)
        └── bit = 0 → read 1 more bit:
             ├── bit = 1 → switch to fol1[x]            (2 bits)
             └── bit = 0 → read 1 more bit:
                  ├── bit = 1 → switch to fol3[x]       (3 bits)
                  └── bit = 0 → switch to fol2[x]       (3 bits)`}</pre>

<p>
  Notice the pattern: <strong>"repeat" is always cheapest</strong> (just 1 bit).
  For type 3, the primary follower (fol1) costs 2 bits, while the rarer followers
  cost 3 bits. The compressor assigns the most common transition to fol1.
</p>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={h2}>The Shift Register &amp; Sentinel Trick</h2>

<p>
  As each pixel is predicted, its two bits need to be separated into the two
  bitplanes. The decoder uses two "shift registers" for this:
</p>

<pre style={pre}>{`Start:
  shift_bp0 = seed                    (e.g. seed=2 → binary 10)
  shift_bp1 = (seed >> 1) | 0b10     (high bit of seed + sentinel)
                                      ←── the "1" at bit position 1

For each predicted pixel:
  1. Check: is bit 7 of shift_bp1 set? (save this as "overflow")
  2. shift_bp0 = (shift_bp0 << 1) | (pixel low bit)
  3. shift_bp1 = (shift_bp1 << 1) | (pixel high bit)
  4. If overflow was set → STOP (we've done 7 predictions)

After the loop:
  shift_bp0 = complete bitplane 0 byte (8 pixels packed)
  shift_bp1 = complete bitplane 1 byte (8 pixels packed)`}</pre>

<div style={note}>
  <strong>Why the sentinel?</strong> Instead of keeping a separate counter ("have I
  done 7 pixels yet?"), the decoder plants a '1' bit at position 1 of shift_bp1.
  As pixels shift in from the right, this sentinel bit moves left. After exactly 6
  shifts it reaches bit 7, and on the 7th shift it "overflows" — signalling that
  all 7 predictions are done. This saves a CPU register and a few clock cycles.
  Vintage 6502 cleverness!
</div>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={h2}>Tile Output</h2>

<p>
  The decoder writes tile data directly to the NES PPU (the graphics chip) via
  the <code>$2007</code> register. The PPU expects 16 bytes per tile:
</p>

<pre style={pre}>{`Byte  0: bitplane 0, row 0 (top)     ─┐
Byte  1: bitplane 0, row 1           │ 8 bytes of "low bits"
  ...                                 │
Byte  7: bitplane 0, row 7 (bottom) ─┘
Byte  8: bitplane 1, row 0 (top)     ─┐
Byte  9: bitplane 1, row 1           │ 8 bytes of "high bits"
  ...                                 │ 64 bits apart from bp0!
Byte 15: bitplane 1, row 7 (bottom) ─┘`}</pre>

<p>
  The decoder writes all 8 bitplane-0 bytes first (one per scanline, as each is decoded),
  then writes the 8 buffered bitplane-1 bytes afterwards. This matches the order the
  NES PPU expects.
</p>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={h2}>How the Compressor Works</h2>

<p>
  The compressor does the opposite of the decompressor, but it has to make smart
  decisions about how to encode each tile:
</p>

<h3 style={h3}>Step 1: Analyse Transitions</h3>
<p>
  Scan all 56 pixel-to-pixel transitions in the tile (7 per row × 8 rows).
  Build a 4×4 count matrix: "how many times does colour X transition to colour Y?"
</p>

<pre style={pre}>{`Example matrix for a tile:
         To: 0    1    2    3
From 0:     (28)   3    0    1     ← pixel 0 mostly stays 0
From 1:      2   (15)   0    0     ← pixel 1 mostly stays 1
From 2:      0    0   (18)   0     ← pixel 2 ONLY stays 2 → type 0!
From 3:      1    0    0    (4)    ← pixel 3 sometimes→0

(diagonal = "stays the same", handled by repeat bit)`}</pre>

<h3 style={h3}>Step 2: Choose Types</h3>
<p>
  For each pixel value, count how many <em>different</em> non-self colours it
  transitions to. That's the type:
</p>
<ul style={{ paddingLeft: 20 }}>
  <li>0 other colours → Type 0 (free!)</li>
  <li>1 other colour → Type 1 (1 bit per pixel)</li>
  <li>2 other colours → Type 2 (1-2 bits per pixel)</li>
  <li>3 other colours → Type 3 (1-3 bits per pixel)</li>
</ul>

<h3 style={h3}>Step 3: Assign Followers</h3>
<p>
  For Type 3, the most frequent non-self transition gets assigned to <strong>fol1</strong>
  (cheapest at 2 bits). fol2 and fol3 are determined automatically by the ROM tables.
</p>

<h3 style={h3}>Step 4: Check Header Sharing</h3>
<p>
  Before encoding a new header, the compressor checks: "Does the existing header
  already cover all transitions in this tile?" If yes, it writes just 1 bit (reuse=1)
  instead of 8-20 bits for a new header.
</p>

<h3 style={h3}>Step 5: Encode Scanlines</h3>
<p>
  For each row, compare it to the previous one. If identical, write '1' (repeat —
  just 1 bit for 8 pixels!). Otherwise, write '0', the 2-bit seed, and encode
  each pixel transition using the prediction table.
</p>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={h2}>Compression Ratios</h2>

<p>Measured on real Super Robin Hood tile data:</p>

<table style={tbl}>
  <thead>
    <tr><th style={th}>Block</th><th style={th}>Tiles</th><th style={th}>Raw</th><th style={th}>PP1</th><th style={th}>Ratio</th></tr>
  </thead>
  <tbody>
    <tr><td style={td}>boxchr</td><td style={td}>9</td><td style={td}>144 bytes</td><td style={td}>46 bytes</td><td style={{...td,...acc}}>31.9%</td></tr>
    <tr><td style={td}>hiscorechrs</td><td style={td}>200</td><td style={td}>3200 bytes</td><td style={td}>1402 bytes</td><td style={{...td,...acc}}>43.8%</td></tr>
    <tr><td style={td}>doorchr</td><td style={td}>73</td><td style={td}>1168 bytes</td><td style={td}>570 bytes</td><td style={{...td,...acc}}>48.8%</td></tr>
    <tr><td style={td}>robinchr</td><td style={td}>256</td><td style={td}>4096 bytes</td><td style={td}>2621 bytes</td><td style={{...td,...acc}}>64.0%</td></tr>
    <tr><td style={td}>rockchr</td><td style={td}>99</td><td style={td}>1584 bytes</td><td style={td}>1146 bytes</td><td style={{...td,...acc}}>72.3%</td></tr>
  </tbody>
</table>

<p>
  Typical range: <strong>30-75%</strong> of original size. Tiles with large solid
  areas compress best. Noisy or dithered tiles compress worst.
</p>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={h2}>Using PP1 in Your Game</h2>

<h3 style={h3}>When to Use PP1</h3>
<ul style={{ paddingLeft: 20 }}>
  <li><strong>CHR-RAM games</strong> (tiles loaded into RAM, not baked into ROM)</li>
  <li>You need to fit more tile graphics in limited ROM space</li>
  <li>Your tiles have solid regions or predictable colour patterns</li>
  <li>You can afford CPU time during loading screens</li>
</ul>

<h3 style={h3}>When NOT to Use PP1</h3>
<ul style={{ paddingLeft: 20 }}>
  <li><strong>CHR-ROM games</strong> (tiles mapped directly from cartridge — can't decompress)</li>
  <li>Tiles that update every frame (decompression is too slow)</li>
  <li>Heavily dithered tiles (may compress to MORE than the original)</li>
</ul>

<h3 style={h3}>Quick Start</h3>
<pre style={pre}>{`1. Compress your .chr file using this tool (Compress mode)
2. Download the result (.pp1 file)
3. Download the cc65 Unpacker (.s file)
4. In your ca65 project:

   .include "pp1_unpack.s"

   ; Set PPU address
   bit $2002
   lda #$00
   sta $2006
   sta $2006

   ; Point to compressed data
   lda #<mydata
   sta pp1_ptr
   lda #>mydata
   sta pp1_ptr+1

   ; Decompress!
   jsr pp1_unpack

   ; ...
   mydata: .incbin "mytiles.pp1"`}</pre>

<div style={note}>
  The decompressor needs ~29 bytes of zero page (configurable via <code>PP1_ZP</code>),
  8 bytes of RAM buffer, and ~280 bytes of code + 18 bytes of tables. It writes
  directly to <code>$2007</code>, so PPU rendering must be off.
</div>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={h2}>Why Every Byte Mattered</h2>

<p>
  To understand why someone would invent an algorithm this clever just to save
  a few kilobytes, you need to understand how expensive memory was in the late 1980s
  when these games were made.
</p>

<h3 style={h3}>The NES Hardware (1983-1995)</h3>
<p>
  The NES has just <strong>2 KB of RAM</strong> — that's 2,048 bytes. Your phone
  has about 4,000,000 times more. The CPU runs at <strong>1.79 MHz</strong> —
  about 2,000 times slower than a modern laptop.
</p>

<p>
  Game cartridges had ROM chips to store the game code and graphics. The amount of
  ROM determined how big and detailed a game could be — and ROM chips were the most
  expensive part of the cartridge.
</p>

<h3 style={h3}>What Memory Cost</h3>
<table style={tbl}>
  <thead>
    <tr><th style={th}>Year</th><th style={th}>Component</th><th style={th}>Approx. Cost</th><th style={th}>Context</th></tr>
  </thead>
  <tbody>
    <tr><td style={td}>1988</td><td style={td}>32 KB ROM chip</td><td style={td}>$2-4</td><td style={td}>The smallest useful NES cart ROM</td></tr>
    <tr><td style={td}>1988</td><td style={td}>128 KB ROM chip</td><td style={td}>$8-15</td><td style={td}>A typical Codemasters game</td></tr>
    <tr><td style={td}>1988</td><td style={td}>256 KB ROM chip</td><td style={td}>$15-30</td><td style={td}>A large NES game</td></tr>
    <tr><td style={td}>1988</td><td style={td}>8 KB CHR-RAM chip</td><td style={td}>$1-3</td><td style={td}>For decompressed tile storage</td></tr>
    <tr><td style={td}>1990</td><td style={td}>512 KB ROM</td><td style={td}>$20-40</td><td style={td}>Late-era premium cartridges</td></tr>
  </tbody>
</table>

<p>
  These costs were <em>per cartridge manufactured</em>. A popular game might sell
  hundreds of thousands of copies. Saving $2 on ROM per cartridge × 500,000 copies
  = <strong>$1,000,000 saved</strong>. That's the power of compression.
</p>

<h3 style={h3}>Codemasters: The Penny Pinchers</h3>
<p>
  Codemasters were especially creative with limited resources. As an unlicensed
  NES publisher, they couldn't use Nintendo's official cartridge hardware. They
  designed their own cartridge boards and mapper chips (the BF909x series), and
  squeezed every byte out of their ROMs.
</p>

<p>
  Super Robin Hood fits an entire platform game — code, graphics, maps, music,
  sound effects — into just <strong>128 KB</strong> of ROM. That's smaller than a
  single low-resolution JPEG photo. The tile graphics alone would take ~40 KB
  uncompressed, but PP1 squeezes them down to about ~18 KB, freeing up 22 KB for
  more levels, more music, and more gameplay.
</p>

<h3 style={h3}>For Perspective</h3>
<pre style={pre}>{`What fits in 128 KB (a whole NES game):
  • All game code and logic
  • 1,464 compressed graphic tiles (PP1)
  • 60+ room maps
  • Music and sound effects
  • Title screen, menus, score display

What 128 KB is today:
  • About 2 sentences of a Word document with formatting
  • 1/80th of a single iPhone photo
  • Less than this help page you're reading right now`}</pre>

<div style={note}>
  <strong>The bottom line:</strong> PP1 isn't just a technical curiosity — it's a
  survival tool. In a world where every byte of ROM cost real money multiplied across
  every cartridge, clever compression was the difference between a game that shipped
  and one that didn't fit. The developers who wrote these algorithms were solving a
  very real economic problem, one bit at a time.
</div>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={h2}>Limitations</h2>

<ul style={{ paddingLeft: 20 }}>
  <li><strong>Max 256 tiles</strong> per stream (count byte is 1 byte)</li>
  <li><strong>2bpp only</strong> — designed for NES CHR format</li>
  <li><strong>Sequential output</strong> — tiles decompress in order, no random access</li>
  <li><strong>No error detection</strong> — corrupted data produces garbage silently</li>
  <li><strong>CPU cost</strong> — roughly 1000-3000 cycles per tile. Fine for loading screens, too slow for per-frame updates</li>
  <li><strong>Variable ratio</strong> — worst case (random data) can be larger than raw</li>
</ul>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={h2}>Keyboard Shortcuts</h2>

<table style={tbl}>
  <tbody>
    <tr><td style={{...td, fontFamily: 'monospace'}}>← / →</td><td style={td}>Previous / Next step</td></tr>
    <tr><td style={{...td, fontFamily: 'monospace'}}>Space</td><td style={td}>Next step</td></tr>
    <tr><td style={{...td, fontFamily: 'monospace'}}>↓</td><td style={td}>Jump to next tile</td></tr>
    <tr><td style={{...td, fontFamily: 'monospace'}}>Home / End</td><td style={td}>First / Last step</td></tr>
    <tr><td style={{...td, fontFamily: 'monospace'}}>Escape</td><td style={td}>Close this help</td></tr>
  </tbody>
</table>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={h2}>Credits, Copyright &amp; Licensing</h2>

<h3 style={h3}>Who Made PP1?</h3>
<p>
  The PP1 format was used in NES games developed at and around{' '}
  <strong>Codemasters</strong>, a British video game company founded in 1986 by
  David and Richard Darling. The specific author of the PP1 algorithm is unknown —
  several programmers worked on Codemasters NES titles in the late 1980s and early
  1990s.
</p>
<p>
  The games were developed using the <strong>PDS (Programmers Development System)</strong>,
  a cross-development platform by Andy Glaister that ran on an Apricot PC and connected
  to target hardware (including the NES) via a custom interface. The original compressor
  tool (<code>PP1PACK.EXE</code>) and the 6502 decompressor routine were part of
  this development toolkit.
</p>
<p>
  The original PDS source code for Super Robin Hood was published by
  the <strong>Oliver Twins</strong> (Andrew and Philip Oliver) through{' '}
  <strong>Wireframe Magazine</strong>. The Oliver Twins were prolific Codemasters
  developers, best known for creating the Dizzy series. It is through their
  release of this source material that we know the <code>.PP1</code> file extension
  and the existence of <code>PP1PACK.EXE</code>.
</p>
<div style={note}>
  <strong>Ownership is complicated.</strong> Codemasters as a company was acquired
  by <strong>Electronic Arts (EA)</strong> in February 2021. However, the relationship
  between the Oliver Twins, Codemasters, and the rights to these old NES-era assets
  is unclear — many early Codemasters games were developed by external programmers
  (including the Oliver Twins) under various arrangements. We don't know who
  specifically holds the rights to the original PP1 code and tools today.
</div>

<h3 style={h3}>This Tool</h3>
<p>
  The PP1 format was <strong>reverse-engineered</strong> from the game ROMs — specifically
  the decompressor at address <code>$F23B</code> in the Super Robin Hood ROM (bank 3),
  with lookup tables at <code>$F381</code>. No original Codemasters source code was
  used in creating this tool.
</p>
<p>
  The compressor, decompressor, ca65 unpacker, and this interactive demo were
  written entirely from scratch based on analysis of the format. The algorithm
  itself (context-based pixel prediction with variable-length codes) is a general
  technique — not something that can be copyrighted or patented.
</p>

<h3 style={h3}>Can I Use PP1 in My Game?</h3>
<p>
  <strong>The algorithm:</strong> Yes. Algorithms and data formats are generally not
  subject to copyright. The PP1 encoding scheme is a mathematical method — you are
  free to implement it, use it, and ship commercial products that use it. Our
  reimplementation (the compressor, decompressor, and ca65 unpacker provided by this
  tool) is original code that you can use freely.
</p>
<p>
  <strong>The original Codemasters code:</strong> The original 6502 decompressor in the
  game ROM and the <code>PP1PACK.EXE</code> compressor are copyrighted works belonging
  to Codemasters / EA. You should not copy their machine code directly. Our ca65
  unpacker is a clean-room reimplementation — it produces the same results but is
  entirely original code.
</p>

<h3 style={h3}>Sample Data in This Demo</h3>
<div style={warn}>
  The tile data samples embedded in this demo (<em>boxchr</em>, <em>beadchr</em>,{' '}
  <em>okchr</em>, <em>hiscorechrs</em>) are compressed graphics extracted from{' '}
  <strong>Super Robin Hood</strong> (© Codemasters / Oliver Twins). This data is
  included here for educational and research purposes only. The tile artwork
  is copyrighted material — do not use these specific tiles in your own products.
  When you use PP1 for your own game, you'll compress your own original artwork.
</div>

<h3 style={h3}>Summary</h3>
<table style={tbl}>
  <tbody>
    <tr><td style={td}>PP1 algorithm / format</td><td style={{...td,...grn}}>Free to use (not copyrightable)</td></tr>
    <tr><td style={td}>Our compressor &amp; decompressor code</td><td style={{...td,...grn}}>Free to use (original implementation)</td></tr>
    <tr><td style={td}>Our ca65 unpacker (.s file)</td><td style={{...td,...grn}}>Free to use (clean-room reimplementation)</td></tr>
    <tr><td style={td}>Original 6502 decompressor code</td><td style={{...td, color: '#ff9800'}}>© Codemasters / Oliver Twins — do not copy</td></tr>
    <tr><td style={td}>PP1PACK.EXE (original compressor)</td><td style={{...td, color: '#ff9800'}}>© Codemasters / Oliver Twins — do not distribute</td></tr>
    <tr><td style={td}>Sample tile data in this demo</td><td style={{...td, color: '#ff9800'}}>© Codemasters / Oliver Twins — educational use only</td></tr>
  </tbody>
</table>

<div style={{ marginTop: 24, paddingTop: 16, borderTop: '1px solid #333', color: '#666', fontSize: '0.85em' }}>
  <p>
    <em>Disclaimer: This is not legal advice. If you're shipping a commercial product
    and have specific concerns, consult a lawyer. That said, using a reimplemented
    compression algorithm is well-established practice in the games industry and
    software development generally.</em>
  </p>
</div>

      </div>
    </div>
  );
};

export default HelpModal;
