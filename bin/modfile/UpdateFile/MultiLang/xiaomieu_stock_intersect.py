#!/usr/bin/env python3
"""Intersect Xiaomi.eu upstream-only resource keys with stock EN->VI missing keys.

Outputs RESOURCE NAMES ONLY (plus provenance), no upstream translation texts.
This is a conservative shortlist, NOT proof of overlayability or safe reuse.
"""
import argparse
import csv
import json
from collections import Counter
from pathlib import Path


def load(path):
    with path.open("r", encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def matched_keys(upstream, stock):
    missing = {
        (r["overlay_apk"], r["resource_name"])
        for r in stock if r.get("status") == "MISSING_VI"
    }
    return sorted(
        (r for r in upstream if
         r.get("resource_type") == "string" and
         (r["overlay_apk"], r["resource_name"]) in missing),
        key=lambda r: (
            {"high": 0, "normal": 1, "low": 2}.get(r["priority"], 3),
            r["overlay_apk"], r["resource_name"]
        )
    )


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--upstream-gaps", type=Path)
    p.add_argument("--stock-review", type=Path)
    p.add_argument("--output", type=Path, default=Path("xiaomieu-gap-audit"))
    p.add_argument("--self-test", action="store_true")
    a = p.parse_args()
    if a.self_test:
        src = [{"overlay_apk": "Nothings.Settings.apk", "resource_name": "battery_title",
                "resource_type": "string", "priority": "high"}]
        stock = [{"overlay_apk": "Nothings.Settings.apk", "resource_name": "battery_title",
                  "status": "MISSING_VI"}]
        assert len(matched_keys(src, stock)) == 1
        stock[0]["status"] = "SAME_AS_ENGLISH_REVIEW"
        assert not matched_keys(src, stock)
        print("[PASS] source vs stock missing-key intersection")
        return
    if not a.upstream_gaps or not a.stock_review:
        p.error("--upstream-gaps and --stock-review are required")
    src = load(a.upstream_gaps)
    stock = load(a.stock_review)
    hits = matched_keys(src, stock)
    a.output.mkdir(parents=True, exist_ok=True)
    names = ("overlay_apk", "upstream_app", "resource_type",
             "resource_name", "source_xml", "priority", "status")
    path = a.output / "xiaomieu-stock-matched-candidates.csv"
    with path.open("w", newline="", encoding="utf-8-sig") as stream:
        writer = csv.DictWriter(stream, fieldnames=names, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(hits)
    summary = {
        "xiaomieu_upstream_only_keys": len(src),
        "stock_english_missing_review_keys": sum(
            s.get("status") == "MISSING_VI" for s in stock
        ),
        "upstream_only_matching_stock_missing": len(hits),
        "by_overlay": dict(Counter(r["overlay_apk"] for r in hits)),
        "priority_counts": dict(Counter(r["priority"] for r in hits)),
        "notes": [
            "These key names appear in Xiaomi.eu Vietnamese XML and in English stock missing-VI candidates.",
            "A matching name does not prove the Xiaomi.eu translated value is correct for this ROM.",
            "Confirm target resource exists, exact formatting and overlayable policy before patching.",
            "No upstream translation text was copied and no APK was modified.",
        ],
    }
    (a.output / "XIAOMIEU_STOCK_MATCH.md").write_text(
        "# Existing overlays: Xiaomi.eu keys also missing in stock English audit\n\n"
        f"- Upstream-only keys: **{len(src)}**\n"
        f"- Stock EN->VI missing keys: **{summary['stock_english_missing_review_keys']}**\n"
        f"- Matched candidates: **{len(hits)}**\n\n"
        "Candidates by current overlay:\n\n"
        + "".join(f"- {name}: {n}\n" for name,n in sorted(summary["by_overlay"].items()))
        + "\nNo third-party translated text is included. Review before import.\n",
        encoding="utf-8"
    )
    (a.output / "xiaomieu-stock-match-summary.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print("[XIAOMIEU-STOCK] " + json.dumps(summary, ensure_ascii=False))
    if not src or not stock:
        raise SystemExit("Empty input audit; check stock workflow artifact")


if __name__ == "__main__":
    main()
