import math
import wave
import struct
import random
import os

# Ensure the output directory exists relative to the script
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
AUDIO_DIR = os.path.join(PROJECT_ROOT, 'assets', 'audio')

if not os.path.exists(AUDIO_DIR):
    os.makedirs(AUDIO_DIR)

def write_wav(filename, samples, sample_rate=44100):
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        # Convert floats (-1 to 1) to short integers
        data = bytearray()
        for s in samples:
            val = int(s * 32767)
            if val > 32767: val = 32767
            if val < -32768: val = -32768
            data.extend(struct.pack('<h', val))
        wav_file.writeframesraw(data)

def generate_water_drip(filename):
    sr = 44100
    dur = 0.5
    samples = []
    for i in range(int(sr * dur)):
        t = i / sr
        freq = 400 + (t * 8000) * math.exp(-t * 20)
        amp = math.exp(-t * 10) * (0.5 - t)
        if amp < 0: amp = 0
        samples.append(amp * math.sin(2 * math.pi * freq * t))
    write_wav(filename, samples, sr)

def generate_thunder(filename):
    sr = 44100
    dur = 3.0
    samples = []
    last_val = 0
    for i in range(int(sr * dur)):
        t = i / sr
        noise = random.uniform(-1, 1)
        val = last_val + 0.1 * (noise - last_val) # low pass
        last_val = val
        amp = math.exp(-t)
        if t > 0.5: amp *= (3.0 - t) / 2.5
        samples.append(amp * val * 2.0)
    write_wav(filename, samples, sr)

def generate_noise(dur, filter_factor=1.0):
    sr = 44100
    samples = []
    last_val = 0
    for i in range(int(sr * dur)):
        noise = random.uniform(-1, 1)
        val = last_val + filter_factor * (noise - last_val)
        last_val = val
        samples.append(val)
    return samples

def generate_rain(filename):
    # Pink noise approximation for rain
    samples = generate_noise(2.0, filter_factor=0.3)
    write_wav(filename, samples)

def generate_storm(filename):
    # Heavy pink noise for storm
    samples = generate_noise(2.0, filter_factor=0.1)
    write_wav(filename, [s * 1.5 for s in samples])

def generate_winter_birds_wind(filename):
    # Wind (lowpass noise) + occasional high pitch chirps
    sr = 44100
    dur = 4.0
    samples = generate_noise(dur, filter_factor=0.05) # deep wind
    # Add bird chirps
    for i in range(int(sr * dur)):
        t = i / sr
        if 1.0 < t < 1.2 or 2.5 < t < 2.6:
            freq = 3000 + 1000 * math.sin(t * 20)
            amp = math.exp(-(t - 1.0)*10) if t < 2.0 else math.exp(-(t - 2.5)*10)
            samples[i] += amp * math.sin(2 * math.pi * freq * t) * 0.1
    write_wav(filename, samples, sr)

def generate_spring_frogs(filename):
    # Rhythmic low frequency croaks
    sr = 44100
    dur = 2.0
    samples = []
    for i in range(int(sr * dur)):
        t = i / sr
        croak_env = math.sin(2 * math.pi * 2 * t) # 2 croaks per second
        if croak_env < 0: croak_env = 0
        samples.append(croak_env * math.sin(2 * math.pi * 100 * t) * 0.5)
    write_wav(filename, samples, sr)

def generate_summer_cicadas(filename):
    # Continuous high-frequency buzz
    sr = 44100
    dur = 2.0
    samples = []
    for i in range(int(sr * dur)):
        t = i / sr
        buzz_env = 0.8 + 0.2 * math.sin(2 * math.pi * 5 * t)
        samples.append(buzz_env * random.uniform(-1, 1) * math.sin(2 * math.pi * 4000 * t) * 0.3)
    write_wav(filename, samples, sr)

def generate_autumn_crickets(filename):
    # Rhythmic high frequency chirps
    sr = 44100
    dur = 2.0
    samples = []
    for i in range(int(sr * dur)):
        t = i / sr
        chirp_env = math.sin(2 * math.pi * 4 * t)
        if chirp_env < 0: chirp_env = 0
        samples.append(chirp_env * math.sin(2 * math.pi * 5000 * t) * 0.4)
    write_wav(filename, samples, sr)

def generate_harvest_slice(filename):
    # Quick whoosh/slice sound
    sr = 44100
    dur = 0.4
    samples = []
    for i in range(int(sr * dur)):
        t = i / sr
        freq = 1000 * math.exp(-t * 20)
        amp = math.exp(-t * 15)
        samples.append(amp * (random.uniform(-1, 1) + math.sin(2 * math.pi * freq * t)) * 0.5)
    write_wav(filename, samples, sr)

if __name__ == '__main__':
    generate_water_drip(os.path.join(AUDIO_DIR, 'water_drip.wav'))
    generate_thunder(os.path.join(AUDIO_DIR, 'distant_thunder.wav'))
    generate_rain(os.path.join(AUDIO_DIR, 'rain.wav'))
    generate_storm(os.path.join(AUDIO_DIR, 'storm.wav'))
    generate_winter_birds_wind(os.path.join(AUDIO_DIR, 'winter_birds_wind.wav'))
    generate_spring_frogs(os.path.join(AUDIO_DIR, 'spring_frogs.wav'))
    generate_summer_cicadas(os.path.join(AUDIO_DIR, 'summer_cicadas.wav'))
    generate_autumn_crickets(os.path.join(AUDIO_DIR, 'autumn_crickets.wav'))
    generate_harvest_slice(os.path.join(AUDIO_DIR, 'harvest_slice.wav'))
    
    print(f"Successfully generated all procedural ambient loops and sound effects in {AUDIO_DIR}")
