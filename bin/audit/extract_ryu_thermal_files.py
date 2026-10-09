#!/usr/bin/env python3
"""Copy only thermal/power-hint configuration files from an extracted RYU partition.

Read-only with respect to the ROM. Files are kept byte-for-byte unchanged.
The script never patches or installs any thermal profile.
"""
import argparse
import hashlib
import json
import shutil
from pathlib import Path

ALLOWED_SUFFIXES = {
    ".conf", ".xml", ".json", ".json5", ".ini", ".rc", ".txt",
    ".cfg", ".prop", ".config", ".bin", ".pb", ".csv", ".sh",
}


def is_thermal_config(relative: Path) -> bool:
    parts = tuple(part.lower() for part in relative.parts)
    if "etc" not in parts or not relative.name:
        return False
    # Thermal files normally live in /vendor/etc, /odm/etc and /etc/init.
    # Do not pull executable binaries, firmware or unrelated APKs.
    etc_index = parts.index("etc")
    focus = parts[etc_index + 1:]
    if not focus:
        return False
    related = any(
        ("thermal" in part or "powerhint" in part
         or "power_hint" in part or "sconfig" in part)
        for part in focus
    )
    if not related:
        return False
    return relative.suffix.lower() in ALLOWED_SUFFIXES or relative.name.lower() in {
        "thermal", "sconfig", "powerhint"
    }


def scan(root: Path, partition: str, output: Path):
    if partition not in {"vendor", "odm", "system_ext", "mi_ext", "product"}:
        raise ValueError("Unsupported partition")
    if not root.is_dir():
        raise ValueError(f"Missing partition extraction: {root}")
    collected = []
    for file in sorted(root.rglob("*")):
        if file.is_symlink() or not file.is_file():
            continue
        rel = file.relative_to(root)
        if not is_thermal_config(rel):
            continue
        size = file.stat().st_size
        if size > 24 * 1024 * 1024:
            raise ValueError(f"Unexpectedly large thermal config: {rel}: {size}")
        destination = output / "files" / partition / rel
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(file, destination)
        digest = hashlib.sha256(destination.read_bytes()).hexdigest()
        collected.append({
            "partition": partition,
            "original_path": "/" + rel.as_posix(),
            "artifact_path": destination.relative_to(output).as_posix(),
            "size_bytes": size,
            "sha256": digest,
        })
    manifest_path = output / "manifest.json"
    previous = json.loads(manifest_path.read_text()) if manifest_path.is_file() else []
    previous = [entry for entry in previous if entry["partition"] != partition]
    manifest_path.write_text(
        json.dumps(previous + collected, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    print(f"[RYU-THERMAL] {partition}: collected {len(collected)} files", flush=True)
    for file in collected:
        print("  " + file["original_path"], flush=True)
    return len(collected)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, required=True)
    parser.add_argument("--partition", required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    scan(args.root, args.partition, args.output)


if __name__ == "__main__":
    main()
