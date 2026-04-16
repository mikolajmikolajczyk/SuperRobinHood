/**
 * PP1: Decompressor with step-by-step recording
 *
 * Ports the entire decompression algorithm from the Rust/6502 reference,
 * recording every operation as a Step for the educational walkthrough UI.
 * Includes detailed descriptions of the PP1 format, 6502 tricks, and
 * lookup-table mechanics.
 */

import { BitReader } from './bitstream';
import { fc1, fc2, fc3, f1l, f2h, TYPE_NAMES } from './constants';
import type { Step, Header, DecodedResult } from './types';

// ---------------------------------------------------------------------------
// Pixel / bitplane helpers (used by both decompress and compress)
// ---------------------------------------------------------------------------

/**
 * Convert a pair of NES bitplane bytes into 8 pixel values (0-3).
 * MSB = leftmost pixel.
 */
export function pixelsFromBp(bp0: number, bp1: number): number[] {
  const p: number[] = new Array(8);
  for (let c = 0; c < 8; c++) {
    const bit = 7 - c;
    p[c] = ((bp0 >> bit) & 1) | (((bp1 >> bit) & 1) << 1);
  }
  return p;
}

/**
 * Extract a single bitplane byte from an array of 8 pixel values.
 * plane=0 → low bit, plane=1 → high bit.  MSB = leftmost pixel.
 */
export function bpFromPixels(pixels: number[], plane: number): number {
  let byte = 0;
  for (let c = 0; c < 8; c++) {
    byte = (byte << 1) | ((pixels[c] >> plane) & 1);
  }
  return byte;
}

// ---------------------------------------------------------------------------
// Header tree decoders
// ---------------------------------------------------------------------------

/**
 * T1 tree: select one follower value from FC1/FC2/FC3 using 1-2 bits.
 *
 *   bit=1         → FC1[x]
 *   bit=0, bit=1  → FC3[x]
 *   bit=0, bit=0  → FC2[x]
 */
function decodeT1(br: BitReader, x: number): number {
  if (br.readBit()) return fc1(x);
  if (br.readBit()) return fc3(x);
  return fc2(x);
}

/**
 * T1 tree decode with detail string for educational display.
 * Returns [value, description].
 */
function decodeT1WithDetail(br: BitReader, x: number): [number, string] {
  const startPos = br.pos;
  if (br.readBit()) {
    const v = fc1(x);
    return [v, `T1 tree: read bit 1 → FC1[${x}] = ${v} (1 bit consumed)`];
  }
  if (br.readBit()) {
    const v = fc3(x);
    return [v, `T1 tree: read bits 01 → FC3[${x}] = ${v} (2 bits consumed)`];
  }
  const v = fc2(x);
  return [v, `T1 tree: read bits 00 → FC2[${x}] = ${v} (2 bits consumed)`];
}

/**
 * T3 tree: decode fol1 + fol2 via T1, return a value used for fol3 or fol2-override.
 *
 *   v = T1(x)  →  fol1[x] = v
 *   v=0: fol2[x] = FC2[x], return FC3[x]
 *   v=1: fol2[x] = F1L[x], return FC3[x]
 *   v=2: fol2[x] = FC1[x], return F2H[x]
 *   v=3: fol2[x] = FC1[x], return FC2[x]
 */
function decodeT3WithDetail(
  br: BitReader,
  x: number,
  fol1: number[],
  fol2: number[],
): [number, string] {
  const [v, t1Detail] = decodeT1WithDetail(br, x);
  fol1[x] = v;

  let f2val: number;
  let retVal: number;
  let desc: string;

  switch (v) {
    case 0:
      f2val = fc2(x);
      retVal = fc3(x);
      desc = `v=0 → fol2[${x}] = FC2[${x}] = ${f2val}, return FC3[${x}] = ${retVal}`;
      break;
    case 1:
      f2val = f1l(x);
      retVal = fc3(x);
      desc = `v=1 → fol2[${x}] = F1L[${x}] = ${f2val}, return FC3[${x}] = ${retVal}`;
      break;
    case 2:
      f2val = fc1(x);
      retVal = f2h(x);
      desc = `v=2 → fol2[${x}] = FC1[${x}] = ${f2val}, return F2H[${x}] = ${retVal}`;
      break;
    default: // 3
      f2val = fc1(x);
      retVal = fc2(x);
      desc = `v=3 → fol2[${x}] = FC1[${x}] = ${f2val}, return FC2[${x}] = ${retVal}`;
      break;
  }

  fol2[x] = f2val;

  return [retVal, `${t1Detail}\nT3 dispatch: fol1[${x}] = ${v}, then ${desc}`];
}

// ---------------------------------------------------------------------------
// Snapshot helpers
// ---------------------------------------------------------------------------

function cloneHeader(h: Header): Header {
  return {
    types: [...h.types],
    fol1: [...h.fol1],
    fol2: [...h.fol2],
    fol3: [...h.fol3],
  };
}

function emptyTileGrid(): number[][] {
  return Array.from({ length: 8 }, () => new Array(8).fill(-1));
}

function cloneTileGrid(g: number[][]): number[][] {
  return g.map(row => [...row]);
}

// ---------------------------------------------------------------------------
// Main decoder with step recording
// ---------------------------------------------------------------------------

/**
 * Decompress a PP1 stream, recording every operation as a Step.
 *
 * The step descriptions include educational content about the PP1 format,
 * 6502 implementation tricks, and lookup-table mechanics.
 */
export function decodeWithSteps(data: Uint8Array): DecodedResult {
  if (data.length === 0) {
    return {
      mode: 'decompress',
      steps: [],
      allTiles: [],
      allTilesChr: [],
      tileBitRanges: [],
      tileCount: 0,
      totalBits: 0,
    };
  }

  const steps: Step[] = [];
  const allTiles: number[][][] = [];
  const allTilesChr: Uint8Array[] = [];
  const tileBitRanges: { start: number; end: number }[] = [];

  // Tile count byte
  const tileCount = data[0] === 0 ? 256 : data[0];
  const br = new BitReader(data, 1);

  // Header state (persists across tiles)
  const header: Header = {
    types: [0, 0, 0, 0],
    fol1: [0, 0, 0, 0],
    fol2: [0, 0, 0, 0],
    fol3: [0, 0, 0, 0],
  };

  // Last scanline (persists across tiles for repeat-on-first-line)
  let prevBp0 = 0;
  let prevBp1 = 0;

  let currentGrid = emptyTileGrid();

  // Step 0: tile count
  steps.push({
    type: 'tile-count',
    tileIndex: -1,
    bitStart: 0,
    bitEnd: 8,
    title: `Tile count: ${tileCount}`,
    detail:
`The first byte of a PP1 stream is the tile count.

Read byte 0x${data[0].toString(16).padStart(2, '0')} = ${data[0]} → ${tileCount} tile${tileCount !== 1 ? 's' : ''} to decode.

6502 trick: the decoder uses DEC + BEQ, so a count byte of 0x00
wraps to 255 after the first decrement, giving 256 tiles total.
This lets a single byte encode 1–256.

The bitstream begins at byte 1 (bit offset 8). All subsequent
reads are MSB-first: bit 7 of each byte is consumed first, then
bit 6, etc. When all 8 bits are used, the next byte is loaded.`,
    header: cloneHeader(header),
    currentTile: cloneTileGrid(currentGrid),
    completedCount: 0,
    highlightRow: -1,
    highlightPixels: [],
    headerHighlight: -1,
  });

  for (let tileIdx = 0; tileIdx < tileCount; tileIdx++) {
    const tileStartBit = br.pos;
    currentGrid = emptyTileGrid();

    // --- Header flag ---
    const hflagStart = br.pos;
    const hflag = br.readBit();
    const hflagEnd = br.pos;

    if (hflag) {
      // Reuse previous header
      steps.push({
        type: 'header-flag',
        tileIndex: tileIdx,
        bitStart: hflagStart,
        bitEnd: hflagEnd,
        title: `Tile ${tileIdx}: reuse header (bit=1)`,
        detail:
`Header flag: read 1 bit = 1 → reuse the previous tile's header.

Multiple tiles can share the same prediction table. The 6502 decoder
simply skips header parsing when this bit is set. This saves significant
space when consecutive tiles have similar colour transition patterns
(e.g. tiles from the same sprite or background region).

Current header state is unchanged:
  types = [${header.types.join(', ')}]
  fol1  = [${header.fol1.join(', ')}]
  fol2  = [${header.fol2.join(', ')}]
  fol3  = [${header.fol3.join(', ')}]`,
        header: cloneHeader(header),
        currentTile: cloneTileGrid(currentGrid),
        completedCount: tileIdx,
        highlightRow: -1,
        highlightPixels: [],
        headerHighlight: -1,
      });
    } else {
      // New header
      steps.push({
        type: 'header-flag',
        tileIndex: tileIdx,
        bitStart: hflagStart,
        bitEnd: hflagEnd,
        title: `Tile ${tileIdx}: new header (bit=0)`,
        detail:
`Header flag: read 1 bit = 0 → decode a new prediction header.

The header defines, for each pixel value (decoded in order x=3, 2, 1, 0),
a prediction type and its follower set. The order 3→0 matches the 6502
loop which decrements X from 3 to 0.

Each entry starts with a 2-bit type code:
  00 = type 0: pixel only transitions to itself (0 bits per pixel)
  01 = type 1: 1 follower, decoded via T1 tree (1-2 bits)
  10 = type 2: 2 followers, decoded via T3 tree + 1 override bit
  11 = type 3: 3 followers, decoded via T3 tree`,
        header: cloneHeader(header),
        currentTile: cloneTileGrid(currentGrid),
        completedCount: tileIdx,
        highlightRow: -1,
        highlightPixels: [],
        headerHighlight: -1,
      });

      // Decode header for x = 3, 2, 1, 0
      for (let xi = 3; xi >= 0; xi--) {
        const typeStart = br.pos;
        const tc = br.readBits(2);
        header.types[xi] = tc;

        if (tc === 0) {
          steps.push({
            type: 'header-type',
            tileIndex: tileIdx,
            bitStart: typeStart,
            bitEnd: br.pos,
            title: `Pixel ${xi}: type 0 (constant)`,
            detail:
`Header entry for pixel value ${xi}:
Read 2-bit type code = ${tc.toString(2).padStart(2, '0')} = type 0.

${TYPE_NAMES[0]}

No follower data needed — during scanline decode, pixel ${xi} always
stays ${xi}. Zero bits consumed per prediction. This is optimal for
pixel values that never transition to a different colour within a tile.`,
            header: cloneHeader(header),
            currentTile: cloneTileGrid(currentGrid),
            completedCount: tileIdx,
            highlightRow: xi,
            highlightPixels: [],
            headerHighlight: xi,
          });
        } else if (tc === 1) {
          const folStart = br.pos;
          const [fol1Val, t1Detail] = decodeT1WithDetail(br, xi);
          header.fol1[xi] = fol1Val;

          steps.push({
            type: 'header-type',
            tileIndex: tileIdx,
            bitStart: typeStart,
            bitEnd: br.pos,
            title: `Pixel ${xi}: type 1, fol1=${fol1Val}`,
            detail:
`Header entry for pixel value ${xi}:
Read 2-bit type code = ${tc.toString(2).padStart(2, '0')} = type 1.

${TYPE_NAMES[1]}

Follower decode via T1 binary tree:
  ${t1Detail}

Result: fol1[${xi}] = ${fol1Val}

During scanline decode, when current pixel is ${xi}:
  Read 1 bit → 1 = stay ${xi}, 0 = switch to ${fol1Val}

The T1 tree is a compact 1-2 bit Huffman-like code:
  1    → FC1[x] = ${fc1(xi)}
  01   → FC3[x] = ${fc3(xi)}
  00   → FC2[x] = ${fc2(xi)}
FC1 is the single-bit option (most frequent follower gets 1 bit).`,
            header: cloneHeader(header),
            currentTile: cloneTileGrid(currentGrid),
            completedCount: tileIdx,
            highlightRow: xi,
            highlightPixels: [],
            headerHighlight: xi,
          });
        } else if (tc === 2) {
          const t3Start = br.pos;
          const [temp, t3Detail] = decodeT3WithDetail(br, xi, header.fol1, header.fol2);
          const overrideBit = br.readBit();
          if (overrideBit) {
            header.fol2[xi] = temp;
          }

          steps.push({
            type: 'header-type',
            tileIndex: tileIdx,
            bitStart: typeStart,
            bitEnd: br.pos,
            title: `Pixel ${xi}: type 2, fol1=${header.fol1[xi]}, fol2=${header.fol2[xi]}`,
            detail:
`Header entry for pixel value ${xi}:
Read 2-bit type code = ${tc.toString(2).padStart(2, '0')} = type 2.

${TYPE_NAMES[2]}

T3 tree decode (sets fol1 and fol2):
  ${t3Detail}

Override bit = ${overrideBit}${overrideBit ? ` → fol2[${xi}] overridden to ${temp} (the T3 return value)` : ` → fol2[${xi}] stays as ${header.fol2[xi]} (from T3 dispatch)`}

Result: fol1[${xi}] = ${header.fol1[xi]}, fol2[${xi}] = ${header.fol2[xi]}

During scanline decode, when current pixel is ${xi}:
  Read 1 bit → 1 = stay ${xi}
  Read 1 bit → 0 = fol1[${xi}] = ${header.fol1[xi]}, 1 = fol2[${xi}] = ${header.fol2[xi]}

The T3 tree reuses T1 to select a "class" value, then the class
determines fol2 and a return value. The override bit allows the
compressor to swap fol2 with the return value, giving more flexibility
in assigning the two followers to match the tile's actual transitions.`,
            header: cloneHeader(header),
            currentTile: cloneTileGrid(currentGrid),
            completedCount: tileIdx,
            highlightRow: xi,
            highlightPixels: [],
            headerHighlight: xi,
          });
        } else {
          // tc === 3
          const t3Start = br.pos;
          const [fol3Val, t3Detail] = decodeT3WithDetail(br, xi, header.fol1, header.fol2);
          header.fol3[xi] = fol3Val;

          steps.push({
            type: 'header-type',
            tileIndex: tileIdx,
            bitStart: typeStart,
            bitEnd: br.pos,
            title: `Pixel ${xi}: type 3, fol1=${header.fol1[xi]}, fol2=${header.fol2[xi]}, fol3=${fol3Val}`,
            detail:
`Header entry for pixel value ${xi}:
Read 2-bit type code = ${tc.toString(2).padStart(2, '0')} = type 3.

${TYPE_NAMES[3]}

T3 tree decode (sets fol1 and fol2, returns fol3):
  ${t3Detail}

Result: fol1[${xi}] = ${header.fol1[xi]}, fol2[${xi}] = ${header.fol2[xi]}, fol3[${xi}] = ${fol3Val}

During scanline decode, when current pixel is ${xi}:
  Read 1 bit → 1 = stay ${xi}
  0 then: 1 → fol1 = ${header.fol1[xi]}, 01 → fol3 = ${fol3Val}, 00 → fol2 = ${header.fol2[xi]}

Type 3 handles all 3 possible different-colour transitions.
The variable-length code assigns 2 bits to the most common
follower (fol1) and 3 bits to the less common ones (fol2, fol3).`,
            header: cloneHeader(header),
            currentTile: cloneTileGrid(currentGrid),
            completedCount: tileIdx,
            highlightRow: xi,
            highlightPixels: [],
            headerHighlight: xi,
          });
        }
      }
    }

    // --- 8 scanlines (line 7 first → line 0 last) ---
    const bp0: number[] = new Array(8).fill(0);
    const bp1: number[] = new Array(8).fill(0);

    for (let line = 7; line >= 0; line--) {
      const scanStart = br.pos;
      const repeatBit = br.readBit();

      // The row in the tile grid: line 7 is decoded first → row 0 visually (top)
      // Actually in NES CHR, line 7 = byte 0 = top of tile
      // Decode order 7→0, but output byte index = 7-line
      // For visual display: decode_line 7 → grid row 0 (top), decode_line 0 → grid row 7 (bottom)
      const gridRow = 7 - line;

      if (repeatBit) {
        // Repeat previous scanline
        let rBp0: number, rBp1: number;
        if (line === 7) {
          rBp0 = prevBp0;
          rBp1 = prevBp1;
        } else {
          rBp0 = bp0[line + 1];
          rBp1 = bp1[line + 1];
        }
        bp0[line] = rBp0;
        bp1[line] = rBp1;

        const pixels = pixelsFromBp(rBp0, rBp1);
        for (let c = 0; c < 8; c++) {
          currentGrid[gridRow][c] = pixels[c];
        }

        const srcDesc = line === 7
          ? 'previous tile\'s last scanline (state carries across tiles)'
          : `scanline ${line + 1} (just decoded above)`;

        steps.push({
          type: 'scanline-repeat',
          tileIndex: tileIdx,
          bitStart: scanStart,
          bitEnd: br.pos,
          title: `Line ${line}: repeat (bit=1)`,
          detail:
`Scanline ${line} of tile ${tileIdx}: read 1 bit = 1 → repeat.

Copy bp0/bp1 from ${srcDesc}:
  bp0 = 0x${rBp0.toString(16).padStart(2, '0')} = ${rBp0.toString(2).padStart(8, '0')}
  bp1 = 0x${rBp1.toString(16).padStart(2, '0')} = ${rBp1.toString(2).padStart(8, '0')}
  pixels = [${pixels.join(', ')}]

The repeat flag saves significant space for tiles with horizontal
bands of constant colour. The 6502 decoder keeps the previous
bp0/bp1 in a buffer that persists across tile boundaries, so even
the very first scanline of a new tile can repeat the last line of
the previous tile.`,
          header: cloneHeader(header),
          currentTile: cloneTileGrid(currentGrid),
          completedCount: tileIdx,
          highlightRow: -1,
          highlightPixels: Array.from({ length: 8 }, (_, c) => ({ r: gridRow, c })),
          headerHighlight: -1,
        });
        continue;
      }

      // New scanline: seed + 7 predicted pixels
      const seedStart = br.pos;
      const seed = br.readBits(2);
      const seedEnd = br.pos;

      // Shift registers — match the 6502's ASL/ROL approach
      let shiftBp0 = seed;
      let shiftBp1 = (seed >> 1) | 2; // sentinel bit at position 1
      let pixel = seed;

      const linePixels: number[] = [seed];
      currentGrid[gridRow][0] = seed;

      steps.push({
        type: 'scanline-seed',
        tileIndex: tileIdx,
        bitStart: scanStart,
        bitEnd: seedEnd,
        title: `Line ${line}: seed=${seed}`,
        detail:
`Scanline ${line} of tile ${tileIdx}: read 1 bit = 0 → new scanline.

Seed pixel (2 bits) = ${seed.toString(2).padStart(2, '0')} = ${seed}

The seed is the leftmost pixel of this row. It initialises two
shift registers that will accumulate the 8-pixel bitplane output:

  shift_bp0 = seed               = ${seed.toString(2).padStart(8, '0')} (low bits of pixels)
  shift_bp1 = (seed >> 1) | 0b10 = ${shiftBp1.toString(2).padStart(8, '0')} (high bits + sentinel)

6502 trick: the sentinel bit (0b10) starts at bit position 1 in
shift_bp1. After each pixel, both registers shift left. The sentinel
moves up one position per shift. After 6 shifts it reaches bit 7,
and after the 7th shift it "overflows" out — the 6502 code checks
the carry flag from ASL to detect this, terminating the loop after
exactly 7 predicted pixels (8 total including the seed).`,
        header: cloneHeader(header),
        currentTile: cloneTileGrid(currentGrid),
        completedCount: tileIdx,
        highlightRow: header.types[seed] > 0 ? seed : -1,
        highlightPixels: [{ r: gridRow, c: 0 }],
        headerHighlight: -1,
      });

      // 7 predicted pixels
      for (let pixIdx = 1; pixIdx <= 7; pixIdx++) {
        const predStart = br.pos;
        const x = pixel & 3;
        const t = header.types[x];
        let nextPixel = pixel;
        let predDetail = '';

        if (t === 0) {
          nextPixel = pixel;
          predDetail = `Type 0 (constant): pixel stays ${pixel}. Zero bits consumed.`;
        } else if (t === 1) {
          const bit = br.readBit();
          if (bit) {
            nextPixel = pixel;
            predDetail = `Type 1: read bit 1 → repeat pixel ${pixel}`;
          } else {
            nextPixel = header.fol1[x];
            predDetail = `Type 1: read bit 0 → fol1[${x}] = ${nextPixel}`;
          }
        } else if (t === 2) {
          const bit1 = br.readBit();
          if (bit1) {
            nextPixel = pixel;
            predDetail = `Type 2: read bit 1 → repeat pixel ${pixel}`;
          } else {
            const bit2 = br.readBit();
            if (bit2) {
              nextPixel = header.fol2[x];
              predDetail = `Type 2: read bits 01 → fol2[${x}] = ${nextPixel}`;
            } else {
              nextPixel = header.fol1[x];
              predDetail = `Type 2: read bits 00 → fol1[${x}] = ${nextPixel}`;
            }
          }
        } else {
          // type 3
          const bit1 = br.readBit();
          if (bit1) {
            nextPixel = pixel;
            predDetail = `Type 3: read bit 1 → repeat pixel ${pixel}`;
          } else {
            const bit2 = br.readBit();
            if (bit2) {
              nextPixel = header.fol1[x];
              predDetail = `Type 3: read bits 01 → fol1[${x}] = ${nextPixel}`;
            } else {
              const bit3 = br.readBit();
              if (bit3) {
                nextPixel = header.fol3[x];
                predDetail = `Type 3: read bits 001 → fol3[${x}] = ${nextPixel}`;
              } else {
                nextPixel = header.fol2[x];
                predDetail = `Type 3: read bits 000 → fol2[${x}] = ${nextPixel}`;
              }
            }
          }
        }

        // Shift register update (matching 6502 ASL/ROL)
        const overflow = (shiftBp1 & 0x80) !== 0;
        shiftBp0 = ((shiftBp0 << 1) | (nextPixel & 1)) & 0xff;
        shiftBp1 = ((shiftBp1 << 1) | ((nextPixel >> 1) & 1)) & 0xff;

        pixel = nextPixel;
        linePixels.push(pixel);
        currentGrid[gridRow][pixIdx] = pixel;

        steps.push({
          type: 'pixel',
          tileIndex: tileIdx,
          bitStart: predStart,
          bitEnd: br.pos,
          title: `Line ${line}, px ${pixIdx}: ${pixel} (from ${linePixels[pixIdx - 1]})`,
          detail:
`Pixel prediction ${pixIdx}/7 on scanline ${line}:
Current pixel = ${linePixels[pixIdx - 1]}, type[${x}] = ${t}

${predDetail}

Result: next pixel = ${pixel}
Shift registers after update:
  bp0 = 0x${shiftBp0.toString(16).padStart(2, '0')} = ${shiftBp0.toString(2).padStart(8, '0')}
  bp1 = 0x${shiftBp1.toString(16).padStart(2, '0')} = ${shiftBp1.toString(2).padStart(8, '0')}
  overflow = ${overflow} ${pixIdx === 7 ? '→ sentinel reached bit 7, loop terminates' : '→ continue'}

Row so far: [${linePixels.join(', ')}]`,
          header: cloneHeader(header),
          currentTile: cloneTileGrid(currentGrid),
          completedCount: tileIdx,
          highlightRow: t > 0 ? x : -1,
          highlightPixels: [{ r: gridRow, c: pixIdx }],
          headerHighlight: -1,
        });
      }

      bp0[line] = shiftBp0;
      bp1[line] = shiftBp1;
    }

    // Remember last scanline for next tile
    prevBp0 = bp0[0];
    prevBp1 = bp1[0];

    // Build CHR tile: NES order is line 7 first = byte 0 (top of tile)
    const chrTile = new Uint8Array(16);
    for (let i = 0; i < 8; i++) {
      chrTile[i] = bp0[7 - i];
      chrTile[8 + i] = bp1[7 - i];
    }
    allTilesChr.push(chrTile);

    // Build pixel grid for completed tile
    const tilePixels: number[][] = [];
    for (let row = 0; row < 8; row++) {
      tilePixels.push(pixelsFromBp(chrTile[row], chrTile[8 + row]));
    }
    allTiles.push(tilePixels);

    tileBitRanges.push({ start: tileStartBit, end: br.pos });

    // Tile completion step
    steps.push({
      type: 'tile-complete',
      tileIndex: tileIdx,
      bitStart: tileStartBit,
      bitEnd: br.pos,
      title: `Tile ${tileIdx} complete`,
      detail:
`Tile ${tileIdx} fully decoded! ${br.pos - tileStartBit} bits consumed.

CHR output (16 bytes, NES bitplane format):
  bp0: ${Array.from(chrTile.slice(0, 8)).map(b => b.toString(16).padStart(2, '0')).join(' ')}
  bp1: ${Array.from(chrTile.slice(8, 16)).map(b => b.toString(16).padStart(2, '0')).join(' ')}

Bitplanes are stored top-to-bottom: byte 0 = top row's bp0, byte 8 = top row's bp1.
The decoder wrote scanlines in order 7→0, and the NES PPU reads them 0→7,
so the output naturally matches the expected CHR RAM layout.

${tileIdx + 1} of ${tileCount} tile${tileCount !== 1 ? 's' : ''} decoded.`,
      header: cloneHeader(header),
      currentTile: cloneTileGrid(currentGrid),
      completedCount: tileIdx + 1,
      highlightRow: -1,
      highlightPixels: [],
      headerHighlight: -1,
    });
  }

  // Build output CHR data
  const outputData = new Uint8Array(allTilesChr.length * 16);
  for (let i = 0; i < allTilesChr.length; i++) {
    outputData.set(allTilesChr[i], i * 16);
  }

  return {
    mode: 'decompress',
    steps,
    allTiles,
    allTilesChr,
    tileBitRanges,
    tileCount,
    totalBits: br.pos,
    outputData,
  };
}
