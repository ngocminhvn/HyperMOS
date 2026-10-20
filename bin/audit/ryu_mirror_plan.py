#!/usr/bin/env python3
"""Rank SourceForge mirrors from a GitHub runner using bounded HTTP GET samples.

Never downloads the complete ROM while probing; at most 2 MiB per route.
This is separate from the general SourceForge downloader so other workflows
keep their existing behavior.
"""
from __future__ import annotations

import argparse
import concurrent.futures
import json
import time
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import urlsplit
from urllib.request import Request, urlopen

from bin.dump import sourceforge_download as sf

SAMPLE_BYTES = 2 * 1024 * 1024
MIN_BYTES = 128 * 1024


def probe(mirror: str, project: str, relative: str) -> dict:
    url = sf.download_router_url(project, relative,
                                 None if mirror == "autoselect" else mirror)
    headers = {"User-Agent": "Mozilla/5.0 (HyperMOS RYU-EU mirror tester)",
               "Accept-Encoding": "identity"}
    result = {"mirror": mirror, "probe_method": "bounded_get",
              "sample_limit_bytes": SAMPLE_BYTES}
    started = time.monotonic()
    try:
        req = Request(url, headers=headers)
        with urlopen(req, timeout=9) as response:
            code = response.getcode()
            serving = (urlsplit(response.geturl()).hostname or "").lower()
            first = response.read(4)
            if first != b"PK\\x03\\x04":
                return {**result, "status": "unavailable",
                        "reason": f"non_zip_header_http_{code}",
                        "serving_host": serving}
            consumed = 4
            while consumed < SAMPLE_BYTES:
                if time.monotonic() - started > 12:
                    break
                chunk = response.read(min(65536, SAMPLE_BYTES - consumed))
                if not chunk:
                    break
                consumed += len(chunk)
            elapsed = max(time.monotonic() - started, 0.001)
            if consumed < MIN_BYTES or code not in (200, 206):
                return {**result, "status": "unavailable",
                        "reason": f"short_sample_http_{code}",
                        "bytes": consumed, "serving_host": serving}
            return {**result, "status": "ok",
                    "bytes": consumed, "seconds": round(elapsed, 3),
                    "speed_bps": round(consumed / elapsed),
                    "speed_mib_s": round(consumed / elapsed / 1048576, 2),
                    "http_status": code, "serving_host": serving}
    except (HTTPError, URLError, OSError, TimeoutError, ValueError) as exc:
        return {**result, "status": "unavailable",
                "reason": f"{type(exc).__name__}: {str(exc)[:100]}"}


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--url", required=True)
    ap.add_argument("--output", required=True, type=Path)
    args = ap.parse_args()

    normalized = sf.normalize(args.url)
    if not normalized:
        raise SystemExit("Not a valid SourceForge URL")
    canonical, project, relative = normalized
    print(f"[MIRROR] Benchmarking {len(sf.MIRRORS)} RYU-EU routes with "
          f"at most {SAMPLE_BYTES // 1048576} MiB GET per mirror",
          flush=True)
    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as pool:
        probes = list(pool.map(lambda m: probe(m, project, relative), sf.MIRRORS))
    probes.sort(key=lambda p: p.get("speed_bps", 0), reverse=True)
    ranked = []
    seen_hosts = set()
    for item in probes:
        if item["status"] == "ok":
            print(f"[MIRROR] {item['mirror']}: {item['speed_mib_s']:.2f} MiB/s "
                  f"({item['bytes']} bytes, {item['seconds']}s) "
                  f"via {item['serving_host']}", flush=True)
            host = item["serving_host"]
            if host not in seen_hosts:
                ranked.append(item["mirror"])
                seen_hosts.add(host)
        else:
            print(f"[MIRROR] {item['mirror']}: {item['reason']}", flush=True)
    if "autoselect" not in ranked:
        ranked.append("autoselect")
    verified = sum(p["status"] == "ok" for p in probes)
    if verified:
        print(f"[MIRROR] Fastest measured route: {ranked[0]} "
              "(short GET sample, not a guarantee for the whole ROM)", flush=True)
    else:
        print("[MIRROR] No measurable source accepted bounded GET; "
              "falling back to SourceForge autoselect and alternate routes",
              flush=True)
    report = {
        "version": 1, "canonical_url": canonical, "project": project,
        "file": relative, "probe_method": "bounded_get",
        "sample_limit_bytes": SAMPLE_BYTES,
        "ranked": ranked, "probes": probes,
        "verified_speed_samples": verified,
        "fastest_measured": ranked[0] if verified else None,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\\n", encoding="utf-8")


if __name__ == "__main__":
    main()
