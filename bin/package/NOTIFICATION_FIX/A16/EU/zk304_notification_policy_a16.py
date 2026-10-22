#!/usr/bin/env python3
"""Exact ZKOS HAOTIAN 304 NotificationManager initializer port for EU309 A16.

Original audited donor ZK304 has no cached static IS_INTERNATIONAL_BUILD write
in NotificationManagerServiceImpl.<clinit> (65 code units); EU309 has two
additional 2-unit read/write instructions (69 units). Preserve all remaining
instructions and every EU-only method. Never spoof build or region globally.
"""
import argparse
import json
import re
from pathlib import Path

REL = "com/android/server/notification/NotificationManagerServiceImpl.smali"
OWNER = "Lcom/android/server/notification/NotificationManagerServiceImpl;"
BUILD = "Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z"
METHOD = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$")
READ = re.compile(r"(?m)^([ \t]*)sget-boolean\s+(v\d+),\s+" + re.escape(BUILD) + r"\s*$")
WRITE = re.compile(r"(?m)^([ \t]*)sput-boolean\s+(v\d+),\s+" +
                   re.escape(OWNER + "->IS_INTERNATIONAL_BUILD:Z") + r"\s*$")
TARGET_OTHER = (
    ("com/android/server/DeviceIdleControllerStubImpl.smali", "<clinit>()V"),
    ("com/android/server/am/BroadcastQueueModernStubImpl.smali",
     "checkApplicationAutoStart("),
    ("com/android/server/am/BroadcastQueueModernStubImpl.smali",
     "checkReceiverAppDealBroadcast("),
    ("com/android/server/am/BroadcastQueueModernStubImpl.smali",
     "isInternationalSpecialAction("),
    ("com/android/server/am/BroadcastQueueModernStubImpl.smali",
     "updateBlockBroadcast("),
    ("com/android/server/am/ProcessManagerService.smali", "isForceStopEnable("),
    ("com/android/server/am/ProcessSceneCleaner.smali", "handleSwipeKill("),
    ("com/android/server/am/ProcessSceneCleaner.smali", "killAppForHasOtherTask("),
    ("com/android/server/job/JobServiceContextImpl.smali", "checkIfCancelJob("),
    ("com/android/server/notification/NotificationManagerServiceImpl.smali",
     "checkFullScreenIntent("),
)
ZK_ALIAS = "Lmiui/zk/Build;->IS_ZK_BUILD:Z"


def one(root, rel):
    paths = list(root.glob("smali*/" + rel))
    if len(paths) != 1:
        raise ValueError(f"Expected one {rel}, found {len(paths)}")
    return paths[0]


def find_method(src, name):
    matches = [m for m in METHOD.finditer(src)
               if m.group().splitlines()[0].strip().split()[-1].startswith(name)]
    if len(matches) != 1:
        raise ValueError(f"Expected one method {name}, found {len(matches)}")
    return matches[0]


def normalize(block):
    return tuple(line.strip() for line in block.splitlines()
                 if line.strip() and not line.strip().startswith(
                     ("#", ".line", ".prologue", ".local", ".end local", ".restart local")))


def patch_clinit(src, donor=None):
    m = find_method(src, "<clinit>()V")
    block = m.group()
    reads, writes = list(READ.finditer(block)), list(WRITE.finditer(block))
    if not reads and not writes:
        edited = block
        state = "already_zk"
    elif len(reads) == 1 and len(writes) == 1:
        r, w = reads[0], writes[0]
        if r.group(2) != w.group(2) or r.end() > w.start():
            raise ValueError("Unexpected NotificationManager region-gate register/order")
        between = block[r.end():w.start()]
        if any(s.strip() and not s.strip().startswith((".", "#"))
               for s in between.splitlines()):
            raise ValueError("Unexpected executable code between region-gate instructions")
        edited = block
        for sub in sorted((r, w), key=lambda x: x.start(), reverse=True):
            edited = edited[:sub.start()] + edited[sub.end():]
        state = "ported_zk304"
    else:
        raise ValueError(f"Unexpected gate inventory: reads={len(reads)} writes={len(writes)}")
    if donor is not None:
        z = find_method(donor, "<clinit>()V").group()
        if normalize(edited) != normalize(z):
            raise ValueError("Post-port method differs from real ZK304 donor")
    return src[:m.start()] + edited + src[m.end():], state


def verify_other_gates(root):
    result = {}
    for rel, signature in TARGET_OTHER:
        path = one(root, rel)
        m = find_method(path.read_text(encoding="utf-8"), signature)
        block = m.group()
        native = block.count(BUILD)
        if native != 1 or ZK_ALIAS in block:
            raise ValueError(f"{rel}/{signature}: expected one native international-build read, got {native}")
        result[rel + "/" + signature] = "native_IS_INTERNATIONAL_BUILD"
    return result


def apply(root, donor_root, report):
    original = one(root, REL)
    zk = one(donor_root, REL)
    src = original.read_text(encoding="utf-8")
    donor = zk.read_text(encoding="utf-8")
    edited, state = patch_clinit(src, donor)
    gates = verify_other_gates(root)
    if src != edited:
        original.write_text(edited, encoding="utf-8")
    result = {
        "source": "ZKOS_HAOTIAN_OS3.0.304.0 donor",
        "target": "Xiaomi.eu A16 original",
        "notification_initializer": state,
        "other_native_gate_methods_verified": len(gates),
        "gates": gates,
        "region_CN_MODEL": "dynamic_and_unchanged",
        "greeze_freeze_thaw_logic": "unchanged",
        "powerkeeper": "not_in_this_patcher",
        "runtime_tested": False
    }
    report.parent.mkdir(parents=True, exist_ok=True)
    report.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("decoded_eu", type=Path)
    parser.add_argument("decoded_zk", type=Path)
    parser.add_argument("--report", required=True, type=Path)
    args = parser.parse_args()
    try:
        print("[EU ZK304 NOTIFICATION POLICY] " +
              json.dumps(apply(args.decoded_eu, args.decoded_zk, args.report)))
    except (ValueError, OSError) as e:
        raise SystemExit("[EU ZK304 NOTIFICATION POLICY] FAIL: " + str(e))


if __name__ == "__main__":
    main()
