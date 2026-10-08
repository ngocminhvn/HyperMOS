#!/usr/bin/env python3
"""HyperMOS font catalog: automatically register build-time variable theme fonts.

Drop *.ttf or *.otf (with an actual OpenType 'wght' axis) in Fonts/HyperOS.
Run 'catalog <source_dir> <build_dir>' to validate sources, generate ten weight
stops, and emit stable Xiaomi resource IDs. Stock MiSans and emoji are excluded.
"""
from __future__ import annotations

import argparse
import csv
import json
import re
import sys
import uuid
from pathlib import Path

from fontTools.ttLib import TTFont, TTLibError
from PIL import Image, ImageDraw, ImageFont

# Match Xiaomi's ten positions in the weight slider, within a particular font's
# supported wght axis. This does not itself make Xiaomi Settings show its slider.
MIUI_STOPS = (100, 200, 300, 350, 400, 500, 700, 800, 900, 950)
EXCLUDED_FILES = {"notocoloremoji.ttf", "misansvf.ttf"}
LEGACY = {
    "sf-pro.ttf": {
        "title": "SF Pro",
        "author": "Apple",
        "font_id": "9c6f0f9a-4c74-4bd1-9c18-1d7f5b3a2102",
        "theme_id": "9c6f0f9a-4c74-4bd1-9c18-1d7f5b3a2101",
        "normalize_line_gap": True,
    },
    "roboto-vf.ttf": {
        "title": "Roboto",
        "author": "Google",
        "font_id": "b1e6e1d4-5f63-4a3d-8df1-2f9a4c6b3102",
        "theme_id": "b1e6e1d4-5f63-4a3d-8df1-2f9a4c6b3101",
        "normalize_line_gap": False,
    },
}


def weight_stops(font: TTFont, title: str) -> str:
    if "fvar" not in font:
        raise ValueError(
            f"{title}: static font (no fvar); use one variable TTF/OTF with a wght axis"
        )
    axes = [axis for axis in font["fvar"].axes if axis.axisTag == "wght"]
    if len(axes) != 1 or axes[0].minValue >= axes[0].maxValue:
        raise ValueError(f"{title}: no usable 'wght' OpenType variable axis")
    axis = axes[0]
    lo, hi = float(axis.minValue), float(axis.maxValue)
    values = [
        round(lo + (stop - MIUI_STOPS[0]) / (MIUI_STOPS[-1] - MIUI_STOPS[0]) * (hi - lo))
        for stop in MIUI_STOPS
    ]
    if len(set(values)) != len(values):
        raise ValueError(f"{title}: 'wght' range too narrow for ten distinct steps")
    return ",".join(str(value) for value in values)


def friendly_title(filename: str) -> str:
    stem = Path(filename).stem
    stem = re.sub(r"(?i)([-_ ](?:variable|vf))$", "", stem)
    return re.sub(r"\s+", " ", stem.replace("_", " ").replace("-", " ")).strip()


def read_overrides(source_dir: Path) -> dict:
    config_path = source_dir / "fonts.json"
    if not config_path.exists():
        return {}
    overrides = json.loads(config_path.read_text(encoding="utf-8"))
    if not isinstance(overrides, dict):
        raise ValueError("fonts.json must be a dictionary keyed by font file name")
    for key, settings in overrides.items():
        if not isinstance(key, str) or not isinstance(settings, dict):
            raise ValueError("fonts.json entries must be {filename: {title, author, normalize_line_gap}}")
        if not (source_dir / key).is_file():
            raise ValueError(f"fonts.json references missing file: {key}")
        for name in settings:
            if name not in {"title", "author", "normalize_line_gap"}:
                raise ValueError(f"fonts.json entry {key}: unsupported property {name}")
        if "normalize_line_gap" in settings and not isinstance(settings["normalize_line_gap"], bool):
            raise ValueError(f"fonts.json entry {key}: normalize_line_gap must be true or false")
    return overrides


def font_identity(filename: str) -> tuple[str, str]:
    # Preserve SF Pro / Roboto IDs so an OTA build cannot register duplicates.
    prior = LEGACY.get(filename.casefold())
    if prior:
        return prior["font_id"], prior["theme_id"]
    # Filename -> deterministic IDs across builds, independent of file contents.
    key = filename.casefold()
    return (
        str(uuid.uuid5(uuid.NAMESPACE_URL, "hypermos/font/" + key)),
        str(uuid.uuid5(uuid.NAMESPACE_URL, "hypermos/theme/" + key)),
    )


def normalize_leading(font: TTFont) -> None:
    # Leave the shape, UPM, wght axis and glyph bounds unchanged.
    if "hhea" in font:
        font["hhea"].lineGap = 0
    if "OS/2" in font:
        font["OS/2"].sTypoLineGap = 0


def inspect_file(source: Path, outdir: Path, settings: dict) -> dict:
    default = LEGACY.get(source.name.casefold(), {})
    title = settings.get("title", default.get("title", friendly_title(source.name)))
    author = settings.get("author", default.get("author", "Custom"))
    if not all(isinstance(x, str) and x.strip() and "\t" not in x and "\n" not in x
               for x in (title, author)):
        raise ValueError(f"{source.name}: title/author must be nonempty single-line text")
    if '"' in title or '"' in author:
        raise ValueError(f"{source.name}: title/author cannot contain quotes")
    normalize = settings.get("normalize_line_gap", default.get("normalize_line_gap", False))
    if not isinstance(normalize, bool):
        raise ValueError(f"{source.name}: normalize_line_gap must be boolean")

    font_id, theme_id = font_identity(source.name)
    with TTFont(source, fontNumber=0, lazy=False) as font:
        stops = weight_stops(font, title)
        if "glyf" not in font and "CFF2" not in font:
            raise ValueError(f"{title}: expected an outline-based TTF/OTF variable font")
        cmap = font.getBestCmap() or {}
        missing = [hex(code) for code in (0x1EA1, 0x1ED9, 0x0111) if code not in cmap]
        if missing:
            print(f"[FONT-CATALOG] WARN {title}: missing Vietnamese glyphs {', '.join(missing)}")
        prepared = source
        if normalize:
            prepared = outdir / ("prepared-" + font_id + source.suffix.lower())
            normalize_leading(font)
            font.save(prepared)

    # Repeat validation on the saved font to catch accidental corruption.
    if normalize:
        with TTFont(prepared, lazy=False) as saved:
            if weight_stops(saved, title) != stops:
                raise ValueError(f"{title}: weight axis changed during line-height normalization")
    print(f"[FONT-CATALOG] {source.name} -> {title}: wght=[{stops}], id={font_id}")
    return {
        "file": source.name,
        "path": str(prepared.resolve()),
        "font_id": font_id,
        "theme_id": theme_id,
        "title": title,
        "author": author,
        "weights": stops,
        "normalize_line_gap": normalize,
    }


def catalog(source_dir: Path, outdir: Path) -> None:
    if not source_dir.is_dir():
        raise ValueError(f"Missing font directory: {source_dir}")
    outdir.mkdir(parents=True, exist_ok=True)
    # Clear generated manifests before validation so a failed catalog cannot be
    # mistaken for a successful earlier attempt on reused runners.
    for stale in ("catalog.tsv", "catalog.json"):
        (outdir / stale).unlink(missing_ok=True)
    overrides = read_overrides(source_dir)
    fonts = sorted((
        file for file in source_dir.iterdir()
        if file.is_file() and file.suffix.casefold() in (".ttf", ".otf")
        and file.name.casefold() not in EXCLUDED_FILES
    ), key=lambda path: path.name.casefold())
    if not fonts:
        raise ValueError("No custom *.ttf/*.otf font files found")
    manifest = []
    seen_files = set()
    seen_titles = set()
    for file in fonts:
        key = file.name.casefold()
        if any(mark in file.name for mark in ("\t", "\n", "\r", '"')):
            raise ValueError(f"Invalid filename for tab-separated catalog: {file.name!r}")
        if key in seen_files:
            raise ValueError(f"Duplicate case-insensitive font filename: {file.name}")
        seen_files.add(key)
        settings = overrides.get(file.name, {})
        entry = inspect_file(file, outdir, settings)
        title_key = entry["title"].casefold()
        if title_key in seen_titles:
            raise ValueError(f"Duplicate ThemeManager display title: {entry['title']}")
        seen_titles.add(title_key)
        manifest.append(entry)
    # Write metadata only after every font validates; prevent partial catalogs.
    table = outdir / "catalog.tsv"
    with table.open("w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f, delimiter="\t", lineterminator="\n")
        for entry in manifest:
            writer.writerow([entry[key] for key in
                             ("path", "font_id", "theme_id", "title", "author", "weights")])
    (outdir / "catalog.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(f"[FONT-CATALOG] Validated {len(manifest)} custom VF fonts; MiSans/emoji unchanged")


def preview(title: str, font_path: Path, output: Path) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    image = Image.new("RGB", (480, 160), "#181818")
    draw = ImageDraw.Draw(image)
    try:
        font = ImageFont.truetype(str(font_path), 57)
        draw.text((240, 80), title, fill="#F2F2F2", font=font, anchor="mm")
    except (OSError, ValueError) as exc:
        # A valid CFF2 VF can be unsupported by FreeType/Pillow. Do not block
        # ROM builds because a decorative thumbnail cannot be drawn.
        print(f"[FONT-CATALOG] WARN fallback preview for {title}: {exc}")
        fallback = ImageFont.load_default()
        draw.text((240, 80), title, fill="#F2F2F2", font=fallback, anchor="mm")
    image.save(output, format="PNG", optimize=True)


def main() -> int:
    parser = argparse.ArgumentParser()
    commands = parser.add_subparsers(dest="action", required=True)
    ct = commands.add_parser("catalog")
    ct.add_argument("source_dir", type=Path)
    ct.add_argument("output_dir", type=Path)
    pv = commands.add_parser("preview")
    pv.add_argument("title")
    pv.add_argument("font", type=Path)
    pv.add_argument("output", type=Path)
    args = parser.parse_args()
    try:
        if args.action == "catalog":
            catalog(args.source_dir, args.output_dir)
        else:
            preview(args.title, args.font, args.output)
    except (OSError, ValueError, KeyError, TTLibError) as exc:
        print(f"[FONT-CATALOG] ERROR: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
