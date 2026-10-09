#!/usr/bin/env python3
"""Read-only method/dependency inventory of RYU PerfHook from its PowerKeeper APK.

This intentionally DOES NOT copy proprietary smali into HyperMOS, write sysfs,
apply thermal settings or infer safe CPU/GPU limits from method names.
"""
import argparse
import json
import re
from collections import Counter
from pathlib import Path

METHOD = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$")
CLASS = re.compile(r"(?m)^\.class[^\n]*\s(L[^;]+;)[ \t]*$")
REF = re.compile(r"L[^;\s{}]+;")
TARGET = "Lcom/projectryu/perf/PerfHook;"
FOCUS = (
    "sconfig", "thermal", "perf", "governor", "cpu", "gpu",
    "freq", "screen", "foreground", "observer", "mode", "policy",
)
SENSITIVE = ("thermal-nolimits", "nolimit", "trip_point", "thermal_message", "scaling_max_freq", "gpu_max")


def classes(root):
    found = {}
    for file in root.rglob("*.smali"):
        content = file.read_text(encoding="utf-8", errors="replace")
        matched = CLASS.search(content)
        if matched:
            name = matched.group(1)
            if name in found:
                raise ValueError(f"Duplicate smali class {name}")
            found[name] = (file, content)
    return found


def signature(method):
    return method.splitlines()[0].strip().split()[-1]


def inventory(ryu_root, stock_root):
    ryu = classes(ryu_root)
    stock = classes(stock_root)
    if TARGET not in ryu:
        raise ValueError("RYU PerfHook not found in supplied PowerKeeper APK")
    perf_family = sorted(k for k in ryu if k == TARGET or k.startswith(TARGET[:-1] + "$"))
    methods = []
    outgoing = Counter()
    literals = set()
    direct_nodes = set()
    for name in perf_family:
        path, body = ryu[name]
        for m in METHOD.finditer(body):
            src = m.group()
            refs = sorted(set(REF.findall(src)) - {name})
            for ref in refs:
                if ref.startswith("Lcom/projectryu/"):
                    outgoing[ref] += 1
            strings = re.findall(r'const-string(?:/jumbo)?\s+[^,]+,\s*"([^"]{1,180})"', src)
            for item in strings:
                if any(term in item.lower() for term in FOCUS):
                    literals.add(item)
                if any(term in item.lower() for term in SENSITIVE):
                    direct_nodes.add(item)
            methods.append({
                "class": name,
                "signature": signature(src),
                "ryu_private_refs": sorted(ref for ref in refs if ref.startswith("Lcom/projectryu/")),
                "thermal_or_perf_related": any(s in signature(src).lower() for s in FOCUS),
                "node_writes_possible": any(s in src for s in ("Ljava/io/FileOutputStream;", "Ljava/io/RandomAccessFile;", "Landroid/system/Os;->write")),
            })
    callers = []
    for name, (_, body) in ryu.items():
        if name in perf_family:
            continue
        if TARGET in body:
            for m in METHOD.finditer(body):
                if TARGET in m.group():
                    callers.append({"class": name, "method": signature(m.group())})
    return {
        "ryu_classes": len(ryu),
        "stock_classes": len(stock),
        "perf_family": perf_family,
        "perf_method_count": len(methods),
        "method_inventory": methods,
        "ryu_private_dependencies": dict(outgoing.most_common()),
        "call_sites": sorted(callers, key=lambda x: (x["class"], x["method"])),
        "focused_string_literals": sorted(literals),
        "sensitive_node_literals": sorted(direct_nodes),
        "stock_has_ryu_perfhook": TARGET in stock,
        "notes": [
            "Signatures and string hints are not a verified implementation specification.",
            "Do not assume PERF_MODE or sconfig values have identical effects on Xiaomi stock vs RYU.",
            "Do not transplant whole APK or unsafe per-app CPU/GPU governor enforcement.",
            "Device boot and battery/thermal measurements are required after an independent port.",
        ],
    }


def markdown(report):
    lines = [
        "# RYU HAOTIAN PerfHook — real APK dependency map", "",
        "**Status: ANALYSIS ONLY — PerfHook is NOT ported by this workflow.**", "",
        f"RYU PowerKeeper classes: {report['ryu_classes']}; stock classes: {report['stock_classes']}.",
        f"PerfHook family: {len(report['perf_family'])} classes, {report['perf_method_count']} methods.", "",
        "## Activation call sites", "",
    ]
    for site in report["call_sites"]:
        lines.append(f"- `{site['class']}` → `{site['method']}`")
    lines += ["", "## RYU-private class dependencies", ""]
    for name, n in report["ryu_private_dependencies"].items():
        lines.append(f"- `{name}`: {n} method references")
    lines += ["", "## Relevant PerfHook methods", ""]
    for m in report["method_inventory"]:
        if m["thermal_or_perf_related"]:
            lines.append(f"- `{m['class']}` / `{m['signature']}` (private deps: {len(m['ryu_private_refs'])}; direct I/O: {m['node_writes_possible']})")
    lines += ["", "## Referenced settings / node strings", ""]
    for key in report["focused_string_literals"]:
        lines.append(f"- `{key.replace(chr(96), '')}`")
    lines += ["", "## Guardrails", ""]
    lines += [f"- {item}" for item in report["notes"]]
    return "\n".join(lines) + "\n"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--ryu", type=Path, required=True)
    parser.add_argument("--stock", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    result = inventory(args.ryu, args.stock)
    args.out.mkdir(parents=True, exist_ok=True)
    (args.out / "ryu-perfhook-dependency-map.json").write_text(
        json.dumps(result, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    (args.out / "ryu-perfhook-dependency-map.md").write_text(
        markdown(result), encoding="utf-8"
    )
    print(f"[RYU PERFHOOK] {result['perf_method_count']} methods, {len(result['call_sites'])} callsites, {len(result['ryu_private_dependencies'])} private dependencies")
    print("[RYU PERFHOOK] AUDIT ONLY. Thermal sysfs and PowerKeeper APK unchanged.")


if __name__ == "__main__":
    main()
