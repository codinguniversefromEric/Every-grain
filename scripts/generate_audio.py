"""
Procedural ambient audio generator for 粒粒.
Run: python scripts/generate_audio.py
"""
import math
import wave
import array
import random
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
AUDIO_DIR = os.path.join(PROJECT_ROOT, 'assets', 'audio')
os.makedirs(AUDIO_DIR, exist_ok=True)

SR = 44100


# ---------- 基礎工具 ----------

def write_wav(name, samples, sr=SR):
    path = os.path.join(AUDIO_DIR, name)
    buf = array.array('h', (max(-32768, min(32767, int(s * 32767))) for s in samples))
    with wave.open(path, 'w') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(sr)
        f.writeframes(buf.tobytes())
    print(f'  {name}  ({len(samples) / sr:.1f}s)')


def seamless(samples, fade=0.3, sr=SR):
    """頭尾交叉淡化，讓 loop 接縫聽不出來。"""
    n = int(sr * fade)
    out = samples[:-n]
    for i in range(n):
        w = i / n
        out[i] = out[i] * w + samples[-n + i] * (1 - w)
    return out


def noise(dur, lp=1.0, sr=SR):
    """一階低通濾波的白噪音。lp 越小越悶。"""
    out, last = [], 0.0
    for _ in range(int(sr * dur)):
        last += lp * (random.uniform(-1, 1) - last)
        out.append(last)
    return out


def silence(dur, sr=SR):
    return [0.0] * int(sr * dur)


def add_tone(buf, start, length, freq, amp, env='sine', vibrato=0.0, sr=SR):
    """在 buf 上疊一段正弦音。env: sine / decay / attack"""
    s0 = int(sr * start)
    n = int(sr * length)
    for i in range(n):
        if s0 + i >= len(buf):
            break
        t = i / sr
        p = i / n
        if env == 'sine':
            e = math.sin(math.pi * p)
        elif env == 'decay':
            e = math.exp(-p * 6)
        else:  # attack
            e = min(1.0, p * 4) * (1 - p)
        f = freq * (1 + vibrato * math.sin(2 * math.pi * 40 * t))
        buf[s0 + i] += amp * e * math.sin(2 * math.pi * f * t)


def normalize(buf, peak=0.8):
    m = max(abs(x) for x in buf) or 1.0
    return [x / m * peak for x in buf]


# ---------- 底層：風 / 天氣 / 地形 ----------

def wind_base():
    s = noise(10.0, lp=0.02)
    for i, _ in enumerate(s):
        t = i / SR
        s[i] *= 0.5 + 0.3 * math.sin(2 * math.pi * 0.12 * t) + 0.1 * math.sin(2 * math.pi * 0.37 * t)
    write_wav('wind_base.wav', seamless(normalize(s, 0.6)))


def sea_wind():
    s = noise(10.0, lp=0.04)
    for i, _ in enumerate(s):
        s[i] *= 0.6 + 0.3 * math.sin(2 * math.pi * 0.2 * (i / SR))
    write_wav('sea_wind.wav', seamless(normalize(s, 0.6)))


def rain_light():
    s = noise(8.0, lp=0.35)
    write_wav('rain_light.wav', seamless(normalize(s, 0.5)))


def rain_heavy():
    s = noise(8.0, lp=0.25)
    write_wav('rain_heavy.wav', seamless(normalize(s, 0.8)))


def storm():
    s = noise(10.0, lp=0.1)
    gust = noise(10.0, lp=0.005)
    for i, _ in enumerate(s):
        s[i] *= 0.6 + 0.6 * abs(gust[i])
    write_wav('storm.wav', seamless(normalize(s, 0.9)))


def ocean_waves():
    s = noise(12.0, lp=0.08)
    for i, _ in enumerate(s):
        t = i / SR
        env = (math.sin(2 * math.pi * t / 6.0) + 1) / 2
        s[i] *= 0.15 + 0.85 * env ** 2
    write_wav('ocean_waves.wav', seamless(normalize(s, 0.7)))


def valley_echo():
    s = noise(10.0, lp=0.01)
    d = int(SR * 0.8)
    for i in range(d, len(s)):
        s[i] += 0.4 * s[i - d]
    write_wav('valley_echo.wav', seamless(normalize(s, 0.5)))


# ---------- 生物層 ----------

def spring_frogs():
    dur = 10.0
    s = silence(dur)
    # 三隻蛙，不同音高與節奏，錯開
    for base, rate, phase in [(110, 1.8, 0.0), (140, 2.3, 0.4), (95, 1.5, 0.9)]:
        t = phase
        while t < dur - 0.3:
            add_tone(s, t, 0.18, base, 0.25, env='attack', vibrato=0.03)
            add_tone(s, t, 0.18, base * 2, 0.08, env='attack')
            t += 1.0 / rate + random.uniform(-0.1, 0.1)
    write_wav('spring_frogs.wav', seamless(normalize(s, 0.6)))


def summer_cicadas():
    dur = 10.0
    s = []
    for i in range(int(SR * dur)):
        t = i / SR
        swell = 0.6 + 0.4 * math.sin(2 * math.pi * 0.25 * t)
        buzz = math.sin(2 * math.pi * 4200 * t) * (0.7 + 0.3 * math.sin(2 * math.pi * 110 * t))
        s.append(swell * buzz * random.uniform(0.6, 1.0) * 0.3)
    write_wav('summer_cicadas.wav', seamless(normalize(s, 0.5)))


def autumn_crickets():
    dur = 10.0
    s = silence(dur)
    for freq, rate, phase in [(4800, 6.0, 0.0), (5200, 5.0, 0.3)]:
        t = phase
        while t < dur - 0.1:
            add_tone(s, t, 0.06, freq, 0.3, env='sine')
            t += 1.0 / rate
    write_wav('autumn_crickets.wav', seamless(normalize(s, 0.5)))


def winter_birds_wind():
    s = noise(10.0, lp=0.03)
    s = [x * 0.5 for x in s]
    for _ in range(5):
        start = random.uniform(0.5, 9.0)
        for k in range(random.randint(2, 4)):
            add_tone(s, start + k * 0.15, 0.1, random.uniform(2800, 3600), 0.15, env='sine')
    write_wav('winter_birds_wind.wav', seamless(normalize(s, 0.5)))


def spring_birds():
    s = noise(10.0, lp=0.03)
    s = [x * 0.2 for x in s]
    for _ in range(14):
        start = random.uniform(0.3, 9.5)
        f0 = random.uniform(2200, 3800)
        for k in range(random.randint(3, 6)):
            add_tone(s, start + k * 0.09, 0.07, f0 * (1 + 0.1 * math.sin(k)), 0.18, env='sine')
    write_wav('spring_birds.wav', seamless(normalize(s, 0.5)))


def rustling_ears():
    # 稻穗摩擦：高通噪音 + 隨風起伏
    s = noise(10.0, lp=0.6)
    gust = noise(10.0, lp=0.004)
    for i, _ in enumerate(s):
        s[i] *= 0.3 + 0.7 * abs(gust[i])
    write_wav('rustling_ears.wav', seamless(normalize(s, 0.4)))


# ---------- 點綴（one-shot，不 loop）----------

def water_drip():
    s = silence(0.5)
    for i, _ in enumerate(s):
        t = i / SR
        f = 400 + 8000 * t * math.exp(-t * 20)
        s[i] = math.exp(-t * 10) * max(0.0, 0.5 - t) * math.sin(2 * math.pi * f * t)
    write_wav('water_drip.wav', normalize(s, 0.6))


def distant_thunder():
    s = noise(3.5, lp=0.08)
    for i, _ in enumerate(s):
        t = i / SR
        e = math.exp(-t * 0.9) * min(1.0, t * 8)
        s[i] *= e
    write_wav('distant_thunder.wav', normalize(s, 0.8))


def bird_chirp():
    s = silence(0.35)
    add_tone(s, 0.0, 0.3, 2500, 0.4, env='sine')
    for i, _ in enumerate(s):  # 上揚
        t = i / SR
        s[i] = s[i] * math.sin(2 * math.pi * (2500 + 2000 * t / 0.3) * t) if s[i] else 0
    write_wav('bird_chirp.wav', normalize(s, 0.5))


def rooster():
    s = silence(1.3)
    for a, l, f in [(0.0, 0.2, 700), (0.25, 0.2, 900), (0.5, 0.2, 1100), (0.75, 0.5, 820)]:
        add_tone(s, a, l, f, 0.4, env='sine', vibrato=0.05)
        add_tone(s, a, l, f * 2, 0.1, env='sine', vibrato=0.05)
    write_wav('rooster.wav', normalize(s, 0.7))


def owl():
    s = silence(1.2)
    add_tone(s, 0.0, 0.35, 380, 0.4, env='sine')
    add_tone(s, 0.5, 0.6, 360, 0.4, env='sine')
    write_wav('owl.wav', normalize(s, 0.5))


def distant_dog():
    s = silence(1.0)
    for a in (0.0, 0.35, 0.7):
        add_tone(s, a, 0.2, 500, 0.3, env='decay', vibrato=0.08)
        add_tone(s, a, 0.2, 750, 0.15, env='decay', vibrato=0.08)
    write_wav('distant_dog.wav', normalize(s, 0.4))


def distant_train():
    s = noise(5.0, lp=0.03)
    for i, _ in enumerate(s):
        t = i / SR
        clack = 1.0 if (t * 3) % 1 < 0.08 else 0.35
        s[i] *= clack * math.sin(math.pi * t / 5.0)
    write_wav('distant_train.wav', normalize(s, 0.5))


def scooter_pass():
    s = noise(3.0, lp=0.2)
    for i, _ in enumerate(s):
        t = i / SR
        doppler = 1.0 - 0.3 * (t / 3.0)
        s[i] = s[i] * 0.4 + 0.5 * math.sin(2 * math.pi * 90 * doppler * t)
        s[i] *= math.sin(math.pi * t / 3.0) ** 2
    write_wav('scooter_pass.wav', normalize(s, 0.5))


def harvest_slice():
    s = silence(0.4)
    for i, _ in enumerate(s):
        t = i / SR
        f = 1000 * math.exp(-t * 20)
        s[i] = math.exp(-t * 15) * (random.uniform(-1, 1) * 0.6 + math.sin(2 * math.pi * f * t) * 0.4)
    write_wav('harvest_slice.wav', normalize(s, 0.7))


# ---------- 入口 ----------

if __name__ == '__main__':
    random.seed(42)
    print(f'Generating into {AUDIO_DIR}')
    for fn in [
        # 底層
        wind_base, sea_wind, rain_light, rain_heavy, storm, ocean_waves, valley_echo,
        # 生物
        spring_frogs, summer_cicadas, autumn_crickets, winter_birds_wind, spring_birds, rustling_ears,
        # 點綴
        water_drip, distant_thunder, bird_chirp, rooster, owl, distant_dog, distant_train, scooter_pass,
        harvest_slice,
    ]:
        fn()
    print('Done.')