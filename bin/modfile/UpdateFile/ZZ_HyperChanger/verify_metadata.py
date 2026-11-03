#!/usr/bin/env python3
"""Verify that a HyperChanger APK rebuild preserved source APK identity data."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import zipfile


APK_SIG_MAGIC = b"APK Sig Block 42"
DEX_NAME = re.compile(r"classes(\d*)\.dex\Z")


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def signing_block(path: Path, archive: zipfile.ZipFile) -> bytes | None:
    central = archive.start_dir
    if central < 24:
        return None
    with path.open("rb") as stream:
        stream.seek(central - 24)
        footer = stream.read(24)
        if len(footer) != 24 or footer[8:] != APK_SIG_MAGIC:
            return None
        size = struct.unpack("<Q", footer[:8])[0]
        total = size + 8
        if total < 32 or total > central:
            raise ValueError("invalid APK signing-block size")
        stream.seek(central - total)
        block = stream.read(total)
    if len(block) != total or struct.unpack("<Q", block[:8])[0] != size:
        raise ValueError("invalid APK signing-block header")
    return block


def metadata(info: zipfile.ZipInfo) -> tuple:
    return (
        info.date_time, info.compress_type, info.comment, info.extra,
        info.internal_attr, info.external_attr, info.create_system,
        info.create_version, info.extract_version, info.flag_bits,
    )


def verify(base: Path, patched: Path) -> dict:
    with zipfile.ZipFile(base) as original, zipfile.ZipFile(patched) as output:
        for label, archive in (("base", original), ("patched", output)):
            names = archive.namelist()
            if len(names) != len(set(names)):
                raise ValueError(f"{label} APK has duplicate ZIP entries")
            damaged = archive.testzip()
            if damaged:
                raise ValueError(f"{label} APK has damaged member: {damaged}")

        old = {entry.filename: entry for entry in original.infolist()}
        new = {entry.filename: entry for entry in output.infolist()}
        old_dex = {name for name in old if DEX_NAME.fullmatch(name)}
        dex_numbers = [int(DEX_NAME.fullmatch(name).group(1) or "1")
                       for name in old_dex]
        if not dex_numbers:
            raise ValueError("base APK contains no DEX")
        added_dex = f"classes{max(dex_numbers) + 1}.dex"
        added = set(new) - set(old)
        removed = set(old) - set(new)
        if added != {added_dex} or removed:
            raise ValueError(f"unexpected APK members: added={added}, removed={removed}")
        if original.comment != output.comment:
            raise ValueError("ZIP comment changed")

        changed = set()
        for name, old_info in old.items():
            if metadata(old_info) != metadata(new[name]):
                raise ValueError(f"ZIP metadata changed for {name}")
            if original.read(name) != output.read(name):
                changed.add(name)
        if len(changed) != 1 or not changed <= old_dex:
            raise ValueError(f"non-target members changed: {sorted(changed)}")

        new_dex = output.read(added_dex)
        if not new_dex.startswith(b"dex\n"):
            raise ValueError("classes4.dex is not a DEX file")
        old_block = signing_block(base, original)
        new_block = signing_block(patched, output)
        if new_block is not None:
            raise ValueError("patched APK unexpectedly retains a v2/v3 signing block")

        meta_inf = sorted(name for name in old if name.upper().startswith("META-INF/"))
        identity_names = {
            "META-INF/MANIFEST.MF", "META-INF/CERT.SF", "META-INF/CERT.RSA"
        }
        identity_hashes = {
            name: hashlib.sha256(original.read(name)).hexdigest()
            for name in sorted(identity_names & set(old))
        }
        return {
            "mode": "ryu-style-v1-metadata-preserved-no-resign",
            "base_sha256": sha256(base),
            "patched_sha256": sha256(patched),
            "changed_members": sorted(changed | added),
            "unchanged_member_metadata": len(old),
            "meta_inf_member_count_preserved": len(meta_inf),
            "identity_member_sha256": identity_hashes,
            "source_signing_block_present": old_block is not None,
            "source_signing_block_sha256": (
                hashlib.sha256(old_block).hexdigest() if old_block else None
            ),
            "patched_signing_block_present": False,
            "v2_v3_signing_block_stripped": old_block is not None,
            "cryptographic_signature_valid_after_dex_change": False,
            "resigned": False,
        }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", type=Path, required=True)
    parser.add_argument("--patched", type=Path, required=True)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    result = verify(args.base, args.patched)
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print("[HyperChanger metadata] " + json.dumps(result, sort_keys=True))


if __name__ == "__main__":
    main()
