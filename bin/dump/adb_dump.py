#!/usr/bin/env python3
"""Dump files from a *running* Android ROM over ADB instead of encrypted ZIP.

Use on your own device with USB debugging authorized. Read-only; no partition
flash, mount changes, or installer execution. Works with system files Android
has already mounted, including files packaged in encrypted fastboot ZIPs.
"""
import argparse
import json
import shlex
import shutil
import subprocess
import sys
import tarfile
import zipfile
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PARTS = {
    "system", "system_ext", "product", "vendor", "odm", "mi_ext",
    "mi_product", "system_dlkm", "vendor_dlkm", "odm_dlkm", "product_dlkm",
}
BASE_NAMES = (
    "framework.jar", "miui-framework.jar", "miui-services.jar",
    "powerkeeper.apk", "services.jar",
)
ROOTS = ("/system", "/system_ext", "/product", "/vendor", "/odm",
         "/mi_ext", "/mi_product", "/system_dlkm", "/vendor_dlkm", "/odm_dlkm",
         "/product_dlkm")


def target_location(path):
    """Convert old dump target names to actual Android mount-point paths."""
    bits = Path(path).parts
    for index, name in enumerate(bits):
        if name not in PARTS:
            continue
        rest = list(bits[index+1:])
        if rest and rest[0] == name:
            rest.pop(0)  # installed /system is not /system/system
        if rest:
            return name, "/".join(rest)
    return None


def selected_remote_files(entries, mode, target_lines):
    """Return {absolute device path: (partition, relative image path)}."""
    index = {name.casefold(): name for name in entries if name.startswith("/")}
    by_name, by_directory = defaultdict(list), defaultdict(list)
    for name in index.values():
        by_name[Path(name).name.casefold()].append(name)
        by_directory[str(Path(name).parent).casefold()].append(name)
    found = {}

    def add(name):
        info = target_location(name[1:])
        if info:
            part, relative = info
            found[name] = (part, relative)

    if mode == "base":
        for name in BASE_NAMES:
            choices = by_name.get(name, [])
            if not choices:
                continue
            def prefer(path):
                part = "system_ext" if name.startswith("miui-") or name == "powerkeeper.apk" else "system"
                return (0 if path.startswith("/"+part+"/") else 1, len(path), path.casefold())
            add(sorted(choices, key=prefer)[0])
        return found

    for target in target_lines:
        parsed = target_location(target)
        if not parsed:
            continue
        part, relative = parsed
        desired = ("/"+part+"/"+relative).casefold()
        name = index.get(desired)
        if name:
            add(name)
            continue
        # APK names may vary across ROMs. Use exactly one APK in that folder.
        if relative.lower().endswith(".apk"):
            parent = str(Path("/"+part+"/"+relative).parent).casefold()
            options = [f for f in by_directory.get(parent, [])
                       if f.casefold().endswith(".apk")]
            if len(options) == 1:
                add(options[0])
            continue
        # Some target-list rows are *members inside* a disassembled PowerKeeper
        # APK. Fetch its container; collect.py can read those members.
        chunks = Path(relative).parts
        for i, segment in enumerate(chunks[:-1]):
            if segment.casefold() not in ("powerkeeper", "powerkeeperzk"):
                continue
            dirname = (Path("/"+part) / Path(*chunks[:i+1])).as_posix().casefold()
            options = [f for f in by_directory.get(dirname, [])
                       if f.casefold().endswith(".apk")]
            if len(options) == 1:
                add(options[0])
            break
    return found


def adb(args, *command, check=True):
    return subprocess.run(
        [args.adb, *(["-s", args.serial] if args.serial else []), *command],
        check=check, capture_output=True, text=True,
    )


def adb_base(args):
    return [args.adb, *(["-s", args.serial] if args.serial else [])]


def connected_device(args):
    result = adb(args, "get-state", check=False)
    if result.returncode != 0 or result.stdout.strip() != "device":
        raise SystemExit("ADB device not authorized/connected. Check adb devices.")
    print("[DUMP] Authorized ADB device connected.")
    has_root = False
    if not args.no_root:
        result = adb(args, "shell", "su", "-c", "id", check=False)
        has_root = result.returncode == 0 and "uid=0" in result.stdout
    print("[DUMP] Access:", "granted root (read only)" if has_root else "Android shell")
    return has_root


def remote_files(args, root):
    dirs = " ".join(shlex.quote(p) for p in ROOTS)
    script = f"find {dirs} -type f 2>/dev/null"
    argv = adb_base(args) + ["shell"]
    argv += ["su", "-c", script] if root else ["sh", "-c", script]
    result = subprocess.run(argv, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, check=False)
    entries = [
        s.strip() for s in result.stdout.decode("utf-8", "replace").splitlines()
        if s.startswith("/")
    ]
    if not entries:
        raise SystemExit("No readable partition files found through ADB.")
    return entries


def transfer_tar(args, has_root, files, image_root, batch_size=40):
    """Stream device tar members through ADB; accept only listed regular files."""
    found = 0
    all_files = sorted(files)
    for start in range(0, len(all_files), batch_size):
        chunk = all_files[start:start+batch_size]
        relative = [p.lstrip("/") for p in chunk]
        shell = "tar -cf - -C / " + " ".join(shlex.quote(p) for p in relative)
        cmd = adb_base(args) + ["exec-out"]
        cmd += ["su", "-c", shell] if has_root else ["sh", "-c", shell]
        print(f"[DUMP] Reading files {start+1}–{start+len(chunk)} of {len(all_files)}")
        with subprocess.Popen(cmd, stdout=subprocess.PIPE,
                              stderr=subprocess.DEVNULL) as proc:
            try:
                with tarfile.open(fileobj=proc.stdout, mode="r|*") as stream:
                    for member in stream:
                        if not member.isfile():
                            continue
                        name = "/" + member.name.removeprefix("./").lstrip("/")
                        if name not in files:
                            continue
                        part, rel = files[name]
                        target = (image_root / part / rel).resolve()
                        if not target.is_relative_to(image_root.resolve()):
                            raise RuntimeError("Unsafe device archive filename")
                        target.parent.mkdir(parents=True, exist_ok=True)
                        reader = stream.extractfile(member)
                        if reader is None:
                            continue
                        with reader, target.open("wb") as out:
                            shutil.copyfileobj(reader, out, 1024*1024)
                        found += 1
            except (tarfile.TarError, EOFError) as exc:
                raise RuntimeError(f"ADB tar transfer failed: {exc}") from exc
            if proc.wait() != 0:
                raise RuntimeError("ADB tar failed. Check read permissions or su grant.")
    return found


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", choices=("base", "full"), default="base")
    parser.add_argument("--output", type=Path, default=Path("HyperMOS-device-dump.zip"))
    parser.add_argument("--adb", default="adb")
    parser.add_argument("--serial", default="")
    parser.add_argument("--no-root", action="store_true")
    args = parser.parse_args()

    has_root = connected_device(args)
    entries = remote_files(args, has_root)
    targets = (ROOT/"bin/dump/targets.txt").read_text(encoding="utf-8").splitlines()
    chosen = selected_remote_files(entries, args.mode, targets)
    if not chosen:
        raise SystemExit("No requested files found on the connected device.")

    import tempfile
    with tempfile.TemporaryDirectory(prefix="hypermos-device-dump-") as tmp:
        work = Path(tmp)
        images = work/"images"
        images.mkdir()
        downloaded = transfer_tar(args, has_root, chosen, images)
        if downloaded == 0:
            raise SystemExit("ADB returned no readable requested files")
        output = work/"output"
        task = (ROOT/"bin/dump/base.py" if args.mode == "base"
                else ROOT/"bin/dump/collect.py")
        cmd = [sys.executable, str(task), "--images", str(images),
               "--output", str(output), "--source-url", "adb://installed-rom"]
        if args.mode == "full":
            cmd += ["--targets", str(ROOT/"bin/dump/targets.txt")]
        subprocess.run(cmd, check=True)
        device = adb(args, "shell", "getprop", "ro.build.version.incremental", check=False)
        summary = {
            "source": "installed-Android-filesystem",
            "mode": args.mode,
            "read_only": True,
            "root_authorized": has_root,
            "version": device.stdout.strip() if device.returncode == 0 else "",
            "downloaded_file_count": downloaded,
            "note": "Files belong to the currently installed ROM, not necessarily the supplied encrypted ZIP.",
        }
        (output/"pack-meta").mkdir(parents=True, exist_ok=True)
        (output/"pack-meta"/"device-source.json").write_text(
            json.dumps(summary, indent=2)+"\n", encoding="utf-8"
        )
        archive = args.output.resolve()
        archive.parent.mkdir(parents=True, exist_ok=True)
        with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=1) as z:
            for file in output.rglob("*"):
                if file.is_file():
                    z.write(file, file.relative_to(output).as_posix())
        print(f"[DUMP] Completed {archive} ({downloaded} files transferred)")


if __name__ == "__main__":
    main()
