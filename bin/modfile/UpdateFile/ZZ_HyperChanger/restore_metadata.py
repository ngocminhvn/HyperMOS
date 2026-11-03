#!/usr/bin/env python3
"""Rebuild a patched APK with source ZIP/V1 metadata and no v2/v3 block."""
from __future__ import annotations

import argparse
import copy
import os
from pathlib import Path
import re
import struct
import tempfile
import zipfile


APK_SIG_MAGIC = b"APK Sig Block 42"
DEX_NAME = re.compile(r"classes(\d*)\.dex\Z")
CENTRAL_MAGIC = b"PK\x01\x02"
LOCAL_MAGIC = b"PK\x03\x04"


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
            raise ValueError("invalid source APK signing block")
        stream.seek(central - total)
        result = stream.read(total)
    if len(result) != total or struct.unpack("<Q", result[:8])[0] != size:
        raise ValueError("invalid source APK signing-block header")
    return result


def restore_header_metadata(path: Path, expected: dict[str, tuple[int, int]]) -> None:
    """Restore header fields that Python normalizes while writing ZIPs."""
    data = bytearray(path.read_bytes())
    with zipfile.ZipFile(path) as archive:
        position = archive.start_dir
        count = 0
        while position + 46 <= len(data) and data[position:position + 4] == CENTRAL_MAGIC:
            flags = struct.unpack_from("<H", data, position + 8)[0]
            name_len, extra_len, comment_len = struct.unpack_from("<HHH", data, position + 28)
            name_bytes = bytes(data[position + 46:position + 46 + name_len])
            name = name_bytes.decode("utf-8" if flags & 0x800 else "cp437")
            desired, external_attr = expected[name]
            if (flags ^ desired) & ~0x800:
                raise ValueError(f"structural ZIP flags changed for {name}")
            struct.pack_into("<H", data, position + 8, desired)
            struct.pack_into("<I", data, position + 38, external_attr)
            local = struct.unpack_from("<I", data, position + 42)[0]
            if data[local:local + 4] != LOCAL_MAGIC:
                raise ValueError(f"invalid local ZIP header for {name}")
            local_flags = struct.unpack_from("<H", data, local + 6)[0]
            if (local_flags ^ desired) & ~0x800:
                raise ValueError(f"structural local ZIP flags changed for {name}")
            struct.pack_into("<H", data, local + 6, desired)
            position += 46 + name_len + extra_len + comment_len
            count += 1
        if count != len(expected):
            raise ValueError("central-directory member count changed")
    path.write_bytes(data)


def restore(base: Path, rebuilt: Path, output: Path) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(base) as source, zipfile.ZipFile(rebuilt) as patched:
        for label, archive in (("base", source), ("rebuilt", patched)):
            names = archive.namelist()
            if len(names) != len(set(names)) or archive.testzip():
                raise ValueError(f"{label} APK is duplicate or damaged")
        old_names = source.namelist()
        new_names = patched.namelist()
        old_dex = [name for name in old_names if DEX_NAME.fullmatch(name)]
        if not old_dex:
            raise ValueError("base APK contains no DEX")
        numbers = [int(DEX_NAME.fullmatch(name).group(1) or "1") for name in old_dex]
        added = f"classes{max(numbers) + 1}.dex"
        if set(new_names) - set(old_names) != {added}:
            raise ValueError("rebuilt APK does not contain exactly one next-split DEX")
        changed = [name for name in old_dex if source.read(name) != patched.read(name)]
        if len(changed) != 1:
            raise ValueError(f"expected one changed existing DEX, found {changed}")
        for name in set(old_names) - set(old_dex):
            if source.read(name) != patched.read(name):
                raise ValueError(f"rebuilder changed non-DEX content: {name}")
        with tempfile.TemporaryDirectory(dir=output.parent, prefix="hyperchanger-meta-") as temp:
            unsigned = Path(temp) / "unsigned.apk"
            candidate = Path(temp) / "preserved.apk"
            with zipfile.ZipFile(unsigned, "w") as archive:
                archive.comment = source.comment
                expected_headers = {}
                for info in source.infolist():
                    data = patched.read(info.filename) if info.filename in changed else source.read(info.filename)
                    archive.writestr(copy.copy(info), data)
                    expected_headers[info.filename] = (info.flag_bits, info.external_attr)
                # New DEX inherits the last source DEX's timestamp, compression,
                # Unix attributes and extra fields; only its filename differs.
                template = copy.copy(source.getinfo(old_dex[-1]))
                template.filename = added
                template.orig_filename = added
                archive.writestr(template, patched.read(added))
                expected_headers[added] = (template.flag_bits, template.external_attr)
            restore_header_metadata(unsigned, expected_headers)
            # Match the supplied RYU APK: retain V1 META-INF identity but omit
            # the v2/v3 block instead of carrying a block with stale digests.
            os.replace(unsigned, candidate)
            with zipfile.ZipFile(candidate) as check:
                if check.testzip():
                    raise ValueError("metadata-restored APK is damaged")
                if signing_block(candidate, check) is not None:
                    raise ValueError("v2/v3 signing block was not stripped")
            os.replace(candidate, output)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", type=Path, required=True)
    parser.add_argument("--rebuilt", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    restore(args.base, args.rebuilt, args.output)
    print(f"[HyperChanger metadata] restored ZIP/V1 metadata; stripped v2/v3: {args.output}")


if __name__ == "__main__":
    main()
