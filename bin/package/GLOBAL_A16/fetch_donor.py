#!/usr/bin/env python3
"""Retrieve SHA-pinned Xiaomi 15 Global 303 PowerKeeper donor DEX from Actions.

No user APK, vendor resources or signing metadata are transplanted.
The workflow pin-global-a16.yml snapshots this DEX into Git after checkout.
"""
import hashlib
import io
import json
import os
import sys
import urllib.error
import urllib.request
import zipfile
from pathlib import Path

REPO = "ngocminhvn/HyperMOS"
PINNED_ID = 12494258310
EXPECTED_APK = "56f0a7e02a9966e47441dee60d78f4d99e93700b1e912f45617d3d0d29c52eda"
EXPECTED_DEX = "21c20b3ddbaab981276bab60ab6c2a0f62587ea6d87b84bc54aa33def6df25bf"
API = "https://api.github.com/repos/" + REPO

def request(url):
    token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    if not token:
        raise ValueError("GH_TOKEN required when pinned Global DEX is not in repo")
    req = urllib.request.Request(url, headers={
        "Authorization": "Bearer " + token,
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
        "User-Agent": "HyperMOS-Global303-A16",
    })
    with urllib.request.urlopen(req, timeout=150) as response:
        return response.read()

def latest_ids():
    url = API + "/actions/workflows/dump-dada-global.yml/runs?status=success&per_page=8"
    payload = json.loads(request(url))
    ids = []
    for run in payload.get("workflow_runs", []):
        listing = json.loads(request(API + "/actions/runs/" + str(run["id"]) + "/artifacts?per_page=100"))
        for artifact in listing.get("artifacts", []):
            if artifact.get("name") == "HyperMOS-dump-base-2" and not artifact.get("expired"):
                ids.append(int(artifact["id"]))
    return ids

def get_apk(data):
    # GitHub's Actions artifact ZIP contains the original dump ZIP; support
    # direct and nested layouts without extracting arbitrary paths to disk.
    with zipfile.ZipFile(io.BytesIO(data)) as outer:
        for info in outer.infolist():
            if info.is_dir():
                continue
            if info.filename.lower() == "powerkeeper.apk":
                return outer.read(info)
            if info.filename.lower().endswith(".zip"):
                with zipfile.ZipFile(io.BytesIO(outer.read(info))) as nested:
                    for member in nested.infolist():
                        if member.filename.lower() == "powerkeeper.apk":
                            return nested.read(member)
    raise ValueError("Global artifact has no powerkeeper.apk")

def run(output):
    ids = [PINNED_ID]
    # The pin job normally commits the DEX to main; only a fresh build
    # without the pinned blob needs the short-lived Actions artifact.
    ids.extend(i for i in latest_ids() if i != PINNED_ID)
    errors = []
    for artifact_id in ids:
        try:
            blob = request(API + "/actions/artifacts/" + str(artifact_id) + "/zip")
            apk = get_apk(blob)
            if hashlib.sha256(apk).hexdigest() != EXPECTED_APK:
                raise ValueError("Global APK SHA256 mismatch")
            with zipfile.ZipFile(io.BytesIO(apk)) as z:
                dex = z.read("classes.dex")
            if hashlib.sha256(dex).hexdigest() != EXPECTED_DEX:
                raise ValueError("Global DEX SHA256 mismatch")
            output.parent.mkdir(parents=True, exist_ok=True)
            output.write_bytes(dex)
            print("[GLOBAL A16] verified Global303 PowerKeeper DEX, artifact", artifact_id)
            return
        except (urllib.error.URLError, zipfile.BadZipFile, KeyError, ValueError, OSError) as exc:
            errors.append(str(artifact_id) + ": " + str(exc))
    raise ValueError("No verified Global303 donor artifact; rerun dump-dada-global.yml: " + "; ".join(errors))

if __name__ == "__main__":
    try:
        if len(sys.argv) != 2:
            raise ValueError("usage: fetch_donor.py OUTPUT.dex")
        run(Path(sys.argv[1]))
    except (OSError, ValueError, urllib.error.URLError, zipfile.BadZipFile) as exc:
        raise SystemExit("[GLOBAL A16] FAIL: " + str(exc))
