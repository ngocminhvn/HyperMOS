#!/usr/bin/env python3
"""Read-only Xiaomi.eu -> existing Nothings RRO Vietnamese key audit.

The report contains resource *names*, counts and safety flags, never the
Xiaomi.eu translation text. No APK is modified, rebuilt or redistributed.
"""
from __future__ import annotations

import argparse
import csv
import json
import re
import subprocess
import tempfile
from collections import Counter
from pathlib import Path

from compare_english_vi import strings_at

VI_FOLDERS = ("values-vi", "values-vi-rVN", "values-b+vi+VN")
DEFAULT_FOLDERS = ("values",)
EN_FOLDERS = ("values-en", "values-en-rUS", "values-en-rGB", "values")
PLACEHOLDER = re.compile(r"%(?:\d+\$)?[-+#0 ,.(]*\d*(?:\.\d+)?[a-zA-Z%]")


def format_tokens(value: str) -> Counter:
    return Counter(x for x in PLACEHOLDER.findall(value) if x != "%%")


def check_keys(eu_vi, eu_en, existing, retired):
    """Classify by resource key only; do not emit EU translation values."""
    rows = []
    for key in sorted(eu_vi):
        if key in retired:
            status = "RETIRED_DO_NOT_READD"
        elif key in existing:
            status = "ALREADY_PRESENT_KEEP"
        elif key not in eu_en:
            status = "NO_SOURCE_KEY_REVIEW"
        elif format_tokens(eu_vi[key][0]) != format_tokens(eu_en[key][0]):
            status = "PLACEHOLDER_MISMATCH_REVIEW"
        else:
            status = "MISSING_KEY_CANDIDATE"
        rows.append({"resource_name": key, "status": status})
    return rows


def decode(apktool: Path, apk: Path, output: Path):
    result = subprocess.run(
        ["java", "-Xmx3g", "-jar", str(apktool), "d", "-f", "-s",
         str(apk), "-o", str(output)],
        capture_output=True, text=True, errors="replace",
    )
    if result.returncode:
        raise RuntimeError((result.stderr or result.stdout)[-600:])


def run(args):
    inventory = json.loads(args.report.read_text(encoding="utf-8"))
    stock_by_package = {p["target_package"]: p["stock_apk"]
                        for p in inventory["packages"] if p.get("stock_apk")}
    retired = set(args.retired.read_text(encoding="utf-8").splitlines())
    names = [p for p in sorted(args.overlays.glob("Nothings.*.apk"))]
    records, warnings = [], []
    with tempfile.TemporaryDirectory(prefix="hypermos-eu-vi-") as temp:
        tmp = Path(temp)
        for index, overlay_apk in enumerate(names, 1):
            name = overlay_apk.stem
            matching = next((x for x in inventory["overlay_resources"]
                             if x["file"] == overlay_apk.name), None)
            if not matching:
                warnings.append(name + ": missing inventory entry")
                continue
            target = matching["target_package"]
            relative = stock_by_package.get(target)
            if not relative:
                warnings.append(name + ": no matching Xiaomi.eu APK for " + target)
                continue
            eu_apk = args.eu_root / relative
            if not eu_apk.is_file():
                warnings.append(name + ": target APK missing in extracted Xiaomi.eu ROM")
                continue
            eu_out = tmp / "eu"
            overlay_out = tmp / "overlay"
            try:
                decode(args.apktool, eu_apk, eu_out)
                decode(args.apktool, overlay_apk, overlay_out)
                eu_vi = strings_at(eu_out, VI_FOLDERS)
                eu_en = strings_at(eu_out, EN_FOLDERS)
                # Treat all existing keys (including default locale) as owned.
                # No existing resource is ever replaced.
                existing = strings_at(overlay_out, (*VI_FOLDERS, *DEFAULT_FOLDERS))
                keys = check_keys(eu_vi, eu_en, existing,
                                  retired if name == "Nothings.Settings" else set())
                for row in keys:
                    records.append({
                        "overlay_apk": overlay_apk.name,
                        "target_package": target,
                        "resource_name": row["resource_name"],
                        "status": row["status"],
                    })
                print(f"[EU-VI] {index}/{len(names)} {name}: "
                      f"{sum(x['status'] == 'MISSING_KEY_CANDIDATE' for x in keys)} "
                      f"missing candidates / {len(keys)} EU vi keys", flush=True)
            except (RuntimeError, OSError, ValueError) as exc:
                warnings.append(name + ": " + str(exc)[-400:])
            finally:
                import shutil
                shutil.rmtree(eu_out, ignore_errors=True)
                shutil.rmtree(overlay_out, ignore_errors=True)

    args.output.mkdir(parents=True, exist_ok=True)
    csv_path = args.output / "eu-vi-resource-keys.csv"
    with csv_path.open("w", encoding="utf-8-sig", newline="") as out:
        writer = csv.DictWriter(out, fieldnames=(
            "overlay_apk", "target_package", "resource_name", "status"))
        writer.writeheader()
        writer.writerows(records)
    statuses = Counter(row["status"] for row in records)
    missing = Counter(row["overlay_apk"] for row in records
                      if row["status"] == "MISSING_KEY_CANDIDATE")
    summary = {
        "source": "xiaomi.eu HAOTIAN OS3.0.309.0.WOBCNXM Android 16",
        "target": "HyperMOS HAOTIAN OS3.0.308.0.WOBCNXM Android 16",
        "overlays_scanned": len(names),
        "overlays_with_eu_vi_keys": len({r["overlay_apk"] for r in records}),
        "status_counts": dict(statuses),
        "missing_candidates_by_overlay": dict(sorted(missing.items())),
        "warnings": warnings,
        "limitations": [
            "Read-only key inventory. No Xiaomi.eu translation values are exported.",
            "Candidate keys are NOT automatically overlayable on the older 3.0.308 base.",
            "EU APK decoding can require proprietary Xiaomi framework resources.",
            "No RRO was rebuilt or signed. Original 358 additions and 22 retired keys are untouched.",
        ],
    }
    (args.output / "eu-vi-summary.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    with (args.output / "EU_VI.md").open("w", encoding="utf-8") as out:
        out.write("# Xiaomi.eu Vietnamese resource key comparison\n\n")
        out.write("**Read-only. No Xiaomi.eu translated text copied or committed.**\n\n")
        out.write(f"Overlays scanned: {len(names)}; with EU vi keys: "
                  f"{summary['overlays_with_eu_vi_keys']}.\n\n")
        for key, count in sorted(statuses.items()):
            out.write(f"- {key}: {count}\n")
        out.write("\n## Missing key candidates per overlay\n\n")
        out.write("| Existing overlay | Candidate keys |\n| --- | ---: |\n")
        for name, count in missing.most_common():
            out.write(f"| {name} | {count} |\n")
        if warnings:
            out.write("\n## Warnings\n\n")
            for warning in warnings:
                out.write("- " + warning.replace("|", "/") + "\n")
        out.write("\nNo APK was changed; no signing or device idmap verification performed.\n")
    print("[EU-VI] " + json.dumps(summary, ensure_ascii=False), flush=True)
    if not records:
        raise RuntimeError("No Xiaomi.eu vi resource keys were decoded; refusing empty-success report")


def self_test():
    eu_vi = {
        "keep": ("Bản dịch đã có", "values-vi"),
        "new": ("Giá trị mới %1$s", "values-vi"),
        "bad": ("Không đúng %d", "values-vi"),
        "retired": ("Đã loại bỏ", "values-vi"),
        "unknown": ("Chưa rõ", "values-vi"),
    }
    eu_en = {
        "keep": ("Already there", "values-en"),
        "new": ("New value %1$s", "values-en"),
        "bad": ("Wrong %s", "values-en"),
        "retired": ("Removed", "values-en"),
    }
    existing = {"keep": ("Bản dịch cũ", "values-vi")}
    rows = check_keys(eu_vi, eu_en, existing, {"retired"})
    got = {x["resource_name"]: x["status"] for x in rows}
    assert got == {
        "bad": "PLACEHOLDER_MISMATCH_REVIEW",
        "keep": "ALREADY_PRESENT_KEEP",
        "new": "MISSING_KEY_CANDIDATE",
        "retired": "RETIRED_DO_NOT_READD",
        "unknown": "NO_SOURCE_KEY_REVIEW",
    }, got
    print("[PASS] EU resource key classification: preserve, retired, placeholders, missing")


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--self-test", action="store_true")
    p.add_argument("--report", type=Path)
    p.add_argument("--eu-root", type=Path)
    p.add_argument("--overlays", type=Path)
    p.add_argument("--retired", type=Path)
    p.add_argument("--apktool", type=Path)
    p.add_argument("--output", type=Path, default=Path("eu-vi-audit"))
    args = p.parse_args()
    if args.self_test:
        self_test()
        return
    for field in ("report", "eu_root", "overlays", "retired", "apktool"):
        if getattr(args, field) is None:
            p.error("--" + field.replace("_", "-") + " required")
    run(args)


if __name__ == "__main__":
    main()
