/// Parser for the Codemasters NES music format.
///
/// Reads binary ROM data (bank 1) and extracts songs, instruments,
/// and frequency tables into structured Rust types.

use crate::types::*;

/// Known addresses in the Super Robin Hood bank 1 ROM.
const BANK_BASE: u16 = 0x8000;
const INDEX_ADDR: u16 = 0x86CF;
const INSTRUMENTS_ADDR: u16 = 0x86DA;
const TABLO_ADDR: u16 = 0x860F;
const TABHI_ADDR: u16 = 0x866F;
const NUM_NOTES: usize = 96;
const INSTRUMENT_SIZE: usize = 12;

fn off(addr: u16) -> usize {
    if addr < BANK_BASE {
        panic!("Address ${:04X} is below bank base ${:04X}", addr, BANK_BASE);
    }
    (addr - BANK_BASE) as usize
}

fn try_off(addr: u16) -> Option<usize> {
    if addr >= BANK_BASE && addr < BANK_BASE + 0x4000 {
        Some((addr - BANK_BASE) as usize)
    } else {
        None
    }
}

fn read_u16(data: &[u8], addr: u16) -> u16 {
    let o = off(addr);
    u16::from_le_bytes([data[o], data[o + 1]])
}

/// Parse all music data from a bank 1 ROM image (16 KB, mapped at $8000).
pub fn parse_bank(data: &[u8]) -> MusicData {
    assert!(data.len() >= 0x4000, "Bank data too small (expected 16 KB)");

    // --- Frequency tables ---
    let freq_table = parse_freq_table(data);

    // --- Song table ---
    let song_table_addr = read_u16(data, INDEX_ADDR);
    let songs = parse_songs(data, song_table_addr);

    // --- Instruments ---
    // Count instruments by finding the highest instrument_offset used in any song
    let max_offset = songs.iter()
        .flat_map(|s| s.voices.iter())
        .flat_map(|v| v.sections.iter())
        .map(|sec| sec.instrument_offset as usize)
        .max()
        .unwrap_or(0);
    let num_instruments = max_offset / INSTRUMENT_SIZE + 1;
    let instruments = parse_instruments(data, num_instruments);

    MusicData { instruments, songs, freq_table }
}

fn parse_freq_table(data: &[u8]) -> Vec<Period> {
    let mut table = Vec::with_capacity(NUM_NOTES);
    for i in 0..NUM_NOTES {
        let lo = data[off(TABLO_ADDR) + i] as u16;
        let hi = data[off(TABHI_ADDR) + i] as u16;
        table.push((hi << 8) | lo);
    }
    table
}

fn parse_instruments(data: &[u8], count: usize) -> Vec<Instrument> {
    let base = off(INSTRUMENTS_ADDR);
    (0..count).map(|i| {
        let o = base + i * INSTRUMENT_SIZE;
        Instrument {
            start_volume: data[o],
            attack_rate: data[o + 1],
            peak_volume: data[o + 2],
            decay_rate: data[o + 3],
            sustain_level: data[o + 4],
            tone_control: data[o + 5],
            wobble_delay: data[o + 6],
            wobble_freq: data[o + 7],
            wobble_inc: data[o + 8],
            wobble_max: data[o + 9],
            reverb: data[o + 10],
            thud_note: data[o + 11],
        }
    }).collect()
}

fn parse_songs(data: &[u8], table_addr: u16) -> Vec<Song> {
    let mut songs = Vec::new();
    for song_idx in 0..9 {
        let entry_addr = table_addr + (song_idx as u16) * 10;
        let o = off(entry_addr);

        let transpose = data[o];
        let tempo = data[o + 1];

        let mut voices: [Voice; 4] = std::array::from_fn(|_| Voice {
            sections: Vec::new(),
            repeat_from: None,
        });

        for v in 0..4 {
            let voice_ptr = u16::from_le_bytes([data[o + 2 + v * 2], data[o + 3 + v * 2]]);
            voices[v] = parse_voice(data, voice_ptr, v, transpose);
        }

        songs.push(Song { transpose, tempo, voices });
    }
    songs
}

/// Parse one voice's macro chain starting from the given pointer.
///
/// The pointer is offset by -2 (NEW_MACRO adds 2 before first read).
fn parse_voice(data: &[u8], start_ptr: u16, channel: usize, transpose: u8) -> Voice {
    let mut sections = Vec::new();
    let mut repeat_from = None;
    let mut ptr = start_ptr.wrapping_add(2); // skip the -2 offset junk

    for _safety in 0..256 {
        let o = match try_off(ptr) {
            Some(o) if o + 1 < data.len() => o,
            _ => break,
        };
        let lo = data[o];
        let hi = data[o + 1];

        if hi == 0 {
            // End marker
            if lo > 0 {
                // Repeat from section (lo - 1).
                // The 6502 code does: SBC #1, ASL → (lo-1)*2 byte offset
                // into the pointer list. Each pointer is 2 bytes, so
                // section index = lo - 1.
                repeat_from = Some(lo as usize - 1);
            }
            break;
        }

        let section_addr = u16::from_le_bytes([lo, hi]);
        if let Some(section) = parse_section(data, section_addr, channel, transpose) {
            sections.push(section);
        }

        ptr = ptr.wrapping_add(2);
    }

    Voice { sections, repeat_from }
}

/// Parse a section: instrument offset byte + note events.
///
/// The macro pointer list contains 16-bit addresses pointing to section data.
/// Each section is laid out as:
///   byte 0:    instrument offset (index into INSTRUMENTS table, divide by 12)
///   bytes 1+:  note event stream (read via MACRO_COUNT starting at 1)
///
/// NEW_MACRO reads byte 0 as the instrument.
/// DO_VOICES reads bytes 1+ as note data.
fn parse_section(data: &[u8], addr: u16, channel: usize, transpose: u8) -> Option<Section> {
    let o = try_off(addr)?;
    if o + 2 > data.len() { return None; }

    let instrument_offset = data[o];
    let events = parse_note_events(data, o, channel, transpose);

    Some(Section {
        instrument_offset,
        events,
    })
}

/// Parse the note event stream starting at the given ROM offset.
/// `base` is the offset of the instrument/data block (note data starts at +1).
fn parse_note_events(data: &[u8], base: usize, channel: usize, transpose: u8) -> Vec<NoteEvent> {
    let mut events = Vec::new();
    let mut pos = 1usize; // MACRO_COUNT starts at 1
    // Starting note: only pulse channels (0,1) add transpose.
    // Triangle and noise start at plain 32.
    // (6502: CPX #2; BCS skips transpose for channels >= 2)
    let mut current_note: u8 = 32u8.wrapping_add(if channel < 2 { transpose } else { 0 });
    // Track the pending delay from a long event's first byte
    let mut pending_delay: u8 = 0;

    for _safety in 0..1024 {
        if base + pos >= data.len() { break; }
        let byte = data[base + pos];
        pos += 1;

        if byte == 1 {
            events.push(NoteEvent::EndSection);
            break;
        }

        let duration_field = byte & 7;
        let note_field = byte >> 3;

        if duration_field >= 1 {
            // Short event: relative note + duration
            let delta = (note_field as i8) - 16;
            current_note = (current_note as i16 + delta as i16) as u8;
            events.push(NoteEvent::RelativeNote {
                delta,
                duration: duration_field - 1,
            });
        } else {
            // Long event: first byte provides delay, second byte has note+command
            pending_delay = note_field;
            // Fall through to read the note byte(s)
            // This is a loop because cmd=3 (instrument change) reads another note byte
            loop {
                if base + pos >= data.len() { break; }
                let next_byte = data[base + pos];
                pos += 1;

                let note_value = next_byte & 63;
                let command = (next_byte >> 6) & 3;

                // Absolute note: channels 0-2 add transpose, channel 3 (noise) doesn't
                // (6502: CPX #3; BEQ skips transpose only for noise)
                let abs_note = note_value.wrapping_add(9)
                    .wrapping_add(if channel != 3 { transpose } else { 0 });
                current_note = abs_note;

                match command {
                    0 => {
                        // Normal note
                        events.push(NoteEvent::Note {
                            note: abs_note,
                            duration: pending_delay,
                        });
                        break;
                    }
                    1 => {
                        // Glissando: read 3 more bytes
                        if base + pos + 2 >= data.len() { break; }
                        let target = data[base + pos].wrapping_add(
                            if channel != 3 { transpose } else { 0 }
                        );
                        let wait = data[base + pos + 1];
                        let rate = data[base + pos + 2];
                        pos += 3;
                        events.push(NoteEvent::Glissando {
                            note: abs_note,
                            duration: pending_delay,
                            target_note: target,
                            wait,
                            rate,
                        });
                        break;
                    }
                    2 => {
                        // Chord: read 1 more byte
                        if base + pos >= data.len() { break; }
                        let shape = data[base + pos];
                        pos += 1;
                        events.push(NoteEvent::Chord {
                            note: abs_note,
                            duration: pending_delay,
                            interval1: shape >> 4,
                            interval2: shape & 0x0F,
                        });
                        break;
                    }
                    3 => {
                        // Change instrument — then immediately read next note byte
                        // (6502: JMP !NEW_INSTRUMENT_RELOOP re-enters the note read)
                        let inst_off = note_value.wrapping_mul(12);
                        events.push(NoteEvent::SetInstrument {
                            instrument_offset: inst_off,
                        });
                        // Loop back to read the next byte as another note+cmd
                        continue;
                    }
                    _ => unreachable!(),
                }
            }
        }
    }

    events
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_bank1() {
        let data = std::fs::read("../../disasm/banks/bank1.bin")
            .expect("Run from tools/musictool/");
        let music = parse_bank(&data);

        assert_eq!(music.freq_table.len(), 96);
        assert_eq!(music.songs.len(), 9);

        // Song 1: title music
        let song1 = &music.songs[0];
        assert_eq!(song1.transpose, 253);
        assert_eq!(song1.tempo, 8);
        for voice in &song1.voices {
            assert!(!voice.sections.is_empty(),
                "Each voice should have at least one section");
        }

        println!("Parsed {} instruments, {} songs", music.instruments.len(), music.songs.len());
        for (i, song) in music.songs.iter().enumerate() {
            let total_events: usize = song.voices.iter()
                .flat_map(|v| v.sections.iter())
                .map(|s| s.events.len())
                .sum();
            let section_counts: Vec<usize> = song.voices.iter()
                .map(|v| v.sections.len())
                .collect();
            println!("  Song {}: transpose={}, tempo={}, sections={:?}, events={}",
                i + 1, song.transpose, song.tempo, section_counts, total_events);
        }
    }
}
