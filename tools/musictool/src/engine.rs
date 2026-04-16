/// Tick-by-tick emulation of the Codemasters "Mega Music Driver".
///
/// Replicates the behaviour of the 6502 engine called once per NMI (~60 Hz).
/// Instead of writing to NES APU registers, it produces per-frame snapshots
/// of the 4 channel states that can be fed into an audio synthesiser.

use crate::types::*;

/// Per-channel APU output state for one frame.
#[derive(Debug, Clone, Copy, Default)]
pub struct ChannelOutput {
    pub period: u16,     // 11-bit APU period
    pub volume: u8,      // 0–15 (4-bit)
    pub duty: u8,        // 0–3 (pulse duty cycle)
    pub enabled: bool,
}

/// Complete APU state for one frame (all 4 channels).
#[derive(Debug, Clone, Default)]
pub struct FrameOutput {
    pub channels: [ChannelOutput; 4],
}

/// Internal state for one voice/channel.
#[derive(Debug, Clone)]
struct ChannelState {
    // Position in song
    section_idx: usize,
    event_idx: usize,
    finished: bool,

    // Note
    note: u8,
    old_note: u8,
    instrument_offset: u8,

    // Timing
    delay_small: i16,
    voice_delay: u8,

    // ADSR
    volume: u8,
    /// The volume as written to $4000 — captured BEFORE ADSR processes.
    /// The 6502 writes volume to the APU register first, then runs the
    /// envelope. The APU output uses this pre-ADSR value.
    output_volume: u8,
    phase: u8, // 0=attack, 1=decay, 2=sustain

    // Pitch (raw APU values)
    low_pitch: u8,
    high_pitch: u8,

    // Vibrato
    wob_delay: u8,
    wob_phase: u8,
    wob_count: u8,
    wob_freq: u8,
    wob_amount: u8,

    // Effects
    reverb_count: u8,
    echo_hold: u8,
    special_thud: u8,
    tin_tone: u8,
    tin_delay: u8,
    chord_shape: u8,
    gliss_rate: u8,
    gliss_wait: u8,
    gliss_new_note: u8,
    /// Triangle linear counter — controls how long the triangle sounds.
    /// Decrements each frame. When 0, triangle is silenced.
    tri_linear_counter: u8,
    /// Pre-decrement linear counter snapshot for output
    tri_output_counter: u8,
}

impl Default for ChannelState {
    fn default() -> Self {
        Self {
            section_idx: 0, event_idx: 0, finished: false,
            note: 32, old_note: 32, instrument_offset: 0,
            delay_small: 0, voice_delay: 0,
            volume: 0, output_volume: 0, phase: 0,
            low_pitch: 0, high_pitch: 0,
            wob_delay: 0, wob_phase: 0, wob_count: 0, wob_freq: 0, wob_amount: 0,
            reverb_count: 0, echo_hold: 0, special_thud: 0,
            tin_tone: 0, tin_delay: 0,
            chord_shape: 0, gliss_rate: 0, gliss_wait: 0, gliss_new_note: 0,
            tri_linear_counter: 0, tri_output_counter: 0,
        }
    }
}

/// The music engine state machine.
pub struct Engine {
    song: Song,
    instruments: Vec<Instrument>,
    freq_table: Vec<Period>,

    channels: [ChannelState; 4],
    delay_main: u8,
    main_counter: u8,
    chord_counter: u8,
    playing: bool,
}

impl Engine {
    /// Create a new engine for the given song.
    pub fn new(music: &MusicData, song_index: usize) -> Self {
        let song = music.songs[song_index].clone();
        let mut engine = Engine {
            song,
            instruments: music.instruments.clone(),
            freq_table: music.freq_table.clone(),
            channels: Default::default(),
            delay_main: 0,
            main_counter: 0,
            chord_counter: 0,
            playing: true,
        };
        engine.init();
        engine
    }

    fn init(&mut self) {
        let tempo = self.song.tempo;
        self.delay_main = tempo.saturating_sub(1);
        self.main_counter = 0;
        self.chord_counter = 0;

        for ch in 0..4 {
            self.channels[ch] = ChannelState::default();
            let start_note = 32u8.wrapping_add(
                if ch < 2 { self.song.transpose } else { 0 }
            );
            self.channels[ch].note = start_note;
            self.channels[ch].old_note = start_note;

            // Load first section
            self.load_section(ch);
        }
    }

    fn load_section(&mut self, ch: usize) {
        let voice = &self.song.voices[ch];
        let idx = self.channels[ch].section_idx;

        if idx >= voice.sections.len() {
            // Check for repeat
            if let Some(repeat_from) = voice.repeat_from {
                if ch == 0 {
                    // Channel 0 controls repeat for all voices
                    for c in 0..4 {
                        self.channels[c].section_idx = repeat_from;
                        self.channels[c].event_idx = 0;
                        self.channels[c].finished = false;
                    }
                    // Re-init all channels
                    for c in 0..4 {
                        self.load_section_inner(c);
                    }
                    return;
                }
            }
            self.channels[ch].finished = true;
            return;
        }

        self.load_section_inner(ch);
    }

    fn load_section_inner(&mut self, ch: usize) {
        let voice = &self.song.voices[ch];
        let idx = self.channels[ch].section_idx;
        if idx >= voice.sections.len() {
            self.channels[ch].finished = true;
            return;
        }

        let section = &voice.sections[idx];
        self.channels[ch].instrument_offset = section.instrument_offset;
        self.channels[ch].event_idx = 0;
        self.channels[ch].delay_small = 0;

        let start_note = 32u8.wrapping_add(
            if ch < 3 { self.song.transpose } else { 0 }
        );
        self.channels[ch].note = start_note;
    }

    /// Returns true if the song is still playing.
    pub fn is_playing(&self) -> bool {
        self.playing
    }

    /// Advance one frame (~60 Hz). Returns the APU output for this frame.
    pub fn tick(&mut self) -> FrameOutput {
        if !self.playing {
            return FrameOutput::default();
        }

        // Decrement voice delays
        for ch in 0..4 {
            if self.channels[ch].voice_delay > 0 {
                self.channels[ch].voice_delay -= 1;
            }
        }

        self.main_counter = self.main_counter.wrapping_add(1);

        // DELAY_BIT — always called once
        self.delay_bit();

        // Called again on odd frames
        if self.main_counter & 1 != 0 {
            self.delay_bit();
        }

        // ADSR processing
        self.process_adsr();

        // Build output
        self.build_output()
    }

    fn delay_bit(&mut self) {
        self.delay_main = self.delay_main.wrapping_add(1);
        if self.delay_main >= self.song.tempo {
            self.delay_main = 0;
            self.do_voices();
        }
    }

    /// Advance note sequences for all channels.
    fn do_voices(&mut self) {
        for ch in 0..4 {
            if self.channels[ch].finished { continue; }

            self.channels[ch].delay_small -= 1;
            if self.channels[ch].delay_small >= 0 { continue; }

            // Need next note event
            self.read_next_event(ch);
        }
    }

    fn read_next_event(&mut self, ch: usize) {
        let voice = &self.song.voices[ch];
        let sec_idx = self.channels[ch].section_idx;
        if sec_idx >= voice.sections.len() {
            self.channels[ch].finished = true;
            return;
        }

        let section = &voice.sections[sec_idx];
        let ev_idx = self.channels[ch].event_idx;

        if ev_idx >= section.events.len() {
            // End of section
            self.channels[ch].section_idx += 1;
            self.load_section(ch);
            if !self.channels[ch].finished {
                self.read_next_event(ch);
            }
            return;
        }

        let event = section.events[ev_idx].clone();
        self.channels[ch].event_idx += 1;

        // Clear per-note state (matches 6502 DO_VOICES)
        self.channels[ch].chord_shape = 0;
        self.chord_counter = 0; // global — zeroed on every new note, any channel
        self.channels[ch].gliss_rate = 0;
        self.channels[ch].special_thud = 0;

        match event {
            NoteEvent::EndSection => {
                self.channels[ch].section_idx += 1;
                self.load_section(ch);
                if !self.channels[ch].finished {
                    self.read_next_event(ch);
                }
                return;
            }
            NoteEvent::SetInstrument { instrument_offset } => {
                self.channels[ch].instrument_offset = instrument_offset;
                // Immediately read next event (no note played)
                self.read_next_event(ch);
                return;
            }
            NoteEvent::Note { note, duration } => {
                self.channels[ch].note = note;
                self.channels[ch].old_note = note;
                self.channels[ch].delay_small = duration as i16;
            }
            NoteEvent::RelativeNote { delta, duration } => {
                let new_note = (self.channels[ch].note as i16 + delta as i16) as u8;
                self.channels[ch].note = new_note;
                self.channels[ch].old_note = new_note;
                self.channels[ch].delay_small = duration as i16;
            }
            NoteEvent::Rest { duration } => {
                self.channels[ch].delay_small = duration as i16;
                return; // Don't trigger a new note
            }
            NoteEvent::Glissando { note, duration, target_note, wait, rate } => {
                self.channels[ch].note = note;
                self.channels[ch].old_note = note;
                self.channels[ch].delay_small = duration as i16;
                self.channels[ch].gliss_new_note = target_note;
                self.channels[ch].gliss_wait = wait;
                self.channels[ch].gliss_rate = rate;
            }
            NoteEvent::Chord { note, duration, interval1, interval2 } => {
                self.channels[ch].note = note;
                self.channels[ch].old_note = note;
                self.channels[ch].delay_small = duration as i16;
                self.channels[ch].chord_shape = (interval1 << 4) | interval2;
            }
        }

        // Trigger new note — reset envelope and set pitch
        self.trigger_note(ch);
    }

    fn trigger_note(&mut self, ch: usize) {
        let state = &mut self.channels[ch];
        let inst_idx = (state.instrument_offset / 12) as usize;
        let inst = self.instruments.get(inst_idx).cloned().unwrap_or(Instrument {
            start_volume: 0, attack_rate: 0, peak_volume: 0,
            decay_rate: 0, sustain_level: 0, tone_control: 0,
            wobble_delay: 0, wobble_freq: 0, wobble_inc: 0,
            wobble_max: 0, reverb: 0, thud_note: 0,
        });

        // Reset envelope
        state.volume = inst.start_volume;
        state.phase = 0;
        state.reverb_count = 0;
        state.wob_delay = 0;
        state.wob_phase = 0;
        state.wob_count = 0;
        state.wob_amount = 1;
        state.wob_freq = inst.wobble_freq;

        // Instant vibrato if no delay
        if inst.wobble_delay == 0 {
            state.wob_amount = inst.wobble_max;
        }

        // Set pitch from note
        let note_idx = state.note as usize;
        if note_idx < self.freq_table.len() {
            let period = self.freq_table[note_idx];
            state.low_pitch = period as u8;
            state.high_pitch = (period >> 8) as u8;
        }

        // Tinny tone (duty cycle)
        let duty_start = (inst.tone_control >> 2) & 3;
        state.tin_tone = duty_start << 6;
        state.tin_delay = 0;

        // Triangle linear counter: the 6502 writes attack_rate to $4008.
        // This controls how many frames the triangle sounds before silencing.
        // (6502: LDA INSTRUMENTS+1,Y; STA $4000,Y  where Y=8 for triangle)
        if ch == 2 {
            state.tri_linear_counter = inst.attack_rate;
        }

        // Thud: ch 3 (noise) gets the thud_note value directly,
        // ch 2 (triangle) always starts at 2 (countdown to trigger).
        // (6502: CPX #3; BEQ !WHITE_NOISE; LDA #2; !WHITE_NOISE: STA)
        if inst.thud_note > 0 {
            state.special_thud = if ch == 3 { inst.thud_note } else { 2 };
        }
    }

    /// Process ADSR envelope, thud, vibrato, glissando, chords for all channels.
    /// Order matches the 6502 code exactly:
    ///   1. Volume write + ADSR (skip for triangle)
    ///   2. Special thud (ch >= 2 only: triangle + noise)
    ///   3. Reverb
    ///   4. Tinny tone
    ///   5. Wobble (if no chord/gliss active)
    ///   6. Glissando
    ///   7. Chords
    fn process_adsr(&mut self) {
        for ch in 0..4 {
            if self.channels[ch].finished { continue; }

            let inst_idx = (self.channels[ch].instrument_offset / 12) as usize;
            let inst = self.instruments.get(inst_idx).cloned().unwrap_or_default();

            // Triangle linear counter: the NES decrements at ~240 Hz (4x/frame).
            // The volume is captured BEFORE decrementing (the 6502 writes $4008
            // on trigger_note and the counter runs on subsequent frames).
            // We decrement AFTER capturing output_volume.


            // The 6502 writes volume to $4000 BEFORE running ADSR.
            // Capture the pre-ADSR, pre-effect state for output.
            self.channels[ch].output_volume = self.channels[ch].volume;
            // Triangle: snapshot counter before it gets decremented this frame
            if ch == 2 {
                self.channels[ch].tri_output_counter = self.channels[ch].tri_linear_counter;
            }

            // 1. ADSR envelope (skip for triangle ch 2)
            if ch != 2 {
                if self.channels[ch].voice_delay == 0 {
                    if self.channels[ch].reverb_count == 0 {
                        self.process_envelope(ch, &inst);
                    }
                }
            }

            // Early exit: the 6502 ADSR sustain path checks if sustain_level=0.
            // If so, it jumps to !NO_HIGH, skipping all effects (thud, wobble, etc).
            // This only applies when ADSR has reached the sustain phase (phase >= 2).
            // Triangle skips ADSR entirely so never hits this path.
            if ch != 2 && self.channels[ch].phase >= 2 && inst.sustain_level == 0 {
                continue;
            }

            // 2. Special thud (only ch >= 2: triangle and noise)
            if ch >= 2 {
                self.process_thud(ch, &inst);
            }

            // 3. Reverb
            if inst.reverb > 0 {
                self.process_reverb(ch, &inst);
            }

            // 4. Tinny tone (duty cycle modulation)
            self.process_tinny_tone(ch, &inst);

            // 5. Wobble (only if no chord/gliss active)
            if self.channels[ch].chord_shape == 0 && self.channels[ch].gliss_rate == 0 {
                self.process_vibrato(ch, &inst);
            }

            // 6. Glissando
            if self.channels[ch].gliss_rate > 0 {
                self.process_glissando(ch);
            }

            // 7. Chords
            if self.channels[ch].chord_shape > 0 {
                self.process_chord(ch);
            }

            // Triangle linear counter: decrement AFTER all effects.
            // This ensures the frame that triggers the note gets the full counter
            // value for output (matching the 6502's write-then-count order).
            if ch == 2 && self.channels[ch].tri_linear_counter > 0 {
                self.channels[ch].tri_linear_counter =
                    self.channels[ch].tri_linear_counter.saturating_sub(4);
            }
        }

        // Advance chord counter
        self.chord_counter += 1;
        if self.chord_counter >= 3 {
            self.chord_counter = 0;
        }
    }

    fn process_envelope(&mut self, ch: usize, inst: &Instrument) {
        let state = &mut self.channels[ch];
        match state.phase {
            0 => {
                // Attack
                let new_vol = state.volume.saturating_add(inst.attack_rate);
                if new_vol >= inst.peak_volume {
                    state.volume = inst.peak_volume;
                    state.phase = 1;
                } else {
                    state.volume = new_vol;
                }
            }
            1 => {
                // Decay
                let new_vol = state.volume.saturating_sub(inst.decay_rate);
                if new_vol <= inst.sustain_level {
                    state.volume = inst.sustain_level;
                    state.phase = 2;
                } else {
                    state.volume = new_vol;
                }
            }
            _ => {
                // Sustain
                state.volume = inst.sustain_level;
            }
        }
    }

    /// Process the "special thud" percussion effect.
    ///
    /// For triangle (ch 2): creates a bass drum by loading a low note's period
    /// then sweeping pitch downward (+35 to period each frame).
    ///
    /// For noise (ch 3): rapid pitch change (+199 to low byte) for percussion snap.
    ///
    /// The thud lifecycle:
    ///   trigger_note sets special_thud = 2 (triangle) or thud_note (noise)
    ///   Each frame: countdown decrements. At 0:
    ///     - triangle: set to 255, load thud_note period (bass kick)
    ///     - noise: silence the channel
    ///   When special_thud == 255 (triangle only):
    ///     - Add 35 to period each frame (sweep down)
    ///     - When high_pitch >= 2: stop thud, silence channel
    fn process_thud(&mut self, ch: usize, inst: &Instrument) {
        let state = &mut self.channels[ch];
        if state.special_thud == 0 { return; }

        if ch == 3 {
            // Noise channel: add 199 to low_pitch (wrapping), then countdown
            state.low_pitch = state.low_pitch.wrapping_add(199);
            state.special_thud -= 1;
            if state.special_thud == 0 {
                state.volume = 0;
                state.phase = 2; // sustain (silent)
            }
            return;
        }

        // Triangle channel (ch 2)
        if state.special_thud == 255 {
            // "Doof" sweep: add 35 to period (pitch drops)
            // SUB_VOICE adds to the period (confusing name — see FORMAT.md)
            let period = ((state.high_pitch as u16) << 8) | state.low_pitch as u16;
            let new_period = period.wrapping_add(35);
            state.low_pitch = new_period as u8;
            state.high_pitch = (new_period >> 8) as u8;

            // Stop when high_pitch >= 2 (period too large = pitch too low)
            if state.high_pitch >= 2 {
                state.special_thud = 0;
                state.volume = 0;
                // 6502 also writes silence to APU: $4000,Y = 0, $4002,Y = 6, $4003,Y = $AE
            }
        } else {
            // Countdown phase (2, 1, ...)
            state.special_thud -= 1;
            if state.special_thud == 0 {
                // Countdown reached 0 → trigger the thud: load thud_note period
                state.special_thud = 255;

                let thud_idx = inst.thud_note as usize;
                if thud_idx < self.freq_table.len() {
                    let period = self.freq_table[thud_idx];
                    state.low_pitch = period as u8;
                    state.high_pitch = (period >> 8) as u8;
                }
                // 6502 writes $20 to $4008 (retrigger with linear counter = 32)
                state.tri_linear_counter = 0x20;
            }
        }
    }

    fn process_vibrato(&mut self, ch: usize, inst: &Instrument) {
        let state = &mut self.channels[ch];
        if state.wob_delay < inst.wobble_delay {
            state.wob_delay += 1;
            return;
        }
        if inst.wobble_freq == 0 { return; }

        let amount = state.wob_amount as u16;

        // ADD_VOICE subtracts from period (pitch up).
        // SUB_VOICE adds to period (pitch down).
        // The 6502 operates on the low byte with carry propagation,
        // which is equivalent to 16-bit add/sub for our purposes.
        match state.wob_phase {
            0 | 2 => {
                // Pitch up: ADD_VOICE subtracts amount from period
                let lo = state.low_pitch.wrapping_sub(amount as u8);
                let borrow = if amount as u8 > state.low_pitch { 1u8 } else { 0 };
                state.low_pitch = lo;
                state.high_pitch = state.high_pitch.wrapping_sub(borrow);
            }
            1 => {
                // Pitch down: SUB_VOICE adds amount to period
                // (NOT doubled — the 6502 doubles the freq LIMIT instead)
                let (lo, carry) = state.low_pitch.overflowing_add(amount as u8);
                state.low_pitch = lo;
                if carry { state.high_pitch = state.high_pitch.wrapping_add(1); }
            }
            _ => {}
        }

        state.wob_count += 1;
        // Down phase (phase 1) runs for 2x the normal freq limit.
        // (6502: LDA WOB_FREQ1,X; ASL; JSR DO_WOB_CHECK)
        let limit = if state.wob_phase == 1 {
            inst.wobble_freq.saturating_mul(2)
        } else {
            inst.wobble_freq
        };
        if state.wob_count >= limit {
            state.wob_count = 0;
            state.wob_phase += 1;
            if state.wob_phase >= 3 {
                state.wob_phase = 0;
                if state.wob_amount < inst.wobble_max {
                    state.wob_amount = state.wob_amount.saturating_add(inst.wobble_inc);
                    if state.wob_amount > inst.wobble_max {
                        state.wob_amount = inst.wobble_max;
                    }
                }
            }
        }
    }

    fn process_glissando(&mut self, ch: usize) {
        let state = &mut self.channels[ch];
        if state.gliss_wait > 0 {
            state.gliss_wait -= 1;
            return;
        }

        let rate = state.gliss_rate;
        let speed = (rate >> 1) as u16;
        // Half-speed on even frames if bit 0 set
        if rate & 1 != 0 && self.main_counter & 1 == 0 {
            return;
        }

        let current = ((state.high_pitch as u16) << 8) | state.low_pitch as u16;
        let target_note = state.gliss_new_note as usize;
        if target_note >= self.freq_table.len() { return; }
        let target = self.freq_table[target_note];

        if state.note > state.gliss_new_note {
            // Slide up (period decreases)
            let new_period = current.saturating_sub(speed.max(1));
            state.low_pitch = new_period as u8;
            state.high_pitch = (new_period >> 8) as u8;
            if new_period <= target {
                state.gliss_rate = 0;
                state.low_pitch = target as u8;
                state.high_pitch = (target >> 8) as u8;
            }
        } else {
            // Slide down (period increases)
            let new_period = current.saturating_add(speed.max(1));
            state.low_pitch = new_period as u8;
            state.high_pitch = (new_period >> 8) as u8;
            if new_period >= target {
                state.gliss_rate = 0;
                state.low_pitch = target as u8;
                state.high_pitch = (target >> 8) as u8;
            }
        }
    }

    fn process_chord(&mut self, ch: usize) {
        let state = &mut self.channels[ch];
        let note = match self.chord_counter {
            0 => state.old_note,
            1 => state.old_note.wrapping_add(state.chord_shape >> 4),
            _ => state.old_note.wrapping_add(state.chord_shape & 0x0F),
        };
        let idx = note as usize;
        if idx < self.freq_table.len() {
            let period = self.freq_table[idx];
            state.low_pitch = period as u8;
            state.high_pitch = (period >> 8) as u8;
        }
    }

    fn process_reverb(&mut self, ch: usize, inst: &Instrument) {
        let state = &mut self.channels[ch];
        let rev = inst.reverb;
        let half = rev / 2;

        state.reverb_count += 1;
        if state.reverb_count >= rev {
            state.reverb_count = 0;
            state.volume = state.echo_hold;
        } else if state.reverb_count == half {
            state.echo_hold = state.volume;
            state.volume = 0;
        } else if state.reverb_count > half {
            state.volume = 0;
        }
    }

    fn process_tinny_tone(&mut self, ch: usize, inst: &Instrument) {
        let state = &mut self.channels[ch];
        let pulse_period = (inst.tone_control >> 4) & 0x0F;
        if pulse_period > 0 {
            // Constant pulse mode
            state.tin_delay += 1;
            if state.tin_delay >= pulse_period * 2 {
                state.tin_delay = 0;
                state.tin_tone = state.tin_tone.wrapping_add(0x40);
            }
        } else {
            // One-shot mode: cycle duty (adding 0x40 each frame) until the
            // 2-bit counter matches the target count.
            // Stops when (tin_tone >> 6) == changes.
            // The 6502 wraps 0xC0+0x40 → 0x00 (not 0x100).
            let changes = inst.tone_control & 3;
            let current = state.tin_tone >> 6;
            if current != changes {
                state.tin_tone = state.tin_tone.wrapping_add(0x40) & 0xC0;
            }
        }
    }

    fn build_output(&self) -> FrameOutput {
        let mut out = FrameOutput::default();
        for ch in 0..4 {
            let state = &self.channels[ch];
            if state.finished {
                out.channels[ch].enabled = false;
                continue;
            }
            let period = ((state.high_pitch as u16) << 8) | state.low_pitch as u16;
            out.channels[ch].period = period & 0x7FF; // 11-bit
            out.channels[ch].duty = state.tin_tone >> 6;

            if ch == 2 {
                // Triangle: enabled is controlled by the linear counter.
                // Use the pre-decrement snapshot so the trigger frame gets output.
                let active = state.tri_output_counter > 0 && state.volume > 0;
                out.channels[ch].volume = if active { 15 } else { 0 };
                out.channels[ch].enabled = state.voice_delay == 0 && active && period > 0;
            } else if ch == 3 {
                // Noise: $400E uses only the low byte of the period.
                out.channels[ch].period = (state.low_pitch & 0x0F) as u16;
                let vol4 = state.output_volume >> 4;
                out.channels[ch].volume = vol4;
                out.channels[ch].enabled = state.voice_delay == 0 && vol4 > 0;
            } else {
                // Pulse: use pre-ADSR volume. Enable only when 4-bit volume > 0.
                let vol4 = state.output_volume >> 4;
                out.channels[ch].volume = vol4;
                out.channels[ch].enabled = state.voice_delay == 0 && vol4 > 0;
            }
        }
        out
    }
}

impl Default for Instrument {
    fn default() -> Self {
        Instrument {
            start_volume: 0, attack_rate: 0, peak_volume: 0,
            decay_rate: 0, sustain_level: 0, tone_control: 0,
            wobble_delay: 0, wobble_freq: 0, wobble_inc: 0,
            wobble_max: 0, reverb: 0, thud_note: 0,
        }
    }
}
