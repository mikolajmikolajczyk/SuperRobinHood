//! Complete 6502 CPU emulator — all standard opcodes.
//!
//! Emulates the CPU with a 64K address space. No special I/O handling;
//! writes go directly to mem (the sprite renderer uses OAM at $0200).

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
    pub interrupt_disable: bool,
    pub decimal: bool,
    pub mem: Vec<u8>,
    pub cycles: u64,
}

impl Emu {
    pub fn new() -> Self {
        Self {
            a: 0, x: 0, y: 0, sp: 0xFD,
            pc: 0, carry: false, zero: false, negative: false, overflow: false,
            interrupt_disable: true, decimal: false,
            mem: vec![0; 65536],
            cycles: 0,
        }
    }

    fn read(&self, addr: u16) -> u8 {
        self.mem[addr as usize]
    }

    pub fn write(&mut self, addr: u16, val: u8) {
        self.mem[addr as usize] = val;
    }

    fn read16(&self, addr: u16) -> u16 {
        let lo = self.read(addr) as u16;
        let hi = self.read(addr.wrapping_add(1)) as u16;
        (hi << 8) | lo
    }

    /// Read 16-bit with page-wrapping bug (for JMP indirect).
    fn read16_wrap(&self, addr: u16) -> u16 {
        let lo = self.read(addr) as u16;
        // High byte wraps within the same page
        let hi_addr = (addr & 0xFF00) | ((addr.wrapping_add(1)) & 0x00FF);
        let hi = self.read(hi_addr) as u16;
        (hi << 8) | lo
    }

    fn push(&mut self, val: u8) {
        self.write(0x0100 | self.sp as u16, val);
        self.sp = self.sp.wrapping_sub(1);
    }

    fn push16(&mut self, val: u16) {
        self.push((val >> 8) as u8);
        self.push(val as u8);
    }

    fn pull(&mut self) -> u8 {
        self.sp = self.sp.wrapping_add(1);
        self.read(0x0100 | self.sp as u16)
    }

    fn pull16(&mut self) -> u16 {
        let lo = self.pull() as u16;
        let hi = self.pull() as u16;
        (hi << 8) | lo
    }

    fn set_nz(&mut self, val: u8) {
        self.zero = val == 0;
        self.negative = val & 0x80 != 0;
    }

    fn flags_to_u8(&self, brk_bit: bool) -> u8 {
        let mut p: u8 = 0x20; // bit 5 always set
        if self.carry { p |= 0x01; }
        if self.zero { p |= 0x02; }
        if self.interrupt_disable { p |= 0x04; }
        if self.decimal { p |= 0x08; }
        if brk_bit { p |= 0x10; }
        if self.overflow { p |= 0x40; }
        if self.negative { p |= 0x80; }
        p
    }

    fn set_flags_from_u8(&mut self, p: u8) {
        self.carry = p & 0x01 != 0;
        self.zero = p & 0x02 != 0;
        self.interrupt_disable = p & 0x04 != 0;
        self.decimal = p & 0x08 != 0;
        self.overflow = p & 0x40 != 0;
        self.negative = p & 0x80 != 0;
    }

    // --- Addressing mode helpers (return effective address) ---

    fn addr_zp(&mut self) -> u16 {
        let a = self.read(self.pc) as u16;
        self.pc += 1;
        a
    }

    fn addr_zpx(&mut self) -> u16 {
        let base = self.read(self.pc);
        self.pc += 1;
        base.wrapping_add(self.x) as u16
    }

    fn addr_zpy(&mut self) -> u16 {
        let base = self.read(self.pc);
        self.pc += 1;
        base.wrapping_add(self.y) as u16
    }

    fn addr_abs(&mut self) -> u16 {
        let a = self.read16(self.pc);
        self.pc += 2;
        a
    }

    fn addr_absx(&mut self) -> u16 {
        let base = self.read16(self.pc);
        self.pc += 2;
        base.wrapping_add(self.x as u16)
    }

    fn addr_absy(&mut self) -> u16 {
        let base = self.read16(self.pc);
        self.pc += 2;
        base.wrapping_add(self.y as u16)
    }

    fn addr_indx(&mut self) -> u16 {
        let base = self.read(self.pc);
        self.pc += 1;
        let ptr = base.wrapping_add(self.x);
        let lo = self.read(ptr as u16) as u16;
        let hi = self.read(ptr.wrapping_add(1) as u16) as u16;
        (hi << 8) | lo
    }

    fn addr_indy(&mut self) -> u16 {
        let zp = self.read(self.pc);
        self.pc += 1;
        let lo = self.read(zp as u16) as u16;
        let hi = self.read(zp.wrapping_add(1) as u16) as u16;
        let base = (hi << 8) | lo;
        base.wrapping_add(self.y as u16)
    }

    fn imm(&mut self) -> u8 {
        let v = self.read(self.pc);
        self.pc += 1;
        v
    }

    fn branch(&mut self, cond: bool) {
        let offset = self.read(self.pc) as i8;
        self.pc += 1;
        if cond {
            self.pc = (self.pc as i32 + offset as i32) as u16;
        }
    }

    // --- ALU operations ---

    fn op_adc(&mut self, val: u8) {
        let a = self.a as u16;
        let v = val as u16;
        let c = if self.carry { 1u16 } else { 0 };
        let sum = a + v + c;
        let result = sum as u8;
        self.carry = sum > 0xFF;
        self.overflow = ((a ^ sum) & (v ^ sum) & 0x80) != 0;
        self.a = result;
        self.set_nz(result);
    }

    fn op_sbc(&mut self, val: u8) {
        // SBC is equivalent to ADC with complement
        self.op_adc(!val);
    }

    fn op_cmp(&mut self, reg: u8, val: u8) {
        let result = reg.wrapping_sub(val);
        self.carry = reg >= val;
        self.set_nz(result);
    }

    fn op_asl_mem(&mut self, addr: u16) {
        let val = self.read(addr);
        self.carry = val & 0x80 != 0;
        let result = val << 1;
        self.set_nz(result);
        self.write(addr, result);
    }

    fn op_lsr_mem(&mut self, addr: u16) {
        let val = self.read(addr);
        self.carry = val & 0x01 != 0;
        let result = val >> 1;
        self.set_nz(result);
        self.write(addr, result);
    }

    fn op_rol_mem(&mut self, addr: u16) {
        let val = self.read(addr);
        let old_carry = self.carry;
        self.carry = val & 0x80 != 0;
        let result = (val << 1) | if old_carry { 1 } else { 0 };
        self.set_nz(result);
        self.write(addr, result);
    }

    fn op_ror_mem(&mut self, addr: u16) {
        let val = self.read(addr);
        let old_carry = self.carry;
        self.carry = val & 0x01 != 0;
        let result = (val >> 1) | if old_carry { 0x80 } else { 0 };
        self.set_nz(result);
        self.write(addr, result);
    }

    fn op_inc(&mut self, addr: u16) {
        let val = self.read(addr).wrapping_add(1);
        self.set_nz(val);
        self.write(addr, val);
    }

    fn op_dec(&mut self, addr: u16) {
        let val = self.read(addr).wrapping_sub(1);
        self.set_nz(val);
        self.write(addr, val);
    }

    fn op_bit(&mut self, val: u8) {
        self.zero = (self.a & val) == 0;
        self.overflow = val & 0x40 != 0;
        self.negative = val & 0x80 != 0;
    }

    /// Run until BRK or max_cycles exceeded.
    pub fn run(&mut self, max_cycles: u64) {
        loop {
            if self.cycles > max_cycles {
                eprintln!("Exceeded {} cycles, aborting", max_cycles);
                break;
            }
            let opcode = self.read(self.pc);
            self.pc = self.pc.wrapping_add(1);
            self.cycles += 1;

            match opcode {
                // === BRK ===
                0x00 => {
                    break;
                }

                // === ORA ===
                0x09 => { let v = self.imm();       self.a |= v; self.set_nz(self.a); }
                0x05 => { let a = self.addr_zp();    self.a |= self.read(a); self.set_nz(self.a); }
                0x15 => { let a = self.addr_zpx();   self.a |= self.read(a); self.set_nz(self.a); }
                0x0D => { let a = self.addr_abs();   self.a |= self.read(a); self.set_nz(self.a); }
                0x1D => { let a = self.addr_absx();  self.a |= self.read(a); self.set_nz(self.a); }
                0x19 => { let a = self.addr_absy();  self.a |= self.read(a); self.set_nz(self.a); }
                0x01 => { let a = self.addr_indx();  self.a |= self.read(a); self.set_nz(self.a); }
                0x11 => { let a = self.addr_indy();  self.a |= self.read(a); self.set_nz(self.a); }

                // === AND ===
                0x29 => { let v = self.imm();       self.a &= v; self.set_nz(self.a); }
                0x25 => { let a = self.addr_zp();    self.a &= self.read(a); self.set_nz(self.a); }
                0x35 => { let a = self.addr_zpx();   self.a &= self.read(a); self.set_nz(self.a); }
                0x2D => { let a = self.addr_abs();   self.a &= self.read(a); self.set_nz(self.a); }
                0x3D => { let a = self.addr_absx();  self.a &= self.read(a); self.set_nz(self.a); }
                0x39 => { let a = self.addr_absy();  self.a &= self.read(a); self.set_nz(self.a); }
                0x21 => { let a = self.addr_indx();  self.a &= self.read(a); self.set_nz(self.a); }
                0x31 => { let a = self.addr_indy();  self.a &= self.read(a); self.set_nz(self.a); }

                // === EOR ===
                0x49 => { let v = self.imm();       self.a ^= v; self.set_nz(self.a); }
                0x45 => { let a = self.addr_zp();    self.a ^= self.read(a); self.set_nz(self.a); }
                0x55 => { let a = self.addr_zpx();   self.a ^= self.read(a); self.set_nz(self.a); }
                0x4D => { let a = self.addr_abs();   self.a ^= self.read(a); self.set_nz(self.a); }
                0x5D => { let a = self.addr_absx();  self.a ^= self.read(a); self.set_nz(self.a); }
                0x59 => { let a = self.addr_absy();  self.a ^= self.read(a); self.set_nz(self.a); }
                0x41 => { let a = self.addr_indx();  self.a ^= self.read(a); self.set_nz(self.a); }
                0x51 => { let a = self.addr_indy();  self.a ^= self.read(a); self.set_nz(self.a); }

                // === ADC ===
                0x69 => { let v = self.imm();       self.op_adc(v); }
                0x65 => { let a = self.addr_zp();    let v = self.read(a); self.op_adc(v); }
                0x75 => { let a = self.addr_zpx();   let v = self.read(a); self.op_adc(v); }
                0x6D => { let a = self.addr_abs();   let v = self.read(a); self.op_adc(v); }
                0x7D => { let a = self.addr_absx();  let v = self.read(a); self.op_adc(v); }
                0x79 => { let a = self.addr_absy();  let v = self.read(a); self.op_adc(v); }
                0x61 => { let a = self.addr_indx();  let v = self.read(a); self.op_adc(v); }
                0x71 => { let a = self.addr_indy();  let v = self.read(a); self.op_adc(v); }

                // === SBC ===
                0xE9 => { let v = self.imm();       self.op_sbc(v); }
                0xE5 => { let a = self.addr_zp();    let v = self.read(a); self.op_sbc(v); }
                0xF5 => { let a = self.addr_zpx();   let v = self.read(a); self.op_sbc(v); }
                0xED => { let a = self.addr_abs();   let v = self.read(a); self.op_sbc(v); }
                0xFD => { let a = self.addr_absx();  let v = self.read(a); self.op_sbc(v); }
                0xF9 => { let a = self.addr_absy();  let v = self.read(a); self.op_sbc(v); }
                0xE1 => { let a = self.addr_indx();  let v = self.read(a); self.op_sbc(v); }
                0xF1 => { let a = self.addr_indy();  let v = self.read(a); self.op_sbc(v); }

                // === CMP ===
                0xC9 => { let v = self.imm();       let r = self.a; self.op_cmp(r, v); }
                0xC5 => { let a = self.addr_zp();    let v = self.read(a); let r = self.a; self.op_cmp(r, v); }
                0xD5 => { let a = self.addr_zpx();   let v = self.read(a); let r = self.a; self.op_cmp(r, v); }
                0xCD => { let a = self.addr_abs();   let v = self.read(a); let r = self.a; self.op_cmp(r, v); }
                0xDD => { let a = self.addr_absx();  let v = self.read(a); let r = self.a; self.op_cmp(r, v); }
                0xD9 => { let a = self.addr_absy();  let v = self.read(a); let r = self.a; self.op_cmp(r, v); }
                0xC1 => { let a = self.addr_indx();  let v = self.read(a); let r = self.a; self.op_cmp(r, v); }
                0xD1 => { let a = self.addr_indy();  let v = self.read(a); let r = self.a; self.op_cmp(r, v); }

                // === CPX ===
                0xE0 => { let v = self.imm();       let r = self.x; self.op_cmp(r, v); }
                0xE4 => { let a = self.addr_zp();    let v = self.read(a); let r = self.x; self.op_cmp(r, v); }
                0xEC => { let a = self.addr_abs();   let v = self.read(a); let r = self.x; self.op_cmp(r, v); }

                // === CPY ===
                0xC0 => { let v = self.imm();       let r = self.y; self.op_cmp(r, v); }
                0xC4 => { let a = self.addr_zp();    let v = self.read(a); let r = self.y; self.op_cmp(r, v); }
                0xCC => { let a = self.addr_abs();   let v = self.read(a); let r = self.y; self.op_cmp(r, v); }

                // === BIT ===
                0x24 => { let a = self.addr_zp();   let v = self.read(a); self.op_bit(v); }
                0x2C => { let a = self.addr_abs();   let v = self.read(a); self.op_bit(v); }

                // === LDA ===
                0xA9 => { self.a = self.imm();       self.set_nz(self.a); }
                0xA5 => { let a = self.addr_zp();    self.a = self.read(a); self.set_nz(self.a); }
                0xB5 => { let a = self.addr_zpx();   self.a = self.read(a); self.set_nz(self.a); }
                0xAD => { let a = self.addr_abs();   self.a = self.read(a); self.set_nz(self.a); }
                0xBD => { let a = self.addr_absx();  self.a = self.read(a); self.set_nz(self.a); }
                0xB9 => { let a = self.addr_absy();  self.a = self.read(a); self.set_nz(self.a); }
                0xA1 => { let a = self.addr_indx();  self.a = self.read(a); self.set_nz(self.a); }
                0xB1 => { let a = self.addr_indy();  self.a = self.read(a); self.set_nz(self.a); }

                // === LDX ===
                0xA2 => { self.x = self.imm();       self.set_nz(self.x); }
                0xA6 => { let a = self.addr_zp();    self.x = self.read(a); self.set_nz(self.x); }
                0xB6 => { let a = self.addr_zpy();   self.x = self.read(a); self.set_nz(self.x); }
                0xAE => { let a = self.addr_abs();   self.x = self.read(a); self.set_nz(self.x); }
                0xBE => { let a = self.addr_absy();  self.x = self.read(a); self.set_nz(self.x); }

                // === LDY ===
                0xA0 => { self.y = self.imm();       self.set_nz(self.y); }
                0xA4 => { let a = self.addr_zp();    self.y = self.read(a); self.set_nz(self.y); }
                0xB4 => { let a = self.addr_zpx();   self.y = self.read(a); self.set_nz(self.y); }
                0xAC => { let a = self.addr_abs();   self.y = self.read(a); self.set_nz(self.y); }
                0xBC => { let a = self.addr_absx();  self.y = self.read(a); self.set_nz(self.y); }

                // === STA ===
                0x85 => { let a = self.addr_zp();    self.write(a, self.a); }
                0x95 => { let a = self.addr_zpx();   self.write(a, self.a); }
                0x8D => { let a = self.addr_abs();   self.write(a, self.a); }
                0x9D => { let a = self.addr_absx();  self.write(a, self.a); }
                0x99 => { let a = self.addr_absy();  self.write(a, self.a); }
                0x81 => { let a = self.addr_indx();  self.write(a, self.a); }
                0x91 => { let a = self.addr_indy();  self.write(a, self.a); }

                // === STX ===
                0x86 => { let a = self.addr_zp();    self.write(a, self.x); }
                0x96 => { let a = self.addr_zpy();   self.write(a, self.x); }
                0x8E => { let a = self.addr_abs();   self.write(a, self.x); }

                // === STY ===
                0x84 => { let a = self.addr_zp();    self.write(a, self.y); }
                0x94 => { let a = self.addr_zpx();   self.write(a, self.y); }
                0x8C => { let a = self.addr_abs();   self.write(a, self.y); }

                // === Transfers ===
                0xAA => { self.x = self.a;  self.set_nz(self.x); } // TAX
                0xA8 => { self.y = self.a;  self.set_nz(self.y); } // TAY
                0x8A => { self.a = self.x;  self.set_nz(self.a); } // TXA
                0x98 => { self.a = self.y;  self.set_nz(self.a); } // TYA
                0xBA => { self.x = self.sp; self.set_nz(self.x); } // TSX
                0x9A => { self.sp = self.x;                       } // TXS

                // === ASL ===
                0x0A => { // ASL A
                    self.carry = self.a & 0x80 != 0;
                    self.a <<= 1;
                    self.set_nz(self.a);
                }
                0x06 => { let a = self.addr_zp();   self.op_asl_mem(a); }
                0x16 => { let a = self.addr_zpx();  self.op_asl_mem(a); }
                0x0E => { let a = self.addr_abs();  self.op_asl_mem(a); }
                0x1E => { let a = self.addr_absx(); self.op_asl_mem(a); }

                // === LSR ===
                0x4A => { // LSR A
                    self.carry = self.a & 0x01 != 0;
                    self.a >>= 1;
                    self.set_nz(self.a);
                }
                0x46 => { let a = self.addr_zp();   self.op_lsr_mem(a); }
                0x56 => { let a = self.addr_zpx();  self.op_lsr_mem(a); }
                0x4E => { let a = self.addr_abs();  self.op_lsr_mem(a); }
                0x5E => { let a = self.addr_absx(); self.op_lsr_mem(a); }

                // === ROL ===
                0x2A => { // ROL A
                    let old_carry = self.carry;
                    self.carry = self.a & 0x80 != 0;
                    self.a = (self.a << 1) | if old_carry { 1 } else { 0 };
                    self.set_nz(self.a);
                }
                0x26 => { let a = self.addr_zp();   self.op_rol_mem(a); }
                0x36 => { let a = self.addr_zpx();  self.op_rol_mem(a); }
                0x2E => { let a = self.addr_abs();  self.op_rol_mem(a); }
                0x3E => { let a = self.addr_absx(); self.op_rol_mem(a); }

                // === ROR ===
                0x6A => { // ROR A
                    let old_carry = self.carry;
                    self.carry = self.a & 0x01 != 0;
                    self.a = (self.a >> 1) | if old_carry { 0x80 } else { 0 };
                    self.set_nz(self.a);
                }
                0x66 => { let a = self.addr_zp();   self.op_ror_mem(a); }
                0x76 => { let a = self.addr_zpx();  self.op_ror_mem(a); }
                0x6E => { let a = self.addr_abs();  self.op_ror_mem(a); }
                0x7E => { let a = self.addr_absx(); self.op_ror_mem(a); }

                // === INC ===
                0xE6 => { let a = self.addr_zp();   self.op_inc(a); }
                0xF6 => { let a = self.addr_zpx();  self.op_inc(a); }
                0xEE => { let a = self.addr_abs();  self.op_inc(a); }
                0xFE => { let a = self.addr_absx(); self.op_inc(a); }

                // === DEC ===
                0xC6 => { let a = self.addr_zp();   self.op_dec(a); }
                0xD6 => { let a = self.addr_zpx();  self.op_dec(a); }
                0xCE => { let a = self.addr_abs();  self.op_dec(a); }
                0xDE => { let a = self.addr_absx(); self.op_dec(a); }

                // === INX, INY, DEX, DEY ===
                0xE8 => { self.x = self.x.wrapping_add(1); self.set_nz(self.x); } // INX
                0xC8 => { self.y = self.y.wrapping_add(1); self.set_nz(self.y); } // INY
                0xCA => { self.x = self.x.wrapping_sub(1); self.set_nz(self.x); } // DEX
                0x88 => { self.y = self.y.wrapping_sub(1); self.set_nz(self.y); } // DEY

                // === Branches ===
                0x10 => { let c = !self.negative;  self.branch(c); } // BPL
                0x30 => { let c = self.negative;   self.branch(c); }  // BMI
                0x50 => { let c = !self.overflow;  self.branch(c); } // BVC
                0x70 => { let c = self.overflow;   self.branch(c); }  // BVS
                0x90 => { let c = !self.carry;     self.branch(c); } // BCC
                0xB0 => { let c = self.carry;      self.branch(c); }  // BCS
                0xD0 => { let c = !self.zero;      self.branch(c); } // BNE
                0xF0 => { let c = self.zero;       self.branch(c); }  // BEQ

                // === JMP ===
                0x4C => { // JMP abs
                    self.pc = self.read16(self.pc);
                }
                0x6C => { // JMP (indirect) — with page-boundary bug
                    let ptr = self.read16(self.pc);
                    self.pc = self.read16_wrap(ptr);
                }

                // === JSR / RTS / RTI ===
                0x20 => { // JSR
                    let addr = self.read16(self.pc);
                    self.pc += 2;
                    let ret = self.pc.wrapping_sub(1);
                    self.push16(ret);
                    self.pc = addr;
                }
                0x60 => { // RTS
                    let addr = self.pull16();
                    self.pc = addr.wrapping_add(1);
                }
                0x40 => { // RTI
                    let p = self.pull();
                    self.set_flags_from_u8(p);
                    self.pc = self.pull16();
                }

                // === Stack ===
                0x48 => { let v = self.a; self.push(v); }                        // PHA
                0x68 => { self.a = self.pull(); self.set_nz(self.a); }           // PLA
                0x08 => { let p = self.flags_to_u8(true); self.push(p); }        // PHP
                0x28 => { let p = self.pull(); self.set_flags_from_u8(p); }      // PLP

                // === Flags ===
                0x18 => { self.carry = false; }             // CLC
                0x38 => { self.carry = true; }              // SEC
                0xD8 => { self.decimal = false; }           // CLD
                0xF8 => { self.decimal = true; }            // SED
                0x58 => { self.interrupt_disable = false; }  // CLI
                0x78 => { self.interrupt_disable = true; }   // SEI
                0xB8 => { self.overflow = false; }           // CLV

                // === NOP ===
                0xEA => {}

                _ => {
                    eprintln!("Unimplemented opcode ${:02X} at ${:04X}", opcode, self.pc.wrapping_sub(1));
                    break;
                }
            }
        }
    }
}
