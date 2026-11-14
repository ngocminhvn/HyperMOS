#!/usr/bin/env python3
"""Pure Global Android 17 / OS4 notification and power management patcher for miui-services.jar.

Switches HyperOS 2 / OS4 into native International policy mode without custom hook methods:
1. PolicyManagerConfig: forces isCnModel()Z to return false (0), activating native InternationalPolicyManager
   in Greeze and Aurogon (handles C2DM apps and keeps push sockets open).
2. WakePathChecker, SecurityManagerService, ActivityStarter, NotificationManagerService:
   redirects Build.IS_INTERNATIONAL_BUILD to xBuild.IS_INTERNATIONAL_BUILD.
3. NotificationManagerServiceImpl: native IS_INTERNATIONAL_BUILD check cleanly skips AppOps 0x2725
   restriction on fullScreenIntent, allowing incoming call UI on lock screen for all apps.
4. ProcessManagerService: preserves scoped AutoIdleKill (policy 0xd = 13) so idle apps can sleep,
   while keeping Global semantics for other kill policies.
5. AurogonFilterManager, GreezeManagerService, AlarmManagerServiceStub, PowerManagerService,
   MiuiNetworkPolicyManagerService: ensures Google Play Services (GMS) is unblocked from
   China-specific background throttling, network limits, and sleep-mode firewalls.
6. Removes custom fcm_c2dm_thaw injections and custom background activity launch preambles,
   restoring clean stock Modern Broadcast Queue and ActivityStarter execution.
"""
import argparse
import json
import re
from pathlib import Path

def edit_method(source, signature, edit):
    pattern = rf"(?ms)^\.method[^\n]*\s{signature}[ \t]*\n.*?^\.end method[ \t]*$"
    matches = list(re.finditer(pattern, source))
    if len(matches) != 1:
        raise ValueError(f"expected one method matching {signature}, got {len(matches)}")
    method = matches[0]
    return source[:method.start()] + edit(method.group()) + source[method.end():]

PROCESS_MANAGER = "com/android/server/am/ProcessManagerService.smali"
GREEZE_SERVICE = "com/miui/server/greeze/GreezeManagerService.smali"
AUROGON_FILTER = "com/miui/server/greeze/AurogonFilterManager.smali"
DOMESTIC_POLICY = "com/miui/server/greeze/DomesticPolicyManager.smali"
ALARM_STUB = "com/android/server/alarm/AlarmManagerServiceStubImpl.smali"
POWER_IMPL = "com/android/server/power/PowerManagerServiceImpl.smali"
NETWORK_POLICY = "com/android/server/net/MiuiNetworkPolicyManagerService.smali"
BQ_STUB = "com/android/server/am/BroadcastQueueModernStubImpl.smali"
ACTIVITY_STARTER = "com/android/server/wm/ActivityStarterImpl.smali"
AMS_IMPL = "com/android/server/am/ActivityManagerServiceImpl.smali"
POLICY_CONFIG = "com/miui/server/greeze/PolicyManagerConfig.smali"
WAKEPATH_CHECKER = "com/miui/server/WakePathChecker.smali"
SECURITY_MANAGER = "com/miui/server/SecurityManagerService.smali"
SECURITY_LOCAL_SERVICE = "com/miui/server/SecurityManagerService$LocalService.smali"
FSI_CLASS = "com/android/server/notification/NotificationManagerServiceImpl.smali"

REGION_GATES = (
    ("com/android/server/am/BroadcastQueueModernStubImpl.smali",
     "checkApplicationAutoStart(Lcom/android/server/am/BroadcastQueue;Lcom/android/server/am/BroadcastRecord;Landroid/content/pm/ResolveInfo;)Z"),
    ("com/android/server/am/ActivityManagerServiceImpl.smali",
     "checkRunningCompatibility(Landroid/content/ComponentName;III)Z"),
    ("com/android/server/alarm/AlarmManagerServiceStubImpl.smali",
     "init(Lcom/android/server/alarm/AlarmManagerService;)V"),
)

AUTO_IDLE_POLICY = re.compile(r"(?m)^[ \t]*const/16[ \t]+([vp]\d+),[ \t]+0xd[ \t]*$")
FORCE_STOP_METHOD = re.compile(
    r"(?ms)^\.method[^\n]*\bisForceStopEnable\(Lcom/android/server/am/ProcessRecord;I\)Z[^\n]*\n"
    r".*?^\.end method[ \t]*$"
)

REGION_READ = re.compile(
    r"(?m)^([ \t]*)sget-boolean[ \t]+([vp]\d+),[ \t]+"
    r"Lmiui/os/(?:x)?Build;->IS_INTERNATIONAL_BUILD:Z([ \t]*.*)$"
)


def locate(root: Path, relative: str):
    matches = [p for p in root.glob("smali*/" + relative) if p.is_file()]
    if not matches:
        direct = root / relative
        if direct.is_file():
            return direct
    if len(matches) > 1:
        raise ValueError(f"Duplicate smali class: {relative}")
    return matches[0] if matches else None


def patch_region_gate(source, signature):
    def edit(block):
        if "# XNotifyFix international gate" in block or ":a17_compat_ready" in block:
            return block
        if signature.startswith("checkRunningCompatibility(") and re.search(
            r"(?m)^    move-object/from16 v1, p1\s+if-eqz v1, :\w+\s+const/4 v1, 0x1",
            block,
        ):
            return block
        if signature.startswith("init(") and re.search(
            r"(?m)^    const/4 (v\d+), 0x1\s+if-eqz \1, :\w+\s+"
            r"(?:\.line \d+\s+)?new-instance \1, Ljava/util/ArrayList;",
            block,
        ):
            return block

        matches = list(REGION_READ.finditer(block))
        if not matches:
            if signature.startswith("checkApplicationAutoStart(") and re.search(
                r'(?m)^    const/(?:4|16) (v\d+), 0x1\s+if-eqz \1, :[^\n]+'
                r'\s+(?:\.line \d+\s+)?const-string(?:/jumbo)? \1, "com.google.android.c2dm.intent.RECEIVE"',
                block,
            ):
                return block
            raise ValueError(f"{signature}: region gate missing")
        gate = matches[0]
        indent, register, _ = gate.groups()
        opcode = "const/4" if int(register[1:]) <= 15 else "const/16"
        replacement = f"{indent}{opcode} {register}, 0x1  # XNotifyFix international gate"
        if signature.startswith("checkRunningCompatibility("):
            if register != "v1":
                raise ValueError("checkRunningCompatibility: unexpected region register")
            replacement = (
                "    move-object/from16 v1, p1\n\n"
                "    if-eqz v1, :a17_compat_null\n\n"
                "    const/4 v1, 0x1\n\n"
                "    goto :a17_compat_ready\n\n"
                "    :a17_compat_null\n"
                "    const/4 v1, 0x0\n\n"
                "    :a17_compat_ready"
            )
        return block[:gate.start()] + replacement + block[gate.end():]

    return edit_method(source, re.escape(signature), edit)


def patch_force_stop(source: str):
    methods = list(FORCE_STOP_METHOD.finditer(source))
    if len(methods) != 1:
        raise ValueError(f"ProcessManagerService: expected one isForceStopEnable, got {len(methods)}")
    block = methods[0].group()
    if not AUTO_IDLE_POLICY.search(block):
        raise ValueError("ProcessManagerService: AutoIdleKill policy 13 (0xd) guard missing")
    if ":hypermos_keep_notif_all_stock" in block:
        raise ValueError("ProcessManagerService: unconditional KEEP_NOTIF=ALL hook still present")

    gates = list(REGION_READ.finditer(block))
    if not gates:
        if re.search(r"(?m)^\s+const/4\s+v\d+,\s+0x1\s+const/4\s+v\d+,\s+0x0\s+if-eqz", block):
            return source, {
                "method_patched": False,
                "already_patched": True,
                "keep_notifications": "scoped_268",
                "auto_idle_policy_13": "stock_force_stop",
                "runtime_module_required": False,
            }
        raise ValueError("ProcessManagerService: region read missing; cannot verify #268 policy-13 behavior")

    def enable_international(match):
        indent, register, suffix = match.groups()
        opcode = "const/4" if int(register[1:]) <= 15 else "const/16"
        return f"{indent}{opcode} {register}, 0x1{suffix}"

    patched_block = REGION_READ.sub(enable_international, block)
    output = source[:methods[0].start()] + patched_block + source[methods[0].end():]
    return output, {
        "method_patched": True,
        "keep_notifications": "scoped_268",
        "auto_idle_policy_13": "stock_force_stop",
        "region_reads_replaced": len(gates),
        "runtime_module_required": False,
    }


def disable_gms_app_check(source):
    def edit(block):
        if re.fullmatch(
            r"\.method[^\n]*\n\s*\.(?:registers|locals) \d+\s+"
            r"const/4 ([vp]\d+), 0x0\s+return \1\s+\.end method",
            block,
        ):
            return block
        header = block.splitlines()[0]
        return f"{header}\n    .registers 2\n\n    const/4 p0, 0x0\n\n    return p0\n.end method"

    return edit_method(source, r"isGmsApp\(I\)Z", edit)


def replace_void_method(source: str, signature: str, registers: int = 1):
    method_re = re.compile(
        rf"(?ms)^\.method[^\n]*\b{re.escape(signature)}[^\n]*\n.*?^\.end method[ \t]*$"
    )
    methods = list(method_re.finditer(source))
    if len(methods) != 1:
        raise ValueError(f"expected one {signature}, got {len(methods)}")
    header = methods[0].group().splitlines()[0]
    replacement = (
        f"{header}\n"
        f"    .registers {registers}\n\n"
        "    return-void\n"
        ".end method"
    )
    return source[:methods[0].start()] + replacement + source[methods[0].end():]


def find_header_end(block: str) -> int:
    lines = block.splitlines(True)
    in_annotation = False
    header_end = 0
    cur_pos = 0
    for line in lines:
        stripped = line.strip()
        if stripped.startswith(".method"):
            cur_pos += len(line)
            header_end = cur_pos
            continue
        if stripped.startswith(".annotation"):
            in_annotation = True
            cur_pos += len(line)
            header_end = cur_pos
            continue
        if in_annotation:
            cur_pos += len(line)
            header_end = cur_pos
            if stripped == ".end annotation":
                in_annotation = False
            continue
        if stripped.startswith((".registers", ".locals", ".param", ".end param", ".prologue", ".line")):
            cur_pos += len(line)
            header_end = cur_pos
            continue
        if not stripped:
            cur_pos += len(line)
            continue
        break
    return header_end


def count_param_registers(signature: str, is_static: bool = False) -> int:
    params_match = re.search(r"\((.*?)\)", signature)
    if not params_match:
        return 0
    param_str = params_match.group(1)
    count = 0 if is_static else 1
    i = 0
    while i < len(param_str):
        c = param_str[i]
        if c in "ZBCSIF":
            count += 1
            i += 1
        elif c in "JD":
            count += 2
            i += 1
        elif c == "[":
            while i < len(param_str) and param_str[i] == "[":
                i += 1
            if i < len(param_str):
                if param_str[i] == "L":
                    end = param_str.find(";", i)
                    i = end + 1 if end != -1 else len(param_str)
                else:
                    i += 1
            count += 1
        elif c == "L":
            end = param_str.find(";", i)
            i = end + 1 if end != -1 else len(param_str)
            count += 1
        else:
            i += 1
    return count


def inject_method_preamble(source: str, signature: str, preamble: str, label: str, min_locals: int = 2):
    method_re = re.compile(
        rf"(?ms)^\.method[^\n]*\b{re.escape(signature)}[^\n]*\n.*?^\.end method[ \t]*$"
    )
    methods = list(method_re.finditer(source))
    if len(methods) != 1:
        raise ValueError(f"expected one {signature}, got {len(methods)}")
    block = methods[0].group()

    clean_lines = [l.strip() for l in preamble.splitlines() if l.strip() and not l.strip().startswith("#")]
    body_lines = clean_lines[:-1] if clean_lines and clean_lines[-1].startswith(":") else clean_lines
    escaped = [re.escape(l) for l in body_lines]
    pattern_str = r"\s+".join(escaped)
    pattern_str = re.sub(r":fcm_a17_\w+", lambda _: r":\w+", pattern_str)
    if re.search(pattern_str, block):
        return source

    if label in block:
        raise ValueError(
            f"{signature}: found {label} but bytecode differs from target preamble; "
            f"refusing to patch to preserve stock bytecode integrity"
        )

    is_static = bool(re.search(r"(?m)^\.method[^\n]*\bstatic\b", block))
    param_count = count_param_registers(signature, is_static)
    reg_match = re.search(r"(?m)^([ \t]*)\.(registers|locals)[ \t]+(\d+)[ \t]*$", block)
    if not reg_match:
        raise ValueError(f"{signature}: missing registers/locals declaration")
    indent, kind, val_str = reg_match.groups()
    val = int(val_str)
    if kind == "locals":
        if val < min_locals:
            new_reg_line = f"{indent}.locals {min_locals}"
            block = block[:reg_match.start()] + new_reg_line + block[reg_match.end():]
    else:
        num_locals = val - param_count
        if num_locals < min_locals:
            raise ValueError(f"{signature}: insufficient local registers (locals={num_locals}, required={min_locals})")

    at = find_header_end(block)
    if at <= 0:
        raise ValueError(f"{signature}: failed to locate method header directives")
    block = block[:at] + "\n\n" + preamble.rstrip() + "\n" + block[at:]

    return source[:methods[0].start()] + block + source[methods[0].end():]


def replace_boolean_method(source: str, signature: str, value: int):
    method_re = re.compile(
        rf"(?ms)^\.method[^\n]*\b{re.escape(signature)}[^\n]*\n.*?^\.end method[ \t]*$"
    )
    methods = list(method_re.finditer(source))
    if len(methods) != 1:
        raise ValueError(f"expected one {signature}, got {len(methods)}")
    header = methods[0].group().splitlines()[0]
    replacement = (
        f"{header}\n"
        "    .locals 1\n\n"
        f"    const/4 v0, 0x{value:x}\n\n"
        "    return v0\n"
        ".end method"
    )
    return source[:methods[0].start()] + replacement + source[methods[0].end():]


def clean_injected_c2dm_hooks(source: str) -> str:
    """Restores BroadcastQueueModernStubImpl methods to clean stock code."""
    # Clean checkReceiverAppDealBroadcast
    deal_re = re.compile(
        r"(?ms)^\.method[^\n]*\bcheckReceiverAppDealBroadcast\([^\n]*\n.*?^\.end method[ \t]*$"
    )
    m = deal_re.search(source)
    if m:
        block = m.group(0)
        if "fcm_c2dm_thaw" in block or ":fcm_a17_deal_stock" in block:
            c_match = re.search(r"(?m)^[ \t]*:cond_[0-9a-f]+\s*\n[ \t]*move-object/from16 v1, p2", block)
            if not c_match:
                c_match = re.search(r"(?m)^[ \t]*:fcm_a17_deal_stock\s*\n", block)
            if c_match:
                hdr_end = find_header_end(block)
                block = block[:hdr_end] + "\n\n    " + block[c_match.start():].lstrip()
                source = source[:m.start()] + block + source[m.end():]

    # Clean checkReceiverIfRestricted
    restr_re = re.compile(
        r"(?ms)^\.method[^\n]*\bcheckReceiverIfRestricted\([^\n]*\n.*?^\.end method[ \t]*$"
    )
    m = restr_re.search(source)
    if m:
        block = m.group(0)
        if "com.google.android.c2dm.intent.RECEIVE" in block and (
            ":fcm_a17_restr_stock" in block or "const/4 v0, 0x0\n\n    return v0" in block
        ):
            c_match = re.search(r"(?m)^[ \t]*:cond_[0-9a-f]+\s*\n[ \t]*invoke-static \{\}, Lcom/miui/server/greeze/GreezeManagerInternal;", block)
            if not c_match:
                c_match = re.search(r"(?m)^[ \t]*:fcm_a17_restr_stock\s*\n", block)
            if c_match:
                hdr_end = find_header_end(block)
                block = block[:hdr_end] + "\n\n    " + block[c_match.start():].lstrip()
                source = source[:m.start()] + block + source[m.end():]

    # Clean isInDeferCachedWhiteList
    defer_re = re.compile(
        r"(?ms)^\.method[^\n]*\bisInDeferCachedWhiteList\([^\n]*\n.*?^\.end method[ \t]*$"
    )
    m = defer_re.search(source)
    if m:
        block = m.group(0)
        if "com.google.android.c2dm.intent.RECEIVE" in block and (
            ":fcm_a17_defer_stock" in block or "iput-boolean v0, v1, Lcom/android/server/am/BroadcastRecord;->deferUntilActive:Z" in block
        ):
            c_match = re.search(r"(?m)^[ \t]*:cond_[0-9a-f]+\s*\n[ \t]*invoke-static \{p1\}, Landroid/text/TextUtils;->isEmpty", block)
            if not c_match:
                c_match = re.search(r"(?m)^[ \t]*:fcm_a17_defer_stock\s*\n", block)
            if c_match:
                hdr_end = find_header_end(block)
                block = block[:hdr_end] + "\n\n    " + block[c_match.start():].lstrip()
                source = source[:m.start()] + block + source[m.end():]

    return source


def clean_injected_activity_starter_hooks(source: str) -> str:
    """Restores ActivityStarterImpl methods to clean stock code."""
    # Clean checkStartActivityPermission
    m = re.search(r"(?ms)^\.method[^\n]*\bcheckStartActivityPermission\(Lcom/android/server/wm/ActivityStarter\$Request;\)Z\n.*?^\.end method[ \t]*$", source)
    if m:
        block = m.group(0)
        if "com.zing.zalo" in block or ":fsi_a17_check_start_stock" in block:
            c_match = re.search(r"(?m)^[ \t]*(?::cond_[0-9a-f]+|:goto_[0-9a-f]+|:fsi_a17_check_start_stock)\s*\n[ \t]*move-object/from16 v7, p1", block)
            if c_match:
                hdr_end = find_header_end(block)
                block = block[:hdr_end] + "\n\n    " + block[c_match.start():].lstrip()
                source = source[:m.start()] + block + source[m.end():]

    # Clean isAllowedStartActivity 3-param
    m = re.search(r"(?ms)^\.method[^\n]*\bisAllowedStartActivity\(IILjava/lang/String;\)Z\n.*?^\.end method[ \t]*$", source)
    if m:
        block = m.group(0)
        if "com.zing.zalo" in block or ":fsi_a17_allowed_3_stock" in block:
            c_match = re.search(r"(?m)^[ \t]*(?::cond_[0-9a-f]+|:goto_[0-9a-f]+|:fsi_a17_allowed_3_stock)\s*\n[ \t]*invoke-static \{p1\}, Landroid/os/UserHandle;->getAppId", block)
            if c_match:
                hdr_end = find_header_end(block)
                block = block[:hdr_end] + "\n\n    " + block[c_match.start():].lstrip()
                source = source[:m.start()] + block + source[m.end():]

    return source


def clean_injected_ams_compat_hooks(source: str) -> str:
    """Restores ActivityManagerServiceImpl checkRunningCompatibility to clean stock code."""
    m = re.search(r"(?ms)^\.method[^\n]*\bcheckRunningCompatibility\(Landroid/app/IApplicationThread;Landroid/content/pm/ActivityInfo;Landroid/content/Intent;ILjava/lang/String;\)Z\n.*?^\.end method[ \t]*$", source)
    if m:
        block = m.group(0)
        if "com.zing.zalo" in block or ":fsi_a17_ams_compat_stock" in block:
            c_match = re.search(r"(?m)^[ \t]*(?::cond_[0-9a-f]+|:goto_[0-9a-f]+|:fsi_a17_ams_compat_stock)\s*\n[ \t]*const/4 v0, 0x1\s*\n\s*if-nez p2,", block)
            if c_match:
                hdr_end = find_header_end(block)
                block = block[:hdr_end] + "\n\n    " + block[c_match.start():].lstrip()
                source = source[:m.start()] + block + source[m.end():]
    return source


def patch_fsi(source: str) -> str:
    """Ensures NotificationManagerServiceImpl.checkFullScreenIntent uses clean Global check."""
    method_re = re.compile(
        r"(?ms)^\.method[^\n]*\bcheckFullScreenIntent\([^\n]*\n.*?^\.end method[ \t]*$"
    )
    m = method_re.search(source)
    if not m:
        return source
    block = m.group(0)
    hdr_end = find_header_end(block)
    target_m = re.search(
        r"sget-boolean\s+([vp]\d+),\s+Lmiui/os/(?:x)?Build;->IS_INTERNATIONAL_BUILD:Z\s+if-nez\s+\1,\s+:(\w+)",
        block
    )
    if target_m and target_m.start() > hdr_end:
        block = block[:hdr_end] + "\n\n    " + block[target_m.start():]
    elif "com.zing.zalo" in block or ":fsi_call_stock" in block:
        ib_match = re.search(r"sget-boolean\s+[vp]\d+,\s+Lmiui/os/(?:x)?Build;->IS_INTERNATIONAL_BUILD:Z", block)
        if ib_match and ib_match.start() > hdr_end:
            block = block[:hdr_end] + "\n\n    " + block[ib_match.start():]

    # Redirect stock Build to xBuild
    block = re.sub(
        r"Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z",
        "Lmiui/os/xBuild;->IS_INTERNATIONAL_BUILD:Z",
        block
    )
    return source[:m.start()] + block + source[m.end():]


def patch(root: Path):
    if not root.is_dir():
        raise ValueError(f"Missing decompiled miui-services: {root}")
    details = {}
    modified = False

    # 1. Region Gates: allow C2DM autostart and international running compatibility
    for relative, signature in REGION_GATES:
        file = locate(root, relative)
        if file is None:
            raise ValueError(f"{relative}: missing")
        original = file.read_text(encoding="utf-8")
        changed = patch_region_gate(original, signature)
        if changed != original:
            file.write_text(changed, encoding="utf-8")
            modified = True
        details[signature] = "patched" if changed != original else "already patched"

    # 2. Full Screen Intent (FSI): pure Global branch
    # When IS_INTERNATIONAL_BUILD is true, checkFullScreenIntent returns without AppOps check.
    fsi_file = locate(root, FSI_CLASS)
    if fsi_file is not None:
        orig_fsi = fsi_file.read_text(encoding="utf-8")
        patched_fsi = patch_fsi(orig_fsi)
        if patched_fsi != orig_fsi:
            fsi_file.write_text(patched_fsi, encoding="utf-8")
            modified = True
        details["full_screen_intent"] = "pure_global_xbuild"

    # 3. ProcessManagerService: EU/scoped-268 force-stop policy
    # AutoIdleKill (13) preserves stock force-stop behavior; other policies use Global semantics.
    process_manager = locate(root, PROCESS_MANAGER)
    if process_manager is None:
        raise ValueError(f"{PROCESS_MANAGER}: missing")
    original_pm = process_manager.read_text(encoding="utf-8")
    patched_pm, pm_info = patch_force_stop(original_pm)
    if patched_pm != original_pm:
        process_manager.write_text(patched_pm, encoding="utf-8")
        modified = True
    details[PROCESS_MANAGER] = pm_info

    # 4. Clean BroadcastQueueModernStubImpl: remove custom fcm_c2dm_thaw hooks
    bq_stub = locate(root, BQ_STUB)
    if bq_stub is not None:
        orig_bq = bq_stub.read_text(encoding="utf-8")
        cleaned_bq = clean_injected_c2dm_hooks(orig_bq)
        if cleaned_bq != orig_bq:
            bq_stub.write_text(cleaned_bq, encoding="utf-8")
            modified = True
        details[BQ_STUB] = {"clean_modern_queue": True}

    # 5. Clean ActivityStarterImpl & AMS: remove custom BAL preambles
    activity_starter = locate(root, ACTIVITY_STARTER)
    if activity_starter is not None:
        orig_starter = activity_starter.read_text(encoding="utf-8")
        cleaned_starter = clean_injected_activity_starter_hooks(orig_starter)
        if cleaned_starter != orig_starter:
            activity_starter.write_text(cleaned_starter, encoding="utf-8")
            modified = True
        details[ACTIVITY_STARTER] = {"clean_activity_starter": True}

    ams_impl = locate(root, AMS_IMPL)
    if ams_impl is not None:
        orig_ams = ams_impl.read_text(encoding="utf-8")
        cleaned_ams = clean_injected_ams_compat_hooks(orig_ams)
        if cleaned_ams != orig_ams:
            ams_impl.write_text(cleaned_ams, encoding="utf-8")
            modified = True
        details[AMS_IMPL] = {"clean_ams_compat": True}

    # 6. PolicyManagerConfig: force isCnModel()Z to return false (0)
    # Activates native InternationalPolicyManager in Greeze/Aurogon.
    policy_config = locate(root, POLICY_CONFIG)
    if policy_config is not None:
        original_pc = policy_config.read_text(encoding="utf-8")
        pc_text = replace_boolean_method(original_pc, "isCnModel()Z", 0)
        if "sput-boolean v0, Lcom/miui/server/greeze/PolicyManagerConfig;->sCnModel:Z" not in pc_text or "const/4 v0, 0x0" not in pc_text:
            pc_text = re.sub(
                r"(?m)^([ \t]*sput-boolean[ \t]+[vp]\d+,[ \t]+Lcom/miui/server/greeze/PolicyManagerConfig;->sCnModel:Z[ \t]*)$",
                r"    const/4 v0, 0x0\n    sput-boolean v0, Lcom/miui/server/greeze/PolicyManagerConfig;->sCnModel:Z",
                pc_text
            )
        if pc_text != original_pc:
            policy_config.write_text(pc_text, encoding="utf-8")
            modified = True
        details[POLICY_CONFIG] = {"is_cn_model_forced_false": True}

    # 7. Extend xBuild redirection across all critical security, autostart & launch classes
    for smali_target in (
        WAKEPATH_CHECKER,
        SECURITY_MANAGER,
        SECURITY_LOCAL_SERVICE,
        ACTIVITY_STARTER,
        AMS_IMPL,
        PROCESS_MANAGER,
        BQ_STUB,
        FSI_CLASS,
    ):
        target_file = locate(root, smali_target)
        if target_file is not None:
            orig_text = target_file.read_text(encoding="utf-8")
            rewritten = re.sub(
                r"Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z",
                "Lmiui/os/xBuild;->IS_INTERNATIONAL_BUILD:Z",
                orig_text
            )
            if rewritten != orig_text:
                target_file.write_text(rewritten, encoding="utf-8")
                modified = True
            details[smali_target] = {"xbuild_redirected": True}

    # 8. GreezeManagerService: disable outgoing GMS limits
    greeze_service = locate(root, GREEZE_SERVICE)
    if greeze_service is not None:
        original_greeze = greeze_service.read_text(encoding="utf-8")
        service_text = replace_void_method(original_greeze, "triggerGMSLimitAction()V")
        service_text = disable_gms_app_check(service_text)
        if service_text != original_greeze:
            greeze_service.write_text(service_text, encoding="utf-8")
            modified = True
        details[GREEZE_SERVICE] = {
            "gms_limit_action_disabled": True,
            "gms_special_freeze_path_disabled": True,
        }

    # 9. AurogonFilterManager: protect GMS from quick freeze
    aurogon = locate(root, AUROGON_FILTER)
    if aurogon is not None:
        original_aurogon = aurogon.read_text(encoding="utf-8")
        aurogon_text = inject_method_preamble(
            original_aurogon,
            "filter(ILjava/lang/String;I)Z",
            '    const-string v0, "com.google.android.gms"\n\n'
            '    invoke-virtual {v0, p2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n\n'
            '    move-result v0\n\n'
            '    if-eqz v0, :fcm_a17_aurogon_stock\n\n'
            '    const/16 v0, 0x40\n\n'
            '    iput v0, p0, Lcom/miui/server/greeze/AurogonFilterManager;->mContinueReason:I\n\n'
            '    const/4 v0, 0x0\n\n'
            '    return v0\n\n'
            '    :fcm_a17_aurogon_stock',
            ":fcm_a17_aurogon_stock"
        )
        if aurogon_text != original_aurogon:
            aurogon.write_text(aurogon_text, encoding="utf-8")
            modified = True
        details[AUROGON_FILTER] = {"gms_quick_freeze_shield": True}

    # 10. Alarm throttling: exempt GMS heartbeat alarms from SSRU throttling & alignment
    alarm_stub = locate(root, ALARM_STUB)
    if alarm_stub is not None:
        original_alarm = alarm_stub.read_text(encoding="utf-8")
        alarm_hook = (
            '    if-eqz p1, :fcm_a17_alarm_stock\n\n'
            '    move-object/from16 v0, p1\n\n'
            '    iget-object v0, v0, Lcom/android/server/alarm/Alarm;->sourcePackage:Ljava/lang/String;\n\n'
            '    if-eqz v0, :fcm_a17_alarm_stock\n\n'
            '    const-string v1, "com.google.android.gms"\n\n'
            '    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n\n'
            '    move-result v0\n\n'
            '    if-eqz v0, :fcm_a17_alarm_stock\n\n'
            '    move-object/from16 v0, p1\n\n'
            '    iget-object v0, v0, Lcom/android/server/alarm/Alarm;->statsTag:Ljava/lang/String;\n\n'
            '    if-eqz v0, :fcm_a17_alarm_stock\n\n'
            '    const-string v1, "GCM"\n\n'
            '    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z\n\n'
            '    move-result v0\n\n'
            '    if-nez v0, :cond_fcm_alarm_exempt\n\n'
            '    move-object/from16 v0, p1\n\n'
            '    iget-object v0, v0, Lcom/android/server/alarm/Alarm;->statsTag:Ljava/lang/String;\n\n'
            '    const-string v1, "fcm"\n\n'
            '    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z\n\n'
            '    move-result v0\n\n'
            '    if-nez v0, :cond_fcm_alarm_exempt\n\n'
            '    move-object/from16 v0, p1\n\n'
            '    iget-object v0, v0, Lcom/android/server/alarm/Alarm;->statsTag:Ljava/lang/String;\n\n'
            '    const-string v1, "FCM"\n\n'
            '    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z\n\n'
            '    move-result v0\n\n'
            '    if-nez v0, :cond_fcm_alarm_exempt\n\n'
            '    move-object/from16 v0, p1\n\n'
            '    iget-object v0, v0, Lcom/android/server/alarm/Alarm;->statsTag:Ljava/lang/String;\n\n'
            '    const-string v1, "chimera"\n\n'
            '    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z\n\n'
            '    move-result v0\n\n'
            '    if-eqz v0, :fcm_a17_alarm_stock\n\n'
            '    :cond_fcm_alarm_exempt\n\n'
            '    const/4 v0, 0x1\n\n'
            '    return v0\n\n'
            '    :fcm_a17_alarm_stock'
        )
        alarm_text = inject_method_preamble(
            original_alarm,
            "canAffordBillLocked(Lcom/android/server/alarm/Alarm;Lcom/android/server/ssru/ResourceBudgetManagerInternal$OperateAccount;)Z",
            alarm_hook,
            ":fcm_a17_alarm_stock"
        )
        align_hook = (
            '    if-eqz p1, :fcm_a17_align_stock\n\n'
            '    move-object/from16 v0, p1\n\n'
            '    iget-object v0, v0, Lcom/android/server/alarm/Alarm;->sourcePackage:Ljava/lang/String;\n\n'
            '    if-eqz v0, :fcm_a17_align_stock\n\n'
            '    const-string v1, "com.google.android.gms"\n\n'
            '    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n\n'
            '    move-result v0\n\n'
            '    if-eqz v0, :fcm_a17_align_stock\n\n'
            '    move-object/from16 v0, p1\n\n'
            '    iget-object v0, v0, Lcom/android/server/alarm/Alarm;->statsTag:Ljava/lang/String;\n\n'
            '    if-eqz v0, :fcm_a17_align_stock\n\n'
            '    const-string v1, "GCM"\n\n'
            '    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z\n\n'
            '    move-result v0\n\n'
            '    if-nez v0, :cond_fcm_align_exempt\n\n'
            '    move-object/from16 v0, p1\n\n'
            '    iget-object v0, v0, Lcom/android/server/alarm/Alarm;->statsTag:Ljava/lang/String;\n\n'
            '    const-string v1, "fcm"\n\n'
            '    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z\n\n'
            '    move-result v0\n\n'
            '    if-nez v0, :cond_fcm_align_exempt\n\n'
            '    move-object/from16 v0, p1\n\n'
            '    iget-object v0, v0, Lcom/android/server/alarm/Alarm;->statsTag:Ljava/lang/String;\n\n'
            '    const-string v1, "FCM"\n\n'
            '    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z\n\n'
            '    move-result v0\n\n'
            '    if-nez v0, :cond_fcm_align_exempt\n\n'
            '    move-object/from16 v0, p1\n\n'
            '    iget-object v0, v0, Lcom/android/server/alarm/Alarm;->statsTag:Ljava/lang/String;\n\n'
            '    const-string v1, "chimera"\n\n'
            '    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z\n\n'
            '    move-result v0\n\n'
            '    if-eqz v0, :fcm_a17_align_stock\n\n'
            '    :cond_fcm_align_exempt\n\n'
            '    const/4 v0, 0x0\n\n'
            '    return v0\n\n'
            '    :fcm_a17_align_stock'
        )
        alarm_text = inject_method_preamble(
            alarm_text,
            "alignAlarmLocked(Lcom/android/server/alarm/Alarm;)Z",
            align_hook,
            ":fcm_a17_align_stock"
        )
        adjust_hook = (
            '    if-eqz p1, :fcm_a17_adjust_stock\n\n'
            '    move-object/from16 v0, p1\n\n'
            '    iget-object v0, v0, Lcom/android/server/alarm/Alarm;->sourcePackage:Ljava/lang/String;\n\n'
            '    if-eqz v0, :fcm_a17_adjust_stock\n\n'
            '    const-string v1, "com.google.android.gms"\n\n'
            '    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n\n'
            '    move-result v0\n\n'
            '    if-eqz v0, :fcm_a17_adjust_stock\n\n'
            '    move-object/from16 v0, p1\n\n'
            '    iget-object v0, v0, Lcom/android/server/alarm/Alarm;->statsTag:Ljava/lang/String;\n\n'
            '    if-eqz v0, :fcm_a17_adjust_stock\n\n'
            '    const-string v1, "GCM"\n\n'
            '    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z\n\n'
            '    move-result v0\n\n'
            '    if-nez v0, :cond_fcm_adjust_exempt\n\n'
            '    move-object/from16 v0, p1\n\n'
            '    iget-object v0, v0, Lcom/android/server/alarm/Alarm;->statsTag:Ljava/lang/String;\n\n'
            '    const-string v1, "fcm"\n\n'
            '    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z\n\n'
            '    move-result v0\n\n'
            '    if-nez v0, :cond_fcm_adjust_exempt\n\n'
            '    move-object/from16 v0, p1\n\n'
            '    iget-object v0, v0, Lcom/android/server/alarm/Alarm;->statsTag:Ljava/lang/String;\n\n'
            '    const-string v1, "FCM"\n\n'
            '    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z\n\n'
            '    move-result v0\n\n'
            '    if-nez v0, :cond_fcm_adjust_exempt\n\n'
            '    move-object/from16 v0, p1\n\n'
            '    iget-object v0, v0, Lcom/android/server/alarm/Alarm;->statsTag:Ljava/lang/String;\n\n'
            '    const-string v1, "chimera"\n\n'
            '    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z\n\n'
            '    move-result v0\n\n'
            '    if-eqz v0, :fcm_a17_adjust_stock\n\n'
            '    :cond_fcm_adjust_exempt\n\n'
            '    const/4 v0, 0x0\n\n'
            '    return v0\n\n'
            '    :fcm_a17_adjust_stock'
        )
        alarm_text = inject_method_preamble(
            alarm_text,
            "adjustAlarmLocked(Lcom/android/server/alarm/Alarm;)Z",
            adjust_hook,
            ":fcm_a17_adjust_stock"
        )
        if alarm_text != original_alarm:
            alarm_stub.write_text(alarm_text, encoding="utf-8")
            modified = True
        details[ALARM_STUB] = {
            "gms_alarm_budget_shield": True,
            "gms_alarm_align_exempt": True,
            "gms_alarm_adjust_exempt": True,
        }

    # 11. PowerManagerServiceImpl: protect GMS wakelocks
    power_impl = locate(root, POWER_IMPL)
    if power_impl is not None:
        original_power = power_impl.read_text(encoding="utf-8")
        wl_hook = (
            '    if-eqz p1, :fcm_a17_wl_stock\n\n'
            '    move-object/from16 v0, p1\n\n'
            '    iget-object v0, v0, Lcom/android/server/power/PowerManagerService$WakeLock;->mPackageName:Ljava/lang/String;\n\n'
            '    if-eqz v0, :fcm_a17_wl_stock\n\n'
            '    const-string v1, "com.google.android.gms"\n\n'
            '    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n\n'
            '    move-result v1\n\n'
            '    if-nez v1, :fcm_a17_wl_stock\n\n'
            '    move-object/from16 v0, p1\n\n'
            '    iget-object v0, v0, Lcom/android/server/power/PowerManagerService$WakeLock;->mTag:Ljava/lang/String;\n\n'
            '    if-eqz v0, :fcm_a17_wl_stock\n\n'
            '    const-string v1, "C2DM"\n\n'
            '    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z\n\n'
            '    move-result v0\n\n'
            '    if-nez v0, :cond_fcm_wl_exempt\n\n'
            '    move-object/from16 v0, p1\n\n'
            '    iget-object v0, v0, Lcom/android/server/power/PowerManagerService$WakeLock;->mTag:Ljava/lang/String;\n\n'
            '    const-string v1, "GCM"\n\n'
            '    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z\n\n'
            '    move-result v0\n\n'
            '    if-nez v0, :cond_fcm_wl_exempt\n\n'
            '    move-object/from16 v0, p1\n\n'
            '    iget-object v0, v0, Lcom/android/server/power/PowerManagerService$WakeLock;->mTag:Ljava/lang/String;\n\n'
            '    const-string v1, "gcm"\n\n'
            '    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z\n\n'
            '    move-result v0\n\n'
            '    if-nez v0, :cond_fcm_wl_exempt\n\n'
            '    move-object/from16 v0, p1\n\n'
            '    iget-object v0, v0, Lcom/android/server/power/PowerManagerService$WakeLock;->mTag:Ljava/lang/String;\n\n'
            '    const-string v1, "FCM"\n\n'
            '    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z\n\n'
            '    move-result v0\n\n'
            '    if-nez v0, :cond_fcm_wl_exempt\n\n'
            '    move-object/from16 v0, p1\n\n'
            '    iget-object v0, v0, Lcom/android/server/power/PowerManagerService$WakeLock;->mTag:Ljava/lang/String;\n\n'
            '    const-string v1, "fcm"\n\n'
            '    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z\n\n'
            '    move-result v0\n\n'
            '    if-eqz v0, :fcm_a17_wl_stock\n\n'
            '    :cond_fcm_wl_exempt\n\n'
            '    const/4 v0, 0x0\n\n'
            '    return v0\n\n'
            '    :fcm_a17_wl_stock'
        )
        power_text = inject_method_preamble(
            original_power,
            "isWakelockDisabledByPolicy(Lcom/android/server/power/PowerManagerService$WakeLock;)Z",
            wl_hook,
            ":fcm_a17_wl_stock",
            min_locals=2
        )
        if power_text != original_power:
            power_impl.write_text(power_text, encoding="utf-8")
            modified = True
        details[POWER_IMPL] = {"c2dm_wakelock_shield": True}

    # 12. MiuiNetworkPolicyManagerService: disable sleep mode chain
    net_policy = locate(root, NETWORK_POLICY)
    if net_policy is not None:
        original_net = net_policy.read_text(encoding="utf-8")
        net_text = replace_boolean_method(original_net, "sleepModeEnableControl()Z", 0)
        sleep_chain_hook = (
            '    if-eqz p1, :fcm_a17_sleep_disable\n\n'
            '    return-void\n\n'
            '    :fcm_a17_sleep_disable'
        )
        net_text = inject_method_preamble(
            net_text,
            "enableSleepModeChain(Z)V",
            sleep_chain_hook,
            ":fcm_a17_sleep_disable",
            min_locals=0
        )
        if net_text != original_net:
            net_policy.write_text(net_text, encoding="utf-8")
            modified = True
        details[NETWORK_POLICY] = {"sleep_mode_chain_disabled": True}

    return {
        "status": "success",
        "changed": modified,
        "target_jar": "miui-services.jar",
        "classes": details,
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("decoded_miui_services", type=Path)
    parser.add_argument("--report", required=True, type=Path)
    args = parser.parse_args()
    report = patch(args.decoded_miui_services)
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("[FRAMEWORKPATCHER A17] " + json.dumps(report))


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        raise SystemExit("[FRAMEWORKPATCHER A17] FAIL: " + str(exc))
