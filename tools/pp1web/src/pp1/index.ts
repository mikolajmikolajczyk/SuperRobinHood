/**
 * PP1
 *
 * Re-exports all public API from the PP1 codec modules.
 */

// Types
export type { Step, Header, DecodedResult } from './types';

// Constants and lookup tables
export {
  PALETTE,
  PALETTE_RGB,
  ROM,
  fc1, fc2, fc3, f1l, f2h,
  TYPE_NAMES,
  SAMPLES,
  hexToBytes,
} from './constants';

// Bitstream I/O
export { BitReader, BitWriter } from './bitstream';

// Decompression
export {
  decodeWithSteps,
  pixelsFromBp,
  bpFromPixels,
} from './decompress';

// Compression
export {
  compressWithSteps,
  tilePixelsFromChr,
  tileTransitionsFromChr,
  t3Followers,
  buildHeaderFromTrans,
  headerCoversChr,
  encT1,
  encT1Desc,
  encHeaderEntry,
  encPixel,
} from './compress';

// ca65 assembly source
export { CC65_UNPACKER_SRC } from './cc65';
