#!/usr/bin/env python3
"""Read-only PowerKeeper performance parity for Xiaomi 15 Pro/TNM A16.

Never import TNM binaries or touch thermal limits. The stock 3.0.308 versus
TNM 3.0.309 comparison can include Xiaomi base-version differences.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path

METHOD = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$")
CLASS = re.compile(r"(?m)^\.class[^\n]*\s(L[^;]+;)[ \t]*$")
FOCUS = re.compile(r"perf|thermal|power|boost|freq|cpu|gpu|fps|frame|sched|game|scenario|battery", re.I)
IGNORE = (".line", ".param", ".local", ".end local", ".restart local", ".prologue", "#")


def catalogue(root):
    classes = {}
    for file in root.rglob("*.smali"):
        source = file.read_text(encoding="utf-8", errors="replace")
        match = CLASS.search(source)
        if not match:
            continue
        cls = match.group(1)
        if cls in classes:
            raise ValueError(f"duplicate class {cls}")
        methods = {}
        for item in METHOD.finditer(source):
            body = item.group()
            sig = body.splitlines()[0].strip().split()[-1]
            norm = "\n".join(
                line.strip() for line in body.splitlines()
                if line.strip() and not line.lstrip().startswith(IGNORE)
            )
            methods[sig] = {
                "sha": hashlib.sha256(norm.encode("utf-8")).hexdigest()[:16],
                "tnm_reference": "Lcom/projectryu/" in norm,
                "tiktok_reference": "zhiliaoapp" in norm.lower()
                                    or "tiktok" in norm.lower()
                                    or "musically" in norm.lower(),
            }
        classes[cls] = methods
    return classes


def report(stock, tnm):
    a, b = catalogue(stock), catalogue(tnm)
    result = {
        "warning": "Read-only: Xiaomi stock 3.0.308 vs TNM 3.0.309 are not the same base.",
        "stock_classes": len(a),
        "tnm_classes": len(b),
        "tnm_private_classes": sorted(k for k in b if k.startswith("Lcom/projectryu/")),
        "performance_changes": [],
    }
    for cls in sorted(set(a) | set(b)):
        if not FOCUS.search(cls):
            continue
        old, new = a.get(cls, {}), b.get(cls, {})
        for sig in sorted(set(old) | set(new)):
            left, right = old.get(sig), new.get(sig)
            if left and right and left["sha"] == right["sha"]:
                continue
            result["performance_changes"].append({
                "class": cls, "method": sig,
                "state": "tnm-only" if not left else ("stock-only" if not right else "different"),
                "tnm_private_reference": bool(right and right["tnm_reference"]),
                "tiktok_reference": bool(right and right["tiktok_reference"]),
                "stock_hash": left["sha"] if left else None,
                "tnm_hash": right["sha"] if right else None,
            })
    return result


def markdown(data):
    lines = [
        "# HAOTIAN PowerKeeper performance audit (read only)", "",
        data["warning"], "",
        f"Stock classes: {data['stock_classes']}; TNM classes: {data['tnm_classes']}.",
        f"Performance-related method differences: {len(data['performance_changes'])}.",
        f"Private TNM classes: {len(data['tnm_private_classes'])}.", "",
        "## TNM-only class dependencies", "",
        *[f"- `{x}`" for x in data["tnm_private_classes"][:100]], "",
        "## Changed performance-related methods", "",
        "| Class | Method | State | Private dependency | TikTok literal |",
        "|---|---|---|---|---|",
    ]
    for item in data["performance_changes"][:300]:
        lines.append(
            f"| `{item['class']}` | `{item['method']}` | {item['state']} | "
            f"{item['tnm_private_reference']} | {item['tiktok_reference']} |"
        )
    if len(data["performance_changes"]) > 300:
        lines.append(f"\n... {len(data['performance_changes']) - 300} additional entries in JSON.")
    lines += [
        "", "## Migration safety constraints", "",
        "- No thermal safety disable, no -nolimit profiles, no hardcoded CPU/GPU frequencies.",
        "- Do not transplant PerfHook without dependency tracing and controlled device profiling.",
        "- Foreground TikTok heat cannot be attributed to FCM/Doze from this report.",
        "- Vendor/odm thermal and performance configurations are NOT covered by this APK audit.",
        "- Requires comparable on-device screen-on temperature/CPU/GPU measurements.", "",
    ]
    return "\n".join(lines)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--stock", type=Path, required=True)
    p.add_argument("--tnm", type=Path, required=True)
    p.add_argument("--out", type=Path, required=True)
    args = p.parse_args()
    for path in (args.stock, args.tnm):
        if not path.is_dir():
            p.error(f"missing decompiled APK directory: {path}")
    data = report(args.stock, args.tnm)
    args.out.mkdir(parents=True, exist_ok=True)
    (args.out / "tnm-performance-parity.json").write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    (args.out / "tnm-performance-parity.md").write_text(
        markdown(data), encoding="utf-8"
    )
    print(f"[TNM-PERF] {len(data['performance_changes'])} method differences; "
          f"{len(data['tnm_private_classes'])} private classes")
    print("[TNM-PERF] REPORT ONLY: no policy, thermal or binaries modified")


if __name__ == "__main__":
    main()
