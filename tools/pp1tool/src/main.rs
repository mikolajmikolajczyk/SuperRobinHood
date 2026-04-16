mod pp1;
mod debug;
mod emu6502;

use std::fs;
use std::path::PathBuf;

/// NES greyscale palette for tile visualization.
const PALETTE: [[u8; 3]; 4] = [
    [0x00, 0x00, 0x00], // colour 0: black
    [0x6d, 0x6d, 0x6d], // colour 1: dark grey
    [0xb2, 0xb2, 0xb2], // colour 2: light grey
    [0xff, 0xff, 0xff], // colour 3: white
];

fn main() {
    let args: Vec<String> = std::env::args().collect();

    match args.get(1).map(|s| s.as_str()) {
        Some("decompress") => cmd_decompress(&args[2..]),
        Some("compress") => cmd_compress(&args[2..]),
        Some("roundtrip") => cmd_roundtrip(&args[2..]),
        Some("view") => cmd_view(&args[2..]),
        Some("info") => cmd_info(&args[2..]),
        Some("dump-all") => cmd_dump_all(&args[2..]),
        Some("dump-all-emu") => cmd_dump_all_emu(&args[2..]),
        Some("debug") => {
            let data = fs::read(&args[2]).expect("Cannot read");
            let offset = parse_offset(&args[3]);
            debug::debug_decompress(&data, offset);
        }
        _ => {
            eprintln!("PP1 Tool — NES CHR tile compressor/decompressor");
            eprintln!();
            eprintln!("Usage:");
            eprintln!("  pp1tool info <bank2.bin>              Show all PP1 blocks in bank2");
            eprintln!("  pp1tool view <bank2.bin> <offset> <out.png>  Decompress and render one block");
            eprintln!("  pp1tool decompress <bank2.bin> <offset> <out.chr>  Decompress to raw CHR");
            eprintln!("  pp1tool compress <input.chr> <out.pp1>  Compress raw CHR to PP1");
            eprintln!("  pp1tool roundtrip <bank2.bin> <offset>  Decompress then recompress, verify match");
            eprintln!("  pp1tool dump-all <bank2.bin> <outdir>  Decompress all known blocks to PNGs");
            std::process::exit(1);
        }
    }
}

/// Known PP1 blocks in bank2 (addresses relative to bank start at $8000).
const PP1_BLOCKS: &[(&str, u16)] = &[
    ("hiscorechrs", 0x8B6F - 0x8000),
    ("topchrs", 0x90E9 - 0x8000),
    ("botchrs", 0x997A - 0x8000),
    ("robinchr", 0xA213 - 0x8000),
    ("basechr", 0xAC50 - 0x8000),
    ("beadchr", 0xB152 - 0x8000),
    ("boxchr", 0xB227 - 0x8000),
    ("archchr", 0xB255 - 0x8000),
    ("rockchr", 0xB5EE - 0x8000),
    ("bedchr", 0xBA68 - 0x8000),
    ("doorchr", 0xBC8D - 0x8000),
    ("okchr", 0xBEC7 - 0x8000),
];

fn cmd_compress(args: &[String]) {
    if args.len() < 2 {
        eprintln!("Usage: pp1tool compress <input.chr> <out.pp1>");
        std::process::exit(1);
    }
    let raw = fs::read(&args[0]).expect("Cannot read input CHR");
    if raw.len() % 16 != 0 {
        eprintln!("Input size {} is not a multiple of 16 bytes", raw.len());
        std::process::exit(1);
    }
    let tiles: Vec<[u8; 16]> = raw.chunks_exact(16)
        .map(|c| { let mut t = [0u8; 16]; t.copy_from_slice(c); t })
        .collect();
    let compressed = pp1::compress(&tiles);
    let out_path = PathBuf::from(&args[1]);
    fs::write(&out_path, &compressed).expect("Cannot write output");
    println!(
        "Compressed {} tiles ({} bytes) -> {} bytes (ratio {:.1}%)",
        tiles.len(),
        raw.len(),
        compressed.len(),
        compressed.len() as f64 / raw.len() as f64 * 100.0,
    );
}

fn cmd_roundtrip(args: &[String]) {
    if args.len() < 2 {
        eprintln!("Usage: pp1tool roundtrip <bank2.bin> <offset>");
        eprintln!("       pp1tool roundtrip --all <bank2.bin>");
        std::process::exit(1);
    }

    if args[0] == "--all" {
        let data = fs::read(&args[1]).expect("Cannot read bank file");
        let mut pass = 0;
        let mut fail = 0;
        for (name, offset) in PP1_BLOCKS {
            let off = *offset as usize;
            if off >= data.len() { continue; }
            let tiles = pp1::decompress(&data[off..]);
            let compressed = pp1::compress(&tiles);
            let tiles2 = pp1::decompress(&compressed);
            if tiles == tiles2 {
                let orig_size = tiles.len() * 16;
                println!(
                    "  OK  {:<20} {} tiles, orig CHR {} bytes, recompressed {} bytes ({:.1}%)",
                    name, tiles.len(), orig_size, compressed.len(),
                    compressed.len() as f64 / orig_size as f64 * 100.0,
                );
                pass += 1;
            } else {
                eprintln!("  FAIL {:<20} roundtrip mismatch!", name);
                fail += 1;
            }
        }
        println!("\n{} passed, {} failed", pass, fail);
        if fail > 0 { std::process::exit(1); }
        return;
    }

    let data = fs::read(&args[0]).expect("Cannot read bank file");
    let offset = parse_offset(&args[1]);
    let tiles = pp1::decompress(&data[offset..]);
    let compressed = pp1::compress(&tiles);
    let tiles2 = pp1::decompress(&compressed);
    if tiles == tiles2 {
        let orig_size = tiles.len() * 16;
        println!(
            "Roundtrip OK: {} tiles, orig CHR {} bytes, recompressed {} bytes ({:.1}%)",
            tiles.len(), orig_size, compressed.len(),
            compressed.len() as f64 / orig_size as f64 * 100.0,
        );
    } else {
        eprintln!("Roundtrip FAILED: decompressed tiles don't match!");
        for (i, (a, b)) in tiles.iter().zip(tiles2.iter()).enumerate() {
            if a != b {
                eprintln!("  First mismatch at tile {}", i);
                eprintln!("    original:     {:02X?}", a);
                eprintln!("    recompressed: {:02X?}", b);
                break;
            }
        }
        std::process::exit(1);
    }
}

fn cmd_info(args: &[String]) {
    if args.is_empty() {
        eprintln!("Usage: pp1tool info <bank2.bin>");
        std::process::exit(1);
    }
    let data = fs::read(&args[0]).expect("Cannot read bank file");

    println!("PP1 blocks in bank2:");
    println!("{:<20} {:>6} {:>6} {:>6}", "Name", "Offset", "Addr", "Tiles");
    println!("{}", "-".repeat(50));

    for (name, offset) in PP1_BLOCKS {
        let off = *offset as usize;
        if off < data.len() {
            let num_tiles = data[off] as usize;
            println!(
                "{:<20} 0x{:04X} ${:04X} {:>5}",
                name,
                off,
                off + 0x8000,
                num_tiles
            );
        }
    }
}

fn cmd_decompress(args: &[String]) {
    if args.len() < 3 {
        eprintln!("Usage: pp1tool decompress <bank2.bin> <offset_hex> <out.chr>");
        std::process::exit(1);
    }
    let data = fs::read(&args[0]).expect("Cannot read bank file");
    let offset = parse_offset(&args[1]);
    let out_path = PathBuf::from(&args[2]);

    let tiles = pp1::decompress(&data[offset..]);
    let mut raw = Vec::with_capacity(tiles.len() * 16);
    for tile in &tiles {
        raw.extend_from_slice(tile);
    }
    fs::write(&out_path, &raw).expect("Cannot write output");
    println!(
        "Decompressed {} tiles ({} bytes) to {}",
        tiles.len(),
        raw.len(),
        out_path.display()
    );
}

fn cmd_view(args: &[String]) {
    if args.len() < 3 {
        eprintln!("Usage: pp1tool view <bank2.bin> <offset_hex> <out.png>");
        std::process::exit(1);
    }
    let data = fs::read(&args[0]).expect("Cannot read bank file");
    let offset = parse_offset(&args[1]);
    let out_path = PathBuf::from(&args[2]);

    let tiles = pp1::decompress(&data[offset..]);
    save_tiles_as_png(&tiles, &out_path);
    println!(
        "Rendered {} tiles to {}",
        tiles.len(),
        out_path.display()
    );
}

fn cmd_dump_all(args: &[String]) {
    if args.len() < 2 {
        eprintln!("Usage: pp1tool dump-all <bank2.bin> <outdir>");
        std::process::exit(1);
    }
    let data = fs::read(&args[0]).expect("Cannot read bank file");
    let outdir = PathBuf::from(&args[1]);
    fs::create_dir_all(&outdir).expect("Cannot create output directory");

    for (name, offset) in PP1_BLOCKS {
        let off = *offset as usize;
        if off >= data.len() {
            eprintln!("Warning: {} offset 0x{:04X} out of range", name, off);
            continue;
        }
        let tiles = pp1::decompress(&data[off..]);
        let out_path = outdir.join(format!("{}.png", name));
        save_tiles_as_png(&tiles, &out_path);
        println!("{}: {} tiles -> {}", name, tiles.len(), out_path.display());
    }
}

fn cmd_dump_all_emu(args: &[String]) {
    if args.len() < 2 {
        eprintln!("Usage: pp1tool dump-all-emu <bank2.bin> <outdir>");
        eprintln!("Requires disasm/banks/bank3.bin for the PP1 code (run from repo root)");
        std::process::exit(1);
    }
    let bank2_data = fs::read(&args[0]).expect("Cannot read bank2 file");
    let bank3_data = fs::read("disasm/banks/bank3.bin").expect("Cannot read bank3.bin");
    let outdir = PathBuf::from(&args[1]);
    fs::create_dir_all(&outdir).expect("Cannot create output directory");

    for (name, offset) in PP1_BLOCKS {
        let off = *offset as usize;
        if off >= bank2_data.len() {
            continue;
        }
        let tiles = emu_decompress_block(&bank2_data, &bank3_data, off);
        let out_path = outdir.join(format!("{}.png", name));
        save_tiles_as_png(&tiles, &out_path);
        println!("{}: {} tiles -> {}", name, tiles.len(), out_path.display());
    }
}

fn emu_decompress_block(bank2_data: &[u8], bank3_data: &[u8], offset: usize) -> Vec<[u8; 16]> {
    let mut emu = emu6502::Emu::new();

    for (i, &b) in bank3_data.iter().enumerate() {
        emu.mem[0xC000 + i] = b;
    }

    let data_addr: u16 = 0x4000;
    for (i, &b) in bank2_data[offset..].iter().enumerate() {
        if (data_addr as usize) + i >= 0xC000 { break; }
        emu.mem[(data_addr as usize) + i] = b;
    }

    emu.mem[0x1D] = (data_addr & 0xFF) as u8;
    emu.mem[0x1E] = (data_addr >> 8) as u8;
    emu.pc = 0xF23B;
    emu.y = 0;

    emu.run(100_000_000);

    let mut tiles = Vec::new();
    let mut pos = 0;
    while pos + 16 <= emu.vram_writes.len() {
        let mut tile = [0u8; 16];
        tile.copy_from_slice(&emu.vram_writes[pos..pos + 16]);
        tiles.push(tile);
        pos += 16;
    }
    tiles
}

fn save_tiles_as_png(tiles: &[[u8; 16]], path: &PathBuf) {
    let (width, height, pixels) = pp1::tiles_to_pixels(tiles);
    let mut img = image::RgbImage::new(width as u32, height as u32);

    for y in 0..height {
        for x in 0..width {
            let pixel = pixels[y * width + x] as usize;
            let [r, g, b] = PALETTE[pixel & 3];
            img.put_pixel(x as u32, y as u32, image::Rgb([r, g, b]));
        }
    }

    img.save(path).expect("Cannot save PNG");
}

fn parse_offset(s: &str) -> usize {
    let s = s.trim_start_matches("0x").trim_start_matches("0X").trim_start_matches('$');
    usize::from_str_radix(s, 16).expect("Invalid hex offset")
}
