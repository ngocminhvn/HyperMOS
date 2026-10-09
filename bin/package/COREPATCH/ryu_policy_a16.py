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
    """Replicate the one-instruction RYU FCM gate delta, in its stock position.

    Xiaomi stock already parses ResolveInfo, ApplicationInfo and C2DM action.
    RYU changes IS_INTERNATIONAL_BUILD(false on CN) to IS_RYU_BUILD(true),
    after reading ApplicationInfo.uid and before the C2DM action test.
    Do NOT insert an early return or duplicate the FCM check.
    """
    signature = ("checkApplicationAutoStart("
                 "Lcom/android/server/am/BroadcastQueue;"
                 "Lcom/android/server/am/BroadcastRecord;"
                 "Landroid/content/pm/ResolveInfo;)Z")
    m = method(text, signature)
    body = m.group()
    marker = "# HyperMOS RYU FCM: enable existing post-ApplicationInfo gate"
    if marker in body:
        return text
    if ACTION not in body or "ResolveInfo;->activityInfo:" not in body or (
            "ActivityInfo;->applicationInfo:" not in body or
            "ApplicationInfo;->uid:I" not in body):
        raise ValueError("FCM method lacks stock receiver/app/action sequence")

    action_at = body.index(ACTION)
    app_at = body.index("ApplicationInfo;->uid:I")
    if app_at >= action_at:
        raise ValueError("FCM action is not after ApplicationInfo uid resolution")

    # The authentic RYU JAR already uses its own true-build flag here.
    if "Lcom/projectryu/Build;->IS_RYU_BUILD:Z" in body:
        return text

    lines = body.splitlines(keepends=True)
    gate_pat = re.compile(
        r"^([ \t]*)sget-boolean[ \t]+(?P<reg>v\d+),[ \t]*"
        r"Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z[ \t]*(?:\n|$)"
    )
    candidates = []
    for i, line in enumerate(lines):
        g = gate_pat.match(line)
        if not g:
            continue
        reg = g.group("reg")
        # Skip only smali debug directives and comments. These instruction
        # neighbors match the actual stock/RYU HAOTIAN method-level delta.
        nxt = []
        for extra in lines[i + 1:]:
            stmt = extra.strip()
            if not stmt or stmt.startswith(("#", ".line", ".local", ".end local",
                                             ".restart local", ".prologue")):
                continue
            nxt.append(stmt)
            if len(nxt) == 2:
                break
        if (len(nxt) == 2
                and re.fullmatch(rf"if-eqz[ \t]+{re.escape(reg)},[ \t]*:\w+", nxt[0])
                and re.fullmatch(
                    rf"const-string(?:/jumbo)?[ \t]+v\d+,[ \t]*\"{re.escape(ACTION)}\"",
                    nxt[1])):
            candidates.append((i, g, reg))
    if len(candidates) != 1:
        raise ValueError(f"Expected one stock FCM build gate, found {len(candidates)}")
    i, g, reg = candidates[0]
    if int(reg[1:]) > 15:
        raise ValueError("FCM gate register cannot use const/4")
    if sum(len(x) for x in lines[:i]) <= app_at:
        raise ValueError("FCM build gate is before ApplicationInfo check")
    lines[i] = f"{g.group(1)}{marker}\n{g.group(1)}const/4 {reg}, 0x1\n"
    patched = "".join(lines)
    if patched.count(marker) != 1 or patched.count(ACTION) != 1:
        raise ValueError("FCM one-instruction gate postcondition failed")
    return text[:m.start()] + patched + text[m.end():]

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
    if ACTION not in post_fcm or not (
            "# HyperMOS RYU FCM: enable existing post-ApplicationInfo gate" in post_fcm
            or "Lcom/projectryu/Build;->IS_RYU_BUILD:Z" in post_fcm):
        raise ValueError("FCM postcondition failed: exact RYU gate not present")
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
