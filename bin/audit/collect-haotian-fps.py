#!/usr/bin/env python3
"""Read-only adb capture; keeps the measured app foreground on the phone.

Usage: python collect-haotian-fps.py --package com.zhiliaoapp.musically --label video
Optional --layer selects one exact name from SurfaceFlinger --list; --root
uses su only for these read-only dumps. No stats/settings are cleared/written.
FrameTracker columns: desiredPresentTime, actualPresentTime, frameReadyTime.
Source: https://android.googlesource.com/platform/frameworks/native/+/master/services/surfaceflinger/FrameTracker.cpp
Layer presentation cadence is not the physical LTPO panel refresh rate.
"""
import argparse
import datetime
import json
import re
import shlex
import shutil
import subprocess
import time
from pathlib import Path


def parse_latency(text):
    period = None
    times = set()
    for line in text.splitlines():
        parts = line.split()
        if len(parts) == 1 and parts[0].isdigit() and period is None:
            period = int(parts[0])
        elif len(parts) == 3 and all(x.isdigit() for x in parts):
            actual = int(parts[1])
            if 0 < actual < 9223372036854775807:
                times.add(actual)
    return period, sorted(times)


def summarize(before, after):
    period, times = parse_latency(after)
    _, old = parse_latency(before)
    if not old:
        return {'status': 'unavailable_no_baseline_timestamps', 'layer_fps': None}
    new = [t for t in times if t > old[-1]]
    result = {'new_present_timestamps': len(new), 'layer_fps': None,
              'nominal_period_ns_reported_by_surfaceflinger': period,
              'physical_ltpo_refresh_hz': 'not_measured'}
    if len(new) < 2:
        result['status'] = 'insufficient_new_frames_static_or_unavailable'
    else:
        span = (new[-1] - new[0]) / 1e9
        result.update(status='sampled_layer_presentation_cadence',
                      layer_fps=round((len(new) - 1) / span, 2),
                      timestamp_span_seconds=round(span, 4))
    return result


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--package', required=True)
    p.add_argument('--label', default='snapshot')
    p.add_argument('--layer')
    p.add_argument('--root', action='store_true')
    p.add_argument('--adb', default='adb')
    p.add_argument('--out', type=Path)
    a = p.parse_args()
    if not re.fullmatch(r'[A-Za-z0-9_]+(?:\.[A-Za-z0-9_]+)+', a.package):
        p.error('invalid package name')
    if not shutil.which(a.adb):
        p.error('adb not found; use platform-tools or --adb /path/to/adb')
    stamp = datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
    label = re.sub(r'[^A-Za-z0-9_-]', '_', a.label)
    out = a.out or Path(f'haotian-fps-{label}-{stamp}')
    out.mkdir(parents=True, exist_ok=True)

    def shell(*args):
        command = shlex.join(args)
        if a.root:
            command = shlex.join(['su', '-c', command])
        try:
            r = subprocess.run([a.adb, 'shell', command], capture_output=True,
                               text=True, encoding='utf-8', errors='replace', timeout=25)
            return r.stdout + r.stderr
        except subprocess.TimeoutExpired:
            return 'UNAVAILABLE: adb command timed out\n'

    if shell('getprop', 'ro.product.device').strip().lower() != 'haotian':
        p.error('authorized HAOTIAN adb device required')
    listing = shell('dumpsys', 'SurfaceFlinger', '--list')
    (out / 'layers.txt').write_text(listing, encoding='utf-8')
    candidates = [s for s in listing.splitlines() if a.package in s]
    if a.layer:
        selected = [a.layer] if a.layer in listing.splitlines() else []
    else:
        selected = sorted(candidates, key=lambda s: ('SurfaceView' not in s, s))[:3]
    before = {layer: shell('dumpsys', 'SurfaceFlinger', '--latency', layer)
              for layer in selected}
    time.sleep(2)
    results = {}
    for index, layer in enumerate(selected):
        after = shell('dumpsys', 'SurfaceFlinger', '--latency', layer)
        (out / f'layer-{index}-before.txt').write_text(before[layer], encoding='utf-8')
        (out / f'layer-{index}-after.txt').write_text(after, encoding='utf-8')
        results[layer] = summarize(before[layer], after)
    for filename, args in {
        'display.txt': ('dumpsys', 'display'),
        'surfaceflinger.txt': ('dumpsys', 'SurfaceFlinger'),
        'gfxinfo.txt': ('dumpsys', 'gfxinfo', a.package, 'framestats'),
        'battery.txt': ('dumpsys', 'battery'),
        'refresh-settings.txt': ('settings', '--user', '0', 'list', 'system'),
    }.items():
        content = shell(*args)
        if filename == 'refresh-settings.txt':
            content = '\n'.join(s for s in content.splitlines()
                                if re.search('refresh|fps', s, re.I))
        (out / filename).write_text(content, encoding='utf-8')
    summary = {'package': a.package, 'label': label, 'captured_at': stamp,
               'layers': results, 'matching_layers': candidates,
               'scope': 'per-layer recent presentation cadence, not whole-app or physical panel FPS',
               'ring_buffer_note': 'high FPS may leave less than two seconds of retained frames',
               'unavailable_note': 'empty/stale timestamps are not proof of zero FPS; no stats were cleared'}
    (out / 'summary.json').write_text(json.dumps(summary, indent=2), encoding='utf-8')
    print(json.dumps(summary, indent=2))
    print(f'Saved: {out.resolve()}')


if __name__ == '__main__':
    main()
