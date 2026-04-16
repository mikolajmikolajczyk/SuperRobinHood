# Codemasters NES Music Engine — Complete Format Reference

## Overview

The "Mega Music Driver" is a 4-channel music engine for the NES, written
in 6502 assembly by **Gavin Raeburn** (credited "(c) 1990 G.RAEBURN" in the
PDS source file `MACROS.MUS`). It was inspired by Jon Menzies' MUSICED system.

The engine drives the 4 standard NES APU channels:

| Channel | Hardware | APU Registers | Features |
|---------|----------|---------------|----------|
| 0 | Pulse 1 | `$4000–$4003` | Duty cycle, volume envelope, vibrato |
| 1 | Pulse 2 | `$4004–$4007` | Same as Pulse 1 |
| 2 | Triangle | `$4008–$400B` | Thud percussion, linear counter, no volume control |
| 3 | Noise | `$400C–$400F` | White noise percussion, thud decay |

The engine supports up to 9 tunes with per-channel instrument definitions,
ADSR envelopes, vibrato ("wobble"), glissando, chord arpeggios, reverb,
pulse width modulation ("tinny tone"), and percussion thud effects.

### Known Games Using This Engine

- Super Robin Hood (1992)
- Bee 52 (1992)
- Linus Spacehead (1992)
- Other Codemasters/Camerica NES titles from 1990–1993

### Source Files (from PDS development environment)

| File | Purpose |
|------|---------|
| `MUSIC1.MUS` | Complete engine code (~1400 lines) + frequency tables + song index |
| `MACROS.MUS` | PDS assembler macros |
| `JONSBIT.MUS` | Jon Menzies' bootstrap/setup code |
| `DATA.MUS` | Binary song data (~4.2 KB) |
| `DATA2`, `DATA3` | Additional instrument/song data |
| `SOUNDFX.ROU` | Separate sound effects engine (~1290 lines) |

---

## ROM Layout

The music engine and data reside in a single 16 KB ROM bank, mapped at
`$8000–$BFFF`. In Super Robin Hood this is bank 1.

### Memory Map

| Address | Label | Size | Content |
|---------|-------|------|---------|
| `$8000` | — | 1 | Bank ID byte |
| `$8001` | — | 3 | `JMP START_MUSIC` |
| `$8004` | — | 3 | `JMP PLAY_MUSIC` |
| `$8007` | `START_MUSIC` | ~90 | Init: parse song table, set up voices |
| `$8066` | `PLAY_MUSIC` | ~30 | Per-frame tick: delays, ADSR |
| `$80B5` | `ADSR` | ~850 | Envelope, effects, APU register writes |
| `$8417` | `NEW_MACRO` | ~100 | Load next section for a voice |
| `$84A2` | `DO_VOICES` | ~350 | Note sequence decoder |
| `$860F` | `TABLO` | 96 | Frequency table — low bytes |
| `$866F` | `TABHI` | 96 | Frequency table — high bytes |
| `$86CF` | `INDEX` | 2 | 16-bit pointer to song table |
| `$86DA` | `INSTRUMENTS` | N×12 | Instrument definitions |
| `$87D6` | Song table | 9×10 | Song headers |
| `$883A`+ | Song data | ~3 KB | Sections, note sequences |

---

## Entry Points

### `START_MUSIC` (`$8001` → `$8007`)

Initialise a tune. Call with the tune number (1–9) in the A register.
Value 0 silences all channels.

```
LDA #1          ; tune 1 = title music
JSR $8001       ; start playing
```

**What it does:**
1. Computes song table offset: `INDEX + (tune - 1) * 10`
2. Reads transpose and tempo from the song header
3. Reads 4 × 16-bit voice macro pointers
4. Calls `TRIGGER` which:
   - Zeros all per-channel state variables
   - Enables APU channels (`$4015 = $0F`)
   - Sets `DELAY_MAIN = TEMPO - 1`
   - Calls `NEW_MACRO` for each voice (loads first section)

### `PLAY_MUSIC` (`$8004` → `$8066`)

Called once per NMI frame (~60 Hz NTSC). Advances all music state.

**Frame processing order:**
1. Decrement per-voice delay counters (`VOICE1..4`)
2. Increment `MAIN_COUNTER`
3. Call `DELAY_BIT` (always once; twice on odd frames)
4. `JMP ADSR` — process envelopes and effects for all 4 channels

### `DELAY_BIT`

Manages the master tempo clock:
```
INC DELAY_MAIN
if DELAY_MAIN >= TEMPO:
    DELAY_MAIN = 0
    JSR DO_VOICES    ← advance note sequences
```

Since `DELAY_BIT` is called 1.5× per frame on average (once on even
frames, twice on odd), notes advance approximately every `TEMPO / 1.5`
frames.

---

## Song Table

Located at the address stored in `INDEX` (typically `$87D6`).
Each song is a **10-byte** entry:

```
Offset  Size  Field          Description
0       1     transpose      Added to note values for pulse/triangle channels
1       1     tempo          Master tempo divisor (higher = slower)
2       2     voice1_ptr     16-bit pointer to Pulse 1 macro data
4       2     voice2_ptr     16-bit pointer to Pulse 2 macro data
6       2     voice3_ptr     16-bit pointer to Triangle macro data
8       2     voice4_ptr     16-bit pointer to Noise macro data
```

### Transpose

- Channels 0–1 (pulse): add transpose to absolute note values AND to
  the starting note (32) on section load
- Channel 2 (triangle): add transpose to absolute note values only,
  NOT to the starting note on section load
- Channel 3 (noise): NO transpose applied anywhere

Transpose uses unsigned 8-bit arithmetic (wraps). Common values like
253 effectively transpose down by 3 semitones.

### Tempo

Controls note advancement speed. `DELAY_BIT` increments a counter each
call (~1.5×/frame); when the counter reaches `TEMPO`, notes advance.

| Tempo | Approx. notes/second | Feel |
|-------|---------------------|------|
| 6 | ~15 | Fast |
| 8 | ~11 | Medium |
| 12 | ~7.5 | Slow |

### Super Robin Hood Songs

| # | Name | Transpose | Tempo | Repeats |
|---|------|-----------|-------|---------|
| 1 | Title page | -3 | 8 | Yes |
| 2 | Game completed | -8 | 11 | Yes |
| 3 | Enter name | -3 | 6 | Yes |
| 4 | Game over | 0 | 8 | No |
| 5 | Intro | 0 | 8 | No |
| 6 | Dungeons | 0 | 8 | Yes |
| 7 | Halls | -8 | 12 | Yes |
| 8 | Sky | -12 | 6 | Yes |
| 9 | Bedrooms | -15 | 12 | Yes |

---

## Voice Macro System

Each voice has a **macro pointer** that walks through a list of 16-bit
section addresses. This is a two-level structure:

```
Song table → voice_ptr → [ junk 2 bytes ]    ← -2 offset
                          [ section_ptr_0 ] → section data
                          [ section_ptr_1 ] → section data
                          ...
                          [ end marker     ] → stop or repeat
```

### The -2 Offset

The voice pointer from the song table points **2 bytes before** the first
real section pointer. `NEW_MACRO` always adds 2 before reading. The first
2 bytes are effectively unused.

### Section Format

Each section pointer points to a data block:

```
Byte 0:    instrument_offset    (byte offset into INSTRUMENTS table; ÷ 12 = index)
Bytes 1+:  note event stream    (read via MACRO_COUNT starting at 1)
```

### End/Repeat Markers

When the macro pointer list contains an entry with high byte = 0:

| Low byte | Meaning |
|----------|---------|
| `$00` | Stop tune — silence all channels, set TUNE=0 |
| `$01`+ | Repeat — restart from section `(low_byte - 1)` |

On repeat, only channel 0 triggers the restart. All 4 voices' macro
pointers are reset from `SAVE_MACRO_POINT`, and `TRIGGER` reinitialises
all channel state.

---

## Note Event Encoding

Note data is a byte stream within each section, starting at offset 1.
Each byte is decoded as follows:

```
byte = data[MACRO_COUNT]
MACRO_COUNT++

if byte == $01:
    → end of section, call NEW_MACRO to load next

duration_field = byte & 7      (bits 0–2)
note_field     = byte >> 3     (bits 3–7)
```

### Short Events (duration_field ≥ 1)

A single byte encoding both duration and a **relative** pitch change:

```
Duration:  duration_field - 1  (stored in DELAY_SMALL; 0–6 ticks)
Pitch:     NOTE += (note_field - 16)  (range -16 to +15 semitones)
```

This is extremely compact — common note sequences where the pitch
changes by small intervals need only 1 byte per note.

### Long Events (duration_field = 0)

Two or more bytes. The first byte provides a **large delay**, the second
provides an **absolute note** with a **command code**:

```
Byte 1: [note_field: 5 bits] [000]     → DELAY_SMALL = note_field (0–31)
Byte 2: [command: 2 bits] [note_value: 6 bits]
```

The absolute note is computed as:
```
NOTE = note_value + 9 + transpose    (channels 0–2)
NOTE = note_value + 9                (channel 3, noise)
```

### Commands (bits 7–6 of byte 2)

| Cmd | Meaning | Extra bytes | Description |
|-----|---------|-------------|-------------|
| 0 | Normal note | 0 | Play the note at the computed pitch |
| 1 | Glissando | 3 | Pitch slide: `target_note`, `wait`, `rate` |
| 2 | Chord | 1 | Arpeggio: `shape` byte (high nibble = interval 2, low = interval 1) |
| 3 | Instrument change | 0 | Set instrument to `note_value × 12`. Then **immediately read another note byte** (no note is played for this event) |

### Command 3: Instrument Change

After setting the instrument, the engine jumps back to read the **next byte
as another absolute note** (the same format as byte 2 of a long event). This
is NOT a fresh event from the top — it re-enters at the note decode point.
The delay from byte 1 is retained.

This is a critical parsing detail: after cmd=3, the following byte must
be decoded as `[command:2][note_value:6]`, not as a short/long event.

---

## Instruments

Each instrument is **12 bytes** in the `INSTRUMENTS` table:

```
Offset  Field           Range    Description
0       start_volume    0–255    Initial volume on note trigger
1       attack_rate     0–255    Volume added per ADSR tick (attack phase)
                                 Also: triangle linear counter load value
2       peak_volume     0–255    Maximum volume (attack stops here)
3       decay_rate      0–255    Volume subtracted per ADSR tick (decay phase)
4       sustain_level   0–255    Volume floor (decay stops here; 0 = silence)
5       tone_control    packed   Pulse width modulation (see below)
6       wobble_delay    0–255    Frames before vibrato starts
7       wobble_freq     0–255    Vibrato speed (ticks per phase change)
8       wobble_inc      0–255    Vibrato depth growth per cycle
9       wobble_max      0–255    Maximum vibrato depth
10      reverb          0–255    Reverb period (0 = off)
11      thud_note       0–255    Percussion thud note index (0 = off)
```

### ADSR Envelope

Three phases, tracked by the `PHASE` variable:

| Phase | Action | Transition |
|-------|--------|-----------|
| 0 (Attack) | `volume += attack_rate` | When `volume >= peak_volume` → phase 1 |
| 1 (Decay) | `volume -= decay_rate` | When `volume <= sustain_level` → phase 2 |
| 2 (Sustain) | `volume = sustain_level` | Held until next note |

The 6502 writes `(volume >> 4) | $30 | tin_tone` to `$4000/$4004` (pulse)
or `$400C` (noise). Only the top 4 bits of volume are sent to the APU
(0–15 range).

**Triangle (channel 2) skips ADSR entirely.** The engine writes
`attack_rate` to `$4008` (linear counter register) on note trigger instead.

**Early exit:** When `phase >= 2` and `sustain_level == 0`, the 6502 jumps
to `!NO_HIGH`, skipping all remaining effects (thud, reverb, wobble, etc.)
for that channel. This prevents wobble from running on silent channels.

### Tone Control (Pulse Width Modulation)

```
Bits 7–4: pulse_period    If > 0: constant cycling mode (period = value × 2)
                          If = 0: one-shot mode
Bits 3–2: start_duty     Starting duty cycle (0–3)
Bits 1–0: changes        Number of duty cycle transitions
```

**One-shot mode** (pulse_period = 0): duty cycles from `start_duty` through
`changes` steps, incrementing by 1 each frame, wrapping 3→0. Stops when
the cycle count equals `changes`.

**Constant mode** (pulse_period > 0): duty cycles continuously at the
given period.

Duty cycle values: 0 = 12.5%, 1 = 25%, 2 = 50%, 3 = 75%.

---

## Effects

### Vibrato (Wobble)

Three-phase pitch modulation applied every frame (after thud, before glissando):

| Phase | Action | Duration |
|-------|--------|----------|
| 0 (Up) | Subtract `wob_amount` from period (pitch rises) | `wobble_freq` ticks |
| 1 (Down) | Add `wob_amount` to period (pitch drops) | `wobble_freq × 2` ticks |
| 2 (Back up) | Subtract `wob_amount` from period | `wobble_freq` ticks |

After completing all 3 phases, `wob_amount` grows by `wobble_inc`,
capped at `wobble_max`. If `wobble_delay > 0`, vibrato doesn't start
until that many frames have passed.

**Important naming:** `ADD_VOICE` in the 6502 source **subtracts** from
the period (raising pitch), and `SUB_VOICE` **adds** to the period
(lowering pitch). The names reflect the musician's perspective, not the
period register direction.

### Glissando (Portamento)

Pitch slide between notes. Encoded as command 1 in long events with
3 extra bytes:

```
target_note:  destination note index (+ transpose for ch 0–2)
wait:         frames to wait before sliding starts
rate:         slide speed. Bit 0 = half-speed flag (only advance on odd frames)
              Bits 7–1 = speed value (added/subtracted from period each frame)
```

The engine slides the period registers directly, comparing against the
target note's period. When reached, glissando stops.

### Chord (Arpeggio)

Rapid cycling through 3 notes per frame, creating the illusion of harmony:

```
shape byte:  high nibble = interval 2 (semitones above base)
             low nibble  = interval 1 (semitones above base)
```

A global `CHORD_COUNTER` (0→1→2→0...) selects:
- 0: base note (`OLD_NOTE`)
- 1: base + interval from high nibble
- 2: base + interval from low nibble

**Critical:** `CHORD_COUNTER` is zeroed whenever ANY channel triggers a
new note event (not just the channel with the chord). This is a global
counter shared across all channels.

### Reverb

Simple echo simulation via periodic volume on/off:

```
REVERB_COUNT increments each frame.
At reverb/2:     save volume → ECHO_HOLD, set volume = 0
At reverb:       restore volume from ECHO_HOLD, reset counter
Between:         volume stays at 0 (silence gap)
```

### Thud (Percussion)

The thud effect creates drum-like sounds on triangle and noise channels.
It only activates when the instrument's `thud_note > 0`.

**Triangle (ch 2) — Bass Drum:**

```
trigger_note: special_thud = 2    (always 2, regardless of thud_note)

Frame processing:
  special_thud = 2:  decrement → 1
  special_thud = 1:  decrement → 0 → reload:
                     - Set special_thud = 255
                     - Load thud_note's period from frequency table
                     - Write $20 to $4008 (linear counter = 32)
  special_thud = 255: "doof" sweep:
                     - Add 35 to period each frame (pitch drops)
                     - When high_pitch >= 2: stop thud
                       - Set special_thud = 0, volume = 0
                       - Write silence to APU
```

The bass drum sound: 2 frames of the original note pitch, then the
thud note period loads (a low bass note), then sweeps downward for
~7 frames until the period is too large. The linear counter (32)
ensures the triangle sounds for the duration of the sweep.

**Noise (ch 3) — Percussion Snap:**

```
trigger_note: special_thud = thud_note    (the actual value)

Frame processing:
  Each frame: low_pitch += 199 (wrapping), decrement special_thud
  When special_thud reaches 0: volume = 0, phase = 2 (silence)
```

### Triangle Linear Counter

The NES triangle channel has a hardware linear counter that controls
how long the triangle produces sound. The engine uses it to create
short percussive blips vs sustained bass tones:

- On **note trigger**: `$4008 = attack_rate` (typically 2 = very brief)
- On **thud reload**: `$4008 = $20` (32 = longer sustain for bass sweep)

The counter decrements at ~240 Hz (4× per frame). A value of 2 means
the triangle sounds for less than 1 frame — effectively a brief click.
A value of 32 means ~8 frames of sustained output.

---

## Frequency Tables

96 entries covering 8 octaves of the chromatic scale. Each entry is an
11-bit NES APU period value, split across `TABLO` (low bytes) and
`TABHI` (high bytes).

Base octave (12 notes):

| Note | Period | Approx Hz |
|------|--------|-----------|
| C | `$6AE` (1710) | 65.4 |
| C# | `$64E` (1614) | 69.3 |
| D | `$5F3` (1523) | 73.4 |
| D# | `$59E` (1438) | 77.8 |
| E | `$54D` (1357) | 82.4 |
| F | `$501` (1281) | 87.3 |
| F# | `$4B9` (1209) | 92.5 |
| G | `$475` (1141) | 98.0 |
| G# | `$435` (1077) | 103.8 |
| A | `$3F8` (1016) | 110.0 |
| A# | `$3BF` (959) | 116.5 |
| B | `$389` (905) | 123.5 |

Higher octaves are generated by dividing by powers of 2:
`period[n+12] = period[n] / 2`

Note index: `note = octave × 12 + semitone` (range 0–95)

Frequency formula: `freq = 1789773 / (16 × (period + 1))` for pulse,
`freq = 1789773 / (32 × (period + 1))` for triangle.

---

## Timing Reference

```
NMI rate:           ~60 Hz (NTSC)
DELAY_BIT calls:    1.5× per frame average (1 on even, 2 on odd)
Note advance:       every TEMPO calls of DELAY_BIT
                    ≈ 90/TEMPO notes per second

Short event duration field: 0–6 ticks (stored as field-1)
Long event delay field:     0–31 ticks

Total note duration = delay_ticks × (TEMPO / 1.5) frames
                    ≈ delay_ticks × TEMPO × 0.67 frames

Example with TEMPO=8:
  delay=0  →  ~5.3 frames  →  ~89ms
  delay=3  →  ~21.3 frames →  ~355ms
  delay=7  →  ~37.3 frames →  ~622ms
```

---

## ADSR Processing Order

The ADSR loop processes all 4 channels in order (0, 1, 2, 3).
For each channel:

```
1. Write volume to APU register ($4000/$4004/$400C)     [skip for triangle]
2. ADSR envelope (attack/decay/sustain)                  [skip for triangle]
   → If sustain_level=0 and phase>=2: skip everything below (early exit)
3. Special thud effect                                   [ch >= 2 only]
4. Reverb
5. Tinny tone (pulse width modulation)
6. Vibrato/wobble                                        [skip if chord or gliss active]
7. Glissando
8. Chords
```

After all 4 channels: increment `CHORD_COUNTER` (0→1→2→0).

---

## Using This Tool

```bash
# Show all songs and instruments in a ROM bank
musictool info bank1.bin

# Dump note events for a song (human-readable)
musictool dump bank1.bin 1

# Render a song to WAV (all channels, 30 seconds)
musictool render bank1.bin 1 title.wav 30

# Render a single channel (0=Pulse1, 1=Pulse2, 2=Triangle, 3=Noise)
musictool render bank1.bin 1 triangle.wav 30 --channel 2

# Render all songs
for i in $(seq 1 9); do musictool render bank1.bin $i "song${i}.wav" 30; done
```

---

## Credits & Acknowledgements

- **Gavin Raeburn** — music engine author ("Mega Music Driver", © 1990)
- **Jon Menzies** — original MUSICED system that inspired this engine
- **Oliver Twins** — published the PDS source code via Wireframe Magazine
- **Codemasters** — game publisher (now part of EA)

The music engine was reverse-engineered from the Super Robin Hood NES ROM
and verified against the original PDS source code. The Rust reimplementation
was validated frame-by-frame against a 6502 emulator running the original
engine code, achieving 88% match rate (remaining differences are inaudible
or due to linear counter approximation).
