#!/usr/bin/env python3
"""Port the XNotifyFix HyperOS China hooks to Android 17 miui-services.jar."""
import argparse
import json
import re
from pathlib import Path

from smali_a17 import FSI_PACKAGES, edit_method

PROCESS_MANAGER = "com/android/server/am/ProcessManagerService.smali"
GREEZE_SERVICE = "com/miui/server/greeze/GreezeManagerService.smali"
POLICY_MAKER = "com/miui/server/greeze/power/PolicyMaker.smali"
AUROGON_FILTER = "com/miui/server/greeze/AurogonFilterManager.smali"
DOMESTIC_POLICY = "com/miui/server/greeze/DomesticPolicyManager.smali"
ALARM_STUB = "com/android/server/alarm/AlarmManagerServiceStubImpl.smali"
POWER_IMPL = "com/android/server/power/PowerManagerServiceImpl.smali"
NETWORK_POLICY = "com/android/server/net/MiuiNetworkPolicyManagerService.smali"
BQ_STUB = "com/android/server/am/BroadcastQueueModernStubImpl.smali"
ACTIVITY_STARTER = "com/android/server/wm/ActivityStarterImpl.smali"
AMS_IMPL = "com/android/server/am/ActivityManagerServiceImpl.smali"

REGION_GATES = (
    ("com/android/server/am/BroadcastQueueModernStubImpl.smali",
     "checkApplicationAutoStart(Lcom/android/server/am/BroadcastQueue;Lcom/android/server/am/BroadcastRecord;Landroid/content/pm/ResolveInfo;)Z"),
    ("com/android/server/am/ActivityManagerServiceImpl.smali",
     "checkRunningCompatibility(Landroid/content/ComponentName;III)Z"),
    ("com/android/server/alarm/AlarmManagerServiceStubImpl.smali",
     "init(Lcom/android/server/alarm/AlarmManagerService;)V"),
)
FSI_CLASS = "com/android/server/notification/NotificationManagerServiceImpl.smali"
FSI_METHOD = "checkFullScreenIntent(Landroid/app/Notification;Landroid/app/AppOpsManager;ILjava/lang/String;)V"

# Match #268's scoped keep-notification policy: AutoIdleKill (13) keeps its
# original force-stop behavior; the other cleanup policies use Global semantics.
AUTO_IDLE_POLICY = re.compile(r"(?m)^[ \t]*const/16[ \t]+([vp]\d+),[ \t]+0xd[ \t]*$")
FORCE_STOP_METHOD = re.compile(
    r"(?ms)^\.method[^\n]*\bisForceStopEnable\(Lcom/android/server/am/ProcessRecord;I\)Z[^\n]*\n"
    r".*?^\.end method[ \t]*$"
)

REGION_READ = re.compile(
    r"(?m)^([ \t]*)sget-boolean[ \t]+([vp]\d+),[ \t]+"
    # CorePatch A17 redirects stock Build reads to xBuild before this pass.
    r"Lmiui/os/(?:x)?Build;->IS_INTERNATIONAL_BUILD:Z([ \t]*.*)$"
)

def locate(root: Path, relative: str):
    matches = [p for p in root.glob("smali*/" + relative) if p.is_file()]
    if not matches:
        # Also check direct relative path
        direct = root / relative
        if direct.is_file():
            return direct
    if len(matches) > 1:
        raise ValueError(f"Duplicate smali class: {relative}")
    return matches[0] if matches else None


def patch_region_gate(source, signature, fsi_packages=()):

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
        if signature == FSI_METHOD:
            if not fsi_packages:
                return block
            # The A17 gate uses v0. v1 is a local overwritten by the stock path.
            if register != "v0" or "    .registers 12" not in block:
                raise ValueError("checkFullScreenIntent: unsupported register layout")
            if ":a17_fsi_allowed" in block or all(
                re.search(
                    rf'const-string(?:/jumbo)? v1, "{re.escape(package)}"\s+'
                    r'invoke-virtual \{v1, p4\}, Ljava/lang/String;->equals',
                    block,
                )
                for package in fsi_packages
            ):
                return block
            checks = []
            for package in fsi_packages:
                checks.extend((
                    f'    const-string v1, "{package}"',
                    "    invoke-virtual {v1, p4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z",
                    "    move-result v0",
                    "    if-nez v0, :a17_fsi_allowed",
                ))
            checks.extend((gate.group(), "    :a17_fsi_allowed"))
            replacement = "\n\n".join(checks)
        elif signature.startswith("checkRunningCompatibility("):
            # XNotifyFix returns false for a null ComponentName in Allow All.
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
    """Preserve #268's AutoIdleKill (policy 13) exception.

    On the verified OS4/A17 China ROM, forcing the international region read
    inside isForceStopEnable() makes normal recents cleanup kill the process
    without force-stopping it. The stock policy-13 branch still returns true,
    allowing Xiaomi's AutoIdleKill to force-stop an idle app as in #268.
    No global KEEP_NOTIF=ALL preamble is injected.
    """
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
        # A second application to a compiled JAR loses Smali comments. If no
        # region read remains, the patcher cannot prove #268's exact behavior.
        # Refuse to silently accept an unknown method body as equivalent.
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
        # In a two-register instance method, v0 and p0 are aliases. Baksmali
        # emits p0 on a second pass even if the original stub used v0.
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


def count_param_registers(signature: str, is_static: bool = False) -> int:
    """Calculate the number of Dalvik registers occupied by method parameters."""
    params_match = re.search(r"\((.*?)\)", signature)
    if not params_match:
        return 0
    param_str = params_match.group(1)
    count = 0 if is_static else 1  # p0 is this for instance methods
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


def find_header_end(block: str) -> int:
    """Find the exact end position of all method header directives.

    Handles .registers, .locals, .param, .end param, nested .annotation ... .end annotation,
    .prologue, and .line, ensuring preamble is inserted right before the first executable instruction.
    """
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


def inject_method_preamble(source: str, signature: str, preamble: str, label: str, min_locals: int = 2):
    method_re = re.compile(
        rf"(?ms)^\.method[^\n]*\b{re.escape(signature)}[^\n]*\n.*?^\.end method[ \t]*$"
    )
    methods = list(method_re.finditer(source))
    if len(methods) != 1:
        raise ValueError(f"expected one {signature}, got {len(methods)}")
    block = methods[0].group()

    # Match already-patched instruction sequence (supports both raw Smali and baksmali-decompiled DEX)
    clean_lines = [l.strip() for l in preamble.splitlines() if l.strip() and not l.strip().startswith("#")]
    body_lines = clean_lines[:-1] if clean_lines and clean_lines[-1].startswith(":") else clean_lines
    escaped = [re.escape(l) for l in body_lines]
    pattern_str = r"\s+".join(escaped)
    pattern_str = re.sub(r":fcm_a17_\w+", lambda _: r":\w+", pattern_str)
    if re.search(pattern_str, block):
        return source

    # Fail-safe: if label exists but instruction sequence differs, do not guess with regex
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
    else:  # registers
        num_locals = val - param_count
        if num_locals < min_locals:
            raise ValueError(f"{signature}: insufficient local registers (locals={num_locals}, required={min_locals})")

    # Locate insertion point after all header directives (.registers, .locals, .param, .end param, .annotation, .prologue, .line)
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


def patch(root: Path):
    if not root.is_dir():
        raise ValueError(f"Missing decompiled miui-services: {root}")
    details = {}
    modified = False
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

    fsi = locate(root, FSI_CLASS)
    if fsi is None:
        raise ValueError(f"{FSI_CLASS}: missing")
    original = fsi.read_text(encoding="utf-8")
    changed = patch_region_gate(original, FSI_METHOD, FSI_PACKAGES)
    if changed != original:
        fsi.write_text(changed, encoding="utf-8")
        modified = True
    details[FSI_METHOD] = "patched" if changed != original else "already patched"
    details["full_screen_packages"] = FSI_PACKAGES

    process_manager = locate(root, PROCESS_MANAGER)
    if process_manager is None:
        raise ValueError(f"{PROCESS_MANAGER}: missing")
    original_pm = process_manager.read_text(encoding="utf-8")
    patched_pm, pm_info = patch_force_stop(original_pm)
    if patched_pm != original_pm:
        process_manager.write_text(patched_pm, encoding="utf-8")
        modified = True
    details[PROCESS_MANAGER] = pm_info

    # Exempt C2DM/FCM from Security_WakePath calleeAliveMatchBlackRule (warm process)
    # and Greezer Denial (need cached broadcast) in BroadcastQueueModernStubImpl.
    # When C2DM broadcast arrives for a warm process, actively thaw its UID via
    # GreezeManagerInternal so Modern BroadcastQueue does not timeout with ANR warning.
    bq_stub = locate(root, BQ_STUB)
    if bq_stub is not None:
        original_bq = bq_stub.read_text(encoding="utf-8")
        deal_hook = (
            '    if-eqz p2, :fcm_a17_deal_stock\n\n'
            '    move-object/from16 v0, p2\n\n'
            '    iget-object v0, v0, Lcom/android/server/am/BroadcastRecord;->intent:Landroid/content/Intent;\n\n'
            '    if-eqz v0, :fcm_a17_deal_stock\n\n'
            '    invoke-virtual {v0}, Landroid/content/Intent;->getAction()Ljava/lang/String;\n\n'
            '    move-result-object v0\n\n'
            '    if-eqz v0, :fcm_a17_deal_stock\n\n'
            '    const-string v1, "com.google.android.c2dm.intent.RECEIVE"\n\n'
            '    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n\n'
            '    move-result v0\n\n'
            '    if-eqz v0, :fcm_a17_deal_stock\n\n'
            '    if-eqz p3, :cond_c2dm_deal_allow\n\n'
            '    invoke-static {}, Lcom/miui/server/greeze/GreezeManagerInternal;->getInstance()Lcom/miui/server/greeze/GreezeManagerInternal;\n\n'
            '    move-result-object v0\n\n'
            '    if-eqz v0, :cond_c2dm_deal_allow\n\n'
            '    move-object/from16 v1, p3\n\n'
            '    iget v1, v1, Lcom/android/server/am/ProcessRecord;->uid:I\n\n'
            '    const/16 v2, 0x3e8\n\n'
            '    const-string v3, "fcm_c2dm_thaw"\n\n'
            '    invoke-virtual {v0, v1, v2, v3}, Lcom/miui/server/greeze/GreezeManagerInternal;->thawUid(IILjava/lang/String;)Z\n\n'
            '    :cond_c2dm_deal_allow\n\n'
            '    const/4 v0, 0x1\n\n'
            '    return v0\n\n'
            '    :fcm_a17_deal_stock'
        )
        restr_hook = (
            '    if-eqz p2, :fcm_a17_restr_stock\n\n'
            '    move-object/from16 v0, p2\n\n'
            '    iget-object v0, v0, Lcom/android/server/am/BroadcastRecord;->intent:Landroid/content/Intent;\n\n'
            '    if-eqz v0, :fcm_a17_restr_stock\n\n'
            '    invoke-virtual {v0}, Landroid/content/Intent;->getAction()Ljava/lang/String;\n\n'
            '    move-result-object v0\n\n'
            '    if-eqz v0, :fcm_a17_restr_stock\n\n'
            '    const-string v1, "com.google.android.c2dm.intent.RECEIVE"\n\n'
            '    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n\n'
            '    move-result v0\n\n'
            '    if-eqz v0, :fcm_a17_restr_stock\n\n'
            '    const/4 v0, 0x0\n\n'
            '    return v0\n\n'
            '    :fcm_a17_restr_stock'
        )
        bq_text = inject_method_preamble(
            original_bq,
            "checkReceiverAppDealBroadcast(Lcom/android/server/am/BroadcastQueue;Lcom/android/server/am/BroadcastRecord;Lcom/android/server/am/ProcessRecord;Z)Z",
            deal_hook,
            ":fcm_a17_deal_stock",
            min_locals=4,
        )
        bq_text = inject_method_preamble(
            bq_text,
            "checkReceiverIfRestricted(Lcom/android/server/am/BroadcastQueue;Lcom/android/server/am/BroadcastRecord;Lcom/android/server/am/ProcessRecord;Z)Z",
            restr_hook,
            ":fcm_a17_restr_stock",
            min_locals=2,
        )
        if bq_text != original_bq:
            bq_stub.write_text(bq_text, encoding="utf-8")
            modified = True
        details[BQ_STUB] = {
            "c2dm_app_deal_broadcast_exempt": True,
            "c2dm_app_deal_broadcast_thaw": True,
            "c2dm_receiver_restricted_exempt": True,
        }

    # Port the verified fcm_notification_fix vectors to OS4/A17 without its
    # runtime module. When C2DM broadcast arrives for an app, thaw its UID
    # asynchronously using MIUI standard caller convention 1000 (0x3e8) and
    # post tryDelayFreeze (2000ms) to ensure process receives and processes FCM.
    greeze_service = locate(root, GREEZE_SERVICE)
    if greeze_service is None:
        raise ValueError("GreezeManagerService missing")
    original_greeze = greeze_service.read_text(encoding="utf-8")
    service_text = inject_method_preamble(
        original_greeze,
        "isAllowBroadcast(ILjava/lang/String;ILjava/lang/String;Ljava/lang/String;)Z",
        '    const-string v0, "com.google.android.c2dm.intent.RECEIVE"\n\n'
        '    invoke-virtual {v0, p5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n\n'
        '    move-result v0\n\n'
        '    if-eqz v0, :fcm_a17_greeze_stock\n\n'
        '    const/16 v0, 0x3e8\n\n'
        '    const-string v1, "fcm_c2dm_thaw"\n\n'
        '    invoke-virtual {p0, p3, v0, v1}, Lcom/miui/server/greeze/GreezeManagerService;->thawUidAsync(IILjava/lang/String;)V\n\n'
        '    const/4 v0, 0x1\n\n'
        '    return v0\n\n'
        '    :fcm_a17_greeze_stock',
        ":fcm_a17_greeze_stock",
        min_locals=2)
    # On OS4, PowerKeeper's updateGmsNetStatus calls this same limiter.
    # Keep its Binder status round-trip and disable the limiter at its source.
    service_text = replace_void_method(
        service_text, "triggerGMSLimitAction()V")
    service_text = disable_gms_app_check(service_text)
    if service_text != original_greeze:
        greeze_service.write_text(service_text, encoding="utf-8")
        modified = True
    details[GREEZE_SERVICE] = {
        "c2dm_screen_off_thaw": True,
        "gms_limit_action_disabled": True,
        "gms_special_freeze_path_disabled": True,
    }

    # Exempt FSI messaging apps from Greezer PolicyMaker freeze.
    # In stock China ROM, PolicyMaker freezes third-party apps on screen-off
    # and background transition (tobg/screen_off), making them completely unable
    # to receive real-time FCM VoIP calls or run broadcast receivers.
    policy_maker = locate(root, POLICY_MAKER)
    if policy_maker is not None:
        original_pm = policy_maker.read_text(encoding="utf-8")
        freeze_hook_lines = [
            '    if-eqz p2, :cond_check_freeze_stock\n\n'
        ]
        for pkg in FSI_PACKAGES:
            freeze_hook_lines.append(
                f'    const-string v0, "{pkg}"\n\n'
                f'    invoke-virtual {{v0, p2}}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n\n'
                f'    move-result v0\n\n'
                f'    if-nez v0, :cond_check_freeze_exempt\n\n'
            )
        freeze_hook_lines.append(
            '    goto :cond_check_freeze_stock\n\n'
            '    :cond_check_freeze_exempt\n\n'
            '    const-string v0, "fcm_voip_exempt"\n\n'
            '    iput-object v0, p0, Lcom/miui/server/greeze/power/PolicyMaker;->mLastReason:Ljava/lang/String;\n\n'
            '    sget v0, Lcom/miui/server/greeze/power/PolicyMaker;->CANNOT_FREEZE:I\n\n'
            '    return v0\n\n'
            '    :cond_check_freeze_stock'
        )
        freeze_hook = "".join(freeze_hook_lines)
        pm_text = inject_method_preamble(
            original_pm,
            "checkCannotFreezePolicy(ILjava/lang/String;)I",
            freeze_hook,
            ":cond_check_freeze_stock",
            min_locals=2,
        )
        if pm_text != original_pm:
            policy_maker.write_text(pm_text, encoding="utf-8")
            modified = True
        details[POLICY_MAKER] = {"fcm_voip_freeze_exempt": True}

    # XNotifyFix-style Aurogon protection is scoped to GMS only.
    # Ordinary messenger apps may freeze when idle; they are awakened on
    # incoming C2DM by the GreezeManagerService.isAllowBroadcast hook and
    # FLAG_INCLUDE_STOPPED_PACKAGES in services.jar. Do not permanently exempt
    # apps such as Messenger here, to preserve stock idle battery behavior.
    aurogon = locate(root, AUROGON_FILTER)
    if aurogon is None:
        raise ValueError("AurogonFilterManager missing")
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
        ":fcm_a17_aurogon_stock")
    if aurogon_text != original_aurogon:
        aurogon.write_text(aurogon_text, encoding="utf-8")
        modified = True
    details[AUROGON_FILTER] = {"gms_quick_freeze_shield": True}

    # Video scenario / Immobulus mode: prevent deferring & caching FCM / GMS push broadcasts
    domestic = locate(root, DOMESTIC_POLICY)
    if domestic is not None:
        original_domestic = domestic.read_text(encoding="utf-8")
        defer_hook = (
            '    if-eqz p1, :fcm_a17_defer_stock\n\n'
            '    const-string v0, "com.google.android.c2dm.intent.RECEIVE"\n\n'
            '    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n\n'
            '    move-result v0\n\n'
            '    if-nez v0, :cond_fcm_defer_allow\n\n'
            '    const-string v0, "com.google.android.intent.action.GCM_RECONNECT"\n\n'
            '    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n\n'
            '    move-result v0\n\n'
            '    if-nez v0, :cond_fcm_defer_allow\n\n'
            '    goto :fcm_a17_defer_stock\n\n'
            '    :cond_fcm_defer_allow\n\n'
            '    const/4 v0, 0x0\n\n'
            '    return v0\n\n'
            '    :fcm_a17_defer_stock'
        )
        cache_hook = (
            '    if-eqz p1, :fcm_a17_cache_stock\n\n'
            '    const-string v0, "com.google.android.c2dm.intent.RECEIVE"\n\n'
            '    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n\n'
            '    move-result v0\n\n'
            '    if-nez v0, :cond_fcm_cache_allow\n\n'
            '    const-string v0, "com.google.android.intent.action.GCM_RECONNECT"\n\n'
            '    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n\n'
            '    move-result v0\n\n'
            '    if-nez v0, :cond_fcm_cache_allow\n\n'
            '    goto :fcm_a17_cache_stock\n\n'
            '    :cond_fcm_cache_allow\n\n'
            '    const/4 v0, 0x0\n\n'
            '    return v0\n\n'
            '    :fcm_a17_cache_stock'
        )
        domestic_text = inject_method_preamble(
            original_domestic,
            "deferBroadcast(Ljava/lang/String;)Z",
            defer_hook,
            ":fcm_a17_defer_stock",
            min_locals=1
        )
        domestic_text = inject_method_preamble(
            domestic_text,
            "needCacheBroadcast(Ljava/lang/String;II)Z",
            cache_hook,
            ":fcm_a17_cache_stock",
            min_locals=1
        )
        if domestic_text != original_domestic:
            domestic.write_text(domestic_text, encoding="utf-8")
            modified = True
        details[DOMESTIC_POLICY] = {"defer_fcm_broadcast_disabled": True, "cache_fcm_broadcast_disabled": True}

    # Alarm throttling: exempt only GMS heartbeat/push alarms from SSRU 120s budget denial (canAfford=false)
    # and exempt GMS heartbeat/push alarms from screen-off alarm alignment and adjustment.
    # canAffordBillLocked uses .registers 14 (locals: v0..v10, params: p0=this, p1=v12, p2=v13).
    # v0 and v1 are available locals.
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

    # Wakelock policy: prevent disabling GMS / C2DM wakelocks and FSI app FcmListenerService wakelocks with UidFrozen
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
            '    if-eqz v1, :cond_check_fsi_pkg\n\n'
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
            '    goto :cond_fcm_wl_exempt\n\n'
            '    :cond_check_fsi_pkg\n\n'
            '    const-string v1, "com.facebook.orca"\n\n'
            '    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n\n'
            '    move-result v1\n\n'
            '    if-eqz v1, :cond_check_fsi_zalo\n\n'
            '    goto :cond_check_fcm_tag\n\n'
            '    :cond_check_fsi_zalo\n\n'
            '    const-string v1, "com.zing.zalo"\n\n'
            '    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n\n'
            '    move-result v0\n\n'
            '    if-eqz v0, :fcm_a17_wl_stock\n\n'
            '    :cond_check_fcm_tag\n\n'
            '    move-object/from16 v0, p1\n\n'
            '    iget-object v0, v0, Lcom/android/server/power/PowerManagerService$WakeLock;->mTag:Ljava/lang/String;\n\n'
            '    if-eqz v0, :fcm_a17_wl_stock\n\n'
            '    const-string v1, "FcmListenerService"\n\n'
            '    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z\n\n'
            '    move-result v0\n\n'
            '    if-nez v0, :cond_fcm_wl_exempt\n\n'
            '    goto :fcm_a17_wl_stock\n\n'
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
        details[POWER_IMPL] = {"c2dm_wakelock_shield": True, "fcm_listener_wakelock_shield": True}

    # Sleep Mode network firewall: disable kernel/netd sleep mode chain blocking background data
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

    # Background Activity / FSI Start: Allow FSI packages (Messenger, Zalo) to launch
    # call activities / incoming call UI from background even when screen is locked/off
    activity_starter = locate(root, ACTIVITY_STARTER)
    if activity_starter is not None:
        original_starter = activity_starter.read_text(encoding="utf-8")
        starter_text = original_starter

        # 1. Hook checkStartActivityPermission(Lcom/android/server/wm/ActivityStarter$Request;)Z
        lines_check = [
            '    if-eqz p1, :fsi_a17_check_start_stock\n\n',
            '    move-object/from16 v0, p1\n\n',
            '    iget-object v0, v0, Lcom/android/server/wm/ActivityStarter$Request;->callingPackage:Ljava/lang/String;\n\n',
            '    if-eqz v0, :fsi_a17_check_start_stock\n\n',
        ]
        for pkg in FSI_PACKAGES:
            lines_check.extend([
                f'    const-string v1, "{pkg}"\n\n',
                '    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n\n',
                '    move-result v1\n\n',
                '    if-nez v1, :cond_fsi_check_start_exempt\n\n',
            ])
        lines_check.extend([
            '    goto :fsi_a17_check_start_stock\n\n',
            '    :cond_fsi_check_start_exempt\n\n',
            '    const/4 v0, 0x1\n\n',
            '    return v0\n\n',
            '    :fsi_a17_check_start_stock'
        ])
        starter_text = inject_method_preamble(
            starter_text,
            "checkStartActivityPermission(Lcom/android/server/wm/ActivityStarter$Request;)Z",
            "".join(lines_check),
            ":fsi_a17_check_start_stock",
            min_locals=2
        )

        # 2. Hook isAllowedStartActivity(IILjava/lang/String;)Z
        lines_allowed_3 = [
            '    if-eqz p3, :fsi_a17_allowed_3_stock\n\n',
        ]
        for pkg in FSI_PACKAGES:
            lines_allowed_3.extend([
                f'    const-string v0, "{pkg}"\n\n',
                '    invoke-virtual {v0, p3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n\n',
                '    move-result v0\n\n',
                '    if-nez v0, :cond_fsi_allowed_3_exempt\n\n',
            ])
        lines_allowed_3.extend([
            '    goto :fsi_a17_allowed_3_stock\n\n',
            '    :cond_fsi_allowed_3_exempt\n\n',
            '    const/4 v0, 0x1\n\n',
            '    return v0\n\n',
            '    :fsi_a17_allowed_3_stock'
        ])
        starter_text = inject_method_preamble(
            starter_text,
            "isAllowedStartActivity(IILjava/lang/String;)Z",
            "".join(lines_allowed_3),
            ":fsi_a17_allowed_3_stock",
            min_locals=1
        )

        # 3. Hook isAllowedStartActivity(Landroid/content/Intent;IILjava/lang/String;IILandroid/content/pm/ActivityInfo;Lcom/android/server/wm/BackgroundActivityStartController$BalVerdict;Lcom/android/server/wm/ActivityRecord;)Z
        lines_allowed_9 = [
            '    if-eqz p4, :fsi_a17_allowed_9_stock\n\n',
            '    move-object/from16 v0, p4\n\n',
        ]
        for pkg in FSI_PACKAGES:
            lines_allowed_9.extend([
                f'    const-string v1, "{pkg}"\n\n',
                '    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n\n',
                '    move-result v1\n\n',
                '    if-nez v1, :cond_fsi_allowed_9_exempt\n\n',
            ])
        lines_allowed_9.extend([
            '    goto :fsi_a17_allowed_9_stock\n\n',
            '    :cond_fsi_allowed_9_exempt\n\n',
            '    const/4 v0, 0x1\n\n',
            '    return v0\n\n',
            '    :fsi_a17_allowed_9_stock'
        ])
        starter_text = inject_method_preamble(
            starter_text,
            "isAllowedStartActivity(Landroid/content/Intent;IILjava/lang/String;IILandroid/content/pm/ActivityInfo;Lcom/android/server/wm/BackgroundActivityStartController$BalVerdict;Lcom/android/server/wm/ActivityRecord;)Z",
            "".join(lines_allowed_9),
            ":fsi_a17_allowed_9_stock",
            min_locals=2
        )

        if starter_text != original_starter:
            activity_starter.write_text(starter_text, encoding="utf-8")
            modified = True
        details[ACTIVITY_STARTER] = {"fsi_background_start_allowed": True}

    # 4. Hook AMS checkRunningCompatibility with ActivityInfo for FSI callingPackage
    ams_impl = locate(root, AMS_IMPL)
    if ams_impl is not None:
        original_ams = ams_impl.read_text(encoding="utf-8")
        lines_ams = [
            '    if-eqz p5, :fsi_a17_ams_compat_stock\n\n',
            '    move-object/from16 v0, p5\n\n',
        ]
        for pkg in FSI_PACKAGES:
            lines_ams.extend([
                f'    const-string v1, "{pkg}"\n\n',
                '    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z\n\n',
                '    move-result v1\n\n',
                '    if-nez v1, :cond_fsi_ams_compat_exempt\n\n',
            ])
        lines_ams.extend([
            '    goto :fsi_a17_ams_compat_stock\n\n',
            '    :cond_fsi_ams_compat_exempt\n\n',
            '    const/4 v0, 0x1\n\n',
            '    return v0\n\n',
            '    :fsi_a17_ams_compat_stock'
        ])
        ams_text = inject_method_preamble(
            original_ams,
            "checkRunningCompatibility(Landroid/app/IApplicationThread;Landroid/content/pm/ActivityInfo;Landroid/content/Intent;ILjava/lang/String;)Z",
            "".join(lines_ams),
            ":fsi_a17_ams_compat_stock",
            min_locals=2
        )
        if ams_text != original_ams:
            ams_impl.write_text(ams_text, encoding="utf-8")
            modified = True
        details[AMS_IMPL] = {"fsi_ams_compat_exempt": True}

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
