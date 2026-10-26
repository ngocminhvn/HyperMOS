#!/usr/bin/env python3
"""Replace only EU PowerKeeper classes.dex; retain source APK entry metadata.

This does not sign or cryptographically authenticate a modified APK.
Original META-INF entries (if present) are copied byte-for-byte, as are
manifest, resources, assets, JNI libs, and all other non-DEX ZIP members.
An APK Signature Scheme v2/v3 signing block cannot remain valid after a DEX
modification and is not reintroduced by rebuilding a ZIP.
"""
import argparse
import copy
import hashlib
import json
import os
import tempfile
import zipfile
from pathlib import Path


def digest(data):
    return hashlib.sha256(data).hexdigest()


def read_members(apk):
    with zipfile.ZipFile(apk, "r") as archive:
        infos = archive.infolist()
        names = [info.filename for info in infos]
        if len(names) != len(set(names)):
            raise ValueError("APK has duplicate ZIP members")
        if archive.testzip() is not None:
            raise ValueError("APK failed ZIP CRC verification")
        if "classes.dex" not in names:
            raise ValueError("PowerKeeper APK has no classes.dex")
        extras = [n for n in names if n.startswith("classes") and n.endswith(".dex")
                  and n != "classes.dex"]
        if extras:
            raise ValueError("PowerKeeper has additional DEX; refusing partial DEX replacement: "
                             + repr(extras))
        if "AndroidManifest.xml" not in names:
            raise ValueError("PowerKeeper APK has no AndroidManifest.xml")
        if any(info.flag_bits & 0x1 for info in infos):
            raise ValueError("Encrypted APK ZIP member")
        contents = {name: archive.read(name) for name in names}
        return infos, contents, archive.comment


def verify_preservation(original, output, expected_dex):
    base_infos, before, base_comment = read_members(original)
    final_infos, after, final_comment = read_members(output)
    source_order = [info.filename for info in base_infos]
    target_order = [info.filename for info in final_infos]
    if source_order != target_order:
        raise ValueError("APK ZIP entries added, removed, or reordered")
    if base_comment != final_comment:
        raise ValueError("APK ZIP comment changed")
    if after["classes.dex"] != expected_dex:
        raise ValueError("Patched DEX missing or corrupted in APK")
    if not before["classes.dex"] or before["classes.dex"] == expected_dex:
        raise ValueError("PowerKeeper classes.dex was not actually changed")
    for name, data in before.items():
        if name != "classes.dex" and after[name] != data:
            raise ValueError("Non-DEX APK member changed: " + name)
    # ZIP container padding, offsets and v2/v3 blocks are not cryptographic
    # metadata. Do not claim signatures remain valid after modifying DEX.
    preserved_meta = sorted(n for n in before if n.upper().startswith("META-INF/"))
    return {
        "mode": "eu_original_apk_non_dex_and_meta_preserved",
        "original_apk_sha256": digest(original.read_bytes()),
        "patched_apk_sha256": digest(output.read_bytes()),
        "original_dex_sha256": digest(before["classes.dex"]),
        "patched_dex_sha256": digest(after["classes.dex"]),
        "non_dex_entries_verified": len(before) - 1,
        "meta_inf_entries_preserved": preserved_meta,
        "meta_inf_hashes": {n: digest(before[n]) for n in preserved_meta},
        "apk_resources_manifest_native_libraries_preserved": True,
        "cryptographic_signature_valid_after_modification": False,
        "apk_resigned": False,
        "v2_v3_signing_block_recreated": False,
        "runtime_tested": False
    }


def pack(original, dex, output):
    original = original.resolve()
    output = output.resolve()
    if original == output:
        raise ValueError("Output cannot overwrite stock APK before verification")
    if not original.is_file() or not dex.is_file():
        raise ValueError("Original APK or compiled DEX is missing")
    dex_data = dex.read_bytes()
    if not dex_data.startswith(b"dex\n"):
        raise ValueError("Compiled PowerKeeper classes.dex has invalid DEX magic")
    infos, contents, comment = read_members(original)
    output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="eu-pk-preserve-", dir=output.parent) as temp:
        candidate = Path(temp) / "PowerKeeper.apk"
        with zipfile.ZipFile(candidate, "w") as dest:
            dest.comment = comment
            for info in infos:
                name = info.filename
                raw = dex_data if name == "classes.dex" else contents[name]
                dest.writestr(copy.copy(info), raw)
        verify_preservation(original, candidate, dex_data)
        os.replace(candidate, output)
    return verify_preservation(original, output, dex_data)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", type=Path, required=True)
    parser.add_argument("--dex", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--verify-only", action="store_true")
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    try:
        if args.verify_only:
            result = verify_preservation(args.base, args.output, args.dex.read_bytes())
        else:
            result = pack(args.base, args.dex, args.output)
        if args.report:
            args.report.parent.mkdir(parents=True, exist_ok=True)
            args.report.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n",
                                   encoding="utf-8")
        print("[EU POWERKEEPER KEEP META] " + json.dumps({
            "apk_resigned": result["apk_resigned"],
            "non_dex_entries_verified": result["non_dex_entries_verified"],
            "meta_inf_entries_preserved": len(result["meta_inf_entries_preserved"]),
            "patched_dex_sha256": result["patched_dex_sha256"]
        }))
    except (OSError, ValueError, zipfile.BadZipFile, RuntimeError) as exc:
        raise SystemExit("[EU POWERKEEPER KEEP META] FAIL: " + str(exc))


if __name__ == "__main__":
    main()
