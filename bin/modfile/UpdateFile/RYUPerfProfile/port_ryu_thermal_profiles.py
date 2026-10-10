#!/usr/bin/env python3
"""Experimental HAOTIAN RYU ODM thermal *profile* import, without disabling safety.

Match original RYU files by archive manifest+SHA, device layout and opaque
format. Preserve emergency/no-limits bypass, charging, low-level thermald,
boot, kernel and vendor safety rules on OS3.0.308.0 base. No wildcards on
ROM destinations. Fail closed if a required source is missing.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import tempfile

# RYU HAOTIAN original ODM thermal profiles with explicit exclusion of the
# bypass/charging profiles. Files are opaque: no unproved cutoff assumptions.
PROFILES = (
    "4k", "arvr", "camera", "cclassvideo", "cgame", "class0",
    "hp-mgame", "hp-normal", "huanji", "mgame", "navigation",
    "normal", "odm-map", "per-class0", "per-normal", "per-video",
    "phone", "video", "videochat",
)
PROTECTED = {"charge", "chg-only", "nolimits", "tgame"}
REQUIRED = {"normal", "video", "per-normal", "hp-normal"}
assert not PROTECTED.intersection(PROFILES)


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def prepare(artifact: Path, images: Path):
    records = json.loads((artifact / "manifest.json").read_text("utf-8"))
    keys = {}
    for record in records:
        key = record["partition"] + "/" + record["original_path"].lstrip("/")
        if key in keys:
            raise ValueError("Duplicate RYU archive path: " + key)
        keys[key] = record
    staged = []
    skipped = []
    for suffix in PROFILES:
        rel = f"odm/etc/thermal-{suffix}.conf"
        record = keys.get(rel)
        if record is None:
            if suffix in REQUIRED:
                raise ValueError("Required RYU thermal profile missing: " + rel)
            skipped.append({"file": rel, "reason": "RYU archive missing optional profile"})
            continue
        src = artifact / record["artifact_path"]
        if not src.resolve().is_relative_to(artifact.resolve()) or not src.is_file():
            raise ValueError("Invalid original RYU file path: " + rel)
        raw = src.read_bytes()
        if sha(raw) != record["sha256"]:
            raise ValueError("RYU thermal hash mismatch: " + rel)
        dst = images / rel
        if not dst.is_file() or dst.is_symlink():
            if suffix in REQUIRED:
                raise ValueError("Required Xiaomi stock thermal profile missing: " + rel)
            skipped.append({"file": rel, "reason": "Xiaomi base missing optional profile"})
            continue
        stock = dst.read_bytes()
        # Both versions must use the same nontrivial opaque block-file format.
        # Never write 16-byte no-limits substitutes over proper thermal profiles.
        if (min(len(raw), len(stock)) < 256 or len(raw) % 16 or len(stock) % 16):
            raise ValueError("Unsafe/incompatible thermal file encoding: " + rel)
        staged.append((rel, dst, stock, raw))
    if not REQUIRED.issubset({x[0].split("thermal-")[1][:-5] for x in staged}):
        raise ValueError("Not all required normal/video profiles validated")
    return staged, skipped


def run(artifact: Path, images: Path):
    staged, skipped = prepare(artifact, images)
    report = []
    completed = []
    try:
        for rel, dst, stock, new in staged:
            report.append(dict(file=rel, stock_sha256=sha(stock),
                               ryu_sha256=sha(new), changed=(stock != new)))
            if stock == new:
                continue
            fd, temporary = tempfile.mkstemp(prefix=".ryu-profile-", dir=dst.parent)
            try:
                with os.fdopen(fd, "wb") as out:
                    out.write(new)
                os.chmod(temporary, dst.stat().st_mode & 0o777)
                os.replace(temporary, dst)
                completed.append((dst, stock))
            finally:
                if os.path.exists(temporary):
                    os.unlink(temporary)
            if sha(dst.read_bytes()) != sha(new):
                raise ValueError("Post-installation hash mismatch: " + rel)
    except Exception:
        for dst, stock in reversed(completed):
            dst.write_bytes(stock)
        raise
    protected_before = {}
    for partition in ("odm", "vendor"):
        for suffix in sorted(PROTECTED):
            rel = f"{partition}/etc/thermal-{suffix}.conf"
            path = images / rel
            if path.is_file() and not path.is_symlink():
                protected_before[rel] = sha(path.read_bytes())
    result = dict(mode="RYU application-facing ODM thermal profiles",
                  installed=report, skipped=skipped,
                  excluded_safety_profiles=sorted(PROTECTED),
                  protected_stock_sha256=protected_before,
                  kernel_thermald_and_charging_unchanged=True)
    (images.parent / "ryu-test-thermal-profiles.json").write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"[RYU THERMAL] Verified {len(staged)} original RYU ODM profiles; "
          f"{sum(x['changed'] for x in report)} differ from Xiaomi base; "
          f"{len(skipped)} optional skipped")
    print("[RYU THERMAL] No Limits, TGame, charging, thermald and boot safeguards untouched")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--artifact", type=Path, required=True)
    parser.add_argument("--rom", type=Path, required=True)
    opts = parser.parse_args()
    run(opts.artifact, opts.rom)
