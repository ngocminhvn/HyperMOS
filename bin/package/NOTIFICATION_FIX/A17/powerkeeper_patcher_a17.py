#!/usr/bin/env python3
"""Scoped Android 17 / OS4 PowerKeeper smali patcher.

Only disables the outgoing Google-network limiter that blocks FCM.  It does
not change Doze, sleep mode, alarms, cloud policy, or per-app battery policy.
Does NOT import PerfHook or external Ryu classes.
"""
import argparse
import json
import re
from pathlib import Path

GMS_OBSERVER = "com/miui/powerkeeper/utils/GmsObserver.smali"
INTERNATIONAL_ADAPTER = "com/miui/powerkeeper/utils/InternationalAdapter.smali"
LOCAL_UPDATE_UTILS = "com/miui/powerkeeper/cloudcontrol/LocalUpdateUtils.smali"
UTILS = "com/miui/powerkeeper/utils/Utils.smali"
DEVICE = "com/miui/powerkeeper/utils/Device.smali"


def locate(root: Path, relative: str, required=True):
    matches = [path for path in root.glob("smali*/" + relative) if path.is_file()]
    direct = root / relative
    if not matches and direct.is_file():
        matches = [direct]
    if not matches and not required:
        return None
    if len(matches) != 1:
        raise ValueError(f"expected one {relative}, got {len(matches)}")
    return matches[0]


def method_pattern(signature: str):
    return re.compile(
        rf"(?ms)^\.method[^\n]*\b{re.escape(signature)}[^\n]*\n.*?^\.end method[ \t]*$"
    )


def force_boolean_parameter(source: str, signature: str, parameter: str, value: int):
    methods = list(method_pattern(signature).finditer(source))
    if len(methods) != 1:
        raise ValueError(f"expected one {signature}, got {len(methods)}")
    block = methods[0].group()
    registers = re.search(r"(?m)^([ \t]*)\.(?:registers|locals)[ \t]+\d+[ \t]*$", block)
    if not registers:
        raise ValueError(f"{signature}: missing registers declaration")
    instruction = f"{registers.group(1)}const/4 {parameter}, 0x{value:x}"
    following = block[registers.end():]
    already_forced = re.match(
        rf"\s*const/4[ \t]+{re.escape(parameter)},[ \t]+0x{value:x}\b", following)
    if not already_forced:
        at = registers.end()
        block = block[:at] + "\n\n" + instruction + block[at:]
    return source[:methods[0].start()] + block + source[methods[0].end():]


def patch(root: Path):
    if not root.is_dir():
        raise ValueError(f"Missing decompiled PowerKeeper smali dir: {root}")

    details = {}
    total = 0

    # OS4 moved the old region-gated FCM behavior into a Google-reachability
    # observer. It inverts "reachable" to a Greezer "limit" bit. Keep the old
    # XNotifyFix's runtime gms_control=false outcome narrowly by forcing only
    # that outgoing notification-limit bit false; do not alter sleep mode,
    # alarms, cloud configuration, or unrelated power policy.
    gms = locate(root, GMS_OBSERVER)
    gms.write_text(
        force_boolean_parameter(
            gms.read_text(encoding="utf-8"),
            "updateFrameworkGmsNetStatus(Z)Z", "p1", 0),
        encoding="utf-8")
    details[GMS_OBSERVER] = {"gms_network_limit_forced_false": True}
    total += 1

    # 2. InternationalAdapter: empty initRestrictPkgs (no-op) and clear sNetworkAllowApps
    # matches Global EEA behavior to eliminate sleep-mode alarm throttling and network restriction.
    ia_file = locate(root, INTERNATIONAL_ADAPTER, required=False)
    if ia_file is not None:
        ia_text = ia_file.read_text(encoding="utf-8")
        irp_re = re.compile(
            r"(?ms)^\.method[^\n]*\binitRestrictPkgs\([^\n]*\n.*?^\.end method[ \t]*$"
        )
        if irp_re.search(ia_text):
            new_irp = (
                ".method public static initRestrictPkgs(Landroid/content/Context;)V\n"
                "    .registers 1\n\n"
                "    return-void\n"
                ".end method"
            )
            ia_text = irp_re.sub(new_irp, ia_text)
        ia_text = re.sub(
            r'(?m)^(\.field public static sNetworkAllowApps:Ljava/lang/String; = )".*?"',
            r'\1""',
            ia_text
        )
        ia_text = re.sub(
            r'(?m)^([ \t]*const-string[ \t]+[vp]\d+,[ \t]+)"com\.xiaomi\.xmsf.*?"(\s*\n[ \t]*sput-object[ \t]+[vp]\d+,[ \t]+Lcom/miui/powerkeeper/utils/InternationalAdapter;->sNetworkAllowApps:Ljava/lang/String;)',
            r'\1""\2',
            ia_text
        )
        ia_file.write_text(ia_text, encoding="utf-8")
        details[INTERNATIONAL_ADAPTER] = {
            "init_restrict_pkgs_noop": True,
            "network_allow_apps_emptied": True,
        }
        total += 1

    # 3. Direct PowerKeeper Cloud Sync to International Endpoint:
    # Routes to jupiter.intl.sys.miui.com with global SIDs (disables GMS control,
    # drops aggressive freeze/sync kill, and sets standby chain delay to 30s).
    lu_file = locate(root, LOCAL_UPDATE_UTILS, required=False)
    if lu_file is not None:
        lu_text = lu_file.read_text(encoding="utf-8")
        set_server_re = re.compile(
            r"(?ms)^\.method private static setServerConfigurations\([^\n]*\n.*?^\.end method[ \t]*$"
        )
        if set_server_re.search(lu_text):
            new_set_server = (
                ".method private static setServerConfigurations(Landroid/content/Context;)V\n"
                "    .registers 2\n\n"
                '    const-string/jumbo v0, "https://jupiter.intl.sys.miui.com/api/profile/getProfile.do?"\n\n'
                "    sput-object v0, Lcom/miui/powerkeeper/cloudcontrol/Constants;->CLOUD_NEW_SERVER:Ljava/lang/String;\n\n"
                '    const-string/jumbo v0, "wdFSzmfNh"\n\n'
                "    sput-object v0, Lcom/miui/powerkeeper/cloudcontrol/Constants;->CLOUD_POWER_NEW_SID:Ljava/lang/String;\n\n"
                '    const-string/jumbo v0, "kxIu9S9Wi"\n\n'
                "    sput-object v0, Lcom/miui/powerkeeper/cloudcontrol/Constants;->CLOUD_PERF_ENGINE_SID:Ljava/lang/String;\n\n"
                '    const-string/jumbo v0, "J6G4oVvvp"\n\n'
                "    sput-object v0, Lcom/miui/powerkeeper/cloudcontrol/Constants;->CLOUD_THERMAL_NEW_SID:Ljava/lang/String;\n\n"
                '    const-string/jumbo v0, "MGdeXyMDu"\n\n'
                "    sput-object v0, Lcom/miui/powerkeeper/cloudcontrol/Constants;->CLOUD_PERF_SHIELDER_SID:Ljava/lang/String;\n\n"
                "    return-void\n"
                ".end method"
            )
            lu_text = set_server_re.sub(new_set_server, lu_text)
            lu_file.write_text(lu_text, encoding="utf-8")
            details[LOCAL_UPDATE_UTILS] = {"cloud_server_forced_international": True}
            total += 1

    # 4. Scope-isolated Utils.getRegion():
    # Returns GLOBAL within PowerKeeper so cloud registration uses rgn-GLOBAL.
    utils_file = locate(root, UTILS, required=False)
    if utils_file is not None:
        u_text = utils_file.read_text(encoding="utf-8")
        get_rgn_re = re.compile(
            r"(?ms)^\.method static getRegion\(\)Ljava/lang/String;\s*\n.*?^\.end method[ \t]*$"
        )
        if get_rgn_re.search(u_text):
            new_get_rgn = (
                ".method static getRegion()Ljava/lang/String;\n"
                "    .registers 1\n\n"
                '    const-string/jumbo v0, "GLOBAL"\n\n'
                "    return-object v0\n"
                ".end method"
            )
            u_text = get_rgn_re.sub(new_get_rgn, u_text)
            utils_file.write_text(u_text, encoding="utf-8")
            details[UTILS] = {"region_forced_global": True}
            total += 1

    # 5. Scope-isolated Device.getModel():
    # Maps model to 2412DPN6CG (Xiaomi 15 Ultra Global / xuanyuan) ONLY within
    # PowerKeeper cloud sync without affecting system camera, HAL, or properties.
    dev_file = locate(root, DEVICE, required=False)
    if dev_file is not None:
        d_text = dev_file.read_text(encoding="utf-8")
        get_mod_re = re.compile(
            r"(?ms)^\.method public static getModel\(\)Ljava/lang/String;\s*\n.*?^\.end method[ \t]*$"
        )
        if get_mod_re.search(d_text):
            new_get_mod = (
                ".method public static getModel()Ljava/lang/String;\n"
                "    .registers 1\n\n"
                '    const-string/jumbo v0, "2412DPN6CG"\n\n'
                "    return-object v0\n"
                ".end method"
            )
            d_text = get_mod_re.sub(new_get_mod, d_text)
            dev_file.write_text(d_text, encoding="utf-8")
            details[DEVICE] = {"model_mapped_xuanyuan_global": True}
            total += 1

    if total == 0:
        raise ValueError("no Android 17 PowerKeeper gates were patched")

    return {
        "status": "success",
        "target_apk": "PowerKeeper.apk",
        "gates_replaced": total,
        "patched_files": details,
        "perfhook_omitted": True,
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("smali_dir", type=Path)
    parser.add_argument("--report", required=True, type=Path)
    args = parser.parse_args()
    report = patch(args.smali_dir)
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("[POWERKEEPER A17] " + json.dumps(report))


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        raise SystemExit("[POWERKEEPER A17] FAIL: " + str(exc))
