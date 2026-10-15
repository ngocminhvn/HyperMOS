#!/usr/bin/env python3
"""Read-only extraction fallback for custom ROM ZIP layouts.

Handles nested payloads, nested/split/compressed super images, per-partition
images, transfer-list images, or direct system file trees. Does not flash/repack.
"""
import argparse
import re
import shutil
import subprocess
import zipfile
from pathlib import Path, PurePosixPath

PARTS = (
    "system", "system_ext", "product", "vendor", "odm", "mi_ext",
    "mi_product", "system_dlkm", "vendor_dlkm", "odm_dlkm", "product_dlkm",
)
COMPRESS = {
    ".zst": ["zstd", "-dc"], ".gz": ["gzip", "-dc"],
    ".xz": ["xz", "-dc"], ".lz4": ["lz4", "-dc"], ".br": ["brotli", "-dc"],
}
ROOT = Path(__file__).resolve().parents[2]


def run(*cmd):
    print("[DUMP] Exec:", " ".join(map(str, cmd)), flush=True)
    subprocess.run(list(map(str, cmd)), check=True)


def read_member(archive, name, destination):
    destination.parent.mkdir(parents=True, exist_ok=True)
    suffix = next((s for s in COMPRESS if name.endswith(s)), None)
    if suffix:
        with archive.open(name) as source, destination.open("wb") as out:
            proc = subprocess.Popen(COMPRESS[suffix], stdin=subprocess.PIPE, stdout=out)
            try:
                shutil.copyfileobj(source, proc.stdin, length=1024 * 1024)
            finally:
                proc.stdin.close()
            if proc.wait() != 0:
                raise RuntimeError("Decompression failed for " + name)
    else:
        with archive.open(name) as source, destination.open("wb") as out:
            shutil.copyfileobj(source, out, length=1024 * 1024)
    print("[DUMP] Unpacked:", name, flush=True)


def make_raw(path, work):
    with path.open("rb") as f:
        sparse = f.read(4) == b"\x3a\xff\x26\xed"
    if sparse:
        output = work / "input" / (path.name + ".raw")
        run("simg2img", path, output)
        path.unlink()
        return output
    return path


def unpack_super(archive, work, partitions, names, parts):
    split = [(int(m.group(1)), name) for name in names
             if (m := re.search(r"(?:^|/)super\.img\.(\d+)$", name))]
    split.sort()
    source = work / "input" / "custom-super.img"
    if split:
        segments = []
        for i, (_, name) in enumerate(split):
            dest = work / "input" / ("super-part-" + str(i))
            read_member(archive, name, dest)
            segments.append(dest)
        # Xiaomi sparse splits are combined directly into a raw image.
        run("simg2img", *segments, source)
        for part in segments:
            part.unlink()
    else:
        candidates = [
            name for name in names
            if re.search(r"(?:^|/)super\.img(?:\.(?:zst|gz|xz|lz4))?$", name)
        ]
        if not candidates:
            return False
        read_member(archive, sorted(candidates, key=len)[0], source)
    source = make_raw(source, work)
    wanted = ",".join(value for part in parts for value in (part, part + "_a", part + "_b"))
    run("python3", ROOT / "bin/lpunpack.py", "-p", wanted, source, partitions)
    source.unlink(missing_ok=True)
    return True


def find_part_image(name, parts):
    basename = PurePosixPath(name).name
    match = re.fullmatch(
        r"([a-z0-9_]+?)(_a|_b)?\.img(?:\.(zst|gz|xz|lz4))?",
        basename, flags=re.I
    )
    if not match or match.group(1).lower() not in parts:
        return None
    return match.group(1).lower(), match.group(2) or "", basename


def unpack_partition_images(archive, work, partitions, names, parts):
    found = {}
    for name in names:
        info = find_part_image(name, parts)
        if info is None:
            continue
        part, slot, _ = info
        rank = (0 if not slot else 1 if slot == "_a" else 2, len(name), name)
        if part not in found or rank < found[part][0]:
            found[part] = (rank, name)
    for part, (_, name) in sorted(found.items()):
        read_member(archive, name, partitions / (part + ".img"))
    return bool(found)


def unpack_transfer_lists(archive, work, partitions, names, parts):
    name_set = set(names)
    found = 0
    for part in parts:
        matches = [
            name for name in names
            if re.search(r"(?:^|/)" + re.escape(part) +
                         r"\.new\.dat(?:\.(?:br|zst|gz|xz))?$", name)
        ]
        if not matches:
            continue
        data_name = matches[0]
        list_name = re.sub(r"\.new\.dat(?:\.(?:br|zst|gz|xz))?$",
                           ".transfer.list", data_name)
        if list_name not in name_set:
            print("[WARN] Missing transfer list:", list_name)
            continue
        data = work / "input" / (part + ".new.dat")
        transfer = work / "input" / (part + ".transfer.list")
        read_member(archive, data_name, data)
        read_member(archive, list_name, transfer)
        run("python3", ROOT / "bin/Linux/x86_64/sdat2img.py",
            transfer, data, partitions / (part + ".img"))
        data.unlink(missing_ok=True)
        transfer.unlink(missing_ok=True)
        found += 1
    return found > 0


def extract(zip_path, work, mode):
    if mode not in ("base", "full"):
        raise SystemExit("Unsupported dump mode: " + mode)
    work.mkdir(parents=True, exist_ok=True)
    partitions = work / "partitions"
    partitions.mkdir(parents=True, exist_ok=True)
    (work / "input").mkdir(parents=True, exist_ok=True)
    (work / "images").mkdir(parents=True, exist_ok=True)
    parts = ("system", "system_ext", "product") if mode == "base" else PARTS
    with zipfile.ZipFile(zip_path, "r") as archive:
        names = [item.filename for item in archive.infolist() if not item.is_dir()]
        for name in names:
            path = PurePosixPath(name)
            if path.is_absolute() or ".." in path.parts or "\\" in name:
                raise SystemExit("Unsafe archive member: " + name)
        print("[DUMP] Archive members:", len(names), flush=True)
        print("[DUMP] First ZIP members:", names[:30], flush=True)
        payloads = [name for name in names if re.search(r"(?:^|/)payload\.bin$", name)]
        if payloads:
            payload = work / "input/payload.bin"
            read_member(archive, payloads[0], payload)
            run(ROOT / "bin/Linux/x86_64/payload-extract",
                "extract", "-o", partitions, payload)
            payload.unlink(missing_ok=True)
            return "nested payload.bin"
        if unpack_super(archive, work, partitions, names, parts):
            return "custom super.img"
        if unpack_partition_images(archive, work, partitions, names, parts):
            return "individual partition images"
        if unpack_transfer_lists(archive, work, partitions, names, parts):
            return "transfer-list images"
    run("python3", ROOT / "bin/dump/direct_files.py",
        "--zip", zip_path, "--output", work / "images",
        "--mode", mode, "--targets", ROOT / "bin/dump/targets.txt")
    return "direct partition file tree"


def main():
    p = argparse.ArgumentParser()
    p.add_argument("zip_path", type=Path)
    p.add_argument("work", type=Path)
    p.add_argument("mode", choices=("base", "full"))
    args = p.parse_args()
    print("[DUMP] Detected fallback layout:", extract(args.zip_path, args.work, args.mode))


if __name__ == "__main__":
    main()
