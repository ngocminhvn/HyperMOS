#!/usr/bin/env python3
"""Install already-built OS4 Vietnamese RRO APKs: no AAPT2/rebuild during ROM build."""
from __future__ import annotations

import hashlib
import json
import re
import shutil
import sys
import xml.etree.ElementTree as ET
import zipfile
from pathlib import Path

from rom_version import version_key


def install(root: Path, images: Path, full_version: str) -> None:
    key = version_key(full_version)
    folder = root / "updatesource" / key
    manifest_file = folder / "manifest.json"
    if not manifest_file.is_file():
        raise ValueError(
            f"No OS4 Vietnamese prebuilt overlays for {key}. "
            "Run 'Prebuild OS4 Vietnamese Overlays' action first."
        )
    manifest = json.loads(manifest_file.read_text(encoding="utf-8"))
    if manifest.get("schema") != 1 or manifest.get("rom_version") != key:
        raise ValueError(f"OS4 Vietnamese prebuilt manifest version mismatch for {key}")
    overlays = manifest.get("overlays")
    if not isinstance(overlays, list) or not overlays:
        raise ValueError(f"No prebuilt OS4 overlay APKs for {key}")

    checked: list[tuple[Path, str]] = []
    seen: set[str] = set()
    for entry in overlays:
        if not isinstance(entry, dict):
            raise ValueError("Invalid overlay manifest entry")
        filename, package, checksum = (
            entry.get("file"), entry.get("package"), entry.get("sha256")
        )
        if not isinstance(filename, str) or not re.fullmatch(
            r"HyperMOS\.OS4\.VI\.[a-z0-9]+\.r[1-9][0-9]*\.apk", filename
        ):
            raise ValueError(f"Unexpected overlay APK name: {filename!r}")
        if not isinstance(package, str) or not re.fullmatch(
            r"com\.hypermos\.vi\.os4\.[a-z0-9]+\.r[1-9][0-9]*", package
        ):
            raise ValueError(f"Invalid overlay package for {filename}")
        if not isinstance(checksum, str) or not re.fullmatch(r"[0-9a-f]{64}", checksum):
            raise ValueError(f"Invalid SHA256 for {filename}")
        if filename in seen:
            raise ValueError(f"Duplicate OS4 overlay: {filename}")
        seen.add(filename)
        apk = folder / filename
        if not apk.is_file() or apk.stat().st_size < 100:
            raise ValueError(f"Missing or empty OS4 prebuilt: {apk}")
        if hashlib.sha256(apk.read_bytes()).hexdigest() != checksum:
            raise ValueError(f"SHA256 mismatch for {apk}")
        with zipfile.ZipFile(apk) as archive:
            if archive.testzip() is not None or "AndroidManifest.xml" not in archive.namelist():
                raise ValueError(f"Broken overlay APK: {apk}")
        checked.append((apk, package))

    dest = images / "product" / "overlay"
    dest.mkdir(parents=True, exist_ok=True)
    generated = dest / "HyperMOS-OS4-VI"
    if generated.is_dir():
        shutil.rmtree(generated)
    generated.mkdir(parents=True)
    for apk, package in checked:
        shutil.copy2(apk, generated / apk.name)

    config = dest / "config" / "config.xml"
    if config.is_file():
        tree = ET.parse(config)
        xml_root = tree.getroot()
        if xml_root.tag != "config":
            raise ValueError(f"Unsupported overlay config: {config}")
        present = {node.get("package") for node in xml_root.findall(".//overlay")}
        for _, package in checked:
            if package not in present:
                ET.SubElement(xml_root, "overlay", {
                    "package": package, "enabled": "true", "mutable": "false"
                })
        tree.write(config, encoding="utf-8", xml_declaration=True)
    print(f"[MultiLang OS4] Installed {len(checked)} verified prebuilt APK overlays "
          f"for ROM {key} (shared across devices; no build-time recompilation).")


if __name__ == "__main__":
    if len(sys.argv) != 4:
        sys.exit("Usage: install_prebuilt.py <OS4 dir> <unpacked images> <base ROM version>")
    try:
        install(Path(sys.argv[1]), Path(sys.argv[2]), sys.argv[3])
    except (ValueError, OSError, KeyError, json.JSONDecodeError,
            zipfile.BadZipFile, ET.ParseError) as exc:
        print(f"[ERROR] MultiLang OS4: {exc}", file=sys.stderr)
        sys.exit(1)
