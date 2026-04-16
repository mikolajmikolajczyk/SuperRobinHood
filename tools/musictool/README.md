# musictool

Parser, engine reimplementation, and WAV renderer for the Codemasters NES
"Mega Music Driver" — a 4-channel chiptune format from the early 1990s.

## What It Does

Takes a raw NES ROM bank containing the Codemasters music engine and data,
and renders the songs to WAV files. The engine reimplements the original
6502 music driver in Rust, tick-for-tick, including:

- ADSR volume envelopes (attack, decay, sustain)
- Vibrato (3-phase pitch wobble with configurable speed, depth, delay)
- Glissando (portamento / pitch slides between notes)
- Chord arpeggio (3-note cycling for faux-polyphony)
- Pulse width modulation (duty cycle animation)
- Reverb (periodic volume on/off echo simulation)
- Triangle percussion thud (bass drum sweeps)
- Noise percussion (white noise snaps)
- Triangle linear counter (hardware-accurate note duration)

## Usage

```bash
# Build
cargo build --release

# Show all songs and instruments
musictool info bank1.bin

# Render song 1 (title music) to WAV
musictool render bank1.bin 1 title.wav 30

# Render individual channels for analysis
musictool render bank1.bin 1 pulse1.wav --channel 0
musictool render bank1.bin 1 triangle.wav --channel 2

# Dump note events (human-readable)
musictool dump bank1.bin 1
```

## Pre-rendered Songs

The `songs/` directory contains all 9 Super Robin Hood songs rendered
at 30 seconds, 44100 Hz mono WAV:

| File | Song |
|------|------|
| `1_title.wav` | Title page music |
| `2_game_completed.wav` | Game completed fanfare |
| `3_enter_name.wav` | Enter name screen |
| `4_game_over.wav` | Game over |
| `5_intro.wav` | Intro into game |
| `6_dungeons.wav` | Dungeons theme |
| `7_halls.wav` | Halls theme |
| `8_sky.wav` | Sky theme |
| `9_bedrooms.wav` | Bedrooms theme |

## Format Documentation

See [FORMAT.md](FORMAT.md) for the complete reverse-engineered format
specification, covering every byte of the song data, instrument
definitions, note encoding, and effect parameters.

## Architecture

```
bank1.bin (16 KB ROM)
    │
    ├── parse.rs     → Song, Instrument, NoteEvent structs
    │
    ├── engine.rs    → Tick-by-tick music engine emulation
    │                   (ADSR, wobble, thud, glissando, chords, reverb)
    │
    ├── apu.rs       → NES APU waveform synthesis
    │                   (pulse, triangle, noise → PCM samples)
    │
    └── main.rs      → CLI: info, dump, render commands
```

## Accuracy

The Rust engine was validated against a 6502 emulator running the
original game code, comparing APU register outputs frame-by-frame:

- **Pulse 2**: perfect match (0 mismatches in 600 frames)
- **Noise**: perfect match
- **Pulse 1**: 88% match (remaining mismatches are inaudible — period
  drift on silent channels)
- **Triangle**: match on all audible frames (differences are linear
  counter timing, a comparison tool limitation)

## Credits

- **Gavin Raeburn** — original "Mega Music Driver" (© 1990)
- **Jon Menzies** — MUSICED system (inspiration)
- **Oliver Twins** — published PDS source via Wireframe Magazine
