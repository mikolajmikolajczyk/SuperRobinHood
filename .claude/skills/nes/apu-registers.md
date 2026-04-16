# APU Registers — Full Reference

The APU (Audio Processing Unit) is integrated into the 2A03/2A07 chip.
It has 5 channels: 2 pulse waves, 1 triangle, 1 noise, and 1 DMC (sample playback).
All registers are write-only except $4015 (R/W).

## Pulse Channel 1: $4000–$4003

### $4000 — Duty / Length Halt / Constant Volume / Volume
```
7654 3210
DDLC VVVV
|||| ||||
|||| ++++- Volume (if C=1) or envelope period (if C=0)
|||+------ Constant volume flag (0=envelope, 1=constant)
||+------- Length counter halt / envelope loop (0=one-shot, 1=loop/halt)
++-------- Duty cycle: 00=12.5%, 01=25%, 10=50%, 11=75% (negated 25%)
```

### $4001 — Sweep Unit
```
7654 3210
EPPP NSSS
|||| ||||
|||| |+++- Shift count (0-7)
|||| +---- Negate flag (0=add to period, 1=subtract)
|+++------ Sweep period (reload value)
+--------- Sweep enable
```
Pulse 1 uses one's complement for negate (subtract - 1).

### $4002 — Timer Low
```
7654 3210
TTTT TTTT — Timer low 8 bits
```

### $4003 — Length Counter Load / Timer High
```
7654 3210
LLLL LTTT
|||| |+++- Timer high 3 bits (total 11-bit timer)
++++-+---- Length counter load value (index into lookup table)
```
Writing this register resets the phase and restarts the envelope.

## Pulse Channel 2: $4004–$4007

Identical layout to Pulse 1 ($4000–$4003).
Difference: Pulse 2 uses two's complement for sweep negate (subtract).

## Triangle Channel: $4008–$400B

### $4008 — Linear Counter / Length Halt
```
7654 3210
CRRR RRRR
|||| ||||
|+++-++++- Linear counter reload value (0-127)
+--------- Length counter halt / linear counter control
```

### $4009 — Unused

### $400A — Timer Low
```
TTTT TTTT — Timer low 8 bits
```

### $400B — Length Counter Load / Timer High
```
LLLL LTTT — Same format as pulse $4003
```
Triangle has no volume control — it's either on or off. Volume is
effectively controlled by the linear counter period.

## Noise Channel: $400C–$400F

### $400C — Length Halt / Constant Volume / Volume
```
7654 3210
--LC VVVV — Same as pulse $4000 bits 0-5 (no duty cycle)
```

### $400D — Unused

### $400E — Mode / Period
```
7654 3210
M--- PPPP
|    ||||
|    ++++- Noise period index (0-15, lookup table)
+--------- Mode (0=long sequence 32767 steps, 1=short sequence 93 steps)
```

Short mode (M=1) produces a more metallic/harsh tone.

### $400F — Length Counter Load
```
7654 3210
LLLL L--- — Length counter load (upper 5 bits)
```

## DMC (Delta Modulation Channel): $4010–$4013

### $4010 — Flags and Rate
```
7654 3210
IL-- RRRR
||   ||||
||   ++++- Rate index (0-15, determines playback speed)
|+-------- Loop flag
+--------- IRQ enable (generates IRQ when sample finishes)
```

### $4011 — Direct Load (7-bit)
```
7654 3210
-DDD DDDD — Direct load value (0-127), output level
```
Writing here directly sets the DMC output level. Can be used for
crude PCM playback by writing values every cycle.

### $4012 — Sample Address
```
7654 3210
AAAA AAAA
```
Sample address = $C000 + (A × 64). Range: $C000–$FFFF.

### $4013 — Sample Length
```
7654 3210
LLLL LLLL
```
Sample length = (L × 16) + 1 bytes. Range: 1–4081 bytes.

## $4014 — OAM DMA

Not strictly APU, but lives in the APU register space.
Writing a page number (e.g., $02) copies 256 bytes from CPU $0200–$02FF
to PPU OAM. Takes 513 or 514 CPU cycles (depending on odd/even cycle).

## $4015 — APU Status (Read/Write)

### Write:
```
7654 3210
---D NT21
    ||||
    |||+- Enable Pulse 1 (1=enable, 0=silence and reset length)
    ||+-- Enable Pulse 2
    |+--- Enable Triangle
    +---- Enable Noise
---+----- Enable DMC (1=restart if sample finished, 0=stop)
```

### Read:
```
7654 3210
IF-D NT21
||||
|||+- Pulse 1 length counter > 0
||+-- Pulse 2 length counter > 0
|+--- Triangle length counter > 0
+---- Noise length counter > 0
-+--- DMC active (sample bytes remaining)
+---- Frame interrupt flag
-+--- DMC interrupt flag
```
Reading $4015 clears the frame interrupt flag.

## $4016 — Controller Port 1 / Strobe

### Write:
```
---- ---S — Strobe bit. While S=1, controllers continuously reload.
             Set S=1 then S=0 to latch button states.
```

### Read:
```
---- ---D — Serial button data (one bit per read)
```
Read 8 times for: A, B, Select, Start, Up, Down, Left, Right.

## $4017 — Controller Port 2 (Read) / APU Frame Counter (Write)

### Read: Same as $4016 but for controller 2.

### Write (Frame Counter):
```
7654 3210
MI-- ----
||
|+-------- IRQ inhibit (1=disable frame IRQ)
+--------- Sequencer mode (0=4-step, 1=5-step)
```

4-step mode: clocks envelope/linear at 240 Hz, length/sweep at 120 Hz,
generates frame IRQ at ~60 Hz.

5-step mode: same clocks but 5th step is empty, no IRQ generated,
effective rate ~48 Hz (NTSC).

Writing to $4017 resets the frame counter sequencer.

## Length Counter Lookup Table

| Index | Value | Index | Value |
|-------|-------|-------|-------|
| $00 | 10 | $01 | 254 |
| $02 | 20 | $03 | 2 |
| $04 | 40 | $05 | 4 |
| $06 | 80 | $07 | 6 |
| $08 | 160 | $09 | 8 |
| $0A | 60 | $0B | 10 |
| $0C | 14 | $0D | 12 |
| $0E | 26 | $0F | 14 |
| $10 | 12 | $11 | 16 |
| $12 | 24 | $13 | 18 |
| $14 | 48 | $15 | 20 |
| $16 | 96 | $17 | 22 |
| $18 | 192 | $19 | 24 |
| $1A | 72 | $1B | 26 |
| $1C | 16 | $1D | 28 |
| $1E | 32 | $1F | 30 |

## Frequency Calculation (Pulse/Triangle)

```
freq_hz = CPU_clock / (16 × (timer_value + 1))     [Pulse channels]
freq_hz = CPU_clock / (32 × (timer_value + 1))     [Triangle channel]

CPU_clock = 1789773 Hz (NTSC) / 1662607 Hz (PAL)
timer_value = 11-bit value from registers ($4002/$4003 etc.)
```

## DMC Rate Table (NTSC)

| Index | Rate (CPU cycles/sample) | Freq (Hz) |
|-------|--------------------------|-----------|
| $0 | 428 | 4181.71 |
| $1 | 380 | 4709.93 |
| $2 | 340 | 5264.04 |
| $3 | 320 | 5593.04 |
| $4 | 286 | 6257.95 |
| $5 | 254 | 7046.35 |
| $6 | 226 | 7919.35 |
| $7 | 214 | 8363.42 |
| $8 | 190 | 9419.86 |
| $9 | 160 | 11186.1 |
| $A | 142 | 12604.0 |
| $B | 128 | 13982.6 |
| $C | 106 | 16884.6 |
| $D | 84 | 21306.8 |
| $E | 72 | 24858.0 |
| $F | 54 | 33143.9 |
