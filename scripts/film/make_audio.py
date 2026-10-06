# Builds the soundtrack for motorcycle_titled.mp4 (make_edit.py output: film + end card): music edit + synthesized SFX + engine, then muxes it.
# Run:  python make_audio.py            (from anywhere; paths below are absolute)
# All times are film seconds (24 fps, 67.5 s of film, then a 3 s end card). Tweak the GAIN_* constants / cue lists and re-run.
import os, subprocess, json
import numpy as np
from scipy.signal import butter, sosfiltfilt, stft, istft, fftconvolve
from scipy.io import wavfile

R = r"C:\Users\micheal\Downloads\motorcyle\renders"
VIDEO = os.path.join(R, "motorcycle_titled.mp4")
MUSIC = os.path.join(R, "kulakovka-hard-edm-281146.mp3")
ENGINE = os.path.join(R, "engine-audio.mp3")
OUT_DIR = os.path.join(R, "audio")
VERSION = "v2"
SR = 48000
FILM_LEN = 67.5
END_CARD = 3.0
N = int((FILM_LEN + END_CARD) * SR)
rng = np.random.default_rng(7)

# music grid: 110 BPM, first downbeat 0.012 s
BAR = 4 * 60 / 110
def tbar(k): return 0.012 + k * BAR

GAIN_MUSIC = 0.5
GAIN_ENGINE = 3.6
GAIN_WHOOSH_SMALL, GAIN_WHOOSH_BIG = 0.65, 0.95
GAIN_CLICK, GAIN_TICK, GAIN_BOOM = 0.45, 0.45, 0.45
GAIN_END_WASH = 0.7


def load(path):
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", path, "-ac", "2", "-ar", str(SR), "-f", "f32le", "-"],
                         capture_output=True, check=True).stdout
    return np.frombuffer(raw, np.float32).reshape(-1, 2).T.copy()


def place(dst, src, t, gain=1.0):
    i = int(round(t * SR)); src = np.atleast_2d(src)
    if src.shape[0] == 1: src = np.vstack([src, src])
    a, b = max(i, 0), min(i + src.shape[1], dst.shape[1])
    if b > a: dst[:, a:b] += gain * src[:, a - i:b - i]


def fade(x, fin=0.005, fout=0.005):
    x = x.copy(); n = x.shape[-1]
    a, b = min(int(fin * SR), n), min(int(fout * SR), n)
    if a: x[..., :a] *= np.linspace(0, 1, a)
    if b: x[..., n - b:] *= np.linspace(1, 0, b)
    return x


def pan(mono, p):  # p in [-1, 1], equal power; p may be an array
    th = (np.asarray(p) + 1) * np.pi / 4
    return np.vstack([mono * np.cos(th), mono * np.sin(th)])


def lp(x, fc, order=4):
    return sosfiltfilt(butter(order, fc, 'low', fs=SR, output='sos'), x)


def hp(x, fc, order=2):
    return sosfiltfilt(butter(order, fc, 'high', fs=SR, output='sos'), x)


# ---------------------------------------------------------------- SFX synthesis
def whoosh(dur, peak, f_lo, f_hi, f_end=None, bw=0.9, pan_from=-0.5, pan_to=0.5, tail=0.18):
    """Band-limited noise whose band sweeps f_lo -> f_hi (at peak) -> f_end; loudest at `peak` seconds."""
    f_end = f_end or f_lo * 1.3
    n = int(dur * SR)
    f, tt, Z = stft(rng.standard_normal(n), SR, nperseg=1024, noverlap=768)
    c = np.where(tt < peak, f_lo * (f_hi / f_lo) ** np.clip(tt / peak, 0, 1),
                 f_hi * (f_end / f_hi) ** np.clip((tt - peak) / max(dur - peak, 1e-3), 0, 1))
    G = np.exp(-0.5 * (np.log2(np.maximum(f[:, None], 1) / c[None, :]) / bw) ** 2)
    A = np.where(tt < peak, np.clip(tt / peak, 0, 1) ** 2.5, np.exp(-(tt - peak) / tail))
    _, y = istft(Z * G * A[None, :], SR, nperseg=1024, noverlap=768)
    y = fade(y[:n] / (np.abs(y).max() + 1e-9), 0.01, 0.05)
    return pan(y, np.linspace(pan_from, pan_to, len(y)))


def riser(dur):
    n = int(dur * SR); t = np.arange(n) / SR
    w = whoosh(dur, dur * 0.98, 300, 7000, 7000, bw=1.1, pan_from=0, pan_to=0, tail=0.02)
    f = 180 * (1400 / 180) ** (t / dur)
    tone = np.sin(2 * np.pi * np.cumsum(f) / SR) * (t / dur) ** 3 * 0.25
    return fade(w + tone, 0.01, 0.01)


def boom(dur=1.6, f0=72, f1=36, tau=0.45, punch=0.5):
    n = int(dur * SR); t = np.arange(n) / SR
    f = f1 + (f0 - f1) * np.exp(-t / 0.18)
    sub = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t / tau)
    hit = lp(rng.standard_normal(n), 2500) * np.exp(-t / 0.035) * punch
    y = np.tanh(1.6 * (sub + hit)) / np.tanh(1.6)
    return fade(y, 0.001, 0.05)


def modal(freqs, decays, amps, dur=0.4, noise_hp=2500, noise_amt=0.6):
    n = int(dur * SR); t = np.arange(n) / SR
    y = sum(a * np.exp(-t / d) * np.sin(2 * np.pi * f * t + rng.uniform(0, 6.28)) for f, d, a in zip(freqs, decays, amps))
    y = y + noise_amt * hp(rng.standard_normal(n), noise_hp) * np.exp(-t / 0.0015)
    return fade(y / (np.abs(y).max() + 1e-9), 0.0003, 0.01)


def metal_click(size=1.0):
    base = rng.uniform(1700, 3600) / size
    ratios = np.array([1, 2.76, 5.40, 8.93])
    return modal(base * ratios, rng.uniform(0.02, 0.07, 4) * size, [1, 0.6, 0.35, 0.2])


def clunk():
    low = modal([170, 410, 760, 1290], [0.14, 0.09, 0.05, 0.03], [1, 0.7, 0.4, 0.25], dur=0.6, noise_hp=800)
    click = metal_click(0.8)
    return 0.8 * low + 0.5 * np.pad(click, (0, len(low) - len(click)))


def relay(on=True):
    return modal([2300, 3700, 5600] if on else [1400, 2350, 3900], [0.006, 0.004, 0.003], [1, 0.6, 0.3], dur=0.06, noise_amt=0.8)


def light_switch():
    return modal([2900, 4400, 6300], [0.008, 0.005, 0.004], [1, 0.5, 0.3], dur=0.08, noise_amt=1.0)


def hum(dur=2.6):
    n = int(dur * SR); t = np.arange(n) / SR
    y = sum(a * np.sin(2 * np.pi * f * t) for f, a in ((100, 1), (200, 0.5), (300, 0.25), (1200, 0.04)))
    env = np.minimum(t / 0.06, 1) * (0.35 + 0.65 * np.exp(-t / 0.4)) * np.clip((dur - t) / 1.2, 0, 1)
    return y * env / 2.0


def reverb_ir(rt60=2.2, dur=2.8):
    n = int(dur * SR); t = np.arange(n) / SR
    ir = rng.standard_normal((2, n)) * np.exp(-6.9 * t / rt60)
    ir = lp(ir, 6000); ir[:, :int(0.015 * SR)] = 0
    return ir / np.sqrt((ir ** 2).sum() / 2)


# ---------------------------------------------------------------- music edit
music = load(MUSIC)
bed = np.zeros((2, N))
DROP_FILM = 19.5                                  # drop (bar 12) lands on the explode wide shot
off1 = tbar(12) - DROP_FILM                       # film 0 <-> track 6.69 s
SWITCH = tbar(31) - off1                          # 60.96 s: bar-aligned jump to the biggest phrase (bar 36)
END_HIT = SWITCH + 2 * BAR                        # 65.32 s: final downbeat
seg1 = music[:, int(off1 * SR):int((off1 + SWITCH) * SR)]
place(bed, fade(seg1, 0.0, 0.01), 0)
s2a = tbar(36)
seg2 = music[:, int(s2a * SR):int((s2a + END_HIT - SWITCH + 0.5) * SR)]
place(bed, fade(seg2, 0.004, 0.08), SWITCH)
bed *= GAIN_MUSIC

# time-varying low-pass: crossfade between zero-phase filtered copies
CUTS = [220, 320, 480, 720, 1100, 1700, 2600, 4000, 6500, 11000]
def cutoff_at(t):
    c = np.full_like(t, 20000.0)
    m = t < 5.5;  c[m] = 250 * (1300 / 250) ** (t[m] / 5.5)                      # intro opens up, full on the 5.5 s cut
    m = (t >= 49.5) & (t < 49.7); c[m] = 20000 * (300 / 20000) ** ((t[m] - 49.5) / 0.2)  # night: muffle
    m = (t >= 49.7) & (t < 58.0); c[m] = 300
    m = (t >= 58.0) & (t < SWITCH); c[m] = 300 * (3500 / 300) ** ((t[m] - 58.0) / (SWITCH - 58.0))
    return c
t_all = np.arange(N) / SR
lc = np.log(np.clip(cutoff_at(t_all), CUTS[0], 20000))
grid = np.log(np.array(CUTS + [20000.0]))
filtered = [lp(bed, fc) for fc in CUTS] + [bed]
idx = np.clip(np.searchsorted(grid, lc) - 1, 0, len(grid) - 2)
w = (lc - grid[idx]) / (grid[idx + 1] - grid[idx])
music_out = np.zeros_like(bed)
for k in range(len(grid) - 1):
    m = idx == k
    music_out[:, m] = filtered[k][:, m] * (1 - w[m]) + filtered[k + 1][:, m] * w[m]

g = np.ones(N)
g[t_all < 0.6] = np.sin(np.pi / 2 * t_all[t_all < 0.6] / 0.6) ** 2            # matches the fade from black
g[t_all < 5.5] *= 1.4                                                           # filtered intro loses energy
m = (t_all >= 49.6) & (t_all < SWITCH); g[m] *= 0.6
music_out *= g
end_i = int((END_HIT + 0.55) * SR)                                              # hard stop one beat after final downbeat
music_out[:, end_i:] = 0
music_out[:, end_i - int(0.06 * SR):end_i] *= np.linspace(1, 0, int(0.06 * SR))

# reverb sends: full-band wash into the night cut and the final hit
send = np.zeros(N)
for a, b in ((49.30, 49.55), (END_HIT, END_HIT + 0.55)):
    send[int(a * SR):int(b * SR)] = 1
tail = np.vstack([fftconvolve(bed[c] * send, reverb_ir()[c])[:N] for c in range(2)]) * 0.35

# ---------------------------------------------------------------- engine
eng = load(ENGINE)
def eseg(a, b): return eng[:, int(a * SR):int(b * SR)]
engine = np.zeros((2, N))
place(engine, fade(eseg(0.25, 3.75), 0.02, 0.15), 54.15)        # starter + catch at ~54.6, idle
place(engine, fade(eseg(5.25, 8.60), 0.15, 0.25), 57.50)        # first rev over the high-beam flashes
place(engine, fade(eseg(12.30, 14.80), 0.25, 1.4), 60.30)       # second rev peaks on the 61 s cut
engine *= GAIN_ENGINE

# ---------------------------------------------------------------- SFX cues
sfx = np.zeros((2, N))
def W(t_peak, big=False, pre=0.45, **kw):
    dur = pre + (0.9 if big else 0.6)
    place(sfx, whoosh(dur, pre, **kw), t_peak - pre, GAIN_WHOOSH_BIG if big else GAIN_WHOOSH_SMALL)

for tc, p in ((5.5, -0.5), (9.5, 0.5), (13.5, -0.5), (17.5, 0.5)):              # detail-shot cuts
    W(tc, f_lo=500, f_hi=3200, pan_from=p, pan_to=-p)
place(sfx, riser(DROP_FILM - 17.6), 17.6, 0.28)                                 # into the drop
place(sfx, boom(), DROP_FILM, GAIN_BOOM)
W(21.9, big=True, pre=1.4, f_lo=300, f_hi=2200, f_end=500, bw=1.2, pan_from=-0.3, pan_to=0.3)  # parts fly apart
for t in np.sort(rng.uniform(20.7, 23.3, 10)):
    place(sfx, pan(metal_click(rng.uniform(0.8, 1.3)), rng.uniform(-0.7, 0.7)), t, GAIN_CLICK * rng.uniform(0.6, 1.0))
W(30.5, f_lo=400, f_hi=2400, pan_from=0.4, pan_to=-0.4)
W(32.1, pre=0.6, f_lo=350, f_hi=1800, pan_from=-0.2, pan_to=0.2)                # engine internals separate
for t in np.sort(rng.uniform(31.6, 32.7, 5)):
    place(sfx, pan(metal_click(rng.uniform(0.9, 1.4)), rng.uniform(-0.6, 0.6)), t, GAIN_CLICK * rng.uniform(0.6, 0.9))
for t in np.sort(rng.uniform(35.55, 36.2, 3)):
    place(sfx, pan(metal_click(), rng.uniform(-0.5, 0.5)), t, GAIN_CLICK * 0.7)
W(36.67, big=True, pre=0.8, f_lo=600, f_hi=4000, f_end=900, pan_from=0.5, pan_to=-0.5)   # into reassembly
W(38.9, big=True, pre=1.1, f_lo=250, f_hi=1600, f_end=300, bw=1.1, pan_from=0.3, pan_to=-0.3)  # parts fly back
for i, t in enumerate(np.linspace(37.9, 39.15, 8)):
    place(sfx, pan(metal_click(rng.uniform(0.9, 1.2)), rng.uniform(-0.6, 0.6)), t, GAIN_CLICK * (0.5 + 0.06 * i))
place(sfx, pan(clunk(), 0), 39.40, 0.45)                                         # it's whole again
place(sfx, boom(1.0, 90, 50, 0.2, 0.3), 39.40, 0.25)
W(42.5, f_lo=500, f_hi=2600)
W(46.0, f_lo=600, f_hi=3000, pan_from=0.3, pan_to=-0.3)
W(49.5, big=True, pre=0.5, f_lo=1500, f_hi=2500, f_end=200, bw=1.1, pan_from=0, pan_to=0)  # into the night
place(sfx, boom(2.2, 60, 32, 0.7, 0.25), 49.5, GAIN_BOOM * 0.8)
place(sfx, pan(light_switch(), 0.1), 50.21, 0.55)                               # headlight on
place(sfx, pan(hum(), 0.1), 50.21, 0.10)
W(54.0, f_lo=300, f_hi=1500, pan_from=-0.3, pan_to=0.3)
W(58.0, f_lo=400, f_hi=2200, pan_from=0.3, pan_to=-0.3)
for k in range(17):                                                              # hazard relay, 0.375 s half-period
    place(sfx, pan(relay(on=k % 2 == 0), -0.15), 54.75 + 0.375 * k, GAIN_TICK)
for t in (58.33, 59.33, 60.33):                                                  # high-beam flashes
    place(sfx, pan(light_switch(), 0.15), t, 0.30)
place(sfx, riser(SWITCH - 59.0), 59.0, 0.30)
place(sfx, boom(), SWITCH, GAIN_BOOM)
for tc in (62.45, 65.05):                                                        # finish swaps
    W(tc, pre=0.35, f_lo=2000, f_hi=9000, f_end=4000, bw=0.7, pan_from=-0.6, pan_to=0.6)
place(sfx, boom(2.0, 65, 30, 0.6, 0.6), END_HIT, GAIN_BOOM * 1.1)
sfx_tail = np.vstack([fftconvolve(sfx[c], reverb_ir(1.4, 1.8)[c])[:N] for c in range(2)]) * 0.12

# ---------------------------------------------------------------- end card
rng = np.random.default_rng(11)                                                  # own generator: cues above stay as in v1
a, b = int(END_HIT * SR), int((END_HIT + 0.55) * SR)
ir = reverb_ir(7.0, 7.0)                                                         # long wash: the final hit rings out over the card
long_tail = np.zeros((2, N))
place(long_tail, np.vstack([fftconvolve(bed[c, a:b], ir[c]) for c in range(2)]), END_HIT, GAIN_END_WASH)
place(sfx, whoosh(1.05, 0.45, 300, 1500, pan_from=-0.3, pan_to=0.3), FILM_LEN - 0.45, 0.35)   # cut to black
place(sfx, boom(2.2, 60, 32, 0.7, 0.25), FILM_LEN + 0.5, 0.10)                   # soft hit as the name fades up

# ---------------------------------------------------------------- mix + master + mux
mix = music_out + tail + long_tail + engine + sfx + sfx_tail
mix[:, -int(1.0 * SR):] *= np.linspace(1, 0, int(1.0 * SR))
os.makedirs(OUT_DIR, exist_ok=True)
raw_wav = os.path.join(OUT_DIR, f"mix_{VERSION}_raw.wav")
wavfile.write(raw_wav, SR, mix.T.astype(np.float32))
for name, stem in (("music", music_out + tail + long_tail), ("engine", engine), ("sfx", sfx + sfx_tail)):
    wavfile.write(os.path.join(OUT_DIR, f"stem_{name}_{VERSION}.wav"), SR, stem.T.astype(np.float32))

pre = "alimiter=limit=0.84:attack=2:release=60:level=disabled"
meas = subprocess.run(["ffmpeg", "-hide_banner", "-i", raw_wav, "-af", pre + ",loudnorm=I=-14:TP=-1.5:LRA=11:print_format=json",
                       "-f", "null", "-"], capture_output=True, text=True).stderr
js = json.loads(meas[meas.rindex("{"):meas.rindex("}") + 1])
ln = (f"loudnorm=I=-14:TP=-1.5:LRA=11:measured_I={js['input_i']}:measured_TP={js['input_tp']}:"
      f"measured_LRA={js['input_lra']}:measured_thresh={js['input_thresh']}:offset={js['target_offset']}:linear=true")
master = os.path.join(OUT_DIR, f"mix_{VERSION}.wav")
subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", raw_wav, "-af", f"{pre},{ln},aresample={SR}", "-c:a", "pcm_s24le", master], check=True)
out_mp4 = os.path.join(R, f"motorcycle_final_{VERSION}.mp4")
subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", VIDEO, "-i", master, "-map", "0:v", "-map", "1:a", "-c:v", "copy",
                "-c:a", "aac", "-b:a", "320k", "-movflags", "+faststart", "-shortest", out_mp4], check=True)
print("wrote", out_mp4)
print(subprocess.run(["ffmpeg", "-hide_banner", "-i", master, "-af", "ebur128=peak=true", "-f", "null", "-"],
                     capture_output=True, text=True).stderr.split("Summary:")[-1])
