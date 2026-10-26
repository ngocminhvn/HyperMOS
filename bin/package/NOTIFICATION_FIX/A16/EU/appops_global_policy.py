#!/usr/bin/env python3
"""Apply only the 3 EU-vs-Global/Taiwan AppOpsServiceStubImpl gate deltas.

Original EU: invoke AppOpsUtils.isXOptMode() into a boolean register.
Both DADA Global303 and Taiwan303: read Build.IS_INTERNATIONAL_BUILD instead.
No blanket AppOps exemption, signature, autostart or permission grant.
"""
import argparse
import json
import re
from pathlib import Path

CLASS = "com/android/server/AppOpsServiceStubImpl.smali"
GATE = "Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z"
CALL = "Landroid/miui/AppOpsUtils;->isXOptMode()Z"
METHOD = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$")
SIGNATURES = (
    "ignoreUsage(Ljava/lang/String;IIIIILjava/lang/String;)Z",
    "isSupportVirtualGrant(I)Z",
    "systemReady()V",
)
PAIR = re.compile(
    r"(?m)^[ \t]*invoke-static \{\}, " + re.escape(CALL) +
    r"[ \t]*\n[ \t]*move-result ([vp]\d+)[ \t]*$"
)

def modify(source):
    matches = list(METHOD.finditer(source))
    changes = {}
    result = source
    for sig in SIGNATURES:
        candidates = [m for m in matches if m.group().splitlines()[0].endswith(" " + sig)]
        if len(candidates) != 1:
            raise ValueError(f"{sig}: expected exactly one method, found {len(candidates)}")
        orig = candidates[0].group()
        if GATE in orig or len(PAIR.findall(orig)) != 1:
            raise ValueError(f"{sig}: unexpected original EU XOpt gate")
        updated, n = PAIR.subn(lambda m: "    sget-boolean " + m.group(1) + ", " + GATE, orig)
        if n != 1 or updated == orig:
            raise ValueError(f"{sig}: no gate replacement")
        changes[sig] = (orig, updated)
    for sig, (old, new) in changes.items():
        if result.count(old) != 1:
            raise ValueError("Duplicate method text: " + sig)
        result = result.replace(old, new, 1)
    return result, list(changes)

def verify(source):
    methods = list(METHOD.finditer(source))
    for sig in SIGNATURES:
        ms = [m.group() for m in methods if m.group().splitlines()[0].endswith(" " + sig)]
        if len(ms) != 1 or ms[0].count(GATE) != 1 or CALL in ms[0]:
            raise ValueError(f"{sig}: compiled Global/Taiwan gate is not present")
    return {"class": CLASS, "methods": list(SIGNATURES),
            "reference": "DADA Global303 == Taiwan303",
            "gate": GATE}

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--root", type=Path, required=True)
    p.add_argument("--verify", action="store_true")
    p.add_argument("--report", type=Path)
    args = p.parse_args()
    hits = list(args.root.rglob(CLASS))
    if len(hits) != 1:
        raise SystemExit(f"{CLASS}: expected one class, found {len(hits)}")
    file = hits[0]
    if args.verify:
        report = verify(file.read_text(encoding="utf-8"))
    else:
        before = file.read_text(encoding="utf-8")
        after, names = modify(before)
        report = verify(after)
        file.write_text(after, encoding="utf-8")
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("[EU GLOBAL/TW APPOPS] " + json.dumps(report))

if __name__ == "__main__":
    try: main()
    except (ValueError, OSError) as e:
        raise SystemExit("[EU GLOBAL/TW APPOPS] FAIL: " + str(e))
