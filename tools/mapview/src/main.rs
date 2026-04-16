use std::fs;
use std::path::PathBuf;

/// NES palette: 64 colours, RGB values.
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

/// Map info entry from bank3's mapinfo table at $FD95.
struct MapInfo {
    data_ptr: u16,   // pointer into bank0
    offset: u8,      // scroll offset
    height: u8,      // height in rows
    palette_idx: u8, // palette config
    chr_config: u8,  // CHR set config
}

/// 256 block definitions from bank0.
struct BlockDefs {
    tile_tl: [u8; 256],
    tile_tr: [u8; 256],
    tile_bl: [u8; 256],
    tile_br: [u8; 256],
    attr: [u8; 256],
    solid: [u8; 256],
}

fn main() {
    let args: Vec<String> = std::env::args().collect();

    match args.get(1).map(|s| s.as_str()) {
        Some("list") => cmd_list(&args[2..]),
        Some("render") => cmd_render(&args[2..]),
        Some("render-all") => cmd_render_all(&args[2..]),
        _ => {
            eprintln!("mapview — Super Robin Hood map renderer");
            eprintln!();
            eprintln!("Usage:");
            eprintln!("  mapview list <bank0.bin> <bank3.bin>                   List all maps");
            eprintln!("  mapview render <bank0.bin> <bank2.bin> <bank3.bin> <map#> <out.png>");
            eprintln!("  mapview render-all <bank0.bin> <bank2.bin> <bank3.bin> <outdir>");
            std::process::exit(1);
        }
    }
}

fn read_mapinfo(bank3: &[u8]) -> Vec<MapInfo> {
    let off = 0xFD95 - 0xC000;
    (0..14).map(|i| {
        let b = off + i * 6;
        MapInfo {
            data_ptr: u16::from_le_bytes([bank3[b], bank3[b + 1]]),
            offset: bank3[b + 2],
            height: bank3[b + 3],
            palette_idx: bank3[b + 4],
            chr_config: bank3[b + 5],
        }
    }).collect()
}

fn read_blocks(bank0: &[u8]) -> BlockDefs {
    let mut defs = BlockDefs {
        tile_tl: [0; 256], tile_tr: [0; 256],
        tile_bl: [0; 256], tile_br: [0; 256],
        attr: [0; 256], solid: [0; 256],
    };
    for i in 0..256 {
        defs.tile_tl[i] = bank0[0x000 + i];
        defs.tile_tr[i] = bank0[0x100 + i];
        defs.tile_bl[i] = bank0[0x200 + i];
        defs.tile_br[i] = bank0[0x300 + i];
        defs.attr[i] = bank0[0x400 + i];
        defs.solid[i] = bank0[0x500 + i];
    }
    defs
}

fn read_palette(bank0: &[u8], pal_offset: u8) -> [[u8; 3]; 16] {
    // pal_offset is a byte offset into the palette data at $861E in bank0
    let base = 0x61E + pal_offset as usize;
    let mut pal = [[0u8; 3]; 16];
    for i in 0..16 {
        let nes_color = if base + i < bank0.len() {
            bank0[base + i] as usize & 0x3F
        } else {
            0
        };
        pal[i] = NES_PALETTE[nes_color];
    }
    pal
}

/// Decompress a PP1 CHR block from bank2 and return 8x8 tile patterns.
/// Each tile is 16 bytes: 8 bytes bp0 + 8 bytes bp1.
fn decompress_pp1_tiles(bank2: &[u8], offset: usize) -> Vec<[u8; 16]> {
    if offset >= bank2.len() { return vec![]; }
    let data = &bank2[offset..];
    if data.is_empty() { return vec![]; }
    let num_tiles = if data[0] == 0 { 256 } else { data[0] as usize };
    // Inline minimal PP1 decompressor (reusing the algorithm from pp1tool)
    pp1_decompress(data, num_tiles)
}

fn pp1_decompress(data: &[u8], num_tiles: usize) -> Vec<[u8; 16]> {
    // Minimal PP1 decompressor — same algorithm as pp1tool
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

/// Known PP1 blocks in bank2 with their offsets and names.
const PP1_BLOCKS: &[(&str, u16)] = &[
    ("hiscorechrs", 0x8B6F - 0x8000),
    ("topchrs",     0x90E9 - 0x8000),
    ("botchrs",     0x997A - 0x8000),
    ("robinchr",    0xA213 - 0x8000),
    ("basechr",     0xAC50 - 0x8000),
    ("beadchr",     0xB152 - 0x8000),
    ("boxchr",      0xB227 - 0x8000),
    ("archchr",     0xB255 - 0x8000),
    ("rockchr",     0xB5EE - 0x8000),
    ("bedchr",      0xBA68 - 0x8000),
    ("doorchr",     0xBC8D - 0x8000),
    ("okchr",       0xBEC7 - 0x8000),
];

/// PP1 block info: source address in bank2, target tile offset.
/// Derived from the compactedchrstable at $F1A8 in bank3.
const CHR_BLOCK_INFO: &[(u16, u16)] = &[
    // (pp1_addr_in_bank2, vram_target)
    // Index 0-4 are special (title screen, hiscore, etc)
    (0x042C, 0x0000),  //  0: title/logo CHR → pattern table 0
    (0x10E9, 0x1000),  //  1: topchrs → pattern table 1 tile 0
    (0x197A, 0x0000),  //  2: botchrs → pattern table 0
    (0x0B6F, 0x1000),  //  3: hiscorechrs → pattern table 1
    (0x0B6F, 0x0000),  //  4: hiscorechrs → pattern table 0
    (0xAC50 - 0x8000, 0x1000),  //  5: basechr → pattern table 1 tile 0
    (0xB152 - 0x8000, 0x19D0),  //  6: beadchr → tile 157 (after basechr)
    (0xB227 - 0x8000, 0x1F70),  //  7: boxchr → tile 247
    (0xB255 - 0x8000, 0x19D0),  //  8: archchr → tile 157 (replaces beadchr area)
    (0xB5EE - 0x8000, 0x19D0),  //  9: rockchr → tile 157
    (0xBA68 - 0x8000, 0x1B40),  // 10: bedchr → tile 180
    (0xBC8D - 0x8000, 0x1B40),  // 11: doorchr → tile 180
];

/// Convert raw 16-byte NES tile to 8x8 pixel array.
fn tile_to_pixels(raw: &[u8; 16]) -> [[u8; 8]; 8] {
    let mut pixels = [[0u8; 8]; 8];
    for row in 0..8 {
        let b0 = raw[row];
        let b1 = raw[row + 8];
        for col in 0..8 {
            let bit = 7 - col;
            pixels[row][col] = ((b0 >> bit) & 1) | (((b1 >> bit) & 1) << 1);
        }
    }
    pixels
}

/// Build the CHR table for a specific map by loading basechr + additional blocks.
/// The chr_config byte indexes into the mapchrsdefs list at $860E in bank0.
fn build_chr_table(bank0: &[u8], bank2: &[u8], chr_config: u8) -> Vec<[[u8; 8]; 8]> {
    let mut chr = vec![[[0u8; 8]; 8]; 512]; // 2 pattern tables

    // Always load basechr (index 5) → VRAM $1000 (tiles 256-412)
    let (base_pp1, base_vram) = CHR_BLOCK_INFO[5];
    let base_tiles = decompress_pp1_tiles(bank2, base_pp1 as usize);
    let base_tile_start = (base_vram / 16) as usize;
    for (i, raw) in base_tiles.iter().enumerate() {
        if base_tile_start + i < 512 {
            chr[base_tile_start + i] = tile_to_pixels(raw);
        }
    }

    // Load additional CHR blocks from the mapchrsdefs list
    let mut list_pos = chr_config as usize;
    loop {
        if 0x60E + list_pos >= bank0.len() { break; }
        let block_idx = bank0[0x60E + list_pos];
        if block_idx & 0x80 != 0 { break; } // $FF terminator (or any negative)
        list_pos += 1;

        let idx = block_idx as usize;
        if idx >= CHR_BLOCK_INFO.len() { continue; }
        let (pp1_addr, vram_addr) = CHR_BLOCK_INFO[idx];
        let tiles = decompress_pp1_tiles(bank2, pp1_addr as usize);
        let tile_start = (vram_addr / 16) as usize;
        for (i, raw) in tiles.iter().enumerate() {
            if tile_start + i < 512 {
                chr[tile_start + i] = tile_to_pixels(raw);
            }
        }
    }

    chr
}

/// Render a map to an image buffer.
fn render_map(
    bank0: &[u8],
    bank2: &[u8],
    map_info: &MapInfo,
    blocks: &BlockDefs,
) -> (u32, u32, Vec<u8>) {
    let chr = build_chr_table(bank0, bank2, map_info.chr_config);
    let palette = read_palette(bank0, map_info.palette_idx);

    // Maps are 14 blocks tall (screen height) × N columns wide (scroll direction)
    let cols = map_info.height as u32;  // "height" field is actually the column count
    let rows = 14u32;                    // always 14 rows (224px = NES screen height minus HUD)
    if cols == 0 { return (0, 0, vec![]); }

    let px_w = (cols * 16) as u32;
    let px_h = (rows * 16) as u32;

    let mut img = vec![0u8; (px_w * px_h * 3) as usize];

    let map_offset = (map_info.data_ptr - 0x8000) as usize;

    for col in 0..cols {
        for row in 0..rows {
            let block_idx = bank0[map_offset + (col * rows + row) as usize] as usize;
            let tiles = [
                blocks.tile_tl[block_idx], blocks.tile_tr[block_idx],
                blocks.tile_bl[block_idx], blocks.tile_br[block_idx],
            ];

            // The sub-palette (0-3) is in bits 3-2 of blksattr
            let attr = blocks.attr[block_idx];
            let pal_group = ((attr >> 2) & 0x03) as usize;

            // Render 4 tiles (2×2) into the image
            for ty in 0..2u32 {
                for tx in 0..2u32 {
                    // Block tile indices reference pattern table 1 ($1000+)
                    // which is tiles 256-511 in our CHR array
                    let tile_idx = 256 + tiles[(ty * 2 + tx) as usize] as usize;
                    if tile_idx >= chr.len() { continue; }
                    let tile = &chr[tile_idx];

                    for py in 0..8u32 {
                        for px_col in 0..8u32 {
                            let pixel = tile[py as usize][px_col as usize] as usize;
                            let color_idx = pal_group * 4 + pixel;
                            let rgb = palette[color_idx & 0x0F];

                            let img_x = col * 16 + tx * 8 + px_col;
                            let img_y = row * 16 + ty * 8 + py;
                            let off = ((img_y * px_w + img_x) * 3) as usize;
                            if off + 2 < img.len() {
                                img[off] = rgb[0];
                                img[off + 1] = rgb[1];
                                img[off + 2] = rgb[2];
                            }
                        }
                    }
                }
            }
        }
    }

    (px_w, px_h, img)
}

fn cmd_list(args: &[String]) {
    if args.len() < 2 {
        eprintln!("Usage: mapview list <bank0.bin> <bank3.bin>");
        std::process::exit(1);
    }
    let bank0 = fs::read(&args[0]).expect("Cannot read bank0");
    let bank3 = fs::read(&args[1]).expect("Cannot read bank3");
    let maps = read_mapinfo(&bank3);

    let names = [
        "Kitchen", "Sky", "Water", "Dungeons", "Sewers",
        "Halls (G)", "Halls (H)", "Bedrooms", "Church (J)",
        "Water2 (K)", "Lava (L)", "Church2 (M)", "Lava2 (N)", "Title"
    ];

    println!("Super Robin Hood — Map List");
    println!("══════════════════════════════════════════════════════════");
    println!("{:<4} {:<16} {:>6} {:>5}  {:>6} {:>6}  {:>5} {:>4}",
        "#", "Name", "Ptr", "Rows", "Cols", "Bytes", "Pal", "CHR");
    println!("{}", "─".repeat(60));
    for (i, map) in maps.iter().enumerate() {
        let name = names.get(i).unwrap_or(&"?");
        let bytes = map.height as u32 * 14;
        if map.data_ptr < 0x8000 { continue; }
        println!("{:<4} {:<16} ${:04X} {:>5}  {:>5}  {:>5}  ${:02X}  ${:02X}",
            i, name, map.data_ptr, map.height, 14, bytes,
            map.palette_idx, map.chr_config);
    }
}

fn cmd_render(args: &[String]) {
    if args.len() < 5 {
        eprintln!("Usage: mapview render <bank0.bin> <bank2.bin> <bank3.bin> <map#> <out.png>");
        std::process::exit(1);
    }
    let bank0 = fs::read(&args[0]).expect("Cannot read bank0");
    let bank2 = fs::read(&args[1]).expect("Cannot read bank2");
    let bank3 = fs::read(&args[2]).expect("Cannot read bank3");
    let map_num: usize = args[3].parse().expect("Invalid map number");
    let out_path = PathBuf::from(&args[4]);

    let maps = read_mapinfo(&bank3);
    if map_num >= maps.len() {
        eprintln!("Map number must be 0–{}", maps.len() - 1);
        std::process::exit(1);
    }

    let blocks = read_blocks(&bank0);
    let map = &maps[map_num];
    let (w, h, pixels) = render_map(&bank0, &bank2, map, &blocks);

    if w == 0 || h == 0 {
        eprintln!("Map {} has no data (0 rows)", map_num);
        std::process::exit(1);
    }

    let mut img = image::RgbImage::new(w, h);
    for y in 0..h {
        for x in 0..w {
            let off = ((y * w + x) * 3) as usize;
            let r = pixels[off];
            let g = pixels[off + 1];
            let b = pixels[off + 2];
            img.put_pixel(x, y, image::Rgb([r, g, b]));
        }
    }
    img.save(&out_path).expect("Cannot save PNG");
    println!("Rendered map {} ({}×{} pixels, {}×14 blocks) → {}",
        map_num, w, h, map.height, out_path.display());
}

fn cmd_render_all(args: &[String]) {
    if args.len() < 4 {
        eprintln!("Usage: mapview render-all <bank0.bin> <bank2.bin> <bank3.bin> <outdir>");
        std::process::exit(1);
    }
    let bank0 = fs::read(&args[0]).expect("Cannot read bank0");
    let bank2 = fs::read(&args[1]).expect("Cannot read bank2");
    let bank3 = fs::read(&args[2]).expect("Cannot read bank3");
    let outdir = PathBuf::from(&args[3]);
    fs::create_dir_all(&outdir).expect("Cannot create output directory");

    let maps = read_mapinfo(&bank3);
    let blocks = read_blocks(&bank0);

    let names = [
        "kitchen", "sky", "water", "dungeons", "sewers",
        "halls_g", "halls_h", "bedrooms", "church_j",
        "water2", "lava", "church2", "lava2", "title"
    ];

    for (i, map) in maps.iter().enumerate() {
        if map.height == 0 || map.data_ptr < 0x8000 { continue; }
        let name = names.get(i).unwrap_or(&"unknown");
        let out_path = outdir.join(format!("{:02}_{}.png", i, name));

        let (w, h, pixels) = render_map(&bank0, &bank2, map, &blocks);
        if w == 0 || h == 0 { continue; }

        let mut img = image::RgbImage::new(w, h);
        for y in 0..h {
            for x in 0..w {
                let off = ((y * w + x) * 3) as usize;
                img.put_pixel(x, y, image::Rgb([pixels[off], pixels[off+1], pixels[off+2]]));
            }
        }
        img.save(&out_path).expect("Cannot save PNG");
        println!("  {} → {} ({}×{})", name, out_path.display(), w, h);
    }
}
