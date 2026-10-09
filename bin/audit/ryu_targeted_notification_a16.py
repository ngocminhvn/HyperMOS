#!/usr/bin/env python3
"""Focused, read-only HAOTIAN RYU vs Xiaomi notification/JAR audit.

Never ports broad force-stop policies, notification AppOp bypasses, PerfHook,
or private RYU classes. A stock/RYU difference is NOT proof of a RYU fix.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path

METHOD = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method\s*$")
IGNORE = (".line", ".param", ".local", ".end local", ".restart local",
          ".prologue", ".epilogue", "#")
INVOKE = re.compile(r"\binvoke-[\w/-]+\s+\{[^}]*\},\s*(\S+)")
FOCUS = {
    "BroadcastQueueModernStubImpl": ("checkApplicationAutoStart(",),
    "ProcessSceneCleaner": ("handleSwipeKill(", "killAppForHasOtherTask("),
    "ProcessManagerService": ("isForceStopEnable(",),
}
SECURITY_SENSITIVE = ("checkFullScreenIntent", "AppOp", "Permission")


def read_class(folder: Path, name: str, required: bool = True):
    hits = list(folder.rglob(name + ".smali"))
    if not hits and not required:
        return ""
    if len(hits) != 1:
        raise ValueError(f"{folder}: {name}.smali count={len(hits)}")
    return hits[0].read_text(encoding="utf-8")


def methods(source: str):
    out = {}
    for match in METHOD.finditer(source):
        block = match.group()
        sig = block.splitlines()[0].strip().split()[-1]
        normalized = "\n".join(
            x.strip() for x in block.splitlines()
            if x.strip() and not x.strip().startswith(IGNORE))
        if sig in out:
            raise ValueError(f"Duplicate method: {sig}")
        out[sig] = {
            "digest": hashlib.sha256(normalized.encode()).hexdigest(),
            "calls": sorted(set(INVOKE.findall(normalized))),
            "ryu_private": "Lcom/projectryu/" in normalized,
            "has_fcm": "com.google.android.c2dm.intent.RECEIVE" in normalized,
        }
    return out


def method_summary(a, b):
    if a is None or b is None:
        return {"state": "missing-stock" if a is None else "missing-ryu"}
    return {
        "state": "identical" if a["digest"] == b["digest"] else "different",
        "stock_hash": a["digest"][:16],
        "ryu_hash": b["digest"][:16],
        "ryu_private_dependency": b["ryu_private"],
        "calls_added_in_ryu": sorted(set(b["calls"]) - set(a["calls"])),
        "calls_removed_in_ryu": sorted(set(a["calls"]) - set(b["calls"])),
        "fcm_action_in_stock": a["has_fcm"],
        "fcm_action_in_ryu": b["has_fcm"],
    }


def audit(stock: Path, ryu: Path):
    output = {"warning": "OS3.0.308 stock vs RYU OS3.0.309 may include base changes",
              "focused": {}, "notification_manager": {},
              "policy": {
                  "port_fullscreen_intent_appop_bypass": False,
                  "port_force_stop_override": False,
                  "port_private_perf_hook": False,
                  "auto_port_other_notification_methods": False,
              }}
    for classname, needles in FOCUS.items():
        required = classname in ("BroadcastQueueModernStubImpl", "ProcessSceneCleaner")
        a = methods(read_class(stock, classname, required=required))
        b = methods(read_class(ryu, classname, required=required))
        for needle in needles:
            matching = sorted(x for x in set(a) | set(b) if x.startswith(needle))
            if not matching:
                output["focused"][classname + "." + needle + "..."] = {
                    "state": "not-found-in-either", "port_decision": "NO_CHANGE"}
            for sig in matching:
                output["focused"][classname + "." + sig] = method_summary(a.get(sig), b.get(sig))

    # Compare NotificationManager methods, but never auto-import unknown hooks.
    classname = "NotificationManagerServiceImpl"
    a = methods(read_class(stock, classname, required=False))
    b = methods(read_class(ryu, classname, required=False))
    if not a or not b:
        output["warning"] += "; NotificationManagerServiceImpl absent from at least one JAR"
    for sig in sorted(set(a) | set(b)):
        entry = method_summary(a.get(sig), b.get(sig))
        if entry["state"] == "identical":
            continue
        entry["port_decision"] = "DO_NOT_PORT: security/AppOp/full-screen" if any(
            x.lower() in sig.lower() for x in SECURITY_SENSITIVE
        ) else "REVIEW_ONLY: cannot attribute to notification delivery"
        output["notification_manager"][sig] = entry
    return output


def markdown(obj):
    rows = [
        "# HAOTIAN RYU notification focused audit",
        "",
        "Compared read-only Xiaomi stock OS3.0.308.0 and RYUOS 3.0.309.0 smali.",
        "Changed methods are NOT automatically notification fixes.",
        "",
        "## FCM, swipe cleanup, and force-stop",
        "",
        "| Method | Result | RYU-private dependency |",
        "|---|---|---|",
    ]
    for sig, v in obj["focused"].items():
        rows.append(f"| {sig} | {v['state']} | {v.get('ryu_private_dependency', 'N/A')} |")
    rows += ["", "## NotificationManagerServiceImpl", ""]
    changed = obj["notification_manager"]
    rows.append(f"Changed or unmatched methods: {len(changed)}.")
    for sig, v in changed.items():
        rows.append(f"- {sig}: {v['state']} — {v['port_decision']}")
        if v.get("calls_added_in_ryu"):
            rows.append("  - Additional RYU calls: " + ", ".join(v["calls_added_in_ryu"][:5]))
    rows += ["", "## Guaranteed exclusions", "",
             "- No RYU PerfHook or proprietary classes.",
             "- No modifications to ProcessManagerService.isForceStopEnable().",
             "- No AppOp bypass or full-screen-intent permission changes.",
             "- No automatic transplant of unmatched RYU notification methods.",
             "",
             "Test actual build, boot, notifications and idle drain before merging.",
             ""]
    return "\n".join(rows)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--stock", type=Path, required=True)
    p.add_argument("--ryu", type=Path, required=True)
    p.add_argument("--output", type=Path, required=True)
    args = p.parse_args()
    report = audit(args.stock, args.ryu)
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / "ryu-targeted-notification.json").write_text(
        json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    (args.output / "ryu-targeted-notification.md").write_text(
        markdown(report), encoding="utf-8")
    print(markdown(report), flush=True)


if __name__ == "__main__":
    main()
