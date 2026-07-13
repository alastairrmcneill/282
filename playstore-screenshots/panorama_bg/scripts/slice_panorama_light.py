#!/usr/bin/env python3
"""Slice a wide source photo into N contiguous vertical strips, each scaled
to fill a target canvas exactly, with a LIGHTENED/FADED treatment (opposite
of the darkened App Store version) while keeping a dark scrim behind the
top (headline) and bottom (breakout/nav) zones for text legibility."""
import argparse
from PIL import Image, ImageEnhance


def make_strip(src, x0, x1, canvas_w, canvas_h):
    strip = src.crop((x0, 0, x1, src.height))
    scale = canvas_h / strip.height
    strip = strip.resize((round(strip.width * scale), canvas_h), Image.LANCZOS)
    if strip.width != canvas_w:
        strip = strip.resize((canvas_w, canvas_h), Image.LANCZOS)
    return strip


def treat(strip):
    # Fade: lower saturation, lower contrast, mimic a washed-out misty look
    strip = ImageEnhance.Color(strip).enhance(0.55)
    strip = ImageEnhance.Contrast(strip).enhance(0.80)
    strip = ImageEnhance.Brightness(strip).enhance(1.35)

    w, h = strip.size
    # Overall lighten: blend toward white
    white = Image.new("RGB", (w, h), (255, 255, 255))
    strip = Image.blend(strip, white, 0.30)

    # Gradient dark scrim ONLY behind top (headline) and bottom (breakout/nav)
    # zones for text legibility — kept lighter than the App Store version
    # since the overall image is already much brighter.
    grad = Image.new("L", (1, h), 0)
    for y in range(h):
        t = y / (h - 1)
        if t < 0.26:
            a = 0.42 * (1 - t / 0.26)
        elif t > 0.80:
            a = 0.42 * ((t - 0.80) / 0.20)
        else:
            a = 0.0
        grad.putpixel((0, y), int(a * 255))
    grad = grad.resize((w, h))
    black = Image.new("RGB", (w, h), (0, 0, 0))
    strip = Image.composite(black, strip, grad)

    return strip


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--source", required=True)
    p.add_argument("--count", type=int, default=4)
    p.add_argument("--canvas-w", type=int, required=True)
    p.add_argument("--canvas-h", type=int, required=True)
    p.add_argument("--output-prefix", required=True)
    args = p.parse_args()

    src = Image.open(args.source).convert("RGB")

    scale_factor = args.canvas_h / src.height
    strip_w_src = args.canvas_w / scale_factor
    total_src_w = strip_w_src * args.count
    left_trim = (src.width - total_src_w) / 2
    if left_trim < 0:
        raise SystemExit(f"Source too narrow: need {total_src_w:.0f}px wide, have {src.width}")

    for i in range(args.count):
        x0 = left_trim + i * strip_w_src
        x1 = x0 + strip_w_src
        strip = make_strip(src, round(x0), round(x1), args.canvas_w, args.canvas_h)
        strip = treat(strip)
        out = f"{args.output_prefix}{i+1}.png"
        strip.save(out, "PNG")
        print(f"✓ {out} ({strip.width}x{strip.height}) src_x=[{x0:.0f},{x1:.0f}]")


if __name__ == "__main__":
    main()
