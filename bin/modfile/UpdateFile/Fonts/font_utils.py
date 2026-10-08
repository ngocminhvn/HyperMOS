#!/usr/bin/env python3
"""Prepare Xiaomi ThemeManager variable-font metadata without modifying stock MiSans."""
from __future__ import annotations

import argparse
from pathlib import Path

from fontTools.ttLib import TTFont
from PIL import Image, ImageDraw, ImageFont

# Ten stops, matching the ten-step MiSans/MIUI font-weight selector.
MIUI_STOPS = (100, 200, 300, 350, 400, 500, 700, 800, 900, 950)


def weight_stops(font: TTFont, title: str) -> str:
    if "fvar" not in font:
        raise ValueError(f"{title} is not a variable font (missing fvar); cannot enable real font-weight adjustment")
    axis = next((a for a in font["fvar"].axes if a.axisTag == "wght"), None)
    if axis is None or axis.maxValue <= axis.minValue:
        raise ValueError(f"{title} has no usable wght variation axis")
    lo, hi = float(axis.minValue), float(axis.maxValue)
    values = [round(lo + (stop - MIUI_STOPS[0]) / (MIUI_STOPS[-1] - MIUI_STOPS[0]) * (hi - lo))
              for stop in MIUI_STOPS]
    if len(set(values)) != len(values):
        raise ValueError(f"{title} wght range is too narrow for ten distinct steps")
    return ",".join(str(value) for value in values)


def prepare(sf_path: Path, roboto_path: Path, output: Path) -> None:
    output.mkdir(parents=True, exist_ok=True)
    sf = TTFont(sf_path, fontNumber=0)
    roboto = TTFont(roboto_path, fontNumber=0)
    sf_stops = weight_stops(sf, "SF Pro")
    roboto_stops = weight_stops(roboto, "Roboto")
    sf_prepared = output / "SF-Pro.ttf"

    # Do not scale glyph outlines, alter em-size, or change the font's weight
    # axis. Only remove additional leading; this is a conservative first fix
    # for the excessive inter-line spacing observed with SF Pro on HyperOS.
    hhea_gap = sf["hhea"].lineGap if "hhea" in sf else 0
    typo_gap = sf["OS/2"].sTypoLineGap if "OS/2" in sf else 0
    if "hhea" in sf:
        sf["hhea"].lineGap = 0
    if "OS/2" in sf:
        sf["OS/2"].sTypoLineGap = 0
    sf.save(sf_prepared)

    # Check the saved face, not only the original.
    with TTFont(sf_prepared, fontNumber=0) as saved:
        assert weight_stops(saved, "prepared SF Pro") == sf_stops

    env_path = output / "font_weights.env"
    env_path.write_text(f'SF_WEIGHTS="{sf_stops}"\nROBOTO_WEIGHTS="{roboto_stops}"\n', encoding="ascii")
    print(f"SF Pro: wght stops={sf_stops}; leading hhea={hhea_gap}->0, typo={typo_gap}->0")
    print(f"Roboto: wght stops={roboto_stops}; source font unchanged")


def preview(title: str, font_path: Path, output: Path) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    image = Image.new("RGB", (480, 160), "#181818")
    draw = ImageDraw.Draw(image)
    font = ImageFont.truetype(str(font_path), 57)
    # Render actual lettering rather than blank white placeholder images.
    draw.text((240, 80), title, fill="#F2F2F2", font=font, anchor="mm")
    image.save(output, format="PNG", optimize=True)


def main() -> None:
    parser = argparse.ArgumentParser()
    commands = parser.add_subparsers(dest="action", required=True)
    prep = commands.add_parser("prepare")
    prep.add_argument("sf", type=Path)
    prep.add_argument("roboto", type=Path)
    prep.add_argument("output", type=Path)
    pv = commands.add_parser("preview")
    pv.add_argument("title")
    pv.add_argument("font", type=Path)
    pv.add_argument("output", type=Path)
    args = parser.parse_args()
    if args.action == "prepare":
        prepare(args.sf, args.roboto, args.output)
    else:
        preview(args.title, args.font, args.output)


if __name__ == "__main__":
    main()
