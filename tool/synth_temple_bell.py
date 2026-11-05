#!/usr/bin/env python3
"""Synthesize a Korean temple bell (범종) strike as a 6-second mono WAV.

    python3 tool/synth_temple_bell.py out.wav
    ffmpeg -y -i out.wav -codec:a libmp3lame -b:a 96k assets/sounds/temple_bell.mp3

Model: a wooden striker (당목) thud + inharmonic bell partials. Each partial is a
pair of slightly detuned sines, which gives the slow "맥놀이" (beating) a Korean
bell is known for. Lower partials ring longer; the last 0.8 s fades out.
Partials sit high enough (>= 150 Hz carries most energy) to be heard on a phone
speaker, with a 75 Hz hum underneath for weight on headphones.
Pure standard library (no numpy).
"""
import math
import random
import struct
import sys
import wave

RATE = 44100
DURATION = 6.0
FADE_OUT = 0.8
BASE = 150.0  # Hz, fundamental

# (ratio to BASE, amplitude, decay time constant s, beat Hz)
PARTIALS = [
    (0.5, 0.55, 4.5, 0.35),   # hum
    (1.0, 1.00, 3.8, 0.70),   # fundamental, strongest beating
    (1.19, 0.35, 3.0, 0.50),  # minor third (tierce-like)
    (1.52, 0.45, 2.6, 0.90),
    (2.0, 0.60, 2.4, 0.60),
    (2.53, 0.30, 1.8, 1.10),
    (3.04, 0.32, 1.5, 0.80),
    (4.11, 0.18, 1.0, 1.30),
    (5.37, 0.10, 0.7, 1.70),
    (6.82, 0.06, 0.45, 2.10),
]


def main(out_path: str) -> None:
    random.seed(108)
    n = int(RATE * DURATION)
    fade_start = int(RATE * (DURATION - FADE_OUT))
    phases = [random.random() * 2 * math.pi for _ in PARTIALS]
    samples = [0.0] * n

    for (ratio, amp, tau, beat), ph in zip(PARTIALS, phases):
        f1 = BASE * ratio - beat / 2
        f2 = BASE * ratio + beat / 2
        w1 = 2 * math.pi * f1 / RATE
        w2 = 2 * math.pi * f2 / RATE
        k = 1.0 / (tau * RATE)
        for i in range(n):
            env = math.exp(-i * k)
            samples[i] += amp * env * 0.5 * (math.sin(w1 * i + ph) + math.sin(w2 * i + ph * 1.3))

    # Wooden striker thud: low-passed noise burst, ~60 ms.
    lp = 0.0
    thud_len = int(RATE * 0.06)
    for i in range(thud_len):
        lp += 0.08 * (random.uniform(-1, 1) - lp)
        samples[i] += 2.5 * lp * math.exp(-i / (RATE * 0.015))

    # Soft attack (5 ms) to avoid a click, and fade out at the end.
    attack = int(RATE * 0.005)
    for i in range(attack):
        samples[i] *= i / attack
    for i in range(fade_start, n):
        t = (i - fade_start) / (n - fade_start)
        samples[i] *= 0.5 * (1 + math.cos(math.pi * t))

    peak = max(abs(s) for s in samples)
    gain = 0.74 / peak  # about -2.6 dBFS, same peak as bell.mp3
    with wave.open(out_path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", int(s * gain * 32767)) for s in samples))


if __name__ == "__main__":
    main(sys.argv[1])
