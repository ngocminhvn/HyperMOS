#!/usr/bin/env python3
"""Read-only English stock APK -> Vietnamese overlay XML comparison.

This reports translation gaps by existing Android resource name. It neither
creates translations nor signs/patches any APK. Inspect candidates manually.
"""
import argparse
import csv
import json
import re
import subprocess
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path

# Expand stock English -> Vietnamese gap discovery to Xiaomi system apps
# already covered by the 67 bundled Nothings RROs. This is READ-ONLY.
# Do not automatically import translations or change the ROM boot chain.
PRIORITY = {
    "Nothings.Settings", "Nothings.MiSettings", "Nothings.MiuiSystemUI",
    "Nothings.HyperPhoneSystemUI", "Nothings.MiuiSystemUIPlugin",
    "Nothings.SecurityCenter",
    "Nothings.MiuiHome", "Nothings.MiuiCamera", "Nothings.MiuiGallery",
    "Nothings.FileExplorer", "Nothings.ThemeManager", "Nothings.ThemeManagerV2",
    "Nothings.Weather", "Nothings.Calendar", "Nothings.Contacts",
    "Nothings.InCallUI", "Nothings.Permissioncontroller",
    "Nothings.PowerKeeper", "Nothings.PersonalAssistant",
    "Nothings.Mms", "Nothings.MiuiAod", "Nothings.MiuiBluetooth",
    "Nothings.MiSound", "Nothings.MiShare",
}
CORE = re.compile(
    r"setting|notification|control|privacy|permission|security|battery|power|"
    r"lock|screen|status|display|wifi|network|bluetooth|app.manage|device", re.I,
)
SKIP = re.compile(r"^(gb_|gs_|game_|keywords?_|dirac_|wifitrackerlib_)", re.I)
CJK = re.compile(r"[\u3400-\u9fff]")
WORD = re.compile(r"[A-Za-z]{2,}")
STATUS = ("MISSING_VI", "SAME_AS_ENGLISH_REVIEW", "VI_PRESENT_REVIEW")
HEADERS = ("overlay_apk", "target_package", "stock_apk", "resource_name",
           "english_source", "vietnamese_overlay", "english_locale",
           "status", "priority")


def strings_at(root, directories):
    out = {}
    for folder in directories:
        # Stock apktool output has res/values-xx; workflow-exported overlay
        # translations have values-xx directly below the APK-named folder.
        directory = root / "res" / folder
        if not directory.is_dir():
            directory = root / folder
        if not directory.is_dir():
            continue
        for filename in sorted(directory.glob("*.xml")):
            if filename.name == "public.xml":
                continue
            for elem in ET.parse(filename).getroot():
                if elem.tag != "string" or not elem.get("name"):
                    continue
                key = elem.get("name")
                value = "".join(elem.itertext()).strip()
                if value and key not in out:
                    out[key] = (value, folder)
    return out


def looks_english(value):
    candidate = re.sub(r"<[^>]+>|%\d*\$?[#0 ,.+-]*[a-zA-Z]", " ", value)
    candidate = re.sub(r"https?://\S+|@\w+/\S+", " ", candidate)
    if CJK.search(candidate):
        return False
    words = WORD.findall(candidate)
    if not words or sum(c.isascii() for c in candidate) < len(candidate) * 0.95:
        return False
    return len(words) > 1 or words[0].casefold() in {
        "battery", "settings", "privacy", "security", "display", "sound",
        "device", "network", "connected", "notifications", "permission",
        "permissions", "storage", "system", "accessibility", "screen",
    }


def compare(source, vi, overlay, target, stock, native_vi=None):
    result = []
    native_vi = native_vi or {}
    for name, (english, locale) in sorted(source.items()):
        # Stock Vietnamese takes precedence: translating it again would be
        # redundant, even when an external overlay lacks the same resource.
        if name in native_vi:
            continue
        if not looks_english(english):
            continue
        vietnamese = vi.get(name, ("", ""))[0]
        status = ("MISSING_VI" if not vietnamese else
                  "SAME_AS_ENGLISH_REVIEW" if vietnamese.casefold() == english.casefold()
                  else "VI_PRESENT_REVIEW")
        priority = "low" if SKIP.search(name) else "high" if CORE.search(name) else "normal"
        result.append(dict(zip(HEADERS, (
            overlay + ".apk", target, stock, name, english, vietnamese,
            locale, status, priority,
        ))))
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--report", type=Path)
    parser.add_argument("--stock-root", type=Path)
    parser.add_argument("--overlay-xml", type=Path)
    parser.add_argument("--apktool", type=Path)
    parser.add_argument("--output", type=Path, default=Path("translation-audit"))
    parser.add_argument("--self-test", action="store_true")
    a = parser.parse_args()
    if a.self_test:
        src = {"battery_title": ("Battery saver", "values-en"),
               "network_options": ("Network settings", "values-en"),
               "non_english": ("设置", "values")}
        vi = {"battery_title": ("Tiết kiệm pin", "values-vi")}
        found = compare(src, vi, "Nothings.Settings", "com.android.settings", "Settings.apk")
        assert [(x["resource_name"], x["status"]) for x in found] == [
            ("battery_title", "VI_PRESENT_REVIEW"),
            ("network_options", "MISSING_VI"),
        ]
        assert compare(src, {}, "Nothings.Settings", "com.android.settings",
                       "Settings.apk", native_vi={"network_options": ("Cài đặt mạng", "values-vi")}) == [
            x for x in found if x["resource_name"] == "battery_title"
        ]
        with tempfile.TemporaryDirectory() as td:
            root = Path(td) / "Nothings.Settings" / "values-vi"
            root.mkdir(parents=True)
            (root / "strings.xml").write_text(
                '<resources><string name="battery_title">Tiết kiệm pin</string></resources>',
                encoding="utf-8")
            assert strings_at(root.parent, ["values-vi"])["battery_title"][0] == "Tiết kiệm pin"
        print("[PASS] English -> Vietnamese resource comparison + flattened overlay XML")
        return 0
    for required in ("report", "stock_root", "overlay_xml", "apktool"):
        if getattr(a, required) is None:
            parser.error("--" + required.replace("_", "-") + " required")
    inv = json.loads(a.report.read_text(encoding="utf-8"))
    pkg_to_stock = {x["target_package"]: x["stock_apk"]
                    for x in inv["packages"] if x.get("stock_apk")}
    rows, warnings = [], []
    with tempfile.TemporaryDirectory(prefix="hypermos-english-vi-") as temp:
        for entry in inv["overlay_resources"]:
            name = entry["file"].removesuffix(".apk")
            if name not in PRIORITY:
                continue
            target = entry["target_package"]
            source = pkg_to_stock.get(target)
            if not source:
                warnings.append(name + ": no matching stock APK for " + target)
                continue
            stock = a.stock_root / source
            translated = a.overlay_xml / name
            if not stock.is_file() or not translated.is_dir():
                warnings.append(name + ": missing stock file or decoded overlay XML")
                continue
            location = Path(temp) / name
            build = subprocess.run(
                ["java", "-Xmx4g", "-jar", str(a.apktool), "d", "-f", "-s",
                 str(stock), "-o", str(location)],
                capture_output=True, text=True, errors="replace",
            )
            if build.returncode:
                warnings.append(name + ": apktool failed: " + build.stderr[-200:])
                continue
            english = strings_at(location, [
                "values-en", "values-en-rUS", "values-en-rGB",
                "values-b+en+US", "values",
            ])
            vietnamese = strings_at(translated, [
                "values-vi", "values-vi-rVN", "values-b+vi+VN",
            ])
            native_vi = strings_at(location, [
                "values-vi", "values-vi-rVN", "values-b+vi+VN",
            ])
            rows.extend(compare(english, vietnamese, name, target, source,
                                native_vi=native_vi))
    a.output.mkdir(parents=True, exist_ok=True)
    with (a.output / "english-vietnamese-all.csv").open(
        "w", newline="", encoding="utf-8-sig"
    ) as file:
        writer = csv.DictWriter(file, fieldnames=HEADERS)
        writer.writeheader()
        writer.writerows(rows)
    priority = [x for x in rows if x["status"] != "VI_PRESENT_REVIEW"]
    priority.sort(key=lambda x: (x["priority"] != "high",
                                x["status"] != "MISSING_VI", x["overlay_apk"], x["resource_name"]))
    with (a.output / "english-vietnamese-review.csv").open(
        "w", newline="", encoding="utf-8-sig"
    ) as file:
        writer = csv.DictWriter(file, fieldnames=HEADERS)
        writer.writeheader()
        writer.writerows(priority)
    info = {
        "english_resource_candidates": len(rows),
        "missing_vi": sum(x["status"] == "MISSING_VI" for x in rows),
        "same_as_english_needs_review": sum(x["status"] == "SAME_AS_ENGLISH_REVIEW" for x in rows),
        "missing_by_overlay": {
            name: sum(x["status"] == "MISSING_VI" and x["overlay_apk"] == name
                      for x in rows)
            for name in sorted({x["overlay_apk"] for x in rows})
        },
        "warnings": warnings,
        "caveat": ("English heuristic is conservative; source default locale may "
                   "contain language other than English. Resource presence does not "
                   "prove that the overlay is enabled or renders correctly. "
                   "No APK was modified."),
    }
    (a.output / "english-vi-summary.json").write_text(
        json.dumps(info, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    with (a.output / "ENGLISH_VI.md").open("w", encoding="utf-8") as file:
        file.write("# English stock to Vietnamese RRO comparison\n\n")
        file.write(f"English-source candidates: {len(rows)}. "
                   f"Missing VI: {info['missing_vi']}. "
                   f"Identical English values to review: {info['same_as_english_needs_review']}.\n\n")
        file.write("Review english-vietnamese-review.csv before translating any UI.\n")
        file.write("\n## Missing English-to-Vietnamese candidates by overlay\n\n")
        file.write("| Existing RRO | Missing candidate strings |\n| --- | ---: |\n")
        for name, count in sorted(info["missing_by_overlay"].items(),
                                  key=lambda kv: (-kv[1], kv[0])):
            file.write(f"| {name} | {count} |\n")
        for warning in warnings:
            file.write("\n- " + warning.replace("|", "/"))
        file.write("\n")
    print("[EN-VI] " + json.dumps(info, ensure_ascii=False))
    return 0 if rows else 2


if __name__ == "__main__":
    raise SystemExit(main())
