#!/usr/bin/env python3
"""Slice a wide source photo into N equal vertical strips, each scaled to fill
a target canvas exactly, with a fade+darken treatment for text legibility.
Adjacent strips are cut from contiguous, non-overlapping source regions so
placing the outputs side-by-side reproduces the original photo continuously.
"""
import argparse
from PIL import Image, ImageEnhance, ImageDraw


def make_strip(src, x0, x1, canvas_w, canvas_h):
    strip = src.crop((x0, 0, x1, src.height))
    scale = canvas_h / strip.height
    strip = strip.resize((round(strip.width * scale), canvas_h), Image.LANCZOS)
    # strip.width should already equal canvas_w by construction; guard anyway
    if strip.width != canvas_w:
        strip = strip.resize((canvas_w, canvas_h), Image.LANCZOS)
    return strip


def treat(strip):
    # Fade: lower saturation & contrast slightly, mimic misty look
    strip = ImageEnhance.Color(strip).enhance(0.82)
    strip = ImageEnhance.Contrast(strip).enhance(0.88)
    strip = ImageEnhance.Brightness(strip).enhance(0.92)

    w, h = strip.size
    # Uniform darken
    dark = Image.new("RGB", (w, h), (0, 0, 0))
    strip = Image.blend(strip, dark, 0.38)

    # Extra gradient darken: stronger at top (headline) and bottom (breakout/nav)
    grad = Image.new("L", (1, h), 0)
    for y in range(h):
        t = y / (h - 1)
        # heavier at top (0..0.30) and bottom (0.78..1.0), lighter in middle
        if t < 0.30:
            a = 0.55 * (1 - t / 0.30)
        elif t > 0.78:
            a = 0.55 * ((t - 0.78) / 0.22)
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
