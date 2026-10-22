#!/usr/bin/env python3
"""Select the exact ZKOS HAOTIAN OS3.0.304.0 fastboot folder inside a large ZIP.

Copies only its super.img or super.img.N members into a small-layout ROM ZIP
(with potentially large binary data), without unpacking unrelated ROM folders.
"""
from __future__ import annotations

import argparse
import json
import re
import shutil
import zipfile
from pathlib import Path, PurePosixPath

TARGET_FOLDER = "ZKOS_HAOTIAN_OS3.0.304.0.WOBCNXM_EU260623"
SUPER_NAME = re.compile(r"super\.img(?:\.(0|[1-9][0-9]*))?", re.I)
GIB = 1024 ** 3


def select(outer: Path, dest: Path, manifest: Path, target: str = TARGET_FOLDER) -> dict:
    if not outer.is_file() or not zipfile.is_zipfile(outer):
        raise RuntimeError("Outer Google Drive archive is not a valid ZIP")
    if not re.fullmatch(r"ZKOS_HAOTIAN_OS3\.0\.304\.0\.WOBCNXM_EU260623", target, re.I):
        raise RuntimeError("Refusing to select any ROM folder other than ZKOS HAOTIAN 304")

    dest.parent.mkdir(parents=True, exist_ok=True)
    found = {}
    folder_samples = []
    try:
        with zipfile.ZipFile(outer) as source:
            for item in source.infolist():
                if item.filename.startswith("/") or "\\" in item.filename or ".." in PurePosixPath(item.filename).parts:
                    raise RuntimeError("Unsafe ZIP member name: " + item.filename)
                parts = PurePosixPath(item.filename.rstrip("/")).parts
                for part in parts:
                    if part.lower().startswith("zkos_haotian_os") and part not in folder_samples:
                        folder_samples.append(part)
                positions = [idx for idx, part in enumerate(parts) if part.lower() == target.lower()]
                if not positions or item.is_dir():
                    continue
                if len(positions) != 1:
                    raise RuntimeError("Ambiguous target folder nesting")
                rel = parts[positions[0] + 1:]
                if not rel:
                    continue
                base = rel[-1]
                if not SUPER_NAME.fullmatch(base):
                    continue
                if base in found:
                    raise RuntimeError("Duplicate super image member: " + base)
                if item.flag_bits & 1:
                    raise RuntimeError("Encrypted super image member: " + item.filename)
                if item.file_size < 1048576:
                    raise RuntimeError("Suspiciously small super image: " + item.filename)
                found[base] = item

            if not found:
                raise RuntimeError(
                    f"No super.img or super.img.N found in {target}/. "
                    f"ROM folders seen: {folder_samples}"
                )

            bare = [n for n in found if n.lower() == "super.img"]
            chunks = []
            for name in found:
                m = SUPER_NAME.fullmatch(name)
                if m and m.group(1) is not None:
                    chunks.append((int(m.group(1)), name))
            if bare and chunks:
                raise RuntimeError("Target contains both super.img and super.img.N chunks")
            if bare:
                if len(bare) != 1 or len(found) != 1:
                    raise RuntimeError("More than one super.img in target folder")
                order = bare
            else:
                chunks.sort()
                if [i for i, _ in chunks] != list(range(len(chunks))):
                    raise RuntimeError("Selected ROM has missing or duplicate super.img.N chunks")
                order = [name for _, name in chunks]

            required = sum(found[name].file_size for name in order)
            available = shutil.disk_usage(dest.parent).free
            if available < required + 2 * GIB:
                raise RuntimeError(f"Not enough disk for selected 304 super images: available={available}, require={required + 2 * GIB}")

            copied = []
            with zipfile.ZipFile(dest, "w", compression=zipfile.ZIP_STORED, allowZip64=True) as result:
                for name in order:
                    item = found[name]
                    # ZipFile.open reads and checks the source CRC while copying.
                    with source.open(item, "r") as reader, result.open(name, "w", force_zip64=True) as writer:
                        shutil.copyfileobj(reader, writer, 8 * 1024 * 1024)
                    copied.append({"source_member": item.filename, "output_member": name,
                                   "bytes": item.file_size, "crc32": f"{item.CRC:08x}"})
                    print(f"[304] {item.filename} -> {name} ({item.file_size} bytes)", flush=True)
        with zipfile.ZipFile(dest) as check:
            if check.namelist() != order:
                raise RuntimeError("Selected archive member verification failed")
            if any(check.getinfo(item["output_member"]).file_size != item["bytes"] for item in copied):
                raise RuntimeError("Selected image size mismatch")
        result = {
            "source_archive": outer.name,
            "selection_policy": "exact_folder",
            "selected_folder": target,
            "selected_version": "3.0.304.0",
            "candidate_rom_folders": folder_samples,
            "super_images": copied,
            "selected_archive": dest.name,
        }
        manifest.parent.mkdir(parents=True, exist_ok=True)
        manifest.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        print("[SELECTED] " + target, flush=True)
        return result
    except Exception:
        dest.unlink(missing_ok=True)
        raise


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("outer", type=Path)
    parser.add_argument("selected_rom_zip", type=Path)
    parser.add_argument("selection_manifest", type=Path)
    args = parser.parse_args()
    select(args.outer, args.selected_rom_zip, args.selection_manifest)


if __name__ == "__main__":
    main()
