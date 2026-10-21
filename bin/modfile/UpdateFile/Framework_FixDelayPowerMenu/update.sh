#!/usr/bin/env bash
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"

rom_source=""
if [[ -f "$work_dir/bin/ddevice/rom_source.txt" ]]; then
    rom_source="$(tr -d '\r\n' < "$work_dir/bin/ddevice/rom_source.txt")"
fi
deviceTYPE="$(cat "$work_dir/bin/ddevice/device_type.txt")"
rom_os="$(cat "$work_dir/bin/ddevice/rom_os.txt")"
sdkLevel="$(cat "$work_dir/bin/ddevice/sdkLevel.txt")"

# China retains its power-menu patch. EU OS3 uses a reversible trial:
# set HYPERMOS_EU_DELAY_POWER_MENU_FIX=0 to preserve the original EU JAR.
if [[ "$rom_source" == "xiaomi_eu" ]]; then
    if [[ "${HYPERMOS_EU_DELAY_POWER_MENU_FIX:-1}" != "1" ]]; then
        mods "EU: power-menu patch disabled; keeping original JAR"
        exit 0
    fi
    if [[ "$rom_os" != "OS3" ]]; then
        mods "EU: power-menu trial validated only for OS3; skipping $rom_os"
        exit 0
    fi
elif [[ "$deviceTYPE" != "China" ]]; then
    exit 0
fi

target_jar="$work_dir/build/baserom/images/system_ext/framework/miui-services.jar"
bak="$work_dir/bin/apktool/baksmaliv2.jar"
sma="$work_dir/bin/apktool/smaliv2.jar"
search='sget-boolean v0, Lmiui/os/Build;->IS_GLOBAL_BUILD:Z'
replacement='const/4 v0, 0x1'

if [[ "$rom_os" == "MIUI" ]]; then
    target_class='MiuiKeyShortcutManager$MiuiOtherSettingsObserver.smali'
else
    target_class='MiuiShortcutTriggerHelper$ShortcutSettingsObserver.smali'
fi

if [[ ! -s "$target_jar" || ! -s "$bak" || ! -s "$sma" ]]; then
    error "FixDelayPowerMenu: missing source JAR or smali tools"
    exit 1
fi

# Preserve source JAR until every validation/assembly step succeeds.
patch_tmp="$(mktemp -d "$work_dir/jar_temp.powermenu.XXXXXX")"
trap 'rm -rf "$patch_tmp"' EXIT
mkdir -p "$patch_tmp/original" "$patch_tmp/disasm"
unzip -q "$target_jar" -d "$patch_tmp/original"

mapfile -d '' -t dex_files < <(
    find "$patch_tmp/original" -maxdepth 1 -type f -name 'classes*.dex' -print0 | sort -zV
)
if (( ${#dex_files[@]} == 0 )); then
    error "FixDelayPowerMenu: no classes*.dex found"
    exit 1
fi

for dex in "${dex_files[@]}"; do
    dex_name="$(basename "$dex")"
    java -jar "$bak" d --api "$sdkLevel" "$dex" \
        -o "$patch_tmp/disasm/$dex_name" >/dev/null || {
        error "FixDelayPowerMenu: failed to disassemble $dex_name"
        exit 1
    }
done

# Literal dollar sign selects the nested observer, not its parent class.
mapfile -d '' -t matches < <(
    find "$patch_tmp/disasm" -type f -name "$target_class" -print0
)
if (( ${#matches[@]} != 1 )); then
    error "FixDelayPowerMenu: expected one $target_class, found ${#matches[@]}"
    exit 1
fi
smali_file="${matches[0]}"
old_count="$(grep -Fc "$search" "$smali_file" || true)"
new_count_before="$(grep -Fc "$replacement" "$smali_file" || true)"

# The EU OS3 reference contains precisely three IS_GLOBAL_BUILD reads.
# An unexpected class layout must fail before writing any ROM files.
if [[ "$rom_source" == "xiaomi_eu" && "$old_count" -ne 3 ]]; then
    error "EU FixDelayPowerMenu: expected 3 IS_GLOBAL_BUILD reads, got $old_count; source preserved"
    exit 1
fi
if (( old_count < 1 )); then
    error "FixDelayPowerMenu: no matching instruction; source preserved"
    exit 1
fi

sed -i "s|$search|$replacement|g" "$smali_file"
new_count_after="$(grep -Fc "$replacement" "$smali_file" || true)"
if grep -Fq "$search" "$smali_file" ||
   (( new_count_after - new_count_before != old_count )); then
    error "FixDelayPowerMenu: edited-smali verification failed"
    exit 1
fi

relative="${smali_file#"$patch_tmp/disasm/"}"
dex_name="${relative%%/*}"
java -jar "$sma" a --api "$sdkLevel" "$patch_tmp/disasm/$dex_name" \
    -o "$patch_tmp/$dex_name" >/dev/null || {
    error "FixDelayPowerMenu: failed to reassemble $dex_name"
    exit 1
}
[[ -s "$patch_tmp/$dex_name" ]] || { error "FixDelayPowerMenu: rebuilt DEX missing"; exit 1; }

# Verify rebuilt DEX independently, not just the intermediate smali text.
java -jar "$bak" d --api "$sdkLevel" "$patch_tmp/$dex_name" \
    -o "$patch_tmp/verified" >/dev/null || {
    error "FixDelayPowerMenu: rebuilt DEX failed validation"
    exit 1
}
mapfile -d '' -t verified < <(
    find "$patch_tmp/verified" -type f -name "$target_class" -print0
)
if (( ${#verified[@]} != 1 )); then
    error "FixDelayPowerMenu: rebuilt class missing or ambiguous"
    exit 1
fi
verified_old="$(grep -Fc "$search" "${verified[0]}" || true)"
verified_new="$(grep -Fc "$replacement" "${verified[0]}" || true)"
if (( verified_old != 0 || verified_new - new_count_before != old_count )); then
    error "FixDelayPowerMenu: rebuilt DEX did not preserve all $old_count changes"
    exit 1
fi

# Update only one DEX entry, retaining the other contents of the vendor JAR.
cp "$target_jar" "$patch_tmp/patched.jar"
(
    cd "$patch_tmp"
    zip -q -0 "patched.jar" "$dex_name"
)
zipalign -f 4 "$patch_tmp/patched.jar" "$patch_tmp/aligned.jar"
unzip -tq "$patch_tmp/aligned.jar" >/dev/null
if cmp -s "$target_jar" "$patch_tmp/aligned.jar"; then
    error "FixDelayPowerMenu: produced unchanged JAR"
    exit 1
fi

sudo cp -f "$patch_tmp/aligned.jar" "$target_jar"
patch "FixDelayPowerMenu: verified $old_count change(s) in $target_class [$rom_source]"
