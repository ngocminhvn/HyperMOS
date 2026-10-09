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
    """Make the FCM exemption only after stock ResolveInfo/ApplicationInfo checks.

    Never overwrite a live local: a new register is allocated for the result.
    The helper is action-only, and has no effect on Android broadcast permissions.
    """
    signature = ("checkApplicationAutoStart("
                 "Lcom/android/server/am/BroadcastQueue;"
                 "Lcom/android/server/am/BroadcastRecord;"
                 "Landroid/content/pm/ResolveInfo;)Z")
    m = method(text, signature)
    body = m.group()
    marker = ":hypermos_ryu_autostart_original"
    helper_sig = "hypermosRyuIsFcmBroadcast(Lcom/android/server/am/BroadcastRecord;)Z"
    if marker in body:
        if text.count(".method private static " + helper_sig) != 1:
            raise ValueError("FCM exemption marker exists without its helper")
        return text
    # Preserve an existing FCM exemption only if receiver/application
    # resolution already precedes the action check, as it does in RYU.
    if ACTION in body:
        action_at = body.find(ACTION)
        resolve_at = body.find("ResolveInfo;->")
        app_at = body.find("ApplicationInfo;")
        print(f"[RYU-A16-FCM] existing action at {action_at}, "
              f"ResolveInfo at {resolve_at}, ApplicationInfo at {app_at}",
              flush=True)
        if min(resolve_at, app_at) < 0 or action_at <= max(resolve_at, app_at):
            raise ValueError("Existing FCM path is not after receiver/app resolution")
        return text

    if "Lcom/android/server/am/BroadcastRecord;->intent:Landroid/content/Intent;" not in body:
        raise ValueError("Expected BroadcastRecord.intent missing")
    # Require the actual Xiaomi receiver path, not a guessed method entry.
    resolve = re.search(
        r"(?m)^    iget-object\s+v\d+,\s*[vp]\d+,\s*"
        r"Landroid/content/pm/ResolveInfo;->activityInfo:Landroid/content/pm/ActivityInfo;\s*$",
        body)
    if not resolve:
        raise ValueError("ResolveInfo.activityInfo gate not found")
    app_matches = list(re.finditer(
        r"(?m)^    iget-object\s+(?P<app>v\d+),\s*[vp]\d+,\s*"
        r"Landroid/content/pm/ActivityInfo;->applicationInfo:Landroid/content/pm/ApplicationInfo;\s*$",
        body))
    if len(app_matches) != 1 or app_matches[0].start() <= resolve.start():
        raise ValueError("Expected one ApplicationInfo extraction after ResolveInfo")
    app = app_matches[0]
    # Insert only on the validated receiver path: preserve Xiaomi's null guard.
    tail = body[app.end():]
    guard = re.search(rf"(?m)^[ \t]*if-eqz[ \t]+{re.escape(app.group('app'))},[ \t]*:\w+[ \t]*$", tail)
    if not guard or len(tail[:guard.start()].splitlines()) > 12:
        raise ValueError("Expected nearby ApplicationInfo null guard; fail closed")
    insert_at = app.end() + guard.end()
    if ".method static " in body.splitlines()[0]:
        raise ValueError("Unexpected static Xiaomi autostart method")
    reg = re.search(r"(?m)^    \.(locals|registers)\s+(\d+)\s*$", body)
    if not reg:
        raise ValueError("Autostart register directive missing")
    kind, num = reg.group(1), int(reg.group(2))
    # Nonstatic parameters: this, BroadcastQueue, BroadcastRecord, ResolveInfo.
    available = num if kind == "locals" else num - 4
    if available < 0 or available >= 255:
        raise ValueError("No safe fresh Dalvik local available")
    # Xiaomi generally uses pN parameter aliases. Explicit vN aliases to
    # parameter registers would shift if register count is increased.
    used = [int(x) for x in re.findall(r"\bv(\d+)\b", body[reg.end():])]
    if kind == "registers" and any(i >= available for i in used):
        raise ValueError("Autostart uses vN parameter aliases; cannot grow registers")
    temp = f"v{available}"
    klass = re.search(
        r"(?m)^\.class[^\n]*\s+(Lcom/android/server/am/BroadcastQueueModernStubImpl;)\s*$", text)
    if not klass:
        raise ValueError("Unexpected BroadcastQueue class descriptor")
    invoke = klass.group(1) + "->" + helper_sig
    addition = f"""
    # RYU FCM: only after ResolveInfo/ActivityInfo/ApplicationInfo validation.
    invoke-static/range {{p2 .. p2}}, {invoke}
    move-result {temp}
    if-eqz {temp}, {marker}
    return {temp}
{marker}
"""
    new_body = body[:insert_at] + "\n" + addition + body[insert_at:]
    new_reg = f"    .{kind} {num + 1}"
    new_body = new_body[:reg.start()] + new_reg + new_body[reg.end():]
    patched = text[:m.start()] + new_body + text[m.end():]
    if helper_sig in text:
        raise ValueError("FCM helper signature already present without patch marker")
    helper = f"""
.method private static {helper_sig}
    .locals 2
    if-eqz p0, :hypermos_ryu_fcm_no
    iget-object v0, p0, Lcom/android/server/am/BroadcastRecord;->intent:Landroid/content/Intent;
    if-eqz v0, :hypermos_ryu_fcm_no
    invoke-virtual {{v0}}, Landroid/content/Intent;->getAction()Ljava/lang/String;
    move-result-object v0
    const-string v1, "{ACTION}"
    invoke-virtual {{v1, v0}}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    return v0
:hypermos_ryu_fcm_no
    const/4 v0, 0x0
    return v0
.end method
"""
    return patched.rstrip() + "\n\n" + helper.strip() + "\n"

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
    """Enable Xiaomi's EXISTING FGS guard, exactly as RYU does for HAOTIAN.

    Stock Xiaomi already protects a foreground service in
    killAppForHasOtherTask(), but only if IS_INTERNATIONAL_BUILD is true.
    Real RYUOS replaces that gate with IS_RYU_BUILD (true on RYU).
    Reproduce the same true-gate outcome on HyperMOS CN without inserting
    another hasForegroundServices() call or changing the success return.
    """
    signature = "killAppForHasOtherTask(ILmiui/process/ProcessConfig;)Z"
    m = method(text, signature)
    body = m.group()
    marker = "# HyperMOS RYU FGS: enable existing Xiaomi guard"
    if marker in body:
        return text

    if "Lcom/projectryu/Build;->IS_RYU_BUILD:Z" in body:
        # The reference RYU JAR already implements exactly this behavior.
        return text

    if body.count("hasForegroundServices()Z") != 1:
        raise ValueError("Expected exactly one existing Xiaomi FGS check")

    gate = re.compile(
        r"(?m)^(?P<indent>[ \t]*)sget-boolean[ \t]+(?P<reg>v\d+),[ \t]*"
        r"Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z[ \t]*$"
    )
    found = list(gate.finditer(body))
    if len(found) != 1:
        raise ValueError("Expected exactly one Xiaomi international FGS gate")
    g = found[0]
    reg = g.group("reg")
    if int(reg[1:]) > 15:
        raise ValueError("International FGS gate register cannot use const/4")
    # Match the original Xiaomi sequence, including debug metadata.
    tail = body[g.end():]
    next_branch = re.match(
        rf"(?s)^[ \t]*\n(?:[ \t]*(?:\.[^\n]+|#[^\n]*)?\n)*"
        rf"[ \t]*if-eqz[ \t]+{re.escape(reg)},[ \t]*(?P<skip>:\w+)[ \t]*",
        tail
    )
    if not next_branch:
        raise ValueError("Expected Xiaomi FGS gate's original if-eqz")
    skip = next_branch.group("skip")
    block_start = g.end() + next_branch.end()
    block = body[block_start:]
    check = re.match(
        rf"(?s)^\s*iget-object[ \t]+(?P<tmp>v\d+),[ \t]*(?P<proc>v\d+),[ \t]*"
        rf"Lcom/android/server/am/ProcessRecord;->mServices:Lcom/android/server/am/ProcessServiceRecord;"
        rf"\s*(?:\.[^\n]+\s*)?"
        rf"invoke-virtual[ \t]+\{{(?P=tmp)\}},[ \t]*"
        rf"Lcom/android/server/am/ProcessServiceRecord;->hasForegroundServices\(\)Z"
        rf"\s*move-result[ \t]+(?P=tmp)\s*"
        rf"if-nez[ \t]+(?P=tmp),[ \t]*(?P<done>:\w+)",
        block,
    )
    if not check:
        raise ValueError("Unexpected Xiaomi FGS guard body; refusing rewrite")
    done = check.group("done")
    if done == skip:
        raise ValueError("FGS skip label cannot be the success return")
    skip_locations = re.findall(rf"(?m)^[ \t]*{re.escape(skip)}[ \t]*$", body)
    done_locations = list(re.finditer(rf"(?m)^[ \t]*{re.escape(done)}[ \t]*$", body))
    if len(skip_locations) != 1 or len(done_locations) != 1:
        raise ValueError("Missing or ambiguous original Xiaomi FGS branch labels")
    if done_locations[0].start() <= g.start():
        raise ValueError("Unexpected Xiaomi FGS return branch ordering")
    done_tail = body[done_locations[0].end():]
    if not re.match(r"(?s)^\s*const/4[ \t]+(?P<reg>v\d+),[ \t]*0x1\s*return[ \t]+(?P=reg)\b", done_tail):
        raise ValueError("FGS exit does not return true on the stock Xiaomi path")
    cross = body.find("isProcessHasActivityInOtherTaskLocked(")
    if cross < 0 or cross >= g.start():
        raise ValueError("FGS guard not located on the Xiaomi cross-task cleanup path")
    # Only change the existing stock international-build gate to true.
    # Retain the original FGS call, killOnce(), branches and return value.
    edit = f"{g.group('indent')}{marker}\n{g.group('indent')}const/4 {reg}, 0x1"
    changed = body[:g.start()] + edit + body[g.end():]
    if changed.count("hasForegroundServices()Z") != 1:
        raise ValueError("FGS call count changed unexpectedly")
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
    signature = ("checkApplicationAutoStart("
                 "Lcom/android/server/am/BroadcastQueue;"
                 "Lcom/android/server/am/BroadcastRecord;"
                 "Landroid/content/pm/ResolveInfo;)Z")
    post_fcm = method(changed, signature).group()
    if ":hypermos_ryu_autostart_original" not in post_fcm and ACTION not in post_fcm:
        raise ValueError("FCM postcondition failed: no action or guarded fast path")
    if ":hypermos_ryu_autostart_original" in post_fcm and (
            "hypermosRyuIsFcmBroadcast(" not in post_fcm or ACTION not in changed):
        raise ValueError("FCM postcondition failed: helper/marker mismatch")
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
