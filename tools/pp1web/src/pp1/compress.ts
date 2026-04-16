/**
 * PP1: Compressor with step-by-step recording
 *
 * Ports the entire compression algorithm from the Rust reference,
 * recording every operation as a Step for the educational walkthrough UI.
 */

import { BitWriter } from './bitstream';
import { fc1, fc2, fc3, f1l, f2h, TYPE_NAMES } from './constants';
import { pixelsFromBp } from './decompress';
import type { Step, Header, DecodedResult } from './types';

// ---------------------------------------------------------------------------
// Analysis helpers
// ---------------------------------------------------------------------------

/**
 * Convert a 16-byte NES CHR tile into 8 rows of 8 pixel values (0-3).
 * Returns the rows in NES order (row 0 = top of tile).
 */
export function tilePixelsFromChr(chr: Uint8Array): number[][] {
  const rows: number[][] = [];
  for (let r = 0; r < 8; r++) {
    rows.push(pixelsFromBp(chr[r], chr[8 + r]));
  }
  return rows;
}

/**
 * Count pixel transitions in a CHR tile.
 * Returns trans[from][to] = count of from→to transitions.
 * Scanlines are processed in decode order (line 7 first = top row).
 */
export function tileTransitionsFromChr(chr: Uint8Array): number[][] {
  const trans = Array.from({ length: 4 }, () => new Array(4).fill(0));
  for (let decodeLine = 7; decodeLine >= 0; decodeLine--) {
    const idx = 7 - decodeLine;
    const bp0 = chr[idx];
    const bp1 = chr[8 + idx];
    const pixels = pixelsFromBp(bp0, bp1);
    for (let k = 0; k < 7; k++) {
      trans[pixels[k]][pixels[k + 1]]++;
    }
  }
  return trans;
}

/**
 * Given fol1 value v at position x, compute the (fol2, fol3) values
 * that the T3 tree dispatch would produce.
 */
export function t3Followers(x: number, v: number): [number, number] {
  switch (v) {
    case 0: return [fc2(x), fc3(x)];
    case 1: return [f1l(x), fc3(x)];
    case 2: return [fc1(x), f2h(x)];
    default: return [fc1(x), fc2(x)]; // v=3
  }
}

/**
 * Build an optimal prediction header from accumulated transition counts.
 * Followers are ordered by frequency (most common = fol1, cheapest to encode).
 */
export function buildHeaderFromTrans(trans: number[][]): Header {
  const header: Header = {
    types: [0, 0, 0, 0],
    fol1: [0, 0, 0, 0],
    fol2: [0, 0, 0, 0],
    fol3: [0, 0, 0, 0],
  };

  for (let x = 0; x < 4; x++) {
    // Collect followers (y != x with count > 0), sorted by frequency descending
    const followers: [number, number][] = [];
    for (let y = 0; y < 4; y++) {
      if (y !== x && trans[x][y] > 0) {
        followers.push([y, trans[x][y]]);
      }
    }
    followers.sort((a, b) => b[1] - a[1]);

    header.types[x] = followers.length;
    if (followers.length >= 1) {
      header.fol1[x] = followers[0][0];
    }
    if (followers.length >= 2) {
      header.fol2[x] = followers[1][0];
    }
    if (followers.length === 3) {
      // fol1 is already set; fol2/fol3 come from T3 dispatch
      const [f2, f3] = t3Followers(x, followers[0][0]);
      header.fol2[x] = f2;
      header.fol3[x] = f3;
    }
  }

  return header;
}

/**
 * Check whether all pixel transitions in a CHR tile are representable
 * by the given header. Returns true if the header "covers" the tile.
 */
export function headerCoversChr(header: Header, chr: Uint8Array): boolean {
  for (let decodeLine = 7; decodeLine >= 0; decodeLine--) {
    const idx = 7 - decodeLine;
    const bp0 = chr[idx];
    const bp1 = chr[8 + idx];
    const pixels = pixelsFromBp(bp0, bp1);
    for (let k = 0; k < 7; k++) {
      const from = pixels[k];
      const to = pixels[k + 1];
      if (to === from) continue;
      const t = header.types[from];
      let ok = false;
      switch (t) {
        case 0: ok = false; break;
        case 1: ok = (to === header.fol1[from]); break;
        case 2: ok = (to === header.fol1[from] || to === header.fol2[from]); break;
        case 3: ok = (to === header.fol1[from] || to === header.fol2[from] || to === header.fol3[from]); break;
      }
      if (!ok) return false;
    }
  }
  return true;
}

// ---------------------------------------------------------------------------
// Bit-level encoding helpers
// ---------------------------------------------------------------------------

/**
 * Encode a value through the T1 tree (1-2 bits).
 * Returns the number of bits written.
 */
export function encT1(bw: BitWriter, x: number, v: number): number {
  if (v === fc1(x)) {
    bw.writeBit(1);
    return 1;
  } else if (v === fc3(x)) {
    bw.writeBit(0);
    bw.writeBit(1);
    return 2;
  } else {
    // v === fc2(x)
    bw.writeBit(0);
    bw.writeBit(0);
    return 2;
  }
}

/**
 * Describe what the T1 tree encoding will produce for value v at position x.
 */
export function encT1Desc(x: number, v: number): string {
  if (v === fc1(x)) return `T1: ${v} = FC1[${x}] → write bit 1 (1 bit)`;
  if (v === fc3(x)) return `T1: ${v} = FC3[${x}] → write bits 01 (2 bits)`;
  return `T1: ${v} = FC2[${x}] → write bits 00 (2 bits)`;
}

/**
 * Encode a complete header entry for pixel x into the bitstream.
 * Returns a description string.
 */
export function encHeaderEntry(bw: BitWriter, header: Header, x: number): string {
  const t = header.types[x];
  bw.writeBits(t, 2);
  let desc = `type = ${t.toString(2).padStart(2, '0')} (type ${t})`;

  if (t === 0) {
    desc += '\n  No follower data needed.';
  } else if (t === 1) {
    desc += `\n  Encode fol1[${x}] = ${header.fol1[x]} via T1 tree:`;
    desc += `\n  ${encT1Desc(x, header.fol1[x])}`;
    encT1(bw, x, header.fol1[x]);
  } else if (t === 2) {
    desc += `\n  Encode fol1[${x}] = ${header.fol1[x]} via T1 tree (inside T3):`;
    desc += `\n  ${encT1Desc(x, header.fol1[x])}`;
    encT1(bw, x, header.fol1[x]);
    const [fol2Tab, temp] = t3Followers(x, header.fol1[x]);
    if (header.fol2[x] === fol2Tab) {
      bw.writeBit(0);
      desc += `\n  Override bit = 0 → fol2[${x}] = ${fol2Tab} (from T3 dispatch)`;
    } else {
      bw.writeBit(1);
      desc += `\n  Override bit = 1 → fol2[${x}] = ${temp} (T3 return value overrides)`;
    }
  } else {
    // t === 3
    desc += `\n  Encode fol1[${x}] = ${header.fol1[x]} via T1 tree (inside T3):`;
    desc += `\n  ${encT1Desc(x, header.fol1[x])}`;
    encT1(bw, x, header.fol1[x]);
    desc += `\n  fol2/fol3 determined by T3 dispatch tables`;
  }

  return desc;
}

/**
 * Encode a single pixel transition.
 * Returns a description string.
 */
export function encPixel(
  bw: BitWriter,
  cur: number,
  next: number,
  header: Header,
): string {
  const x = cur;
  const t = header.types[x];

  if (t === 0) {
    return `Type 0: pixel ${cur} → ${next} (must be same, 0 bits)`;
  }

  if (next === cur) {
    bw.writeBit(1);
    return `Type ${t}: pixel ${cur} → ${next} repeat, write bit 1`;
  }

  bw.writeBit(0); // not repeat
  let desc = `Type ${t}: pixel ${cur} → ${next}, write bit 0 (not repeat)`;

  switch (t) {
    case 1:
      desc += `, then fol1 (no extra bits)`;
      break;
    case 2:
      if (next === header.fol1[x]) {
        bw.writeBit(0);
        desc += `, write 0 → fol1[${x}] = ${next}`;
      } else {
        bw.writeBit(1);
        desc += `, write 1 → fol2[${x}] = ${next}`;
      }
      break;
    case 3:
      if (next === header.fol1[x]) {
        bw.writeBit(1);
        desc += `, write 1 → fol1[${x}] = ${next}`;
      } else if (next === header.fol3[x]) {
        bw.writeBit(0);
        bw.writeBit(1);
        desc += `, write 01 → fol3[${x}] = ${next}`;
      } else {
        bw.writeBit(0);
        bw.writeBit(0);
        desc += `, write 00 → fol2[${x}] = ${next}`;
      }
      break;
  }

  return desc;
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
// Main compressor with step recording
// ---------------------------------------------------------------------------

/**
 * Compress an array of CHR tiles into a PP1 stream, recording every
 * operation as a Step for the educational walkthrough UI.
 */
export function compressWithSteps(inputTilesChr: Uint8Array[]): DecodedResult {
  const tileCount = inputTilesChr.length;
  if (tileCount === 0 || tileCount > 256) {
    return {
      mode: 'compress',
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
  const allTilesChr: Uint8Array[] = [...inputTilesChr];
  const tileBitRanges: { start: number; end: number }[] = [];

  // Build pixel grids for display
  for (const chr of inputTilesChr) {
    const rows: number[][] = [];
    for (let r = 0; r < 8; r++) {
      rows.push(pixelsFromBp(chr[r], chr[8 + r]));
    }
    allTiles.push(rows);
  }

  const bw = new BitWriter();
  const countByte = tileCount === 256 ? 0 : tileCount;

  // Header state
  const header: Header = {
    types: [0, 0, 0, 0],
    fol1: [0, 0, 0, 0],
    fol2: [0, 0, 0, 0],
    fol3: [0, 0, 0, 0],
  };
  let headerValid = false;
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
`Write tile count byte = 0x${countByte.toString(16).padStart(2, '0')} = ${countByte}${tileCount === 256 ? ' (0 means 256)' : ''}.

${tileCount} tile${tileCount !== 1 ? 's' : ''} to compress. Each tile is 16 bytes of NES CHR
data (8 bytes bitplane 0 + 8 bytes bitplane 1 = 64 pixels, 8x8 grid).

The compressor analyses each tile's pixel transitions to build an
optimal prediction header, then encodes scanlines using that header.
Consecutive tiles that share the same transition patterns can reuse
the header, saving the overhead of re-encoding it.`,
    header: cloneHeader(header),
    currentTile: cloneTileGrid(currentGrid),
    completedCount: 0,
    highlightRow: -1,
    highlightPixels: [],
    headerHighlight: -1,
  });

  for (let tileIdx = 0; tileIdx < tileCount; tileIdx++) {
    const chr = inputTilesChr[tileIdx];
    const tileStartBit = bw.pos + 8; // +8 for count byte

    // Fill current grid for display
    currentGrid = allTiles[tileIdx].map(row => [...row]);

    // --- Header decision ---
    const canReuse = headerValid && headerCoversChr(header, chr);

    if (canReuse) {
      bw.writeBit(1); // reuse header
      steps.push({
        type: 'header-flag',
        tileIndex: tileIdx,
        bitStart: tileStartBit,
        bitEnd: bw.pos + 8,
        title: `Tile ${tileIdx}: reuse header (write 1)`,
        detail:
`Header decision for tile ${tileIdx}: the current header can represent
all pixel transitions in this tile → write bit 1 (reuse).

This saves ${(() => {
  // Estimate header cost
  let cost = 1; // flag bit
  for (let x = 3; x >= 0; x--) {
    cost += 2; // type bits
    const t = header.types[x];
    if (t === 1) cost += (header.fol1[x] === fc1(x) ? 1 : 2);
    if (t === 2) cost += (header.fol1[x] === fc1(x) ? 1 : 2) + 1;
    if (t === 3) cost += (header.fol1[x] === fc1(x) ? 1 : 2);
  }
  return cost;
})()} bits compared to emitting a new header.

Current header:
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
      // Build new header from this tile's transitions
      const trans = tileTransitionsFromChr(chr);
      const newHeader = buildHeaderFromTrans(trans);
      header.types = [...newHeader.types];
      header.fol1 = [...newHeader.fol1];
      header.fol2 = [...newHeader.fol2];
      header.fol3 = [...newHeader.fol3];
      headerValid = true;

      bw.writeBit(0); // new header

      const headerBitStart = bw.pos + 8;

      steps.push({
        type: 'header-flag',
        tileIndex: tileIdx,
        bitStart: tileStartBit,
        bitEnd: bw.pos + 8,
        title: `Tile ${tileIdx}: new header (write 0)`,
        detail:
`Header decision for tile ${tileIdx}: ${canReuse ? '' : 'previous header cannot represent all transitions → '}emit new header.

Transition analysis for this tile:
${(() => {
  let s = '';
  for (let x = 0; x < 4; x++) {
    const followers: string[] = [];
    for (let y = 0; y < 4; y++) {
      if (y !== x && trans[x][y] > 0) {
        followers.push(`→${y} (×${trans[x][y]})`);
      }
    }
    if (followers.length > 0 || trans[x][x] > 0) {
      s += `  pixel ${x}: self ×${trans[x][x]}, ${followers.join(', ') || 'no transitions'}\n`;
    }
  }
  return s;
})()}
Optimal header:
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

      // Encode header entries for x = 3, 2, 1, 0
      for (let xi = 3; xi >= 0; xi--) {
        const entryStart = bw.pos + 8;
        const desc = encHeaderEntry(bw, header, xi);

        steps.push({
          type: 'header-type',
          tileIndex: tileIdx,
          bitStart: entryStart,
          bitEnd: bw.pos + 8,
          title: `Pixel ${xi}: type ${header.types[xi]}${header.types[xi] > 0 ? `, fol1=${header.fol1[xi]}` : ''}`,
          detail:
`Encode header entry for pixel value ${xi}:
  ${desc}

${TYPE_NAMES[header.types[xi]]}`,
          header: cloneHeader(header),
          currentTile: cloneTileGrid(currentGrid),
          completedCount: tileIdx,
          highlightRow: xi,
          highlightPixels: [],
          headerHighlight: xi,
        });
      }
    }

    // --- Encode 8 scanlines in decode order: line 7, 6, …, 0 ---
    for (let line = 7; line >= 0; line--) {
      const idx = 7 - line;
      const bp0 = chr[idx];
      const bp1 = chr[8 + idx];
      const gridRow = 7 - line;

      // Determine previous scanline for repeat check
      let prevBp0Line: number;
      let prevBp1Line: number;
      if (line === 7) {
        prevBp0Line = prevBp0;
        prevBp1Line = prevBp1;
      } else {
        const prevIdx = 7 - (line + 1);
        prevBp0Line = chr[prevIdx];
        prevBp1Line = chr[8 + prevIdx];
      }

      const scanStart = bw.pos + 8;

      if (bp0 === prevBp0Line && bp1 === prevBp1Line) {
        // Repeat scanline
        bw.writeBit(1);
        const pixels = pixelsFromBp(bp0, bp1);
        const srcDesc = line === 7
          ? 'previous tile\'s last scanline'
          : `scanline ${line + 1}`;

        steps.push({
          type: 'scanline-repeat',
          tileIndex: tileIdx,
          bitStart: scanStart,
          bitEnd: bw.pos + 8,
          title: `Line ${line}: repeat (write 1)`,
          detail:
`Scanline ${line}: identical to ${srcDesc} → write bit 1 (repeat).

  bp0 = 0x${bp0.toString(16).padStart(2, '0')} = ${bp0.toString(2).padStart(8, '0')}
  bp1 = 0x${bp1.toString(16).padStart(2, '0')} = ${bp1.toString(2).padStart(8, '0')}
  pixels = [${pixels.join(', ')}]

Repeat saves all the per-pixel encoding bits. For tiles with solid
horizontal bands, this can compress an entire row to just 1 bit.`,
          header: cloneHeader(header),
          currentTile: cloneTileGrid(currentGrid),
          completedCount: tileIdx,
          highlightRow: -1,
          highlightPixels: Array.from({ length: 8 }, (_, c) => ({ r: gridRow, c })),
          headerHighlight: -1,
        });
      } else {
        // New scanline
        bw.writeBit(0);
        const pixels = pixelsFromBp(bp0, bp1);
        bw.writeBits(pixels[0], 2); // seed

        const seedEnd = bw.pos + 8;

        steps.push({
          type: 'scanline-seed',
          tileIndex: tileIdx,
          bitStart: scanStart,
          bitEnd: seedEnd,
          title: `Line ${line}: seed=${pixels[0]}`,
          detail:
`Scanline ${line}: different from previous → write bit 0, then seed.

Seed pixel = ${pixels[0]} (2 bits: ${pixels[0].toString(2).padStart(2, '0')})
  bp0 = 0x${bp0.toString(16).padStart(2, '0')} = ${bp0.toString(2).padStart(8, '0')}
  bp1 = 0x${bp1.toString(16).padStart(2, '0')} = ${bp1.toString(2).padStart(8, '0')}
  pixels = [${pixels.join(', ')}]

The seed is the leftmost pixel. The remaining 7 pixels will be
encoded as transitions from each pixel to the next, using the
prediction header.`,
          header: cloneHeader(header),
          currentTile: cloneTileGrid(currentGrid),
          completedCount: tileIdx,
          highlightRow: -1,
          highlightPixels: [{ r: gridRow, c: 0 }],
          headerHighlight: -1,
        });

        // Encode 7 pixel transitions
        for (let k = 0; k < 7; k++) {
          const predStart = bw.pos + 8;
          const desc = encPixel(bw, pixels[k], pixels[k + 1], header);

          steps.push({
            type: 'pixel',
            tileIndex: tileIdx,
            bitStart: predStart,
            bitEnd: bw.pos + 8,
            title: `Line ${line}, px ${k + 1}: ${pixels[k]}→${pixels[k + 1]}`,
            detail:
`Encode pixel transition ${k + 1}/7 on scanline ${line}:
${desc}

Row: [${pixels.slice(0, k + 2).join(', ')}${k + 2 < 8 ? ', ...' : ''}]`,
            header: cloneHeader(header),
            currentTile: cloneTileGrid(currentGrid),
            completedCount: tileIdx,
            highlightRow: header.types[pixels[k]] > 0 ? pixels[k] : -1,
            highlightPixels: [{ r: gridRow, c: k + 1 }],
            headerHighlight: -1,
          });
        }
      }
    }

    // Track last decoded scanline (line 0) for next tile
    prevBp0 = chr[7];   // bp0 of decode line 0 = chr[7]
    prevBp1 = chr[15];  // bp1 of decode line 0 = chr[15]

    const tileEndBit = bw.pos + 8;
    tileBitRanges.push({ start: tileStartBit, end: tileEndBit });

    // Tile completion step
    steps.push({
      type: 'tile-complete',
      tileIndex: tileIdx,
      bitStart: tileStartBit,
      bitEnd: tileEndBit,
      title: `Tile ${tileIdx} compressed`,
      detail:
`Tile ${tileIdx} fully compressed! ${tileEndBit - tileStartBit} bits used.

Input CHR (16 bytes):
  bp0: ${Array.from(chr.slice(0, 8)).map(b => b.toString(16).padStart(2, '0')).join(' ')}
  bp1: ${Array.from(chr.slice(8, 16)).map(b => b.toString(16).padStart(2, '0')).join(' ')}

${tileIdx + 1} of ${tileCount} tile${tileCount !== 1 ? 's' : ''} compressed.
Running total: ${Math.ceil((tileEndBit) / 8)} bytes output so far
(${((Math.ceil((tileEndBit) / 8) / ((tileIdx + 1) * 16)) * 100).toFixed(1)}% of uncompressed).`,
      header: cloneHeader(header),
      currentTile: cloneTileGrid(currentGrid),
      completedCount: tileIdx + 1,
      highlightRow: -1,
      highlightPixels: [],
      headerHighlight: -1,
    });
  }

  // Build output: count byte + bitstream
  const bitstreamBytes = bw.toBytes();
  const outputData = new Uint8Array(1 + bitstreamBytes.length);
  outputData[0] = countByte;
  outputData.set(bitstreamBytes, 1);

  return {
    mode: 'compress',
    steps,
    allTiles,
    allTilesChr,
    tileBitRanges,
    tileCount,
    totalBits: bw.pos + 8,
    outputData,
  };
}
