#!/usr/bin/env python3
"""Same as the skill's compose.py but takes a pre-rendered background image
(already sized to the canvas) instead of a solid hex colour."""
import argparse
import os
from PIL import Image, ImageDraw, ImageFont

CANVAS_W = 1290
CANVAS_H = 2796
DEVICE_W = 1030
BEZEL = 15
SCREEN_W = DEVICE_W - 2 * BEZEL
SCREEN_CORNER_R = 62
DEVICE_Y = 720
VERB_SIZE_MAX = 256
VERB_SIZE_MIN = 150
DESC_SIZE = 124
VERB_DESC_GAP = 20
DESC_LINE_GAP = 24
MAX_TEXT_W = int(CANVAS_W * 0.92)
MAX_VERB_W = int(CANVAS_W * 0.92)
FONT_PATH = "/Library/Fonts/SF-Pro-Display-Black.otf"
SKILL_DIR = os.path.expanduser("~/.claude/skills/aso-appstore-screenshots")
FRAME_PATH = os.path.join(SKILL_DIR, "assets", "device_frame.png")


def word_wrap(draw, text, font, max_w):
    words = text.split()
    lines, cur = [], ""
    for w in words:
        test = f"{cur} {w}".strip()
        if draw.textlength(test, font=font) <= max_w:
            cur = test
        else:
            if cur:
                lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines


def fit_font(text, max_w, size_max, size_min):
    dummy = ImageDraw.Draw(Image.new("RGBA", (1, 1)))
    for size in range(size_max, size_min - 1, -4):
        font = ImageFont.truetype(FONT_PATH, size)
        bbox = dummy.textbbox((0, 0), text, font=font)
        if (bbox[2] - bbox[0]) <= max_w:
            return font
    return ImageFont.truetype(FONT_PATH, size_min)


def draw_centered(draw, y, text, font, max_w=None):
    lines = word_wrap(draw, text, font, max_w) if max_w else [text]
    for line in lines:
        bbox = draw.textbbox((0, 0), line, font=font)
        h = bbox[3] - bbox[1]
        draw.text((CANVAS_W // 2, y - bbox[1]), line, fill="white", font=font, anchor="mt")
        y += h + DESC_LINE_GAP
    return y


def compose(bg_image_path, verb, desc, screenshot_path, output_path):
    bg_img = Image.open(bg_image_path).convert("RGB")
    if bg_img.size != (CANVAS_W, CANVAS_H):
        bg_img = bg_img.resize((CANVAS_W, CANVAS_H), Image.LANCZOS)
    canvas = bg_img.convert("RGBA")
    draw = ImageDraw.Draw(canvas)

    verb_font = fit_font(verb.upper(), MAX_VERB_W, VERB_SIZE_MAX, VERB_SIZE_MIN)
    desc_font = ImageFont.truetype(FONT_PATH, DESC_SIZE)

    text_top = 200
    y = text_top
    y = draw_centered(draw, y, verb.upper(), verb_font)
    y += VERB_DESC_GAP
    draw_centered(draw, y, desc.upper(), desc_font, max_w=MAX_TEXT_W)

    device_x = (CANVAS_W - DEVICE_W) // 2
    device_y = DEVICE_Y
    screen_x = device_x + BEZEL
    screen_y = device_y + BEZEL

    shot = Image.open(screenshot_path).convert("RGBA")
    scale = SCREEN_W / shot.width
    sc_w = SCREEN_W
    sc_h = int(shot.height * scale)
    shot = shot.resize((sc_w, sc_h), Image.LANCZOS)

    screen_h = CANVAS_H - screen_y + 500

    scr_mask = Image.new("L", canvas.size, 0)
    ImageDraw.Draw(scr_mask).rounded_rectangle(
        [screen_x, screen_y, screen_x + SCREEN_W, screen_y + screen_h],
        radius=SCREEN_CORNER_R, fill=255,
    )

    scr_layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(scr_layer).rounded_rectangle(
        [screen_x, screen_y, screen_x + SCREEN_W, screen_y + screen_h],
        radius=SCREEN_CORNER_R, fill=(0, 0, 0, 255),
    )
    scr_layer.paste(shot, (screen_x, screen_y))
    scr_layer.putalpha(scr_mask)
    canvas = Image.alpha_composite(canvas, scr_layer)

    frame_template = Image.open(FRAME_PATH).convert("RGBA")
    frame_layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    frame_layer.paste(frame_template, (device_x, device_y))
    canvas = Image.alpha_composite(canvas, frame_layer)

    canvas.convert("RGB").save(output_path, "PNG")
    print(f"✓ {output_path} ({CANVAS_W}×{CANVAS_H})")


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--bg-image", required=True)
    p.add_argument("--verb", required=True)
    p.add_argument("--desc", required=True)
    p.add_argument("--screenshot", required=True)
    p.add_argument("--output", required=True)
    args = p.parse_args()
    compose(args.bg_image, args.verb, args.desc, args.screenshot, args.output)


if __name__ == "__main__":
    main()
