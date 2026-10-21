#!/usr/bin/env python3
"""Read-only extraction of three Xiaomi.eu auxiliary APKs from a RYU-EU fastboot ROM."""
from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path

from audit_xiaomi_eu_apps import call, filesystem, make_super, read_partition_names

COMPONENTS = ("XiaomiEUExt", "XiaomiEUInject", "MiuiExtraPhoto")
APP_PARTITIONS = ("product", "system_ext", "system", "mi_ext", "mi_product")


def sha256(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def record_apk(apk: Path, original: Path, part: str, component: str,
               output: Path, entries: list[dict]) -> None:
    if not apk.is_file() or apk.is_symlink() or not apk.stat().st_size:
        raise RuntimeError("Missing, empty, or symlinked APK: " + str(apk))
    with zipfile.ZipFile(apk) as archive:
        if "AndroidManifest.xml" not in archive.namelist():
            raise RuntimeError("APK has no AndroidManifest.xml: " + str(apk))
        corrupt = archive.testzip()
        if corrupt is not None:
            raise RuntimeError("Corrupt APK: " + str(apk) + " / " + corrupt)
    destination = output / "apks" / part / original
    if destination.exists():
        raise RuntimeError("Duplicate APK path: " + str(destination))
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(apk, destination)
    entry = {
        "component": component, "partition": part,
        "original_path": "/" + original.as_posix(),
        "artifact_path": destination.relative_to(output).as_posix(),
        "bytes": destination.stat().st_size, "sha256": sha256(destination),
    }
    entries.append(entry)
    print("[EXTRACT]", component, part + ":" + entry["original_path"],
          "->", entry["artifact_path"], flush=True)


def component_for(relative: Path) -> str | None:
    parts = relative.parts
    if not any(segment in ("app", "priv-app") for segment in parts[:-1]):
        return None
    for component in COMPONENTS:
        if relative.stem.casefold() == component.casefold():
            return component
        for index, segment in enumerate(parts[:-1]):
            if (segment in ("app", "priv-app") and index + 1 < len(parts) - 1
                    and parts[index + 1].casefold() == component.casefold()):
                return component
    return None


def scan_erofs(image: Path, part: str, scratch: Path,
               output: Path, entries: list[dict]) -> None:
    root = scratch / "erofs"
    root.mkdir(parents=True)
    call("fsck.erofs", "--extract=" + str(root), image)
    for apk in sorted(root.rglob("*")):
        if apk.suffix.lower() != ".apk" or not apk.is_file() or apk.is_symlink():
            continue
        relative = apk.relative_to(root)
        component = component_for(relative)
        if component:
            record_apk(apk, relative, part, component, output, entries)


def scan_ext4(image: Path, part: str, scratch: Path,
              output: Path, entries: list[dict]) -> None:
    # Narrow fallback for normal ext4 app paths; RYU-EU OS3 HAOTIAN uses EROFS.
    prefixes = ("", part, "system", "system/system")
    seen = set()
    for prefix in prefixes:
        for kind in ("app", "priv-app"):
            for component in COMPONENTS:
                for rel in (
                    Path(prefix) / kind / component / (component + ".apk"),
                    Path(prefix) / kind / (component + ".apk"),
                ):
                    rel = Path(rel.as_posix().lstrip("/"))
                    if rel in seen:
                        continue
                    seen.add(rel)
                    result = subprocess.run(
                        ["debugfs", "-R", "stat /" + rel.as_posix(), str(image)],
                        capture_output=True, text=True, check=False)
                    if "Inode:" not in result.stdout or "Type: regular" not in result.stdout:
                        continue
                    destination = scratch / "ext4" / rel
                    destination.parent.mkdir(parents=True, exist_ok=True)
                    call("debugfs", "-R",
                         "dump -p /" + rel.as_posix() + " " + str(destination), image)
                    record_apk(destination, rel, part, component, output, entries)


def main(rom: Path, work: Path, lpunpack: Path) -> None:
    output = work / "output"
    output.mkdir(parents=True, exist_ok=True)
    super_image = make_super(rom, work)
    scanned = []
    entries = []
    available = read_partition_names(super_image, lpunpack.resolve())
    try:
        for part in APP_PARTITIONS:
            selected = next((name for name in (part + "_a", part, part + "_b")
                             if name in available), None)
            if not selected:
                continue
            stage = work / "partition"
            scratch = work / "scratch"
            stage.mkdir(exist_ok=True)
            try:
                call(sys.executable, lpunpack, "-p", selected, super_image, stage)
                image = stage / (selected + ".img")
                if not image.is_file() or not image.stat().st_size:
                    raise RuntimeError("Cannot unpack partition: " + selected)
                kind = filesystem(image)
                print("[SCAN]", selected, "filesystem=" + kind, flush=True)
                if kind == "erofs":
                    scan_erofs(image, part, scratch, output, entries)
                elif kind == "ext4":
                    scan_ext4(image, part, scratch, output, entries)
                else:
                    raise RuntimeError("Unsupported filesystem: " + kind)
                scanned.append({"partition": part, "image": selected,
                                "filesystem": kind})
            finally:
                shutil.rmtree(scratch, ignore_errors=True)
                shutil.rmtree(stage, ignore_errors=True)
    finally:
        super_image.unlink(missing_ok=True)

    if not scanned:
        raise RuntimeError("No app-bearing ROM partitions were scanned")

    entries.sort(key=lambda e: (e["component"], e["partition"], e["original_path"]))
    components = {
        name: {"found": any(e["component"] == name for e in entries),
               "files": [e for e in entries if e["component"] == name]}
        for name in COMPONENTS
    }
    manifest = {
        "source_url": os.environ.get("ROM_URL", ""),
        "original_apks_unchanged": True,
        "scanned_partitions": scanned,
        "components": components,
    }
    (output / "ryu-eu-extras-manifest.json").write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    (output / "SHA256SUMS.txt").write_text(
        "".join(e["sha256"] + "  " + e["artifact_path"] + "\n" for e in entries),
        encoding="utf-8")
    report = [
        "# RYU-EU original Xiaomi.eu auxiliary APK check", "",
        "Source: " + os.environ.get("ROM_URL", ""),
        "Partitions scanned: " + ", ".join(x["image"] for x in scanned), "",
        "| Component | Found? | Original partition/path |",
        "| --- | --- | --- |",
    ]
    for name, result in components.items():
        paths = ", ".join(e["partition"] + ":" + e["original_path"]
                          for e in result["files"])
        report.append("| " + name + " | " +
                      ("YES" if result["found"] else "NOT FOUND") +
                      " | " + (paths or "—") + " |")
    report.extend(("", "Original APKs, if present, are in apks/<partition>/...",
                   "SHA-256 hashes and byte sizes are in the manifest.",
                   "NOT FOUND means no matching APK in the scanned application locations.",
                   "No ROM images, APKs, or build.prop values were modified."))
    report_text = "\n".join(report) + "\n"
    (output / "report.md").write_text(report_text, encoding="utf-8")
    print(report_text, flush=True)


if __name__ == "__main__":
    if len(sys.argv) != 4:
        raise SystemExit("Usage: extract_ryu_eu_extras.py ROM.zip WORKDIR bin/lpunpack.py")
    try:
        main(Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve(),
             Path(sys.argv[3]).resolve())
    except (OSError, ValueError, RuntimeError, zipfile.BadZipFile,
            subprocess.CalledProcessError) as exc:
        raise SystemExit("[RYU EXTRAS ERROR] " + str(exc))
