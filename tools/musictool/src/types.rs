/// NES APU period value (11-bit, used for pulse and triangle channels)
pub type Period = u16;

/// Instrument definition — 12 bytes controlling how a note sounds.
///
/// The ADSR envelope, vibrato ("wobble"), duty cycle modulation ("tinny tone"),
/// reverb, and percussion thud are all defined here.
#[derive(Debug, Clone)]
pub struct Instrument {
    /// Initial volume when a note starts (0–255).
    pub start_volume: u8,
    /// Volume added per tick during attack phase.
    pub attack_rate: u8,
    /// Maximum volume — attack stops when this is reached.
    pub peak_volume: u8,
    /// Volume subtracted per tick during decay phase.
    pub decay_rate: u8,
    /// Minimum volume — decay stops here, note sustains at this level.
    pub sustain_level: u8,
    /// Duty cycle / pulse width modulation control (packed byte).
    ///
    /// - Bits 7–4: constant pulse period (0 = one-shot mode)
    /// - Bits 3–2: starting duty cycle (0–3 → 12.5%, 25%, 50%, 75%)
    /// - Bits 1–0: number of duty cycle transitions
    pub tone_control: u8,
    /// Ticks to wait before vibrato begins (0 = no delay).
    pub wobble_delay: u8,
    /// Vibrato speed: ticks per phase change.
    pub wobble_freq: u8,
    /// Vibrato depth growth: added to amplitude each cycle.
    pub wobble_inc: u8,
    /// Maximum vibrato amplitude.
    pub wobble_max: u8,
    /// Reverb period (0 = off). Creates echo by alternating volume.
    pub reverb: u8,
    /// Percussion "thud" effect: 0 = off, >0 = note index for the
    /// transient. Channel 3 gets white noise, channels 0–1 get a pitch sweep.
    pub thud_note: u8,
}

/// A single event in a note sequence.
#[derive(Debug, Clone)]
pub enum NoteEvent {
    /// Play a note with the given absolute note index and duration (in ticks).
    Note {
        note: u8,
        duration: u8,
    },
    /// Relative pitch adjustment from the previous note.
    RelativeNote {
        delta: i8,
        duration: u8,
    },
    /// Rest / delay with no new note trigger.
    Rest {
        duration: u8,
    },
    /// Glissando (pitch slide) to a target note.
    Glissando {
        note: u8,
        duration: u8,
        target_note: u8,
        wait: u8,
        rate: u8,
    },
    /// Chord (arpeggio): rapidly cycle through base + two intervals.
    Chord {
        note: u8,
        duration: u8,
        interval1: u8,
        interval2: u8,
    },
    /// Change the active instrument (no note played).
    SetInstrument {
        instrument_offset: u8,
    },
    /// End of section marker — load next section.
    EndSection,
}

/// A section of music: an instrument assignment + a sequence of note events.
#[derive(Debug, Clone)]
pub struct Section {
    /// Offset into the instrument table (byte offset, divide by 12 for index).
    pub instrument_offset: u8,
    /// Sequence of note events in this section.
    pub events: Vec<NoteEvent>,
}

/// One voice (channel) of a song: a list of sections played in order.
#[derive(Debug, Clone)]
pub struct Voice {
    /// Sections to play, in order.
    pub sections: Vec<Section>,
    /// If Some(n), repeat from section n after the last section.
    pub repeat_from: Option<usize>,
}

/// A complete song.
#[derive(Debug, Clone)]
pub struct Song {
    /// Transpose value (added to note indices for channels 0–2).
    pub transpose: u8,
    /// Master tempo (higher = slower). Notes advance every `tempo` ticks.
    pub tempo: u8,
    /// Four voices: [Pulse1, Pulse2, Triangle, Noise].
    pub voices: [Voice; 4],
}

/// All music data extracted from a ROM bank.
#[derive(Debug, Clone)]
pub struct MusicData {
    /// Instrument definitions.
    pub instruments: Vec<Instrument>,
    /// Songs (up to 9).
    pub songs: Vec<Song>,
    /// Note frequency table — 96 NES APU period values.
    pub freq_table: Vec<Period>,
}
