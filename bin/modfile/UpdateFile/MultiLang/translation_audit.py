#!/usr/bin/env python3
"""Read-only Vietnamese resource coverage audit for HyperMOS RRO APKs.

No overlay is generated, signed, enabled, or injected by this tool.
Default-config RRO entries are translation *candidates*, not verified Vietnamese.
"""
from __future__ import annotations

import argparse
import csv
import json
import re
import shutil
import subprocess
import sys
import zipfile
from collections import defaultdict
from pathlib import Path

RESOURCE = re.compile(
    r"^\s*resource\s+0x[0-9a-fA-F]+\s+(?:(?:[\w.$-]+):)?"
    r"(?P<kind>string|plurals)/(?P<name>[\w.$-]+)\b"
)
CONFIG = re.compile(r"^\s+\((?P<locale>[^)]*)\)\s+")
PACKAGE = re.compile(r"(?m)^\s*Package name=(?P<package>[\w.]+)\s+id=")
TARGET = re.compile(r'\btargetPackage\b[^\n]*?="([^"]+)"')
TARGET_RAW = re.compile(r'\btargetPackage\b[^\n]*?\(Raw:\s*"([^"]+)"')
OVERLAY_NAME = re.compile(r'\btargetName\b[^\n]*?="([^"]+)"')


def parse_resources(output: str) -> dict[str, set[str]]:
    """Map string/plurals resource names to the configurations present."""
    found: dict[str, set[str]] = defaultdict(set)
    current = None
    for line in output.splitlines():
        item = RESOURCE.match(line)
        if item:
            current = f"{item['kind']}/{item['name']}"
            found.setdefault(current, set())
            continue
        if line.lstrip().startswith("resource "):
            current = None
            continue
        config = CONFIG.match(line)
        if current is not None and config:
            # aapt2: () = default; (vi), (vi-rVN), (b+vi+VN) = Vietnamese.
            found[current].add(config["locale"])
    return dict(found)


def has_vietnamese(locales: set[str]) -> bool:
    return any(
        name == "vi" or name.startswith(("vi-", "vi_", "b+vi+"))
        for name in locales
    )


def dump(aapt2: str, apk: Path, kind: str) -> str:
    if kind == "xmltree":
        cmd = [aapt2, "dump", "xmltree", str(apk), "--file", "AndroidManifest.xml"]
    else:
        cmd = [aapt2, "dump", kind, str(apk)]
    result = subprocess.run(cmd, capture_output=True, text=True, errors="replace")
    if result.returncode:
        raise ValueError(f"{apk.name}: {kind}: {result.stderr.strip()[:350]}")
    return result.stdout


def overlay_info(aapt2: str, apk: Path) -> dict:
    with zipfile.ZipFile(apk) as archive:
        bad = archive.testzip()
        if bad:
            raise ValueError(f"{apk.name}: corrupt ZIP entry {bad}")
        if "AndroidManifest.xml" not in archive.namelist():
            raise ValueError(f"{apk.name}: no AndroidManifest.xml")
    xml = dump(aapt2, apk, "xmltree")
    m = TARGET.search(xml) or TARGET_RAW.search(xml)
    if not m:
        raise ValueError(f"{apk.name}: no overlay targetPackage (not an RRO?)")
    p = dump(aapt2, apk, "packagename").strip().strip("'\" ")
    if not re.fullmatch(r"[\w.]+", p):
        raise ValueError(f"{apk.name}: invalid overlay package: {p[:100]}")
    return {
        "file": apk.name,
        "overlay_package": p,
        "target_package": m.group(1),
        "target_name": (OVERLAY_NAME.search(xml) or [None, None])[1],
        "resources": parse_resources(dump(aapt2, apk, "resources")),
    }


def stock_info(aapt2: str, apk: Path) -> tuple[str, dict[str, set[str]]]:
    p = dump(aapt2, apk, "packagename").strip().strip("'\" ")
    if not re.fullmatch(r"[\w.]+", p):
        raise ValueError(f"{apk.name}: invalid stock package: {p[:100]}")
    return p, parse_resources(dump(aapt2, apk, "resources"))


def audit(overlays: list[Path], stock_root: Path | None, aapt2: str) -> dict:
    invalid = []
    records = []
    duplicate_ids = defaultdict(list)
    grouped: dict[str, list[dict]] = defaultdict(list)

    for apk in overlays:
        try:
            rec = overlay_info(aapt2, apk)
            records.append(rec)
            grouped[rec["target_package"]].append(rec)
            duplicate_ids[rec["overlay_package"]].append(rec["file"])
        except (OSError, ValueError, zipfile.BadZipFile) as exc:
            invalid.append(str(exc))

    stock = {}
    stock_errors = []
    if stock_root:
        for apk in sorted(stock_root.rglob("*.apk")):
            # Skip stock RROs: they are not the primary target app resource table.
            if "/overlay/" in apk.as_posix():
                continue
            try:
                pkg = dump(aapt2, apk, "packagename").strip().strip("'\" ")
                if pkg not in grouped:
                    continue
                name, entries = stock_info(aapt2, apk)
                if name not in stock or len(entries) > len(stock[name]["resources"]):
                    stock[name] = {"apk": str(apk.relative_to(stock_root)), "resources": entries}
            except (OSError, ValueError, zipfile.BadZipFile) as exc:
                stock_errors.append(str(exc))

    packages = []
    missing_rows = []
    for target in sorted(grouped):
        layers = grouped[target]
        candidates = set()
        explicit_vi = set()
        default_only = set()
        for layer in layers:
            for key, locales in layer["resources"].items():
                if has_vietnamese(locales):
                    explicit_vi.add(key)
                    candidates.add(key)
                elif "" in locales:
                    default_only.add(key)
                    candidates.add(key)
        app = stock.get(target)
        if app:
            source = app["resources"]
            native_vi = {key for key, loc in source.items() if has_vietnamese(loc)}
            source_keys = set(source)
            missing = sorted(source_keys - native_vi - candidates)
            missing_rows.extend((target, key) for key in missing)
            total = len(source_keys)
        else:
            missing = []
            total = None
            native_vi = set()
        packages.append({
            "target_package": target,
            "stock_apk": app["apk"] if app else None,
            "overlay_files": [x["file"] for x in layers],
            "source_string_resources": total,
            "native_vi": len(native_vi),
            "overlay_vi": len(explicit_vi),
            "overlay_default_candidates": len(default_only - explicit_vi),
            "candidate_covered_in_stock": (
                len((candidates | native_vi) & set(app["resources"])) if app else None
            ),
            "missing_count": len(missing) if app else None,
            "sample_missing": missing[:25],
        })

    return {
        "mode": "stock_comparison" if stock_root else "overlay_inventory",
        "overlay_apks": len(overlays),
        "valid_overlay_apks": len(records),
        "invalid": invalid,
        "duplicate_overlay_package_ids": {
            name: files for name, files in duplicate_ids.items() if len(files) > 1
        },
        "stock_errors": stock_errors[:150],
        "stock_targets_found": len(stock),
        "packages": packages,
        "missing_rows": missing_rows,
    }


def write_reports(result: dict, dest: Path) -> None:
    dest.mkdir(parents=True, exist_ok=True)
    public = {k: v for k, v in result.items() if k != "missing_rows"}
    (dest / "report.json").write_text(
        json.dumps(public, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    with (dest / "missing.csv").open("w", newline="", encoding="utf-8-sig") as stream:
        writer = csv.writer(stream)
        writer.writerow(["target_package", "resource_name"])
        writer.writerows(result["missing_rows"])
    lines = [
        "# HyperMOS — Vietnamese Translation Audit",
        "",
        f"- Mode: **{result['mode']}**",
        f"- Overlays: **{result['valid_overlay_apks']}/{result['overlay_apks']}** valid",
        f"- Stock targets matched: **{result['stock_targets_found']}**",
        "",
        "This is a **resource coverage estimate**, not a measured translation percentage.",
        "Default-configuration overlay strings are candidates only; they may not be Vietnamese.",
        "An overlay may also be disabled or rejected by Android's idmap/overlayable policy.",
        "Strings embedded in code, arrays and remote UI are outside this audit.",
        "",
        "## Package summary",
        "",
        "| Target package | Stock strings | Native vi | Overlay vi | Default candidates | Missing candidates |",
        "| --- | ---: | ---: | ---: | ---: | ---: |",
    ]
    for p in sorted(
        result["packages"],
        key=lambda v: (v["missing_count"] is None, -(v["missing_count"] or 0), v["target_package"]),
    ):
        def cell(value: int | None) -> str:
            return "N/A" if value is None else str(value)
        lines.append(
            f"| {p['target_package']} | {cell(p['source_string_resources'])} | "
            f"{p['native_vi']} | {p['overlay_vi']} | {p['overlay_default_candidates']} | "
            f"{cell(p['missing_count'])} |"
        )
    if result["invalid"]:
        lines += ["", "## Invalid overlays", ""]
        lines += [f"- {e}" for e in result["invalid"]]
    if result["duplicate_overlay_package_ids"]:
        lines += ["", "## Duplicate overlay package IDs", ""]
        lines += [f"- {k}: {', '.join(v)}" for k, v in result["duplicate_overlay_package_ids"].items()]
    lines += [
        "", "## How to proceed", "",
        "Review missing.csv and the installed overlay state before authoring replacement resources.",
        "Only use separately verified, correctly compiled and signed RRO APKs as supplements.",
        "No translation or APK was automatically created or installed by this workflow.",
    ]
    (dest / "SUMMARY.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def self_test() -> None:
    aapt2 = """
      resource 0x7f050001 string/settings_title
        () "Settings"
        (vi) "Cài đặt"
      resource 0x7f050002 string/battery
        () "Battery"
      resource 0x7f050003 plurals/items
        (vi-rVN) (bag)
      resource 0x7f050004 drawable/icon
        () (file) res/drawable/a.png
      resource 0x7f050005 string/about
        (b+vi+VN) "Giới thiệu"
    """
    result = parse_resources(aapt2)
    assert set(result) == {"string/settings_title", "string/battery", "plurals/items", "string/about"}
    assert has_vietnamese(result["string/settings_title"])
    assert has_vietnamese(result["plurals/items"])
    assert has_vietnamese(result["string/about"])
    assert not has_vietnamese(result["string/battery"])
    assert TARGET.search('A: android:targetPackage(0x01010021)="com.android.settings"')
    print("[PASS] audit resource parser self-test")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--overlays", type=Path)
    ap.add_argument("--extra-overlays", type=Path)
    ap.add_argument("--stock-apks", type=Path)
    ap.add_argument("--output", type=Path, default=Path("translation-audit"))
    ap.add_argument("--aapt2", default=shutil.which("aapt2"))
    ap.add_argument("--self-test", action="store_true")
    args = ap.parse_args()
    if args.self_test:
        self_test()
        return 0
    if not args.aapt2 or not Path(args.aapt2).exists():
        ap.error("aapt2 is required (pass --aapt2 /path/to/aapt2)")
    if not args.overlays or not args.overlays.is_dir():
        ap.error("--overlays must refer to the existing source APK directory")
    paths = sorted(args.overlays.glob("*.apk"))
    if args.extra_overlays and args.extra_overlays.exists():
        paths += sorted(args.extra_overlays.glob("*.apk"))
    if not paths:
        ap.error("no overlay APK files found")
    if args.stock_apks and not args.stock_apks.is_dir():
        ap.error("--stock-apks directory not found")
    result = audit(paths, args.stock_apks, args.aapt2)
    write_reports(result, args.output)
    print(f"[TRANSLATION AUDIT] {result['valid_overlay_apks']}/{len(paths)} valid overlays")
    print(f"[TRANSLATION AUDIT] {result['stock_targets_found']} matched stock targets")
    print(f"[TRANSLATION AUDIT] report: {args.output / 'SUMMARY.md'}")
    if result["invalid"] or result["duplicate_overlay_package_ids"]:
        print("[TRANSLATION AUDIT] errors detected — check SUMMARY.md", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
