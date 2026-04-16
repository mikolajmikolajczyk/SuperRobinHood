//! # PP1
//!
//! A tile compression format used by Codemasters NES games, written by
//! Codemasters NES games. Compresses 8×8 2-bitplane NES CHR tiles (16 bytes each)
//! using context-based pixel prediction.
//!
//! ## Concepts
//!
//! Each pixel in a tile has a value 0–3 (2 bits, one from each bitplane).
//! Tiles tend to have long runs of the same pixel value, or predictable
//! transitions (e.g. colour 1 always followed by colour 3). PP1 exploits
//! this by encoding *which transition* occurred rather than the raw pixel
//! value.
//!
//! ## Stream layout
//!
//! ```text
//! [tile_count: u8] [bitstream...]
//! ```
//!
//! - `tile_count` = 0 means 256 (wraps via 6502 DEC/BEQ).
//! - The bitstream is read MSB-first. When all 8 bits of the current byte
//!   are consumed, the next byte is loaded automatically.
//!
//! ## Per-tile structure
//!
//! ```text
//! [header_flag: 1 bit]
//!   0 → new header follows (see below)
//!   1 → reuse the previous header
//!
//! [8 scanlines, decoded top-to-bottom (line 7 first, line 0 last)]
//! ```
//!
//! Multiple tiles can share the same header. The header persists until a
//! tile sets the flag to 0.
//!
//! ## Header (when header_flag = 0)
//!
//! The header defines, for each of the 4 pixel values (decoded in order
//! x=3, 2, 1, 0), a **type** and its **follower set**:
//!
//! ```text
//! for x in [3, 2, 1, 0]:
//!   [type: 2 bits]     — how many distinct followers pixel x has
//!   [follower data]    — depends on type (see below)
//! ```
//!
//! ### Type meanings
//!
//! - **Type 0**: pixel x only ever transitions to itself. No follower data.
//!   Zero bits consumed per pixel during scanline decode.
//!
//! - **Type 1**: pixel x has 1 follower (fol1). Decoded via T1 tree (3 bits
//!   max). During scanline decode: 1 bit — `1` = repeat self, `0` = use fol1.
//!
//! - **Type 2**: pixel x has 2 followers (fol1, fol2). Decoded via T3 tree
//!   which sets fol1 and fol2, plus an extra bit that may override fol2.
//!   During scanline decode: 1 bit repeat, then 1 bit to pick fol1 vs fol2.
//!
//! - **Type 3**: pixel x has 3 followers (fol1, fol2, fol3). Decoded via T3
//!   tree (fol1, fol2) + return value → fol3.
//!   During scanline decode: 1 bit repeat, then variable-length code:
//!   `1` → fol1, `01` → fol3, `00` → fol2.
//!
//! ### T1 tree — decode one follower value
//!
//! A binary tree selecting from three lookup tables indexed by x:
//!
//! ```text
//! bit=1         → FC1[x]
//! bit=0, bit=1  → FC3[x]
//! bit=0, bit=0  → FC2[x]
//! ```
//!
//! ### T3 tree — decode two followers + return a third
//!
//! Calls T1 to get a "class" value v, then sets fol1, fol2 and returns
//! a value based on v:
//!
//! ```text
//! v = T1(x)
//! fol1[x] = v
//!
//! v=0: fol2[x] = FC2[x], return FC3[x]
//! v=1: fol2[x] = F1L[x], return FC3[x]
//! v=2: fol2[x] = FC1[x], return F2H[x]
//! v=3: fol2[x] = FC1[x], return FC2[x]
//! ```
//!
//! ### Header decode for each type
//!
//! - **Type 1**: `fol1[x] = T1(x)`
//! - **Type 2**: `temp = T3(x)` (sets fol1, fol2); then 1 bit: if 1,
//!   overwrite `fol2[x] = temp`
//! - **Type 3**: `fol3[x] = T3(x)` (sets fol1, fol2)
//!
//! ## Lookup tables
//!
//! Stored contiguously in ROM. Each is only 3–4 bytes but indexed with
//! x=0..3 — out-of-bounds reads spill into the next table. This is
//! intentional; the compressor relies on the exact overlap pattern.
//!
//! ```text
//! Address  Table   Values          Notes
//! $F381    FC3     03 03 03        3 bytes; FC3[3] reads FC2[0] = 02
//! $F384    FC2     02 02 01        3 bytes; FC2[3] reads FC1[0] = 01
//! $F387    FC1     01 00 00 00     4 bytes
//! $F38B    F1L     02 FF 00 00     4 bytes
//! $F38F    F2H     03 03 FF 01     4 bytes
//!
//! Aliases:
//!   F0L = FC2        F0H = FC3
//!   F1H = FC3        F2L = FC1
//!   F3L = FC1        F3H = FC2
//! ```
//!
//! ## Scanline decode
//!
//! Each scanline produces two bytes: bp0 (bitplane 0) and bp1 (bitplane 1).
//!
//! ```text
//! [repeat_flag: 1 bit]
//!   1 → reuse previous scanline's bp0/bp1 values
//!       (on the very first scanline of a tile, "previous" means the
//!        last scanline of the preceding tile — state carries over)
//!   0 → decode new scanline:
//!
//! [seed: 2 bits]  — initial pixel value (0–3)
//!
//! The seed pixel goes into shift registers:
//!   shift_bp0 = seed
//!   shift_bp1 = (seed >> 1) | 2    ← bit 1 is a sentinel
//!
//! Then 7 iterations of pixel prediction, shifting bits in:
//!   loop:
//!     next_pixel = predict(current_pixel, ...)
//!     current_pixel = next_pixel
//!     overflow = shift_bp1 bit 7
//!     shift_bp0 = (shift_bp0 << 1) | (next_pixel & 1)
//!     shift_bp1 = (shift_bp1 << 1) | (next_pixel >> 1)
//!     if overflow: break
//!
//! The sentinel bit (originally at position 1 in shift_bp1) reaches
//! bit 7 after 6 shifts, then exits as "overflow" on the 7th shift.
//! This terminates the loop after exactly 7 iterations.
//!
//! Result: 8 pixels total (1 seed + 7 predicted) packed into shift_bp0
//! and shift_bp1, MSB = leftmost pixel.
//! ```
//!
//! ## Pixel prediction (within a scanline)
//!
//! Given the current pixel value x:
//!
//! ```text
//! type[x] = 0:  no bits read, pixel stays x
//! type[x] = 1:  [1 bit] 1→x (repeat), 0→fol1[x]
//! type[x] = 2:  [1 bit] 1→x (repeat), 0→[1 bit] 1→fol2[x], 0→fol1[x]
//! type[x] = 3:  [1 bit] 1→x (repeat), 0→[1 bit] 1→fol1[x],
//!                                               0→[1 bit] 1→fol3[x],
//!                                                         0→fol2[x]
//! ```
//!
//! ## Tile output order
//!
//! Scanlines are decoded 7→0 (top to bottom on screen). Each scanline's
//! bp0 byte is written to VRAM immediately. The bp1 bytes are buffered
//! and written after all 8 bp0 bytes. So the VRAM output order is:
//!
//! ```text
//! bp0[7], bp0[6], ..., bp0[0], bp1[7], bp1[6], ..., bp1[0]
//! ```
//!
//! This matches the NES CHR RAM layout: 8 bytes of bitplane 0 followed
//! by 8 bytes of bitplane 1, top line first.

// -----------------------------------------------------------------------
// Bitstream reader
// -----------------------------------------------------------------------

struct BitReader<'a> {
    data: &'a [u8],
    pos: usize,
    buf: u8,
    bits_left: u8,
}

impl<'a> BitReader<'a> {
    fn new(data: &'a [u8], start: usize) -> Self {
        Self { data, pos: start, buf: 0, bits_left: 0 }
    }

    fn read_bit(&mut self) -> bool {
        if self.bits_left == 0 {
            self.buf = self.data.get(self.pos).copied().unwrap_or(0);
            self.pos += 1;
            self.bits_left = 8;
        }
        let bit = self.buf & 0x80 != 0;
        self.buf <<= 1;
        self.bits_left -= 1;
        bit
    }

    fn read_bits(&mut self, n: u8) -> u8 {
        let mut val = 0u8;
        for _ in 0..n {
            val = (val << 1) | u8::from(self.read_bit());
        }
        val
    }
}

// -----------------------------------------------------------------------
// Lookup tables (packed as in ROM — see module docs)
// -----------------------------------------------------------------------

const ROM: [u8; 18] = [
    0x03, 0x03, 0x03,             // FC3
    0x02, 0x02, 0x01,             // FC2
    0x01, 0x00, 0x00, 0x00,       // FC1
    0x02, 0xFF, 0x00, 0x00,       // F1L
    0x03, 0x03, 0xFF, 0x01,       // F2H
];

fn fc3(x: usize) -> u8 { ROM[x] }
fn fc2(x: usize) -> u8 { ROM[3 + x] }
fn fc1(x: usize) -> u8 { ROM[6 + x] }
fn f1l(x: usize) -> u8 { ROM[10 + x] }
fn f2h(x: usize) -> u8 { ROM[14 + x] }

// -----------------------------------------------------------------------
// Header tree decoders
// -----------------------------------------------------------------------

/// T1: select one value from FC1/FC2/FC3 via a 1–2 bit binary tree.
fn decode_t1(br: &mut BitReader, x: usize) -> u8 {
    if br.read_bit() { fc1(x) }
    else if br.read_bit() { fc3(x) }
    else { fc2(x) }
}

/// T3: decode fol1 and fol2 via T1, return a value for the caller.
fn decode_t3(
    br: &mut BitReader, x: usize,
    fol1: &mut [u8; 4], fol2: &mut [u8; 4],
) -> u8 {
    let v = decode_t1(br, x);
    fol1[x] = v;
    match v {
        0 => { fol2[x] = fc2(x); fc3(x) }
        1 => { fol2[x] = f1l(x); fc3(x) }
        2 => { fol2[x] = fc1(x); f2h(x) }
        _ => { fol2[x] = fc1(x); fc2(x) }
    }
}

// -----------------------------------------------------------------------
// Pixel prediction
// -----------------------------------------------------------------------

fn predict_pixel(
    br: &mut BitReader, cur: u8,
    types: &[u8; 4], fol1: &[u8; 4], fol2: &[u8; 4], fol3: &[u8; 4],
) -> u8 {
    let x = (cur & 3) as usize;

    if types[x] == 0 {
        return cur;
    }

    if br.read_bit() {
        return cur; // repeat
    }

    match types[x] {
        1 => fol1[x],
        2 => if br.read_bit() { fol2[x] } else { fol1[x] },
        3 => {
            if br.read_bit() { fol1[x] }
            else if br.read_bit() { fol3[x] }
            else { fol2[x] }
        }
        _ => cur,
    }
}

// -----------------------------------------------------------------------
// Decompressor
// -----------------------------------------------------------------------

pub fn decompress(data: &[u8]) -> Vec<[u8; 16]> {
    if data.is_empty() {
        return vec![];
    }

    let num_tiles = if data[0] == 0 { 256 } else { data[0] as usize };
    let mut br = BitReader::new(data, 1);
    let mut tiles = Vec::with_capacity(num_tiles);

    // Header state (persists across tiles until replaced)
    let mut types = [0u8; 4];
    let mut fol1 = [0u8; 4];
    let mut fol2 = [0u8; 4];
    let mut fol3 = [0u8; 4];

    // Last decoded scanline (persists across tiles for repeat-on-first-line)
    let mut prev_bp0: u8 = 0;
    let mut prev_bp1: u8 = 0;

    for _ in 0..num_tiles {
        // --- Header ---
        if !br.read_bit() {
            for x in (0..4).rev() {
                let tc = br.read_bits(2);
                types[x] = tc;
                match tc {
                    0 => {}
                    1 => { fol1[x] = decode_t1(&mut br, x); }
                    2 => {
                        let temp = decode_t3(&mut br, x, &mut fol1, &mut fol2);
                        if br.read_bit() { fol2[x] = temp; }
                    }
                    3 => {
                        fol3[x] = decode_t3(&mut br, x, &mut fol1, &mut fol2);
                    }
                    _ => unreachable!(),
                }
            }
        }

        // --- 8 scanlines (line 7 first, line 0 last) ---
        let mut bp0 = [0u8; 8];
        let mut bp1 = [0u8; 8];

        for line in (0..8).rev() {
            if br.read_bit() {
                // Repeat previous scanline
                let (prev0, prev1) = if line == 7 {
                    (prev_bp0, prev_bp1)
                } else {
                    (bp0[line + 1], bp1[line + 1])
                };
                bp0[line] = prev0;
                bp1[line] = prev1;
                continue;
            }

            // Seed pixel (2 bits)
            let seed = br.read_bits(2);
            let mut shift_bp0 = seed;
            let mut shift_bp1 = (seed >> 1) | 2; // sentinel at bit 1
            let mut pixel = seed;

            // 7 predicted pixels
            loop {
                pixel = predict_pixel(
                    &mut br, pixel, &types, &fol1, &fol2, &fol3,
                );

                let overflow = shift_bp1 & 0x80 != 0;
                shift_bp0 = (shift_bp0 << 1) | (pixel & 1);
                shift_bp1 = (shift_bp1 << 1) | ((pixel >> 1) & 1);

                if overflow { break; }
            }

            bp0[line] = shift_bp0;
            bp1[line] = shift_bp1;
        }

        // Remember last scanline for next tile's repeat
        prev_bp0 = bp0[0];
        prev_bp1 = bp1[0];

        // Output tile in NES CHR order (line 7 first = byte 0)
        let mut tile = [0u8; 16];
        for i in 0..8 {
            tile[i] = bp0[7 - i];
            tile[8 + i] = bp1[7 - i];
        }
        tiles.push(tile);
    }

    tiles
}

// -----------------------------------------------------------------------
// Bit writer
// -----------------------------------------------------------------------

struct BitWriter {
    bytes: Vec<u8>,
    buf: u8,
    bits_used: u8,
}

impl BitWriter {
    fn new() -> Self {
        Self { bytes: Vec::new(), buf: 0, bits_used: 0 }
    }

    fn write_bit(&mut self, bit: bool) {
        self.buf = (self.buf << 1) | u8::from(bit);
        self.bits_used += 1;
        if self.bits_used == 8 {
            self.bytes.push(self.buf);
            self.buf = 0;
            self.bits_used = 0;
        }
    }

    fn write_bits(&mut self, val: u8, n: u8) {
        for i in (0..n).rev() {
            self.write_bit((val >> i) & 1 != 0);
        }
    }

    fn finish(mut self) -> Vec<u8> {
        if self.bits_used > 0 {
            self.buf <<= 8 - self.bits_used;
            self.bytes.push(self.buf);
        }
        self.bytes
    }
}

// -----------------------------------------------------------------------
// Compressor internals
// -----------------------------------------------------------------------

struct Header {
    types: [u8; 4],
    fol1: [u8; 4],
    fol2: [u8; 4],
    fol3: [u8; 4],
}

/// Get (bp0, bp1) for a decode-order line number (7 = first decoded = top).
fn get_scanline_bp(tile: &[u8; 16], decode_line: usize) -> (u8, u8) {
    let idx = 7 - decode_line;
    (tile[idx], tile[8 + idx])
}

/// Extract 8 pixels (left-to-right) from a bitplane pair.
fn pixels_from_bp(bp0: u8, bp1: u8) -> [u8; 8] {
    let mut p = [0u8; 8];
    for c in 0..8 {
        let bit = 7 - c;
        p[c] = ((bp0 >> bit) & 1) | (((bp1 >> bit) & 1) << 1);
    }
    p
}

/// Count pixel transitions in a tile: result[from][to] = count.
fn tile_transitions(tile: &[u8; 16]) -> [[u32; 4]; 4] {
    let mut trans = [[0u32; 4]; 4];
    for line in 0..8 {
        let (bp0, bp1) = get_scanline_bp(tile, line);
        let pixels = pixels_from_bp(bp0, bp1);
        for k in 0..7 {
            trans[pixels[k] as usize][pixels[k + 1] as usize] += 1;
        }
    }
    trans
}

/// Compute (fol2, fol3) that T3 produces for a given v = fol1 at position x.
fn t3_followers(x: usize, v: u8) -> (u8, u8) {
    match v {
        0 => (fc2(x), fc3(x)),
        1 => (f1l(x), fc3(x)),
        2 => (fc1(x), f2h(x)),
        _ => (fc1(x), fc2(x)),
    }
}

/// Build an optimal header from accumulated transition counts.
fn build_header(trans: &[[u32; 4]; 4]) -> Header {
    let mut header = Header {
        types: [0; 4], fol1: [0; 4], fol2: [0; 4], fol3: [0; 4],
    };

    for x in 0..4 {
        let mut followers: Vec<(u8, u32)> = (0..4)
            .filter(|&y| y != x && trans[x][y] > 0)
            .map(|y| (y as u8, trans[x][y]))
            .collect();
        followers.sort_by(|a, b| b.1.cmp(&a.1));

        header.types[x] = followers.len() as u8;
        match followers.len() {
            0 => {}
            1 => {
                header.fol1[x] = followers[0].0;
            }
            2 => {
                header.fol1[x] = followers[0].0;
                header.fol2[x] = followers[1].0;
            }
            3 => {
                // fol1 is cheapest (2 bits); fol2/fol3 (3 bits) determined by tables
                header.fol1[x] = followers[0].0;
                let (f2, f3) = t3_followers(x, followers[0].0);
                header.fol2[x] = f2;
                header.fol3[x] = f3;
            }
            _ => unreachable!(),
        }
    }
    header
}

/// Check whether all transitions in a tile are representable by the header.
fn header_covers(header: &Header, tile: &[u8; 16]) -> bool {
    for line in 0..8 {
        let (bp0, bp1) = get_scanline_bp(tile, line);
        let pixels = pixels_from_bp(bp0, bp1);
        for k in 0..7 {
            let from = pixels[k] as usize;
            let to = pixels[k + 1];
            if to == pixels[k] { continue; }
            let ok = match header.types[from] {
                0 => false,
                1 => to == header.fol1[from],
                2 => to == header.fol1[from] || to == header.fol2[from],
                3 => to == header.fol1[from] || to == header.fol2[from]
                    || to == header.fol3[from],
                _ => unreachable!(),
            };
            if !ok { return false; }
        }
    }
    true
}

/// Encode a value through the T1 tree (1–2 bits).
fn encode_t1(bw: &mut BitWriter, x: usize, v: u8) {
    if v == fc1(x) {
        bw.write_bit(true);
    } else if v == fc3(x) {
        bw.write_bit(false);
        bw.write_bit(true);
    } else {
        debug_assert_eq!(v, fc2(x));
        bw.write_bit(false);
        bw.write_bit(false);
    }
}

/// Encode the header into the bitstream.
fn encode_header_bits(bw: &mut BitWriter, header: &Header) {
    for x in (0..4).rev() {
        bw.write_bits(header.types[x], 2);
        match header.types[x] {
            0 => {}
            1 => encode_t1(bw, x, header.fol1[x]),
            2 => {
                // T3: encode fol1 via T1, then 1 bit for fol2 override
                encode_t1(bw, x, header.fol1[x]);
                let (fol2_tab, temp) = t3_followers(x, header.fol1[x]);
                if header.fol2[x] == fol2_tab {
                    bw.write_bit(false);
                } else {
                    debug_assert_eq!(header.fol2[x], temp);
                    bw.write_bit(true);
                }
            }
            3 => {
                // T3: encode fol1 via T1; fol2/fol3 determined by tables
                encode_t1(bw, x, header.fol1[x]);
            }
            _ => unreachable!(),
        }
    }
}

/// Encode a single pixel transition.
fn encode_pixel_transition(
    bw: &mut BitWriter, cur: u8, next: u8, header: &Header,
) {
    let x = cur as usize;
    if header.types[x] == 0 {
        debug_assert_eq!(cur, next);
        return;
    }
    if next == cur {
        bw.write_bit(true); // repeat self
        return;
    }
    bw.write_bit(false); // not repeat
    match header.types[x] {
        1 => {
            debug_assert_eq!(next, header.fol1[x]);
            // no additional bits
        }
        2 => {
            if next == header.fol1[x] {
                bw.write_bit(false);
            } else {
                debug_assert_eq!(next, header.fol2[x]);
                bw.write_bit(true);
            }
        }
        3 => {
            if next == header.fol1[x] {
                bw.write_bit(true);
            } else if next == header.fol3[x] {
                bw.write_bit(false);
                bw.write_bit(true);
            } else {
                debug_assert_eq!(next, header.fol2[x]);
                bw.write_bit(false);
                bw.write_bit(false);
            }
        }
        _ => unreachable!(),
    }
}

// -----------------------------------------------------------------------
// Compressor
// -----------------------------------------------------------------------

pub fn compress(tiles: &[[u8; 16]]) -> Vec<u8> {
    if tiles.is_empty() {
        return vec![];
    }
    assert!(tiles.len() <= 256);

    let count_byte = if tiles.len() == 256 { 0u8 } else { tiles.len() as u8 };
    let mut bw = BitWriter::new();

    let mut header = Header {
        types: [0; 4], fol1: [0; 4], fol2: [0; 4], fol3: [0; 4],
    };
    let mut header_valid = false;
    let mut prev_bp0: u8 = 0;
    let mut prev_bp1: u8 = 0;

    for tile in tiles {
        // Header decision: reuse or emit new
        if header_valid && header_covers(&header, tile) {
            bw.write_bit(true); // reuse
        } else {
            let trans = tile_transitions(tile);
            header = build_header(&trans);
            header_valid = true;
            bw.write_bit(false); // new header
            encode_header_bits(&mut bw, &header);
        }

        // Encode 8 scanlines in decode order: line 7, 6, …, 0
        for line in (0..8).rev() {
            let (bp0, bp1) = get_scanline_bp(tile, line);

            let (prev0, prev1) = if line == 7 {
                (prev_bp0, prev_bp1)
            } else {
                get_scanline_bp(tile, line + 1)
            };

            if bp0 == prev0 && bp1 == prev1 {
                bw.write_bit(true); // repeat scanline
            } else {
                bw.write_bit(false); // new scanline
                let pixels = pixels_from_bp(bp0, bp1);
                bw.write_bits(pixels[0], 2); // seed
                for k in 0..7 {
                    encode_pixel_transition(
                        &mut bw, pixels[k], pixels[k + 1], &header,
                    );
                }
            }
        }

        // Track last decoded scanline (line 0) for next tile
        prev_bp0 = tile[7];   // bp0 of decode line 0 = tile[7]
        prev_bp1 = tile[15];  // bp1 of decode line 0 = tile[15]
    }

    let mut result = vec![count_byte];
    result.extend(bw.finish());
    result
}

// -----------------------------------------------------------------------
// Utility
// -----------------------------------------------------------------------

/// Render tiles into a 2-bit pixel grid, 16 tiles per row.
pub fn tiles_to_pixels(tiles: &[[u8; 16]]) -> (usize, usize, Vec<u8>) {
    let cols = 16;
    let rows = (tiles.len() + cols - 1) / cols;
    let w = cols * 8;
    let h = rows * 8;
    let mut px = vec![0u8; w * h];
    for (i, tile) in tiles.iter().enumerate() {
        let tx = (i % cols) * 8;
        let ty = (i / cols) * 8;
        for r in 0..8 {
            let b0 = tile[r];
            let b1 = tile[r + 8];
            for c in 0..8 {
                let bit = 7 - c;
                let v = ((b0 >> bit) & 1) | (((b1 >> bit) & 1) << 1);
                px[(ty + r) * w + tx + c] = v;
            }
        }
    }
    (w, h, px)
}
