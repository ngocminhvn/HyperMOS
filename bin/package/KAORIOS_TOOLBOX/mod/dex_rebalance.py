#!/usr/bin/env python3
"""Conservative Kaorios DEX reference overflow recovery and validation.

Move complete top-level class families (including $-nested classes) out of
an overfull framework DEX without dropping methods or disabling any hooks.
The final JAR is accepted only if every original class survives exactly once.
"""
from __future__ import annotations

import argparse
from collections import defaultdict
from pathlib import Path
import re
import shutil
import struct
import sys

LIMIT = 65536
FIELDS = {
    "string_ids": 0x38,
    "type_ids": 0x40,
    "proto_ids": 0x48,
    "field_ids": 0x50,
    "method_ids": 0x58,
    "class_defs": 0x60,
}

# Never relocate bootstrap-sensitive framework classes, Kaorios callsites,
# or classes needed early in system_server/zygote boot.
PROTECTED_PREFIXES = (
    "android/os/", "android/app/", "android/content/", "android/provider/",
    "android/security/", "android/system/", "android/util/",
    "com/android/internal/os/", "com/android/internal/app/",
    "com/android/internal/util/", "java/", "javax/crypto/",
    "dalvik/", "libcore/", "sun/",
)
PROTECTED_CLASSES = {
    "android/view/WindowManagerGlobal",
    "android/view/WindowManagerImpl",
    "android/content/pm/ApplicationPackageManager",
    "android/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi",
    "android/security/keystore2/AndroidKeyStoreSpi",
    "android/provider/Settings$NameValueCache",
}


def dex_names(root: Path, suffix: str) -> list[Path]:
    return sorted(root.glob("classes*.dex" + suffix))


def read_stats(path: Path) -> dict[str, int]:
    """Validate every generated DEX *before* treating a successful smali exit as success.

    smali v2 can finish writing an invalid output when a 16-bit reference
    table overflows (observed for Android 17 framework classes3.dex).
    A non-empty file is not proof of a valid DEX.
    """
    with path.open("rb") as handle:
        data = handle.read(112)
    if len(data) < 112 or data[:4] != b"dex\n" or data[7:8] != b"\x00":
        raise ValueError(f"{path.name}: invalid DEX magic or truncated header")
    size = path.stat().st_size
    file_size = struct.unpack_from("<I", data, 0x20)[0]
    if size < 112 or file_size < 112 or file_size > size:
        raise ValueError(f"{path.name}: invalid DEX file_size={file_size}, actual={size}")
    stats = {key: struct.unpack_from("<I", data, offset)[0]
             for key, offset in FIELDS.items()}
    for key in ("type_ids", "proto_ids", "field_ids", "method_ids", "class_defs"):
        if stats[key] > LIMIT:
            raise ValueError(f"{path.name}: {key}={stats[key]} exceeds DEX limit {LIMIT}")
    return stats


def audit(root: Path) -> None:
    dexes = dex_names(root, "")
    if not dexes:
        raise ValueError(f"no classes*.dex in {root}")
    for dex in dexes:
        s = read_stats(dex)
        print(f"[DEX AUDIT] {dex.name}: " +
              ", ".join(f"{key}={value}" for key, value in s.items()), flush=True)
        if s["method_ids"] >= LIMIT - 128:
            print(f"[DEX WARN] {dex.name} has only {LIMIT - s['method_ids']} "
                  "method-reference slots left", flush=True)


def inventory(root: Path) -> set[str]:
    found: set[str] = set()
    dirs = dex_names(root, ".out")
    if not dirs:
        raise ValueError(f"no disassembled classes*.dex.out in {root}")
    for directory in dirs:
        for path in directory.rglob("*.smali"):
            rel = path.relative_to(directory).as_posix()
            desc = "L" + rel[:-6] + ";"
            if desc in found:
                raise ValueError(f"duplicate class {desc} in {root}")
            found.add(desc)
    if not found:
        raise ValueError(f"empty smali inventory: {root}")
    return found


def group_key(rel: str) -> str:
    # Keep outer class and nested classes together.
    parent, _, file = rel.rpartition("/")
    top = file[:-6].split("$", 1)[0]
    return (parent + "/" if parent else "") + top


def priority(name: str) -> int:
    if name.startswith(PROTECTED_PREFIXES) or name in PROTECTED_CLASSES:
        return 999
    if name.startswith("com/android/"):
        return 0
    if name.startswith(("com/", "org/", "javax/")):
        return 1
    if name.startswith(("android/hardware/", "android/media/", "android/graphics/")):
        return 2
    if name.startswith("android/"):
        return 3
    return 999


def relocate(source: Path, destination: Path) -> None:
    groups: dict[str, list[Path]] = defaultdict(list)
    for p in source.rglob("*.smali"):
        rel = p.relative_to(source).as_posix()
        groups[group_key(rel)].append(p)

    candidates: list[tuple[int, int, str, list[Path]]] = []
    for key, files in groups.items():
        rank = priority(key)
        if rank >= 999 or len(files) > 30:
            continue
        methods = 0
        for p in files:
            contents = p.read_text(encoding="utf-8", errors="replace")
            methods += len(re.findall(r"^\.method\b", contents, flags=re.MULTILINE))
        if not 4 <= methods <= 500:
            continue
        candidates.append((rank, -methods, key, files))

    if not candidates:
        raise ValueError(
            f"no safe class family available to relieve {source}; "
            "aborting instead of relocating critical framework classes"
        )
    candidates.sort(key=lambda item: (item[0], item[1], item[2]))
    _, negative_methods, key, files = candidates[0]
    for src in files:
        rel = src.relative_to(source)
        dst = destination / rel
        dst.parent.mkdir(parents=True, exist_ok=True)
        if dst.exists():
            raise ValueError(f"destination already contains {rel}")
        shutil.move(str(src), str(dst))
    print(f"[DEX REBALANCE] moved {key} ({len(files)} classes, "
          f"{-negative_methods} methods) from {source.name} to overflow DEX", flush=True)


def verify_classes(manifest: Path, final_root: Path) -> None:
    expected = set(manifest.read_text(encoding="utf-8").splitlines())
    actual = inventory(final_root)
    missing = expected - actual
    if missing:
        raise ValueError("original framework classes missing from rebuilt JAR: " +
                         ", ".join(sorted(missing)[:20]))
    print(f"[DEX VERIFY] retained all {len(expected)} original classes; "
          f"{len(actual) - len(expected)} additional driver classes; "
          "no duplicate definitions", flush=True)


def main() -> int:
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest="command", required=True)
    for name in ("audit", "inventory"):
        sub.add_parser(name).add_argument("root", type=Path)
    sub.add_parser("check-file").add_argument("path", type=Path)
    move = sub.add_parser("relocate")
    move.add_argument("source", type=Path)
    move.add_argument("destination", type=Path)
    verify = sub.add_parser("verify-classes")
    verify.add_argument("manifest", type=Path)
    verify.add_argument("root", type=Path)
    args = p.parse_args()
    try:
        if args.command == "audit":
            audit(args.root)
        elif args.command == "check-file":
            stats = read_stats(args.path)
            print(f"[DEX CHECK] {args.path.name}: " +
                  ", ".join(f"{key}={value}" for key, value in stats.items()), flush=True)
        elif args.command == "inventory":
            for descriptor in sorted(inventory(args.root)):
                print(descriptor)
        elif args.command == "relocate":
            relocate(args.source, args.destination)
        elif args.command == "verify-classes":
            verify_classes(args.manifest, args.root)
    except (OSError, ValueError) as exc:
        print(f"[DEX ERROR] {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
