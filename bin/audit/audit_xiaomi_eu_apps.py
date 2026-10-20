#!/usr/bin/env python3
"""Read-only audit: extract Xiaomi.eu extras and original launcher apps from fastboot ZIP."""
import hashlib
import json
import re
import shutil
import struct
import subprocess
import sys
import zipfile
from pathlib import Path

EXTRAS = ("XiaomiEUExt", "XiaomiEUInject", "MiuiExtraPhoto")
LAUNCHERS = ("MiuiHome", "MiuiHomeT", "MiLauncherGlobal", "PocoHome", "PocoLauncher")
ROOTS = ("app", "priv-app", "product/app", "product/priv-app", "system_ext/app",
         "system_ext/priv-app", "system/app", "system/priv-app", "mi_ext/app",
         "mi_ext/priv-app", "mi_product/app", "mi_product/priv-app")


def call(*args, output=False):
    print("[RUN]", " ".join(map(str, args)), flush=True)
    r = subprocess.run([str(x) for x in args], check=True,
                       capture_output=output, text=output)
    return r.stdout if output else ""


def require_space(path, size):
    available = shutil.disk_usage(path).free
    if available < size + 1024**3:
        raise RuntimeError(f"Not enough free disk: {available} bytes; require {size + 1024**3}")


def make_super(rom, work):
    with zipfile.ZipFile(rom) as z:
        members = []
        for m in z.infolist():
            match = re.fullmatch(r"(?:.*/)?super\.img(?:\.(\d+))?", m.filename)
            if match and not m.is_dir():
                members.append((match.group(1), m))
        bare = [m for index, m in members if index is None]
        numbered = sorted((int(index), m) for index, m in members if index is not None)
        if not members or (bool(bare) == bool(numbered)):
            raise RuntimeError("Expected one super.img or ordered super.img.N chunks in a fastboot ZIP")
        if bare:
            if len(bare) != 1:
                raise RuntimeError("Multiple super.img entries")
            chosen = bare
        else:
            if [x for x, _ in numbered] != list(range(len(numbered))):
                raise RuntimeError("Missing or duplicate numbered super.img chunks")
            chosen = [m for _, m in numbered]
        require_space(work, sum(x.file_size for x in chosen))
        parts = []
        for idx, member in enumerate(chosen):
            if member.file_size < 1048576 or member.flag_bits & 1:
                raise RuntimeError("Encrypted or unexpectedly small super image")
            p = work / f"chunk{idx:03d}"
            with z.open(member) as reader, p.open("wb") as writer:
                shutil.copyfileobj(reader, writer, 8 * 1024 * 1024)
            if p.stat().st_size != member.file_size:
                raise RuntimeError("Truncated super chunk")
            parts.append(p)
    rom.unlink()
    raw = work / "super.raw.img"
    with parts[0].open("rb") as f:
        hdr = f.read(28)
    if hdr[:4] == bytes.fromhex("3aff26ed"):
        _, version, _, _, _, blk_size, blocks, _, _ = struct.unpack("<I4H4I", hdr)
        if version != 1 or blk_size < 4096:
            raise RuntimeError("Unexpected Android sparse super header")
        require_space(work, blk_size * blocks)
        call("simg2img", *parts, raw)
        if raw.stat().st_size != blk_size * blocks:
            raise RuntimeError("Expanded super size mismatch")
    elif len(parts) == 1:
        parts[0].rename(raw)
    else:
        raise RuntimeError("Split super must have sparse-image header")
    for p in parts:
        p.unlink(missing_ok=True)
    return raw


def filesystem(image):
    with image.open("rb") as f:
        f.seek(1024)
        if f.read(4) == bytes.fromhex("e2e1f5e0"):
            return "erofs"
        f.seek(1080)
        if f.read(2) == bytes.fromhex("53ef"):
            return "ext4"
    raise RuntimeError("Unsupported image filesystem: " + str(image))


def copy_target(source, output):
    output.parent.mkdir(parents=True, exist_ok=True)
    if source.is_dir():
        shutil.copytree(source, output, dirs_exist_ok=True, symlinks=True)
    elif source.is_file():
        shutil.copy2(source, output, follow_symlinks=False)


def read_apps(image, part, out, scratch):
    found = []
    names = EXTRAS + LAUNCHERS
    kind = filesystem(image)
    if kind == "erofs":
        root = scratch / "erofs"
        root.mkdir(parents=True, exist_ok=True)
        call("fsck.erofs", "--extract=" + str(root), image)
        for p in root.rglob("*"):
            name = p.name.removesuffix(".apk")
            if name not in names or not (p.is_dir() or (p.is_file() and p.suffix == ".apk")):
                continue
            if any(parent.name in names for parent in p.parents if parent != p):
                continue
            relative = p.relative_to(root)
            copy_target(p, out / "files" / part / relative)
            found.append(dict(name=name, partition=part, path="/" + relative.as_posix()))
    else:
        for dirname in ROOTS:
            for name in names:
                for suffix in ("", ".apk"):
                    source_path = "/" + dirname + "/" + name + suffix
                    try:
                        description = call("debugfs", "-R", "stat " + source_path,
                                           image, output=True)
                    except subprocess.CalledProcessError:
                        continue
                    is_dir = "Inode:" in description and "Type: directory" in description
                    is_apk = suffix == ".apk" and "Inode:" in description and "Type: regular" in description
                    if not (is_dir or is_apk):
                        continue
                    stage = scratch / "ext4" / dirname / name
                    stage.mkdir(parents=True, exist_ok=True)
                    if is_dir:
                        call("debugfs", "-R", "rdump " + source_path + " " + str(stage), image)
                        candidates = [p for p in stage.rglob(name) if p.is_dir()]
                        if candidates:
                            source = min(candidates, key=lambda p: len(p.parts))
                        elif any(stage.iterdir()):
                            source = stage
                        else:
                            raise RuntimeError("Failed ext4 directory dump: " + source_path)
                    else:
                        source = stage / (name + ".apk")
                        call("debugfs", "-R", "dump -p " + source_path + " " + str(source), image)
                        if not source.is_file():
                            raise RuntimeError("Failed ext4 file dump: " + source_path)
                    copy_target(source, out / "files" / part / source_path.lstrip("/"))
                    found.append(dict(name=name, partition=part, path=source_path))
    return found


def launcher_deletion_names(path):
    text = path.read_text()
    section = text.split("apply_kashi_launcher() {", 1)[1].split("apply_kashi_launcher ||", 1)[0]
    found = re.findall(r'modscenter_remove_named_dirs\s+"\$OS3_IMAGES"((?:\s*\\\s*\n\s*"[^"]+")+)', section)
    if len(found) != 1:
        raise RuntimeError("Kashi Launcher delete list changed; audit cannot infer it")
    return re.findall(r'"([^"\n]+)"', found[0])


def audit(rom, work, lpunpack, kashi):
    out = work / "output"
    out.mkdir(exist_ok=True, parents=True)
    deleted = launcher_deletion_names(kashi)
    superimage = make_super(rom, work)
    meta = json.loads(call(sys.executable, lpunpack, "--info", "-f", "json",
                           superimage, output=True))
    all_parts = {x["name"] for x in meta["partition_table"]}
    found, scanned = [], []
    for part in ("product", "system_ext", "system", "mi_ext", "mi_product"):
        exact = next((p for p in (part + "_a", part, part + "_b") if p in all_parts), None)
        if exact is None:
            continue
        extraction = work / "partition"
        extraction.mkdir(exist_ok=True)
        call(sys.executable, lpunpack, "-p", exact, superimage, extraction)
        image = extraction / (exact + ".img")
        if not image.is_file():
            raise RuntimeError("Missing unpacked logical partition " + exact)
        scratch = work / "scratch"
        scanned.append(dict(name=exact, filesystem=filesystem(image)))
        found.extend(read_apps(image, part, out, scratch))
        shutil.rmtree(scratch, ignore_errors=True)
        image.unlink()
    if not scanned:
        raise RuntimeError("No app-bearing partitions found in super.img")
    report = dict(scanned=scanned, paths=found, launcher_removed_dirs=deleted,
                  components={name: {"found": any(x["name"] == name for x in found),
                                     "directly_removed_by_launcher": name in deleted,
                                     "paths": [x["partition"] + ":" + x["path"] for x in found if x["name"] == name]}
                              for name in EXTRAS}, apks=[])
    for apk in sorted((out / "files").rglob("*.apk")):
        sha = hashlib.sha256()
        with apk.open("rb") as f:
            for chunk in iter(lambda: f.read(1024**2), b""):
                sha.update(chunk)
        report["apks"].append(dict(path=str(apk.relative_to(out)), bytes=apk.stat().st_size,
                                   sha256=sha.hexdigest()))
    (out / "audit.json").write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n")
    lines = ["# Xiaomi.eu vs HyperMOS Launcher audit", "",
             "Launcher replacement removes these exact directory names: " + ", ".join(deleted),
             "", "| Component | Found in ROM | Original paths | Deleted directly by Launcher? |",
             "| --- | --- | --- | --- |"]
    for name, info in report["components"].items():
        paths = ", ".join(info["paths"]) or "None in scanned app locations"
        lines.append("| " + name + " | " + str(info["found"]) + " | " + paths + " | " +
                     str(info["directly_removed_by_launcher"]) + " |")
    lines += ["", "No direct name match does not rule out runtime dependencies on Launcher.",
              "Original Launcher directories are also extracted when present.",
              "The source ROM is never flashed or patched. SHA-256 values are in audit.json."]
    (out / "audit.md").write_text("\n".join(lines) + "\n")
    print("\n".join(lines), flush=True)


if __name__ == "__main__":
    try:
        audit(Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3]), Path(sys.argv[4]))
    except (OSError, ValueError, RuntimeError, KeyError, IndexError, subprocess.CalledProcessError,
            zipfile.BadZipFile, json.JSONDecodeError) as ex:
        print("[AUDIT ERROR]", ex, file=sys.stderr)
        sys.exit(1)
