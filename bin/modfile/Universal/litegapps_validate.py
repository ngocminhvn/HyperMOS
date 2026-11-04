#!/usr/bin/env python3
"""Offline LiteGapps payload integrity checks shared by Android 16 and 17.

No network calls or APK modifications. A17 reuses only the existing A16 Maps framework JAR.
Run after Git LFS checkout (actions/checkout with lfs: true).
"""
from __future__ import annotations

import argparse
import hashlib
import json
import sys
import xml.etree.ElementTree as ET
import zipfile
from pathlib import Path

UNIVERSAL = Path(__file__).resolve().parent

REQUIRED = {
    16: (
        "product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk",
        "product/priv-app/GmsCore/GmsCore.apk",
        "product/priv-app/Phonesky/Phonesky.apk",
        "product/priv-app/GoogleVelvet_CTS/GoogleVelvet_CTS.apk",
        "system_ext/priv-app/GoogleServicesFramework/GoogleServicesFramework.apk",
        "maps/com.google.android.maps.jar",
    ),
    17: (
        "product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk",
        "product/app/PrebuiltGmail/PrebuiltGmail.apk",
        "product/priv-app/GmsCore/GmsCore.apk",
        "product/priv-app/Phonesky/Phonesky.apk",
        "product/priv-app/Velvet/Velvet.apk",
        "product/priv-app/GoogleDialer/GoogleDialer.apk",
        "system_ext/priv-app/GoogleServicesFramework/GoogleServicesFramework.apk",
    ),
}
PARTITIONS = ("product", "system_ext")


def fail(message: str) -> None:
    raise ValueError(message)


def sha256(path: Path) -> str:
    hasher = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(8 * 1024 * 1024), b""):
            hasher.update(block)
    return hasher.hexdigest()


def checked_file(base: Path, relative: str) -> Path:
    path = Path(relative)
    if (path.is_absolute() or not path.parts or ".." in path.parts or
            "." in path.parts or path.parts[0] not in PARTITIONS):
        fail("Unsafe LiteGapps inventory path: " + relative)
    result = base / path
    if any(part.is_symlink() for part in [result, *result.parents] if part != base.parent):
        fail("Symlink in GApps payload: " + relative)
    if not result.is_file():
        fail("Required GApps file missing: " + relative)
    if result.stat().st_size < 1:
        fail("Empty GApps payload: " + relative)
    return result


def verify_payload(android: int) -> list[Path]:
    if android not in REQUIRED:
        fail("Only Android 16/17 GApps bundles are supported")
    base = UNIVERSAL / f"LiteGapps{android}"
    if not base.is_dir():
        fail(f"LiteGapps{android} directory missing")
    for required in REQUIRED[android]:
        path = base / required
        if not path.is_file() or path.is_symlink() or path.stat().st_size == 0:
            fail(f"LiteGapps{android} missing: {required}")

    payload = sorted(
        file for part in PARTITIONS
        for file in (base / part).rglob("*") if file.is_file()
    )
    if not payload:
        fail(f"LiteGapps{android} has no partition payload")
    for path in payload:
        relative = path.relative_to(base).as_posix()
        checked_file(base, relative)
        if path.suffix.lower() in (".apk", ".jar"):
            with path.open("rb") as f:
                if f.read(80).startswith(b"version https://git-lfs.github.com/spec"):
                    fail("Unhydrated Git LFS pointer: " + relative)
        if path.suffix.lower() == ".apk":
            if path.stat().st_size < 1024 or not zipfile.is_zipfile(path):
                fail("Corrupt/invalid GApps APK: " + relative)
        elif path.suffix.lower() == ".xml":
            try:
                ET.parse(path)
            except ET.ParseError as exc:
                fail(f"Invalid GApps XML {relative}: {exc}")

    if android == 17:
        inventory_path = base / "inventory.json"
        sources_path = base / "sources.json"
        if not inventory_path.is_file() or not sources_path.is_file():
            fail("A17 source/inventory metadata is missing")
        inventory = json.loads(inventory_path.read_text(encoding="utf-8"))
        source = json.loads(sources_path.read_text(encoding="utf-8"))
        if (source.get("android"), source.get("api"), source.get("arch")) != (17, 37, "arm64"):
            fail("A17 source target is not Android 17/API 37/arm64")
        if (inventory.get("android"), inventory.get("api"),
                inventory.get("source_date")) != (17, 37, source.get("source_date")):
            fail("A17 inventory target/source date mismatches source list")
        if (base / "product/app/Maps/Maps.apk").exists():
            fail("A17 Maps APK must be removed; use the shared maps framework JAR")
        maps = UNIVERSAL / "LiteGapps16/maps/com.google.android.maps.jar"
        if (not maps.is_file() or maps.is_symlink() or maps.stat().st_size < 1024
                or not zipfile.is_zipfile(maps)):
            fail("Shared A16 Maps framework JAR is missing or invalid")
        data = maps.read_bytes()
        actual_git_blob = hashlib.sha1(
            f"blob {len(data)}\0".encode("ascii") + data
        ).hexdigest()
        if actual_git_blob != "0f2ebaf76e1af43703dde3154b724693fd25531e":
            fail("Shared Maps JAR differs from the original pinned A16 file")
        policy = inventory.get("maps_install_policy")
        if not isinstance(policy, dict) or (
                policy.get("remove") != "product/app/Maps/Maps.apk"
                or policy.get("reuse") != "LiteGapps16/maps/com.google.android.maps.jar"
                or policy.get("destination") != "product/framework/com.google.android.maps.jar"):
            fail("A17 Maps install policy is missing or unexpected")
        if inventory.get("sources_sha256") != sha256(sources_path):
            fail("A17 sources.json changed; inventory needs re-verification")
        expected = inventory.get("files")
        if not isinstance(expected, dict) or not expected:
            fail("A17 inventory has no file hashes")
        actual = {f.relative_to(base).as_posix() for f in payload}
        if actual != set(expected):
            fail("A17 inventory differs from checked-in payload: missing/extra files")
        for relative, expected_hash in expected.items():
            if not isinstance(expected_hash, str) or len(expected_hash) != 64:
                fail("Invalid A17 inventory digest: " + relative)
            if sha256(checked_file(base, relative)) != expected_hash:
                fail("A17 SHA-256 mismatch: " + relative)
    print(f"[OK] LiteGapps{android}: {len(payload)} files; "
          "APK/XML integrity and version-specific required files verified",
          flush=True)
    return payload


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("android", type=int, choices=(16, 17))
    args = parser.parse_args()
    verify_payload(args.android)


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, json.JSONDecodeError) as exc:
        print("[ERROR] LiteGapps validation: " + str(exc), file=sys.stderr)
        sys.exit(1)
