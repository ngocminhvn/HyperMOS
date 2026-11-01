#!/usr/bin/env python3
"""Extract only init_boot.img from a ROM ZIP; never patch the ROM.

Sources, in order:
  1. work/partitions/init_boot.img (payload.bin case: payload-extract
     already wrote every partition there, extract.sh with PARTS=""
     deliberately leaves it untouched)
  2. work/partitions/init_boot_a.img / init_boot_b.img (same, slot suffix)
  3. Direct ZIP entries: images/init_boot.img, init_boot.img,
     images/init_boot_a.img, init_boot_a.img (fastboot ROM case)

Output: output/init_boot.img plus map.tsv / map.json / pack-meta
(SHA256SUMS.txt, INDEX.tsv, manifest.json, HOW-TO-EXTRACT.txt),
in the same shape as bin/dump/base.py so the Package step works unchanged.
"""
import argparse
import csv
import hashlib
import json
import shutil
import zipfile
from datetime import datetime, timezone
from pathlib import Path

ZIP_CANDIDATES = (
    "images/init_boot.img",
    "init_boot.img",
    "images/init_boot_a.img",
    "init_boot_a.img",
    "images/init_boot_b.img",
    "init_boot_b.img",
)
PARTITION_CANDIDATES = ("init_boot.img", "init_boot_a.img", "init_boot_b.img")


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--partitions", type=Path, required=True)
    parser.add_argument("--zip", type=Path, required=True, dest="zip_path")
    parser.add_argument("--entries", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--source-url", default="")
    args = parser.parse_args()

    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    (output / "pack-meta").mkdir(exist_ok=True)
    dest = output / "init_boot.img"

    source_desc = ""
    partitions = args.partitions
    for name in PARTITION_CANDIDATES:
        candidate = partitions / name
        if candidate.is_file() and candidate.stat().st_size > 0:
            shutil.copy2(candidate, dest)
            source_desc = f"partitions/{name} (from payload.bin)"
            break

    if not dest.exists() and args.zip_path.is_file():
        with zipfile.ZipFile(args.zip_path) as archive:
            names = set(archive.namelist())
            for name in ZIP_CANDIDATES:
                if name in names:
                    with archive.open(name) as src, dest.open("wb") as out:
                        shutil.copyfileobj(src, out, length=1024 * 1024)
                    source_desc = f"zip:{name}"
                    break

    if not dest.exists() or dest.stat().st_size == 0:
        if dest.exists():
            dest.unlink()
        parts = sorted(p.name for p in partitions.iterdir()) if partitions.is_dir() else []
        entries = ""
        if args.entries.is_file():
            entries = args.entries.read_text(errors="replace")[:2000]
        raise SystemExit(
            "[ERROR] init_boot.img not found.\n"
            f"partitions dir: {parts}\n"
            f"zip entries (first 2000 chars):\n{entries}"
        )

    size = dest.stat().st_size
    digest = sha256(dest)
    row = {
        "target": "init_boot.img",
        "source": source_desc,
        "partition": "init_boot",
        "status": "FOUND",
        "match": "exact-name",
        "size": size,
        "sha256": digest,
    }
    fields = ("target", "source", "partition", "status", "match", "size", "sha256")
    for filename in (output / "map.tsv", output / "pack-meta" / "INDEX.tsv"):
        with filename.open("w", encoding="utf-8", newline="") as stream:
            writer = csv.DictWriter(stream, fieldnames=fields, delimiter="\t")
            writer.writeheader()
            writer.writerow(row)
    summary = {
        "mode": "init_boot",
        "created": datetime.now(timezone.utc).isoformat(),
        "source_url": args.source_url,
        "requested": 1,
        "found": 1,
        "missing": 0,
        "items": [row],
    }
    (output / "map.json").write_text(
        json.dumps(summary, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    meta = output / "pack-meta"
    (meta / "manifest.json").write_text(
        json.dumps({k: v for k, v in summary.items() if k != "items"}, indent=2) + "\n",
        encoding="utf-8",
    )
    (meta / "SHA256SUMS.txt").write_text(f"{digest}  init_boot.img\n", encoding="utf-8")
    (meta / "HOW-TO-EXTRACT.txt").write_text(
        "init_boot mode takes only init_boot.img from the source ROM, "
        "unmodified. Flash it only to the matching haotian OS3.0.309 device "
        "and keep your patched init_boot.img to restore root afterwards.\n",
        encoding="utf-8",
    )
    print(f"[DUMP] mode=init_boot source={source_desc} size={size} sha256={digest}")


if __name__ == "__main__":
    main()
