#!/usr/bin/env python3
"""Patch only Xiaomi.eu A16 ProcessPolicy.updateContentCatcherWhitelist region gate."""
import argparse
import json
import re
from pathlib import Path

RELATIVE = "com/android/server/am/ProcessPolicy.smali"
METHOD = re.compile(
    r"(?ms)^\.method[^\n]*\bupdateContentCatcherWhitelist\(\)V[^\n]*\n.*?^\.end method[ \t]*$"
)
READ = re.compile(
    r"(?m)^([ \t]*)sget-boolean[ \t]+([vp]\d+),[ \t]+"
    r"Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z([ \t]*(?:#.*)?)$"
)
ALREADY = re.compile(
    r"(?m)^[ \t]*const/4[ \t]+([vp]\d+),[ \t]+0x0[ \t]*(?:#.*)?$\n"
    # Baksmali inserts a blank line between instructions after CorePatch
    # reassembles this JAR. Accept only blank/comment lines, then require the
    # conditional to consume the exact same register.
    r"(?:^[ \t]*(?:#.*)?$\n)*"
    r"^[ \t]*if-(?:eqz|nez)[ \t]+\1,[ \t]+:[^\n]+$"
)


def patch_source(source):
    blocks = list(METHOD.finditer(source))
    if len(blocks) != 1:
        raise ValueError("Expected exactly one updateContentCatcherWhitelist()V")
    method = blocks[0].group()
    reads = list(READ.finditer(method))
    if not reads:
        if len(ALREADY.findall(method)) != 1:
            raise ValueError("No auditable ContentCatcher region gate or existing false gate")
        return source, "already_false"
    if len(reads) != 1 or reads[0].group(2) != "v0":
        raise ValueError("Unexpected ContentCatcher read count/register")
    gate = reads[0]
    indent, register, suffix = gate.groups()
    changed = method[:gate.start()] + f"{indent}const/4 {register}, 0x0{suffix}" + method[gate.end():]
    result = source[:blocks[0].start()] + changed + source[blocks[0].end():]
    if result.replace(changed, method, 1) != source:
        raise ValueError("Unexpected change outside ContentCatcher method")
    return result, "patched"


def patch_directory(root):
    matches = [p for p in root.glob("smali*/" + RELATIVE) if p.is_file()]
    if len(matches) != 1:
        raise ValueError("Expected exactly one ProcessPolicy.smali")
    path = matches[0]
    original = path.read_text(encoding="utf-8")
    modified, status = patch_source(original)
    if modified != original:
        path.write_text(modified, encoding="utf-8")
    return {"scope": "xiaomi_eu_a16", "target": RELATIVE,
            "method": "updateContentCatcherWhitelist()V",
            "region_gate": False, "status": status, "other_methods_changed": False}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("decoded", type=Path)
    parser.add_argument("--report", required=True, type=Path)
    args = parser.parse_args()
    result = patch_directory(args.decoded)
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print("[EU CONTENTCATCHER A16] " + json.dumps(result))


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError) as exc:
        raise SystemExit("[EU CONTENTCATCHER A16] FAIL: " + str(exc))
