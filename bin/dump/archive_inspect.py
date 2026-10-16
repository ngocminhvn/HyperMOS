#!/usr/bin/env python3
"""Read-only inspection of ROM ZIP members (without executing any installer)."""
import json
import struct
import zipfile
from pathlib import Path, PurePosixPath

LP_GEOMETRY = struct.pack("<I", 0x616C4467)
EROFS = struct.pack("<I", 0xE0F5E1E2)


def format_mib(size):
    return round(size / (1024 * 1024), 2)


def classify(header):
    """Identify actual image/container magic; do not trust an .img filename."""
    if header.startswith(b"Salted__"):
        return "encrypted-openssl-salted"
    if header.startswith(b"\x3a\xff\x26\xed"):
        return "android-sparse"
    if header[4096:4100] == LP_GEOMETRY:
        return "android-super-raw"
    if header[1024:1028] == EROFS:
        return "erofs"
    if header[1080:1082] == b"\x53\xef":
        return "ext4"
    if header.startswith(b"CrAU"):
        return "android-payload"
    if header.startswith(b"PK\x03\x04"):
        return "zip"
    if header.startswith(b"\x7fELF"):
        return "elf-executable"
    if header.startswith(b"#!"):
        return "shell-or-script"
    return "unknown"


def inspect_archive(archive, zip_path, work):
    """Persist a small, useful inventory even if dumping fails later."""
    work.mkdir(parents=True, exist_ok=True)
    infos = [i for i in archive.infolist() if not i.is_dir()]
    size_total = zip_path.stat().st_size
    rows = []
    for info in infos:
        member = PurePosixPath(info.filename)
        # Probing selected executables/images is safe: read only 8192 bytes.
        wanted = (
            member.suffix.lower() in {".img", ".bin", ".zst", ".lz4", ".gz"}
            or member.name in {"update-binary", "updater-script"}
            or info.file_size > 128 * 1024 * 1024
        )
        head = archive.open(info).read(8192) if wanted else b""
        row = {
            "name": info.filename,
            "size_bytes": info.file_size,
            "compressed_bytes": info.compress_size,
            "kind": classify(head) if wanted else "not-probed",
            "header_hex": head[:16].hex() if wanted else "",
        }
        rows.append(row)
    rows.sort(key=lambda x: x["size_bytes"], reverse=True)
    container = {
        "archive_size_bytes": size_total,
        "members": len(infos),
        "total_member_compressed_bytes": sum(i.compress_size for i in infos),
        "approximate_container_overhead_bytes": max(
            0, size_total - sum(i.compress_size for i in infos)
        ),
        "entries": rows,
    }
    (work / "zip-layout.json").write_text(
        json.dumps(container, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    log = [
        f"Archive size: {format_mib(size_total)} MiB; members: {len(infos)}",
        f"Compressed members total: {format_mib(container['total_member_compressed_bytes'])} MiB",
        "Largest 20 entries (uncompressed MiB | ZIP-compressed MiB | kind | path):",
    ]
    for row in rows[:20]:
        log.append(
            f"  {format_mib(row['size_bytes']):>9.2f} | "
            f"{format_mib(row['compressed_bytes']):>9.2f} | "
            f"{row['kind']:<20s} | {row['name']}"
        )
    (work / "zip-layout.txt").write_text("\n".join(log) + "\n", encoding="utf-8")
    for line in log:
        print("[ZIP-INSPECT]", line, flush=True)

    # Installer source can explain where an apparently missing system is stored.
    for info in infos:
        if PurePosixPath(info.filename).name != "updater-script":
            continue
        if info.file_size > 128 * 1024:
            continue
        with archive.open(info) as f:
            source = f.read(128 * 1024)
        (work / "updater-script.txt").write_text(
            source.decode("utf-8", errors="replace"), encoding="utf-8"
        )
        break
    return container
