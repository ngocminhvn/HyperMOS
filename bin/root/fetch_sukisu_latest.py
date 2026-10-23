#!/usr/bin/env python3
"""Fetch the latest stable OFFICIAL SukiSU release assets for an exact GKI KMI.

No guesses: every selected GitHub release asset must provide a SHA-256 digest,
which is checked before it can be used to patch an image.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
import time
import urllib.error
import urllib.request
import zipfile
from pathlib import Path

API = "https://api.github.com/repos/SukiSU-Ultra/SukiSU-Ultra/releases/latest"
KMIS = frozenset({
    "android12-5.10", "android13-5.10", "android13-5.15",
    "android14-5.15", "android14-6.1", "android15-6.6",
    "android16-6.12", "android17-6.18",
})
USER_AGENT = "HyperMOS-SukiSU-LKM/1.0"
HEX = re.compile(r"^sha256:([0-9a-fA-F]{64})$")


def download(url: str, destination: Path, expected_sha256: str | None = None) -> None:
    if not url.startswith("https://"):
        raise ValueError("only HTTPS downloads are allowed")
    for attempt in range(3):
        try:
            req = urllib.request.Request(
                url, headers={"User-Agent": USER_AGENT, "Accept": "application/octet-stream"}
            )
            with urllib.request.urlopen(req, timeout=180) as response:
                h = hashlib.sha256()
                with destination.open("wb") as output:
                    while chunk := response.read(1024 * 1024):
                        h.update(chunk)
                        output.write(chunk)
            if not destination.stat().st_size:
                raise ValueError("downloaded empty file")
            actual = h.hexdigest()
            if expected_sha256 and actual != expected_sha256.lower():
                raise ValueError("SHA-256 mismatch on release asset")
            return
        except (OSError, ValueError, urllib.error.URLError) as exc:
            destination.unlink(missing_ok=True)
            if attempt == 2:
                raise RuntimeError(f"could not download/verify {url.split('/')[-1]}: {exc}") from exc
            time.sleep(2 * (attempt + 1))


def load_release() -> dict:
    req = urllib.request.Request(API, headers={
        "Accept": "application/vnd.github+json", "User-Agent": USER_AGENT,
    })
    with urllib.request.urlopen(req, timeout=45) as response:
        release = json.load(response)
    tag = release.get("tag_name", "")
    if not re.fullmatch(r"v[0-9][0-9A-Za-z._-]*", tag):
        raise RuntimeError(f"unrecognized stable release tag: {tag!r}")
    if release.get("draft") or release.get("prerelease"):
        raise RuntimeError("latest release is marked draft/prerelease")
    return release


def choose_asset(assets: list[dict], pattern: str) -> dict:
    selected = [a for a in assets if re.fullmatch(pattern, str(a.get("name", "")))]
    if not selected:
        raise RuntimeError(f"the latest release does not ship a verified asset matching: {pattern}")
    for asset in selected:
        if not HEX.fullmatch(str(asset.get("digest", ""))):
            raise RuntimeError(f"release asset {asset['name']} has no SHA-256 digest")
    return selected[0]


def unpack_ksuinit(file: Path, destination: Path) -> None:
    if not zipfile.is_zipfile(file):
        destination.write_bytes(file.read_bytes())
        return
    with zipfile.ZipFile(file) as archive:
        files = [m for m in archive.infolist() if not m.is_dir()
                 and Path(m.filename).name == "ksuinit"]
        if len(files) != 1:
            raise RuntimeError("ksuinit ZIP does not contain exactly one ksuinit executable")
        destination.write_bytes(archive.read(files[0]))


def run(out: Path, kmi: str) -> None:
    if kmi not in KMIS:
        raise RuntimeError(f"unsupported SukiSU aarch64 GKI KMI: {kmi}")
    out.mkdir(parents=True, exist_ok=True)
    release = load_release()
    tag = release["tag_name"]
    assets = release.get("assets", [])
    lkm = choose_asset(assets, re.escape(f"lkm-aarch64-{kmi}_kernelsu.ko"))
    init = choose_asset(assets, r"ksuinit-aarch64(?:\.zip)?")
    manager_pattern = rf"SukiSU_{re.escape(tag)}_[0-9]+(?:-arm64-v8a)?-release\.apk"
    manager = choose_asset(assets, manager_pattern)
    # Prefer the universal manager if a release ships both universal and split APKs.
    universal = [a for a in assets if re.fullmatch(
        rf"SukiSU_{re.escape(tag)}_[0-9]+-release\.apk", str(a.get("name", "")))]
    if universal:
        manager = choose_asset(universal, re.escape(universal[0]["name"]))
    picked = {"lkm": lkm, "init": init, "manager": manager}
    verified = {}
    for key, asset in picked.items():
        name = str(asset["name"])
        uri = str(asset.get("browser_download_url", ""))
        if not uri.startswith(f"https://github.com/SukiSU-Ultra/SukiSU-Ultra/releases/download/{tag}/"):
            raise RuntimeError(f"untrusted source URL for {name}")
        digest = HEX.fullmatch(asset["digest"]).group(1).lower()
        dst = out / name
        download(uri, dst, digest)
        verified[key] = {"asset": name, "sha256": digest}
        print(f"[ROOT] verified official {tag} asset: {name} SHA-256={digest}", flush=True)
    lkm_file = out / verified["lkm"]["asset"]
    init_file = out / verified["init"]["asset"]
    manager_file = out / verified["manager"]["asset"]
    if not lkm_file.read_bytes().startswith(b"\x7fELF"):
        raise RuntimeError("downloaded kernel module is not an ELF object")
    unpack_ksuinit(init_file, out / "ksuinit")
    if not (out / "ksuinit").read_bytes().startswith(b"\x7fELF"):
        raise RuntimeError("downloaded ksuinit is not an ELF object")
    if not zipfile.is_zipfile(manager_file):
        raise RuntimeError("downloaded manager is not a valid APK/ZIP")
    (out / "kernelsu.ko").write_bytes(lkm_file.read_bytes())
    (out / "RootManager.apk").write_bytes(manager_file.read_bytes())
    (out / "ksuinit").chmod(0o755)
    (out / "tag.txt").write_text(tag + "\n")
    (out / "kmi.txt").write_text(kmi + "\n")
    (out / "release-metadata.json").write_text(json.dumps({
        "tag": tag, "kmi": kmi, "release": str(release.get("html_url", "")),
        "assets": verified,
    }, indent=2) + "\n")
    print(f"[ROOT] official latest stable SukiSU={tag}; matching LKM={kmi}")


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--kmi", required=True)
    p.add_argument("--out", type=Path, required=True)
    p.add_argument("--self-test", action="store_true")
    args = p.parse_args()
    if args.self_test:
        assert len(KMIS) == 8
        assert HEX.fullmatch("sha256:" + "a" * 64)
        assert not HEX.fullmatch("sha256:no-digest")
        print("[ROOT] release resolver self-test PASS")
        return 0
    try:
        run(args.out, args.kmi)
    except (OSError, RuntimeError, ValueError, KeyError, urllib.error.URLError) as e:
        print(f"::error title=SukiSU latest release::{e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
