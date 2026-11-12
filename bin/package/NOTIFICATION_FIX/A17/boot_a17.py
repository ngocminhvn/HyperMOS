"""Generate the XNotifyFix boot actions that can run inside system_server."""

import os

from gmswall_a17 import PROP
from smali_a17 import FSI_PACKAGES, edit_method, replace_site

BOOT_CLASS = "com/android/server/am/ActivityManagerService.smali"
HELPER = "Lcom/android/server/am/HypermosNotificationBoot;"
SETTINGS = {
    "Secure": (
        ("notification_animation_style", "screen_on"),
        ("lock_screen_wake_up_for_notification", "1"),
        ("full_screen_aod_notification", "1"),
        ("lock_screen_show_notifications", "1"),
        ("lock_screen_allow_private_notifications", "1"),
        ("lock_screen_show_only_unseen_notifications", "0"),
    ),
    "System": (
        ("wake_up_for_notification", "1"),
        ("wakeup_for_keyguard_notification", "1"),
        ("pref_key_enable_notification_body", "1"),
        ("cloud_sleepmode_networkpolicy_enabled", "off"),
    ),
}


SOUND_SETTINGS = {
    "MIUI_COOLDOWN": {
        "System": (
            ("random_note_mode_mute_time_interval_ms", "0"),
            ("random_note_mode_sequence_time_interval_ms", "0"),
            ("random_note_mode_sequence_sound_number", "100"),
        ),
    },
    "ANDROID_COOLDOWN": {
        namespace: (
            ("notification_cooldown_enabled", "0"),
            ("notification_cooldown_all", "0"),
            ("notification_cooldown_vibrate_unlocked", "0"),
        )
        for namespace in ("System", "Global")
    },
    "OFFBODY_MUTE": {
        namespace: (("obtain_mute_when_off_body", "0"),)
        for namespace in ("System", "Global")
    },
}


def patch_boot(ams):
    source = ams.read_text(encoding="utf-8")
    boot_class = ams.with_name("HypermosNotificationBoot.smali")
    if f"{HELPER}-><init>" in source:
        old = boot_class.read_text(encoding="utf-8")
        updated = patch_firewall_trigger(old)
        if updated == old:
            return False
        boot_class.write_text(updated, encoding="utf-8")
        return True

    def insert(block):
        return replace_site(
            block,
            r"(^    invoke-virtual \{v\d+\}, Lcom/android/server/am/ActivityManagerServiceStub;->finishBooting\(\)V)$",
            r"\1" + r"\n\n    invoke-direct/range {p0 .. p0}, "
            r"Lcom/android/server/am/ActivityManagerService;->hypermosScheduleNotificationBoot()V",
            "boot actions",
        )

    source = edit_method(source, r"finishBooting\(\)V", insert)
    methods = [settings_method("applyDefaults", "defaults", SETTINGS)]
    calls = []
    for feature, settings in SOUND_SETTINGS.items():
        option = f"A17_DISABLE_{feature}"
        value = os.getenv(option, "0")
        if value not in ("0", "1"):
            raise ValueError(f"{option}: expected 0 or 1")
        if value == "1":
            name = "disable" + feature.title().replace("_", "")
            methods.append(settings_method(name, feature.lower(), settings))
            calls.append(f"    invoke-static {{v0}}, {HELPER}->{name}(Landroid/content/Context;)V")
    boot = BOOT_START.replace("    # Sound settings", "\n".join(calls))
    fsi_calls = [
        f'    const-string v1, "{package}"\n'
        f"    invoke-static {{v0, v1}}, {HELPER}->configureFsi(Landroid/content/Context;Ljava/lang/String;)V"
        for package in FSI_PACKAGES
    ]
    boot = boot.replace("    # Full-screen packages", "\n".join(fsi_calls))
    ams.write_text(source + SCHEDULE_BOOT, encoding="utf-8")
    boot_class.write_text(
        patch_firewall_trigger(boot + "".join(methods) + BOOT_GMS + BOOT_FSI),
        encoding="utf-8",
    )
    return True


def patch_firewall_trigger(source):
    def edit(block):
        if PROP in block:
            return block
        return replace_site(
            block,
            r"(^    invoke-virtual \{v0, v1, v2, v3, v4\}, Landroid/content/ContentResolver;"
            r"->call\(Landroid/net/Uri;Ljava/lang/String;Ljava/lang/String;Landroid/os/Bundle;\)Landroid/os/Bundle;)$",
            r"\1" + f'\n\n    const-string v2, "{PROP}"'
            '\n    const-string v3, "1"'
            "\n    invoke-static {v2, v3}, Landroid/os/SystemProperties;->set(Ljava/lang/String;Ljava/lang/String;)V",
            "init GMS firewall action",
        )

    return edit_method(source, r"disarmPowerKeeper\(Landroid/content/Context;\)V", edit)


def settings_method(name, marker, settings):
    lines = []
    for namespace, entries in settings.items():
        for key, value in entries:
            lines.append(f"""
    const-string v1, "{key}"
    const-string v2, "{value}"
    invoke-static {{v0, v1, v2}}, Landroid/provider/Settings${namespace};->putString(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Z
    move-result v4
    and-int/2addr v3, v4
""")
    start = SETTINGS_START.replace("applyDefaults", name).replace("defaults_applied", marker + "_applied")
    end = SETTINGS_END.replace("defaults_applied", marker + "_applied")
    return start + "".join(lines) + end


SCHEDULE_BOOT = f"""
.method private hypermosScheduleNotificationBoot()V
    .locals 4

    iget-object v0, p0, Lcom/android/server/am/ActivityManagerService;->mContext:Landroid/content/Context;
    new-instance v1, {HELPER}
    invoke-direct {{v1, v0}}, {HELPER}-><init>(Landroid/content/Context;)V
    invoke-static {{}}, Lcom/android/internal/os/BackgroundThread;->getHandler()Landroid/os/Handler;
    move-result-object v0
    const-wide/16 v2, 0x1388
    invoke-virtual {{v0, v1, v2, v3}}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z
    return-void
.end method
"""

BOOT_START = f""".class final {HELPER}
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;

.field private final context:Landroid/content/Context;

.method public constructor <init>(Landroid/content/Context;)V
    .locals 0
    invoke-direct {{p0}}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, {HELPER}->context:Landroid/content/Context;
    return-void
.end method

.method public run()V
    .locals 2
    iget-object v0, p0, {HELPER}->context:Landroid/content/Context;

    :settings_start
    invoke-static {{v0}}, {HELPER}->applyDefaults(Landroid/content/Context;)V
    # Sound settings
    :settings_end
    .catch Ljava/lang/RuntimeException; {{:settings_start .. :settings_end}} :settings_error
    goto :gms_start

    :settings_error
    move-exception v1
    invoke-static {{v1}}, {HELPER}->logFailure(Ljava/lang/Exception;)V

    :gms_start
    invoke-static {{v0}}, {HELPER}->disarmPowerKeeper(Landroid/content/Context;)V
    invoke-static {{v0}}, {HELPER}->configureGms(Landroid/content/Context;)V
    :gms_end
    .catch Ljava/lang/Exception; {{:gms_start .. :gms_end}} :gms_error
    goto :fsi

    :gms_error
    move-exception v1
    invoke-static {{v1}}, {HELPER}->logFailure(Ljava/lang/Exception;)V

    :fsi
    # Full-screen packages
    return-void
.end method

.method private static logFailure(Ljava/lang/Exception;)V
    .locals 2
    const-string v0, "HyperMOSNotification"
    const-string v1, "XNotifyFix boot action failed"
    invoke-static {{v0, v1, p0}}, Landroid/util/Slog;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    return-void
.end method
"""

SETTINGS_START = """
.method private static applyDefaults(Landroid/content/Context;)V
    .locals 5
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v0

    const-string v1, "hypermos_xnotify_defaults_applied"
    const/4 v2, 0x0
    invoke-static {v0, v1, v2}, Landroid/provider/Settings$Secure;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I
    move-result v2
    if-nez v2, :done

    const/4 v3, 0x1
"""

SETTINGS_END = """
    if-eqz v3, :done
    const-string v1, "hypermos_xnotify_defaults_applied"
    invoke-static {v0, v1, v3}, Landroid/provider/Settings$Secure;->putInt(Landroid/content/ContentResolver;Ljava/lang/String;I)Z

    :done
    return-void
.end method
"""

BOOT_GMS = f"""
.method private static disarmPowerKeeper(Landroid/content/Context;)V
    .locals 5

    :start
    invoke-virtual {{p0}}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v0

    const-string v1, "content://com.miui.powerkeeper.configure/SimpleSettings/misc"
    invoke-static {{v1}}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v1

    new-instance v4, Landroid/os/Bundle;
    invoke-direct {{v4}}, Landroid/os/Bundle;-><init>()V
    const-string v2, "value"
    const-string v3, "false"
    invoke-virtual {{v4, v2, v3}}, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V

    const-string v2, "PUT_misc"
    const-string v3, "gms_control"
    invoke-virtual {{v0, v1, v2, v3, v4}}, Landroid/content/ContentResolver;->call(Landroid/net/Uri;Ljava/lang/String;Ljava/lang/String;Landroid/os/Bundle;)Landroid/os/Bundle;

    const-string v1, "content://com.miui.powerkeeper.configure/userTable"
    invoke-static {{v1}}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v1
    new-instance v2, Landroid/content/ContentValues;
    invoke-direct {{v2}}, Landroid/content/ContentValues;-><init>()V
    const-string v3, "bgControl"
    const-string v4, "miuiAuto"
    invoke-virtual {{v2, v3, v4}}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    const-string v3, "pkgName='com.android.vending' AND userId=0"
    const/4 v4, 0x0
    invoke-virtual {{v0, v1, v2, v3, v4}}, Landroid/content/ContentResolver;->update(Landroid/net/Uri;Landroid/content/ContentValues;Ljava/lang/String;[Ljava/lang/String;)I
    :end
    .catch Ljava/lang/RuntimeException; {{:start .. :end}} :error
    return-void

    :error
    move-exception v0
    invoke-static {{v0}}, {HELPER}->logFailure(Ljava/lang/Exception;)V
    return-void
.end method

.method private static configureGms(Landroid/content/Context;)V
    .locals 6
    const-string v0, "com.google.android.gms"
    const/4 v1, 0x0
    invoke-virtual {{p0}}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;
    move-result-object v2

    :uid_start
    invoke-virtual {{v2, v0, v1}}, Landroid/content/pm/PackageManager;->getPackageUid(Ljava/lang/String;I)I
    move-result v2
    :uid_end
    .catch Landroid/content/pm/PackageManager$NameNotFoundException; {{:uid_start .. :uid_end}} :missing

    const-class v3, Landroid/os/PowerExemptionManager;
    invoke-virtual {{p0, v3}}, Landroid/content/Context;->getSystemService(Ljava/lang/Class;)Ljava/lang/Object;
    move-result-object v3
    check-cast v3, Landroid/os/PowerExemptionManager;
    if-eqz v3, :appops
    invoke-virtual {{v3, v0}}, Landroid/os/PowerExemptionManager;->addToPermanentAllowList(Ljava/lang/String;)V

    :appops
    const-class v3, Landroid/app/AppOpsManager;
    invoke-virtual {{p0, v3}}, Landroid/content/Context;->getSystemService(Ljava/lang/Class;)Ljava/lang/Object;
    move-result-object v3
    check-cast v3, Landroid/app/AppOpsManager;
    if-eqz v3, :reconnect

    const/16 v4, 0x3f
    invoke-static {{v3, v4, v2, v0}}, {HELPER}->allowOp(Landroid/app/AppOpsManager;IILjava/lang/String;)V
    const/16 v4, 0x46
    invoke-static {{v3, v4, v2, v0}}, {HELPER}->allowOp(Landroid/app/AppOpsManager;IILjava/lang/String;)V
    const/16 v4, 0x2718
    invoke-static {{v3, v4, v2, v0}}, {HELPER}->allowOp(Landroid/app/AppOpsManager;IILjava/lang/String;)V
    const/16 v4, 0x28
    invoke-static {{v3, v4, v2, v0}}, {HELPER}->allowOp(Landroid/app/AppOpsManager;IILjava/lang/String;)V

    :reconnect
    invoke-static {{v2}}, {HELPER}->thawGms(I)V
    new-instance v4, Landroid/content/Intent;
    const-string v5, "com.google.android.intent.action.GCM_RECONNECT"
    invoke-direct {{v4, v5}}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V
    invoke-virtual {{v4, v0}}, Landroid/content/Intent;->setPackage(Ljava/lang/String;)Landroid/content/Intent;
    const/16 v5, 0x20
    invoke-virtual {{v4, v5}}, Landroid/content/Intent;->addFlags(I)Landroid/content/Intent;
    invoke-virtual {{p0, v4}}, Landroid/content/Context;->sendBroadcast(Landroid/content/Intent;)V
    return-void

    :missing
    move-exception v2
    return-void
.end method

.method private static thawGms(I)V
    .locals 3

    :start
    const-string v0, "greezer"
    invoke-static {{v0}}, Landroid/os/ServiceManager;->getService(Ljava/lang/String;)Landroid/os/IBinder;
    move-result-object v0
    instance-of v1, v0, Lcom/miui/server/greeze/GreezeManagerService;
    if-eqz v1, :done
    check-cast v0, Lcom/miui/server/greeze/GreezeManagerService;
    invoke-virtual {{v0, p0}}, Lcom/miui/server/greeze/GreezeManagerService;->clearMonitorNet(I)V

    const v1, 0x5265c00
    const-string v2, "cmd_thuid"
    invoke-virtual {{v0, p0, v1, v2}}, Lcom/miui/server/greeze/GreezeManagerService;->thawUid(IILjava/lang/String;)Z
    :done
    return-void
    :end
    .catch Ljava/lang/RuntimeException; {{:start .. :end}} :error

    :error
    move-exception v0
    invoke-static {{v0}}, {HELPER}->logFailure(Ljava/lang/Exception;)V
    return-void
.end method

.method private static allowOp(Landroid/app/AppOpsManager;IILjava/lang/String;)V
    .locals 1
    const/4 v0, 0x0
    :start
    invoke-virtual {{p0, p1, p2, p3, v0}}, Landroid/app/AppOpsManager;->setMode(IILjava/lang/String;I)V
    :end
    .catch Ljava/lang/RuntimeException; {{:start .. :end}} :error
    return-void

    :error
    move-exception v0
    invoke-static {{v0}}, {HELPER}->logFailure(Ljava/lang/Exception;)V
    return-void
.end method
"""


BOOT_FSI = f"""
.method private static configureFsi(Landroid/content/Context;Ljava/lang/String;)V
    .locals 7

    :start
    const/4 v0, 0x0
    invoke-virtual {{p0}}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;
    move-result-object v1
    invoke-virtual {{v1, p1, v0}}, Landroid/content/pm/PackageManager;->getPackageUid(Ljava/lang/String;I)I
    move-result v2

    # Apply the chosen grant once per installed package UID, as when the
    # upstream WebUI selection is saved. Later Android AppOps edits persist.
    invoke-virtual {{p0}}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v5
    const-string v6, "hypermos_xnotify_fsi_uid_"
    invoke-virtual {{v6, p1}}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v6
    const/4 v1, -0x1
    invoke-static {{v5, v6, v1}}, Landroid/provider/Settings$Secure;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I
    move-result v1
    if-eq v1, v2, :done

    const-class v3, Landroid/app/AppOpsManager;
    invoke-virtual {{p0, v3}}, Landroid/content/Context;->getSystemService(Ljava/lang/Class;)Ljava/lang/Object;
    move-result-object v3
    check-cast v3, Landroid/app/AppOpsManager;
    if-eqz v3, :done

    const-string v4, "android:use_full_screen_intent"
    invoke-static {{v4}}, Landroid/app/AppOpsManager;->strOpToOp(Ljava/lang/String;)I
    move-result v4
    invoke-static {{v3, v4, v2, p1}}, {HELPER}->allowOp(Landroid/app/AppOpsManager;IILjava/lang/String;)V
    const/16 v4, 0x2724
    invoke-static {{v3, v4, v2, p1}}, {HELPER}->allowOp(Landroid/app/AppOpsManager;IILjava/lang/String;)V
    const/16 v4, 0x2725
    invoke-static {{v3, v4, v2, p1}}, {HELPER}->allowOp(Landroid/app/AppOpsManager;IILjava/lang/String;)V
    invoke-static {{v5, v6, v2}}, Landroid/provider/Settings$Secure;->putInt(Landroid/content/ContentResolver;Ljava/lang/String;I)Z

    :done
    return-void
    :end
    .catch Landroid/content/pm/PackageManager$NameNotFoundException; {{:start .. :end}} :missing
    .catch Ljava/lang/RuntimeException; {{:start .. :end}} :error

    :missing
    move-exception v0
    return-void

    :error
    move-exception v0
    invoke-static {{v0}}, {HELPER}->logFailure(Ljava/lang/Exception;)V
    return-void
.end method
"""
