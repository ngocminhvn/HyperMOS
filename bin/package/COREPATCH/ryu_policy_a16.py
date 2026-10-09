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
    # p2 can map to v20+ on A16; iget-object has a 4-bit source register.
    move-object/from16 v0, p2
    if-eqz v0, :hypermos_ryu_autostart_original
    iget-object v0, v0, Lcom/android/server/am/BroadcastRecord;->intent:Landroid/content/Intent;
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
    m = method(text, signature)
    body = m.group()
    if ":hypermos_ryu_first_boot_marker" in body:
        return text
    # On RYU the security service is initialized first, then its
    # first-boot blocking policy is skipped. Preserve that setup here.
    guard = re.compile(
        r"(?m)^[ \t]*invoke-virtual[^\n]*"
        r"Lmiui/security/SecurityManagerInternal;->isAllowedDeviceProvision\(\)Z[ \t]*$"
    )
    hits = list(guard.finditer(body))
    if len(hits) != 1:
        raise ValueError("updateBlockBroadcast: expected one provision guard")
    code = """
    # RYU A16: keep first-boot broadcast blocker disabled, after service init.
    const/4 v0, 0x0
    iput-boolean v0, p0, Lcom/android/server/am/BroadcastQueueModernStubImpl;->mIsBlockBroadcastFirstBoot:Z
    return-void
:hypermos_ryu_first_boot_marker
"""
    updated = body[:hits[0].start()] + code + body[hits[0].start():]
    return text[:m.start()] + updated + text[m.end():]


def foreground_service_protection(text: str) -> str:
    """Match RYU's task-cleanup guard, preserving the original successful return.

    Only skip killOnce() after Xiaomi has established that the task-top
    process has no activity in another task. Follow the existing success
    branch instead of returning false or aborting the method at entry.
    """
    signature = "killAppForHasOtherTask(ILmiui/process/ProcessConfig;)Z"
    m = method(text, signature)
    body = m.group()
    if ":hypermos_ryu_fgs_continue" in body:
        return text

    if "hasForegroundServices()Z" in body:
        # The genuine RYU JAR already contains this guard. Do not inject it
        # twice or rewrite proprietary com.projectryu.Build checks.
        if "Lcom/projectryu/Build;->IS_RYU_BUILD:Z" in body:
            return text
        raise ValueError("Unknown preexisting foreground-service protection")

    lines = body.splitlines(keepends=True)

    def next_instruction(index: int) -> int:
        for pos in range(index + 1, len(lines)):
            stripped = lines[pos].strip()
            if not stripped or stripped.startswith(("#", ".")):
                continue
            if stripped.startswith(":"):
                raise ValueError("Unexpected branch label inside FGS insertion point")
            return pos
        raise ValueError("Unexpected end of ProcessSceneCleaner method")

    matches = [
        index for index, line in enumerate(lines)
        if "Lcom/android/server/wm/WindowProcessUtils;->isProcessHasActivityInOtherTaskLocked(" in line
        and "invoke-static" in line
    ]
    if len(matches) != 1:
        raise ValueError("Expected one Xiaomi cross-task activity check")
    check_idx = matches[0]
    move_idx = next_instruction(check_idx)
    move = re.fullmatch(r"move-result\s+(v\d+)", lines[move_idx].strip())
    if not move:
        raise ValueError("Cross-task activity check lacks move-result")
    branch_idx = next_instruction(move_idx)
    branch = re.fullmatch(
        rf"if-nez\s+{re.escape(move.group(1))},\s*(:[A-Za-z_]\w*)",
        lines[branch_idx].strip()
    )
    if not branch:
        raise ValueError("Unexpected Xiaomi cross-task activity branch")
    exit_label = branch.group(1)

    label_sites = [i for i, line in enumerate(lines) if line.strip() == exit_label]
    if len(label_sites) != 1:
        raise ValueError(f"Expected one success branch {exit_label}")
    success_idx = next_instruction(label_sites[0])
    success = re.fullmatch(r"const/4\s+(v\d+),\s*0x1", lines[success_idx].strip())
    if not success:
        raise ValueError("Cross-task exit is not the Xiaomi return-true branch")
    return_idx = next_instruction(success_idx)
    if lines[return_idx].strip() != f"return {success.group(1)}":
        raise ValueError("Cross-task branch does not return true")

    info_idx = next_instruction(branch_idx)
    info = re.fullmatch(
        r"iget-object\s+(v\d+),\s*(v\d+),\s*"
        r"Lcom/android/server/am/ProcessRecord;->info:Landroid/content/pm/ApplicationInfo;",
        lines[info_idx].strip()
    )
    if not info:
        raise ValueError("Expected Xiaomi ProcessRecord.info immediately after task check")
    scratch, process_reg = info.groups()
    if scratch == process_reg or any(int(reg[1:]) > 15 for reg in (scratch, process_reg)):
        raise ValueError("Cannot safely borrow original ProcessRecord.info registers")
    # The next original instruction overwrites scratch, so its preexisting
    # live value is not needed on the fallthrough path.
    code = f"""
    # RYU HAOTIAN A16: keep a task-top process running an active FGS.
    iget-object {scratch}, {process_reg}, Lcom/android/server/am/ProcessRecord;->mServices:Lcom/android/server/am/ProcessServiceRecord;
    invoke-virtual {{{scratch}}}, Lcom/android/server/am/ProcessServiceRecord;->hasForegroundServices()Z
    move-result {scratch}
    if-nez {scratch}, {exit_label}
:hypermos_ryu_fgs_continue
"""
    # The existing cross-task branch already guarantees process_reg != null.
    # Preserve original control flow and the method's return true for FGS.
    lines.insert(branch_idx + 1, code)
    changed = "".join(lines)
    if "return v0\n:hypermos_ryu_fgs_continue" in changed:
        raise ValueError("Unexpected early return in FGS patch")
    return text[:m.start()] + changed + text[m.end():]


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
