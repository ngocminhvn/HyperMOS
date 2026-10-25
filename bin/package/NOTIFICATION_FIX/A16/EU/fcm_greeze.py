#!/usr/bin/env python3
"""EU A16: selective Google FCM delivery over the original ZK-style Greeze thaw chain.

ZK304 and Xiaomi.eu309 have equivalent isRestrictReceiver/isNeedCachedBroadcast
logic. This deliberately adds an EU FCM exception to isAllowBroadcast; it is
NOT a byte-identical ZK transplant, and does not disable Greeze or change
CN_MODEL / other broadcast policy. FCM delivery and power must be device-tested.
"""
import argparse
import json
import re
from pathlib import Path

SERVICE = "com/miui/server/greeze/GreezeManagerService.smali"
OWNER = "Lcom/miui/server/greeze/GreezeManagerService;"
METHOD = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method\s*$")
SIGNATURE = "isAllowBroadcast(ILjava/lang/String;ILjava/lang/String;Ljava/lang/String;)Z"
RESTRICT = "isRestrictReceiver(Landroid/content/Intent;ILjava/lang/String;ILjava/lang/String;)Z"
ENTRY = re.compile(r"(?m)^[ \t]*iget-object\s+v0,\s*p0,\s*"
                   + re.escape(OWNER)
                   + r"->mBroadcastTargetWhiteList:Ljava/util/Map;[ \t]*$")
REGISTERS = re.compile(r"(?m)^\s*\.(?:locals|registers)\s+(\d+)\s*$")
MARKER = "HYPERMOS_EU_FCM_GREEZE_THAW_A16"

GUARD = f'''    # {MARKER}: Google FCM only; every target app, screen on or off.
    const-string v0, "com.google.android.c2dm.intent.RECEIVE"
    invoke-virtual {{v0, p5}}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :hypermos_eu_greeze_original
    const-string v0, "com.google.android.gms"
    invoke-virtual {{v0, p2}}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :hypermos_eu_greeze_original
    const/4 v0, 0x1
    return v0

    :hypermos_eu_greeze_original
'''

def get_method(src, target):
    matches = [m for m in METHOD.finditer(src)
               if m.group().splitlines()[0].strip().split()[-1] == target]
    if len(matches) != 1:
        raise ValueError(f"Expected exactly one {target}: found {len(matches)}")
    return matches[0]

def is_guard_present(block):
    ops = [s.strip().replace("const-string/jumbo ", "const-string ")
           for s in block.splitlines()
           if s.strip() and not s.strip().startswith((".", ":", "#"))]
    needed = [
        'const-string v0, "com.google.android.c2dm.intent.RECEIVE"',
        'invoke-virtual {v0, p5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z',
        'move-result v0', 'if-eqz v0,',
        'const-string v0, "com.google.android.gms"',
        'invoke-virtual {v0, p2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z',
        'move-result v0', 'if-eqz v0,', 'const/4 v0, 0x1', 'return v0',
        'iget-object v0, p0, '+OWNER+'->mBroadcastTargetWhiteList:Ljava/util/Map;'
    ]
    def eq(a,b):
        return a.startswith(b) if b.endswith(",") else a == b
    return any(all(eq(ops[i+j],k) for j,k in enumerate(needed))
               for i in range(max(0,len(ops)-len(needed)+1)))

def patch_source(src, verify=False):
    allow = get_method(src, SIGNATURE)
    restrict = get_method(src, RESTRICT).group()
    for call in (OWNER + "->" + SIGNATURE,
                 OWNER + "->thawUidAsync(IILjava/lang/String;)V",
                 OWNER + "->isNeedCachedBroadcast("):
        if call not in restrict:
            raise ValueError("Original Greeze allow/thaw/cache call chain changed: " + call)
    block = allow.group()
    if MARKER in block and block.count(MARKER) != 1:
        raise ValueError("Duplicate EU FCM marker")
    if is_guard_present(block):
        return src, "verified" if verify else "already_patched"
    if MARKER in block or verify:
        raise ValueError("EU FCM guard missing or malformed")
    regs = REGISTERS.findall(block)
    decl = re.search(r"(?m)^\s*\.(locals|registers)\s+\d+\s*$", block)
    if len(regs) != 1 or not decl:
        raise ValueError("Greeze register declaration missing or duplicated")
    expected = 4 if decl.group(1) == "locals" else 10
    if int(regs[0]) != expected:
        raise ValueError(f"Unexpected Greeze register ABI: {decl.group(1)}={regs[0]}")
    entries = list(ENTRY.finditer(block))
    if len(entries) != 1:
        raise ValueError("Greeze whitelist entry opcode changed")
    start = entries[0].start()
    if re.search(r"(?m)^\s*(?:iget|sget|invoke-|const|return|if-|monitor-)", block[:start]):
        raise ValueError("Unexpected executable code before Greeze whitelist")
    changed = block[:start] + GUARD + block[start:]
    return src[:allow.start()] + changed + src[allow.end():], "patched"

def apply(root, report, verify=False):
    matches = list(root.glob("smali*/" + SERVICE))
    if len(matches) != 1:
        raise ValueError(f"Expected one GreezeManagerService class, found {len(matches)}")
    path = matches[0]
    original = path.read_text(encoding="utf-8")
    changed, status = patch_source(original, verify)
    if changed != original and not verify:
        path.write_text(changed, encoding="utf-8")
    result = {
        "status": status, "scope": "xiaomi_eu_android16",
        "caller": "com.google.android.gms",
        "action": "com.google.android.c2dm.intent.RECEIVE",
        "target_apps": "all", "screen": "on_or_off",
        "isRestrictReceiver_and_thawUidAsync": "preserved",
        "CN_MODEL_and_region": "preserved",
        "other_broadcasts": "unchanged",
        "services_jar_and_powerkeeper": "unchanged",
        "byte_identical_to_ZK": False,
        "runtime_tested": False,
        "battery_caveat": "More FCM-triggered app wakeups possible"
    }
    if report:
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return result

def main():
    p = argparse.ArgumentParser()
    p.add_argument("decoded", type=Path)
    p.add_argument("--report", type=Path)
    p.add_argument("--verify", action="store_true")
    args = p.parse_args()
    try:
        print("[EU GREEZE FCM] " + json.dumps(apply(args.decoded, args.report, args.verify)))
    except (ValueError, OSError) as exc:
        raise SystemExit("[EU GREEZE FCM] FAIL: " + str(exc))

if __name__ == "__main__":
    main()
