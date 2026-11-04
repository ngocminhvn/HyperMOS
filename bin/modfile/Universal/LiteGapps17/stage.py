#!/usr/bin/env python3
"""Extract verified LiteGapps Android 17 Core and addons into HyperMOS images.

Do not execute upstream Magisk/recovery installers. Reject mismatched hashes
and unexpected staging layouts instead of silently injecting Android 16 APKs.
"""
import argparse
import hashlib
import json
import re
import shutil
import sys
import tarfile
import tempfile
import time
import urllib.request
import zipfile
from pathlib import Path, PurePosixPath

BASE = Path(__file__).resolve().parent
SAFE_SUBDIRS = {"app", "priv-app", "etc", "framework", "overlay"}
SOURCE = "https://sourceforge.net/projects/litegapps/files/"


def fail(message):
    raise RuntimeError(message)


def digest(path):
    h = hashlib.sha256()
    with path.open("rb") as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def download(entry, cache):
    url = entry["url"]
    expected = entry["sha256"].lower()
    if not url.startswith(SOURCE) or not re.fullmatch(r"[a-f0-9]{64}", expected):
        fail("Untrusted URL or invalid SHA256 in pinned manifest")
    name = PurePosixPath(url.split("/download")[0]).name
    if not re.fullmatch(r"[A-Za-z0-9_.-]+[.]zip", name):
        fail("Unsafe archive name: " + name)
    dest = cache / name
    if dest.is_file() and digest(dest) == expected:
        print("[CACHE]", name)
        return dest
    dest.unlink(missing_ok=True)
    for attempt in range(3):
        tmp = dest.with_suffix(".part")
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "HyperMOS-LiteGapps17/1.0"})
            with urllib.request.urlopen(req, timeout=180) as resp, tmp.open("wb") as out:
                while True:
                    chunk = resp.read(1024 * 1024)
                    if not chunk:
                        break
                    out.write(chunk)
            if digest(tmp) != expected:
                fail("SHA256 mismatch: " + name)
            if not zipfile.is_zipfile(tmp):
                fail("Source is not a ZIP: " + name)
            tmp.replace(dest)
            return dest
        except (OSError, RuntimeError, ValueError) as exc:
            tmp.unlink(missing_ok=True)
            if attempt == 2 or "SHA256 mismatch" in str(exc):
                raise
            time.sleep(2 * (attempt + 1))
    fail("Failed downloading: " + name)


def target_path(filename):
    # Never extract with ZipFile.extractall() / TarFile.extractall().
    path = PurePosixPath(filename)
    parts = path.parts
    if not parts or path.is_absolute() or ".." in parts or "\\" in filename:
        fail("Unsafe archive member: " + filename)
    if parts[:2] == ("arm64", "37"):
        parts = parts[2:]
    if parts[:1] == ("system",):
        if len(parts) >= 4 and parts[1] == "etc" and parts[2] in ("permissions", "sysconfig"):
            return Path("system/system", *parts[1:])
        parts = parts[1:]
    if len(parts) < 3:
        return None
    if parts[0] in ("product", "system_ext") and parts[1] in SAFE_SUBDIRS:
        return Path(*parts)
    if parts[0] == "system" and parts[1] == "etc" and len(parts) >= 4 and parts[2] in ("permissions", "sysconfig"):
        return Path("system/system", *parts[1:])
    return None


def copy_member(source, name, size, staging):
    relative = target_path(name)
    if relative is None:
        return None
    if not 0 < size <= 512 * 1024 * 1024:
        fail("Empty or oversized file: " + name)
    destination = staging / relative
    destination.parent.mkdir(parents=True, exist_ok=True)
    with destination.open("wb") as output:
        shutil.copyfileobj(source, output, length=1024 * 1024)
    if destination.stat().st_size != size:
        fail("Short read: " + name)
    destination.chmod(0o644)
    return relative.as_posix()


def unpack_tar(stream, staging):
    extracted = []
    with tarfile.open(fileobj=stream, mode="r|*") as archive:
        for member in archive:
            if member.isdir():
                continue
            if not member.isfile():
                # Never turn upstream symlinks/devices into partition files.
                continue
            handle = archive.extractfile(member)
            if handle is None:
                fail("Invalid tar member: " + member.name)
            with handle:
                relative = copy_member(handle, member.name, member.size, staging)
                if relative:
                    extracted.append(relative)
    return extracted


def unpack_zip(path, staging, core=False):
    extracted = []
    with zipfile.ZipFile(path) as archive:
        bad = archive.testzip()
        if bad:
            fail("Corrupted ZIP member in " + path.name + ": " + bad)
        for member in archive.infolist():
            if member.is_dir():
                continue
            # Do not turn ZIP symlinks into regular partition files.
            if (member.external_attr >> 16) & 0o170000 == 0o120000:
                continue
            name = member.filename
            if core and re.fullmatch(r"(?:files/)?files[.]tar[.](?:xz|gz|bz2)", name):
                with archive.open(member) as stream:
                    extracted.extend(unpack_tar(stream, staging))
                continue
            # Standalone addons provide their payload under system/.
            # Do not execute installer scripts or recursively run modules/.
            with archive.open(member) as stream:
                relative = copy_member(stream, name, member.file_size, staging)
                if relative:
                    extracted.append(relative)
    if not extracted:
        fail("No usable product/system_ext payload in " + path.name)
    return extracted


def validate(staging):
    files = [p for p in staging.rglob("*") if p.is_file()]
    apks = [p for p in files if p.suffix.lower() == ".apk"]
    if len(apks) < 6:
        fail("A17 payload has too few APK files")
    for path in apks:
        if path.stat().st_size < 1024 or not zipfile.is_zipfile(path):
            fail("Invalid APK or Git LFS pointer: " + str(path))
    names = [path.as_posix().lower() for path in apks]
    mandatory = {
        "GmsCore": ("gmscore",),
        "PlayStore": ("phonesky", "playstore"),
        "GoogleServicesFramework": ("googleservicesframework",),
        "GoogleKeyboard": ("latinimegoogle", "googlekeyboard"),
        "Gmail": ("gmail",),
        "GoogleSearch": ("velvet", "googlesearch"),
        "Maps": ("/maps/", "maps.apk"),
    }
    for label, alternatives in mandatory.items():
        if not any(any(key in name for key in alternatives) for name in names):
            fail("Missing Android 17 APK component: " + label)
    return files


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", required=True, type=Path)
    args = parser.parse_args()
    root = args.root.resolve()
    images = root / "build/baserom/images"
    if not (images / "product").is_dir() or not (images / "system_ext").is_dir():
        fail("Extracted product/system_ext partitions are missing")
    prop = images / "system/system/build.prop"
    if not prop.is_file():
        fail("System build.prop missing")
    manifest = json.loads((BASE / "sources.json").read_text())
    if (manifest.get("android"), manifest.get("api"), manifest.get("arch")) != (17, 37, "arm64"):
        fail("Wrong LiteGapps manifest target")
    cache = root / "build/cache/litegapps17"
    cache.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="lg17-", dir=root / "build") as directory:
        staging = Path(directory)
        archives = {"Core": unpack_zip(download(manifest["core"], cache), staging, core=True)}
        for addon in manifest["addons"]:
            archives[addon["name"]] = unpack_zip(download(addon, cache), staging)
        files = validate(staging)
        for file in files:
            relative = file.relative_to(staging)
            destination = images / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(file, destination)
        if "ro.miui.has_gmscore=1" not in prop.read_text().splitlines():
            with prop.open("a") as output:
                output.write("\nro.miui.has_gmscore=1\n")
        report = root / "build/reports/litegapps17/staged.json"
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_text(json.dumps({
            "target": "arm64/37", "source_date": manifest["source_date"],
            "archives": {name: len(paths) for name, paths in archives.items()},
            "files": [path.relative_to(staging).as_posix() for path in files],
        }, indent=2) + "\n")
        print("[OK] LiteGapps17:", len(files), "Android 17 files staged")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, RuntimeError, zipfile.BadZipFile, tarfile.TarError) as exc:
        print("[ERROR] LiteGapps17:", exc, file=sys.stderr)
        sys.exit(1)
