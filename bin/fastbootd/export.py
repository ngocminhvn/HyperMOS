#!/usr/bin/env python3
"""Export selected partition images from the standard HyperMOS ROM build.

The normal packROM.sh builds the same partition images then assembles super.img.
FastbootD mode stops before super construction and creates one GitHub artifact
containing only the requested .img files plus hashes/compatibility metadata.
"""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import tempfile

SUPPORTED = (
    "system", "system_ext", "product", "mi_ext",
    "vendor", "odm", "system_dlkm", "vendor_dlkm",
    "odm_dlkm", "product_dlkm",
)
CHUNK = 1024 * 1024


def parse_selection(value: str) -> tuple[str, ...]:
    parts = tuple(x.strip().lower() for x in value.split(","))
    if not parts or any(not x for x in parts):
        raise ValueError("Expected comma-separated partitions, e.g. system,system_ext,product,mi_ext")
    if len(set(parts)) != len(parts):
        raise ValueError("Duplicate partition name")
    unknown = set(parts) - set(SUPPORTED)
    if unknown:
        raise ValueError("Unsupported partition(s): " + ", ".join(sorted(unknown)))
    return parts


def read_label(root: Path, name: str) -> str:
    path = root / "bin/ddevice" / name
    if not path.is_file():
        raise ValueError(f"Missing build metadata: {name}")
    value = path.read_text(encoding="utf-8").strip()
    if not re.fullmatch(r"[A-Za-z0-9._-]{1,96}", value):
        raise ValueError(f"Unsafe or missing metadata in {name}")
    return value


def hash_file(path: Path) -> tuple[int, str]:
    if not path.is_file() or path.is_symlink():
        raise ValueError("Missing or non-regular image: " + str(path))
    size = path.stat().st_size
    if size < 4096:
        raise ValueError("Partition image is unexpectedly small: " + str(path))
    sha = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(CHUNK), b""):
            sha.update(block)
    return size, sha.hexdigest()


def export(root: Path, out: Path, partitions: tuple[str, ...]) -> dict:
    images = root / "build/baserom/images"
    metadata = {
        key: read_label(root, key)
        for key in ("device_f.txt", "base_rom_code.txt", "androidver.txt", "rom_source.txt")
    }
    if (out / "images").exists():
        raise ValueError("Refusing to overwrite a previous FastbootD artifact")
    info = {}
    # Validate all requested images BEFORE moving any files.
    for part in partitions:
        size, sha = hash_file(images / f"{part}.img")
        info[part] = {
            "path": f"images/{part}.img",
            "bytes": size,
            "sha256": sha,
        }

    dst = out / "images"
    dst.mkdir(parents=True)
    for part in partitions:
        shutil.move(str(images / f"{part}.img"), str(dst / f"{part}.img"))

    manifest = {
        "type": "HyperMOS FastbootD partition artifact; not a complete flashable ROM",
        "device": metadata["device_f.txt"],
        "base_rom_code": metadata["base_rom_code.txt"],
        "android": metadata["androidver.txt"],
        "rom_source": metadata["rom_source.txt"],
        "github_sha": os.environ.get("GITHUB_SHA", "local"),
        "github_run_number": os.environ.get("GITHUB_RUN_NUMBER", "local"),
        "created_utc": datetime.now(timezone.utc).isoformat(),
        "selected_partitions": list(partitions),
        "images": info,
        "boot_init_boot_vbmeta_super_userdata_included": False,
        "boot_tested": False,
    }
    (out / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    (out / "SHA256SUMS.txt").write_text(
        "".join(f"{info[p]['sha256']}  images/{p}.img\n" for p in partitions),
        encoding="utf-8",
    )
    instructions = [
        "HyperMOS fastbootD partition artifact (NOT a full ROM)",
        "",
        f"Device: {manifest['device']}  Android: {manifest['android']}",
        f"Source: {manifest['rom_source']}  Base: {manifest['base_rom_code']}",
        "Included: " + ", ".join(partitions),
        "",
        "CAUTION: Confirm that the installed device and base ROM match the",
        "manifest. Mixing partitions across bases or versions may bootloop.",
        "Back up data and retain a working recovery/rollback path.",
        "Disable any systemless module that replaces these ROM files before",
        "testing the flashed partitions; otherwise a module may mask changes.",
        "This archive includes NO boot/init_boot/vbmeta/super or userdata.",
        "Existing root and userdata are NOT modified by the included images.",
        "Do NOT use fastboot -w or erase userdata.",
        "",
        "Manual procedure (Windows platform-tools):",
        "  adb reboot fastboot",
        "  fastboot getvar product",
        "  fastboot getvar is-userspace",
        "Proceed only when product matches the manifest and userspace is yes.",
        "Flash only the selected matching images in fastbootD:",
    ]
    instructions += [f"  fastboot flash {p} images\\{p}.img" for p in partitions]
    instructions += [
        "  fastboot reboot",
        "",
        "Note: flashing only part of a multi-partition HyperMOS build does",
        "not apply changes from unselected partitions. These are not OTA deltas.",
        "Build-time validity does not guarantee device boot or notification behavior.",
        "",
    ]
    (out / "README_FASTBOOTD.txt").write_text(
        "\n".join(instructions), encoding="utf-8"
    )
    print(f"[FASTBOOTD] Exported {len(partitions)} selected partitions into {out}")
    for part in partitions:
        print(f"[FASTBOOTD] {part}.img: {info[part]['bytes']} bytes, SHA256 {info[part]['sha256']}")
    return manifest


def self_test() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        md = root / "bin/ddevice"
        md.mkdir(parents=True)
        for name, value in {
            "device_f.txt": "haotian",
            "base_rom_code.txt": "OS3.0.309.0.WOBCNXM",
            "androidver.txt": "16",
            "rom_source.txt": "xiaomi_eu",
        }.items():
            (md / name).write_text(value)
        img = root / "build/baserom/images"
        img.mkdir(parents=True)
        for part in ("system", "system_ext"):
            (img / f"{part}.img").write_bytes(part.encode() * 1500)
        (img / "boot.img").write_bytes(b"boot untouched")
        assert parse_selection("system_ext,system") == ("system_ext", "system")
        for bad in ("", "system,", "system,system", "super", "system,../boot"):
            try:
                parse_selection(bad)
            except ValueError:
                pass
            else:
                raise AssertionError(f"Accepted invalid selection: {bad}")
        try:
            export(root, root / "missing", ("system", "product"))
        except ValueError:
            assert (img / "system.img").is_file()
        else:
            raise AssertionError("Partial export passed with missing images")
        out = root / "out/fastbootd"
        result = export(root, out, ("system_ext", "system"))
        assert list(result["images"]) == ["system_ext", "system"]
        assert (out / "images/system.img").is_file()
        assert (img / "boot.img").read_bytes() == b"boot untouched"
        assert not (out / "images/boot.img").exists()
        assert result["boot_init_boot_vbmeta_super_userdata_included"] is False
        assert (out / "SHA256SUMS.txt").read_text().count(".img") == 2
    print("[FASTBOOTD] self-test PASS")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--select", help="Comma-separated partition names")
    parser.add_argument("--export", action="store_true")
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--out", type=Path)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    try:
        if args.self_test:
            self_test()
            return
        if args.select is None:
            raise ValueError("--select is required")
        selection = parse_selection(args.select)
        if args.export:
            if args.out is None:
                raise ValueError("--out is required with --export")
            export(args.root.resolve(), args.out.resolve(), selection)
        else:
            print(" ".join(selection))
    except (OSError, ValueError, AssertionError) as err:
        parser.exit(1, f"[FASTBOOTD] FAIL: {err}\n")


if __name__ == "__main__":
    main()
