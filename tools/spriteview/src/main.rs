mod emu6502;

use std::fs;
use std::path::PathBuf;

/// NES palette RGB values (64 colours).
const NES_PALETTE: [[u8; 3]; 64] = [
    [84,84,84],[0,30,116],[8,16,144],[48,0,136],[68,0,100],[92,0,48],[84,4,0],[60,24,0],
    [32,42,0],[8,58,0],[0,64,0],[0,60,0],[0,50,60],[0,0,0],[0,0,0],[0,0,0],
    [152,150,152],[8,76,196],[48,50,236],[92,30,228],[136,20,176],[160,20,100],[152,34,32],[120,60,0],
    [84,90,0],[40,114,0],[8,124,0],[0,118,40],[0,102,120],[0,0,0],[0,0,0],[0,0,0],
    [236,238,236],[76,154,236],[120,124,236],[176,98,236],[228,84,236],[236,88,180],[236,106,100],[212,136,32],
    [160,170,0],[116,196,0],[76,208,32],[56,204,108],[56,180,220],[60,60,60],[0,0,0],[0,0,0],
    [236,238,236],[168,204,236],[188,188,236],[212,178,236],[236,174,236],[236,174,212],[236,180,176],[228,196,144],
    [204,210,120],[180,222,120],[168,226,144],[152,226,180],[160,214,228],[160,162,160],[0,0,0],[0,0,0],
];

/// Default sprite palette (from bank0 sprite colours at $8696).
const SPRITE_PALETTES: [[u8; 4]; 4] = [
    [0x0D, 0x27, 0x17, 0x06], // palette 0
    [0x0D, 0x20, 0x2D, 0x0C], // palette 1
    [0x0D, 0x37, 0x15, 0x06], // palette 2
    [0x0D, 0x37, 0x27, 0x06], // palette 3
];

/// An OAM entry from the NES sprite table.
#[derive(Debug, Clone)]
struct OamEntry {
    y: u8,
    tile: u8,
    attr: u8,
    x: u8,
}

impl OamEntry {
    fn palette(&self) -> usize { (self.attr & 3) as usize }
    fn flip_h(&self) -> bool { self.attr & 0x40 != 0 }
    fn flip_v(&self) -> bool { self.attr & 0x80 != 0 }
    fn visible(&self) -> bool { self.y < 0xEF }
}

fn main() {
    let args: Vec<String> = std::env::args().collect();

    match args.get(1).map(|s| s.as_str()) {
        Some("dump") => cmd_dump(&args[2..]),
        Some("render") => cmd_render(&args[2..]),
        Some("render-all") => cmd_render_all(&args[2..]),
        _ => {
            eprintln!("spriteview — Super Robin Hood sprite renderer");
            eprintln!();
            eprintln!("Usage:");
            eprintln!("  spriteview dump <bank2.bin> <bank3.bin> <sprite#>      Dump OAM entries");
            eprintln!("  spriteview render <bank2.bin> <bank3.bin> <sprite#> <out.png>");
            eprintln!("  spriteview render-all <bank2.bin> <bank3.bin> <outdir>");
            std::process::exit(1);
        }
    }
}

/// Set up the emulator with bank3 code and sprite CHR tiles loaded.
fn setup_emu(bank2: &[u8], bank3: &[u8]) -> emu6502::Emu {
    let mut emu = emu6502::Emu::new();

    // Load bank3 at $C000
    for (i, &b) in bank3.iter().enumerate() {
        if 0xC000 + i < 0x10000 {
            emu.mem[0xC000 + i] = b;
        }
    }

    // Load bank2 at $8000 (needed for PP1 decompression of robinchr)
    for (i, &b) in bank2.iter().enumerate() {
        if 0x8000 + i < 0xC000 {
            emu.mem[0x8000 + i] = b;
        }
    }

    // Decompress robinchr (sprite tiles) into pattern table 0 ($0000-$0FFF)
    // robinchr is PP1 block index 3, at $A213 in bank2, 256 tiles → VRAM $0000
    // We'll use the game's own PP1 decompressor to do this!
    // Set up VRAM address to $0000
    emu.mem[0x2006] = 0x00; // high byte
    // The PP1 decompressor writes to $2007, but we need to capture those
    // and put them into a separate CHR buffer. For simplicity, let's
    // decompress robinchr ourselves in Rust and load the tiles into
    // a memory region the sprite renderer can reference.

    // Actually, the sprite renderer doesn't read from VRAM — it reads
    // tile indices and writes them into OAM. The actual CHR pixel data
    // is only needed for our PNG rendering step, not for the 6502 emulation.
    // So we just need the OAM output.

    // Put a BRK at a known return address
    emu.mem[0x0400] = 0x00; // BRK

    emu
}

/// Call the sprite renderer for a given sprite index and capture OAM.
fn render_sprite_via_emu(emu: &mut emu6502::Emu, sprite_idx: u8) -> Vec<OamEntry> {
    // Clear OAM area
    for i in 0..256 {
        emu.mem[0x0200 + i] = 0xFE; // Y=FE = off-screen
    }

    // Reset sprite block pointer
    emu.mem[0x0E] = 0x04; // spriteblockpointer = 4 (skip first OAM entry, used for player?)

    // Set sprite position to center of screen (128, 128)
    // The renderer uses temp2 (x pos) and temp3 (y pos)
    emu.mem[0x33] = 128; // temp2 = X position
    emu.mem[0x34] = 128; // temp3 = Y position

    // Clear flip flags
    emu.mem[0x32] = 0x00; // temp1 — bit 7 = horizontal flip
    emu.mem[0x66] = 0x00; // palette override
    emu.mem[0x67] = 0x00; // additional palette bits

    // Player mask (controls palette addition)
    emu.mem[0xEE36 - 0xC000 + 0xC000] = 0x00; // playermask = 0

    // Set up stack and call the sprite renderer
    // printspriteposrev at $ECFF expects A = sprite index
    emu.sp = 0xFD;
    // Push return address (BRK at $0400)
    let ret = 0x03FFu16;
    emu.mem[0x0100 | emu.sp as usize] = (ret >> 8) as u8;
    emu.sp = emu.sp.wrapping_sub(1);
    emu.mem[0x0100 | emu.sp as usize] = ret as u8;
    emu.sp = emu.sp.wrapping_sub(1);

    emu.a = sprite_idx;
    emu.pc = 0xECFF; // printspriteposrev
    emu.cycles = 0;
    emu.run(500_000);

    // Read OAM entries
    let mut entries = Vec::new();
    for i in (0..256).step_by(4) {
        let y = emu.mem[0x0200 + i];
        let tile = emu.mem[0x0201 + i];
        let attr = emu.mem[0x0202 + i];
        let x = emu.mem[0x0203 + i];
        if y < 0xEF { // visible
            entries.push(OamEntry { y, tile, attr, x });
        }
    }
    entries
}

/// Decompress robinchr from bank2 and return 256 tiles as pixel arrays.
fn load_sprite_chr(bank2: &[u8]) -> Vec<[[u8; 8]; 8]> {
    // robinchr at $A213 in bank2 (offset $2213)
    let offset = 0x2213;
    let data = &bank2[offset..];
    let num_tiles = if data[0] == 0 { 256 } else { data[0] as usize };

    // Inline PP1 decompressor (same as mapview)
    let raw_tiles = pp1_decompress(data, num_tiles);

    let mut chr = vec![[[0u8; 8]; 8]; 256];
    for (i, tile) in raw_tiles.iter().enumerate() {
        if i >= 256 { break; }
        for row in 0..8 {
            let b0 = tile[row];
            let b1 = tile[row + 8];
            for col in 0..8 {
                let bit = 7 - col;
                chr[i][row][col] = ((b0 >> bit) & 1) | (((b1 >> bit) & 1) << 1);
            }
        }
    }
    chr
}

/// Render OAM entries to a pixel buffer using CHR tile data.
fn render_oam_to_image(entries: &[OamEntry], chr: &[[[u8; 8]; 8]]) -> (u32, u32, Vec<u8>) {
    if entries.is_empty() {
        return (8, 8, vec![0; 8 * 8 * 4]);
    }

    // Find bounding box
    let min_x = entries.iter().map(|e| e.x as i32).min().unwrap();
    let max_x = entries.iter().map(|e| e.x as i32 + 8).max().unwrap();
    let min_y = entries.iter().map(|e| e.y as i32).min().unwrap();
    let max_y = entries.iter().map(|e| e.y as i32 + 8).max().unwrap();

    let width = (max_x - min_x).max(1) as u32;
    let height = (max_y - min_y).max(1) as u32;

    // RGBA buffer (transparent background)
    let mut pixels = vec![0u8; (width * height * 4) as usize];

    for entry in entries {
        let tile_idx = entry.tile as usize;
        if tile_idx >= chr.len() { continue; }
        let tile = &chr[tile_idx];
        let pal_idx = entry.palette();
        let pal = &SPRITE_PALETTES[pal_idx];

        for ty in 0..8u32 {
            for tx in 0..8u32 {
                let src_y = if entry.flip_v() { 7 - ty } else { ty } as usize;
                let src_x = if entry.flip_h() { 7 - tx } else { tx } as usize;
                let pixel = tile[src_y][src_x] as usize;
                if pixel == 0 { continue; } // transparent

                let nes_color = (pal[pixel] & 0x3F) as usize;
                let rgb = NES_PALETTE[nes_color];

                let px = (entry.x as i32 - min_x) as u32 + tx;
                let py = (entry.y as i32 - min_y) as u32 + ty;
                if px < width && py < height {
                    let off = ((py * width + px) * 4) as usize;
                    pixels[off] = rgb[0];
                    pixels[off + 1] = rgb[1];
                    pixels[off + 2] = rgb[2];
                    pixels[off + 3] = 255; // opaque
                }
            }
        }
    }

    (width, height, pixels)
}

fn save_rgba_png(path: &PathBuf, width: u32, height: u32, pixels: &[u8]) {
    let img = image::RgbaImage::from_raw(width, height, pixels.to_vec())
        .expect("Invalid image dimensions");
    img.save(path).expect("Cannot save PNG");
}

fn cmd_dump(args: &[String]) {
    if args.len() < 3 {
        eprintln!("Usage: spriteview dump <bank2.bin> <bank3.bin> <sprite#>");
        std::process::exit(1);
    }
    let bank2 = fs::read(&args[0]).expect("Cannot read bank2");
    let bank3 = fs::read(&args[1]).expect("Cannot read bank3");
    let sprite_idx: u8 = args[2].parse().expect("Invalid sprite number");

    let mut emu = setup_emu(&bank2, &bank3);
    let entries = render_sprite_via_emu(&mut emu, sprite_idx);

    println!("Sprite {} — {} OAM entries:", sprite_idx, entries.len());
    for (i, e) in entries.iter().enumerate() {
        println!("  [{:2}] x={:3} y={:3} tile=${:02X} attr=${:02X} (pal={} flipH={} flipV={})",
            i, e.x, e.y, e.tile, e.attr,
            e.palette(), e.flip_h(), e.flip_v());
    }
}

fn cmd_render(args: &[String]) {
    if args.len() < 4 {
        eprintln!("Usage: spriteview render <bank2.bin> <bank3.bin> <sprite#> <out.png>");
        std::process::exit(1);
    }
    let bank2 = fs::read(&args[0]).expect("Cannot read bank2");
    let bank3 = fs::read(&args[1]).expect("Cannot read bank3");
    let sprite_idx: u8 = args[2].parse().expect("Invalid sprite number");
    let out_path = PathBuf::from(&args[3]);

    let mut emu = setup_emu(&bank2, &bank3);
    let entries = render_sprite_via_emu(&mut emu, sprite_idx);
    let chr = load_sprite_chr(&bank2);
    let (w, h, pixels) = render_oam_to_image(&entries, &chr);

    save_rgba_png(&out_path, w, h, &pixels);
    println!("Rendered sprite {} ({} OAM entries, {}×{}) → {}",
        sprite_idx, entries.len(), w, h, out_path.display());
}

fn cmd_render_all(args: &[String]) {
    if args.len() < 3 {
        eprintln!("Usage: spriteview render-all <bank2.bin> <bank3.bin> <outdir>");
        std::process::exit(1);
    }
    let bank2 = fs::read(&args[0]).expect("Cannot read bank2");
    let bank3 = fs::read(&args[1]).expect("Cannot read bank3");
    let outdir = PathBuf::from(&args[2]);
    fs::create_dir_all(&outdir).expect("Cannot create output directory");

    let chr = load_sprite_chr(&bank2);
    let mut emu = setup_emu(&bank2, &bank3);

    for idx in 0..66u8 {
        let entries = render_sprite_via_emu(&mut emu, idx);
        if entries.is_empty() {
            println!("  [{:2}] (empty)", idx);
            continue;
        }
        let (w, h, pixels) = render_oam_to_image(&entries, &chr);
        let out_path = outdir.join(format!("{:02}.png", idx));
        save_rgba_png(&out_path, w, h, &pixels);
        println!("  [{:2}] {} OAM entries, {}×{} → {}", idx, entries.len(), w, h, out_path.display());
    }
}

// ── PP1 decompressor (same as mapview) ──

fn pp1_decompress(data: &[u8], num_tiles: usize) -> Vec<[u8; 16]> {
    let mut pos = 1usize;
    let mut buf = 0u8;
    let mut bits_left = 0u8;
    let mut tiles = Vec::with_capacity(num_tiles);

    let rom: [u8; 18] = [
        0x03,0x03,0x03, 0x02,0x02,0x01, 0x01,0x00,0x00,0x00,
        0x02,0xFF,0x00,0x00, 0x03,0x03,0xFF,0x01,
    ];
    let fc3 = |x: usize| rom[x];
    let fc2 = |x: usize| rom[3 + x];
    let fc1 = |x: usize| rom[6 + x];
    let f1l = |x: usize| rom[10 + x];
    let f2h = |x: usize| rom[14 + x];

    macro_rules! read_bit {
        () => {{
            if bits_left == 0 {
                buf = *data.get(pos).unwrap_or(&0);
                pos += 1;
                bits_left = 8;
            }
            let bit = buf & 0x80 != 0;
            buf <<= 1;
            bits_left -= 1;
            bit
        }};
    }
    macro_rules! read_bits {
        ($n:expr) => {{
            let mut val = 0u8;
            for _ in 0..$n { val = (val << 1) | read_bit!() as u8; }
            val
        }};
    }

    let mut types = [0u8; 4];
    let mut fol1 = [0u8; 4];
    let mut fol2 = [0u8; 4];
    let mut fol3 = [0u8; 4];
    let mut prev_bp0 = 0u8;
    let mut prev_bp1 = 0u8;

    for _ in 0..num_tiles {
        if !read_bit!() {
            for x in (0..4).rev() {
                let tc = read_bits!(2);
                types[x] = tc;
                match tc {
                    0 => {}
                    1 => {
                        fol1[x] = if read_bit!() { fc1(x) }
                                  else if read_bit!() { fc3(x) }
                                  else { fc2(x) };
                    }
                    2 => {
                        let v = if read_bit!() { fc1(x) }
                                else if read_bit!() { fc3(x) }
                                else { fc2(x) };
                        fol1[x] = v;
                        let (f2, temp) = match v {
                            0 => (fc2(x), fc3(x)), 1 => (f1l(x), fc3(x)),
                            2 => (fc1(x), f2h(x)), _ => (fc1(x), fc2(x)),
                        };
                        fol2[x] = f2;
                        if read_bit!() { fol2[x] = temp; }
                    }
                    3 => {
                        let v = if read_bit!() { fc1(x) }
                                else if read_bit!() { fc3(x) }
                                else { fc2(x) };
                        fol1[x] = v;
                        let (f2, temp) = match v {
                            0 => (fc2(x), fc3(x)), 1 => (f1l(x), fc3(x)),
                            2 => (fc1(x), f2h(x)), _ => (fc1(x), fc2(x)),
                        };
                        fol2[x] = f2;
                        fol3[x] = temp;
                    }
                    _ => unreachable!(),
                }
            }
        }

        let mut bp0 = [0u8; 8];
        let mut bp1 = [0u8; 8];

        for line in (0..8).rev() {
            if read_bit!() {
                bp0[line] = if line == 7 { prev_bp0 } else { bp0[line + 1] };
                bp1[line] = if line == 7 { prev_bp1 } else { bp1[line + 1] };
                continue;
            }
            let seed = read_bits!(2);
            let mut shift0 = seed;
            let mut shift1 = (seed >> 1) | 2;
            let mut pixel = seed;
            loop {
                let x = (pixel & 3) as usize;
                pixel = if types[x] == 0 { pixel }
                else if read_bit!() { pixel }
                else {
                    match types[x] {
                        1 => fol1[x],
                        2 => if read_bit!() { fol2[x] } else { fol1[x] },
                        3 => if read_bit!() { fol1[x] }
                             else if read_bit!() { fol3[x] }
                             else { fol2[x] },
                        _ => pixel,
                    }
                };
                let overflow = shift1 & 0x80 != 0;
                shift0 = (shift0 << 1) | (pixel & 1);
                shift1 = (shift1 << 1) | ((pixel >> 1) & 1);
                if overflow { break; }
            }
            bp0[line] = shift0;
            bp1[line] = shift1;
        }

        prev_bp0 = bp0[0];
        prev_bp1 = bp1[0];

        let mut tile = [0u8; 16];
        for i in 0..8 {
            tile[i] = bp0[7 - i];
            tile[8 + i] = bp1[7 - i];
        }
        tiles.push(tile);
    }
    tiles
}
