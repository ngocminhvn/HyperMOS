#!/usr/bin/env python3
"""FK_LOCK: synchronize visible ROM fingerprints at build time.

Only system, system_ext, and product fingerprints are normalized.
Vendor/odm fingerprints are intentionally preserved.
"""
from __future__ import annotations

import argparse
from pathlib import Path
import re

PARTITIONS = ("system", "system_ext", "product")
SUSPICIOUS = re.compile(r"(?:^|[/_.:-])(missi|miproduct|qssi|generic|mainline)(?:$|[/_.:-])", re.I)


def parse_prop_file(path: Path) -> dict[str, str]:
    result: dict[str, str] = {}
    if not path.is_file():
        return result
    for raw in path.read_text(errors="ignore").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        result[key.strip()] = value.strip()
    return result


def all_build_props(images: Path) -> list[Path]:
    return sorted(p for p in images.rglob("build.prop") if p.is_file())


def partition_props(images: Path, partition: str) -> list[Path]:
    root = images / partition
    if not root.is_dir():
        return []
    return sorted(p for p in root.rglob("build.prop") if p.is_file())


def first_value(paths: list[Path], keys: tuple[str, ...]) -> str:
    for key in keys:
        for path in paths:
            value = parse_prop_file(path).get(key, "")
            if value:
                return value
    return ""


def canonical_prop_file(images: Path, partition: str) -> Path:
    root = images / partition
    candidates = [root / "build.prop", root / "etc/build.prop"]
    if partition == "system":
        candidates.insert(0, root / "system/build.prop")
    for candidate in candidates:
        if candidate.is_file():
            return candidate
    found = partition_props(images, partition)
    if found:
        return found[0]
    raise ValueError(f"FK_LOCK: no build.prop found for {partition}")


def set_key_in_file(path: Path, key: str, value: str) -> bool:
    lines = path.read_text(errors="ignore").splitlines()
    changed = False
    found = False
    out: list[str] = []

    for line in lines:
        if line.strip().startswith(key + "="):
            found = True
            replacement = f"{key}={value}"
            changed |= line != replacement
            out.append(replacement)
        else:
            out.append(line)

    if not found:
        out.append(f"{key}={value}")
        changed = True

    if changed:
        path.write_text("\n".join(out) + "\n")
    return changed


def set_property_everywhere(images: Path, key: str, value: str, preferred_partition: str) -> int:
    touched = 0
    found_any = False

    for path in all_build_props(images):
        props = parse_prop_file(path)
        if key in props:
            found_any = True
            if set_key_in_file(path, key, value):
                touched += 1

    if not found_any:
        if set_key_in_file(canonical_prop_file(images, preferred_partition), key, value):
            touched += 1

    return touched


def choose_target_fingerprint(images: Path) -> str:
    system_paths = partition_props(images, "system")
    all_paths = all_build_props(images)

    target = first_value(system_paths, ("ro.build.fingerprint",))
    if not target:
        target = first_value(all_paths, ("ro.build.fingerprint",))

    if not target or SUSPICIOUS.search(target):
        return ""
    return target


def normalize_fingerprints(images: Path) -> None:
    target = choose_target_fingerprint(images)
    if not target:
        print("[FK_LOCK] fingerprint sync skipped: trusted top-level ro.build.fingerprint unavailable")
        print("[FK_LOCK] preserving extracted ROM fingerprints")
        return

    print(f"[FK_LOCK] target fingerprint: {target}")

    for partition in PARTITIONS:
        key = f"ro.{partition}.build.fingerprint"
        touched = set_property_everywhere(images, key, target, partition)
        print(f"[FK_LOCK] {key}: synchronized ({touched} file(s) changed)")

    for partition in PARTITIONS:
        key = f"ro.{partition}.build.fingerprint"
        values = []
        for path in all_build_props(images):
            props = parse_prop_file(path)
            if key in props:
                values.append((path, props[key]))

        if not values:
            raise ValueError(f"FK_LOCK: {key} missing after synchronization")

        wrong = [(path, value) for path, value in values if value != target]
        if wrong:
            detail = ", ".join(f"{path}:{value}" for path, value in wrong)
            raise ValueError(f"FK_LOCK: {key} still inconsistent: {detail}")

    print("[FK_LOCK] fingerprint synchronization verified; vendor/odm preserved")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("workspace", type=Path)
    args = parser.parse_args()

    workspace = args.workspace.resolve()
    images = workspace / "build/baserom/images"
    if not images.is_dir():
        parser.exit(1, "ERROR: FK_LOCK: extracted images directory missing\n")

    try:
        normalize_fingerprints(images)
    except (OSError, ValueError) as error:
        parser.exit(1, f"ERROR: {error}\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
