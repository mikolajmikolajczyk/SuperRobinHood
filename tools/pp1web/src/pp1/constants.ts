/**
 * PP1: Constants and lookup tables
 *
 * The ROM table layout mirrors the original 6502 code at $F381–$F392.
 * Tables are packed contiguously so that out-of-bounds reads from one
 * table intentionally spill into the next — the compressor relies on
 * this exact overlap pattern.
 */

// ---------------------------------------------------------------------------
// Palette
// ---------------------------------------------------------------------------

/** NES greyscale palette — CSS colour strings for pixel values 0-3. */
export const PALETTE: string[] = [
  '#000000', // 0 — black
  '#6d6d6d', // 1 — dark grey
  '#b2b2b2', // 2 — light grey
  '#ffffff', // 3 — white
];

/** NES greyscale palette — [r, g, b] triples for canvas rendering. */
export const PALETTE_RGB: [number, number, number][] = [
  [0x00, 0x00, 0x00],
  [0x6d, 0x6d, 0x6d],
  [0xb2, 0xb2, 0xb2],
  [0xff, 0xff, 0xff],
];

// ---------------------------------------------------------------------------
// ROM lookup tables
// ---------------------------------------------------------------------------

/**
 * 18-byte ROM table, packed as in the original cartridge:
 *
 *   Offset  Table  Values
 *   0       FC3    03 03 03        (3 bytes; FC3[3] reads FC2[0] = 02)
 *   3       FC2    02 02 01        (3 bytes; FC2[3] reads FC1[0] = 01)
 *   6       FC1    01 00 00 00     (4 bytes)
 *   10      F1L    02 FF 00 00     (4 bytes)
 *   14      F2H    03 03 FF 01     (4 bytes)
 */
export const ROM: number[] = [
  0x03, 0x03, 0x03,           // FC3
  0x02, 0x02, 0x01,           // FC2
  0x01, 0x00, 0x00, 0x00,     // FC1
  0x02, 0xff, 0x00, 0x00,     // F1L
  0x03, 0x03, 0xff, 0x01,     // F2H
];

/** FC3[x] — x indexes into the FC3 region; x=3 spills into FC2[0]. */
export function fc3(x: number): number { return ROM[x]; }
/** FC2[x] — x indexes into the FC2 region; x=3 spills into FC1[0]. */
export function fc2(x: number): number { return ROM[3 + x]; }
/** FC1[x] — 4-entry table at offset 6. */
export function fc1(x: number): number { return ROM[6 + x]; }
/** F1L[x] — 4-entry table at offset 10. */
export function f1l(x: number): number { return ROM[10 + x]; }
/** F2H[x] — 4-entry table at offset 14. */
export function f2h(x: number): number { return ROM[14 + x]; }

// ---------------------------------------------------------------------------
// Human-readable type descriptions
// ---------------------------------------------------------------------------

/** Descriptions for prediction types 0-3. */
export const TYPE_NAMES: string[] = [
  'Type 0: constant — pixel only transitions to itself (0 bits per pixel)',
  'Type 1: 1 follower — 1 bit: repeat self or switch to fol1',
  'Type 2: 2 followers — 1 bit repeat, then 1 bit to pick fol1 vs fol2',
  'Type 3: 3 followers — 1 bit repeat, then variable: 1→fol1, 01→fol3, 00→fol2',
];

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

/** Convert a hex string to a Uint8Array. */
export function hexToBytes(hex: string): Uint8Array {
  const bytes = new Uint8Array(hex.length / 2);
  for (let i = 0; i < hex.length; i += 2) {
    bytes[i / 2] = parseInt(hex.substring(i, i + 2), 16);
  }
  return bytes;
}

/**
 * Built-in PP1-compressed sample data, extracted from the Codemasters
 * NES ROM (bank 2). Each value is a complete PP1 stream including the
 * tile-count byte.
 */
export const SAMPLES: Record<string, Uint8Array> = {
  boxchr: hexToBytes(
    '090459fe4ca3fc4000ad8a0f242bffe7f9fc9bc731e126a057edff15e022ffe227f9328fe0052b60d41792bf6ff8'
  ),
  beadchr: hexToBytes(
    '172b4b07e07e05e05702a2a815fe2ffa66c015a5815e05405781526a820c3000806f1d05d8d5055e14aa0e630099bfe57f84e59a7f0bf6386df5a8d6b0adb860c0004600fc27382d716d02d928c9268c57c5462b48a8c57c5462b48b4245a62848bd05091698a122f4195885652b10ad25621594ac42b4c3fff3055ff7fe3fed9801130006cc7f4ffc7f5a931843c6021aa7aa8ffee7dcc2e605eabfdcc0fe59c47887823da2d295a016b0f10b90ae60a4053529a37245cd5cc0b883c637892d56b4024a2bb955495831c01fcd83fc8a5972f3f800'
  ),
  okchr: hexToBytes(
    '0120a35e539416a9f8bfe0012dffff'
  ),
  hiscorechrs: hexToBytes(
    'c820a0ff7fddd6a8da3f8da355ffccd3a8da334da3f5ffddd6a8df9b4debff99a751b59faffeeeb547b9be6d37affedf3a8eb9fad7dffddd6bcd5308da6f5ffcd5368ce3a8d5359ffddb6ddd7dbb7ff6f8ab7ae55b6effe6a9967b9f6641aaffe77b5fb547ebff9ca6166c9acffe669d46d4d5339ffddd6a8da9aaddbff99a751b46a9f66fbffbbad51b46e1aad93ff99a751b47e9aa6d3ffb7a6d36ef69b4debff9fc543d7baeffe75355b4ce93ff9cad56d2bb6ffe75334616d33ff9d44ebb7680d67ff3a8927b5eb75effedf16cf6b6e761faffef5dd7bfed7effbb6d2beaf5bfeebefffbaef3b9f7ffdd7bffdebbfeebdffffef6ba4d55a576dffdeb76debddd7ff7759a7e9dd6b1be7ff7759a7b5fa6a9dd7ff75daf695be7d5eb7ff779ac6edf5655db7ff7b5d76f5aabbaffeef354fadebbffbbad53bad55dd7ff775aabbcfabb6ff96080f5d3dcff8fd767febcdfb7ff9ee7feb3def7ff497a7e9ff47edf1fe8ae9ee7febf2ff3fffa30c80ff8c7c68f105e3fc7e2e737e7ff105c06b47b3fd1ed9e5679188840d019d0afe7fc7d46fd7f7fa3388da41e38f4c7a6bffc0074fc7e91c9a0ffe3b033aa4f8fffb7f987983a63ea5f7ffa603763ffffdcbffefe2dffefc5dffdf8b850f5e796c17faf74feffefbd7f5beffefeb788a7f7ff7dd706ffbeeb83cba88b8e3ff1f87d1ee3ff0c746c4f69e4c7ff08f5d78ee3c87c8fc3ffa352bb2fe53a218e3ff7febac23c7fe007aecaa17f9bcedebfe00af72b0eefa86d5457feff40c165c19185b3000343e560efa87dd66edfed876a988267913d4202a819b3cb2270333ff1ffbfef9d9d9dc759dbc2dc059e7129462620482460988a147fe7fbcc8292eef78f77ffe87e9aa2bcf51fefff67feffeaf88f18c3284b890c445201836f20b218c23c44e3183fe0fe1fc798f91ea3daeb16f0370967bda86d8369262aed432e4203ff8f2165f1e08f5c71044b89fdaf0b680f410909ec51ffad38f40ffecccb124596b15507607fcac1e38c41d6b163022501521401811280a90a02d6210341420b414204e331ff9f346bb73fbff7eabee3daddaef1effdb9db96dd2b7d5bd6de6dd76e79eb9f94c31f0afdfddeae197b9fdffde3dc1761ad1eac35db9fd1ae7cdffbf6be11f6af097b376411f1ffbdcfb86aef8ffdc1778f7fff7c37bab856ee77797bef873eb786be1bf7bfe9fcf5efe0f86f0c7b970addcf9fe9c2bfa3fff7f8ffbb9ddd6e1abe1bff3f8f0efdef857861f5bff773b856f72f0c7c37f07ffefe89c29feffdf0dc35619b73a2bce7f3af61adeeafb8f857efdbc6c3c779775bb9f9e770ade157dcde1570cce7d15edcec3370d5f0dffbf7be15f71eeac359d7bff77377eee03b9d86b6f97fe8e675e67cebd866e1abc3bff7e1786b865dcd8576e7e6bec2bb856f73b856c33b731bfb0aeee6e19786bf0bff3c81fc7fefd2f0a9fc7fd6b163e07947a8f41f03ca3d47a5902c288a9b105902c288a9b10519cc7ff7faff1fd5fceffb4fa53c82724392264c3c7f20affffffffffff1f87de3de3788e298be3588e2fd73412277f0a206884031859ed9a06880e101d13cd8973f33e73cfb3f07d0fb3f668c28c0b908c205a080561f1180fffeff23198fe5a55104509010861389a252cacc98648a84820428043090829005930b7fcafd8bee1e40f9af99fb49472634988ae9cf42fbfcc91612184261d75ff39ec03c4e210290303a90720b6ff3f8fffec3906cfbfff1ffffffffffffffffffffffffffffffffe3338df13e0feeb1120299290a9017c9422544a8a80607f4952942c82ca0e50f5873fc1f09d1de3e63ced5414da3255739d1f53f70c20ed08063df1f0fcb541a3a841827ef3ecfa3d2775a3d420c2a0a2f8bc2e0b06c1b86f9aa227c4f19c7319a4ea7afec361fff00a3a3d1f47e1fcc07edf5e704952879f8f91f83fcfdcfb3e8f41dc1db1ffffffffff0'
  ),
};
