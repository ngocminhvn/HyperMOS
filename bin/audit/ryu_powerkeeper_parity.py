#!/usr/bin/env python3
"""Compare RYUOS vs Xiaomi HAOTIAN PowerKeeper without transplanting binary code.

Input trees are decoded with APKEditor (-t raw). Results are diagnostic;
the script NEVER patches the ROM or rewrites a signed APK.
"""
from pathlib import Path
import argparse
import hashlib
import json
import difflib
import re

METHOD = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method\s*$")
PREFERRED = {
    "GmsObserver": ("isGmsControlEnabled()Z", "enableGms()V", "disableGms()V"),
    "KillProcessController": ("setUidState(IZ)V",),
    "ActiveStateController": ("dealNoRestrictApp()V",),
    "PowerKeeperApplication": ("onCreate()V",),
}
CLASS_KEYS = ("GmsObserver", "KillProcessController",
              "ActiveStateController", "PowerKeeperApplication",
              "DeviceIdleController")


def normalize(body):
    # Normalization deliberately conservative: labels/registers and every
    # executable instruction are retained. Only file/line/debug directives
    # and trailing blank space are removed.
    return "\n".join(
        line.strip() for line in body.splitlines()
        if line.strip() and not line.lstrip().startswith(("#", ".line", ".param",
            ".local", ".end local", ".restart local", ".prologue"))
    )


def find_one(root, name):
    matches = list(root.rglob(name + ".smali"))
    if len(matches) != 1:
        raise ValueError(f"{name}: expected one smali class, got {len(matches)}")
    return matches[0]


def methods(root, classname):
    body = find_one(root, classname).read_text(encoding="utf-8")
    result = {}
    for match in METHOD.finditer(body):
        sig = match.group().splitlines()[0].strip().removeprefix(".method ")
        method_id = sig.split(" ")[-1]
        code = normalize(match.group())
        result[method_id] = {
            "sha256": hashlib.sha256(code.encode()).hexdigest(),
            "insns": len(code.splitlines()),
            "has_ryu_dependency": "Lcom/projectryu/" in code,
        }
    return result


def chosen_method_text(root, name, method_id):
    source = find_one(root, name).read_text(encoding="utf-8")
    matching = [
        m.group() for m in METHOD.finditer(source)
        if m.group().splitlines()[0].strip().removeprefix(".method ").split(" ")[-1] == method_id
    ]
    if len(matching) != 1:
        return []
    return normalize(matching[0]).splitlines()


def print_focused_diffs(stock, ryu):
    selected = {
        "GmsObserver": ["<init>(Landroid/content/Context;)V", "updateGoogleSync(Z)V"],
        "KillProcessController": ["setUidState(IZ)V", "shouldKillByCheckerPolicy(I)Z"],
        "PowerKeeperApplication": ["onCreate()V", "d()Z"],
    }
    for name, method_ids in selected.items():
        for method_id in method_ids:
            a = chosen_method_text(stock, name, method_id)
            b = chosen_method_text(ryu, name, method_id)
            print(f"[DIFF] {name}.{method_id}")
            diffs = list(difflib.unified_diff(
                a, b, fromfile="Stock/Xiaomi", tofile="RYUOS", lineterm=""
            ))
            for line in diffs[:120]:
                print(line)
            if len(diffs) > 120:
                print(f"... {len(diffs)-120} more diff lines omitted")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--ryu", type=Path, required=True)
    ap.add_argument("--stock", type=Path, required=True)
    ap.add_argument("--out", type=Path, required=True)
    a = ap.parse_args()
    results = {"classes": {}, "methods": {}, "summary": {}}
    for name in CLASS_KEYS:
        stock = methods(a.stock, name)
        ryu = methods(a.ryu, name)
        ids = sorted(set(stock) | set(ryu))
        changed = [sig for sig in ids if stock.get(sig,{}).get("sha256") != ryu.get(sig,{}).get("sha256")]
        results["classes"][name] = {
            "stock_count": len(stock), "ryu_count": len(ryu),
            "unchanged_methods": len(ids) - len(changed),
            "different_methods": len(changed),
        }
        result = {}
        for sig in ids:
            is_changed = sig in changed
            if is_changed or sig in PREFERRED.get(name,()):
                result[sig] = {
                    "equivalent_code": not is_changed,
                    "stock": stock.get(sig),
                    "ryu": ryu.get(sig),
                }
        results["methods"][name] = result
    for label, root in (("stock", a.stock), ("ryu", a.ryu)):
        obj = find_one(root, "KillProcessController").read_text(encoding="utf-8")
        print("[AUDIT]", label, "KillProcessController rule checker field definitions:")
        for line in obj.splitlines():
            if line.lstrip().startswith(".field") and (
                "mKillProcessAppRuleChecker" in line or "PowerKeeperInterface" in line
            ):
                print(" ", line.strip())
        print("[AUDIT]", label, "rule checker references:",
              obj.count("mKillProcessAppRuleChecker"),
              "setter/callback refs:", obj.count("getUidPolicy("))
        print("[AUDIT]", label, "all field definitions:")
        for line in obj.splitlines():
            if line.lstrip().startswith(".field"):
                print(" ", line.strip())
    perf = list(a.ryu.rglob("PerfHook.smali"))
    results["summary"]["ryu_has_perf_hook"] = bool(perf)
    gms = results["methods"]["GmsObserver"].get("isGmsControlEnabled()Z")
    results["summary"]["gms_control_unchanged"] = bool(gms and gms["equivalent_code"])
    a.out.parent.mkdir(parents=True, exist_ok=True)
    a.out.write_text(json.dumps(results, indent=2, ensure_ascii=False))
    print("RYU vs Xiaomi HAOTIAN PowerKeeper parity")
    for name, item in results["classes"].items():
        print(f"  {name}: unchanged={item['unchanged_methods']} different={item['different_methods']}")
    print("  GmsObserver.isGmsControlEnabled identical:", results["summary"]["gms_control_unchanged"])
    print("  RYU contains PerfHook:", results["summary"]["ryu_has_perf_hook"])
    print_focused_diffs(a.stock, a.ryu)


if __name__ == "__main__":
    main()
