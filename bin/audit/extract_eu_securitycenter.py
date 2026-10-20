#!/usr/bin/env python3
"""Extract the unmodified SecurityCenter.apk from a Xiaomi.eu fastboot ROM.

Reuses the tested sparse-super and liblp readers from audit_xiaomi_eu_apps.py.
Does not patch, re-sign, install, or otherwise change the APK.
"""
import hashlib
import json
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path

from audit_xiaomi_eu_apps import call, filesystem, make_super, read_partition_names

# Xiaomi SecurityCenter normally lives in product/priv-app, but scan fallback
# partitions if its layout changes. The first partition with one exact match wins.
PARTITIONS = ("product", "system_ext", "mi_ext", "system")
APP_DIRS = ("app", "priv-app")
CONTAINER_DIRS = ("SecurityCenter", "MIUISecurityCenter")


def valid_apk(path):
    if not path.is_file() or path.is_symlink() or path.stat().st_size < 100_000:
        return False
    if not zipfile.is_zipfile(path):
        return False
    with zipfile.ZipFile(path) as archive:
        return "AndroidManifest.xml" in archive.namelist() and archive.testzip() is None


def find_erofs(image, scratch):
    root = scratch / "erofs"
    root.mkdir(parents=True, exist_ok=True)
    call("fsck.erofs", "--extract=" + str(root), image)
    found = []
    for path in root.rglob("*"):
        if path.name.lower() != "securitycenter.apk" or path.is_symlink():
            continue
        relative = path.relative_to(root)
        if not any(p in APP_DIRS for p in relative.parts[:-1]):
            continue
        if path.is_file():
            found.append(("/" + relative.as_posix(), path))
    return found


def find_ext4(image, scratch):
    # Probe common partition-relative Android app layouts without mounting ext4.
    found = []
    for prefix in ("", "/product", "/system", "/system_ext", "/mi_ext"):
        for kind in APP_DIRS:
            for container in CONTAINER_DIRS:
                relative = f"{prefix}/{kind}/{container}/SecurityCenter.apk"
                info = subprocess.run(
                    ["debugfs", "-R", "stat " + relative, str(image)],
                    capture_output=True, text=True, check=False
                )
                if "Inode:" not in info.stdout or "Type: regular" not in info.stdout:
                    continue
                dest = scratch / "ext4" / relative.lstrip("/")
                dest.parent.mkdir(parents=True, exist_ok=True)
                call("debugfs", "-R", "dump -p " + relative + " " + str(dest), image)
                if not dest.is_file():
                    raise RuntimeError("debugfs failed to extract " + relative)
                found.append((relative, dest))
    return found


def extract(rom, work, lpunpack):
    output = work / "output"
    output.mkdir(parents=True, exist_ok=True)
    original_archive_name = rom.name
    super_image = make_super(rom, work)
    available = read_partition_names(super_image, lpunpack)
    checked = []

    for partition in PARTITIONS:
        selected = next((candidate for candidate in
                         (partition + "_a", partition, partition + "_b")
                         if candidate in available), None)
        if not selected:
            continue
        checked.append(selected)
        extracted = work / "partition"
        extracted.mkdir(exist_ok=True)
        call(sys.executable, lpunpack, "-p", selected, super_image, extracted)
        image = extracted / (selected + ".img")
        if not image.is_file():
            raise RuntimeError("Missing extracted partition " + selected)
        scratch = work / "scratch"
        try:
            kind = filesystem(image)
            matches = (find_erofs(image, scratch) if kind == "erofs"
                       else find_ext4(image, scratch))
            if len(matches) > 1:
                raise RuntimeError(
                    "Multiple SecurityCenter.apk matches in " + selected +
                    ": " + ", ".join(source for source, _ in matches)
                )
            if not matches:
                continue
            source, apk = matches[0]
            if not valid_apk(apk):
                raise RuntimeError("SecurityCenter candidate is not a valid APK: " + source)
            final_apk = output / "SecurityCenter.apk"
            shutil.copyfile(apk, final_apk)
            with final_apk.open("rb") as f:
                sha256 = hashlib.file_digest(f, "sha256").hexdigest()
            manifest = {
                "source_archive": original_archive_name,
                "source_partition": selected,
                "source_path": source,
                "filesystem": kind,
                "apk_name": final_apk.name,
                "bytes": final_apk.stat().st_size,
                "sha256": sha256,
                "checked_partitions": checked,
                "changed_or_resigned": False,
            }
            (output / "securitycenter-manifest.json").write_text(
                json.dumps(manifest, indent=2, ensure_ascii=False) + "\n"
            )
            (output / "securitycenter-report.md").write_text(
                "# Original Xiaomi.eu SecurityCenter\n\n"
                f"- Source ZIP: `{original_archive_name}`\n"
                f"- Partition: `{selected}` (`{kind}`)\n"
                f"- Original path: `{source}`\n"
                f"- APK size: **{final_apk.stat().st_size:,} bytes**\n"
                f"- SHA-256: `{sha256}`\n"
                "- The APK is copied byte-for-byte; it is not patched or re-signed.\n"
            )
            print(f"[OK] Extracted original {selected}:{source}", flush=True)
            print(f"[SHA256] {sha256}", flush=True)
            return
        finally:
            shutil.rmtree(scratch, ignore_errors=True)
            image.unlink(missing_ok=True)

    raise RuntimeError(
        "SecurityCenter.apk not found in scanned partitions: " +
        ", ".join(checked)
    )


if __name__ == "__main__":
    if len(sys.argv) != 4:
        raise SystemExit(
            "Usage: extract_eu_securitycenter.py ROM.zip WORKDIR bin/lpunpack.py"
        )
    try:
        extract(Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3]).resolve())
    except (OSError, ValueError, RuntimeError, zipfile.BadZipFile,
            subprocess.CalledProcessError) as error:
        raise SystemExit("[EXTRACT ERROR] " + str(error))
