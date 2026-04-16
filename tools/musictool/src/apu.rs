/// Minimal NES APU synthesis — enough to render the music engine output.
///
/// Generates audio samples from the per-frame channel states produced by
/// the engine. Not a cycle-accurate APU emulation, but good enough for
/// recognisable playback.

use crate::engine::ChannelOutput;

const CPU_CLOCK: f64 = 1_789_773.0; // NTSC
const SAMPLE_RATE: u32 = 44_100;

/// Duty cycle waveforms for pulse channels.
/// Each entry is the fraction of the period that is "high".
const DUTY_CYCLES: [f64; 4] = [0.125, 0.25, 0.5, 0.75];

/// Noise channel period lookup table (NTSC).
const NOISE_PERIODS: [u16; 16] = [
    4, 8, 16, 32, 64, 96, 128, 160, 202, 254, 380, 508, 762, 1016, 2034, 4068,
];

/// Per-channel synthesis state.
#[derive(Default)]
struct ChannelSynth {
    phase: f64,        // 0.0–1.0, wraps
    noise_lfsr: u16,   // 15-bit LFSR for noise
}

/// Audio renderer that converts engine frame outputs into PCM samples.
pub struct Renderer {
    channels: [ChannelSynth; 4],
    sample_rate: u32,
}

impl Renderer {
    pub fn new() -> Self {
        Renderer {
            channels: [
                ChannelSynth { phase: 0.0, noise_lfsr: 1 },
                ChannelSynth { phase: 0.0, noise_lfsr: 1 },
                ChannelSynth { phase: 0.0, noise_lfsr: 1 },
                ChannelSynth { phase: 0.0, noise_lfsr: 1 },
            ],
            sample_rate: SAMPLE_RATE,
        }
    }

    pub fn sample_rate(&self) -> u32 {
        self.sample_rate
    }

    /// Render one frame's worth of audio samples (~735 samples at 44100 Hz / 60 fps).
    pub fn render_frame(&mut self, channels: &[ChannelOutput; 4]) -> Vec<f32> {
        let samples_per_frame = self.sample_rate as usize / 60;
        let mut buffer = Vec::with_capacity(samples_per_frame);

        for _ in 0..samples_per_frame {
            let mut mix = 0.0f64;

            // Pulse 1
            mix += self.render_pulse(0, &channels[0]);
            // Pulse 2
            mix += self.render_pulse(1, &channels[1]);
            // Triangle
            mix += self.render_triangle(&channels[2]);
            // Noise
            mix += self.render_noise(&channels[3]);

            // Simple mix — scale to avoid clipping
            buffer.push((mix * 0.25) as f32);
        }

        buffer
    }

    fn render_pulse(&mut self, ch: usize, output: &ChannelOutput) -> f64 {
        if !output.enabled || output.period < 8 || output.volume == 0 {
            return 0.0;
        }

        let freq = CPU_CLOCK / (16.0 * (output.period as f64 + 1.0));
        let duty = DUTY_CYCLES[output.duty as usize & 3];
        let volume = output.volume as f64 / 15.0;

        let synth = &mut self.channels[ch];
        synth.phase += freq / self.sample_rate as f64;
        if synth.phase >= 1.0 { synth.phase -= 1.0; }

        let sample = if synth.phase < duty { 1.0 } else { -1.0 };
        sample * volume
    }

    fn render_triangle(&mut self, output: &ChannelOutput) -> f64 {
        if !output.enabled || output.period < 2 {
            return 0.0;
        }

        // NES triangle uses 32 steps (4-bit): 15,14,13,...,1,0,0,1,...,13,14,15
        // The sequence has 32 entries, clocked at CPU/(32*(period+1)) per step
        // One full wave = 32 steps
        let freq = CPU_CLOCK / (32.0 * (output.period as f64 + 1.0));
        let synth = &mut self.channels[2];
        synth.phase += freq / self.sample_rate as f64;
        if synth.phase >= 1.0 { synth.phase -= 1.0; }

        // 32-step quantised triangle (matches real NES hardware)
        let step = (synth.phase * 32.0) as u32 % 32;
        let value = if step < 16 { 15 - step } else { step - 16 };
        // Convert 0-15 range to -1.0..+1.0
        let sample = (value as f64 / 7.5) - 1.0;
        sample * 0.8
    }

    fn render_noise(&mut self, output: &ChannelOutput) -> f64 {
        if !output.enabled || output.volume == 0 {
            return 0.0;
        }

        // Use period as index into noise period table
        let period_idx = (output.period as usize) & 0x0F;
        let period = NOISE_PERIODS[period_idx] as f64;
        let freq = CPU_CLOCK / (16.0 * period);
        let volume = output.volume as f64 / 15.0;

        let synth = &mut self.channels[3];
        synth.phase += freq / self.sample_rate as f64;

        // Clock LFSR when phase wraps
        if synth.phase >= 1.0 {
            synth.phase -= 1.0;
            // 15-bit LFSR: feedback = bit0 XOR bit1 (short mode: bit0 XOR bit6)
            let feedback = (synth.noise_lfsr & 1) ^ ((synth.noise_lfsr >> 1) & 1);
            synth.noise_lfsr >>= 1;
            synth.noise_lfsr |= feedback << 14;
        }

        let sample = if synth.noise_lfsr & 1 == 0 { 1.0 } else { -1.0 };
        sample * volume * 0.5 // Noise is quieter in the mix
    }
}
