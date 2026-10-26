#!/usr/bin/env python3
"""Unpack historical ZK backup into build/references, NEVER install it to ROM.

Usage: python3 unpack_backupzk.py --archive backupzk.zip --output build/references/zk_eu
Inputs stay read-only; safe ZIP member paths are enforced and no scripts run.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import shutil
import stat
import tempfile
import zipfile

MAX_TOTAL = 250 * 1024 * 1024
MAX_FILES = 20000

def safe_parts(name):
    if not name or "\\" in name or name.startswith("/"):
        raise ValueError("unsafe ZIP path: " + repr(name))
    p = PurePosixPath(name)
    if p.is_absolute() or ".." in p.parts or any(":" in v for v in p.parts):
        raise ValueError("traversal/drive ZIP path: " + repr(name))
    return p

def unpack(archive, dest):
    if not archive.is_file():
        raise ValueError("missing historical backupzk.zip: " + str(archive))
    if archive.stat().st_size < 1:
        raise ValueError("empty backup archive")
    with zipfile.ZipFile(archive) as z:
        records = z.infolist()
        if len(records) > MAX_FILES:
            raise ValueError("archive contains too many members")
        if sum(i.file_size for i in records) > MAX_TOTAL:
            raise ValueError("archive exceeds extraction size limit")
        names = set()
        for info in records:
            path = safe_parts(info.filename)
            if info.filename in names:
                raise ValueError("duplicate ZIP member: " + info.filename)
            names.add(info.filename)
            if info.flag_bits & 0x1:
                raise ValueError("encrypted ZIP member: " + info.filename)
            mode = info.external_attr >> 16
            if stat.S_ISLNK(mode):
                raise ValueError("ZIP symlink refused: " + info.filename)
        if z.testzip() is not None:
            raise ValueError("ZIP CRC verification failed")
        dest.parent.mkdir(parents=True, exist_ok=True)
        temp = Path(tempfile.mkdtemp(prefix="zk-backup-", dir=dest.parent))
        try:
            for info in records:
                path = temp.joinpath(*safe_parts(info.filename).parts)
                if info.is_dir():
                    path.mkdir(parents=True, exist_ok=True)
                else:
                    path.parent.mkdir(parents=True, exist_ok=True)
                    with z.open(info) as src, path.open("wb") as dst:
                        shutil.copyfileobj(src, dst)
            manifest = {
                "source": "EU/backupzk.zip",
                "archive_sha256": hashlib.sha256(archive.read_bytes()).hexdigest(),
                "member_count": len(records),
                "files": [{"path": x.filename, "size": x.file_size}
                          for x in records if not x.is_dir()],
                "installed_into_rom": False,
                "purpose": "historical ZK reference for later audit only",
            }
            (temp / "_unpack_manifest.json").write_text(
                json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
            if dest.exists():
                shutil.rmtree(dest)
            temp.rename(dest)
        finally:
            if temp.exists():
                shutil.rmtree(temp)
    print(f"[EU ZK REFERENCE] extracted {len(records)} ZIP members into {dest}")
    print("[EU ZK REFERENCE] original stock EU JAR/PowerKeeper untouched; no ZK code installed")
    print(f"[EU ZK REFERENCE] inventory: {dest / '_unpack_manifest.json'}")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--archive", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    unpack(args.archive.resolve(), args.output.resolve())

if __name__ == "__main__":
    try: main()
    except (OSError, ValueError, zipfile.BadZipFile) as exc:
        raise SystemExit("[EU ZK REFERENCE] FAIL: " + str(exc))
