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
    signature = ("checkApplicationAutoStart("
                 "Lcom/android/server/am/BroadcastQueue;"
                 "Lcom/android/server/am/BroadcastRecord;"
                 "Landroid/content/pm/ResolveInfo;)Z")
    m = method(text, signature)
    body = m.group()
    if "Lcom/android/server/am/BroadcastRecord;->intent:Landroid/content/Intent;" not in body:
        raise ValueError("BroadcastQueue target lacks expected BroadcastRecord intent")
    # Closely follows RYU's action-specific fast path; the underlying Android
    # sender/receiver permission checks are not modified by this patch.
    code = f"""
    # RYU A16: Xiaomi autostart exemption for incoming FCM action only.
    if-eqz p2, :hypermos_ryu_autostart_original
    iget-object v0, p2, Lcom/android/server/am/BroadcastRecord;->intent:Landroid/content/Intent;
    if-eqz v0, :hypermos_ryu_autostart_original
    invoke-virtual {{v0}}, Landroid/content/Intent;->getAction()Ljava/lang/String;
    move-result-object v0
    const-string v1, "{ACTION}"
    invoke-virtual {{v1, v0}}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :hypermos_ryu_autostart_original
    const/4 v0, 0x1
    return v0
:hypermos_ryu_autostart_original
"""
    return inject(text, signature, ":hypermos_ryu_autostart_original", code)


def first_boot_broadcast(text: str) -> str:
    signature = "updateBlockBroadcast()V"
    if "mIsBlockBroadcastFirstBoot:Z" not in text:
        raise ValueError("first-boot broadcast field not found")
    # RYU exits updateBlockBroadcast() before enabling its first-boot blocker.
    code = """
    # RYU A16: keep first-boot broadcast blocker disabled.
    const/4 v0, 0x0
    iput-boolean v0, p0, Lcom/android/server/am/BroadcastQueueModernStubImpl;->mIsBlockBroadcastFirstBoot:Z
    return-void
:hypermos_ryu_first_boot_marker
"""
    return inject(text, signature, ":hypermos_ryu_first_boot_marker", code, 1)


def foreground_service_protection(text: str) -> str:
    signature = "killAppForHasOtherTask(ILmiui/process/ProcessConfig;)Z"
    body = method(text, signature).group()
    for need in ("getTaskTopApp(I)", "isProcessHasActivityInOtherTaskLocked"):
        if need not in body:
            raise ValueError(f"ProcessSceneCleaner differs from RYU: missing {need}")
    # Avoid killing an activity's process if it still hosts an active FGS.
    # RYU makes this check on the 'other task' cleanup path.
    code = """
    # RYU A16: protect foreground-service processes in task cleanup.
    invoke-static {p1}, Lcom/android/server/wm/WindowProcessUtils;->getTaskTopApp(I)Lcom/android/server/wm/WindowProcessController;
    move-result-object v0
    if-eqz v0, :hypermos_ryu_fgs_continue
    iget-object v0, v0, Lcom/android/server/wm/WindowProcessController;->mOwner:Ljava/lang/Object;
    instance-of v1, v0, Lcom/android/server/am/ProcessRecord;
    if-eqz v1, :hypermos_ryu_fgs_continue
    check-cast v0, Lcom/android/server/am/ProcessRecord;
    iget-object v0, v0, Lcom/android/server/am/ProcessRecord;->mServices:Lcom/android/server/am/ProcessServiceRecord;
    if-eqz v0, :hypermos_ryu_fgs_continue
    invoke-virtual {v0}, Lcom/android/server/am/ProcessServiceRecord;->hasForegroundServices()Z
    move-result v0
    if-eqz v0, :hypermos_ryu_fgs_continue
    const/4 v0, 0x0
    return v0
:hypermos_ryu_fgs_continue
"""
    return inject(text, signature, ":hypermos_ryu_fgs_continue", code)


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
    print("[RYU-A16] FCM broadcast + first-boot policy + FGS task cleanup patched")
    print("[RYU-A16] Android permission checks, RYU-private hooks, Doze, forced force-stop policies untouched")


if __name__ == "__main__":
    try:
        if len(sys.argv) != 2:
            raise ValueError("Usage: ryu_policy_a16.py <decompiled-miui-services-dir>")
        main(Path(sys.argv[1]))
    except (ValueError, OSError) as exc:
        print(f"[RYU-A16] FAIL: {exc}", file=sys.stderr)
        sys.exit(1)
