#!/usr/bin/env python3
"""EU A16 ZKOS 304 parity: no global forced build or CN_MODEL flags.

ZK304 and original EU309 share the same four BroadcastQueue methods, reading
the native IS_INTERNATIONAL_BUILD boolean. Their PolicyManager.<clinit>
sets CN_MODEL dynamically from (ro.miui.region == "CN"). Preserve those
conditions; if a donor alias IS_ZK_BUILD occurs, map to IS_INTERNATIONAL_BUILD.
The prior constant-true/false patch was NOT a bytecode-equivalent ZK port.
"""
import argparse
import json
import re
from pathlib import Path

BROADCAST = "com/android/server/am/BroadcastQueueModernStubImpl.smali"
POLICY = "com/miui/server/greeze/PolicyManager.smali"
TARGETS = ("checkApplicationAutoStart", "checkReceiverAppDealBroadcast",
           "isInternationalSpecialAction", "updateBlockBroadcast")
METHOD = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$")
NATIVE = "Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z"
READ = re.compile(r"(?m)^([ \t]*)sget-boolean\s+(v\d+),\s+(\S+)([ \t]*(?:#.*)?)$")
LEGACY = re.compile(r"(?m)^([ \t]*)const/(?:4|16)\s+(v\d+),\s+0x1\s+# HYPERMOS_EU_ZK_BROADCAST_A16[ \t]*$")
ALIAS = ("Lmiui/zk/Build;->IS_ZK_BUILD:Z", "Lmiui/os/Build;->IS_ZK_BUILD:Z")
WRITE = re.compile(r"(?m)^([ \t]*)sput-boolean\s+(v\d+),\s+Lcom/miui/server/greeze/PolicyManager;->CN_MODEL:Z[ \t]*$")
FORCED_REGION = re.compile(r"(?m)^([ \t]*)const/(?:4|16)\s+(v\d+),\s+0x0\s+# HYPERMOS_EU_ZK_GREEZE_A16[^\n]*\n")

def method_name(block):
    head = block.split("\n", 1)[0]
    match = re.search(r"([\w<>$-]+)\(", head)
    return match.group(1) if match else None


def find_class(root, rel):
    hits = list(root.glob("smali*/" + rel))
    if len(hits) != 1:
        raise ValueError(f"{rel}: expected one class, got {len(hits)}")
    return hits[0]


def patch_broadcast(text):
    counts = dict.fromkeys(TARGETS, 0)
    actions = {}
    parts, last = [], 0
    for match in METHOD.finditer(text):
        parts.append(text[last:match.start()])
        block = match.group()
        name = method_name(block)
        if name in counts:
            counts[name] += 1
            if counts[name] != 1:
                raise ValueError("Duplicate BroadcastQueue method: " + name)
            found = [r for r in READ.finditer(block) if r.group(3) in (NATIVE,) + ALIAS]
            legacy = list(LEGACY.finditer(block))
            if len(found) + len(legacy) != 1:
                raise ValueError(f"{name}: expected exactly one ZK-compatible read or known legacy marker")
            if legacy:
                old = legacy[0]
                replacement = f"{old.group(1)}sget-boolean {old.group(2)}, {NATIVE}"
                block = block[:old.start()] + replacement + block[old.end():]
                actions[name] = "reverted_forced_true"
            else:
                old = found[0]
                if old.group(3) in ALIAS:
                    replacement = f"{old.group(1)}sget-boolean {old.group(2)}, {NATIVE}{old.group(4)}"
                    block = block[:old.start()] + replacement + block[old.end():]
                    actions[name] = "mapped_IS_ZK_BUILD_to_IS_INTERNATIONAL_BUILD"
                else:
                    actions[name] = "already_ZK_exact"
            if len([r for r in READ.finditer(block) if r.group(3) == NATIVE]) != 1:
                raise ValueError(name + ": native flag read not recovered")
            if "HYPERMOS_EU_ZK_BROADCAST_A16" in block:
                raise ValueError(name + ": stale forced-gate marker")
        parts.append(block)
        last = match.end()
    parts.append(text[last:])
    if any(count != 1 for count in counts.values()):
        raise ValueError("BroadcastQueue method inventory changed: " + str(counts))
    return "".join(parts), actions


def patch_policy(text):
    matches = [m for m in METHOD.finditer(text) if method_name(m.group()) == "<clinit>"]
    if len(matches) != 1:
        raise ValueError("PolicyManager: expected exactly one <clinit>")
    m = matches[0]
    block = m.group()
    if block.count('"ro.miui.region"') != 1 or block.count('"CN"') != 1:
        raise ValueError("PolicyManager: donor's region/CN check missing")
    equals_count = (block.count("Ljava/lang/Object;->equals(Ljava/lang/Object;)Z")
                    + block.count("Ljava/lang/String;->equals(Ljava/lang/Object;)Z"))
    if equals_count != 1:
        raise ValueError("PolicyManager: unexpected region comparison count")
    writes = list(WRITE.finditer(block))
    if len(writes) != 1:
        raise ValueError("PolicyManager: expected exactly one CN_MODEL assignment")
    forced = list(FORCED_REGION.finditer(block))
    if len(forced) > 1:
        raise ValueError("PolicyManager: duplicated forced false assignment")
    if forced:
        if forced[0].group(2) != writes[0].group(2):
            raise ValueError("PolicyManager: register mismatch")
        block = block[:forced[0].start()] + block[forced[0].end():]
    required = (r"(?m)^\s*move-result\s+" + re.escape(writes[0].group(2))
                + r"\s*\n\s*sput-boolean\s+" + re.escape(writes[0].group(2))
                + r",\s+Lcom/miui/server/greeze/PolicyManager;->CN_MODEL:Z")
    if not re.search(required, block):
        raise ValueError("PolicyManager: CN_MODEL must be assigned the region equals result")
    if "HYPERMOS_EU_ZK_GREEZE_A16" in block:
        raise ValueError("PolicyManager: stale forced-region marker")
    return text[:m.start()] + block + text[m.end():]


def apply(root, report):
    targets = {rel: find_class(root, rel) for rel in (BROADCAST, POLICY)}
    originals = {rel: path.read_text(encoding="utf-8") for rel, path in targets.items()}
    broadcast, actions = patch_broadcast(originals[BROADCAST])
    greeze = patch_policy(originals[POLICY])
    # Fail closed: validate both original classes before touching either.
    for rel, content in ((BROADCAST, broadcast), (POLICY, greeze)):
        if content != originals[rel]:
            targets[rel].write_text(content, encoding="utf-8")
    result = {
        "scope": "xiaomi_eu_A16_ZK304_semantic_parity",
        "broadcast_queue": actions,
        "CN_MODEL": "dynamic_ro.miui.region_equals_CN",
        "native_build_field": NATIVE,
        "greeze_isAllowBroadcast_changed": False,
        "greeze_isRestrictReceiver_changed": False,
        "services_jar_changed": False,
        "powerkeeper_changed": False,
        "status": "ZK-equivalent-gates; NOT notification-delivery proof"
    }
    report.parent.mkdir(parents=True, exist_ok=True)
    report.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("decoded", type=Path)
    parser.add_argument("--report", required=True, type=Path)
    args = parser.parse_args()
    print("[EU ZK PARITY] " + json.dumps(apply(args.decoded, args.report)))


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError) as exc:
        raise SystemExit("[EU ZK PARITY] FAIL: " + str(exc))
