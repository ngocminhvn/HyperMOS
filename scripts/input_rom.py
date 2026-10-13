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
    if incoming:
        return incoming
    cfg = json.loads(Path("config.json").read_text())
    return cfg.get("source_rom_url", "") or cfg.get("source_super_url", "")

def download():
    url = source_url()
    if not url.startswith(("https://", "http://")):
        raise RuntimeError("Need a direct ROM ZIP/super.img HTTP(S) download URL")
    dest = WORK / "download" / "source.bin"
    dest.parent.mkdir(parents=True, exist_ok=True)
    # Retry intermittent failures, but fail on HTTP errors and never accept a JSON error as an image.
    subprocess.run(["curl", "-fL", "--retry", "4", "--retry-delay", "5", "--connect-timeout", "30",
                    "-o", str(dest), url], check=True)
    expected = os.environ.get("SOURCE_SHA256", "").strip().lower()
    if expected and digest(dest) != expected:
        raise RuntimeError("Input SHA-256 mismatch (incorrect URL or hotlink protection)")
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
            # Zip excludes 7z/rar intentionally; preserve original layout exactly.
    else:
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
        target = out / f"HAOTIAN_SuperMods_{os.environ.get('GITHUB_RUN_NUMBER', 'local')}.zip"
        with zipfile.ZipFile(original, "r", allowZip64=True) as src, zipfile.ZipFile(target, "w", allowZip64=True) as dst:
            for entry in src.infolist():
                if entry.filename == info["super_member"]:
                    dst.write(new, arcname=entry.filename, compress_type=entry.compress_type, compresslevel=1)
                elif entry.is_dir():
                    dst.writestr(entry, b"")
                else:
                    with src.open(entry, "r") as fin, dst.open(entry, "w", force_zip64=True) as fout:
                        shutil.copyfileobj(fin, fout, length=8*1024*1024)
        with zipfile.ZipFile(target) as z:
            if z.testzip() is not None:
                raise RuntimeError("Output ZIP CRC integrity check failed")
        print("Repacked ROM ZIP:", target)
    (REPORTS / "result.txt").write_text(f"Output: {target}\nSHA256: {digest(target)}\nAVB compatibility with separate vbmeta not verified. Do not flash without verifying boot chain.\n")
    envfile = os.environ.get("GITHUB_ENV")
    if envfile:
        with open(envfile, "a") as f:
            f.write(f"OUTPUT_FILE={target}\n")

if __name__ == "__main__":
    {"download": download, "package": package}[sys.argv[1]]()
