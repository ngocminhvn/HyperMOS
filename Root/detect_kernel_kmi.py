#!/usr/bin/env python3
"""Detect stock Android GKI Kernel Module Interface from extracted OTA images.

Output a single KMI such as android15-6.6. Never infer from Android OS version.
Prefer boot.img's Linux version; corroborate with vendor/odm DLKM vermagic.
Ambiguous or unrecognized kernels fail closed before selecting a root LKM.
"""
from __future__ import annotations

import argparse
import re
import subprocess
import sys
import tempfile
from pathlib import Path

KNOWN_KMIS = frozenset({
    "android12-5.10",
    "android13-5.10",
    "android13-5.15",
    "android14-5.15",
    "android14-6.1",
    "android15-6.6",
    "android16-6.12",
    "android17-6.18",
})
# Ubuntu Linux strings and ELF .modinfo fields contain the running release.
KERNEL_RE = re.compile(rb"Linux version\s+(\d+\.\d+)\.\d+-android(1[2-7])\b")
VERMAGIC_RE = re.compile(rb"vermagic=(\d+\.\d+)\.\d+-android(1[2-7])\b")


def candidates(raw: bytes, pattern: re.Pattern[bytes]) -> set[str]:
    return {f"android{ver.decode()}-{major_minor.decode()}"
            for major_minor, ver in pattern.findall(raw)}


def check_sources(kernel_sources: list[Path], dlkm_dirs: list[Path]) -> str:
    found_kernel: set[str] = set()
    found_modules: set[str] = set()
    for path in kernel_sources:
        if path.is_file() and path.stat().st_size:
            found_kernel |= candidates(path.read_bytes(), KERNEL_RE)
    print(f"[KMI] boot kernel: {sorted(found_kernel) or 'no release marker'}", file=sys.stderr)
    checked = 0
    for directory in dlkm_dirs:
        if not directory.is_dir():
            continue
        for item in sorted(directory.rglob("*.ko")):
            if not item.is_file():
                continue
            checked += 1
            # ELF .modinfo is usually near the beginning; cap memory per module.
            with item.open("rb") as fh:
                found_modules |= candidates(fh.read(32 * 1024 * 1024), VERMAGIC_RE)
    print(f"[KMI] vendor/odm modules checked: {checked}; detected: "
          f"{sorted(found_modules) or 'none'}", file=sys.stderr)
    if len(found_kernel) > 1 or len(found_modules) > 1:
        raise RuntimeError(f"conflicting KMI metadata: kernel={found_kernel}, modules={found_modules}")
    if found_kernel and found_modules and found_kernel != found_modules:
        raise RuntimeError(f"kernel/module KMI mismatch: {found_kernel} vs {found_modules}")
    result = found_kernel or found_modules
    if len(result) != 1:
        raise RuntimeError("cannot establish stock KMI; refusing guessed root module")
    kmi = next(iter(result))
    if kmi not in KNOWN_KMIS:
        raise RuntimeError(f"KMI {kmi} is not in the verified root-release matrix")
    return kmi


def validate_self_test() -> None:
    kernel = b"Linux version 6.6.77-android15-8-gabcd SMP PREEMPT"
    module = b"vermagic=6.6.77-android15-8-gabcd SMP preempt mod_unload aarch64"
    assert candidates(kernel, KERNEL_RE) == {"android15-6.6"}
    assert candidates(module, VERMAGIC_RE) == {"android15-6.6"}
    assert not candidates(b"Linux version 6.6.77-generic", KERNEL_RE)
    assert candidates(b"Linux version 6.12.0-android16-1", KERNEL_RE) == {"android16-6.12"}
    assert candidates(b"vermagic=6.1.75-android14-11 SMP", VERMAGIC_RE) == {"android14-6.1"}
    print("[KMI] Self-test PASS", file=sys.stderr)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--boot-image", type=Path)
    parser.add_argument("--magiskboot", type=Path)
    parser.add_argument("--images-dir", type=Path)
    parser.add_argument("--kernel", type=Path, help="Read a previously unpacked kernel (testing)")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()

    if args.self_test:
        validate_self_test()
        return
    if args.images_dir is None:
        parser.error("--images-dir required")
    images = args.images_dir.resolve()
    modules = [
        images / part / "lib/modules"
        for part in ("vendor_dlkm", "odm_dlkm", "system_dlkm", "vendor", "odm")
    ]
    if args.kernel is not None:
        detected = check_sources([args.kernel], modules)
    else:
        if args.boot_image is None or args.magiskboot is None:
            parser.error("must provide both --boot-image and --magiskboot")
        boot, magiskboot = args.boot_image.resolve(), args.magiskboot.resolve()
        if not boot.is_file() or not magiskboot.is_file():
            raise RuntimeError("boot.img or magiskboot binary does not exist")
        with tempfile.TemporaryDirectory(prefix="hypermos-kmi-") as folder:
            work = Path(folder)
            proc = subprocess.run(
                [str(magiskboot), "unpack", str(boot)],
                cwd=work, capture_output=True, text=True
            )
            if proc.returncode:
                raise RuntimeError(f"magiskboot cannot unpack base boot.img: "
                                   f"{proc.stderr[-500:]} {proc.stdout[-500:]}")
            extracted = work / "kernel"
            if not extracted.is_file():
                raise RuntimeError("magiskboot did not extract a kernel from stock boot.img")
            decompressed = work / "kernel.decompressed"
            # magiskboot may unpack a still-compressed kernel. Decompression is
            # optional; the original extracted kernel is always examined.
            attempt = subprocess.run(
                [str(magiskboot), "decompress", str(extracted), str(decompressed)],
                cwd=work, capture_output=True
            )
            kernel_files = [extracted]
            if attempt.returncode == 0 and decompressed.is_file():
                kernel_files.append(decompressed)
            detected = check_sources(kernel_files, modules)
    print(f"[KMI] confirmed stock kernel module interface: {detected}", file=sys.stderr)
    print(detected)


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, OSError, ValueError) as exc:
        print(f"::error::Stock kernel KMI detection failed: {exc}", file=sys.stderr)
        sys.exit(1)
