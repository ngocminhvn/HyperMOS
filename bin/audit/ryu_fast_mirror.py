#!/usr/bin/env python3
"""Benchmark SourceForge redirect mirrors with a 1 MiB byte-range probe.

Only HTTP 206 + ZIP signature is accepted. The original canonical URL is
always retained as a last-resort fallback. No full ROM is downloaded here.
"""
import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import json
from pathlib import Path
import subprocess
import tempfile
from time import monotonic
from urllib.parse import urlencode, urlparse

MIRRORS = ("auto", "cytranet", "netix", "phoenixnap", "versaweb", "pilotfiber",
           "jztkft", "netcologne")
RANGE_END = (1024 * 1024) - 1


def mirror_url(base, mirror):
    if mirror == "auto":
        return base
    return base + ("&" if "?" in base else "?") + urlencode({"use_mirror": mirror})


def probe(mirror, url):
    with tempfile.TemporaryDirectory(prefix="ryu-mirror-") as folder:
        target = Path(folder) / "probe.part"
        cmd = [
            "curl", "--silent", "--show-error", "--fail", "--location",
            "--connect-timeout", "7", "--max-time", "18", "--retry", "0",
            "--max-filesize", "2097152", "--range", f"0-{RANGE_END}",
            "--output", str(target),
            "--write-out", "%{http_code}|%{speed_download}|%{url_effective}", url
        ]
        t0 = monotonic()
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=22,
                              check=False)
        elapsed = max(monotonic() - t0, .001)
        info = proc.stdout.rsplit("|", 2)
        result = {"mirror": mirror, "url": url, "ok": False,
                  "speed_bytes_per_sec": 0, "elapsed_sec": round(elapsed, 3)}
        if proc.returncode or len(info) != 3 or not target.exists():
            result["error"] = (proc.stderr or f"curl exit {proc.returncode}")[-300:]
            return result
        code, speed, effective_url = info
        result["effective_host"] = urlparse(effective_url).hostname or ""
        data_size = target.stat().st_size
        result["bytes_probed"] = data_size
        if code == "206" and 262144 <= data_size <= 1048576:
            with target.open("rb") as f:
                is_zip = f.read(4) == b"PK\x03\x04"
            if is_zip:
                result["ok"] = True
                result["speed_bytes_per_sec"] = round(data_size / elapsed)
                return result
        result["error"] = f"Bad range response: HTTP {code}, bytes {data_size}, ZIP header invalid"
        return result


def run(base, out_urls, out_report):
    if not base.startswith("https://downloads.sourceforge.net/project/"):
        raise ValueError("Expected pinned SourceForge HTTPS project download URL")
    candidates = {name: mirror_url(base, name) for name in MIRRORS}
    results = []
    with ThreadPoolExecutor(max_workers=5) as pool:
        jobs = {pool.submit(probe, name, url): name
                for name, url in candidates.items()}
        for future in as_completed(jobs):
            try:
                result = future.result()
            except Exception as exc:
                result = {"mirror": jobs[future], "url": candidates[jobs[future]],
                          "ok": False, "error": repr(exc)}
            results.append(result)
    ranked = sorted((r for r in results if r["ok"]),
                    key=lambda r: r["speed_bytes_per_sec"], reverse=True)
    # Canonical automatic SourceForge routing must always remain available.
    urls = [r["url"] for r in ranked]
    if base not in urls:
        urls.append(base)
    out_urls.parent.mkdir(parents=True, exist_ok=True)
    out_report.parent.mkdir(parents=True, exist_ok=True)
    out_urls.write_text("\n".join(urls) + "\n", encoding="utf-8")
    out_report.write_text(json.dumps({
        "method": "1MiB HTTP 206 range GET from current GitHub runner",
        "ranking": ranked, "probes": results,
        "note": "Fastest among verified sample mirrors, not a guarantee of sustained full-file speed.",
        "fallback": base
    }, indent=2) + "\n", encoding="utf-8")
    for r in ranked:
        print(f'[RYU MIRROR] PASS {r["mirror"]}: {r["speed_bytes_per_sec"] / 1048576:.2f} MiB/s on 1MiB sample')
    for r in results:
        if not r["ok"]:
            print(f'[RYU MIRROR] SKIP {r["mirror"]}: {r.get("error","unknown")}')
    print(f'[RYU MIRROR] {len(ranked)} valid sample mirrors; canonical fallback enabled')


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", required=True)
    parser.add_argument("--urls", required=True, type=Path)
    parser.add_argument("--report", required=True, type=Path)
    args = parser.parse_args()
    run(args.url, args.urls, args.report)
