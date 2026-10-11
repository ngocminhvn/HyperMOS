#!/usr/bin/env python3
"""Probe reachable SourceForge mirrors, download RYU ROM with fallback and verify ZIP.

The probes fetch only 128 KiB; they never download the whole ROM.
Does not hardcode a single mirror: the fastest valid ranged response wins.
"""
import argparse
import concurrent.futures
import json
import subprocess
import tempfile
import time
import zipfile
from pathlib import Path
from urllib.parse import quote

SOURCEFORGE_PROJECT = "projectzk"
MIRRORS = (
    "onboardcloud", "zenlayer", "twds", "netix",
    "pilotfiber", "phoenixnap", "freefr", "master",
)


def probe(host, relative):
    url = f"https://{host}.dl.sourceforge.net/project/{SOURCEFORGE_PROJECT}/{relative}"
    with tempfile.TemporaryDirectory(prefix="ryu-probe-") as work:
        target = Path(work) / "head.bin"
        command = [
            "curl", "-fsSL", "--retry", "0", "--connect-timeout", "5",
            "--max-time", "19", "--speed-time", "7", "--speed-limit", "1024",
            "--max-filesize", "524288", "--range", "0-131071",
            "-o", str(target), "-w", "%{http_code}", url,
        ]
        start = time.monotonic()
        result = subprocess.run(command, text=True, capture_output=True, timeout=23)
        elapsed = max(time.monotonic() - start, 0.01)
        if (result.returncode == 0 and result.stdout.strip() == "206"
                and target.is_file() and target.stat().st_size >= 4096):
            with target.open("rb") as file:
                magic = file.read(4)
            if magic == b"PK\\x03\\x04":
                return {"mirror": host, "url": url, "bytes_per_sec": round(
                    target.stat().st_size / elapsed), "seconds": round(elapsed, 2)}
    return None


def valid_rom_zip(path):
    if not path.is_file() or path.stat().st_size < 512 * 1024 * 1024:
        return False
    try:
        with zipfile.ZipFile(path) as archive:
            supers = [x for x in archive.infolist()
                      if x.filename.endswith("/super.img") or x.filename == "super.img"]
            return len(supers) == 1 and supers[0].file_size > 1024 * 1024 * 1024
    except (OSError, zipfile.BadZipFile):
        return False


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--file", required=True,
                        help="Path under SourceForge project/projectzk/")
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--report", type=Path, required=True)
    args = parser.parse_args()
    relative = "/".join(quote(part, safe=".-_") for part in args.file.strip("/").split("/"))
    results = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as executor:
        for candidate in executor.map(lambda host: probe(host, relative), MIRRORS):
            if candidate:
                results.append(candidate)
    results.sort(key=lambda item: item["bytes_per_sec"], reverse=True)
    auto = f"https://downloads.sourceforge.net/project/{SOURCEFORGE_PROJECT}/{relative}"
    attempts = [item["url"] for item in results[:5]] + [auto]
    report = {"source_path": args.file, "probes": results, "attempted": [], "selected": None}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.report.parent.mkdir(parents=True, exist_ok=True)
    print("Auto-selected mirror candidates:", flush=True)
    for item in results:
        print(f"  {item['mirror']}: {item['bytes_per_sec']/1024:.0f} KiB/s probe", flush=True)
    if not results:
        print("No usable ranged mirror; SourceForge auto-redirect is fallback.", flush=True)
    for url in attempts:
        args.output.unlink(missing_ok=True)
        args.output.with_name(args.output.name + ".aria2").unlink(missing_ok=True)
        print("Downloading from:", url, flush=True)
        command = [
            "aria2c", "--console-log-level=warn", "--summary-interval=30",
            "--max-tries=3", "--retry-wait=12", "--connect-timeout=20",
            "--timeout=75", "--max-file-not-found=2", "--file-allocation=none",
            "--allow-overwrite=true", "--auto-file-renaming=false",
            "--continue=false", "-x", "4", "-s", "4", "-k", "16M",
            "--dir", str(args.output.parent), "--out", args.output.name, url,
        ]
        proc = subprocess.run(command, timeout=60 * 65, check=False)
        valid = proc.returncode == 0 and valid_rom_zip(args.output)
        report["attempted"].append({"url": url, "exit_code": proc.returncode,
                                    "zip_ok": valid})
        if valid:
            report["selected"] = url
            args.report.write_text(json.dumps(report, indent=2) + "\n")
            print(f"ROM ZIP verified: {args.output.stat().st_size} bytes", flush=True)
            return
        print("Invalid/incomplete ZIP or failed mirror; moving to next mirror.", flush=True)
    args.report.write_text(json.dumps(report, indent=2) + "\n")
    raise SystemExit("All mirror candidates failed; see mirror-report.json")


if __name__ == "__main__":
    main()
