#!/usr/bin/env python3
"""Extract only bootanimation.zip from a HyperOS ROM ZIP (read-only).

Reuses the existing HyperMOS dump extractor only when the ZIP has no direct
bootanimation entry. No ROM repacking, flashing, or APK/JAR collection.
"""
import argparse
import shutil
import subprocess
import zipfile
from pathlib import Path, PurePosixPath

ROOT = Path(__file__).resolve().parents[2]
# Android gives /product/media precedence over the /system/media fallback.
PARTITIONS = ("product", "system", "system_ext")


def candidate_rank(name: str):
    """Return a deterministic priority for a plausible bootanimation path."""
    if "\\" in name or name.startswith("/"):
        return None
    parts = tuple(p.lower() for p in PurePosixPath(name).parts)
    if ".." in parts or not parts or parts[-1] != "bootanimation.zip":
        return None
    if len(parts) == 1:
        return (99, 0, name.lower())
    if parts[-2] != "media":
        return None
    prefix = parts[:-2]
    for priority, part in enumerate(PARTITIONS):
        if part in prefix:
            pos = prefix.index(part)
            if all(p == part for p in prefix[pos + 1:]):
                return (priority, len(prefix), name.lower())
    if not prefix:
        return (50, 0, name.lower())
    return None


def from_archive(rom: Path, output: Path):
    with zipfile.ZipFile(rom) as archive:
        options = sorted(
            ((candidate_rank(info.filename), info) for info in archive.infolist()
             if not info.is_dir() and candidate_rank(info.filename) is not None),
            key=lambda item: item[0],
        )
        if not options:
            return None
        _, info = options[0]
        output.parent.mkdir(parents=True, exist_ok=True)
        with archive.open(info) as src, output.open("wb") as dst:
            shutil.copyfileobj(src, dst, length=1024 * 1024)
        return info.filename


def from_partitions(images: Path, output: Path):
    if not images.is_dir():
        return None
    options = sorted(
        ((candidate_rank(str(path.relative_to(images))), path)
         for path in images.rglob("bootanimation.zip")
         if path.is_file() and candidate_rank(str(path.relative_to(images))) is not None),
        key=lambda item: item[0],
    )
    if not options:
        return None
    _, chosen = options[0]
    output.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(chosen, output)
    return str(chosen.relative_to(images))


def validate_animation(output: Path):
    if not output.is_file() or output.stat().st_size == 0:
        raise SystemExit("[ERROR] bootanimation.zip is missing or empty")
    if not zipfile.is_zipfile(output):
        raise SystemExit("[ERROR] Extracted bootanimation.zip is not a valid ZIP")
    with zipfile.ZipFile(output) as animation:
        bad = animation.testzip()
        if bad:
            raise SystemExit(f"[ERROR] Invalid bootanimation member: {bad}")
        if not any(entry.filename.lower() == "desc.txt" for entry in animation.infolist()):
            print("[WARN] Animation ZIP has no root desc.txt; retaining original file")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--rom", type=Path, required=True, help="Downloaded ROM ZIP")
    parser.add_argument("--work", type=Path, required=True, help="Temporary dump directory")
    parser.add_argument("--output", type=Path, required=True, help="Final bootanimation.zip")
    args = parser.parse_args()
    args.work.mkdir(parents=True, exist_ok=True)

    source = from_archive(args.rom, args.output)
    if source:
        print("[BOOTANIMATION] Found directly inside ROM ZIP:", source, flush=True)
    else:
        print("[BOOTANIMATION] Not directly in ZIP; extracting system/product/system_ext", flush=True)
        subprocess.run(
            ["bash", str(ROOT / "bin/dump/extract.sh"),
             str(args.rom), str(args.work), "base"],
            check=True,
        )
        source = from_partitions(args.work / "images", args.output)
        if not source:
            raise SystemExit(
                "[ERROR] No bootanimation.zip under product/system/system_ext media/. "
                "This ROM might not contain a boot animation or use an unsupported layout."
            )
        source = "partition/" + source

    validate_animation(args.output)
    (args.work / "bootanimation-source.txt").write_text(source + "\n", encoding="utf-8")
    print("[BOOTANIMATION] Source:", source, flush=True)
    print("[BOOTANIMATION] Output:", args.output, "bytes:", args.output.stat().st_size, flush=True)


if __name__ == "__main__":
    main()
