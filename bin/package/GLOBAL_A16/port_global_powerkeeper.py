#!/usr/bin/env python3
"""Port exactly seven Global303 methods into original Xiaomi.eu PowerKeeper."""
from __future__ import annotations
import argparse
import json
import re
from pathlib import Path

METHOD = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$")
AUDITED = {
    ("com/miui/powerkeeper/cloudcontrol/CloudUpdateReceiver.smali", "onReceive(Landroid/content/Context;Landroid/content/Intent;)V"),
    ("com/miui/powerkeeper/cloudcontrol/LocalUpdateUtils.smali", "getCloudServer(Landroid/content/Context;)Ljava/lang/String;"),
    ("com/miui/powerkeeper/cloudcontrol/LocalUpdateUtils.smali", "setServerConfigurations(Landroid/content/Context;)V"),
    ("com/miui/powerkeeper/utils/InternationalAdapter.smali", "<clinit>()V"),
    ("com/miui/powerkeeper/utils/PowerModeAdapter.smali", "<clinit>()V"),
    ("com/miui/powerkeeper/utils/Utils.smali", "isSleepModeViewVisable()Z"),
    ("f/h.smali", "c(Landroid/content/Context;)Lf/j;"),
}
DEBUG = (".line ", ".local ", ".end local", ".restart local", ".param ",
         ".end param", ".prologue", ".epilogue", ".source ")

def norm(block):
    return tuple(line for raw in block.splitlines()
                 if (line := raw.strip()) and not line.startswith("#")
                 and not line.startswith(DEBUG))

def methods(source):
    out = {}
    for m in METHOD.finditer(source):
        block = m.group()
        signature = block.splitlines()[0].strip().split()[-1]
        if signature in out:
            raise ValueError("duplicate method: " + signature)
        out[signature] = block
    return out

def files(root):
    out = {p.relative_to(root).as_posix(): p for p in root.rglob("*.smali")}
    if not out:
        raise ValueError("empty baksmali dir " + str(root))
    return out

def compare(eu, glo):
    a, b = files(eu), files(glo)
    if a.keys() != b.keys():
        raise ValueError("original EU/Global class inventories differ")
    differs, em, gm = set(), {}, {}
    for rel in a:
        x = methods(a[rel].read_text(encoding="utf-8"))
        y = methods(b[rel].read_text(encoding="utf-8"))
        if x.keys() != y.keys():
            raise ValueError("EU/Global method inventories differ: " + rel)
        em[rel], gm[rel] = x, y
        differs.update((rel, sig) for sig in x if norm(x[sig]) != norm(y[sig]))
    return em, gm, differs

def transplant(eu, glo, report):
    original, donor, differences = compare(eu, glo)
    if differences != AUDITED:
        raise ValueError("unexpected donor differences: " + repr(sorted(differences ^ AUDITED)[:25]))
    for rel, sig in sorted(AUDITED):
        path = eu / rel
        src = path.read_text(encoding="utf-8")
        before, after = original[rel][sig], donor[rel][sig]
        if src.count(before) != 1 or before == after:
            raise ValueError("method replacement not unambiguous: " + rel + "/" + sig)
        path.write_text(src.replace(before, after, 1), encoding="utf-8")
    if compare(eu, glo)[2]:
        raise ValueError("method transplant did not converge with global donor")
    if report:
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_text(json.dumps({
            "scope": "Global303 seven method bodies on original EU DEX",
            "changed": [{"path": p, "method": s} for p, s in sorted(AUDITED)],
            "other_eu_methods_unchanged_before_assembly": True,
            "original_eu_class_fields_kept": True,
            "global_whole_dex_replacement": False,
            "runtime_tested": False,
        }, indent=2) + "\n", encoding="utf-8")
    print("[GLOBAL A16] grafted seven methods onto EU source")

def verify(original, output, global_root):
    a, b, c = files(original), files(output), files(global_root)
    if a.keys() != b.keys() or a.keys() != c.keys():
        raise ValueError("rebuild altered EU class inventory")
    changed = set()
    total = 0
    for rel in a:
        x = methods(a[rel].read_text(encoding="utf-8"))
        y = methods(b[rel].read_text(encoding="utf-8"))
        if x.keys() != y.keys():
            raise ValueError("rebuild altered EU method inventory: " + rel)
        total += len(x)
        changed.update((rel, sig) for sig in x if norm(x[sig]) != norm(y[sig]))
    if changed != AUDITED or total != 18332:
        raise ValueError("rebuild altered non-target EU methods or method count: "
                         + repr(sorted(changed ^ AUDITED)[:25]) + " count=" + str(total))
    print("[GLOBAL A16] verified seven changed methods; all other EU method bodies preserved")

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--eu", type=Path, required=True)
    p.add_argument("--global-donor", type=Path, required=True)
    p.add_argument("--verify-original", type=Path)
    p.add_argument("--report", type=Path)
    args = p.parse_args()
    if args.verify_original:
        verify(args.verify_original, args.eu, args.global_donor)
    else:
        transplant(args.eu, args.global_donor, args.report)

if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError) as e:
        raise SystemExit("[GLOBAL A16] FAIL: " + str(e))
