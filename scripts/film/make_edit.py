# Builds the title/edit scene for the motorcycle product film and renders the final frames.
# Run:  blender -b --factory-startup -P make_edit.py -- <frames_dir> <out_blend> <out> [test_frames]
#   <out> ending in .mp4 -> one silent H.264 video (make_audio.py adds the sound); otherwise a folder of PNG frames.
#   [test_frames] e.g. 60,600,1650 -> only render those frames as PNG stills, to check the titles first.
# Progress goes to <out_blend minus .blend>.log (the Store build of Blender has no console when run in the background).
# Edit the TITLES list below (or open the saved edit .blend and change the text strips directly).
import bpy, sys, os
import numpy as np

argv = sys.argv[sys.argv.index("--") + 1:]
FRAMES_DIR, OUT_BLEND, OUT = argv[0], argv[1], argv[2]
TEST = [int(f) for f in argv[3].split(",")] if len(argv) > 3 else []
VIDEO = OUT.lower().endswith(".mp4")
OUT_DIR = os.path.dirname(OUT) if VIDEO else OUT
LOG = os.path.splitext(OUT_BLEND)[0] + ".log"
FILM_END = 1620          # last rendered 3D frame
END_CARD = 72            # 3 s end card
_first = sorted(f for f in os.listdir(FRAMES_DIR) if f.lower().endswith(".png"))[0]
_probe = bpy.data.images.load(os.path.join(FRAMES_DIR, _first))
W, H = _probe.size                      # follow whatever resolution the frames were rendered at
bpy.data.images.remove(_probe)
K = H / 720                             # title sizes below are authored for 720p
FONT_HEAD = r"C:\Windows\Fonts\ARIALNB.TTF"
FONT_SUB = r"C:\Windows\Fonts\segoeuil.ttf"

# (start, end, corner, headline, subtitle)
TITLES = [
    (14, 124, "BL", "Café Racer Concept", "Designed and engineered in SolidWorks"),
    (146, 316, "TL", "Sleek, sculpted design", "Hand-shaped bodywork with a deep gloss finish"),
    (336, 462, "BL", "Built to perform", "Drilled discs and orange-anodised wheels"),
    (530, 726, "TR", "Every part, precision-engineered", "Over 650 individually modelled components"),
    (762, 874, "BL", "Twin-cylinder heart", "Fully modelled internals, down to every bolt"),
    (968, 1020, "BL", "Café Racer Concept", "Form, function, finish"),
    (1030, 1186, "BL", "Made for every hour", "From soft morning light to golden afternoon"),
    (1206, 1294, "BL", "Lights on", "Full LED headlight, indicators and tail light"),
    (1306, 1460, "BL", "Ready to ride", "Hazards, high-beam flash and a growl to match"),
    (1470, 1618, "TR", "Three signature finishes", "Riviera Blue  ·  Army Green  ·  Midnight Black"),
]
END_SMALL = "Designed & engineered by"
END_BIG = "MIKEDOESROBOTS.COM"
SCRIM = 0.45            # darkness of the soft corner gradient behind each title (0 = off)

S = bpy.context.scene
S.name = "FILM_Edit"
S.render.resolution_x, S.render.resolution_y, S.render.resolution_percentage = W, H, 100
S.render.fps = 24
S.frame_start, S.frame_end = 1, FILM_END + END_CARD
S.view_settings.view_transform = 'Standard'
se = S.sequence_editor_create()
fh, fs = bpy.data.fonts.load(FONT_HEAD), bpy.data.fonts.load(FONT_SUB)

files = sorted(f for f in os.listdir(FRAMES_DIR) if f.lower().endswith(".png"))
img = se.strips.new_image("film", os.path.join(FRAMES_DIR, files[0]), channel=1, frame_start=1)
for f in files[1:]:
    img.elements.append(f)
img.blend_type = 'ALPHA_OVER'
for fr, a in ((1, 0.0), (14, 1.0)):            # fade up from black
    img.blend_alpha = a; img.keyframe_insert("blend_alpha", frame=fr)


def text(name, body, font, size, x, y, ax, ay, ch, f0, f1, rise=0.012):
    t = se.strips.new_effect(name=name, type='TEXT', channel=ch, frame_start=f0, length=f1 - f0)
    t.text, t.font, t.font_size = body, font, size
    t.color = (1, 1, 1, 1)
    t.use_shadow = True; t.shadow_color = (0, 0, 0, 0.45); t.shadow_blur = 0.25; t.shadow_offset = 0.04   # both relative to font size
    t.anchor_x, t.anchor_y = ax, ay
    t.alignment_x = 'RIGHT' if ax == 'RIGHT' else ('CENTER' if ax == 'CENTER' else 'LEFT')
    t.blend_type = 'ALPHA_OVER'
    for fr, a, dy in ((f0, 0.0, -rise), (f0 + 12, 1.0, 0.0), (f1 - 10, 1.0, 0.0), (f1, 0.0, 0.0)):
        t.blend_alpha = a; t.keyframe_insert("blend_alpha", frame=fr)
        t.location = (x, y + dy); t.keyframe_insert("location", frame=fr)
    return t


def scrim(corner):
    """Soft dark gradient in one corner so the white titles read on the bright set. Saved next to the edit .blend."""
    x, y = np.linspace(0, 1, W)[None, :], np.linspace(0, 1, H)[:, None]        # row 0 is the bottom of the image
    if corner[1] == "R": x = 1 - x
    if corner[0] == "T": y = 1 - y
    ease = lambda d, a, b: np.cos(np.clip((d - a) / (b - a), 0, 1) * np.pi / 2) ** 2   # 1 up to a, 0 from b
    alpha = SCRIM * ease(x, 0.24, 0.50) * ease(y, 0.13, 0.30)
    px = np.zeros((H, W, 4), np.float32)
    px[..., 3] = np.floor(alpha * 255 + np.random.default_rng(0).random((H, W))) / 255   # dithered: no banding
    im = bpy.data.images.new(f"scrim_{corner}", W, H, alpha=True)
    im.pixels.foreach_set(px.ravel())
    im.filepath_raw, im.file_format = os.path.join(os.path.dirname(OUT_BLEND), f"scrim_{corner}.png"), 'PNG'
    im.save()
    return im.filepath_raw


SCRIMS = {c: scrim(c) for c in sorted({t[2] for t in TITLES})}
POS = {"BL": (0.035, 0.105, 0.085, 'LEFT'), "TL": (0.035, 0.925, 0.905, 'LEFT'), "TR": (0.965, 0.925, 0.905, 'RIGHT')}
for i, (f0, f1, corner, head, sub) in enumerate(TITLES):
    x, yh, ys, ax = POS[corner]
    sc = se.strips.new_image(f"T{i}_scrim", SCRIMS[corner], channel=2, frame_start=f0)
    sc.duration, sc.blend_type = f1 - f0, 'ALPHA_OVER'
    for fr, a in ((f0, 0.0), (f0 + 12, 1.0), (f1 - 10, 1.0), (f1, 0.0)):
        sc.blend_alpha = a; sc.keyframe_insert("blend_alpha", frame=fr)
    text(f"T{i}_head", head, fh, round(21 * K), x, yh, ax, 'BOTTOM', 3, f0, f1)
    text(f"T{i}_sub", sub, fs, round(11 * K), x, ys, ax, 'BOTTOM', 4, f0 + 4, f1)

# end card
e0 = FILM_END + 1
bg = se.strips.new_effect(name="end_black", type='COLOR', channel=2, frame_start=e0, length=END_CARD)
bg.color = (0, 0, 0)
text("end_small", END_SMALL, fs, round(22 * K), 0.5, 0.56, 'CENTER', 'BOTTOM', 5, e0 + 6, e0 + END_CARD)
text("end_big", END_BIG, fh, round(64 * K), 0.5, 0.44, 'CENTER', 'BOTTOM', 6, e0 + 12, e0 + END_CARD)

def log(msg):
    with open(LOG, "a") as fh:
        fh.write(msg + "\n")


if VIDEO:
    S.render.image_settings.media_type = 'VIDEO'
    S.render.ffmpeg.format, S.render.ffmpeg.codec = 'MPEG4', 'H264'
    S.render.ffmpeg.constant_rate_factor = 'PERC_LOSSLESS'
    S.render.ffmpeg.ffmpeg_preset = 'GOOD'
    S.render.ffmpeg.audio_codec = 'NONE'
    S.render.filepath = OUT
else:
    S.render.image_settings.media_type = 'IMAGE'
    S.render.image_settings.file_format = 'PNG'
    S.render.filepath = os.path.join(OUT_DIR, "edit_####")
bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND)
open(LOG, "w").close()
try:
    if TEST:
        S.render.image_settings.media_type = 'IMAGE'
        S.render.image_settings.file_format = 'PNG'
        for f in TEST:
            S.frame_set(f)
            S.render.filepath = os.path.join(OUT_DIR, f"test_{f:04d}")
            bpy.ops.render.render(write_still=True)
            log(f"still {f}")
    else:
        bpy.app.handlers.render_post.append(lambda scene, *_: scene.frame_current % 24 or log(f"frame {scene.frame_current}"))
        bpy.ops.render.render(animation=True)
    log("EDIT_DONE")
except Exception as e:
    log(f"EDIT_FAILED {e!r}")
    raise
