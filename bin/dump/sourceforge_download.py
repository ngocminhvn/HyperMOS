#!/usr/bin/env python3
"""SourceForge-aware ROM downloader: benchmark small byte ranges, then use aria2.

This script only reads remote data. It does not modify a ROM.
Mirror performance is measured FROM THE GITHUB ACTIONS RUNNER, not the user's PC.
"""
import argparse
import concurrent.futures
import json
import re
import subprocess
import tempfile
import time
import zipfile
from pathlib import Path
from urllib.parse import quote, unquote, urlencode, urlsplit, urlunsplit

# SourceForge officially allows use_mirror=<shortname>; mirror availability varies.
MIRRORS = (
    "autoselect", "onboardcloud", "zenlayer", "twds", "netix", "ixpeering",
    "psychz", "cfhcable", "netactuate", "phoenixnap", "pilotfiber",
)
SAMPLE_BYTES = 1024 * 1024
MIN_SAMPLE_BYTES = 128 * 1024


def normalize(url):
    """Return (canonical SF download URL, project slug, filename), or None."""
    url = url.strip().strip("<>")
    parts = urlsplit(url)
    if parts.scheme.lower() not in ("https", "http") or not parts.netloc:
        raise ValueError("ROM URL must begin with https:// or http://")
    hostname = (parts.hostname or "").lower()
    if hostname not in {
        "sourceforge.net", "www.sourceforge.net", "downloads.sourceforge.net"
    }:
        return None
    raw_path = unquote(parts.path)
    if hostname == "downloads.sourceforge.net":
        match = re.fullmatch(r"/project/([^/]+)/(.+)", raw_path, flags=re.I)
    else:
        match = re.fullmatch(r"/projects/([^/]+)/files/(.+)", raw_path, flags=re.I)
    if not match:
        raise ValueError("Not a SourceForge project file URL")
    project, filename = match.groups()
    if not re.fullmatch(r"[A-Za-z0-9._-]+", project):
        raise ValueError("Invalid SourceForge project name")
    # Handles a pasted SF '*/*' suffix (e.g. file.zip*/*), plain ZIP links,
    # and the official /download endpoint. Never treat '*' as a glob.
    zipped = re.fullmatch(
        r"(.+?\.zip)(?:/download|/\*|\*/\*|\*/|\*|/)?",
        filename, flags=re.I
    )
    if not zipped:
        raise ValueError("SourceForge URL must name a ZIP file")
    relative = zipped.group(1)
    if any(x in ("..", ".", "") for x in relative.split("/")):
        raise ValueError("Unsafe SourceForge file path")
    path = f"/projects/{project}/files/{quote(relative, safe='/._-()~+')}/download"
    canonical = urlunsplit(("https", "sourceforge.net", path, "", ""))
    return canonical, project, relative


def mirror_url(canonical, shortname):
    return canonical + "?" + urlencode({"use_mirror": shortname})


def probe(item):
    name, url = item
    # curl's range and max-filesize bound network/data use; --proto-redir
    # prevents redirects to arbitrary non-HTTP protocols.
    with tempfile.TemporaryDirectory(prefix="sf-probe-") as folder:
        sample = Path(folder) / "sample.bin"
        cmd = [
            "curl", "-L", "-sS", "-f", "--proto", "=https,http",
            "--proto-redir", "=https,http",
            "--connect-timeout", "5", "--max-time", "12",
            "--range", f"0-{SAMPLE_BYTES - 1}",
            "--max-filesize", str(SAMPLE_BYTES),
            "-A", "Mozilla/5.0 (HyperMOS dump mirror probe)",
            "-o", str(sample),
            "-w", "%{http_code}\t%{size_download}\t%{speed_download}\t%{url_effective}",
            url,
        ]
        try:
            done = subprocess.run(cmd, capture_output=True, text=True, timeout=14)
            if done.returncode != 0:
                return {"mirror": name, "status": "unavailable", "reason": "range probe failed"}
            fields = done.stdout.strip().split("\t", 3)
            if len(fields) != 4:
                return {"mirror": name, "status": "unavailable", "reason": "invalid probe response"}
            code, received, speed, effective = fields
            with sample.open("rb") as f:
                header = f.read(4)
            if code != "206" or int(float(received)) < MIN_SAMPLE_BYTES or header != b"PK\x03\x04":
                return {"mirror": name, "status": "unavailable", "reason": "no verified ZIP range"}
            host = urlsplit(effective).hostname or ""
            return {
                "mirror": name, "status": "ok", "speed_bps": round(float(speed)),
                "speed_mib_s": round(float(speed) / (1024 * 1024), 2),
                "serving_host": host.lower(),
            }
        except (OSError, subprocess.TimeoutExpired, ValueError, IndexError):
            return {"mirror": name, "status": "unavailable", "reason": "probe failed"}


def benchmark(canonical, mirrors=MIRRORS):
    with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
        results = list(pool.map(probe, [(m, mirror_url(canonical, m)) for m in mirrors]))
    results.sort(key=lambda x: x.get("speed_bps", 0), reverse=True)
    # SF sometimes reroutes unavailable mirrors to the same real mirror;
    # count only one copy of each actual serving host.
    best = []
    hosts = set()
    for result in results:
        if result["status"] == "ok" and result["serving_host"] not in hosts:
            best.append(result["mirror"])
            hosts.add(result["serving_host"])
    # Autoselect is always a last-resort fallback, even when its probe fails.
    if "autoselect" not in best:
        best.append("autoselect")
    return best, results


def download(url, output):
    output.parent.mkdir(parents=True, exist_ok=True)
    cmd = [
        "aria2c", "--file-allocation=none", "--max-tries=3",
        "--retry-wait=4", "--connect-timeout=20", "--timeout=45",
        "--lowest-speed-limit=12K", "--max-connection-per-server=8",
        "--split=8", "--min-split-size=4M", "--continue=true",
        "--dir", str(output.parent), "--out", output.name, url,
    ]
    return subprocess.run(cmd, check=False).returncode == 0


def valid_zip(output):
    return output.is_file() and output.stat().st_size >= 1024 and zipfile.is_zipfile(output)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--url", required=True)
    ap.add_argument("--output", required=True, type=Path)
    ap.add_argument("--report", required=True, type=Path)
    args = ap.parse_args()
    sf = normalize(args.url)
    output = args.output.resolve()
    started = time.monotonic()
    if sf:
        canonical, project, file_path = sf
        print(f"[SOURCEFORGE] Project: {project}, file: {file_path}", flush=True)
        print(f"[SOURCEFORGE] Benchmarking {len(MIRRORS)} mirror options (1 MiB max per probe)", flush=True)
        ordered, probed = benchmark(canonical)
        for item in probed:
            if item["status"] == "ok":
                print(f"[MIRROR] {item['mirror']}: {item['speed_mib_s']} MiB/s via {item['serving_host']}", flush=True)
        urls = [(name, mirror_url(canonical, name)) for name in ordered]
    else:
        print("[DOWNLOAD] Non-SourceForge URL: using original direct download", flush=True)
        project = None
        file_path = None
        probed = []
        urls = [("direct", args.url)]
    attempts = []
    for name, url in urls:
        print(f"[DOWNLOAD] Trying {name}", flush=True)
        success = download(url, output)
        if success and valid_zip(output):
            print(f"[DOWNLOAD] ZIP received from {name} ({output.stat().st_size} bytes)", flush=True)
            attempts.append({"mirror": name, "result": "ok"})
            report = {
                "type": "SourceForge" if sf else "direct",
                "project": project, "file": file_path,
                "selected_mirror": name, "probes": probed,
                "attempts": attempts, "elapsed_seconds": round(time.monotonic() - started, 1),
            }
            args.report.parent.mkdir(parents=True, exist_ok=True)
            args.report.write_text(json.dumps(report, indent=2) + "\n")
            return
        print(f"[WARN] {name} failed or returned non-ZIP content; trying next mirror", flush=True)
        attempts.append({"mirror": name, "result": "failed"})
        # Prevent a corrupted/incomplete .aria2 partial from poisoning fallback.
        output.unlink(missing_ok=True)
        Path(str(output) + ".aria2").unlink(missing_ok=True)
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps({
        "type": "SourceForge" if sf else "direct", "project": project,
        "file": file_path, "selected_mirror": None, "probes": probed,
        "attempts": attempts,
    }, indent=2) + "\n")
    raise SystemExit("[ERROR] Download failed for every mirror")


if __name__ == "__main__":
    main()
