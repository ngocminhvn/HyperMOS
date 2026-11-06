#!/usr/bin/env python3
"""Stage only Xiaomi.eu HyperOS 4 Qualcomm Vietnamese translation XML.

Does not patch APKs, alter ROM images, or touch existing OS3 overlays.
"""
from __future__ import annotations

import argparse
import os
import re
from pathlib import Path
import shutil
import tempfile
import xml.etree.ElementTree as ET


def sync(source: Path, revision: str) -> tuple[int, int]:
    source = source.resolve(strict=True)
    base = Path(__file__).resolve().parent
    output = base / "OS4" / "Vietnamese"
    dest = output / "main"
    if not source.is_dir():
        raise ValueError(f"Not a source directory: {source}")
    if dest.is_symlink():
        raise ValueError("Destination must not be a symlink")
    expected = (
        "Settings.apk/res/values-vi/strings.xml",
        "MiuiSystemUI.apk/res/values-vi/strings.xml",
        "framework-res.apk/res/values-vi/strings.xml",
    )
    for name in expected:
        if not (source / name).is_file():
            raise ValueError(f"Expected Vietnamese source missing: {name}")

    source_files = sorted(p for p in source.rglob("*") if p.is_file() or p.is_symlink())
    if not 100 <= len(source_files) <= 10000:
        raise ValueError(f"Unexpected number of source files: {len(source_files)}")

    output.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="os4-vi-", dir=output) as tmp:
        staging = Path(tmp) / "main"
        apk_names = set()
        for path in source_files:
            if path.is_symlink():
                raise ValueError(f"Upstream symlink rejected: {path}")
            rel = path.relative_to(source)
            if (
                len(rel.parts) < 4
                or not rel.parts[0].endswith(".apk")
                or rel.parts[1] != "res"
                or not re.search(r"(?:^|-)vi(?:-|$)", rel.parts[2])
                or path.suffix.lower() != ".xml"
            ):
                raise ValueError(f"Unexpected upstream file layout: {rel}")
            if path.stat().st_size > 20 * 1024 * 1024:
                raise ValueError(f"Source XML too large: {rel}")
            root = ET.parse(path).getroot()
            if root.tag != "resources":
                raise ValueError(f"Unexpected XML root: {rel}: {root.tag}")
            target = staging / rel
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(path, target)
            apk_names.add(rel.parts[0])

        if len(apk_names) < 40:
            raise ValueError(f"Suspiciously few upstream APK directories: {len(apk_names)}")
        if dest.exists():
            shutil.rmtree(dest)
        os.replace(staging, dest)

    (output / "UPSTREAM_COMMIT.txt").write_text(revision + "\n", encoding="utf-8")
    print(f"Synced {len(source_files)} Vietnamese XML files across {len(apk_names)} APKs; upstream {revision}")
    return len(source_files), len(apk_names)


if __name__ == "__main__":
    cli = argparse.ArgumentParser()
    cli.add_argument("--source", type=Path, required=True)
    cli.add_argument("--revision", required=True)
    args = cli.parse_args()
    sync(args.source, args.revision)
