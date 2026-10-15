#!/usr/bin/env python3
"""Read-only minimal dump: exact filenames, one preferred match per name."""
import argparse
import csv
import hashlib
import json
import os
import shutil
from datetime import datetime, timezone
from pathlib import Path

NAMES = (
    "framework.jar",
    "miui-framework.jar",
    "miui-services.jar",
    "powerkeeper.apk",
    "services.jar",
)
PREFERRED = {
    "framework.jar": ("system/system/framework", "system/framework"),
    "services.jar": ("system/system/framework", "system/framework"),
    "miui-framework.jar": ("system_ext/framework", "system/framework", "system/system/framework"),
    "miui-services.jar": ("system_ext/framework", "system/framework", "system/system/framework"),
    "powerkeeper.apk": (
        "system_ext/app/PowerKeeper", "system_ext/priv-app/PowerKeeper",
        "product/app/PowerKeeper", "product/priv-app/PowerKeeper",
    ),
}
FIELDS = ("target", "source", "partition", "status", "match", "size", "sha256")


def sha256(file):
    digest = hashlib.sha256()
    with file.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def collect(images, output, source_url):
    images, output = images.resolve(), output.resolve()
    if not images.is_dir():
        raise SystemExit("Extracted partition folder does not exist")
    output.mkdir(parents=True, exist_ok=True)
    (output / "pack-meta").mkdir(exist_ok=True)

    matches = {name: [] for name in NAMES}
    for current, dirs, files in os.walk(images, followlinks=False):
        dirs[:] = [name for name in dirs if not (Path(current) / name).is_symlink()]
        for filename in files:
            key = filename.casefold()
            if key not in matches:
                continue
            path = Path(current) / filename
            if path.is_file() and not path.is_symlink():
                matches[key].append(path)

    rows = []
    for name in NAMES:
        candidates = matches[name]

        def priority(path):
            rel = path.relative_to(images).as_posix()
            directory = rel.rsplit("/", 1)[0].casefold()
            paths = tuple(x.casefold() for x in PREFERRED[name])
            return (paths.index(directory) if directory in paths else len(paths), rel)

        candidates.sort(key=priority)
        row = dict(target=name, source="", partition="", status="MISSING",
                   match="missing", size="", sha256="")
        if candidates:
            chosen = candidates[0]
            rel = chosen.relative_to(images)
            dest = output / name
            shutil.copy2(chosen, dest)
            row.update(source=rel.as_posix(), partition=rel.parts[0], status="FOUND",
                       match="exact-name" if len(candidates) == 1 else "preferred-of-multiple",
                       size=dest.stat().st_size, sha256=sha256(dest))
        rows.append(row)

    with (output / "map.tsv").open("w", encoding="utf-8", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=FIELDS, delimiter="\t")
        writer.writeheader()
        writer.writerows(rows)
    found = sum(row["status"] == "FOUND" for row in rows)
    summary = {
        "mode": "base",
        "created": datetime.now(timezone.utc).isoformat(),
        "source_url": source_url,
        "requested": len(rows),
        "found": found,
        "missing": len(rows) - found,
        "items": rows,
    }
    (output / "map.json").write_text(json.dumps(summary, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    meta = output / "pack-meta"
    (meta / "INDEX.tsv").write_bytes((output / "map.tsv").read_bytes())
    (meta / "manifest.json").write_text(
        json.dumps({k: v for k, v in summary.items() if k != "items"}, indent=2) + "\n", encoding="utf-8"
    )
    (meta / "SHA256SUMS.txt").write_text(
        "".join(f"{row['sha256']}  {row['target']}\n" for row in rows if row["status"] == "FOUND"),
        encoding="utf-8",
    )
    (meta / "HOW-TO-EXTRACT.txt").write_text(
        "Base dump takes five requested filenames from the extracted ROM partitions. "
        "map.tsv records the chosen source path; missing files remain listed as MISSING.\n",
        encoding="utf-8",
    )
    print(f"[DUMP] mode=base requested={len(rows)} found={found} missing={len(rows)-found}")
    if found == 0:
        raise SystemExit("No base files matched the source ROM")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--images", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--source-url", default="")
    args = parser.parse_args()
    collect(args.images, args.output, args.source_url)
