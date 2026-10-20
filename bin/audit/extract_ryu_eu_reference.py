#!/usr/bin/env python3
"""Extract original RYU EU framework JARs, APKs and build.props without patching."""
from __future__ import annotations
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path

from audit_xiaomi_eu_apps import (
    call, collect_props_erofs, filesystem, make_super, read_partition_names,
)

PARTITIONS = ("system", "system_ext", "product", "mi_ext", "mi_product",
              "vendor", "odm", "system_dlkm", "vendor_dlkm", "odm_dlkm", "product_dlkm")
FRAMEWORK = {
    "framework.jar": ("system", True),
    "services.jar": ("system", True),
    "miui-framework.jar": ("system_ext", True),
    "miui-services.jar": ("system_ext", True),
    "miui-telephony-common.jar": ("system_ext", False),
    "miui-core.jar": ("system_ext", False),
    "miui-ext.jar": ("system_ext", False),
    "framework-ext.jar": ("system", False),
}
APPS = {"SecurityCenter": "securitycenter.apk", "PowerKeeper": "powerkeeper.apk"}
APP_PARTS = {"product", "system", "system_ext", "mi_ext", "mi_product"}
APP_DIRS = {"SecurityCenter": ("SecurityCenter", "MIUISecurityCenter"),
            "PowerKeeper": ("PowerKeeper", "MIUIPowerKeeper", "PowerKeeperT")}
PROP_PREFIXES = ("", "system", "system/system", "product", "system_ext",
                 "mi_ext", "mi_product", "vendor", "odm", "system_dlkm",
                 "vendor_dlkm", "odm_dlkm", "product_dlkm")


def sha256(path):
    with path.open("rb") as f:
        return hashlib.file_digest(f, "sha256").hexdigest()


def save_file(src, output, group, part, rel, entries):
    if not src.is_file() or src.is_symlink() or src.stat().st_size == 0:
        raise RuntimeError("Not a nonempty regular source file: " + str(src))
    if group in ("framework", "apps"):
        if not zipfile.is_zipfile(src):
            raise RuntimeError("Invalid ZIP/JAR/APK: " + str(src))
        with zipfile.ZipFile(src) as z:
            if z.testzip() is not None:
                raise RuntimeError("Corrupted APK/JAR: " + str(src))
            if group == "apps" and "AndroidManifest.xml" not in z.namelist():
                raise RuntimeError("APK lacks AndroidManifest.xml: " + str(src))
    dest = output / group / part / rel
    if dest.exists():
        raise RuntimeError("Duplicate output path: " + str(dest))
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(src, dest)
    item = {"category": group, "partition": part,
            "original_path": "/" + rel.as_posix(),
            "file": dest.relative_to(output).as_posix(),
            "bytes": dest.stat().st_size, "sha256": sha256(dest)}
    entries.append(item)
    print("[EXTRACT]", part, item["original_path"], "->", item["file"], flush=True)


def framework_paths(name):
    return tuple(Path(prefix) / "framework" / name for prefix in
                 ("", "system", "system/system", "system_ext"))


def scan_tree(root, part, output, entries):
    for name, (expected, _) in FRAMEWORK.items():
        if expected != part:
            continue
        matches = [rel for rel in framework_paths(name)
                   if (root / rel).is_file() and not (root / rel).is_symlink()]
        if len(matches) > 1:
            raise RuntimeError("Ambiguous framework JAR: " + name + " " + str(matches))
        if matches:
            save_file(root / matches[0], output, "framework", part, matches[0], entries)
    if part in APP_PARTS:
        for path in root.rglob("*.apk"):
            if not path.is_file() or path.is_symlink():
                continue
            if path.name.lower() not in APPS.values():
                continue
            rel = path.relative_to(root)
            if any(x in ("app", "priv-app") for x in rel.parts[:-1]):
                save_file(path, output, "apps", part, rel, entries)
    for prop in collect_props_erofs(root, part, output):
        path = output / prop["output_path"]
        entries.append({"category": "build-props", "partition": part,
                        "original_path": prop["source_path"],
                        "file": prop["output_path"],
                        "bytes": path.stat().st_size, "sha256": sha256(path)})


def has_ext4_file(image, name):
    result = subprocess.run(["debugfs", "-R", "stat " + name, str(image)],
                            text=True, capture_output=True, check=False)
    return "Inode:" in result.stdout and "Type: regular" in result.stdout


def dump_ext4(image, name, scratch):
    dest = scratch / name.lstrip("/")
    dest.parent.mkdir(parents=True, exist_ok=True)
    call("debugfs", "-R", "dump -p " + name + " " + str(dest), image)
    if not dest.is_file() or dest.stat().st_size == 0:
        raise RuntimeError("Failed to extract ext4 file: " + name)
    return dest


def scan_ext4(image, part, output, scratch, entries):
    for name, (expected, _) in FRAMEWORK.items():
        if expected != part:
            continue
        hits = [rel for rel in framework_paths(name)
                if has_ext4_file(image, "/" + rel.as_posix())]
        if len(hits) > 1:
            raise RuntimeError("Ambiguous ext4 framework path: " + name)
        if hits:
            rel = hits[0]
            save_file(dump_ext4(image, "/" + rel.as_posix(), scratch),
                      output, "framework", part, rel, entries)
    if part in APP_PARTS:
        for label, folders in APP_DIRS.items():
            hits = []
            for prefix in ("", part, "system", "system/system"):
                for kind in ("app", "priv-app"):
                    for folder in folders:
                        rel = Path(prefix) / kind / folder / (label + ".apk")
                        if has_ext4_file(image, "/" + rel.as_posix()):
                            hits.append(rel)
            if len(hits) > 1:
                raise RuntimeError("Ambiguous ext4 APK: " + label)
            if hits:
                rel = hits[0]
                save_file(dump_ext4(image, "/" + rel.as_posix(), scratch),
                          output, "apps", part, rel, entries)
    candidates = {"/" + (Path(prefix) / inner / "build.prop").as_posix()
                  for prefix in PROP_PREFIXES for inner in ("", "etc")}
    for name in sorted(candidates):
        if has_ext4_file(image, name):
            rel = Path(name.lstrip("/"))
            save_file(dump_ext4(image, name, scratch), output,
                      "build-props", part, rel, entries)


def scan_image(image, part, output, scratch, entries):
    kind = filesystem(image)
    print("[PARTITION]", part, kind, flush=True)
    if kind == "erofs":
        tree = scratch / "erofs"
        tree.mkdir(parents=True, exist_ok=True)
        call("fsck.erofs", "--extract=" + str(tree), image)
        scan_tree(tree, part, output, entries)
    else:
        scan_ext4(image, part, output, scratch, entries)


def extract_fastboot(rom, work, output, lpunpack, entries):
    super_image = make_super(rom, work)
    names = read_partition_names(super_image, lpunpack)
    scanned = []
    try:
        for part in PARTITIONS:
            selected = next((p for p in (part + "_a", part, part + "_b")
                             if p in names), None)
            if not selected:
                continue
            stage = work / "partition"
            stage.mkdir(exist_ok=True)
            scratch = work / "scratch"
            try:
                call(sys.executable, lpunpack, "-p", selected, super_image, stage)
                image = stage / (selected + ".img")
                if not image.is_file() or image.stat().st_size == 0:
                    raise RuntimeError("Missing extracted logical partition: " + selected)
                scan_image(image, part, output, scratch, entries)
                scanned.append(selected)
            finally:
                shutil.rmtree(stage, ignore_errors=True)
                shutil.rmtree(scratch, ignore_errors=True)
    finally:
        super_image.unlink(missing_ok=True)
    return scanned


def extract_fallback(rom, work, output, entries):
    # The existing read-only dump tool understands payload.bin and .new.dat.br.
    stage = work / "fallback"
    call("bash", "bin/dump/extract.sh", rom, stage, "full")
    rom.unlink(missing_ok=True)
    scanned = []
    for part in PARTITIONS:
        root = stage / "images" / part
        if root.is_dir():
            scan_tree(root, part, output, entries)
            scanned.append(part)
            shutil.rmtree(root)
    shutil.rmtree(stage, ignore_errors=True)
    return scanned


def main(rom, work, lpunpack):
    output = work / "output"
    output.mkdir(parents=True, exist_ok=True)
    source_zip = rom.name
    with zipfile.ZipFile(rom) as z:
        members = [info.filename for info in z.infolist() if not info.is_dir()]
    if len(members) != len(set(members)):
        raise RuntimeError("Duplicate filenames inside ROM ZIP")
    for name in members:
        if name.startswith("/") or "\\" in name or ".." in Path(name).parts:
            raise RuntimeError("Unsafe ROM ZIP member: " + name)
    (output / "archive-layout.txt").write_text("\n".join(members) + "\n")
    fastboot = any(re.fullmatch(r"(?:.*/)?super\.img(?:\.\d+)?", n)
                   for n in members)
    print("[ROM] Layout:", "super.img" if fastboot else "alternate", flush=True)
    entries = []
    scanned = (extract_fastboot(rom, work, output, lpunpack, entries) if fastboot
               else extract_fallback(rom, work, output, entries))
    missing = [name for name, (_, needed) in FRAMEWORK.items() if needed
               and not any(item["category"] == "framework"
                           and Path(item["file"]).name == name for item in entries)]
    for label, filename in APPS.items():
        hits = [e for e in entries if e["category"] == "apps"
                and Path(e["file"]).name.lower() == filename]
        if len(hits) != 1:
            missing.append(label + ".apk (found " + str(len(hits)) + ")")
    if not any(e["category"] == "build-props" for e in entries):
        missing.append("build.prop")
    items = sorted(entries, key=lambda e: e["file"])
    manifest = {"source_zip": source_zip, "source_url": os.environ.get("ROM_URL", ""),
                "preserved_unmodified": True,
                "partitions_scanned": scanned, "missing_required": missing,
                "files": items}
    (output / "ryu-reference-manifest.json").write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False) + "\n")
    (output / "SHA256SUMS.txt").write_text(
        "".join(e["sha256"] + "  " + e["file"] + "\n" for e in items))
    lines = ["# Original RYU-EU ROM reference", "",
             "- Source URL: " + os.environ.get("ROM_URL", ""),
             "- Downloaded ZIP: " + source_zip,
             "- Scanned partitions: " + ", ".join(scanned),
             "- Files copied: " + str(len(items)),
             "- Status: " + ("INCOMPLETE" if missing else "PASS"),
             "- Read-only copies; no patching or re-signing", "",
             "## Extracted files", "",
             "| Type | Source path | Bytes |",
             "| --- | --- | ---: |"]
    lines += ["| " + e["category"] + " | " + e["partition"] + ":" +
              e["original_path"] + " | " + str(e["bytes"]) + " |" for e in items]
    if missing:
        lines += ["", "## Missing required files", ""] + ["- " + v for v in missing]
    (output / "report.md").write_text("\n".join(lines) + "\n")
    print("\n".join(lines), flush=True)
    if missing:
        raise RuntimeError("Missing required references: " + ", ".join(missing))


if __name__ == "__main__":
    if len(sys.argv) != 4:
        raise SystemExit("Usage: extract_ryu_eu_reference.py ROM.zip WORKDIR bin/lpunpack.py")
    try:
        main(Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve(),
             Path(sys.argv[3]).resolve())
    except (OSError, ValueError, RuntimeError, zipfile.BadZipFile,
            subprocess.CalledProcessError) as exc:
        raise SystemExit("[RYU EXTRACT ERROR] " + str(exc))
