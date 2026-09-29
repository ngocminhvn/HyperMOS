#!/usr/bin/env python3
"""
Transplant the APK Signing Block from a stock APK into a patched APK.

This does NOT make the patched APK cryptographically Google-signed: the
signature digest no longer matches the modified APK contents. It is intended
only for ROM builds where framework/package-manager signature verification is
already deliberately relaxed (CorePatch-style behavior), while preserving the
stock signer certificate metadata exposed for the package.
"""

from __future__ import annotations

import hashlib
import struct
import sys
from pathlib import Path

EOCD_SIG = b"PK\x05\x06"
APK_SIG_MAGIC = b"APK Sig Block 42"
V2_ID = 0x7109871A


class ApkError(RuntimeError):
    pass


def find_eocd(data: bytes) -> int:
    # EOCD is at least 22 bytes and may be followed by a ZIP comment <= 65535.
    start = max(0, len(data) - (22 + 0xFFFF))
    for off in range(len(data) - 22, start - 1, -1):
        if data[off : off + 4] != EOCD_SIG:
            continue
        comment_len = struct.unpack_from("<H", data, off + 20)[0]
        if off + 22 + comment_len == len(data):
            return off
    raise ApkError("ZIP EOCD not found")


def central_directory_offset(data: bytes, eocd: int) -> int:
    cd_off = struct.unpack_from("<I", data, eocd + 16)[0]
    if cd_off == 0xFFFFFFFF:
        raise ApkError("ZIP64 APKs are not supported by this helper")
    return cd_off


def get_signing_block(data: bytes) -> tuple[int, int, bytes]:
    eocd = find_eocd(data)
    cd_off = central_directory_offset(data, eocd)

    if cd_off < 24 or data[cd_off - 16 : cd_off] != APK_SIG_MAGIC:
        raise ApkError("APK Signing Block not found before central directory")

    size2 = struct.unpack_from("<Q", data, cd_off - 24)[0]
    block_start = cd_off - (size2 + 8)
    if block_start < 0:
        raise ApkError("Invalid APK Signing Block size")

    size1 = struct.unpack_from("<Q", data, block_start)[0]
    if size1 != size2:
        raise ApkError("APK Signing Block size fields do not match")

    block = data[block_start:cd_off]
    if len(block) != size2 + 8:
        raise ApkError("Truncated APK Signing Block")

    return block_start, cd_off, block


def lp32(buf: bytes, off: int) -> tuple[bytes, int]:
    if off + 4 > len(buf):
        raise ApkError("Malformed length-prefixed field")
    n = struct.unpack_from("<I", buf, off)[0]
    off += 4
    end = off + n
    if end > len(buf):
        raise ApkError("Malformed length-prefixed field")
    return buf[off:end], end


def first_v2_cert_sha256(block: bytes) -> str | None:
    # APK Signing Block = size | repeated (uint64 len, uint32 id, value) | size | magic
    pos = 8
    end = len(block) - 24

    while pos < end:
        if pos + 8 > end:
            raise ApkError("Malformed APK Signing Block pair")
        pair_len = struct.unpack_from("<Q", block, pos)[0]
        pos += 8
        pair_end = pos + pair_len
        if pair_len < 4 or pair_end > end:
            raise ApkError("Malformed APK Signing Block pair")

        pair_id = struct.unpack_from("<I", block, pos)[0]
        value = block[pos + 4 : pair_end]
        pos = pair_end

        if pair_id != V2_ID:
            continue

        signers, _ = lp32(value, 0)
        signer, _ = lp32(signers, 0)
        signed_data, _ = lp32(signer, 0)
        _digests, off = lp32(signed_data, 0)
        certs, _ = lp32(signed_data, off)
        cert, _ = lp32(certs, 0)
        return hashlib.sha256(cert).hexdigest()

    return None


def transplant(stock_path: Path, patched_path: Path, out_path: Path) -> None:
    stock = stock_path.read_bytes()
    patched = patched_path.read_bytes()

    _s_start, _s_cd, stock_block = get_signing_block(stock)
    p_start, p_cd, _patched_block = get_signing_block(patched)

    stock_cert = first_v2_cert_sha256(stock_block)
    if not stock_cert:
        raise ApkError("Stock APK does not contain an APK Signature Scheme v2 certificate")

    # Keep all patched ZIP payload bytes and its central directory, replacing
    # only the APK Signing Block with the stock block.
    suffix = bytearray(patched[p_cd:])
    suffix_eocd = find_eocd(bytes(suffix))

    new_cd_off = p_start + len(stock_block)
    struct.pack_into("<I", suffix, suffix_eocd + 16, new_cd_off)

    out = patched[:p_start] + stock_block + bytes(suffix)

    # Structural verification of the rebuilt APK.
    _o_start, _o_cd, out_block = get_signing_block(out)
    out_cert = first_v2_cert_sha256(out_block)
    if out_cert != stock_cert:
        raise ApkError("Signer certificate metadata mismatch after transplant")

    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_bytes(out)

    print(f"[Morphe] Stock signer cert SHA-256: {stock_cert}")
    print(f"[Morphe] Stock signing block bytes: {len(stock_block)}")
    print(f"[Morphe] Patched APK bytes: {len(patched)} -> {len(out)}")
    print("[Morphe] Stock APK Signing Block transplanted successfully")
    print("[Morphe] NOTE: cryptographic signature digest is intentionally not valid for patched contents")


def main() -> int:
    if len(sys.argv) != 4:
        print(
            f"Usage: {Path(sys.argv[0]).name} STOCK_BASE_APK PATCHED_BASE_APK OUTPUT_APK",
            file=sys.stderr,
        )
        return 2

    try:
        transplant(Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3]))
    except (OSError, ApkError, struct.error) as exc:
        print(f"[Morphe][ERROR] {exc}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
