#!/usr/bin/env python3
"""Read-only comparison: Xiaomi.eu/community Vietnamese XML vs HyperMOS RROs.

Does NOT copy upstream translated text to the report or repository.
Does NOT re-sign, rebuild, install or replace any existing overlay APK.
An upstream key absent from an existing overlay is only a CANDIDATE: it must
exist in the matching HyperOS 3 stock target APK and pass overlayable rules.
"""
from __future__ import annotations

import argparse
import csv
import json
import re
import subprocess
import tempfile
import xml.etree.ElementTree as ET
from collections import Counter
from pathlib import Path

# Only compare XML for the same Xiaomi app: do not assume all RROs share a target.
MAPPING = {
    "Nothings.Settings": "Settings.apk",
    "Nothings.MiSettings": "MiSettings.apk",
    "Nothings.MiuiSystemUI": "MiuiSystemUI.apk",
    "Nothings.MiuiSystemUIPlugin": "MiuiSystemUIPlugin.apk",
    "Nothings.SecurityCenter": "SecurityCenter.apk",
}
PRIORITY = re.compile(
    r"setting|status|systemui|control|notification|privacy|permission|"
    r"lock|screen|battery|power|security|network|wifi|bluetooth|display|"
    r"volume|sound|accessibility|app_manage", re.I
)
LOW = re.compile(r"^(gb_|gs_|game_|keywords?_|search_keywords?_|dirac_)", re.I)
KINDS = {"string", "string-array", "integer-array", "plurals"}


def collect(root: Path) -> dict[tuple[str, str], tuple[str, str]]:
    """Collect name/type and source XML filename, not copyrighted string values."""
    found = {}
    for locale in ("values-vi", "values-vi-rVN"):
        folder = root / "res" / locale
        if not folder.is_dir():
            folder = root / locale
        if not folder.is_dir():
            continue
        for file in sorted(folder.glob("*.xml")):
            try:
                parsed = ET.parse(file).getroot()
            except ET.ParseError as e:
                raise ValueError(f"Invalid resource XML {file}: {e}") from e
            for element in parsed:
                if element.tag not in KINDS or not element.get("name"):
                    continue
                name = element.get("name")
                key = (element.tag, name)
                if key in found:
                    continue
                if element.tag in {"plurals", "string-array", "integer-array"}:
                    populated = any("".join(item.itertext()).strip() for item in element)
                else:
                    populated = bool("".join(element.itertext()).strip())
                if populated:
                    found[key] = (locale, file.name)
    return found


def audit(current: Path, upstream: Path, apktool: Path, output: Path,
          upstream_sha: str) -> dict:
    output.mkdir(parents=True, exist_ok=True)
    report_rows = []
    packages = []
    warnings = []
    with tempfile.TemporaryDirectory(prefix="hypermos-xiaomi-eu-") as tmp:
        for overlay, app in MAPPING.items():
            apk = current / (overlay + ".apk")
            src = upstream / "Vietnamese" / "main" / app / "res"
            info = {"overlay": overlay + ".apk", "upstream_app": app}
            if not apk.is_file() or not src.is_dir():
                warnings.append(f"{overlay}: missing original APK or upstream source directory")
                continue
            decoded = Path(tmp) / overlay
            result = subprocess.run(
                ["java", "-Xmx3g", "-jar", str(apktool), "d", "-f", "-s",
                 str(apk), "-o", str(decoded)],
                capture_output=True, text=True, errors="replace"
            )
            if result.returncode:
                warnings.append(f"{overlay}: apktool decode failed ({result.stderr[-220:]})")
                continue
            try:
                existing = collect(decoded)
                external = collect(src.parent)
            except ValueError as e:
                warnings.append(str(e))
                continue
            candidate_count = 0
            for (kind, key), (locale, file) in sorted(external.items()):
                if (kind, key) in existing:
                    continue
                candidate_count += 1
                importance = ("low" if LOW.search(key) else
                              "high" if PRIORITY.search(key) else "normal")
                report_rows.append({
                    "overlay_apk": overlay + ".apk",
                    "upstream_app": app,
                    "resource_type": kind,
                    "resource_name": key,
                    "source_xml": f"Vietnamese/main/{app}/res/{locale}/{file}",
                    "priority": importance,
                    "status": "UPSTREAM_ONLY_VERIFY_IN_STOCK_ROM",
                })
            info.update({
                "upstream_keys": len(external),
                "existing_overlay_keys": len(existing),
                "shared_keys": len(set(external) & set(existing)),
                "upstream_only_candidates": candidate_count,
                "existing_only_keys": len(set(existing) - set(external)),
            })
            packages.append(info)
            print("[XIAOMIEU-KEYS] " + json.dumps(info, ensure_ascii=False))

    report_rows.sort(key=lambda x: (
        {"high": 0, "normal": 1, "low": 2}[x["priority"]],
        x["overlay_apk"], x["resource_type"], x["resource_name"],
    ))
    with (output / "xiaomieu-gaps.csv").open("w", newline="", encoding="utf-8-sig") as stream:
        columns = ("overlay_apk", "upstream_app", "resource_type",
                   "resource_name", "source_xml", "priority", "status")
        writer = csv.DictWriter(stream, fieldnames=columns)
        writer.writeheader()
        writer.writerows(report_rows)

    summary = {
        "source": "https://github.com/butinhi/MIUI-14-XML-Vietnamese",
        "source_revision": upstream_sha,
        "attribution": "Vietnamese translation contributors, including Ken Hao",
        "package_summary": packages,
        "total_upstream_only_keys": len(report_rows),
        "priority_counts": dict(Counter(x["priority"] for x in report_rows)),
        "warnings": warnings,
        "limitations": [
            "Upstream XML is NOT necessarily compatible with HyperOS 3/Android 16.",
            "A missing overlay key may also be absent from the stock target APK.",
            "Existing Vietnamese translations are not overwritten.",
            "No upstream translation text is mirrored or redistributed here.",
            "Before copying any translated text, confirm redistribution permission and preserve attribution.",
        ],
    }
    (output / "xiaomieu-summary.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    lines = ["# Xiaomi.eu Vietnamese source vs existing HyperMOS overlays", "",
             f"Upstream commit: "+upstream_sha, "",
             "This is a **read-only resource-name audit**, not completed translation.",
             "The source repository does not publish a clear license for reusing its translations.",
             "No translated text is copied and no overlay APK is changed.", "",
             "| Existing overlay | Existing keys | Upstream keys | Shared | New candidates |",
             "| --- | ---: | ---: | ---: | ---: |"]
    for p in packages:
        lines.append(
            f"| {p['overlay']} | {p['existing_overlay_keys']} | "
            f"{p['upstream_keys']} | {p['shared_keys']} | {p['upstream_only_candidates']} |"
        )
    lines += ["", "Download xiaomieu-gaps.csv for keys worth checking.",
              "Only consider candidates that **also exist in the exact stock HyperOS 3 APK**.",
              "Check XML format arguments/plurals, target restrictions and rights before porting."]
    if warnings:
        lines += ["", "## Warnings", ""] + [f"- {w}" for w in warnings]
    (output / "XIAOMIEU_AUDIT.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    if not packages:
        raise RuntimeError("No priority overlays could be compared")
    return summary


def self_test():
    with tempfile.TemporaryDirectory() as tmp:
        t = Path(tmp)
        (t / "res" / "values-vi").mkdir(parents=True)
        (t / "res" / "values-vi" / "strings.xml").write_text(
            '<resources><string name="battery">Tiết kiệm pin</string>'
            '<string name="foo"></string><plurals name="item_count">'
            '<item quantity="other">%d mục</item></plurals></resources>',
            encoding="utf-8",
        )
        assert set(collect(t)) == {("string", "battery"), ("plurals", "item_count")}
        print("[PASS] Xiaomi.eu source XML key parser self-test")


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--current", type=Path)
    p.add_argument("--upstream", type=Path)
    p.add_argument("--apktool", type=Path)
    p.add_argument("--upstream-sha", default="unknown")
    p.add_argument("--output", type=Path, default=Path("xiaomieu-gap-audit"))
    p.add_argument("--self-test", action="store_true")
    args = p.parse_args()
    if args.self_test:
        self_test()
        return
    for key in ("current", "upstream", "apktool"):
        if not getattr(args, key):
            p.error("--" + key + " is required")
    audit(args.current, args.upstream, args.apktool, args.output, args.upstream_sha)


if __name__ == "__main__":
    main()
