#!/usr/bin/env python3
"""Read-only, source-qualified ROM comparison: ZK HAOTIAN vs Xiaomi and MOS main.

Inputs are decoded smali trees. The report identifies differences but cannot
prove battery-life/notification runtime behavior without device measurements.
"""
from __future__ import annotations

import argparse
from collections import Counter
from difflib import unified_diff
import hashlib
import json
from pathlib import Path
import re

CLASS_RE = re.compile(r"(?m)^\.class\s+[^\n]*?\s+(L[^;\n]+;)\s*$")
METHOD_RE = re.compile(r"(?ms)^\.method\s+[^\n]*\n.*?^\.end method[ \t]*$")
IGNORE = (".line", ".param", ".local", ".end local", ".restart local", ".prologue", "#")
AREAS = {
    "notification_fcm": re.compile(r"fcm|c2dm|gms|google|notification|broadcast|push|alarm|wake|doze|deviceidle", re.I),
    "background_kill": re.compile(r"kill|greeze|freeze|millet|process|appstate|foregroundservice|powerkeeper", re.I),
    "cpu_thermal_power": re.compile(r"perf|thermal|powerhint|cpu|gpu|boost|freq|sched|governor|battery|game|fps|frame|scene", re.I),
}
SIGNALS = {
    "GMS package": "com.google.android.gms",
    "FCM receiver": "com.google.android.c2dm",
    "Kill ProcessManager": "Lmiui/process/ProcessManager;->kill",
    "Foreground service": "hasForegroundServices()Z",
    "GMS limiter": "isGmsControlEnabled()Z",
    "MILLET whitelist": "MILLET_NO_RESTRICT_APP",
    "International build gate": "IS_INTERNATIONAL_BUILD:Z",
    "PerfHook": "PerfHook",
    "TikTok package": "zhiliaoapp.musically",
    "Doze": "DeviceIdleController",
}


def normalized(method: str) -> str:
    return "\n".join(
        line.strip() for line in method.splitlines()
        if line.strip() and not line.lstrip().startswith(IGNORE)
    )


def catalogue(root: Path) -> dict:
    items = {}
    for module in sorted(root.iterdir()) if root.exists() else []:
        if not module.is_dir():
            continue
        for path in sorted(module.rglob("*.smali")):
            text = path.read_text(errors="replace", encoding="utf-8")
            cls = CLASS_RE.search(text)
            if not cls:
                continue
            key = module.name + ":" + cls.group(1)
            if key in items:
                raise RuntimeError(f"Duplicate class: {key}")
            methods = {}
            for match in METHOD_RE.finditer(text):
                source = normalized(match.group())
                signature = source.splitlines()[0].split()[-1]
                if signature in methods:
                    raise RuntimeError(f"Duplicate method: {key}/{signature}")
                methods[signature] = {
                    "sha256": hashlib.sha256(source.encode()).hexdigest(),
                    "source": source,
                }
            items[key] = methods
    return items


def category(key: str, method: str) -> list[str]:
    return [name for name, pattern in AREAS.items() if pattern.search(key + " " + method)]


def src_inventory(src_root: Path) -> dict:
    descriptions = {
        "MILLET_NO_RESTRICT_APP": "GMS exempted from Millet restrictions",
        "IS_INTERNATIONAL_BUILD": "China/international policy gate",
        "GmsObserver": "Dedicated GMS control",
        "setUidState": "UID process-stop path",
        "PowerKeeper": "PowerKeeper APK build-time modifications",
        "DeviceIdle": "Doze controls",
        "BroadcastQueue": "Notification broadcasts",
        "thermal": "Thermal policy",
        "PerfHook": "Application performance decisions",
    }
    result = {}
    for rel in (
        "bin/package/NOTIFICATION_FIX/A16/PowerKeeper.sh",
        "bin/package/COREPATCH/jar_patcher_a16.sh",
        "bin/package/NOTIFICATION_FIX",
        "bin/package/COREPATCH",
    ):
        target = src_root / rel
        files = [target] if target.is_file() else (
            list(target.rglob("*.py")) + list(target.rglob("*.sh"))
            if target.is_dir() else []
        )
        for path in files:
            if not path.is_file() or path.stat().st_size > 1024 * 1024:
                continue
            text = path.read_text(encoding="utf-8", errors="replace")
            hits = [desc for k, desc in descriptions.items() if k.lower() in text.lower()]
            if hits:
                result[str(path.relative_to(src_root))] = {
                    "sha256": hashlib.sha256(text.encode()).hexdigest(),
                    "matched_areas": sorted(set(hits)),
                }
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--zk", type=Path, required=True)
    parser.add_argument("--stock", type=Path, required=True)
    parser.add_argument("--mos-main", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    cand, base = catalogue(args.zk), catalogue(args.stock)
    if not cand:
        raise SystemExit("ERROR: no ZK APK/JAR successfully decoded; no comparison possible.")
    mos = src_inventory(args.mos_main)
    combined_keys = sorted(set(cand) | set(base))
    changes = []
    candidate_methods = sum(map(len, cand.values()))
    counters = Counter()
    for cls in combined_keys:
        left, right = base.get(cls, {}), cand.get(cls, {})
        for sig in sorted(set(left) | set(right)):
            a, b = left.get(sig), right.get(sig)
            if a and b and a["sha256"] == b["sha256"]:
                continue
            areas = category(cls, sig)
            if not areas and not any(s.lower() in (b or a or {}).get("source", "").lower()
                                     for s in SIGNALS.values()):
                continue
            state = "ZK only" if not a else "Xiaomi only" if not b else "changed"
            sample = (b or {}).get("source", "")
            signals = [name for name, token in SIGNALS.items() if token.lower() in sample.lower()]
            rec = {
                "module_class": cls, "method": sig, "state": state,
                "areas": areas, "signals_in_zk": signals,
                "xiaomi_sha256": a["sha256"] if a else None,
                "zk_sha256": b["sha256"] if b else None,
            }
            changes.append(rec)
            counters.update(areas)
    changes.sort(key=lambda r: (
        -int("notification_fcm" in r["areas"]),
        -int("background_kill" in r["areas"]),
        -int("cpu_thermal_power" in r["areas"]),
        r["module_class"], r["method"],
    ))
    diffs = []
    count = 0
    for item in changes:
        if item["state"] != "changed":
            continue
        cls, sig = item["module_class"], item["method"]
        if not re.search(
            r"GmsObserver|KillProcessController|MilletConfig|PowerKeeperApplication|"
            r"PerfHook|ProcessSceneCleaner|DeviceIdleController|BroadcastQueue|"
            r"Greeze|ActiveStateController|PowerManagerService",
            cls, re.I,
        ):
            continue
        a, b = base[cls][sig]["source"], cand[cls][sig]["source"]
        lines = list(unified_diff(a.splitlines(), b.splitlines(), fromfile="Xiaomi", tofile="ZK", lineterm=""))
        if len(lines) < 3:
            continue
        diffs.append(f"### {cls} / {sig}\n\n" + "\n".join(lines[:85]) + 
                     ("\n... diff truncated" if len(lines) > 85 else "") + "\n")
        count += 1
        if count >= 80:
            break
    signals_total = {}
    for name, token in SIGNALS.items():
        matched = []
        for cls, methods in cand.items():
            for sig, record in methods.items():
                if token.lower() in record["source"].lower():
                    matched.append(cls + "/" + sig)
        signals_total[name] = {"count": len(matched), "examples": matched[:15]}
    result = {
        "disclaimer": (
            "ZK and Xiaomi OS3.0.308.0 may have different base versions. "
            "The MOS main comparison is of PATCH SOURCE, not a flashed/compiled MOS APK. "
            "Source changes alone do not establish battery, heat or notification improvements."
        ),
        "zk_class_count": len(cand), "zk_method_count": candidate_methods,
        "stock_class_count": len(base), "stock_available": bool(base),
        "changes_by_area": dict(counters),
        "changes": changes,
        "candidate_signals": signals_total,
        "mos_main_patch_inventory": mos,
    }
    (args.output / "zk-mos-comparison.json").write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    (args.output / "selected-method-diffs.md").write_text(
        "# Focused Xiaomi vs ZK smali diffs\n\n"
        + ("Differences not available: stock baseline absent.\n" if not base else "")
        + "\n".join(diffs), encoding="utf-8"
    )
    lines = [
        "# ZK HAOTIAN vs HyperMOS analysis", "",
        "## Verification limits", "", result["disclaimer"], "",
        f"Decoded ZK classes: {len(cand)}; methods: {candidate_methods}.",
        f"Decoded Xiaomi classes: {len(base)}.",
        f"Changed focus methods: {len(changes)}.", "",
        "## Key differences by area", "",
        "| Area | Method changes |", "|---|---:|",
    ]
    lines += [f"| {name} | {counters.get(name, 0)} |" for name in AREAS]
    lines += ["", "## Runtime-policy signals in ZK", "",
              "| Signal | ZK methods referencing it |", "|---|---:|"]
    lines += [f"| {name} | {v['count']} |" for name, v in signals_total.items()]
    lines += ["", "## Highest-priority changed methods", "",
              "| Module and class | Method | Direction | Focus |",
              "|---|---|---|---|"]
    for x in changes[:150]:
        lines.append("| " + " | ".join([
            x["module_class"].replace("|", "\\|"),
            x["method"].replace("|", "\\|"),
            x["state"], ", ".join(x["areas"]),
        ]) + " |")
    lines += [
        "", "## Main branch patch implementation (source only)", "",
        "| Source path | Existing patch topics |", "|---|---|",
    ]
    for path, obj in sorted(mos.items()):
        lines.append(f"| {path} | {', '.join(obj['matched_areas'])} |")
    lines += [
        "", "## Recommended decision procedure", "",
        "1. Read selected-method-diffs.md and confirm exact method behavior, not just hash changes.",
        "2. Prefer the smallest isolated framework/whitelist patch that fixes actual delivery failures.",
        "3. Keep original Xiaomi-signed PowerKeeper unless package signing/privileged permissions are verified.",
        "4. Never copy whole PowerKeeper/thermal partitions between dissimilar OS bases.",
        "5. Validate on-device notification latency, idle drain, CPU/GPU utilization, and protected thermal throttling.",
        "",
    ]
    (args.output / "REPORT.md").write_text("\n".join(lines), encoding="utf-8")
    print(f"REPORT READY: ZK {len(cand)} classes; Xiaomi {len(base)} classes; {len(changes)} focused changed methods")


if __name__ == "__main__":
    main()
