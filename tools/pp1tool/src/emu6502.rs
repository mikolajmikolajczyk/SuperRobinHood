//! Minimal 6502 emulator — just enough to run PP1_UNPACK.
//!
//! Emulates the CPU with a 64K address space. The PP1 code runs in the
//! $F1E0-$F392 range (bank3 fixed bank). We load the PP1 code there
//! and the compressed data at a configurable address. VRAM writes to
//! $2007 are captured.

pub struct Emu {
    pub a: u8,
    pub x: u8,
    pub y: u8,
    pub sp: u8,
    pub pc: u16,
    pub carry: bool,
    pub zero: bool,
    pub negative: bool,
    pub overflow: bool,
    pub mem: Vec<u8>,
    pub vram_writes: Vec<u8>,
    pub cycles: u64,
    pub trace: bool,
}

impl Emu {
    pub fn new() -> Self {
        Self {
            a: 0, x: 0, y: 0, sp: 0xFD,
            pc: 0, carry: false, zero: false, negative: false, overflow: false,
            mem: vec![0; 65536],
            vram_writes: Vec::new(),
            cycles: 0,
            trace: false,
        }
    }

    fn read(&self, addr: u16) -> u8 {
        self.mem[addr as usize]
    }

    fn write(&mut self, addr: u16, val: u8) {
        if addr == 0x2007 {
            self.vram_writes.push(val);
        } else {
            self.mem[addr as usize] = val;
        }
    }

    fn read16(&self, addr: u16) -> u16 {
        let lo = self.read(addr) as u16;
        let hi = self.read(addr.wrapping_add(1)) as u16;
        (hi << 8) | lo
    }

    fn push(&mut self, val: u8) {
        self.write(0x0100 | self.sp as u16, val);
        self.sp = self.sp.wrapping_sub(1);
    }

    fn pull(&mut self) -> u8 {
        self.sp = self.sp.wrapping_add(1);
        self.read(0x0100 | self.sp as u16)
    }

    fn set_nz(&mut self, val: u8) {
        self.zero = val == 0;
        self.negative = val & 0x80 != 0;
    }

    /// Run until RTS at the initial call depth, or max cycles exceeded.
    pub fn run(&mut self, max_cycles: u64) {
        let initial_sp = self.sp;
        loop {
            if self.cycles > max_cycles {
                eprintln!("Exceeded {} cycles, aborting", max_cycles);
                break;
            }
            let opcode = self.read(self.pc);
            self.pc = self.pc.wrapping_add(1);
            self.cycles += 1;

            match opcode {
                0x00 => { // BRK
                    eprintln!("BRK at ${:04X}", self.pc.wrapping_sub(1));
                    break;
                }
                0x06 => { // ASL zp
                    let addr = self.read(self.pc) as u16; self.pc += 1;
                    let val = self.read(addr);
                    self.carry = val & 0x80 != 0;
                    let result = val << 1;
                    self.set_nz(result);
                    self.write(addr, result);
                    if self.trace && addr == 0x33 { // TEMP2
                        eprintln!("  ASL TEMP2: ${:02X}→${:02X} carry={} Z={} @ ${:04X}",
                            val, result, self.carry, self.zero, self.pc.wrapping_sub(2));
                    }
                }
                0x09 => { // ORA #imm
                    let imm = self.read(self.pc); self.pc += 1;
                    self.a |= imm;
                    self.set_nz(self.a);
                }
                0x0A => { // ASL A
                    self.carry = self.a & 0x80 != 0;
                    self.a <<= 1;
                    self.set_nz(self.a);
                }
                0x10 => { // BPL
                    let offset = self.read(self.pc) as i8; self.pc += 1;
                    if !self.negative {
                        self.pc = (self.pc as i32 + offset as i32) as u16;
                    }
                }
                0x18 => { // CLC
                    self.carry = false;
                }
                0x20 => { // JSR
                    let addr = self.read16(self.pc); self.pc += 2;
                    let ret = self.pc.wrapping_sub(1);
                    self.push((ret >> 8) as u8);
                    self.push(ret as u8);
                    self.pc = addr;
                }
                0x26 => { // ROL zp
                    let addr = self.read(self.pc) as u16; self.pc += 1;
                    let val = self.read(addr);
                    let old_carry = self.carry;
                    self.carry = val & 0x80 != 0;
                    let result = (val << 1) | if old_carry { 1 } else { 0 };
                    self.set_nz(result);
                    self.write(addr, result);
                }
                0x29 => { // AND #imm
                    let imm = self.read(self.pc); self.pc += 1;
                    self.a &= imm;
                    self.set_nz(self.a);
                }
                0x2A => { // ROL A
                    let old_carry = self.carry;
                    self.carry = self.a & 0x80 != 0;
                    self.a = (self.a << 1) | if old_carry { 1 } else { 0 };
                    self.set_nz(self.a);
                }
                0x30 => { // BMI
                    let offset = self.read(self.pc) as i8; self.pc += 1;
                    if self.negative {
                        self.pc = (self.pc as i32 + offset as i32) as u16;
                    }
                }
                0x48 => { // PHA
                    self.push(self.a);
                }
                0x4A => { // LSR A
                    self.carry = self.a & 1 != 0;
                    self.a >>= 1;
                    self.set_nz(self.a);
                }
                0x4C => { // JMP abs
                    self.pc = self.read16(self.pc);
                }
                0x60 => { // RTS
                    if self.sp >= initial_sp {
                        // Returned from the initial call
                        let lo = self.pull() as u16;
                        let hi = self.pull() as u16;
                        self.pc = ((hi << 8) | lo).wrapping_add(1);
                        break;
                    }
                    let lo = self.pull() as u16;
                    let hi = self.pull() as u16;
                    self.pc = ((hi << 8) | lo).wrapping_add(1);
                }
                0x68 => { // PLA
                    self.a = self.pull();
                    self.set_nz(self.a);
                }
                0x85 => { // STA zp
                    let addr = self.read(self.pc) as u16; self.pc += 1;
                    self.write(addr, self.a);
                }
                0x86 => { // STX zp
                    let addr = self.read(self.pc) as u16; self.pc += 1;
                    self.write(addr, self.x);
                }
                0x8A => { // TXA
                    self.a = self.x;
                    self.set_nz(self.a);
                }
                0x8D => { // STA abs
                    let addr = self.read16(self.pc); self.pc += 2;
                    self.write(addr, self.a);
                    if addr == 0x2007 && self.vram_writes.len() % 16 == 0 {
                        // Start of new tile - print Y (stream position) and TEMP2
                        let tile_num = self.vram_writes.len() / 16;
                        eprintln!("  TILE {} START: Y={} TEMP2=${:02X} carry={}",
                            tile_num, self.y, self.mem[0x33], self.carry);
                    }
                }
                0x90 => { // BCC
                    let offset = self.read(self.pc) as i8; self.pc += 1;
                    if !self.carry {
                        self.pc = (self.pc as i32 + offset as i32) as u16;
                    }
                }
                0x95 => { // STA zp,X
                    let base = self.read(self.pc); self.pc += 1;
                    let addr = base.wrapping_add(self.x) as u16;
                    self.write(addr, self.a);
                    if self.trace && (0x1F..=0x2E).contains(&addr) {
                        let names = ["types","types","types","types",
                                     "fol1","fol1","fol1","fol1",
                                     "fol2","fol2","fol2","fol2",
                                     "fol3","fol3","fol3","fol3"];
                        let idx = (addr - 0x1F) as usize;
                        let slot = idx % 4;
                        eprintln!("  STA {}[{}] = ${:02X} (={}) @ ${:04X}",
                            names.get(idx).unwrap_or(&"?"), slot, self.a, self.a, self.pc.wrapping_sub(2));
                    }
                }
                0xA0 => { // LDY #imm
                    self.y = self.read(self.pc); self.pc += 1;
                    self.set_nz(self.y);
                }
                0xA2 => { // LDX #imm
                    self.x = self.read(self.pc); self.pc += 1;
                    self.set_nz(self.x);
                }
                0xA5 => { // LDA zp
                    let addr = self.read(self.pc) as u16; self.pc += 1;
                    self.a = self.read(addr);
                    self.set_nz(self.a);
                }
                0xA6 => { // LDX zp
                    let addr = self.read(self.pc) as u16; self.pc += 1;
                    self.x = self.read(addr);
                    self.set_nz(self.x);
                }
                0xA9 => { // LDA #imm
                    self.a = self.read(self.pc); self.pc += 1;
                    self.set_nz(self.a);
                }
                0xAA => { // TAX
                    self.x = self.a;
                    self.set_nz(self.x);
                }
                0xB0 => { // BCS
                    let offset = self.read(self.pc) as i8; self.pc += 1;
                    if self.carry {
                        self.pc = (self.pc as i32 + offset as i32) as u16;
                    }
                }
                0xB1 => { // LDA (zp),Y
                    let zp = self.read(self.pc) as u16; self.pc += 1;
                    let base = self.read16(zp);
                    let addr = base.wrapping_add(self.y as u16);
                    self.a = self.read(addr);
                    self.set_nz(self.a);
                    if self.trace && zp == 0x1D { // ADR1 = data read
                        eprintln!("  LDA (ADR1),Y: addr=${:04X} Y={} byte=${:02X} @ ${:04X}",
                            addr, self.y, self.a, self.pc.wrapping_sub(2));
                    }
                }
                0xB5 => { // LDA zp,X
                    let base = self.read(self.pc); self.pc += 1;
                    let addr = base.wrapping_add(self.x) as u16;
                    self.a = self.read(addr);
                    self.set_nz(self.a);
                }
                0xBD => { // LDA abs,X
                    let base = self.read16(self.pc); self.pc += 2;
                    let addr = base.wrapping_add(self.x as u16);
                    self.a = self.read(addr);
                    self.set_nz(self.a);
                }
                0xC6 => { // DEC zp
                    let addr = self.read(self.pc) as u16; self.pc += 1;
                    let val = self.read(addr).wrapping_sub(1);
                    self.set_nz(val);
                    self.write(addr, val);
                }
                0xC8 => { // INY
                    self.y = self.y.wrapping_add(1);
                    self.set_nz(self.y);
                }
                0xC9 => { // CMP #imm
                    let imm = self.read(self.pc); self.pc += 1;
                    let result = self.a.wrapping_sub(imm);
                    self.carry = self.a >= imm;
                    self.set_nz(result);
                }
                0xCA => { // DEX
                    self.x = self.x.wrapping_sub(1);
                    self.set_nz(self.x);
                }
                0xD0 => { // BNE
                    let offset = self.read(self.pc) as i8; self.pc += 1;
                    if !self.zero {
                        self.pc = (self.pc as i32 + offset as i32) as u16;
                    }
                }
                0xE6 => { // INC zp
                    let addr = self.read(self.pc) as u16; self.pc += 1;
                    let val = self.read(addr).wrapping_add(1);
                    self.set_nz(val);
                    self.write(addr, val);
                }
                0xF0 => { // BEQ
                    let offset = self.read(self.pc) as i8; self.pc += 1;
                    if self.zero {
                        self.pc = (self.pc as i32 + offset as i32) as u16;
                    }
                }
                _ => {
                    eprintln!("Unimplemented opcode ${:02X} at ${:04X}", opcode, self.pc.wrapping_sub(1));
                    break;
                }
            }
        }
    }
}
