#!/usr/bin/env python3
"""Identify and verify the EXACT ColorOS OS3 files in full EROFS partitions.

For offline GitHub Actions only. This script does not build images or flash phones.
"""
import argparse
import hashlib
import json
import re
import shutil
import stat
import subprocess
import tempfile
import zipfile
from pathlib import Path, PurePosixPath

SUPPORTED = {"product", "system_ext", "system"}
PACKAGE = "miui.systemui.plugin"
OS3_RE = re.compile(r"(^|[/_.-])(?:hyper)?os3([/_.-]|$)", re.I)
OS4_RE = re.compile(r"(^|[/_.-])(?:hyper)?os4([/_.-]|$)", re.I)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def validated_entries(archive):
    entries = archive.infolist()
    if len(entries) > 5000 or not entries:
        raise ValueError("Unsupported module ZIP entry count")
    known = set()
    for entry in entries:
        name = entry.filename
        if (not name or name in known or name.startswith("/")
                or "\\" in name or ".." in PurePosixPath(name).parts
                or stat.S_IFMT(entry.external_attr >> 16) == stat.S_IFLNK):
            raise ValueError("Unsafe or repeated ZIP member: " + name)
        known.add(name)
    corrupt = archive.testzip()
    if corrupt:
        raise ValueError("Corrupt ZIP entry: " + corrupt)
    return entries


def map_path(rel):
    parts = PurePosixPath(rel).parts
    if not parts:
        return None
    if parts[0] in ("product", "system_ext"):
        if len(parts) < 2:
            return None
        return parts[0], "/".join(parts[1:])
    if parts[0] == "system":
        if len(parts) < 2:
            return None
        return "system", "/".join(parts[1:])
    if parts[0] in ("vendor", "odm", "mi_ext", "mi_product",
                    "vendor_dlkm", "product_dlkm", "system_dlkm", "odm_dlkm"):
        raise ValueError("Unexpected non-framework ColorOS partition: " + rel)
    return "system", rel


def select_apk(archive, entries):
    matches = []
    with tempfile.TemporaryDirectory(prefix="coloros-os3-") as temp:
        for i, entry in enumerate(entries):
            if entry.is_dir() or not entry.filename.lower().endswith(".apk"):
                continue
            dst = Path(temp) / (str(i) + ".apk")
            dst.write_bytes(archive.read(entry))
            result = subprocess.run(["aapt", "dump", "badging", str(dst)],
                                    text=True, stdout=subprocess.PIPE,
                                    stderr=subprocess.PIPE)
            if result.returncode:
                raise ValueError("Cannot inspect APK: " + entry.filename)
            match = re.search(r"^package: name='([^']+)'", result.stdout, re.M)
            if match and match.group(1) == PACKAGE:
                matches.append(entry.filename)
    if not matches:
        raise ValueError("No ColorOS miui.systemui.plugin APK in module ZIP")
    if len(matches) == 1:
        selected = matches[0]
        if OS4_RE.search(selected):
            raise ValueError("Only OS4 APK in release; unsafe for OS3")
        return selected
    os3 = [name for name in matches
           if OS3_RE.search(name) and not OS4_RE.search(name)]
    if len(os3) != 1:
        raise ValueError("Ambiguous ColorOS OS3 selection: " + repr(matches))
    return os3[0]


def create_plan(modzip, out):
    with zipfile.ZipFile(modzip) as archive:
        entries = validated_entries(archive)
        apk = select_apk(archive, entries)
        parts = PurePosixPath(apk).parts
        if "system" not in parts:
            raise ValueError("Selected OS3 APK is outside a system/ tree; cannot safely map partitions")
        idx = parts.index("system")
        prefix = "/".join(parts[:idx + 1]) + "/"
        files = []
        for entry in entries:
            if entry.is_dir() or not entry.filename.startswith(prefix):
                continue
            rel = entry.filename[len(prefix):]
            mapped = map_path(rel)
            if not mapped:
                continue
            partition, inside = mapped
            if partition not in SUPPORTED:
                raise ValueError("Unsupported destination " + partition)
            files.append({"member": entry.filename, "partition": partition,
                          "path": inside, "sha256": digest(archive.read(entry)),
                          "bytes": entry.file_size})
        apk_file = next((x for x in files if x["member"] == apk), None)
        if apk_file is None:
            raise ValueError("Selected APK is not in mapped ColorOS tree")
        if len({(f["partition"], f["path"]) for f in files}) != len(files):
            raise ValueError("ColorOS system tree contains ambiguous destination files")
        plan = {"mod_zip": modzip.name, "selected_os3_apk": apk,
                "selected_os3_apk_sha256": apk_file["sha256"],
                "selected_apk_partition": apk_file["partition"],
                "partitions": sorted({x["partition"] for x in files}),
                "files": files, "note": "Entire partition images will overwrite more than this payload"}
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(json.dumps(plan, indent=2) + "\n", encoding="utf-8")
        print("Selected ColorOS OS3:", apk, flush=True)
        print("Required partitions:", ", ".join(plan["partitions"]), flush=True)
        print("Source ZIP:", modzip.name, flush=True)
        for file in files:
            print("  ", file["partition"] + "/" + file["path"], flush=True)


def copy_verified_images(plan_file, images, output):
    plan = json.loads(plan_file.read_text(encoding="utf-8"))
    output.mkdir(parents=True, exist_ok=True)
    found = {}
    for part in plan["partitions"]:
        candidates = [p for p in (images / (part + ".img"),
                                  images / (part + "_a.img"))
                      if p.exists()]
        if len(candidates) != 1:
            raise ValueError("Expected one image for " + part + "; found " +
                             repr([p.name for p in candidates]))
        img = candidates[0]
        with img.open("rb") as inp:
            inp.seek(1024)
            if inp.read(4) != b"\xe2\xe1\xf5\xe0":
                raise ValueError("Non-EROFS image (do not flash): " + img.name)
        with tempfile.TemporaryDirectory(prefix="coloros-verify-") as temp:
            root = Path(temp) / "root"
            root.mkdir()
            subprocess.run(["fsck.erofs", "--extract=" + str(root), str(img)],
                           check=True)
            for entry in [f for f in plan["files"] if f["partition"] == part]:
                target = root / entry["path"]
                if not target.is_file():
                    raise ValueError("Updated ColorOS file absent from image: " +
                                     part + "/" + entry["path"])
                if digest(target.read_bytes()) != entry["sha256"]:
                    raise ValueError("ColorOS file DOES NOT match repository snapshot: " +
                                     part + "/" + entry["path"])
                print("[VERIFIED]", part + "/" + entry["path"], flush=True)
        dst = output / (part + ".img")
        shutil.copyfile(img, dst)
        with dst.open("rb") as src:
            h = hashlib.sha256()
            for block in iter(lambda: src.read(8 * 1024 * 1024), b""):
                h.update(block)
        found[part] = {"source_partition": img.stem, "image": dst.name,
                       "bytes": dst.stat().st_size, "sha256": h.hexdigest()}
    (output / "SHA256SUMS.txt").write_text(
        "".join(f"{found[p]['sha256']}  {found[p]['image']}\n"
                for p in sorted(found)), encoding="utf-8")
    plan["output_images"] = found
    plan["flashing_performed"] = False
    plan["flash_warning"] = (
        "Full logical partition images, NOT an APK-only update. Flashing onto "
        "HyperMOS #156 replaces ALL files in each image, including unrelated "
        "framework or application changes. Have the corresponding #156 images "
        "and a tested recovery route before flashing.")
    (output / "coloros-extract-manifest.json").write_text(
        json.dumps(plan, indent=2) + "\n", encoding="utf-8")
    (output / "README.txt").write_text(
        "ColorOS OS3 from the current repository release snapshot.\n"
        "The selected APK and EVERY module system-tree file were verified in\n"
        "these EROFS partition images; this is not proof of #156 compatibility.\n"
        "These are FULL partition images, not selective APK updates.\n"
        "Do not use fastboot flash without checking HAOTIAN, slot, fastbootd,\n"
        "bootloader unlock, per-partition sizes, AVB, and #156 rollback images.\n"
        "The workflow does not flash the phone or wipe user data.\n",
        encoding="utf-8")
    print(json.dumps(found, indent=2), flush=True)


def main():
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest="cmd", required=True)
    plan = sub.add_parser("plan")
    plan.add_argument("--modzip", type=Path, required=True)
    plan.add_argument("--output", type=Path, required=True)
    verify = sub.add_parser("verify")
    verify.add_argument("--plan", type=Path, required=True)
    verify.add_argument("--images", type=Path, required=True)
    verify.add_argument("--output", type=Path, required=True)
    a = p.parse_args()
    if a.cmd == "plan":
        create_plan(a.modzip, a.output)
    else:
        copy_verified_images(a.plan, a.images, a.output)


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, zipfile.BadZipFile,
            subprocess.CalledProcessError) as e:
        raise SystemExit("[COLOROS V4 EXTRACT] FAIL: " + str(e))
