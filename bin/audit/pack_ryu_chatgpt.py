#!/usr/bin/env python3
"""Pack original RYU APK/JAR files into exactly two ChatGPT-sized artifacts.

GitHub actions/upload-artifact creates a ZIP from each staging directory.
This script stages directly into those directories (no nested ZIP files).
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import tempfile

MAX_PART_BYTES = 430 * 1024 * 1024  # well below ChatGPT's 512 MB/file limit
IMPORTANT = frozenset({
    "powerkeeper.apk", "securitycenter.apk", "joyose.apk",
    "framework.jar", "services.jar", "miui-services.jar", "miui-framework.jar",
})
REPORTS = ("manifest.json", "app-inventory.tsv", "README.md",
           "SHA256SUMS.txt", "partitions.txt", "partition-info.json",
           "mirror-benchmark.json")


def digest(path):
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(8 * 1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def check_source(root):
    manifest_path = root / "manifest.json"
    data = json.loads(manifest_path.read_text(encoding="utf-8"))
    errors = [entry for entry in data["inventory"]
              if entry["status"] in ("skipped_invalid_apk", "skipped_safety_limit")]
    if errors:
        raise RuntimeError(f"{len(errors)} selected files were skipped: "
                           + ", ".join(x["path"] for x in errors[:7]))
    entries = data["files"]
    if len(entries) < 5:
        raise RuntimeError("Too few APK/JAR files in RYU collector")
    files = []
    seen = set()
    for item in entries:
        relative = Path(item["artifact_path"])
        if relative.is_absolute() or ".." in relative.parts or relative.parts[0] != "files":
            raise RuntimeError("Unsafe artifact path: " + str(relative))
        if str(relative) in seen:
            raise RuntimeError("Duplicate artifact path: " + str(relative))
        seen.add(str(relative))
        src = (root / relative).resolve(strict=True)
        if not src.is_file() or not src.is_relative_to(root.resolve()):
            raise RuntimeError("Invalid original file: " + str(relative))
        actual_size = src.stat().st_size
        if actual_size != item["size_bytes"] or digest(src) != item["sha256"]:
            raise RuntimeError("Manifest SHA256 / size mismatch: " + str(relative))
        if actual_size >= MAX_PART_BYTES:
            raise RuntimeError("A single file exceeds ChatGPT-friendly ZIP limit: " + str(relative))
        files.append((item, relative, src, actual_size))
    required = {"powerkeeper.apk", "miui-services.jar"}
    if not required.issubset({src.name.lower() for _, _, src, _ in files}):
        raise RuntimeError("PowerKeeper or miui-services.jar missing")
    return files, data


def allocate(files):
    groups = [[], []]
    totals = [0, 0]
    ordered = sorted(files, key=lambda x: (
        0 if x[2].name.lower() in IMPORTANT else 1, -x[3], str(x[1])
    ))
    for file in ordered:
        item, relative, src, size = file
        primary = 0 if src.name.lower() in IMPORTANT else (0 if totals[0] <= totals[1] else 1)
        choices = [primary, 1 - primary]
        fit = next((index for index in choices if totals[index] + size < MAX_PART_BYTES), None)
        if fit is None:
            raise RuntimeError(
                f"Cannot fit selected RYU files into exactly 2 x {MAX_PART_BYTES} bytes: {relative}"
            )
        groups[fit].append(file)
        totals[fit] += size
    if any(not group for group in groups):
        raise RuntimeError("Expected two nonempty ChatGPT ZIP groups")
    return groups


def pack(root, destination):
    files, original_manifest = check_source(root)
    groups = allocate(files)
    destination.mkdir(parents=True, exist_ok=True)
    assigned = set()
    for idx, group in enumerate(groups, 1):
        part = destination / f"part-{idx}"
        part.mkdir(parents=True, exist_ok=True)
        selection = []
        sums = []
        for item, relative, src, size in group:
            dst = part / relative
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(src, dst)
            if digest(dst) != item["sha256"]:
                raise RuntimeError("Copied file SHA256 mismatch: " + str(dst))
            assigned.add(str(relative))
            selection.append(item)
            sums.append(f"{item['sha256']}  {relative}")
        (part / "part-selection.json").write_text(json.dumps({
            "part": idx, "parts_total": 2,
            "source": original_manifest["source"], "items": selection,
            "original_file_count": len(files),
        }, indent=2) + "\n", encoding="utf-8")
        (part / "SHA256SUMS-part.txt").write_text("\n".join(sums) + "\n", encoding="utf-8")
        (part / "UPLOAD-TO-CHATGPT.txt").write_text(
            f"RYUOS HAOTIAN REA extraction - PART {idx} OF 2\n"
            "Upload both GitHub Actions artifact ZIP files to ChatGPT in the same chat.\n"
            "The original APK/JAR files are in files/. Do NOT flash these onto a phone.\n"
            "Manifest SHA-256 hashes identify each original file.\n",
            encoding="utf-8",
        )
        for name in REPORTS:
            if (root / name).is_file():
                shutil.copyfile(root / name, part / name)
        staged_size = sum(p.stat().st_size for p in part.rglob("*") if p.is_file())
        if staged_size >= MAX_PART_BYTES:
            raise RuntimeError(f"Part {idx} staging payload too large: {staged_size}")
        print(f"[RYU CHATGPT] PART {idx}: {len(group)} APK/JAR, "
              f"{staged_size / 1048576:.1f} MiB uncompressed; cap 430 MiB")
        for _, rel, _, size in group:
            print(f"  {rel} ({size} bytes)")
    expected = {str(rel) for _, rel, _, _ in files}
    if assigned != expected:
        raise RuntimeError("ZIP grouping lost or duplicated selected files")
    print("[RYU CHATGPT] PASS: all selected original files included in exactly 2 artifact ZIPs.")


def self_test():
    with tempfile.TemporaryDirectory() as folder:
        root = Path(folder) / "input"
        out = Path(folder) / "out"
        root.mkdir()
        names = ["PowerKeeper.apk", "SecurityCenter.apk", "Joyose.apk", "Settings.apk",
                 "framework.jar", "miui-services.jar"]
        entries = []
        for i, filename in enumerate(names):
            rel = Path("files") / ("system_ext" if i < 4 else "system") / filename
            path = root / rel
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(bytes([i + 1]) * (100 + i * 7))
            entries.append({"artifact_path": str(rel), "path": filename,
                            "size_bytes": path.stat().st_size, "sha256": digest(path)})
        (root / "manifest.json").write_text(json.dumps({
            "source": "fixture", "files": entries, "inventory": [],
        }))
        pack(root, out)
        all_files = set()
        for i in (1, 2):
            part = out / f"part-{i}"
            chosen = json.loads((part / "part-selection.json").read_text())["items"]
            for item in chosen:
                assert item["artifact_path"] not in all_files
                all_files.add(item["artifact_path"])
                assert digest(part / item["artifact_path"]) == item["sha256"]
        assert len(all_files) == len(names)
    print("[RYU CHATGPT] Self-test passed")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path)
    parser.add_argument("--out", type=Path)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        self_test()
    else:
        if not args.source or not args.out:
            parser.error("--source and --out are required")
        pack(args.source, args.out)
