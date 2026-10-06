#!/usr/bin/env python3
"""
frames_tool.py - find missing frames, consolidate, and (optionally) encode.

The frame number is the LAST run of digits in the file name (before the extension),
so frame_0011.png and frame_00011.png both -> frame 11.

Usage:
  # 1) Just check what's missing
  python frames_tool.py "D:/renders"

  # 2) Check + copy everything into one clean, sequential folder
  python frames_tool.py "D:/renders" --out "D:/final_frames"

  # 3) Check + consolidate + encode to MP4 at 24 fps (needs ffmpeg in PATH)
  python frames_tool.py "D:/renders" --out "D:/final_frames" --encode "D:/animation.mp4"

Options:
  --start N / --end N   Expected frame range. Default: min and max frame found.
  --fps 24              Frame rate for encoding.
  --pad 5               Digits in the new file names (frame_00001.png).
  --move                Move instead of copy (saves disk space, riskier).
"""
import argparse
import os
import re
import shutil
import subprocess
import sys
from collections import defaultdict

IMG_EXT = {".png", ".jpg", ".jpeg", ".exr", ".tif", ".tiff", ".bmp", ".webp"}
TRAILING_NUM = re.compile(r"(\d+)$")


def scan(root):
    """Return {frame_number: [paths]} and a list of files with no frame number."""
    found = defaultdict(list)
    unparsed = []
    for dirpath, _, files in os.walk(root):
        for f in files:
            stem, ext = os.path.splitext(f)
            if ext.lower() not in IMG_EXT:
                continue
            m = TRAILING_NUM.search(stem)
            path = os.path.join(dirpath, f)
            if m:
                found[int(m.group(1))].append(path)
            else:
                unparsed.append(path)
    return found, unparsed


def to_ranges(nums):
    """[1,2,3,7,9,10] -> '1-3, 7, 9-10'"""
    if not nums:
        return "none"
    nums = sorted(nums)
    out, start, prev = [], nums[0], nums[0]
    for n in nums[1:]:
        if n == prev + 1:
            prev = n
            continue
        out.append((start, prev))
        start = prev = n
    out.append((start, prev))
    return ", ".join(str(a) if a == b else f"{a}-{b}" for a, b in out)


PREFER = None  # folder whose frames always win over duplicates elsewhere


def pick_best(paths):
    """Frame in several folders: the --prefer folder wins; otherwise the largest file."""
    if PREFER:
        pref = [p for p in paths if os.path.abspath(p).lower().startswith(PREFER)]
        if pref:
            return max(pref, key=os.path.getmtime)
    return max(paths, key=lambda p: (os.path.getsize(p), os.path.getmtime(p)))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("root")
    ap.add_argument("--start", type=int)
    ap.add_argument("--end", type=int)
    ap.add_argument("--fps", type=int, default=24)
    ap.add_argument("--pad", type=int, default=5)
    ap.add_argument("--out")
    ap.add_argument("--move", action="store_true")
    ap.add_argument("--encode")
    ap.add_argument("--prefer", help="folder (inside root) whose frames override duplicates")
    a = ap.parse_args()
    global PREFER
    if a.prefer:
        PREFER = os.path.abspath(a.prefer).lower()

    if not os.path.isdir(a.root):
        sys.exit(f"Folder not found: {a.root}")

    found, unparsed = scan(a.root)
    if a.prefer and os.path.isdir(a.prefer):
        # --prefer folder may live outside root, so scan it too (skip paths already seen)
        known = {os.path.normcase(os.path.abspath(p)) for ps in found.values() for p in ps}
        extra, _ = scan(a.prefer)
        for n, ps in extra.items():
            for p in ps:
                if os.path.normcase(os.path.abspath(p)) not in known:
                    found[n].append(p)
    if not found:
        sys.exit("No image files with a trailing frame number found.")

    start = a.start if a.start is not None else min(found)
    end = a.end if a.end is not None else max(found)
    expected = set(range(start, end + 1))
    have = set(found)

    missing = sorted(expected - have)
    extra = sorted(have - expected)
    dupes = {n: p for n, p in found.items() if len(p) > 1}
    empty = [p for paths in found.values() for p in paths if os.path.getsize(p) == 0]

    print(f"Range checked : {start} to {end} ({len(expected)} frames expected)")
    print(f"Frames found  : {len(have & expected)}")
    print(f"Missing       : {len(missing)} -> {to_ranges(missing)}")
    if extra:
        print(f"Outside range : {len(extra)} -> {to_ranges(extra)}")
    print(f"Duplicates    : {len(dupes)} frames exist in more than one place")
    if empty:
        print(f"0-byte files  : {len(empty)} (corrupt, re-render these)")
        for p in empty[:20]:
            print("   ", p)
    if unparsed:
        print(f"Skipped       : {len(unparsed)} image files with no trailing number")

    # Report for re-rendering
    if missing or empty:
        bad = set(missing)
        for p in empty:
            bad.add(int(TRAILING_NUM.search(os.path.splitext(os.path.basename(p))[0]).group(1)))
        report = os.path.join(a.root, "missing_frames.txt")
        with open(report, "w") as fh:
            fh.write("Frames to re-render: " + to_ranges(bad) + "\n")
            fh.write("One per line:\n" + "\n".join(map(str, sorted(bad))) + "\n")
        print(f"\nRe-render list saved: {report}")
        print("Blender CLI per range: blender -b file.blend -s START -e END -a")

    if not a.out:
        return

    if missing:
        print("\nWARNING: frames are missing. The output sequence will have gaps,")
        print("and ffmpeg will stop at the first gap. Re-render them first.")

    os.makedirs(a.out, exist_ok=True)
    ext = os.path.splitext(pick_best(found[min(have)]))[1]
    op = shutil.move if a.move else shutil.copy2
    count = 0
    for n in sorted(have & expected):
        src = pick_best(found[n])
        if os.path.getsize(src) == 0:
            continue
        dst = os.path.join(a.out, f"frame_{n:0{a.pad}d}{os.path.splitext(src)[1].lower()}")
        op(src, dst)
        count += 1
    print(f"\n{'Moved' if a.move else 'Copied'} {count} frames to {a.out}")

    if a.encode:
        if missing:
            sys.exit("Not encoding: fix missing frames first.")
        if ext.lower() == ".exr":
            print("EXR frames: ffmpeg support varies; consider encoding in Blender instead.")
        cmd = [
            "ffmpeg", "-y", "-framerate", str(a.fps), "-start_number", str(start),
            "-i", os.path.join(a.out, f"frame_%0{a.pad}d{ext.lower()}"),
            "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "18", a.encode,
        ]
        print("Running:", " ".join(cmd))
        subprocess.run(cmd, check=True)
        print(f"Done: {a.encode}")


if __name__ == "__main__":
    main()
