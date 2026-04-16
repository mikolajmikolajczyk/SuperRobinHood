use crate::emu6502::Emu;
use crate::pp1;

pub fn debug_decompress(data: &[u8], offset: usize) {
    println!("=== 6502 emulator (ground truth) ===");
    let emu_tiles = emu_decompress(data, offset);
    for (i, tile) in emu_tiles.iter().enumerate() {
        print!("tile {:3}: bp0=", i);
        for b in &tile[..8] { print!("{:02X}", b); }
        print!(" bp1=");
        for b in &tile[8..] { print!("{:02X}", b); }
        println!();
    }

    println!("\n=== Rust PP1 decompressor ===");
    let tiles = pp1::decompress(&data[offset..]);
    for (i, tile) in tiles.iter().enumerate() {
        print!("tile {:3}: bp0=", i);
        for b in &tile[..8] { print!("{:02X}", b); }
        print!(" bp1=");
        for b in &tile[8..] { print!("{:02X}", b); }
        if i < emu_tiles.len() && tile != &emu_tiles[i] {
            print!("  *** WRONG");
        }
        println!();
    }

    let matching = tiles.iter().zip(emu_tiles.iter()).filter(|(a, b)| a == b).count();
    println!("\n{}/{} tiles match", matching, emu_tiles.len());

    // If first mismatch, trace it
    for i in 0..tiles.len().min(emu_tiles.len()) {
        if tiles[i] != emu_tiles[i] {
            println!("\n=== First mismatch at tile {} ===", i);
            println!("Expected: bp0={} bp1={}",
                emu_tiles[i][..8].iter().map(|b| format!("{:02X}", b)).collect::<String>(),
                emu_tiles[i][8..].iter().map(|b| format!("{:02X}", b)).collect::<String>());
            println!("Got:      bp0={} bp1={}",
                tiles[i][..8].iter().map(|b| format!("{:02X}", b)).collect::<String>(),
                tiles[i][8..].iter().map(|b| format!("{:02X}", b)).collect::<String>());
            // Trace up to the mismatching tile
            break;
        }
    }
}

fn emu_decompress(bank2_data: &[u8], offset: usize) -> Vec<[u8; 16]> {
    let bank3_path = "disasm/banks/bank3.bin";
    let bank3 = match std::fs::read(bank3_path) {
        Ok(d) => d,
        Err(e) => {
            eprintln!("Cannot read {}: {} (run from repo root)", bank3_path, e);
            return vec![];
        }
    };

    let mut emu = Emu::new();
    for (i, &b) in bank3.iter().enumerate() {
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
