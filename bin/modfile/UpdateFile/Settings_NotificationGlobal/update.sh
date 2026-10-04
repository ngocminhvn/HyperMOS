#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

androidVER="$(cat "$work_dir/bin/ddevice/androidver.txt")"
[[ "$androidVER" == "16" ]] || {
  info "Settings Notification/Passkey: Android $androidVER -> skipped"
  exit 0
}

MAIN_FOLDER="$work_dir/build/baserom/images"
APKEDITOR="java -jar $work_dir/bin/apktool/apke.jar"
tmp="$work_dir/apk_temp/settings-notification-global"

apk=$(find "$MAIN_FOLDER" -type f -name "Settings.apk" -print -quit)
[[ -n "$apk" && -f "$apk" ]] || {
  error "Settings Notification/Passkey: Settings.apk not found"
  exit 1
}

dir=$(dirname "$apk")
rm -rf "$tmp"
mkdir -p "$tmp/out" "$tmp/final"

mods "Settings: restoring notification channel controls + Passkey UI"
$APKEDITOR d -t raw -f -no-dex-debug -i "$apk" -o "$tmp/out" >/dev/null

SETTINGS_OUT="$tmp/out" python3 <<'PY'
from pathlib import Path
import os
import re
import sys

root = Path(os.environ["SETTINGS_OUT"])

# ------------------------------------------------------------------
# 1) HyperOS NotificationMoreSettings / Badge
# ------------------------------------------------------------------
base_files = list(root.glob("smali*/com/android/settings/notification/BaseNotificationSettings.smali"))
if not base_files:
    print("BaseNotificationSettings.smali not found", file=sys.stderr)
    sys.exit(61)
base = base_files[0]
smali_root = Path(str(base).split("/com/android/settings/notification/BaseNotificationSettings.smali")[0])

listener = smali_root / "com/android/settings/notification/HyperMosNotificationListener.smali"
listener.parent.mkdir(parents=True, exist_ok=True)
listener.write_text(r'''.class public final Lcom/android/settings/notification/HyperMosNotificationListener;
.super Ljava/lang/Object;
.implements Landroidx/preference/Preference$OnPreferenceChangeListener;

.field private final mOwner:Lcom/android/settings/notification/BaseNotificationSettings;
.field private final mMode:I

.method public constructor <init>(Lcom/android/settings/notification/BaseNotificationSettings;I)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/android/settings/notification/HyperMosNotificationListener;->mOwner:Lcom/android/settings/notification/BaseNotificationSettings;
    iput p2, p0, Lcom/android/settings/notification/HyperMosNotificationListener;->mMode:I
    return-void
.end method

.method public onPreferenceChange(Landroidx/preference/Preference;Ljava/lang/Object;)Z
    .locals 4

    iget-object v1, p0, Lcom/android/settings/notification/HyperMosNotificationListener;->mOwner:Lcom/android/settings/notification/BaseNotificationSettings;
    iget v0, p0, Lcom/android/settings/notification/HyperMosNotificationListener;->mMode:I

    if-nez v0, :hypermos_badge

    check-cast p2, Ljava/lang/String;
    invoke-static {p2}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I
    move-result v0

    iput v0, v1, Lcom/android/settings/notification/BaseNotificationSettings;->mBackupImportance:I

    iget-object v2, v1, Lcom/android/settings/notification/BaseNotificationSettings;->mChannel:Landroid/app/NotificationChannel;
    if-eqz v2, :hypermos_done

    invoke-virtual {v2, v0}, Landroid/app/NotificationChannel;->setImportance(I)V
    const/4 v3, 0x4
    invoke-virtual {v2, v3}, Landroid/app/NotificationChannel;->lockFields(I)V

    iget-object v2, v1, Lcom/android/settings/notification/BaseNotificationSettings;->mBackend:Lcom/android/settings/notification/MiuiNotificationBackend;
    iget-object v0, v1, Lcom/android/settings/notification/BaseNotificationSettings;->mPkg:Ljava/lang/String;
    iget v3, v1, Lcom/android/settings/notification/BaseNotificationSettings;->mUid:I
    iget-object v1, v1, Lcom/android/settings/notification/BaseNotificationSettings;->mChannel:Landroid/app/NotificationChannel;
    invoke-virtual {v2, v0, v3, v1}, Lcom/android/settings/notification/MiuiNotificationBackend;->updateChannel(Ljava/lang/String;ILandroid/app/NotificationChannel;)V
    goto :hypermos_done

:hypermos_badge
    check-cast p2, Ljava/lang/Boolean;
    invoke-virtual {p2}, Ljava/lang/Boolean;->booleanValue()Z
    move-result v0

    iget-object v2, v1, Lcom/android/settings/notification/BaseNotificationSettings;->mChannel:Landroid/app/NotificationChannel;
    if-eqz v2, :hypermos_done

    invoke-virtual {v2, v0}, Landroid/app/NotificationChannel;->setShowBadge(Z)V
    const/16 v3, 0x80
    invoke-virtual {v2, v3}, Landroid/app/NotificationChannel;->lockFields(I)V

    iget-object v2, v1, Lcom/android/settings/notification/BaseNotificationSettings;->mBackend:Lcom/android/settings/notification/MiuiNotificationBackend;
    iget-object v0, v1, Lcom/android/settings/notification/BaseNotificationSettings;->mPkg:Ljava/lang/String;
    iget v3, v1, Lcom/android/settings/notification/BaseNotificationSettings;->mUid:I
    iget-object p1, v1, Lcom/android/settings/notification/BaseNotificationSettings;->mChannel:Landroid/app/NotificationChannel;
    invoke-virtual {v2, v0, v3, p1}, Lcom/android/settings/notification/MiuiNotificationBackend;->updateChannel(Ljava/lang/String;ILandroid/app/NotificationChannel;)V

    const/4 v0, 0x0
    invoke-virtual {v1, v0}, Lcom/android/settings/notification/BaseNotificationSettings;->refreshNotificationShade(Z)V

:hypermos_done
    const/4 v0, 0x1
    return v0
.end method
''', encoding="utf-8")

channel_files = []
for rel in (
    "com/android/settings/notification/ChannelNotificationSettings.smali",
    "com/android/settings/notification/app/ChannelNotificationSettings.smali",
):
    channel_files += list(root.glob(f"smali*/{rel}"))

if not channel_files:
    print("ChannelNotificationSettings smali not found", file=sys.stderr)
    sys.exit(62)

helper_template = r'''
.method private hypermosSetupNotificationMore()V
    .locals 4

    const-string v0, "importance"
    invoke-virtual {p0, v0}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;
    move-result-object v1

    instance-of v2, v1, Lmiuix/preference/DropDownPreference;
    if-eqz v2, :hypermos_setup_badge

    check-cast v1, Lmiuix/preference/DropDownPreference;
    iput-object v1, p0, Lcom/android/settings/notification/BaseNotificationSettings;->mImportance:Lmiuix/preference/DropDownPreference;

    const/4 v2, 0x1
    invoke-virtual {p0, v1, v2}, Lcom/android/settings/notification/BaseNotificationSettings;->setPrefVisible(Landroidx/preference/Preference;Z)V

    iget v2, p0, Lcom/android/settings/notification/BaseNotificationSettings;->mBackupImportance:I
    invoke-static {v2}, Ljava/lang/Integer;->toString(I)Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v1, v0}, Landroidx/preference/ListPreference;->setValue(Ljava/lang/String;)V

    new-instance v2, Lcom/android/settings/notification/HyperMosNotificationListener;
    const/4 v3, 0x0
    invoke-direct {v2, p0, v3}, Lcom/android/settings/notification/HyperMosNotificationListener;-><init>(Lcom/android/settings/notification/BaseNotificationSettings;I)V
    invoke-virtual {v1, v2}, Landroidx/preference/Preference;->setOnPreferenceChangeListener(Landroidx/preference/Preference$OnPreferenceChangeListener;)V

:hypermos_setup_badge
    const-string v0, "setting_badge"
    invoke-virtual {p0, v0}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;
    move-result-object v1
    if-nez v1, :hypermos_have_badge

    const-string v0, "badge"
    invoke-virtual {p0, v0}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;
    move-result-object v1

:hypermos_have_badge
    instance-of v2, v1, Landroidx/preference/CheckBoxPreference;
    if-eqz v2, :hypermos_setup_done

    check-cast v1, Landroidx/preference/CheckBoxPreference;
    iput-object v1, p0, Lcom/android/settings/notification/BaseNotificationSettings;->mBadge:Landroidx/preference/CheckBoxPreference;

    const/4 v2, 0x1
    invoke-virtual {p0, v1, v2}, Lcom/android/settings/notification/BaseNotificationSettings;->setPrefVisible(Landroidx/preference/Preference;Z)V

    new-instance v2, Lcom/android/settings/notification/HyperMosNotificationListener;
    const/4 v3, 0x1
    invoke-direct {v2, p0, v3}, Lcom/android/settings/notification/HyperMosNotificationListener;-><init>(Lcom/android/settings/notification/BaseNotificationSettings;I)V
    invoke-virtual {v1, v2}, Landroidx/preference/Preference;->setOnPreferenceChangeListener(Landroidx/preference/Preference$OnPreferenceChangeListener;)V

:hypermos_setup_done
    return-void
.end method
'''

patched_channels = 0
for path in channel_files:
    text = path.read_text(encoding="utf-8")
    class_m = re.search(r"(?m)^\.class\b[^\n]*\s+(L[^;]+;)\s*$", text)
    if not class_m:
        print(f"class descriptor missing: {path}", file=sys.stderr)
        sys.exit(63)
    klass = class_m.group(1)

    method = re.search(
        r"(?ms)^\.method\b[^\n]*\bremoveDefaultPrefs\(\)V\s*$.*?^\.end method\s*$",
        text,
    )
    if not method:
        print(f"removeDefaultPrefs()V missing: {path}", file=sys.stderr)
        sys.exit(64)

    body = method.group(0)
    if "hypermosSetupNotificationMore()V" not in body:
        returns = [m for m in re.finditer(r"(?m)^\s*return-void\s*$", body)]
        if not returns:
            print(f"return-void missing in removeDefaultPrefs: {path}", file=sys.stderr)
            sys.exit(65)
        last = returns[-1]
        inject = (
            f"    invoke-direct {{p0}}, {klass}->hypermosSetupNotificationMore()V\n\n"
        )
        body = body[:last.start()] + inject + body[last.start():]
        text = text[:method.start()] + body + text[method.end():]

    if ".method private hypermosSetupNotificationMore()V" not in text:
        text = text.rstrip() + "\n\n" + helper_template.strip() + "\n"

    path.write_text(text, encoding="utf-8")
    patched_channels += 1

# ------------------------------------------------------------------
# 2) Passkey UI: only make Credential Manager Settings evaluate the
#    international-build gate as true. Do not globally spoof region.
# ------------------------------------------------------------------
credential_files = list(root.glob("smali*/com/android/settings/applications/credentials/**/*.smali"))
credential_files += list(root.glob("smali*/com/android/settings/applications/credentials/*.smali"))
credential_files = list(dict.fromkeys(credential_files))

intl_reads = 0
pat = re.compile(
    r"(sget-boolean\s+)([vp]\d+),\s+Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z"
)
for path in credential_files:
    text = path.read_text(encoding="utf-8")
    def repl(m):
        nonlocal_dummy = None
        return f"const/4 {m.group(2)}, 0x1"
    new, count = pat.subn(repl, text)
    if count:
        path.write_text(new, encoding="utf-8")
        intl_reads += count

if intl_reads == 0:
    print("Passkey Settings international-build gates not found", file=sys.stderr)
    sys.exit(66)

print(f"notification channel variants patched={patched_channels}; passkey Settings gates={intl_reads}")
PY

name=$(basename "$apk")
$APKEDITOR b -f -i "$tmp/out" -o "$tmp/final/$name" >/dev/null

[[ -s "$tmp/final/$name" ]] || {
  error "Settings Notification/Passkey: rebuild failed"
  exit 1
}
unzip -tq "$tmp/final/$name" >/dev/null

rm -rf "$dir/oat"
cp -f "$tmp/final/$name" "$apk"
rm -rf "$tmp"

mods "Settings NotificationMore/Badge + Passkey UI -> Done"
