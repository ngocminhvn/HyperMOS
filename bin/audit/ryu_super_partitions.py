#!/usr/bin/env python3
"""Read Android dynamic-partition names without lpunpack's lossy JSON formatter.

The existing bin/lpunpack.py --info --format json can silently print an
empty string if one partition has zero extents. Read the validated LP
metadata directly instead; nothing is extracted or modified here.
"""
import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from lpunpack import LpUnpack, LP_SECTOR_SIZE  # noqa: E402


def partition_summary(metadata):
    entries = []
    for item in metadata.partitions:
        name = item.name
        if not name or not all(c.isalnum() or c == "_" for c in name):
            raise ValueError(f"Invalid LP partition name: {name!r}")
        if item.first_extent_index + item.num_extents > len(metadata.extents):
            raise ValueError(f"Partition {name} has invalid extent references")
        extents = metadata.extents[
            item.first_extent_index:item.first_extent_index + item.num_extents
        ]
        entries.append({
            "name": name,
            "size_bytes": sum(e.num_sectors for e in extents) * LP_SECTOR_SIZE,
            "extent_count": item.num_extents,
        })
    if len({e["name"] for e in entries}) != len(entries):
        raise ValueError("Duplicate LP partition names")
    names = {e["name"] for e in entries}
    if not names.intersection({"vendor", "vendor_a", "vendor_b"}):
        raise ValueError(f"Missing vendor LP partition; found: {sorted(names)}")
    return {"partitions": entries, "source": "lpunpack.LpUnpack._read_metadata"}


def extract_names(super_img: Path):
    unpacker = LpUnpack(SUPER_IMAGE=str(super_img))
    try:
        metadata = unpacker._read_metadata()
        return partition_summary(metadata)
    finally:
        unpacker._fd.close()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--super", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--names", type=Path, required=True)
    args = parser.parse_args()
    if not args.super.is_file():
        parser.error("super.img missing")
    data = extract_names(args.super)
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.names.parent.mkdir(parents=True, exist_ok=True)
    args.json.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    args.names.write_text(
        "\n".join(x["name"] for x in data["partitions"]) + "\n",
        encoding="utf-8",
    )
    print("[RYU-THERMAL] Partition metadata:", flush=True)
    for entry in data["partitions"]:
        print(f"  {entry['name']} ({entry['size_bytes']} bytes, "
              f"{entry['extent_count']} extents)", flush=True)


if __name__ == "__main__":
    main()
