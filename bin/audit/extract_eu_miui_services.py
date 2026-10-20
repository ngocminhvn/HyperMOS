#!/usr/bin/env python3
"""Extract the original Xiaomi.eu miui-services.jar from a fastboot super image.

Read-only operation: reuse HyperMOS's sparse super and liblp parsers.  The
selected JAR is copied byte-for-byte, never patched or re-signed.
"""
from __future__ import annotations

import hashlib
import json
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path

from audit_xiaomi_eu_apps import call, filesystem, make_super, read_partition_names

JAR_NAME = "miui-services.jar"
JAR_CANDIDATES = (
    "framework/miui-services.jar",
    "system_ext/framework/miui-services.jar",
)


def valid_dex_jar(path: Path) -> bool:
    if not path.is_file() or path.is_symlink() or path.stat().st_size < 1024:
        return False
    if not zipfile.is_zipfile(path):
        return False
    with zipfile.ZipFile(path) as jar:
        names = jar.namelist()
        return (
            any(n == "classes.dex" or
                (n.startswith("classes") and n.endswith(".dex") and
                 n[7:-4].isdigit()) for n in names)
            and jar.testzip() is None
        )


def extract_erofs(image: Path, scratch: Path):
    root = scratch / "erofs"
    root.mkdir(parents=True, exist_ok=True)
    call("fsck.erofs", "--extract=" + str(root), image)
    matches = [
        ("/" + relative, root / relative)
        for relative in JAR_CANDIDATES
        if (root / relative).is_file() and not (root / relative).is_symlink()
    ]
    return matches


def extract_ext4(image: Path, scratch: Path):
    matches = []
    for relative in JAR_CANDIDATES:
        source = "/" + relative
        stat = subprocess.run(
            ["debugfs", "-R", "stat " + source, str(image)],
            capture_output=True, text=True, check=False,
        )
        if "Inode:" not in stat.stdout or "Type: regular" not in stat.stdout:
            continue
        dest = scratch / "ext4" / relative
        dest.parent.mkdir(parents=True, exist_ok=True)
        call("debugfs", "-R", "dump -p " + source + " " + str(dest), image)
        if not dest.is_file():
            raise RuntimeError("debugfs failed to extract " + source)
        matches.append((source, dest))
    return matches


def run(rom: Path, work: Path, lpunpack: Path) -> None:
    output = work / "output"
    output.mkdir(parents=True, exist_ok=True)
    original_archive_name = rom.name

    # make_super checks numbered sparse chunks before merging them and
    # removes the downloaded ZIP to save GitHub runner disk space.
    super_image = make_super(rom, work)
    try:
        available = read_partition_names(super_image, lpunpack)
        selected = next(
            (name for name in ("system_ext_a", "system_ext", "system_ext_b")
             if name in available), None
        )
        if selected is None:
            raise RuntimeError("No system_ext partition in ROM super.img")

        extracted = work / "partition"
        extracted.mkdir(exist_ok=True)
        call(sys.executable, lpunpack, "-p", selected, super_image, extracted)
        image = extracted / (selected + ".img")
        if not image.is_file() or image.stat().st_size == 0:
            raise RuntimeError("Missing extracted " + selected + ".img")

        scratch = work / "scratch"
        kind = filesystem(image)
        matches = (
            extract_erofs(image, scratch) if kind == "erofs"
            else extract_ext4(image, scratch)
        )
        if len(matches) != 1:
            raise RuntimeError(
                "Expected exactly one miui-services.jar in " + selected +
                ", found " + str(len(matches)) + ": " +
                ", ".join(rel for rel, _ in matches)
            )

        source_path, source = matches[0]
        if not valid_dex_jar(source):
            raise RuntimeError("Not a valid DEX JAR: " + source_path)

        final = output / JAR_NAME
        shutil.copyfile(source, final)
        if not valid_dex_jar(final):
            raise RuntimeError("Output JAR failed ZIP/DEX integrity check")
        with final.open("rb") as stream:
            sha256 = hashlib.file_digest(stream, "sha256").hexdigest()
        manifest = {
            "source_archive": original_archive_name,
            "source_partition": selected,
            "source_path": source_path,
            "filesystem": kind,
            "file": final.name,
            "bytes": final.stat().st_size,
            "sha256": sha256,
            "changed_or_resigned": False,
        }
        (output / "miui-services-manifest.json").write_text(
            json.dumps(manifest, indent=2, ensure_ascii=False) + "\n",
            encoding="utf-8",
        )
        (output / "SHA256SUMS.txt").write_text(
            sha256 + "  " + JAR_NAME + "\n", encoding="utf-8"
        )
        (output / "report.md").write_text(
            "# Xiaomi.eu original miui-services.jar\n\n"
            f"- ROM source ZIP: \`{original_archive_name}\`\n"
            f"- Partition: \`{selected}\` (\`{kind}\`)\n"
            f"- Original path: \`{source_path}\`\n"
            f"- Size: {final.stat().st_size:,} bytes\n"
            f"- SHA-256: \`{sha256}\`\n"
            "- File copied byte-for-byte; no patching or re-signing.\n",
            encoding="utf-8",
        )
        print("[OK] Xiaomi.eu miui-services.jar extracted:", source_path, flush=True)
        print("[SHA256]", sha256, flush=True)
    finally:
        super_image.unlink(missing_ok=True)


if __name__ == "__main__":
    if len(sys.argv) != 4:
        raise SystemExit(
            "Usage: extract_eu_miui_services.py ROM.zip WORKDIR bin/lpunpack.py"
        )
    try:
        run(Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve(),
            Path(sys.argv[3]).resolve())
    except (OSError, ValueError, RuntimeError, zipfile.BadZipFile,
            subprocess.CalledProcessError) as error:
        raise SystemExit("[EU MIUI-SERVICES EXTRACT ERROR] " + str(error))
