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
    mirrors = bool(re.fullmatch(r"[a-z0-9-]+\.dl\.sourceforge\.net", hostname))
    if hostname not in {
        "sourceforge.net", "www.sourceforge.net", "downloads.sourceforge.net"
    } and not mirrors:
        return None
    raw_path = unquote(parts.path)
    if hostname == "downloads.sourceforge.net" or mirrors:
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


def download_router_url(project, relative, mirror=None):
    """The binary redirect endpoint, not the web/UI /projects/.../download page."""
    path = quote(relative, safe="/._-()~+")
    url = f"https://downloads.sourceforge.net/project/{project}/{path}"
    return mirror_url(url, mirror) if mirror else url


def direct_mirror_url(project, relative, mirror):
    """Direct SourceForge CDN endpoint for testing actual mirror throughput."""
    if not re.fullmatch(r"[a-z0-9-]+", mirror):
        raise ValueError("Invalid mirror name")
    path = quote(relative, safe="/._-()~+")
    return f"https://{mirror}.dl.sourceforge.net/project/{project}/{path}"


def candidate_urls(original_url, canonical, project, relative, ranked):
    """Never discard the supplied (possibly short-lived signed) mirror link.

    Benchmarked mirrors come first for ordinary SourceForge project URLs.
    Signed mirror URLs supplied by the user come first to preserve valid tokens.
    Unverified direct and downloads.sourceforge.net routes are still attempted
    if SourceForge's small range checks are blocked by a CDN.
    """
    original_host = (urlsplit(original_url).hostname or "").lower()
    is_direct_input = (
        original_host == "downloads.sourceforge.net"
        or bool(re.fullmatch(r"[a-z0-9-]+\.dl\.sourceforge\.net", original_host))
    )
    urls = []
    if is_direct_input:
        urls.append(("input-direct", original_url))
    for mirror in ranked:
        if mirror != "autoselect":
            # Download through the same router that was benchmarked: it provides
            # the mirror's current redirect/token instead of a bare CDN URL.
            urls.append((f"measured-{mirror}",
                         download_router_url(project, relative, mirror)))
    urls.append(("router-autoselect", download_router_url(project, relative)))
    for mirror in ("onboardcloud", "zenlayer", "twds", "psychz", "master"):
        urls.append((f"router-{mirror}",
                     download_router_url(project, relative, mirror)))
    # In some cases the router blocks byte-range probes but permits full GET.
    for mirror in MIRRORS:
        if mirror != "autoselect":
            urls.append((f"direct-{mirror}",
                         direct_mirror_url(project, relative, mirror)))
    urls.append(("direct-master", direct_mirror_url(project, relative, "master")))
    if not is_direct_input:
        urls.append(("input-original", original_url))
    # Last-resort UI URL. Some runners receive HTTP 403 here.
    urls.append(("web-download", canonical))
    deduplicated, seen = [], set()
    for name, url in urls:
        if url not in seen:
            deduplicated.append((name, url))
            seen.add(url)
    return deduplicated


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
            fields = done.stdout.strip().split("\t", 3)
            if done.returncode != 0:
                http_code = fields[0] if fields else ""
                reason = (f"http_{http_code}" if http_code.isdigit() and http_code != "000"
                          else f"curl_exit_{done.returncode}")
                return {"mirror": name, "status": "unavailable", "reason": reason}
            if len(fields) != 4:
                return {"mirror": name, "status": "unavailable", "reason": "invalid_probe_response"}
            code, received, speed, effective = fields
            if code != "206":
                # A full 200 response cannot safely benchmark an 8+ GiB ROM.
                return {"mirror": name, "status": "unavailable",
                        "reason": f"http_{code}_no_partial_content"}
            if int(float(received)) < MIN_SAMPLE_BYTES:
                return {"mirror": name, "status": "unavailable", "reason": "short_range"}
            with sample.open("rb") as f:
                header = f.read(4)
            if header != b"PK\x03\x04":
                return {"mirror": name, "status": "unavailable", "reason": "not_zip_header"}
            host = urlsplit(effective).hostname or ""
            return {
                "mirror": name, "status": "ok", "speed_bps": round(float(speed)),
                "speed_mib_s": round(float(speed) / (1024 * 1024), 2),
                "serving_host": host.lower(),
            }
        except (OSError, subprocess.TimeoutExpired, ValueError, IndexError):
            return {"mirror": name, "status": "unavailable", "reason": "probe failed"}


def benchmark(canonical, mirrors=MIRRORS):
    sf = normalize(canonical)
    if sf is None:
        raise ValueError("Benchmark requires a SourceForge URL")
    _, project, relative = sf
    # SourceForge signs and routes real downloads. Probe that same endpoint,
    # not unsigned direct CDN hosts that may reject otherwise usable mirrors.
    probe_targets = [
        (m, download_router_url(project, relative,
                                None if m == "autoselect" else m))
        for m in mirrors
    ]
    with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
        results = list(pool.map(probe, probe_targets))
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
    """Validate the entire downloaded archive before declaring mirror success."""
    if not output.is_file() or output.stat().st_size < 1024 or not zipfile.is_zipfile(output):
        return False
    try:
        test = subprocess.run(
            ["unzip", "-tq", str(output)],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
            timeout=600, check=False
        )
        return test.returncode == 0
    except (OSError, subprocess.TimeoutExpired):
        return False


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
            else:
                print(f"[MIRROR] {item['mirror']}: {item.get('reason', 'unavailable')} (range probe only)", flush=True)
        urls = candidate_urls(args.url, canonical, project, file_path, ordered)
        if not any(item["status"] == "ok" for item in probed):
            print("[WARN] Range benchmarks blocked/unavailable; will still try input "
                  "direct URL and SourceForge CDN/router fallback endpoints", flush=True)
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
                "selected_mirror": name, "probe_method": "sourceforge_router_range" if sf else None,
                "probes": probed,
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
        "file": file_path, "selected_mirror": None,
        "probe_method": "sourceforge_router_range" if sf else None,
        "probes": probed,
        "attempts": attempts,
    }, indent=2) + "\n")
    raise SystemExit("[ERROR] Download failed for every mirror")


if __name__ == "__main__":
    main()
