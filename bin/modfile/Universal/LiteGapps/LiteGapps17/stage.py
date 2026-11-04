#!/usr/bin/env python3
"""Install only the committed, integrity-verified Android 17 GApps payload.

ROM builds must never download or substitute GApps from another Android
version. A17's archived SourceForge URLs and SHA-256 remain in sources.json;
inventory.json pins the exact unpacked files already stored via Git LFS.
"""
from __future__ import annotations

import argparse
import json
import shutil
import sys
from pathlib import Path

BASE = Path(__file__).resolve().parent
sys.path.insert(0, str(BASE.parent))

from validate import verify_payload  # noqa: E402


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, required=False, default=Path.cwd())
    parser.add_argument("--verify-repo", action="store_true",
                        help="Validate the checked-in A17 data without modifying a ROM")
    args = parser.parse_args()

    files = verify_payload(17)
    if args.verify_repo:
        return

    root = args.root.resolve()
    images = root / "build/baserom/images"
    if not (images / "product").is_dir() or not (images / "system_ext").is_dir():
        raise RuntimeError("Extracted ROM product/system_ext partitions are missing")
    build_prop = images / "system/system/build.prop"
    if not build_prop.is_file():
        raise RuntimeError("System build.prop is missing")

    # Copy verified A17 product/system_ext files only (no Maps APK).
    # The one explicit shared binary exception is the A16 Maps framework JAR.
    for source in files:
        layer = BASE.parent / "Gapps" if source.is_relative_to(BASE.parent / "Gapps") else BASE
        relative = source.relative_to(layer)
        destination = images / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, destination)

    # Do not let PrebuiltGmail from the base ROM survive either Android variant.
    gmail_target = images / "product/app/PrebuiltGmail"
    if gmail_target.is_symlink():
        raise RuntimeError("Refusing to delete symlinked PrebuiltGmail directory")
    if gmail_target.is_dir():
        shutil.rmtree(gmail_target)
    elif gmail_target.exists():
        raise RuntimeError("Unexpected non-directory PrebuiltGmail in ROM image")

    # User-selected legacy Maps shared library in place of the Google Maps app.
    # verify_payload(17) already confirms that this JAR is the pinned A16 blob.
    maps_jar = BASE.parent / "Gapps/maps/com.google.android.maps.jar"
    maps_destination = images / "product/framework/com.google.android.maps.jar"
    maps_destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(maps_jar, maps_destination)

    with build_prop.open("r", encoding="utf-8") as stream:
        has_gms = "ro.miui.has_gmscore=1" in stream.read().splitlines()
    if not has_gms:
        with build_prop.open("a", encoding="utf-8") as stream:
            stream.write("\nro.miui.has_gmscore=1\n")

    report = root / "build/reports/litegapps17/staged.json"
    report.parent.mkdir(parents=True, exist_ok=True)
    report.write_text(json.dumps({
        "android": 17,
        "api": 37,
        "source": "verified-committed-lfs",
        "file_count": len(files) + 1,
        "maps_app_installed": False,
        "gmail_app_installed": False,
        "google_velvet_cts_required": True,
        "velvet_required": True,
        "maps_framework_source": "Gapps/maps/com.google.android.maps.jar",
        "files": [
            p.relative_to(BASE.parent / "Gapps" if p.is_relative_to(BASE.parent / "Gapps") else BASE).as_posix()
            for p in files
        ]
                 + ["product/framework/com.google.android.maps.jar"],
    }, indent=2) + "\n", encoding="utf-8")
    print(f"[OK] LiteGapps17: {len(files)} verified files + Maps framework JAR; no Maps/Gmail APK", flush=True)


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, ValueError, json.JSONDecodeError) as exc:
        print("[ERROR] LiteGapps17: " + str(exc), file=sys.stderr)
        sys.exit(1)
