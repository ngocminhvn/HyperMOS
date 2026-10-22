#!/usr/bin/env python3
"""EU A16 global ZK-like decision gates: BroadcastQueue + Greeze only.

Reference: original ZK HAOTIAN OS3.0.304.0 miui-services.jar.
The four BroadcastQueue methods each read IS_INTERNATIONAL_BUILD; ZK's
PolicyManager sets CN_MODEL = (ro.miui.region == CN). Match the non-CN ZK
runtime branch outcome (true/false). This is NOT a binary method transplant;
if any expected method/field differs on EU 309, stop rather than broad patch.
Applies to all apps/broadcasts/screen states, retaining other control flow.
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
READ = re.compile(
    r"(?m)^([ \t]*)sget-boolean\s+([vp]\d+),\s+"
    r"Lmiui/os/(?:xBuild|Build);->IS_INTERNATIONAL_BUILD:Z"
    r"([ \t]*(?:#.*)?)$"
)
WRITE = re.compile(
    r"(?m)^([ \t]*)sput-boolean\s+([vp]\d+),\s+"
    r"Lcom/miui/server/greeze/PolicyManager;->CN_MODEL:Z[ \t]*$"
)
MARK_BQ = "HYPERMOS_EU_ZK_BROADCAST_A16"
MARK_POLICY = "HYPERMOS_EU_ZK_GREEZE_A16"


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
    counts = {name: 0 for name in TARGETS}
    parts, last = [], 0
    for match in METHOD.finditer(text):
        parts.append(text[last:match.start()])
        block = match.group()
        name = method_name(block)
        if name in counts:
            counts[name] += 1
            if MARK_BQ in block:
                if block.count(MARK_BQ) != 1:
                    raise ValueError(f"{name}: duplicate patch marker")
            else:
                reads = list(READ.finditer(block))
                if len(reads) != 1:
                    raise ValueError(f"{name}: expected 1 original build read, got {len(reads)}")
                read = reads[0]
                indent, reg, _suffix = read.groups()
                if not reg.startswith("v"):
                    raise ValueError(f"{name}: refusing parameter register {reg}")
                opcode = "const/4" if int(reg[1:]) <= 15 else "const/16"
                replacement = f"{indent}{opcode} {reg}, 0x1  # {MARK_BQ}"
                block = block[:read.start()] + replacement + block[read.end():]
        parts.append(block)
        last = match.end()
    parts.append(text[last:])
    if any(count != 1 for count in counts.values()):
        raise ValueError(f"Unexpected BroadcastQueue method counts: {counts}")
    return "".join(parts), counts


def patch_policy(text):
    blocks = [m for m in METHOD.finditer(text) if method_name(m.group()) == "<clinit>"]
    if len(blocks) != 1:
        raise ValueError("PolicyManager: expected one <clinit>")
    match = blocks[0]
    block = match.group()
    if MARK_POLICY in block:
        if block.count(MARK_POLICY) != 1:
            raise ValueError("PolicyManager: duplicate patch marker")
        return text
    writes = list(WRITE.finditer(block))
    if len(writes) != 1:
        raise ValueError(f"PolicyManager: expected 1 CN_MODEL write, got {len(writes)}")
    for fragment in ("ro.miui.region", '"CN"', "Ljava/lang/String;->equals(Ljava/lang/Object;)Z"):
        if fragment not in block:
            raise ValueError(f"PolicyManager: unexpected source, missing {fragment}")
    write = writes[0]
    indent, reg = write.groups()
    if not reg.startswith("v"):
        raise ValueError("PolicyManager: unexpected parameter register")
    opcode = "const/4" if int(reg[1:]) <= 15 else "const/16"
    replacement = (f"{indent}{opcode} {reg}, 0x0  # {MARK_POLICY} (ZK non-CN outcome)\n"
                   + write.group())
    changed = block[:write.start()] + replacement + block[write.end():]
    return text[:match.start()] + changed + text[match.end():]


def apply(root, report):
    targets = {rel: find_class(root, rel) for rel in (BROADCAST, POLICY)}
    original = {rel: path.read_text(encoding="utf-8") for rel, path in targets.items()}
    broadcast, counts = patch_broadcast(original[BROADCAST])
    greeze = patch_policy(original[POLICY])
    # Validate both before writing either JAR source file.
    for rel, content in ((BROADCAST, broadcast), (POLICY, greeze)):
        if content != original[rel]:
            targets[rel].write_text(content, encoding="utf-8")
    result = {
        "scope": "xiaomi_eu_a16",
        "reference": "ZK HAOTIAN OS3.0.304.0, non-CN region branch outcome",
        "all_apps": True,
        "all_broadcast_actions": True,
        "all_screen_states": True,
        "broadcast_methods": counts,
        "greeze_CN_MODEL": False,
        "other_methods_changed": False,
        "services_jar_changed": False,
        "powerkeeper_changed": False,
        "warning": "Not a byte-identical ZK transplant; on-device EU test required"
    }
    report.parent.mkdir(parents=True, exist_ok=True)
    report.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("decoded", type=Path)
    parser.add_argument("--report", required=True, type=Path)
    args = parser.parse_args()
    print("[EU ZK BROADCAST/GREEZE] " + json.dumps(apply(args.decoded, args.report)))


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError) as exc:
        raise SystemExit("[EU ZK BROADCAST/GREEZE] FAIL: " + str(exc))
