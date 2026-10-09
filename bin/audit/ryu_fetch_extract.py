#!/usr/bin/env python3
"""Read only selected /images/*.img ZIP members over HTTP range requests.
Never downloads or publishes complete ROM or third-party APK/JAR files.
"""
import argparse
import hashlib
import json
import os
import shutil
import struct
import subprocess
import sys
import tempfile
from pathlib import Path
from remotezip import RemoteZip

TARGETS = ("framework.jar", "services.jar", "miui-services.jar",
           "PowerKeeper.apk", "MiuiSystemUI.apk", "SecurityCenter.apk")
PARTITIONS = ("system", "system_ext", "product", "mi_ext")
SPARSE_MAGIC = 0xED26FF3A

def invoke(*args, check=True):
    print("$", " ".join(map(str, args)), flush=True)
    return subprocess.run([str(x) for x in args], check=check)

def free_bytes(path):
    return shutil.disk_usage(path).free

def save_one(src, dst):
    dst.parent.mkdir(parents=True, exist_ok=True)
    with src.open() as inp, dst.open("wb") as out:
        shutil.copyfileobj(inp, out, length=4 * 1024 * 1024)
    return dst

def stage_from_image(image, files, root):
    # Android sparse -> raw, for loop mount/lpunpack; ensure free space first.
    with image.open("rb") as f:
        sparse = struct.unpack("<I", f.read(4))[0] == SPARSE_MAGIC
    if sparse:
        with image.open("rb") as f:
            header = f.read(28)
        _, _, _, _, _, block_size, blocks, _, _ = struct.unpack("<I4H4I", header)
        required = block_size * blocks
        if free_bytes(root) < required + 1024 ** 3:
            raise RuntimeError("Not enough disk for sparse->raw image conversion")
        raw = image.with_suffix(".raw.img")
        invoke("simg2img", image, raw)
        image.unlink()
        image = raw
    mountpoint = root / "mounted"
    mountpoint.mkdir(exist_ok=True)
    try:
        # Mount read-only. A GitHub hosted Linux runner is root-capable through sudo.
        invoke("sudo", "mount", "-o", "loop,ro", image, mountpoint)
    except subprocess.CalledProcessError:
        # EROFS image filesystem may require the filesystem type explicitly.
        try:
            invoke("sudo", "mount", "-t", "erofs", "-o", "loop,ro", image, mountpoint)
        except subprocess.CalledProcessError as exc:
            raise RuntimeError(f"Could not mount {image.name} as ext4/EROFS") from exc
    try:
        for path in mountpoint.rglob("*"):
            if not path.is_file() or path.name not in TARGETS:
                continue
            # First occurrence wins, except the first is a tiny stub.
            dest = files / path.name
            if dest.exists() and dest.stat().st_size > 100_000:
                continue
            shutil.copyfile(path, dest)
            print("EXTRACT", path.relative_to(mountpoint), dest, flush=True)
    finally:
        invoke("sudo", "umount", mountpoint)
    return image

def select_logical_partitions(super_image):
    """Read real LP names; Xiaomi super images usually use system_a, product_a, etc."""
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from lpunpack import LpUnpack

    reader = LpUnpack(SUPER_IMAGE=str(super_image))
    try:
        metadata = reader._read_metadata()
        available = {part.name: part.num_extents for part in metadata.partitions}
    finally:
        reader._fd.close()
    print("AVAILABLE LP PARTITIONS", available, flush=True)

    selected = []
    for base in PARTITIONS:
        # Prefer the active A slot; skip empty B-slot placeholders.
        name = next((candidate for candidate in
                     (base + "_a", base, base + "_b")
                     if available.get(candidate, 0) > 0), None)
        if name:
            selected.append(name)
        else:
            print("LP PARTITION ABSENT", base, flush=True)
    if not selected:
        raise RuntimeError("No target logical partitions found in super metadata: "
                           + ", ".join(available))
    print("SELECTED LP PARTITIONS", selected, flush=True)
    return selected


def copy_member_with_progress(source, target, expected, label):
    """Emit a heartbeat during the 11+ GB SourceForge ZIP-member transfer."""
    import time
    copied = 0
    last_log = time.monotonic()
    while True:
        chunk = source.read(4 * 1024 * 1024)
        if not chunk:
            break
        target.write(chunk)
        copied += len(chunk)
        now = time.monotonic()
        if now - last_log >= 30:
            print(f"READ PROGRESS {label}: {copied}/{expected} bytes "
                  f"({copied * 100 / expected:.1f}%)", flush=True)
            last_log = now
    if copied != expected:
        raise RuntimeError(f"ZIP member {label}: incomplete download "
                           f"({copied} != {expected})")


def process_image(image, root, found):
    print("PROCESS", image, "size=", image.stat().st_size, flush=True)
    if "super.img" in image.name or image.name.startswith("super"):
        image2 = image
        with image.open("rb") as f:
            sparse = struct.unpack("<I", f.read(4))[0] == SPARSE_MAGIC
        if sparse:
            with image.open("rb") as f:
                header = f.read(28)
            _, _, _, _, _, bs, nb, _, _ = struct.unpack("<I4H4I", header)
            if free_bytes(root) < bs * nb + 1024**3:
                raise RuntimeError("Runner disk too small to unsparse RYU super.img")
            image2 = root / "super.raw.img"
            invoke("simg2img", image, image2)
            image.unlink()
        # Inspect LP metadata before extraction; unsuffixed partition names fail on A/B ROMs.
        # Extract just selected logical partitions, not the entire 11+ GB super image.
        for partition in select_logical_partitions(image2):
            outdir = root / "partition"
            outdir.mkdir(exist_ok=True)
            invoke(sys.executable, "bin/lpunpack.py", "-p", partition, image2, outdir)
            images = list(outdir.glob("*.img"))
            for partimage in images:
                processed = stage_from_image(partimage, found, root)
                processed.unlink(missing_ok=True)
        image2.unlink(missing_ok=True)
    else:
        processed = stage_from_image(image, found, root)
        processed.unlink(missing_ok=True)

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--url", required=True)
    p.add_argument("--work", default="ryu-work", type=Path)
    p.add_argument("--out", default="ryu-extracted", type=Path)
    p.add_argument("--inventory-only", action="store_true")
    args = p.parse_args()
    args.work.mkdir(parents=True, exist_ok=True)
    args.out.mkdir(parents=True, exist_ok=True)
    inventory_path = args.out / "zip_inventory.json"
    url = args.url
    # Query parameters containing expiring signatures are intentionally not persisted.
    with RemoteZip(url) as z:
        entries = z.infolist()
        inventory = [
            {"name": i.filename, "size": i.file_size,
             "compressed": i.compress_size, "crc": f"{i.CRC:08x}"}
            for i in entries
        ]
        inventory_path.write_text(json.dumps(inventory, indent=2)+"\n")
        print("ZIP items", len(entries), flush=True)
        for e in inventory:
            if e["name"].startswith("images/"):
                print(e["name"], e["size"], flush=True)
        if args.inventory_only:
            return
        eligible = [
            e["name"] for e in inventory
            if e["name"].startswith("images/")
            and e["name"].endswith(".img")
            and Path(e["name"]).name.replace(".img", "") in PARTITIONS
        ]
        if not eligible:
            super_files = sorted(
                (e["name"] for e in inventory
                 if e["name"].startswith("images/")
                 and Path(e["name"]).name.startswith("super.img")),
                key=lambda x: (not x.endswith("super.img"), x)
            )
            if not super_files:
                raise RuntimeError("No images/system*.img or images/super.img found")
            # Segment super.img.0, super.img.1 ... when split.
            eligible = super_files
        print("SELECTED IMAGES", eligible, flush=True)
        by_name = {item["name"]: item["size"] for item in inventory}
        if len(eligible) > 1 and all("super.img" in x for x in eligible):
            dest = args.work / "super.img"
            with dest.open("wb") as out:
                for entry in eligible:
                    print("READ ZIP MEMBER", entry, flush=True)
                    with z.open(entry) as inp:
                        copy_member_with_progress(inp, out, by_name[entry], entry)
            process_image(dest, args.work, args.out)
        else:
            for entry in eligible:
                path = args.work / Path(entry).name
                print("READ ZIP MEMBER", entry, flush=True)
                with z.open(entry) as inp, path.open("wb") as out:
                    copy_member_with_progress(inp, out, by_name[entry], entry)
                process_image(path, args.work, args.out)
                path.unlink(missing_ok=True)
    required = ("framework.jar", "services.jar", "miui-services.jar", "PowerKeeper.apk")
    absent = [x for x in required if not (args.out / x).is_file()]
    if absent:
        raise RuntimeError("Missing required extracts: " + ", ".join(absent))
    print("SUCCESS: extracted", [x.name for x in args.out.iterdir()], flush=True)

if __name__ == "__main__":
    main()
