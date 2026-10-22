#!/usr/bin/env python3
"""Scope-only EU A16 workaround for GMS FCM -> Messenger while display is on.

ZK 304 control flow:
 BroadcastQueueImpl.shouldSkipReceiver
 -> BroadcastQueueModernStubImpl.checkReceiverIfRestricted
 -> GreezeManagerService.isRestrictReceiver
 -> GreezeManagerService.isAllowBroadcast / thawUidAsync.

Only the existing allow+thaw path is selected for this exact sender/action/
receiver/display combination. Do not change services.jar, CN_MODEL, or Doze.
"""
import argparse
import json
import re
from pathlib import Path

CLASS = "com/miui/server/greeze/GreezeManagerService.smali"
OWNER = "Lcom/miui/server/greeze/GreezeManagerService;"
GUARD = "HYPERMOS_EU_FCM_MESSENGER_SCREENON_A16"
METHOD = re.compile(
    r"(?ms)^\.method[^\n]*\bisAllowBroadcast\(ILjava/lang/String;ILjava/lang/String;Ljava/lang/String;\)Z[^\n]*\n.*?^\.end method[ \t]*$"
)
RESTRICT = re.compile(
    r"(?ms)^\.method[^\n]*\bisRestrictReceiver\(Landroid/content/Intent;ILjava/lang/String;ILjava/lang/String;\)Z[^\n]*\n.*?^\.end method[ \t]*$"
)
START = re.compile(
    r"(?m)^(?P<indent>[ \t]*)iget-object[ \t]+v0,[ \t]*p0,[ \t]*"
    + re.escape(OWNER)
    + r"->mBroadcastTargetWhiteList:Ljava/util/Map;[ \t]*$"
)
LOCAL_COUNT = re.compile(r"(?m)^\s*\.locals\s+(\d+)\s*$")


def patch_text(source):
    blocks = list(METHOD.finditer(source))
    if len(blocks) != 1:
        raise ValueError("Expected exactly one isAllowBroadcast(I,String,I,String,String)Z")
    match = blocks[0]
    method = match.group()
    if GUARD in method:
        if method.count(GUARD) != 1:
            raise ValueError("Duplicate FCM patch marker")
        return source, "already_patched"
    loc = LOCAL_COUNT.search(method)
    if not loc or int(loc.group(1)) < 1 or re.search(r"(?m)^\s*\.registers", method):
        raise ValueError("Require .locals >= 1 for v0 scratch and p0..p5 params")
    if len(START.findall(method)) != 1:
        raise ValueError("Unexpected isAllowBroadcast entry register/layout")
    for marker in (
        "Lcom/miui/server/greeze/PolicyManager;->CN_MODEL:Z",
        "Lcom/miui/server/greeze/GreezeManagerService;->mScreenOn:Z",
        "mBroadcastCallerWhiteList:Ljava/util/Map;",
    ):
        if marker not in method:
            raise ValueError("Missing Greeze preflight marker: " + marker)
    restrictions = list(RESTRICT.finditer(source))
    if len(restrictions) != 1:
        raise ValueError("Missing exact isRestrictReceiver(Intent,I,String,I,String)Z")
    body = restrictions[0].group()
    for marker in (
        "->isAllowBroadcast(ILjava/lang/String;ILjava/lang/String;Ljava/lang/String;)Z",
        "->thawUidAsync(IILjava/lang/String;)V",
        "->isNeedCachedBroadcast(",
    ):
        if marker not in body:
            raise ValueError("Expected original allow/thaw/cache chain: " + marker)
    code = f'''    # {GUARD}: one observed delivery case; otherwise original flow.
    const-string v0, "com.google.android.c2dm.intent.RECEIVE"
    invoke-virtual {{v0, p5}}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :hypermos_eu_fcm_original
    const-string v0, "com.google.android.gms"
    invoke-virtual {{v0, p2}}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :hypermos_eu_fcm_original
    const-string v0, "com.facebook.orca"
    invoke-virtual {{v0, p4}}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :hypermos_eu_fcm_original
    iget-boolean v0, p0, {OWNER}->mScreenOn:Z
    if-eqz v0, :hypermos_eu_fcm_original
    const/4 v0, 0x1
    return v0

    :hypermos_eu_fcm_original
'''
    pos = START.search(method).start()
    changed = method[:pos] + code + method[pos:]
    if changed.replace(code, "", 1) != method:
        raise ValueError("Unexpected non-local edit")
    return source[:match.start()] + changed + source[match.end():], "patched"


def apply(root, report):
    hits = list(root.glob("smali*/" + CLASS))
    if len(hits) != 1:
        raise ValueError(f"Expected one {CLASS}, found {len(hits)}")
    path = hits[0]
    original = path.read_text(encoding="utf-8")
    modified, status = patch_text(original)
    if modified != original:
        path.write_text(modified, encoding="utf-8")
    result = {
        "scope": "xiaomi_eu_android16_only",
        "status": status,
        "method_changed": "GreezeManagerService.isAllowBroadcast",
        "sender": "com.google.android.gms",
        "action": "com.google.android.c2dm.intent.RECEIVE",
        "receiver": "com.facebook.orca",
        "screen_on_required": True,
        "original_thaw_chain_preserved": True,
        "services_jar_changed": False,
        "other_methods_changed": False,
        "policy_manager_cn_model_changed": False,
    }
    report.parent.mkdir(parents=True, exist_ok=True)
    report.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("decoded", type=Path)
    parser.add_argument("--report", type=Path, required=True)
    args = parser.parse_args()
    print("[EU GREEZE FCM] " + json.dumps(apply(args.decoded, args.report)))


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError) as exc:
        raise SystemExit(f"[EU GREEZE FCM] FAIL: {exc}")
