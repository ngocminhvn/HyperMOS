#!/usr/bin/env python3
"""Apply small, SHA-pinned instruction deltas to original EU A16 smali.

There are no bundled Global/ZK PowerKeeper or framework DEX donors.
Each delta is checked against the exact EU method before modification.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path

METHOD = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$")
IGNORE = ("#", ".line ", ".local ", ".end local", ".restart local",
          ".param ", ".end param", ".prologue", ".epilogue", ".source ")
EXPECTED = {"global-jar": 3, "global-power": 7, "zk-jar": 1, "zk-power": 4}
ZK_MARKERS = ("Lmiui/zk/", "Lcom/zk/", "IS_ZK_BUILD", "zk_state", "Lcom/projectryu/")


def norm(src):
    return [v for raw in src.splitlines()
            if (v := raw.strip()) and not v.startswith(IGNORE)]


def digest(lines):
    return hashlib.sha256("\n".join(lines).encode("utf-8")).hexdigest()


def one_file(root, rel):
    # Original DEX may split a class between smali, smali_classes2, etc.
    found = list(root.glob("smali*/" + rel))
    if len(found) != 1:
        raise ValueError(f"{rel}: expected 1 smali class, got {len(found)}")
    return found[0]


def one_method(src, sig):
    found = [m for m in METHOD.finditer(src)
             if m.group().splitlines()[0].strip().split()[-1] == sig]
    if len(found) != 1:
        raise ValueError(f"{sig}: expected one method, got {len(found)}")
    return found[0]


def target(lines, edits):
    output = list(lines)
    prev = len(lines) + 1
    for change in reversed(edits):
        offset = change["at"]
        old = change["remove"]
        new = change["insert"]
        if not isinstance(offset, int) or offset < 0 or offset + len(old) > prev:
            raise ValueError("invalid/overlapping method edit")
        if output[offset:offset + len(old)] != old:
            raise ValueError(f"method edit anchor mismatch at {offset}")
        output[offset:offset + len(old)] = new
        prev = offset
    return output


def load_manifest(file):
    data = json.loads(file.read_text(encoding="utf-8"))
    if data.get("format") != "hypermos_a16_method_deltas_v1":
        raise ValueError("unsupported policy delta format")
    amounts = {k: 0 for k in EXPECTED}
    seen = set()
    for entry in data["methods"]:
        bucket = entry["bucket"]
        if bucket not in amounts:
            raise ValueError("unexpected donor bucket")
        identity = (bucket, entry["path"], entry["signature"])
        if identity in seen:
            raise ValueError("duplicate donor method")
        seen.add(identity)
        amounts[bucket] += 1
        if bucket.startswith("zk"):
            for op in entry["changes"]:
                if any(marker in line for line in op["insert"] for marker in ZK_MARKERS):
                    raise ValueError("ZK-only class/property reference not allowed")
    if amounts != EXPECTED:
        raise ValueError(f"incomplete policy delta set: {amounts}")
    if len(data["fields"]) != 1 or data["fields"][0]["bucket"] != "global-jar":
        raise ValueError("missing scoped Global MAP_APP field edit")
    return data


def apply(root, manifest, bucket, verify, report):
    items = [x for x in manifest["methods"] if x["bucket"] == bucket]
    touched, identical = [], []
    for entry in items:
        path = one_file(root, entry["path"])
        source = path.read_text(encoding="utf-8")
        method = one_method(source, entry["signature"])
        current = norm(method.group())
        current_sha = digest(current)
        original_sha = entry["before_sha256"]
        output_sha = entry["after_sha256"]
        if current_sha == output_sha:
            identical.append(entry["path"] + "->" + entry["signature"])
            continue
        if verify:
            raise ValueError(f"{entry['signature']}: rebuilt method SHA mismatch")
        if current_sha != original_sha:
            raise ValueError(f"{entry['signature']}: unexpected EU base method SHA")
        if len(current) != entry["original_lines"]:
            raise ValueError("source method line inventory mismatch")
        result = target(current, entry["changes"])
        if digest(result) != output_sha or len(result) != entry["result_lines"]:
            raise ValueError("result does not match pinned donor method")
        if not entry["changes"]:
            identical.append(entry["path"] + "->" + entry["signature"])
            continue
        patched = "\n".join(result)
        path.write_text(source[:method.start()] + patched + source[method.end():], encoding="utf-8")
        touched.append(entry["path"] + "->" + entry["signature"])

    if bucket == "global-jar":
        info = manifest["fields"][0]
        path = one_file(root, info["path"])
        source = path.read_text(encoding="utf-8")
        before, after = info["before"], info["after"]
        count_before = source.count(before)
        count_after = source.count(after)
        if before != after and count_before == 1 and count_after == 0 and not verify:
            source = source.replace(before, after, 1)
            path.write_text(source, encoding="utf-8")
        elif before != after and (count_after != 1 or count_before != 0):
            raise ValueError("Global MAP_APP field ABI inconsistent")
        elif before == after and count_before != 1:
            raise ValueError("Global MAP_APP field absent")

    result = {"policy":bucket,"modified":touched,"verified_or_equal":identical,
              "target_methods":len(items), "verification_only":verify,
              "source":"audited EU309 -> Global303/ZK304 instruction deltas",
              "whole_dex_donor_required":False}
    if report:
        report.parent.mkdir(parents=True,exist_ok=True)
        report.write_text(json.dumps(result,indent=2)+"\n",encoding="utf-8")
    print("[EU POLICY DELTAS] " + json.dumps(result))


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--root", required=True, type=Path)
    p.add_argument("--manifest", required=True, type=Path)
    p.add_argument("--policy", required=True, choices=EXPECTED)
    p.add_argument("--verify", action="store_true")
    p.add_argument("--report", type=Path)
    a = p.parse_args()
    try:
        apply(a.root,load_manifest(a.manifest),a.policy,a.verify,a.report)
    except (OSError, ValueError, KeyError, TypeError, IndexError) as e:
        raise SystemExit("[EU POLICY DELTAS] FAIL: " + str(e))


if __name__ == "__main__":
    main()
