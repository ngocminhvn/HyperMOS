#!/usr/bin/env python3
"""Download pinned LiteGapps Android 17 ZIPs from the fastest tested SF mirror.

Reuses HyperMOS's SourceForge 1 MiB HTTP-range benchmark and aria2 mirror
downloader. Benchmark speeds are measured on the current GitHub runner;
unmeasurable mirrors are fallback candidates, never declared 'fastest'.
Every finished ZIP MUST match the SHA-256 supplied by sources.json.
"""
from __future__ import annotations

import hashlib
import importlib.util
import re
import time
import zipfile
from pathlib import Path, PurePosixPath

ROOT = Path(__file__).resolve().parents[4]
STOCK_DOWNLOADER = ROOT / "bin/dump/sourceforge_download.py"

MAX_MIRROR_ATTEMPTS = 7
MAX_PACKAGE_SECONDS = 660
PER_MIRROR_SECONDS = 180
SMALL_SAMPLE_BYTES = 1024 * 1024


def load_sourceforge():
    if not STOCK_DOWNLOADER.is_file():
        raise RuntimeError("Missing existing HyperMOS SourceForge downloader")
    spec = importlib.util.spec_from_file_location("hypermos_sourceforge", STOCK_DOWNLOADER)
    if spec is None or spec.loader is None:
        raise RuntimeError("Cannot import SourceForge mirror benchmark")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def sha256(path):
    result = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(8 * 1024 * 1024), b""):
            result.update(chunk)
    return result.hexdigest()


def fetch(entry, cache, *, driver=None, clock=time.monotonic):
    """Probe each mirror; try highest measured throughput first, then fallbacks.

    On connection errors keep aria2 partial data so the next mirror can resume.
    On a completed ZIP with wrong checksum, discard both ZIP and aria2 state.
    """
    url = entry["url"]
    expected = entry["sha256"].lower()
    if (not url.startswith("https://sourceforge.net/projects/litegapps/files/")
            or not re.fullmatch(r"[0-9a-f]{64}", expected)):
        raise ValueError("LiteGapps17: source URL or SHA-256 is not trusted")
    sf = driver if driver is not None else load_sourceforge()
    normalized = sf.normalize(url)
    if normalized is None or normalized[1] != "litegapps":
        raise ValueError("LiteGapps17: invalid SourceForge project URL")
    canonical, project, relative = normalized
    name = PurePosixPath(relative).name
    if not re.fullmatch(r"[A-Za-z0-9_.+-]+[.]zip", name):
        raise ValueError("LiteGapps17: unsafe archive name")
    cache.mkdir(parents=True, exist_ok=True)
    final = cache / name
    if final.is_file() and sha256(final) == expected and zipfile.is_zipfile(final):
        print(f"[LITEGAPPS17] Cached SHA-256 verified: {name}", flush=True)
        return final
    final.unlink(missing_ok=True)
    partial = cache / (name + ".part")
    control = cache / (name + ".part.aria2")

    print(f"[MIRROR] {name}: probing {len(sf.MIRRORS)} SourceForge routes "
          f"({SMALL_SAMPLE_BYTES // (1024 * 1024)} MiB per HTTP 206 sample)",
          flush=True)
    try:
        ranked, probes = sf.benchmark(canonical)
    except (OSError, ValueError, RuntimeError) as exc:
        print(f"[MIRROR] Probe unavailable ({exc}); using bounded SourceForge fallbacks",
              flush=True)
        ranked, probes = ["autoselect"], []

    verified = [p for p in probes if p.get("status") == "ok"]
    for probe in probes:
        if probe.get("status") == "ok":
            print(f"[MIRROR] {probe['mirror']}: "
                  f"{probe.get('speed_mib_s', 0):.2f} MiB/s "
                  f"via {probe.get('serving_host', 'unknown')}", flush=True)
        else:
            print(f"[MIRROR] {probe['mirror']}: "
                  f"{probe.get('reason', 'HTTP range unavailable')}", flush=True)
    if verified:
        top = max(verified, key=lambda p: p.get("speed_bps", 0))
        print(f"[MIRROR] Fastest MEASURED route for {name}: "
              f"{top['mirror']} at {top.get('speed_mib_s', 0):.2f} MiB/s",
              flush=True)
    else:
        print("[MIRROR] No trustworthy range measurement: "
              "SourceForge autoselect is only a fallback, not a measured winner",
              flush=True)

    candidates = sf.candidate_urls(url, canonical, project, relative, ranked)
    started = clock()
    failures = []
    for number, (route, candidate) in enumerate(candidates[:MAX_MIRROR_ATTEMPTS], 1):
        remaining = MAX_PACKAGE_SECONDS - (clock() - started)
        if remaining <= 0:
            print(f"[MIRROR] {name}: overall package deadline reached", flush=True)
            break
        deadline = max(1, min(PER_MIRROR_SECONDS, int(remaining)))
        print(f"[MIRROR] {name}: attempting {number}/{min(len(candidates), MAX_MIRROR_ATTEMPTS)} "
              f"{route}, watchdog={deadline}s, aria2 shows progress every 30s",
              flush=True)
        try:
            ok = sf.download(candidate, partial, connections=12,
                             attempt_timeout=deadline)
        except (OSError, RuntimeError) as exc:
            print(f"[MIRROR] {name}: {route} error: {exc}", flush=True)
            ok = False
        if not ok:
            failures.append(route)
            print(f"[MIRROR] {name}: {route} too slow/unavailable; switching mirror",
                  flush=True)
            continue
        if (not partial.is_file() or partial.stat().st_size < 1024
                or not zipfile.is_zipfile(partial)):
            failures.append(route)
            print(f"[MIRROR] {name}: {route} returned invalid/HTML data", flush=True)
            partial.unlink(missing_ok=True)
            control.unlink(missing_ok=True)
            continue
        actual = sha256(partial)
        if actual != expected:
            failures.append(route)
            print(f"[MIRROR] {name}: {route} SHA-256 mismatch; "
                  "discarding corrupted data and switching mirror", flush=True)
            partial.unlink(missing_ok=True)
            control.unlink(missing_ok=True)
            continue
        # ZIP integrity is checked later by stage.py's unpack_zip() (testzip).
        partial.replace(final)
        control.unlink(missing_ok=True)
        print(f"[MIRROR] {name}: downloaded from {route}, "
              f"{final.stat().st_size / (1024 * 1024):.1f} MiB, "
              "SHA-256 verified", flush=True)
        return final
    raise RuntimeError(f"LiteGapps17 download failed for {name} after "
                       f"{len(failures)} bounded mirror attempts; "
                       f"routes={','.join(failures)}")
