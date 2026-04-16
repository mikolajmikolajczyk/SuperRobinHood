/**
 * PP1: Bitstream I/O
 *
 * MSB-first bit reader and writer, matching the original 6502
 * implementation's bit ordering. When all 8 bits of the current byte
 * are consumed, the next byte is loaded automatically.
 */

// ---------------------------------------------------------------------------
// BitReader — reads bits MSB-first from a Uint8Array
// ---------------------------------------------------------------------------

export class BitReader {
  private data: Uint8Array;
  private bytePos: number;
  private buf: number;
  private bitsLeft: number;
  /** Total number of bits consumed so far (bit-level cursor). */
  private bitPos: number;

  constructor(data: Uint8Array, startByte: number = 0) {
    this.data = data;
    this.bytePos = startByte;
    this.buf = 0;
    this.bitsLeft = 0;
    this.bitPos = startByte * 8;
  }

  /** Current bit position in the stream. */
  get pos(): number {
    return this.bitPos;
  }

  /** Read a single bit (0 or 1). */
  readBit(): number {
    if (this.bitsLeft === 0) {
      this.buf = this.bytePos < this.data.length ? this.data[this.bytePos] : 0;
      this.bytePos++;
      this.bitsLeft = 8;
    }
    const bit = (this.buf >> 7) & 1;
    this.buf = (this.buf << 1) & 0xff;
    this.bitsLeft--;
    this.bitPos++;
    return bit;
  }

  /** Read `n` bits as an unsigned integer (MSB first). */
  readBits(n: number): number {
    let val = 0;
    for (let i = 0; i < n; i++) {
      val = (val << 1) | this.readBit();
    }
    return val;
  }
}

// ---------------------------------------------------------------------------
// BitWriter — writes bits MSB-first into a growing byte array
// ---------------------------------------------------------------------------

export class BitWriter {
  private bytes: number[] = [];
  private buf: number = 0;
  private bitsUsed: number = 0;

  /** Current bit position (total bits written so far). */
  get pos(): number {
    return this.bytes.length * 8 + this.bitsUsed;
  }

  /** Write a single bit (0 or 1). */
  writeBit(bit: number): void {
    this.buf = ((this.buf << 1) | (bit & 1)) & 0xff;
    this.bitsUsed++;
    if (this.bitsUsed === 8) {
      this.bytes.push(this.buf);
      this.buf = 0;
      this.bitsUsed = 0;
    }
  }

  /** Write `n` bits from `val` (MSB first). */
  writeBits(val: number, n: number): void {
    for (let i = n - 1; i >= 0; i--) {
      this.writeBit((val >> i) & 1);
    }
  }

  /**
   * Return a string of '0'/'1' characters for the bits written
   * between positions `from` and `to` (exclusive) in the stream.
   * Useful for educational display.
   */
  bitsFrom(from: number, to: number): string {
    let s = '';
    const allBits = this.bytes.length * 8 + this.bitsUsed;
    for (let i = from; i < to && i < allBits; i++) {
      const byteIdx = Math.floor(i / 8);
      const bitIdx = 7 - (i % 8);
      if (byteIdx < this.bytes.length) {
        s += (this.bytes[byteIdx] >> bitIdx) & 1;
      } else {
        // In the partial buffer
        const shiftedBuf = this.buf << (8 - this.bitsUsed);
        const bufBit = 7 - (i - this.bytes.length * 8);
        s += (shiftedBuf >> bufBit) & 1;
      }
    }
    return s;
  }

  /** Flush and return the complete byte array. Pads the last byte with 0s. */
  toBytes(): Uint8Array {
    const result = new Uint8Array(this.bytes.length + (this.bitsUsed > 0 ? 1 : 0));
    for (let i = 0; i < this.bytes.length; i++) {
      result[i] = this.bytes[i];
    }
    if (this.bitsUsed > 0) {
      result[this.bytes.length] = (this.buf << (8 - this.bitsUsed)) & 0xff;
    }
    return result;
  }
}
