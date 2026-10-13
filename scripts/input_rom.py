#!/usr/bin/env python3
"""Download an already-modded ROM ZIP (or standalone super.img); never use stock payload.bin."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import zipfile

ROOT = Path.cwd()
WORK = ROOT / "work"
REPORTS = WORK / "reports"
REPORTS.mkdir(parents=True, exist_ok=True)

def digest(path):
    h = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(8 * 1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()

def source_url():
    incoming = os.environ.get("INPUT_URL", "").strip()
    if not incoming:
        raise RuntimeError("Missing input_url from GitHub Actions Run workflow form")
    return incoming


def download_with_resume(url, dest):
    """Resume bytes already downloaded; refresh expiring SourceForge mirror links."""
    import time
    from urllib.parse import urlsplit

    parsed = urlsplit(url)
    is_sf_mirror = (
        parsed.hostname is not None
        and (parsed.hostname == "downloads.sourceforge.net"
             or parsed.hostname.endswith(".dl.sourceforge.net"))
        and parsed.path.startswith("/project/")
    )
    # SourceForge mirror links may have expiring e/st/fid query parameters.
    # The canonical project URL generates a fresh redirect on the next attempt.
    canonical = "https://downloads.sourceforge.net" + parsed.path if is_sf_mirror else url
    endpoints = [url] if canonical == url else [url, canonical]
    attempts = 8

    for attempt in range(1, attempts + 1):
        endpoint = endpoints[0] if attempt == 1 else endpoints[-1]
        before = dest.stat().st_size if dest.exists() else 0
        print(
            f"ROM download attempt {attempt}/{attempts}: "
            f"{urlsplit(endpoint).hostname}, resume at {before:,} bytes",
            flush=True,
        )
        cmd = [
            "curl", "--fail", "--location", "--silent", "--show-error",
            "--connect-timeout", "30", "--max-time", "2700",
            "--speed-limit", "65536", "--speed-time", "180",
            "--continue-at", "-", "--output", str(dest), endpoint,
        ]
        with subprocess.Popen(cmd) as proc:
            while True:
                try:
                    code = proc.wait(timeout=45)
                    break
                except subprocess.TimeoutExpired:
                    current = dest.stat().st_size if dest.exists() else 0
                    print(f"ROM download progress: {current:,} bytes on disk", flush=True)

        after = dest.stat().st_size if dest.exists() else 0
        if after < before:
            raise RuntimeError(
                "Download source unexpectedly truncated existing partial ROM; "
                "refusing to continue with potentially corrupt data"
            )
        if code == 0:
            print(f"ROM transfer complete: {after:,} bytes", flush=True)
            return
        print(
            f"ROM transfer failed (curl exit {code}) after {after:,} bytes. "
            "Will preserve downloaded bytes for resumption.",
            flush=True,
        )
        if code == 33 and endpoint == canonical:
            raise RuntimeError(
                "Server does not support HTTP Range resumption on the stable URL. "
                "Use a ROM mirror that supports range requests."
            )
        if attempt < attempts:
            time.sleep(min(3 * attempt, 20))

    raise RuntimeError(
        f"ROM download interrupted after {attempts} attempts "
        f"({dest.stat().st_size if dest.exists() else 0:,} bytes retained). "
        "Try another source mirror."
    )

def download():
    url = source_url()
    if not url.startswith(("https://", "http://")):
        raise RuntimeError("Need a direct ROM ZIP/super.img HTTP(S) download URL")
    dest = WORK / "download" / "source.bin"
    dest.parent.mkdir(parents=True, exist_ok=True)
    # Resume interrupted multi-GB transfers. curl --retry alone does not recover curl (18).
    download_with_resume(url, dest)
    if dest.stat().st_size < 4096:
        raise RuntimeError("Download is too small to contain a ROM/image")
    super_path = WORK / "original" / "super.img"
    super_path.parent.mkdir(parents=True, exist_ok=True)
    meta = {"input_sha256": digest(dest)}
    if zipfile.is_zipfile(dest):
        with zipfile.ZipFile(dest) as z:
            items = [i for i in z.infolist() if i.filename.lower().rstrip("/").endswith("/super.img") or i.filename.lower() == "super.img"]
            items = [i for i in items if not i.is_dir() and not i.filename.startswith(("/", "../"))]
            if len(items) != 1:
                has_payload = any(i.filename.lower().endswith("payload.bin") for i in z.infolist())
                if has_payload:
                    raise RuntimeError("Source is OTA payload.bin, not an already-modded super.img ROM ZIP. This editor requires super.img inside the ZIP.")
                raise RuntimeError(f"Expected exactly one super.img inside ROM ZIP, found {len(items)}")
            selected = items[0]
            with z.open(selected) as src, super_path.open("wb") as out:
                shutil.copyfileobj(src, out, length=8*1024*1024)
            meta.update({"input_type": "rom_zip", "super_member": selected.filename})
            if os.environ.get("ROOT_MODE", "stock") == "root":
                matches = {}
                for name in ("boot.img", "init_boot.img"):
                    options = [i for i in z.infolist()
                               if not i.is_dir() and not i.filename.startswith(("/", "../"))
                               and Path(i.filename).name == name
                               and i.filename.split("/")[0] not in ("RootBackup", "backup", "Backup")]
                    if len(options) != 1:
                        raise RuntimeError(f"Root mode requires exactly one {name} inside the ROM ZIP; found {len(options)}")
                    matches[name] = options[0].filename
                    target = WORK / "root-input" / name
                    target.parent.mkdir(parents=True, exist_ok=True)
                    with z.open(options[0]) as boot_src, target.open("wb") as fout:
                        shutil.copyfileobj(boot_src, fout, length=8*1024*1024)
                    with target.open("rb") as check:
                        if check.read(8) != b"ANDROID!":
                            raise RuntimeError(f"{name}: invalid Android boot image")
                meta["root_members"] = matches
                meta["original_init_boot_sha256"] = digest(WORK / "root-input/init_boot.img")
            # Zip excludes 7z/rar intentionally; preserve original layout exactly.
    else:
        if os.environ.get("ROOT_MODE", "stock") == "root":
            raise RuntimeError("Root mode requires a ROM ZIP containing both boot.img and init_boot.img, not standalone super.img")
        with dest.open("rb") as f:
            prefix = f.read(4)
        sparse_magic = prefix == bytes.fromhex("3aff26ed")
        raw_magic = False
        if not sparse_magic:
            with dest.open("rb") as f:
                f.seek(0x1000)
                raw_magic = f.read(4) in (bytes.fromhex("67446c61"), bytes.fromhex("67446c61")[::-1])
        if not sparse_magic and not raw_magic:
            raise RuntimeError("Input is not a ROM ZIP or recognized super.img (may be an HTML/JSON download error)")
        shutil.copy2(dest, super_path)
        meta.update({"input_type": "super_img", "super_member": None})
    meta["original_super_sha256"] = digest(super_path)
    (WORK / "input.json").write_text(json.dumps(meta, indent=2))
    (REPORTS / "input.txt").write_text(json.dumps(meta, indent=2))
    print("Downloaded ROM:", meta["input_type"], "source super:", meta["super_member"], flush=True)

def package():
    info = json.loads((WORK / "input.json").read_text())
    new = WORK / "output" / "super.img"
    if not new.exists() or new.stat().st_size < 4096:
        raise RuntimeError("Repacked super.img not present")
    out = WORK / "output"
    out.mkdir(exist_ok=True)
    if info["input_type"] == "super_img":
        print("Output standalone image:", new)
        target = new
    else:
        original = WORK / "download" / "source.bin"
        suffix = "_KSUN" if os.environ.get("ROOT_MODE", "stock") == "root" else ""
        target = out / f"HAOTIAN_SuperMods_{os.environ.get('GITHUB_RUN_NUMBER', 'local')}{suffix}.zip"
        root_mode = os.environ.get("ROOT_MODE", "stock")
        if root_mode not in ("root", "stock"):
            raise RuntimeError("Invalid ROOT_MODE")
        patched = WORK / "trees/init_boot.img"
        backup = ROOT / "build/baserom/root-stock-init_boot.img"
        manager = ROOT / "build/baserom/root-package/RootManager.apk"
        root_info = ROOT / "build/baserom/root-package/ROOT-INFO.txt"
        if root_mode == "root":
            for path in (patched, backup, manager, root_info):
                if not path.is_file() or not path.stat().st_size:
                    raise RuntimeError(f"Missing root output: {path}")
            if digest(patched) == digest(backup):
                raise RuntimeError("Root patch returned unchanged init_boot.img")
            if digest(backup) != info["original_init_boot_sha256"]:
                raise RuntimeError("Original init_boot backup digest mismatch")
        with zipfile.ZipFile(original, "r", allowZip64=True) as src, zipfile.ZipFile(target, "w", allowZip64=True) as dst:
            for entry in src.infolist():
                if entry.filename == info["super_member"]:
                    dst.write(new, arcname=entry.filename, compress_type=entry.compress_type, compresslevel=1)
                elif root_mode == "root" and entry.filename == info["root_members"]["init_boot.img"]:
                    dst.write(patched, arcname=entry.filename, compress_type=entry.compress_type, compresslevel=1)
                elif entry.is_dir():
                    dst.writestr(entry, b"")
                else:
                    with src.open(entry, "r") as fin, dst.open(entry, "w", force_zip64=True) as fout:
                        shutil.copyfileobj(fin, fout, length=8*1024*1024)
            if root_mode == "root":
                original_names = set(src.namelist())
                for name, path in (
                    ("RootBackup/init_boot.stock.img", backup),
                    ("RootManager.apk", manager),
                    ("ROOT-INFO.txt", root_info),
                ):
                    if name in original_names:
                        raise RuntimeError(f"Source ROM already contains {name}; refusing to replace existing root payload")
                    dst.write(path, arcname=name, compress_type=zipfile.ZIP_DEFLATED, compresslevel=1)
        with zipfile.ZipFile(target) as z:
            if z.testzip() is not None:
                raise RuntimeError("Output ZIP CRC integrity check failed")
        print("Repacked ROM ZIP:", target)
    (REPORTS / "result.txt").write_text(f"Output: {target}\nSHA256: {digest(target)}\nRoot mode: {os.environ.get('ROOT_MODE', 'stock')}\nAVB compatibility with separate vbmeta not verified. Do not flash without verifying boot chain.\n")
    envfile = os.environ.get("GITHUB_ENV")
    if envfile:
        with open(envfile, "a") as f:
            f.write(f"OUTPUT_FILE={target}\n")

if __name__ == "__main__":
    {"download": download, "package": package}[sys.argv[1]]()
