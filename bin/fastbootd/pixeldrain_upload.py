#!/usr/bin/env python3
"""Upload FastbootD partition images to Pixeldrain concurrently, with SHA-256 verification.

Every image is uploaded as an independent raw PUT. There is no giant GitHub
Actions ZIP, and no attempt to split one image into concurrent HTTP fragments:
Pixeldrain's public file PUT API is a single-stream upload per file.
"""
from __future__ import annotations

import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import hashlib
import json
import os
from pathlib import Path
import re
import sys
import time
from urllib.parse import quote

import requests

API = "https://pixeldrain.com/api"
CHUNK = 4 * 1024 * 1024
PROGRESS_INTERVAL = 256 * 1024 * 1024
TRANSIENT_STATUS = {408, 429, 500, 502, 503, 504}


class UploadError(RuntimeError):
    pass


class ProgressFile:
    """Seekable file-like body so requests sends Content-Length, not chunked POST."""
    def __init__(self, handle, length: int, label: str):
        self.handle = handle
        self.length = length
        self.label = label
        self.next_report = PROGRESS_INTERVAL

    def __len__(self):
        return self.length

    def tell(self):
        return self.handle.tell()

    def read(self, size=-1):
        data = self.handle.read(size)
        pos = self.handle.tell()
        if pos >= self.next_report:
            print(f"[PIXELDRAIN] {self.label}: sent {pos}/{self.length} bytes ({pos * 100 // self.length}%)", flush=True)
            self.next_report = (pos // PROGRESS_INTERVAL + 1) * PROGRESS_INTERVAL
        return data


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(CHUNK), b""):
            digest.update(block)
    return digest.hexdigest()


def valid_identifier(value: str) -> bool:
    return bool(re.fullmatch(r"[A-Za-z0-9._-]+", value))


def load_partitions(directory: Path) -> tuple[dict, list[tuple[str, Path, dict]]]:
    manifest = json.loads((directory / "manifest.json").read_text(encoding="utf-8"))
    parts = manifest.get("selected_partitions")
    if not isinstance(parts, list) or not parts or len(parts) != len(set(parts)):
        raise UploadError("Invalid selected_partitions")
    entries = []
    for part in parts:
        if not isinstance(part, str) or not re.fullmatch(r"[a-z][a-z0-9_]*", part):
            raise UploadError("Invalid partition name")
        info = manifest["images"][part]
        if info["path"] != f"images/{part}.img":
            raise UploadError(f"Unexpected image path for {part}")
        path = directory / "images" / f"{part}.img"
        if not path.is_file() or path.is_symlink() or path.stat().st_size != info["bytes"]:
            raise UploadError(f"Missing or wrong-sized partition {part}")
        entries.append((part, path, info))
    return manifest, entries


def verify_upload(file_id: str, expected_size: int, expected_hash: str, key: str) -> None:
    if not valid_identifier(file_id):
        raise UploadError("Invalid Pixeldrain file ID")
    url = f"{API}/file/{quote(file_id, safe='')}/info"
    for attempt in range(5):
        try:
            response = requests.get(
                url, headers={"Authorization": f"Bearer {key}"}, timeout=(20, 60)
            )
            if response.status_code == 200:
                obj = response.json()
                if obj.get("success") is not True:
                    raise UploadError("Pixeldrain info returned success=false")
                if obj.get("size") != expected_size:
                    raise UploadError(f"Pixeldrain size mismatch for {file_id}")
                if obj.get("hash_sha256", "").lower() != expected_hash.lower():
                    raise UploadError(f"Pixeldrain SHA256 mismatch for {file_id}")
                return
            if response.status_code not in TRANSIENT_STATUS and response.status_code != 404:
                raise UploadError(f"Pixeldrain info HTTP {response.status_code}")
        except requests.RequestException:
            if attempt == 4:
                raise
        time.sleep(min(2 ** attempt, 10))
    raise UploadError(f"Could not verify Pixeldrain file {file_id}")


def upload_one(path: Path, remote_name: str, key: str, expected_hash: str, expected_size: int) -> dict:
    if path.stat().st_size != expected_size:
        raise UploadError(f"{path.name}: size changed before upload")
    if sha256(path) != expected_hash:
        raise UploadError(f"{path.name}: local SHA256 differs from manifest")
    endpoint = f"{API}/file/{quote(remote_name, safe='')}"
    for attempt in range(1, 4):
        try:
            print(f"[PIXELDRAIN] Upload {remote_name} (attempt {attempt}/3)", flush=True)
            with path.open("rb") as handle:
                response = requests.put(
                    endpoint,
                    data=ProgressFile(handle, expected_size, remote_name),
                    headers={
                        "Authorization": f"Bearer {key}",
                        "Content-Type": "application/octet-stream",
                    },
                    timeout=(30, 1800),
                )
            if response.status_code in TRANSIENT_STATUS:
                raise requests.RequestException(f"Temporary upload HTTP {response.status_code}")
            if response.status_code != 201:
                try:
                    description = response.json().get("value", "unknown")
                except ValueError:
                    description = "non-json-response"
                raise UploadError(f"{remote_name}: Pixeldrain HTTP {response.status_code} ({description})")
            data = response.json()
            file_id = data.get("id", "")
            if data.get("success") is not True or not valid_identifier(file_id):
                raise UploadError(f"{remote_name}: upload response lacks valid file ID")
            verify_upload(file_id, expected_size, expected_hash, key)
            url = f"https://pixeldrain.com/u/{file_id}"
            print(f"[PIXELDRAIN] VERIFIED {remote_name}: {url}", flush=True)
            return {"name": remote_name, "id": file_id, "url": url,
                    "bytes": expected_size, "sha256": expected_hash}
        except requests.RequestException as exc:
            if attempt == 3:
                raise UploadError(f"{remote_name}: network upload failed after 3 attempts: {exc}") from exc
            time.sleep(min(2 ** attempt * 3, 20))
    raise UploadError(f"{remote_name}: upload failed")


def post_list(results: list[dict], title: str, key: str) -> str | None:
    try:
        response = requests.post(
            f"{API}/list",
            headers={"Authorization": f"Bearer {key}"},
            json={"title": title, "anonymous": False,
                  "files": [{"id": item["id"]} for item in results]},
            timeout=(20, 90),
        )
        if response.status_code == 201:
            data = response.json()
            file_id = data.get("id", "")
            if data.get("success") and valid_identifier(file_id):
                return f"https://pixeldrain.com/l/{file_id}"
        print(f"::warning::Pixeldrain list creation failed (HTTP {response.status_code}); individual file URLs are valid.", flush=True)
    except (requests.RequestException, ValueError) as exc:
        print(f"::warning::Pixeldrain list creation unavailable: {type(exc).__name__}", flush=True)
    return None


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dir", type=Path, default=Path("out/fastbootd"))
    parser.add_argument("--workers", type=int, default=4)
    args = parser.parse_args()
    if not 1 <= args.workers <= 6:
        parser.error("--workers must be between 1 and 6")
    key = os.environ.get("PIXELDRAIN_API_KEY", "")
    if not key:
        raise UploadError("PIXELDRAIN_API_KEY GitHub Actions secret is not configured")
    directory = args.dir.resolve()
    manifest, entries = load_partitions(directory)
    run = os.environ.get("GITHUB_RUN_NUMBER", "local")
    device = manifest["device"]
    base = manifest["base_rom_code"]
    if not all(valid_identifier(s) for s in (run, device, base)):
        raise UploadError("Invalid run/device/base metadata")
    prefix = f"HyperMOS-{device}-{base}-fastbootd-{run}"
    print(f"[PIXELDRAIN] Verifying and uploading {len(entries)} IMG files concurrently (workers={args.workers})", flush=True)

    results_by_part = {}
    failures = []
    with ThreadPoolExecutor(max_workers=min(args.workers, len(entries))) as pool:
        tasks = {
            pool.submit(upload_one, path, f"{prefix}-{part}.img", key,
                        info["sha256"], info["bytes"]): part
            for part, path, info in entries
        }
        for task in as_completed(tasks):
            part = tasks[task]
            try:
                results_by_part[part] = task.result()
            except Exception as exc:
                failures.append(f"{part}: {exc}")
                print(f"::error::Pixeldrain upload failed for {part}: {exc}", flush=True)
    if failures:
        raise UploadError("Not all partitions uploaded and verified: " + "; ".join(failures))

    result = {"source": manifest["source_zip"], "run": run, "device": device,
              "base_rom_code": base, "images": results_by_part}
    (directory / "pixeldrain_results.json").write_text(
        json.dumps(result, indent=2) + "\n", encoding="utf-8"
    )
    link_lines = [
        f"HyperMOS FastbootD | {device} | {base} | Run {run}",
        "Verify SHA-256 after download before flashing.",
        "Only flash matching partitions for the installed base ROM.",
        "",
    ]
    for part in manifest["selected_partitions"]:
        item = results_by_part[part]
        link_lines.extend((f"{part}.img: {item['url']}",
                           f"  bytes={item['bytes']} sha256={item['sha256']}", ""))
    link_lines.extend((
        "FastbootD flash commands after downloading the matching image files:",
        "  adb reboot fastboot",
        "  fastboot getvar product",
        "  fastboot getvar is-userspace",
    ))
    for part in manifest["selected_partitions"]:
        link_lines.append(f'  fastboot flash {part} "{results_by_part[part]["name"]}"')
    link_lines.extend(("  fastboot reboot", "", "Do NOT flash an IMG with a mismatched SHA-256.", ""))
    links_path = directory / "PIXELDRAIN_LINKS.txt"
    links_path.write_text("\n".join(link_lines) + "\n", encoding="utf-8")
    remote_sums = directory / "PIXELDRAIN_SHA256SUMS.txt"
    remote_sums.write_text("".join(
        f'{results_by_part[part]["sha256"]}  {results_by_part[part]["name"]}\n'
        for part in manifest["selected_partitions"]
    ), encoding="utf-8")
    metadata = []
    for filename in ("manifest.json", "PIXELDRAIN_SHA256SUMS.txt", "PIXELDRAIN_LINKS.txt"):
        path = directory / filename
        if not path.is_file():
            raise UploadError(f"Missing metadata: {filename}")
        metadata.append(upload_one(path, f"{prefix}-{filename}", key,
                                   sha256(path), path.stat().st_size))

    ordered = [results_by_part[p] for p in manifest["selected_partitions"]]
    list_url = post_list(ordered + metadata, f"{prefix} | partitions and checksums", key)
    summary = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary:
        with open(summary, "a", encoding="utf-8") as out:
            out.write("### Pixeldrain FastbootD downloads\n\n")
            out.write(f"Device: {device} | Base: {base} | Run: {run}\n\n")
            out.write("| Partition | Download | Size | SHA-256 |\n|---|---|---:|---|\n")
            for part in manifest["selected_partitions"]:
                item = results_by_part[part]
                out.write(f"| {part} | [Pixeldrain]({item['url']}) | "
                          f"{item['bytes']:,} | `{item['sha256']}` |\n")
            out.write("\n")
            for item in metadata:
                out.write(f"[{item['name']}]({item['url']})  \n")
            if list_url:
                out.write(f"\n[All uploaded files on Pixeldrain]({list_url})\n")
            out.write("\n**Flash only matching images. Check SHA-256 after download.**\n")
    print("[PIXELDRAIN] ALL SELECTED IMAGES VERIFIED", flush=True)
    if list_url:
        print("[PIXELDRAIN] List: " + list_url, flush=True)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError, UploadError) as error:
        print(f"::error::[PIXELDRAIN] {error}", file=sys.stderr)
        raise SystemExit(1)
