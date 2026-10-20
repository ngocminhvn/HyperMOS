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
    # Respect the benchmark order even when SourceForge's "autoselect"
    # route was fastest. It used to be pushed behind slower measured mirrors.
    for mirror in ranked:
        if mirror == "autoselect":
            urls.append(("router-autoselect",
                         download_router_url(project, relative)))
        else:
            # Use the router for signed redirects to the tested real CDN.
            urls.append((f"measured-{mirror}",
                         download_router_url(project, relative, mirror)))
    # Keep autoselect available even when its range probe was unavailable.
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



def classify_mirror_selection(route, probes):
    """Distinguish measured throughput from SourceForge's own fallback routing.

    A completed ZIP download does not prove that we measured this route as the
    fastest. SourceForge may return 403 to every bounded HTTP Range probe even
    though a full aria2 download from its autoselect router works correctly.
    """
    verified = {item["mirror"]: item.get("probe_method", "range") for item in probes if item.get("status") == "ok"}
    if route == "router-autoselect":
        if "autoselect" in verified:
            return ("bounded_get_measured" if verified["autoselect"] == "bounded_get"
                    else "range_measured")
        return "sourceforge_autoselect_fallback"
    if route.startswith("measured-") and route[len("measured-"):] in verified:
        method = verified[route[len("measured-"):]]
        return "bounded_get_measured" if method == "bounded_get" else "range_measured"
    if route == "input-direct":
        return "original_direct_url"
    return "unverified_fallback"


def mirror_selection_label(method):
    return {
        "range_measured": "Selected from measured HTTP 206 range routes (not guaranteed globally fastest)",
        "bounded_get_measured": "Selected from bounded GET mirror samples (not guaranteed globally fastest)",
        "sourceforge_autoselect_fallback":
            "SourceForge autoselect fallback (not measured as fastest)",
        "original_direct_url": "User-supplied direct SourceForge URL (not benchmark winner)",
        "unverified_fallback": "Fallback route (not measured as fastest)",
    }[method]


def download(url, output, connections=8, attempt_timeout=0):
    """One aria2 transfer; a list of URLs is ONE download with multiple mirrors.

    Only callers opting in to the RYU-EU speed flags change the default
    connection count and watchdog. aria2's control file enables continuation
    when the next candidate points to the same unchanged source archive.
    """
    output.parent.mkdir(parents=True, exist_ok=True)
    sources = [url] if isinstance(url, str) else list(url)
    cmd = [
        "aria2c", "--file-allocation=none", "--max-tries=3",
        "--retry-wait=4", "--connect-timeout=20", "--timeout=45",
        "--lowest-speed-limit=12K",
        f"--max-connection-per-server={min(connections, 16)}",
        f"--split={min(connections, 16)}",
        "--min-split-size=1M" if connections > 8 else "--min-split-size=4M",
        "--continue=true", "--auto-file-renaming=false",
        "--dir", str(output.parent), "--out", output.name, *sources,
    ]
    print(f"[DOWNLOAD] aria2 connections={min(connections, 16)}, "
          f"sources={len(sources)}, attempt_timeout={attempt_timeout or 'unlimited'}s",
          flush=True)
    try:
        done = subprocess.run(cmd, check=False,
                              timeout=attempt_timeout if attempt_timeout > 0 else None)
        return done.returncode == 0
    except subprocess.TimeoutExpired:
        print("[WARN] aria2 mirror attempt exceeded the per-attempt deadline; "
              "trying another source while preserving resumable data", flush=True)
        return False


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
    ap.add_argument("--mirror-plan", type=Path, help="Optional pre-benchmarked SourceForge mirror plan")
    # Opt-in RYU-EU tuning; other workflows keep their previous download order.
    ap.add_argument("--parallel-mirrors", type=int, default=1,
                    help="Use several ranked SourceForge mirrors for ONE aria2 download")
    ap.add_argument("--attempt-timeout-seconds", type=int, default=0,
                    help="Move to the next mirror after this many seconds (0 disables)")
    ap.add_argument("--max-mirror-attempts", type=int, default=0,
                    help="Limit total mirror attempts (0 retains old unlimited fallback)")
    ap.add_argument("--connections", type=int, default=8)
    args = ap.parse_args()
    if not (1 <= args.parallel_mirrors <= 5 and 1 <= args.connections <= 16):
        ap.error("parallel-mirrors must be 1..5 and connections must be 1..16")
    if args.attempt_timeout_seconds < 0 or args.max_mirror_attempts < 0:
        ap.error("attempt timeout and maximum mirror attempts must be nonnegative")
    sf = normalize(args.url)
    output = args.output.resolve()
    started = time.monotonic()
    if sf:
        canonical, project, file_path = sf
        print(f"[SOURCEFORGE] Project: {project}, file: {file_path}", flush=True)
        print(f"[SOURCEFORGE] Probing {len(MIRRORS)} SourceForge routes (1 MiB max; requires HTTP 206)", flush=True)
        if args.mirror_plan:
            plan = json.loads(args.mirror_plan.read_text(encoding="utf-8"))
            if (plan.get("version") != 1
                or plan.get("canonical_url") != canonical
                or plan.get("project") != project
                or plan.get("file") != file_path):
                raise SystemExit("[ERROR] Mirror plan does not match this ROM URL")
            ordered = plan.get("ranked")
            probed = plan.get("probes")
            if (not isinstance(ordered, list) or not ordered
                or not all(isinstance(m, str) and m in MIRRORS for m in ordered)
                or not isinstance(probed, list)
                or any(not isinstance(item, dict) for item in probed)):
                raise SystemExit("[ERROR] Invalid SourceForge mirror plan")
            print(f"[MIRROR] Using pre-benchmarked mirror plan: {', '.join(ordered)}",
                  flush=True)
        else:
            ordered, probed = benchmark(canonical)
        for item in probed:
            if item["status"] == "ok":
                print(f"[MIRROR] {item['mirror']}: {item['speed_mib_s']} MiB/s via {item['serving_host']}", flush=True)
            else:
                print(f"[MIRROR] {item['mirror']}: {item.get('reason', 'unavailable')} (range probe only)", flush=True)
        urls = candidate_urls(args.url, canonical, project, file_path, ordered)
        if not any(item["status"] == "ok" for item in probed):
            print("[MIRROR] 0 verified speed samples; using SourceForge "
                  "router/fallback (no fastest mirror could be determined)", flush=True)
    else:
        print("[DOWNLOAD] Non-SourceForge URL: using original direct download", flush=True)
        project = None
        file_path = None
        probed = []
        urls = [("direct", args.url)]
    # aria2 accepts several HTTP URIs as mirrors of the SAME file; it can
    # spread 16 connections across distinct SourceForge servers. For RYU-EU,
    # prioritize the measured URLs as a single parallel attempt before
    # falling back to the original per-mirror candidates.
    if sf and args.parallel_mirrors > 1:
        ranked_candidates = [item for item in urls
                             if item[0].startswith("measured-")
                             or item[0] == "router-autoselect"]
        ranked_candidates = ranked_candidates[:args.parallel_mirrors]
        if len(ranked_candidates) > 1:
            names = ", ".join(label for label, _ in ranked_candidates)
            print(f"[MIRROR] Concurrent SourceForge mirrors: {names}", flush=True)
            urls = [("parallel-ranked", [link for _, link in ranked_candidates])] + urls
    if args.max_mirror_attempts:
        urls = urls[:args.max_mirror_attempts]
    attempts = []
    for name, url in urls:
        print(f"[DOWNLOAD] Trying {name}", flush=True)
        success = download(url, output, connections=args.connections,
                           attempt_timeout=args.attempt_timeout_seconds)
        if success and valid_zip(output):
            print(f"[DOWNLOAD] ZIP received from {name} ({output.stat().st_size} bytes)", flush=True)
            attempts.append({"mirror": name, "result": "ok"})
            selection_method = classify_mirror_selection(name, probed) if sf else "direct"
            verified_speed_samples = sum(item.get("status") == "ok" for item in probed)
            if sf:
                print(f"[MIRROR] Selection: {mirror_selection_label(selection_method)} "
                      f"| verified speed samples: {verified_speed_samples}", flush=True)
            report = {
                "type": "SourceForge" if sf else "direct",
                "project": project, "file": file_path,
                "selected_mirror": name,
                "selection_method": selection_method,
                "speed_benchmark_verified": selection_method in (
                    "range_measured", "bounded_get_measured"),
                "verified_speed_samples": verified_speed_samples,
                "verified_range_probes": sum(p.get("status") == "ok" and
                                             p.get("probe_method", "range") != "bounded_get"
                                             for p in probed),
                "probe_method": "bounded_get" if args.mirror_plan else (
                    "sourceforge_router_range" if sf else None),
                "probes": probed,
                "attempts": attempts, "elapsed_seconds": round(time.monotonic() - started, 1),
            }
            args.report.parent.mkdir(parents=True, exist_ok=True)
            args.report.write_text(json.dumps(report, indent=2) + "\n")
            return
        print(f"[WARN] {name} failed or returned non-ZIP content; trying next mirror", flush=True)
        attempts.append({"mirror": name, "result": "failed"})
        control = Path(str(output) + ".aria2")
        if not success or output.is_file():
            # aria2's sidecar tracks verified pieces. Reuse only when a
            # legitimate interrupted transfer left both file and sidecar.
            # A successful transfer with invalid ZIP is not a safe partial.
            if not success and output.is_file() and control.is_file():
                print("[DOWNLOAD] Keeping partial ROM and aria2 resume control "
                      "for next mirror", flush=True)
                continue
        output.unlink(missing_ok=True)
        control.unlink(missing_ok=True)
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps({
        "type": "SourceForge" if sf else "direct", "project": project,
        "file": file_path, "selected_mirror": None,
        "selection_method": None, "speed_benchmark_verified": False,
        "verified_speed_samples": sum(item.get("status") == "ok" for item in probed),
        "verified_range_probes": sum(item.get("status") == "ok" and
                                     item.get("probe_method", "range") != "bounded_get"
                                     for item in probed),
        "probe_method": "bounded_get" if args.mirror_plan else (
            "sourceforge_router_range" if sf else None),
        "probes": probed,
        "attempts": attempts,
    }, indent=2) + "\n")
    raise SystemExit("[ERROR] Download failed for every mirror")


if __name__ == "__main__":
    main()
