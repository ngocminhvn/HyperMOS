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
import zipfile
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

def settings_symbols(images_root: Path | None) -> dict[str, object]:
    """Find possible Settings UI gating symbols, without patching/rebuilding APK."""
    if images_root is None or not images_root.is_dir():
        return {"inspected": False, "reason": "no unpacked images directory"}
    candidates = [
        file for file in sorted(images_root.rglob("Settings.apk"))
        if "framework" not in str(file).lower()
    ][:4]
    result: list[dict[str, object]] = []
    for apk in candidates:
        symbols: set[str] = set()
        with zipfile.ZipFile(apk) as archive:
            for item in archive.namelist():
                if not re.fullmatch(r"classes\d*\.dex", item):
                    continue
                data = archive.read(item)
                for token in re.findall(rb"[A-Za-z0-9_/$;.()\-]{9,}", data):
                    if any(word in token.lower() for word in (
                        b"fontweight", b"font_weight", b"fontwght", b"fontsettings",
                        b"fontscale", b"typefaceutils", b"themefont",
                    )):
                        symbols.add(token.decode("ascii", errors="replace")[:180])
        result.append({
            "path": str(apk.relative_to(images_root)),
            "sha256": hashlib.sha256(apk.read_bytes()).hexdigest(),
            "candidate_symbols": sorted(symbols)[:100],
            "symbols_truncated": len(symbols) > 100,
        })
    return {"inspected": bool(candidates), "packages": result}



# Method bodies are indispensable for safely deciding whether Xiaomi Settings
# disables the slider, and whether the runtime really understands themed VF.
# Export selected stock methods only; do not copy entire JAR or APK into artifacts.
FOCUS_CLASSES = {
    "FontSettings": ("checkUsingThemeVF", "isUsingThemeVF", "checkUsingThemeFont",
                     "isUsingThemeFont", "checkFontVarWeight", "setWeightsSettings",
                     "getWeightsSettings", "loadFontSetting", "<clinit>"),
    "FontWght": ("getScaleWght", "getWeightIdx", "getWghtArray", "getWghtInRange", "<clinit>"),
    "ThemeFontManager": ("getReplacedFont", "loadThemeFont", "createSysThemeFontInfo"),
    "MiProFontManager": ("doReplaceWithVarFont", "getReplacedFont", "loadFont"),
    "VFUtils": ("getVarFont",),
    "FontType": ("<clinit>",),
}
SETTINGS_CLASS_KEYWORDS = (
    "FontWeightUtils", "FontWeightAdjustView", "LiteFontWeightPreference",
    "FontSettingsScrollView", "FontSettingsActivity",
    "FontWeightAdjustmentPreferenceController", "FontSettingsFragment",
    "FontSettingsPreference",
)
METHOD_PATTERN = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method\s*$")


def save_font_methods(framework_root: Path, settings_root: Path | None, out: Path) -> None:
    records: list[str] = []
    counts: dict[str, int] = {}

    def read_methods(path: Path, allow: tuple[str, ...], scope: str) -> None:
        source = path.read_text(encoding="utf-8")
        name = path.stem
        matched = 0
        for match in METHOD_PATTERN.finditer(source):
            body = match.group(0)
            signature = body.splitlines()[0]
            if not any(token.lower() in signature.lower() for token in allow):
                continue
            # Do not trim instructions: a patch requires all exit paths/labels.
            if len(body) > 28000:
                records.append(f"[SKIPPED: huge method {scope}/{name} {signature}]")
                continue
            records.append(f"\n========== {scope}/{name}: {signature} ==========\n{body}\n")
            matched += 1
        counts[f"{scope}/{name}"] = matched

    for name, methods in FOCUS_CLASSES.items():
        matches = sorted(framework_root.rglob(name + ".smali"))
        for path in matches[:2]:
            if "/miui/util/font/" not in str(path):
                continue
            read_methods(path, methods, "miui-framework")

    if settings_root and settings_root.is_dir():
        for path in sorted(settings_root.rglob("*.smali")):
            if not any(needle in path.stem for needle in SETTINGS_CLASS_KEYWORDS):
                continue
            # Ignore anonymous view and Compose helpers unless they contain
            # relevant weight-control logic.
            allow = ("font", "weight", "theme", "onCreate", "onResume",
                     "onStart", "init", "<clinit>")
            read_methods(path, allow, "Settings")
            if len(records) >= 200:
                break

    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(
        "HyperMOS stock A16 font routing method excerpts (read-only)\n"
        + "\n".join(records),
        encoding="utf-8",
    )
    print("[FONT-AUDIT] Extracted target method bodies into " + str(out))
    for k, count in counts.items():
        if count:
            print(f"[FONT-AUDIT] SOURCE {k}: {count} methods")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("smali_root", type=Path)
    parser.add_argument("report", type=Path)
    parser.add_argument("--images-root", type=Path, default=None)
    parser.add_argument("--settings-smali-root", type=Path, default=None)
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
        "settings_apk": settings_symbols(args.images_root),
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
    print(f"[FONT-AUDIT] Settings APK scan: inspected={report['settings_apk']['inspected']}")
    print(f"[FONT-AUDIT] Report saved: {args.report}")
    save_font_methods(args.smali_root, args.settings_smali_root, args.report.with_name("font-logic-smali.txt"))
    print("[FONT-AUDIT] No bytecode patched: collect actual signatures before targeting Settings/ThemeFontManager")

if __name__ == "__main__":
    main()
