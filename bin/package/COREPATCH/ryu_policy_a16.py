#!/usr/bin/env python3
"""Selective RYUOS A16 notification policy transplant onto HyperMOS base smali.

Preserves Xiaomi/HyperMOS framework classes, permissions and boot-chain.
No dependency on com.projectryu.* classes. Fails closed on unknown layouts.
"""
from pathlib import Path
import re
import sys

ACTION = "com.google.android.c2dm.intent.RECEIVE"


def one_class(root: Path, name: str) -> Path:
    results = list(root.rglob(name + ".smali"))
    if len(results) != 1:
        raise ValueError(f"{name}.smali: expected exactly one, found {len(results)}")
    return results[0]


def method(text: str, signature: str):
    pattern = re.compile(
        rf"(?ms)^\.method[^\n]*\s{re.escape(signature)}\s*$"
        rf".*?^\.end method\s*$"
    )
    matches = list(pattern.finditer(text))
    if len(matches) != 1:
        raise ValueError(f"{signature}: expected exactly one method, found {len(matches)}")
    return matches[0]


def inject(text: str, signature: str, marker: str, source: str,
           min_locals: int = 2) -> str:
    m = method(text, signature)
    body = m.group()
    if marker in body:
        return text
    if ".method static " in body.splitlines()[0]:
        raise ValueError(f"{signature}: unexpected static method")
    reg = re.search(r"(?m)^    \.(locals|registers)\s+(\d+)\s*$", body)
    if not reg:
        raise ValueError(f"{signature}: missing register directive")
    reg_kind, count = reg.group(1), int(reg.group(2))
    param_count = 4 if "checkApplicationAutoStart" in signature else (
        3 if "killAppForHasOtherTask" in signature else 1
    )
    available = count if reg_kind == "locals" else count - param_count
    if available < min_locals:
        raise ValueError(f"{signature}: only {available} local registers")
    # Insert after the register directive and before original executable code.
    new_body = body[:reg.end()] + "\n" + source + body[reg.end():]
    return text[:m.start()] + new_body + text[m.end():]


def fcm_autostart(text: str) -> str:
    """Exempt GMS-originated FCM only at Xiaomi's autostart policy decision.

    We deliberately do NOT short-circuit this method: widget/NFC/first-boot
    and other Xiaomi checks must execute exactly as in the base firmware.
    """
    signature = ("checkApplicationAutoStart("
                 "Lcom/android/server/am/BroadcastQueue;"
                 "Lcom/android/server/am/BroadcastRecord;"
                 "Landroid/content/pm/ResolveInfo;)Z")
    m = method(text, signature)
    body = m.group()
    marker = ":hypermos_ryu_fcm_autostart_only"
    if marker in body:
        return text
    record_match = re.findall(
        r"(?m)^\s*move-object/from16\s+(v\d+),\s*p2\s*$", body)
    action_match = re.findall(
        r"(?s)invoke-virtual\s+\{[vp]\d+\},\s*"
        r"Landroid/content/Intent;->getAction\(\)Ljava/lang/String;"
        r"\s*move-result-object\s+(v\d+)", body)
    if len(record_match) != 1 or len(action_match) != 1:
        raise ValueError("FCM: cannot establish trusted record/action register layout")
    rec, action = record_match[0], action_match[0]
    for needed in ("BroadcastRecord;->callerPackage:",
                   "BroadcastRecord;->callerApp:",
                   "AppOpsManagerInjector;->isAutoStartRestriction"):
        if needed not in body:
            raise ValueError(f"FCM: missing base method guard {needed}")

    call = re.compile(
        r"invoke-static\s+\{[vp]\d+\},\s*"
        r"Landroid/app/AppOpsManagerInjector;"
        r"->isAutoStartRestriction\(Ljava/lang/String;\)Z"
        r"\s*move-result\s+(v\d+)")
    hits = list(call.finditer(body))
    if len(hits) != 1:
        raise ValueError("FCM: expected exactly one Xiaomi autostart AppOp query")
    result = hits[0].group(1)
    if result in (rec, action, "v4", "v5"):
        raise ValueError("FCM: unsafe local register overlap")
    if not re.search(rf"(?m)^\s*if-nez\s+{re.escape(result)},\s*:\w+", body[hits[0].end():][:160]):
        raise ValueError("FCM: unknown branch after autostart restriction check")

    code = f"""
    # RYU-inspired: override only Xiaomi autostart restriction, after prior guards.
    # Do not accept a forged FCM action from an arbitrary sender.
    if-eqz {result}, :hypermos_ryu_fcm_autostart_only
    const-string v4, "{ACTION}"
    invoke-virtual {{v4, {action}}}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v4
    if-eqz v4, :hypermos_ryu_fcm_autostart_only
    iget-object v4, {rec}, Lcom/android/server/am/BroadcastRecord;->callerPackage:Ljava/lang/String;
    const-string v5, "com.google.android.gms"
    invoke-virtual {{v5, v4}}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v4
    if-eqz v4, :hypermos_ryu_fcm_autostart_only
    iget-object v4, {rec}, Lcom/android/server/am/BroadcastRecord;->callerApp:Lcom/android/server/am/ProcessRecord;
    if-eqz v4, :hypermos_ryu_fcm_autostart_only
    iget-object v4, v4, Lcom/android/server/am/ProcessRecord;->info:Landroid/content/pm/ApplicationInfo;
    if-eqz v4, :hypermos_ryu_fcm_autostart_only
    iget-object v4, v4, Landroid/content/pm/ApplicationInfo;->packageName:Ljava/lang/String;
    invoke-virtual {{v5, v4}}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v4
    if-eqz v4, :hypermos_ryu_fcm_autostart_only
    const/4 {result}, 0x0
:hypermos_ryu_fcm_autostart_only
"""
    updated = body[:hits[0].end()] + "\n" + code + body[hits[0].end():]
    return text[:m.start()] + updated + text[m.end():]


def first_boot_broadcast(text: str) -> str:
    """Audit the first-boot guard; keep stock behavior in the trial."""
    m = method(text, "updateBlockBroadcast()V")
    body = m.group()
    for needed in ("mSecurityInternal",
                   "isAllowedDeviceProvision()Z",
                   "is_block_broadcast_first_boot",
                   "mIsBlockBroadcastFirstBoot:Z"):
        if needed not in body:
            raise ValueError(f"first boot: expected security/provisioning guard {needed}")
    if ":hypermos_ryu_first_boot_marker" in body:
        raise ValueError("Unsafe first-boot early return remains in framework")
    return text


def foreground_service_protection(text: str) -> str:
    """Insert FGS protection only on the same task-cleanup path as RYU."""
    signature = "killAppForHasOtherTask(ILmiui/process/ProcessConfig;)Z"
    m = method(text, signature)
    body = m.group()
    marker = ":hypermos_ryu_fgs_cleanup_only"
    if marker in body:
        return text
    process_regs = re.findall(
        r'(?m)^\s*\.local\s+(v\d+),\s*"taskTopApp":'
        r'Lcom/android/server/am/ProcessRecord;\s*$', body)
    if len(process_regs) != 1:
        raise ValueError("FGS: cannot establish current ProcessRecord local")
    process_reg = process_regs[0]
    call = re.compile(
        r"invoke-static\s+\{[^}]+\},\s*"
        r"Lcom/android/server/wm/WindowProcessUtils;"
        r"->isProcessHasActivityInOtherTaskLocked\("
        r"Lcom/android/server/wm/WindowProcessController;I\)Z"
        r"\s*move-result\s+(v\d+)")
    hits = list(call.finditer(body))
    if len(hits) != 1:
        raise ValueError("FGS: expected one original other-task decision")
    after = body[hits[0].end():]
    decision = hits[0].group(1)
    guard = re.search(
        rf"(?m)^\s*if-nez\s+{re.escape(decision)},\s*(:\w+)\s*$", after)
    if not guard or guard.start() > 260:
        raise ValueError("FGS: original other-task guard not found")
    exit_label = guard.group(1)
    if process_reg in ("v2",) or decision == "v2":
        raise ValueError("FGS: unsafe temp/process register overlap")
    # In RYU the common exit branch returns true. Preserve that contract.
    exit_pos = body.find(exit_label + "\n", hits[0].end() + guard.end())
    if exit_pos < 0:
        raise ValueError("FGS: branch exit label undefined")
    if not re.search(r"const/4\s+v0,\s*0x1\s*[\r\n]+\s*return\s+v0",
                     body[exit_pos:exit_pos + 210]):
        raise ValueError("FGS: common exit no longer returns success")

    code = f"""
    # RYU: only protect a foreground service on the task-cleanup path.
    iget-object v2, {process_reg}, Lcom/android/server/am/ProcessRecord;->mServices:Lcom/android/server/am/ProcessServiceRecord;
    if-eqz v2, :hypermos_ryu_fgs_cleanup_only
    invoke-virtual {{v2}}, Lcom/android/server/am/ProcessServiceRecord;->hasForegroundServices()Z
    move-result v2
    if-nez v2, {exit_label}
:hypermos_ryu_fgs_cleanup_only
"""
    at = hits[0].end() + guard.end()
    updated = body[:at] + "\n" + code + body[at:]
    return text[:m.start()] + updated + text[m.end():]


def main(root: Path) -> None:
    if not root.is_dir():
        raise ValueError(f"Missing decompile directory: {root}")
    bq = one_class(root, "BroadcastQueueModernStubImpl")
    psc = one_class(root, "ProcessSceneCleaner")
    original = bq.read_text(encoding="utf-8")
    changed = first_boot_broadcast(fcm_autostart(original))
    ps_original = psc.read_text(encoding="utf-8")
    ps_changed = foreground_service_protection(ps_original)
    if ACTION not in changed or ":hypermos_ryu_autostart_original" not in changed:
        raise ValueError("FCM postcondition failed")
    # Atomic-ish: make no write until every target validated.
    bq.write_text(changed, encoding="utf-8")
    psc.write_text(ps_changed, encoding="utf-8")
    print("[RYU-A16] GMS-verified FCM autostart policy + task-specific FGS cleanup patched")
    print("[RYU-A16] Original first-boot provisioning, widget/NFC and Android permission controls preserved")


if __name__ == "__main__":
    try:
        if len(sys.argv) != 2:
            raise ValueError("Usage: ryu_policy_a16.py <decompiled-miui-services-dir>")
        main(Path(sys.argv[1]))
    except (ValueError, OSError) as exc:
        print(f"[RYU-A16] FAIL: {exc}", file=sys.stderr)
        sys.exit(1)
