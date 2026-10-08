#!/usr/bin/env python3
"""Flag translated short English UI labels and trademark/technical terms for review.

Read-only. Do not assume every English word is a proper noun: "Key" can mean
a keyboard key, a security key, or a product name depending on context.
Do not indiscriminately change previously reviewed translations.
"""
import argparse
import csv
import json
import re
import xml.etree.ElementTree as ET
from pathlib import Path

PROTECTED_TERMS = ("Wi-Fi", "Bluetooth", "PIN", "NFC", "USB", "WLAN",
                   "LE Audio", "Xiaomi", "Smart Play", "AI", "TV")
APP_NAMES = ("Nothings.Settings", "Nothings.MiuiSystemUI",
             "Nothings.MiuiSystemUIPlugin", "Nothings.SecurityCenter")
LANGUAGE_SOURCE = "Nothings.Settings.apk"


def load_translations(directory):
    result = {}
    for app in APP_NAMES:
        path = directory / (app + ".xml")
        if not path.is_file():
            raise RuntimeError("Missing reviewed translation XML: " + str(path))
        d = ET.parse(path).getroot()
        for e in d:
            if e.tag == "string" and e.get("name"):
                result[(app + ".apk", e.get("name"))] = "".join(e.itertext())
    return result


def find_flags(english_review: Path, entries):
    found = []
    with english_review.open(encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            key = (row["overlay_apk"], row["resource_name"])
            if key not in entries:
                continue
            en = row.get("english_source", "").strip()
            vi = entries[key].strip()
            flags = []
            if re.fullmatch(r"[A-Za-z]{1,4}", en) and en.casefold() != vi.casefold():
                flags.append("short_english_label_verify_context")
            if en.casefold() == "key" and vi.casefold() != "key":
                flags.append("exact_key_must_review_not_translate_blindly")
            for term in PROTECTED_TERMS:
                if re.search(r"(?<![A-Za-z])" + re.escape(term) + r"(?![A-Za-z])", en, re.I):
                    if not re.search(r"(?<![A-Za-z])" + re.escape(term) + r"(?![A-Za-z])", vi, re.I):
                        flags.append("unpreserved_technical_term:" + term)
            if flags:
                found.append({
                    "apk": key[0], "resource": key[1], "english": en,
                    "vietnamese": vi, "flags": ";".join(flags),
                })
    return found


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--patches", type=Path)
    p.add_argument("--english-review", type=Path)
    p.add_argument("--output", type=Path)
    p.add_argument("--self-test", action="store_true")
    a = p.parse_args()
    if a.self_test:
        assert re.fullmatch(r"[A-Za-z]{1,4}", "Key")
        assert not re.fullmatch(r"[A-Za-z]{1,4}", "Backspace")
        print("[PASS] short English token audit parser")
        return
    if not a.patches or not a.english_review or not a.output:
        p.error("--patches --english-review --output required")
    a.output.mkdir(parents=True, exist_ok=True)
    found = find_flags(a.english_review, load_translations(a.patches))
    path = a.output / "review-english-short-terms.csv"
    with path.open("w", encoding="utf-8-sig", newline="") as f:
        fields = ("apk", "resource", "english", "vietnamese", "flags")
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(found)
    report = {
        "items_needing_manual_review": len(found),
        "exact_key_labels": sum("exact_key_" in item["flags"] for item in found),
        "technical_terms_missing": sum("unpreserved_technical_term:" in item["flags"] for item in found),
        "note": "Read-only. Flags are potential issues, not automatic translation mistakes.",
    }
    (a.output / "short-terms-summary.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print("[SHORT-TERMS] " + json.dumps(report, ensure_ascii=False))
    for row in found[:30]:
        print("[SHORT-TERMS-REVIEW] " + json.dumps(row, ensure_ascii=False))


if __name__ == "__main__":
    main()
