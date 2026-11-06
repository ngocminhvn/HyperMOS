#!/usr/bin/env python3
"""Compile once into OS4/updatesource/<ROM VERSION>/, for every China device.

The ROM version drops the device/branch suffix (e.g. XOBCNXM), never the
numeric OS4 release number. Normal ROM builds only copy these signed APKs.
"""
from __future__ import annotations

import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path

from rom_version import version_key


def main() -> None:
    if len(sys.argv) != 3:
        sys.exit("Usage: package_prebuilt.py <unpacked-images> <base-rom-code.txt>")
    images = Path(sys.argv[1]).resolve()
    raw_version = Path(sys.argv[2]).read_text(encoding="utf-8")
    key = version_key(raw_version)
    module = Path(__file__).resolve().parent
    source = module / "Vietnamese" / "main"
    output = images / "product" / "overlay"
    subprocess.run([
        sys.executable, str(module / "build_vi_rro.py"), str(source),
        str(images), str(output)
    ], check=True)
    report_file = images.parent / "os4-vietnamese-report.json"
    report = json.loads(report_file.read_text(encoding="utf-8"))
    built = report.get("built", [])
    generated = output / "HyperMOS-OS4-VI"
    if not built or not generated.is_dir():
        raise RuntimeError("No OS4 Vietnamese prebuilt APKs were generated")

    # This directory is the sole source of truth; do not mix APKs from
    # different ROM versions or devices into the same package set.
    target = module / "updatesource" / key
    if target.is_dir():
        shutil.rmtree(target)
    target.mkdir(parents=True)
    entries: list[dict[str, str]] = []
    for item in built:
        apk_name = f"HyperMOS.OS4.VI.{item['apk'][:-4].lower().replace('_', '')}.r1.apk"
        # Actual names can have multiple overlayable groups; locate by package.
        package = str(item["overlay"])
        suffix = package.removeprefix("com.hypermos.vi.os4.")
        apk_name = f"HyperMOS.OS4.VI.{suffix}.apk"
        apk = generated / apk_name
        if not apk.is_file():
            raise RuntimeError(f"Generated overlay missing: {apk}")
        shutil.copy2(apk, target / apk.name)
        entries.append({
            "file": apk.name,
            "package": package,
            "sha256": hashlib.sha256(apk.read_bytes()).hexdigest(),
        })
    if len(set(item["file"] for item in entries)) != len(entries):
        raise RuntimeError("Duplicate overlay APK names in prebuild")
    manifest = {"schema": 1, "rom_version": key, "overlays": entries}
    (target / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    # Verify immediately using the exact same installer as a normal ROM build.
    from install_prebuilt import install
    install(module, images, raw_version)
    print(f"[MultiLang OS4] PREBUILT READY: {len(entries)} shared APKs "
          f"for ROM version {key}; no device-specific subdirectories.")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, RuntimeError, KeyError,
            json.JSONDecodeError, subprocess.CalledProcessError) as exc:
        print(f"[ERROR] OS4 Vietnamese prebuild: {exc}", file=sys.stderr)
        sys.exit(1)
