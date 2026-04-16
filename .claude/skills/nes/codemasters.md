# Codemasters / Camerica — Deep Reference

## Company Background

Codemasters was founded in 1986 by brothers Richard and David Darling in the UK.
Their NES games were published in North America by **Camerica** (founded 1988 by
David J. Harding in Canada) and in Europe by Codemasters themselves. All NES
titles were **unlicensed** — they bypassed Nintendo's CIC lockout chip.

## Lockout Defeat Mechanisms

### CIC Stun Circuit

Camerica/Codemasters cartridges defeat the 10NES lockout chip by sending
negative voltage pulses to the CIC's reset line, "stunning" it before it can
trigger the console's reset. The stun circuit is controlled by a latch driven
by CPU A0 when writing to $E000–$FFFF.

Key points for emulation:
- The stun circuit is **irrelevant for emulation** — emulators don't simulate
  the lockout chip
- The stun writes do go through the BF909x chip but don't affect bank switching
- Some boards have a physical switch to disable the stun circuit

### European Plug-Through Cartridges

Later European releases used "plug-through" cartridges — the game cart plugs
into a licensed game cart (which provides the CIC chip). This was needed because
Nintendo added diodes/resistors to later PAL NES revisions to defeat the stun
circuit.

### CME-01 Chip (PAL Black Cartridges)

Some PAL re-releases used the CME-01 chip with a copy-protection mechanism.
These carts can fail to boot on consoles without a lockout chip providing a
reset signal — they paradoxically need the lockout chip they're trying to bypass.

## Aladdin Deck Enhancer

Released November 1992, the Aladdin Deck Enhancer was a cost-reduction device:
- The base unit contains: CIC stun circuit, CHR-RAM, mapper chip (CCU), and
  battery holder
- "Compact Cartridges" plug into the top and contain only PRG-ROM
- This made individual game cartridges much cheaper to produce
- Only 7 games were released before Camerica went bankrupt in 1993

The CCU (Compact Cartridge Unit) mapper functions identically to the BF9093
for single games and BF9096 for Quattro carts.

## Complete NES Game Catalog

### Standalone Cartridges (Mapper 71, BF9093)

| Game | PRG Size | Mirroring | Notes |
|------|----------|-----------|-------|
| Bee 52 | 64 KiB | H | |
| Bignose the Caveman | 128 KiB | H | |
| Bignose Freaks Out | 128 KiB | V | Also on Aladdin |
| Cosmic Spacehead | 256 KiB | V | PAL only, also called Linus Spacehead |
| Dreamworld Pogie | 128 KiB | V | Bug with bus conflict emulation |
| Fantastic Adventures of Dizzy | 256 KiB | V | Aladdin version has gameplay changes |
| Fantastic Dizzy | 256 KiB | V | PAL-only, enhanced version |
| Linus Spacehead's Cosmic Crusade | 128 KiB | V | Also on Aladdin |
| Micro Machines | 128 KiB | V | Multiple revisions (v1, v2, v3) |
| MiG 29: Soviet Fighter | 128 KiB | H | DMC IRQ timing-sensitive |
| Mystery World Dizzy | 64 KiB | V | 2017 release by Oliver Twins |
| Stunt Kids | 128 KiB | V | |
| Ultimate Stuntman | 256 KiB | V | |
| Wonderland Dizzy | 64 KiB | V | 2017 release by Oliver Twins |

### Fire Hawk (Mapper 71 submapper 1, BF9097)

| Game | PRG Size | Mirroring | Notes |
|------|----------|-----------|-------|
| Fire Hawk | 128 KiB | Mapper-controlled 1-screen | Unique among Codemasters |

### Quattro Multicarts (Mapper 232, BF9096)

| Cart | PRG Size | Games |
|------|----------|-------|
| Quattro Adventure | 256 KiB | Linus Spacehead, Super Robin Hood, Boomerang Kid, Treasure Island Dizzy |
| Quattro Arcade | 256 KiB | CJ's Elephant Antics, Stunt Buggies, F16 Renegade, Go! Dizzy Go! |
| Quattro Sports | 256 KiB | Baseball Pros, Soccer Simulator, Pro Tennis, BMX Simulator |

### Aladdin Deck Enhancer Compact Cartridges

| Game | PRG Size | Notes |
|------|----------|-------|
| Dizzy the Adventurer | 128 KiB | Pack-in, only on Aladdin (enhanced Dizzy Prince) |
| Fantastic Adventures of Dizzy | 256 KiB | Improved: faster char, 250 stars, changed items |
| Linus Spacehead's Cosmic Crusade | 128 KiB | Identical to standalone |
| Micro Machines | 128 KiB | Identical to standalone |
| Bignose Freaks Out | 128 KiB | Identical to standalone |
| Quattro Adventure | 256 KiB | Identical to standalone |
| Quattro Sports | 256 KiB | Identical to standalone |

## Technical Quirks & RE Notes

### 1. Smiley Test (ROM/RAM Self-Test)

All Codemasters NES games include a self-test activated by holding:
**All D-pad directions + A and/or B + Start + Select** while pressing Reset.

- A button = test PRG-ROM (checksums program ROM)
- B button = test CHR-RAM (writes/reads patterns to CHR-RAM)
- A+B = both tests (results ORed together)
- Green smiley face = PASS
- Red frown face = FAIL

The test code is typically at or near the RESET vector. Look for:
1. Button combo check (reads $4016/$4017)
2. PRG-ROM checksum loop (reads $8000–$FFFF across all banks)
3. CHR-RAM test pattern (writes to PPUDATA, reads back)
4. Branch to either smiley or frown tile display

This is a good landmark to identify early in disassembly.

### 2. Color $0D Usage

Many Codemasters games load palette value $0D, which generates a signal
below the NTSC sync level ("blacker than black"). Effects:
- Some CRT TVs display it as slightly darker than black — mostly harmless
- Some TVs lose sync briefly, causing picture roll or distortion
- Some modern capture/display devices may clip or distort

Games known to use $0D: Micro Machines (most versions), most Dizzy games,
most other Codemasters titles.

Fix: Later PAL versions (Cosmic Spacehead, Fantastic Dizzy) replaced $0D
with $0E in some (but not all) palettes.

For RE: When you find palette loading code, check for $0D values. This is
a common target for ROM hacks (replacing $0D with $0F or $0E).

### 3. MiG 29 DMC IRQ Timing

MiG 29: Soviet Fighter uses DPCM (DMC) IRQs for timing-sensitive effects.
The game is extremely picky about the timing of these interrupts — if the
DMC IRQ fires even slightly off, visual glitches occur.

This makes MiG 29 one of the hardest Codemasters games to emulate accurately
and a useful test ROM for APU timing accuracy.

### 4. Micro Machines Revisions

At least 3 known versions of Micro Machines exist:
- **v1** (1991 copyright): PAL timing bug prevents progress on PAL NES
- **v2** (1992 copyright): Simplified cheat code, intro screen changes
- **v3**: Replaced most $0D palette values with $0E

The game also has a hidden cheat code activated during the qualifying race.

### 5. Quattro Bank Wiring Variants

Some Quattro cart revisions have swapped bank wiring, causing games 2 and 3
to be swapped in the menu. NES 2.0 submapper 1 of Mapper 232 distinguishes
this variant. For RE, if a Quattro menu selects the wrong game, check if
the outer bank bits are swapped.

### 6. No Bus Conflicts

Unlike standard UNROM boards where the CPU write value is ANDed with the
ROM output value at the same address (bus conflict), Camerica boards use
the BF909x chip to decode addresses separately. The CPU's written value
always prevails.

This is critical for Dreamworld Pogie — it has a bug where a bank switch
write sends a value that doesn't match the ROM byte at that address. With
bus conflict emulation, the wrong bank gets selected, breaking the game's
ending.

### 7. PAL Compatibility

Codemasters developed for both NTSC and PAL markets. Some games have
PAL-specific timing compensation:
- BMX Simulator and Pro Tennis Simulator (in Quattro Sports) have music
  pitch/speed compensation routines for PAL
- Most other games run slightly slower on PAL with lower-pitched music
- Micro Machines v1 has a timing bug specific to PAL

### 8. CHR-RAM Tile Loading

All Codemasters NES games use CHR-RAM instead of CHR-ROM. This means:
- Tile data is stored in PRG-ROM and copied to CHR-RAM at runtime
- Large tile transfers happen with rendering off (during level loads)
- Smaller updates (animation, scrolling) happen during vblank
- Look for loops that write to $2007 (PPUDATA) with incrementing patterns

Typical tile loading routine structure:
```
; Set PPU address to pattern table
LDA #$00
STA $2006     ; PPUADDR high
STA $2006     ; PPUADDR low
; Copy tile data from PRG-ROM
LDY #$00
.loop:
LDA (ptr),Y  ; Read from PRG-ROM (indirect indexed)
STA $2007     ; Write to PPU
INY
BNE .loop
; ... possibly increment high byte and continue
```

## RE Strategy for Codemasters Games

### Phase 1: Header Analysis
1. Parse iNES header → confirm mapper 71 or 232
2. Note PRG size, mirroring type
3. Calculate number of 16 KiB banks

### Phase 2: Fixed Bank Analysis ($C000–$FFFF)
1. Read RESET vector ($FFFC–$FFFD) → entry point
2. Identify and label the smiley test routine
3. Map NMI handler ($FFFA) → usually the main game loop driver
4. Map IRQ handler ($FFFE) → may be unused or DMC IRQ (MiG 29)
5. Find the bank switching routine (writes to $C000–$FFFF)
6. Find trampoline/dispatch routines that switch banks and jump

### Phase 3: RAM Mapping
1. Run the game in Mesen/FCEUX with RAM watch
2. Identify player position, HP, lives, score in zero page / $03xx–$05xx
3. Map the OAM shadow buffer at $0200–$02FF
4. Find the sound engine workspace

### Phase 4: Switchable Bank Analysis
1. Use CDL data to identify which banks contain code vs data
2. For each bank, start from known entry points (trampoline targets)
3. Map level data, tile data, string tables, lookup tables
4. Cross-reference with fixed bank dispatch tables

### Phase 5: Graphics Analysis
1. Find CHR-RAM loading routines (writes to $2007)
2. Identify which tiles are loaded for each level/screen
3. Map palette loading code (writes to $3F00+ range via $2006/$2007)
4. Find nametable construction routines
5. Identify scrolling implementation

### Phase 6: Audio Analysis
1. Find the sound engine (usually called from NMI)
2. Identify music data format (note tables, instrument definitions)
3. Map sound effect triggers
4. For MiG 29: pay special attention to DMC IRQ handling
