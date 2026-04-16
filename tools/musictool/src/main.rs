mod types;
mod parse;
mod engine;
mod apu;

use std::fs;
use types::NoteEvent;

fn main() {
    let args: Vec<String> = std::env::args().collect();

    match args.get(1).map(|s| s.as_str()) {
        Some("info") => cmd_info(&args[2..]),
        Some("dump") => cmd_dump(&args[2..]),
        Some("render") => cmd_render(&args[2..]),
        _ => {
            eprintln!("musictool — Codemasters NES music engine tool");
            eprintln!();
            eprintln!("Usage:");
            eprintln!("  musictool info <bank1.bin>              Show all songs and instruments");
            eprintln!("  musictool dump <bank1.bin> <song#>      Dump note events for a song");
            eprintln!("  musictool render <bank1.bin> <song#> <out.wav> [seconds] [--channel N]");
            eprintln!("                                          Render song to WAV file");
            std::process::exit(1);
        }
    }
}

fn cmd_info(args: &[String]) {
    if args.is_empty() {
        eprintln!("Usage: musictool info <bank1.bin>");
        std::process::exit(1);
    }
    let data = fs::read(&args[0]).expect("Cannot read bank file");
    let music = parse::parse_bank(&data);

    println!("Codemasters NES Music Engine — Bank 1 Analysis");
    println!("═══════════════════════════════════════════════");
    println!();

    println!("Frequency table: {} entries ({}–{} Hz approx)",
        music.freq_table.len(),
        1_789_773.0 / (16.0 * (music.freq_table[0] as f64 + 1.0)),
        1_789_773.0 / (16.0 * (music.freq_table[95] as f64 + 1.0)));
    println!();

    println!("Instruments: {}", music.instruments.len());
    println!("{:<4} {:>5} {:>5} {:>5} {:>5} {:>5} {:>5} {:>5} {:>5} {:>5} {:>5} {:>5}",
        "#", "Start", "Atk", "Peak", "Dec", "Sus", "Tone", "WDly", "WFrq", "WInc", "WMax", "Thud");
    println!("{}", "─".repeat(72));
    for (i, inst) in music.instruments.iter().enumerate() {
        println!("{:<4} {:>5} {:>5} {:>5} {:>5} {:>5}  0x{:02X} {:>5} {:>5} {:>5} {:>5} {:>5}",
            i, inst.start_volume, inst.attack_rate, inst.peak_volume,
            inst.decay_rate, inst.sustain_level, inst.tone_control,
            inst.wobble_delay, inst.wobble_freq, inst.wobble_inc,
            inst.wobble_max, inst.thud_note);
    }
    println!();

    let song_names = [
        "Title page", "Game completed", "Enter name", "Game over",
        "Intro", "Dungeons", "Halls", "Sky", "Bedrooms"
    ];
    println!("Songs: {}", music.songs.len());
    println!("{:<4} {:<18} {:>5} {:>5}  {:>10} {:>8} {:>7}",
        "#", "Name", "Trans", "Tempo", "Sections", "Events", "Repeat");
    println!("{}", "─".repeat(66));
    for (i, song) in music.songs.iter().enumerate() {
        let name = song_names.get(i).unwrap_or(&"?");
        let section_counts: Vec<usize> = song.voices.iter()
            .map(|v| v.sections.len()).collect();
        let total_events: usize = song.voices.iter()
            .flat_map(|v| v.sections.iter())
            .map(|s| s.events.len()).sum();
        let repeats: Vec<String> = song.voices.iter()
            .map(|v| match v.repeat_from {
                Some(n) => format!("@{}", n),
                None => "-".to_string(),
            }).collect();
        println!("{:<4} {:<18} {:>5} {:>5}  {:>10} {:>8} {:>7}",
            i + 1, name,
            song.transpose as i8 as i16, song.tempo,
            format!("{:?}", section_counts), total_events,
            repeats.join(","));
    }
}

fn cmd_dump(args: &[String]) {
    if args.len() < 2 {
        eprintln!("Usage: musictool dump <bank1.bin> <song#>");
        std::process::exit(1);
    }
    let data = fs::read(&args[0]).expect("Cannot read bank file");
    let song_num: usize = args[1].parse().expect("Invalid song number");
    if song_num < 1 || song_num > 9 {
        eprintln!("Song number must be 1–9");
        std::process::exit(1);
    }

    let music = parse::parse_bank(&data);
    let song = &music.songs[song_num - 1];

    let ch_names = ["Pulse 1", "Pulse 2", "Triangle", "Noise"];
    let note_names = ["C-", "C#", "D-", "D#", "E-", "F-", "F#", "G-", "G#", "A-", "A#", "B-"];

    println!("Song {}: transpose={}, tempo={}",
        song_num, song.transpose as i8 as i16, song.tempo);
    println!();

    for (ch, voice) in song.voices.iter().enumerate() {
        println!("── {} ({} sections{}) ──",
            ch_names[ch], voice.sections.len(),
            match voice.repeat_from {
                Some(n) => format!(", repeat from section {}", n),
                None => String::new(),
            });

        for (si, section) in voice.sections.iter().enumerate() {
            let inst_idx = section.instrument_offset / 12;
            println!("  Section {} (instrument {})", si, inst_idx);

            for event in &section.events {
                match event {
                    NoteEvent::Note { note, duration } => {
                        let octave = *note as usize / 12;
                        let semi = *note as usize % 12;
                        let name = note_names.get(semi).unwrap_or(&"??");
                        println!("    {}{} dur={}", name, octave, duration);
                    }
                    NoteEvent::RelativeNote { delta, duration } => {
                        println!("    rel {:+} dur={}", delta, duration);
                    }
                    NoteEvent::Glissando { note, duration, target_note, wait, rate } => {
                        println!("    gliss {}→{} dur={} wait={} rate={}",
                            note, target_note, duration, wait, rate);
                    }
                    NoteEvent::Chord { note, duration, interval1, interval2 } => {
                        println!("    chord {} +{}+{} dur={}",
                            note, interval1, interval2, duration);
                    }
                    NoteEvent::SetInstrument { instrument_offset } => {
                        println!("    INST → {}", instrument_offset / 12);
                    }
                    NoteEvent::Rest { duration } => {
                        println!("    rest dur={}", duration);
                    }
                    NoteEvent::EndSection => {
                        println!("    END");
                    }
                }
            }
        }
        println!();
    }
}

fn cmd_render(args: &[String]) {
    if args.len() < 3 {
        eprintln!("Usage: musictool render <bank1.bin> <song#> <out.wav> [seconds] [--channel N]");
        eprintln!();
        eprintln!("Options:");
        eprintln!("  --channel 0   Pulse 1 only");
        eprintln!("  --channel 1   Pulse 2 only");
        eprintln!("  --channel 2   Triangle only");
        eprintln!("  --channel 3   Noise only");
        eprintln!("  (omit for all channels mixed)");
        std::process::exit(1);
    }
    let data = fs::read(&args[0]).expect("Cannot read bank file");
    let song_num: usize = args[1].parse().expect("Invalid song number");
    if song_num < 1 || song_num > 9 {
        eprintln!("Song number must be 1–9");
        std::process::exit(1);
    }
    let out_path = &args[2];

    // Parse optional args
    let mut seconds: f64 = 30.0;
    let mut solo_channel: Option<usize> = None;
    let mut i = 3;
    while i < args.len() {
        match args[i].as_str() {
            "--channel" => {
                i += 1;
                solo_channel = Some(args[i].parse().expect("Invalid channel number (0-3)"));
            }
            s => {
                seconds = s.parse().expect("Invalid seconds value");
            }
        }
        i += 1;
    }

    let ch_names = ["Pulse 1", "Pulse 2", "Triangle", "Noise"];

    let music = parse::parse_bank(&data);
    let mut eng = engine::Engine::new(&music, song_num - 1);
    let mut renderer = apu::Renderer::new();

    let total_frames = (seconds * 60.0) as usize;
    let sample_rate = renderer.sample_rate();

    let spec = hound::WavSpec {
        channels: 1,
        sample_rate,
        bits_per_sample: 16,
        sample_format: hound::SampleFormat::Int,
    };
    let mut writer = hound::WavWriter::create(out_path, spec)
        .expect("Cannot create WAV file");

    let mut frame_count = 0;
    for _ in 0..total_frames {
        if !eng.is_playing() { break; }
        let frame = eng.tick();

        // If solo, mute all other channels
        let mut channels = frame.channels;
        if let Some(solo) = solo_channel {
            for (ch, c) in channels.iter_mut().enumerate() {
                if ch != solo { c.enabled = false; }
            }
        }

        let samples = renderer.render_frame(&channels);
        for s in &samples {
            let sample_i16 = (*s * 32000.0).clamp(-32767.0, 32767.0) as i16;
            writer.write_sample(sample_i16).unwrap();
        }
        frame_count += 1;
    }

    writer.finalize().unwrap();
    let duration = frame_count as f64 / 60.0;
    let ch_label = match solo_channel {
        Some(ch) => format!(" [{}]", ch_names[ch]),
        None => " [all]".to_string(),
    };
    println!(
        "Rendered song {}{} ({} frames, {:.1}s) → {} ({} Hz, mono)",
        song_num, ch_label, frame_count, duration, out_path, sample_rate
    );
}
