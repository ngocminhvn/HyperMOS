#!/usr/bin/env python3
"""Read-only discovery of HyperOS font-weight routing (A16/SDK36).

Run on the exact *decompiled stock* miui-framework.jar during HyperMOS build.
Does NOT change any smali or disable the Xiaomi MiSans font manager. Record
precise signatures before attempting a guarded ROM-specific patch.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path

TARGETS = (
    "miui/util/font/TypefaceUtils.smali",
    "miui/util/font/FontWght.smali",
    "miui/util/font/FontSettings.smali",
    "miui/util/font/FontScaleUtil.smali",
    "miui/util/font/ThemeFontManager.smali",
    "miui/util/font/MiProFontManager.smali",
    "miui/util/font/VFUtils.smali",
    "miui/util/font/DefaultFontManager.smali",
    "miui/util/font/FontManagerStubImpl.smali",
)
INTERESTING = re.compile(
    r"font|theme|wght|weight|check|support|current|manager|overlay",
    re.IGNORECASE,
)
DECLARATION = re.compile(r"^\.method\s+.*$", re.MULTILINE)
FIELD = re.compile(r"^\.field\s+.*$", re.MULTILINE)

def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("smali_root", type=Path)
    parser.add_argument("report", type=Path)
    args = parser.parse_args()

    if not args.smali_root.is_dir():
        parser.error(f"Not a decompiled JAR directory: {args.smali_root}")

    entries: dict[str, dict[str, object]] = {}
    for rel in TARGETS:
        matches = sorted(args.smali_root.glob("**/" + rel))
        if len(matches) > 1:
            raise SystemExit(f"Ambiguous copies of {rel}: {len(matches)}")
        if not matches:
            entries[rel] = {"present": False}
            continue
        source = matches[0].read_text(encoding="utf-8")
        signatures = [
            signature for signature in DECLARATION.findall(source)
            if INTERESTING.search(signature)
        ]
        fields = [
            field for field in FIELD.findall(source)
            if INTERESTING.search(field)
        ]
        entries[rel] = {
            "present": True,
            "sha256": hashlib.sha256(source.encode()).hexdigest(),
            "methods": signatures[:80],
            "fields": fields[:40],
            "methods_truncated": len(signatures) > 80,
            "fields_truncated": len(fields) > 40,
            "mentions_vfutils": "Lmiui/util/font/VFUtils;" in source,
            "mentions_misans": "MiSans" in source or "MiPro" in source,
        }

    report = {
        "status": "inspection_only_no_framework_modifications",
        "sdk": 36,
        "notice": "Settings APK slider gate must also be inspected on the same exact ROM. Do not disable FontSettings globally.",
        "classes": entries,
    }
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print("[FONT-AUDIT] Read-only miui-framework font routing scan")
    for rel, entry in entries.items():
        methods = entry.get("methods", [])
        print(f"[FONT-AUDIT] {Path(rel).stem}: present={entry['present']} interesting_methods={len(methods)}")
        if entry["present"]:
            for name in methods:
                print(f"[FONT-AUDIT]   {name.strip()}")
    print(f"[FONT-AUDIT] Report saved: {args.report}")
    print("[FONT-AUDIT] No bytecode patched: collect actual signatures before targeting Settings/ThemeFontManager")

if __name__ == "__main__":
    main()
