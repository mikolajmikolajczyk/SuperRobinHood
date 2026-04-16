/**
 * PP1: Type definitions
 *
 * Interfaces for the step-by-step educational decoder/compressor.
 */

/** A single step in the decode/compress walkthrough. */
export interface Step {
  /** Step category (e.g. 'tile-count', 'header-flag', 'type', 'scanline', 'pixel', etc.) */
  type: string;
  /** Index of the tile currently being processed (0-based). */
  tileIndex: number;
  /** Bit offset where this step's consumed bits begin. */
  bitStart: number;
  /** Bit offset where this step's consumed bits end (exclusive). */
  bitEnd: number;
  /** Short human-readable title for the step. */
  title: string;
  /** Longer educational description (may contain markup). */
  detail: string;
  /** Snapshot of the current header state. */
  header: Header;
  /** Snapshot of the current tile's pixel grid (8 rows x 8 cols, values 0-3; -1 = unfilled). */
  currentTile: number[][];
  /** Number of fully completed tiles so far. */
  completedCount: number;
  /** Row index to highlight in the prediction table (0-3), or -1 for none. */
  highlightRow: number;
  /** Individual pixel cells to highlight in the tile grid. */
  highlightPixels: { r: number; c: number }[];
  /** Which header row(s) to highlight (e.g. during header decode). */
  headerHighlight: number;
}

/** Per-tile prediction header: type + follower tables for each pixel value 0-3. */
export interface Header {
  types: number[];
  fol1: number[];
  fol2: number[];
  fol3: number[];
}

/** Complete result of a step-by-step decode or compress operation. */
export interface DecodedResult {
  /** Whether this result was produced by decompression or compression. */
  mode: 'decompress' | 'compress';
  /** All recorded steps for the walkthrough UI. */
  steps: Step[];
  /** Final decoded tiles as 8x8 pixel grids (values 0-3). */
  allTiles: number[][][];
  /** Final decoded tiles in NES CHR format (16 bytes each). */
  allTilesChr: Uint8Array[];
  /** For each tile, the [start, end) bit range it occupies in the stream. */
  tileBitRanges: { start: number; end: number }[];
  /** Total number of tiles. */
  tileCount: number;
  /** Total bits consumed/produced. */
  totalBits: number;
  /** The output data (compressed PP1 stream, or decompressed CHR). */
  outputData?: Uint8Array;
}
