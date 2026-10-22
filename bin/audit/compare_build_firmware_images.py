#!/usr/bin/env python3
"""Diff exact flashing firmware IMG files outside super, from built ROM ZIPs.

Step 'base' creates hashes of images/*.img from #170. Step 'target' checks the
#176 ZIP against those hashes and extracts ONLY changed target images.
No firmware is flashed; Root/init_boot.stock.img is intentionally not a target.
"""
import argparse
import hashlib
import json
import re
import shutil
import sys
import zipfile
from pathlib import Path

FLASH_IMG = re.compile(r"^images/([a-zA-Z0-9_-]+\.img)$")


def firmware_entries(z):
    files = {}
    for item in z.infolist():
        match = FLASH_IMG.fullmatch(item.filename)
        if not match or item.is_dir():
            continue
        name = match.group(1)
        if item.flag_bits & 1:
            raise RuntimeError("Encrypted firmware image: " + name)
        if name in files:
            raise RuntimeError("Duplicate IMG in archive: " + name)
        files[name] = item
    if len(files) < 15:
        raise RuntimeError("Unexpectedly few firmware images (expected Xiaomi.eu fastboot ROM)")
    return files


def digest_stream(reader):
    h = hashlib.sha256()
    size = 0
    for block in iter(lambda: reader.read(8 * 1024 * 1024), b""):
        h.update(block)
        size += len(block)
    return h.hexdigest(), size


def digest_file(path):
    with path.open("rb") as reader:
        return digest_stream(reader)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("mode", choices=["base", "target"])
    parser.add_argument("--zip", required=True, type=Path)
    parser.add_argument("--manifest", required=True, type=Path)
    parser.add_argument("--output", type=Path)
    opts = parser.parse_args()
    with zipfile.ZipFile(opts.zip) as z:
        files = firmware_entries(z)
        if opts.mode == "base":
            rows = {}
            for name, info in sorted(files.items()):
                print("[BASE FIRMWARE]", name, flush=True)
                with z.open(info) as reader:
                    digest, size = digest_stream(reader)
                if size != info.file_size:
                    raise RuntimeError("Truncated #170 IMG: " + name)
                rows[name] = {"sha256": digest, "size": size}
            opts.manifest.write_text(json.dumps(rows, indent=2) + "\n")
            print("[BASE] Recorded {} IMG files".format(len(rows)), flush=True)
            return
        old = json.loads(opts.manifest.read_text())
        if not opts.output:
            raise RuntimeError("--output is required for target mode")
        dst = opts.output / "firmware"
        dst.mkdir(parents=True, exist_ok=True)
        rows = []
        for name, info in sorted(files.items()):
            with z.open(info) as reader:
                digest, size = digest_stream(reader)
            if size != info.file_size:
                raise RuntimeError("Truncated #176 IMG: " + name)
            prev = old.get(name)
            changed = prev is None or prev["sha256"] != digest
            reason = "added" if prev is None else "changed" if changed else "identical"
            row = {"name": name, "status": reason, "sha256": digest,
                   "size": size, "exported": changed}
            if changed:
                path = dst / name
                with z.open(info) as source, path.open("wb") as target:
                    shutil.copyfileobj(source, target, 8 * 1024 * 1024)
                check, check_size = digest_file(path)
                if check != digest or check_size != size:
                    raise RuntimeError("Export integrity check failed: " + name)
                print("[EXPORT FIRMWARE]", name, flush=True)
            rows.append(row)
        missing = sorted(set(old) - set(files))
        if missing:
            print("[WARN] Firmware omitted in #176:", missing, flush=True)
        result = {
            "note": "Bootloader firmware images only, NOT fastbootd logical partitions. "
                    "Some devices flash both slots for selected firmware images. "
                    "Do not flash blindly; verify A/B, AVB, rollback and compatibility.",
            "comparisons": rows,
            "removed_from_target": missing,
            "exported": [r["name"] for r in rows if r["exported"]]
        }
        (opts.output / "firmware-differences.json").write_text(json.dumps(result, indent=2) + "\n")
        print("[SUCCESS] Firmware image changes: " + ", ".join(result["exported"]), flush=True)


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, ValueError, OSError, zipfile.BadZipFile) as exc:
        sys.exit("[ERROR] Firmware IMG comparison failed: " + str(exc))
