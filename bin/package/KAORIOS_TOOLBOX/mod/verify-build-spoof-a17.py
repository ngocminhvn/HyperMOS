#!/usr/bin/env python3
"""Verify a decompiled Android 17 framework tree carries the Kaorios Build spoof.

The Kaorios Build spoof only exists on Android 17 (guide section 7): the string
fields of ``android/os/Build`` plus ``Build$VERSION`` must be writable at runtime
so the Toolbox can rewrite them, which means the ``final`` modifier has to be
gone. ``Build;->TIME:J`` only needs ``final`` removed.

This is a structural check on the re-disassembled final artifact. It mirrors the
post-patch assertions the upstream patcher performs on the smali it edits, so a
broken DEX rebuild cannot silently ship an unspoofable Build class.
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

BUILD_REL = "android/os/Build.smali"
BUILD_VERSION_REL = "android/os/Build$VERSION.smali"

BUILD_STRING_FIELDS = [
    "BRAND",
    "BRAND_FOR_ATTESTATION",
    "DEVICE",
    "DEVICE_FOR_ATTESTATION",
    "FINGERPRINT",
    "HARDWARE",
    "ID",
    "MANUFACTURER",
    "MANUFACTURER_FOR_ATTESTATION",
    "MODEL",
    "MODEL_FOR_ATTESTATION",
    "PRODUCT",
    "PRODUCT_FOR_ATTESTATION",
    "TAGS",
    "TYPE",
    "USER",
]
VERSION_FIELDS = [
    "RELEASE",
    "RELEASE_OR_CODENAME",
    "RELEASE_OR_PREVIEW_DISPLAY",
    "SECURITY_PATCH",
    "DEVICE_INITIAL_SDK_INT",
]
TIME_FIELD = "TIME"


class VerifyError(ValueError):
    pass


def find_unique(smali_root: Path, rel: str) -> Path:
    matches = sorted(smali_root.rglob(rel))
    if len(matches) != 1:
        raise VerifyError(f"expected exactly one {rel} below {smali_root}; found {len(matches)}")
    return matches[0]


def _field_line(content: str, field: str, descriptor: str) -> str | None:
    match = re.search(rf"\.field[^\r\n]*[ \t]{re.escape(field)}:{re.escape(descriptor)}", content)
    return match.group(0) if match else None


def verify_build(path: Path) -> None:
    content = path.read_bytes().decode("utf-8")
    for field in BUILD_STRING_FIELDS:
        line = _field_line(content, field, "Ljava/lang/String;")
        if line is None:
            if field.endswith("_FOR_ATTESTATION") and not re.search(rf"\.field[^\r\n]*[ \t]{re.escape(field)}:", content):
                continue  # absent on this ROM/framework revision
            raise VerifyError(f"{path.name}: field {field}:Ljava/lang/String; not found")
        if "final" in line:
            raise VerifyError(f"{path.name}: field {field} still declares 'final' - Build spoof did not apply")

    time_line = _field_line(content, TIME_FIELD, "J")
    if time_line is None:
        raise VerifyError(f"{path.name}: field {TIME_FIELD}:J not found")
    if "final" in time_line:
        raise VerifyError(f"{path.name}: field {TIME_FIELD}:J still declares 'final' - Build spoof did not apply")


def verify_version(path: Path) -> None:
    content = path.read_bytes().decode("utf-8")
    for field in VERSION_FIELDS:
        match = re.search(rf"\.field[^\r\n]*[ \t]{re.escape(field)}:[^\s]+", content)
        if match is None:
            raise VerifyError(f"{path.name}: field {field} not found")
        if "final" in match.group(0):
            raise VerifyError(f"{path.name}: field {field} still declares 'final' - Build spoof did not apply")


def verify_root(smali_root: Path) -> tuple[Path, Path]:
    build = find_unique(smali_root, BUILD_REL)
    version = find_unique(smali_root, BUILD_VERSION_REL)
    verify_build(build)
    verify_version(version)
    return build, version


def main() -> int:
    parser = argparse.ArgumentParser(description="Verify the Android 17 Kaorios Build spoof in a smali tree.")
    parser.add_argument("smali_root", type=Path)
    args = parser.parse_args()
    try:
        build, version = verify_root(args.smali_root)
    except (VerifyError, OSError, UnicodeError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1
    print(f"verified Build spoof: {build}, {version}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
