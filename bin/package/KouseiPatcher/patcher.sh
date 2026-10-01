#!/usr/bin/env bash
set -euo pipefail

# SPDX-License-Identifier: GPL-3.0

work_dir=$(pwd)
patcher_dir="$work_dir/bin/package/KouseiPatcher"
sdkLevel=$(tr -d ' \r\n' < "$work_dir/bin/ddevice/sdkLevel.txt")

baksmali="$work_dir/bin/apktool/baksmaliv2.jar"
smali="$work_dir/bin/apktool/smaliv2.jar"
toolbox_py="$patcher_dir/toolbox.py"
a17_patch_py="$patcher_dir/a17_patcher.py"
hide_apps_legacy_py="$patcher_dir/hide_apps/a13_16.py"
hide_apps_a17_py="$patcher_dir/hide_apps/a17.py"
driver_dex="$patcher_dir/classes.dex"

if [[ ! "$sdkLevel" =~ ^[0-9]+$ ]]; then
    echo "Invalid sdkLevel: $sdkLevel"
    exit 1
fi

if (( sdkLevel >= 37 )); then
    hide_apps_py="$hide_apps_a17_py"
    hide_apps_hook="shouldHideAppListForCaller(ILjava/lang/String;I)Z"
else
    hide_apps_py="$hide_apps_legacy_py"
    hide_apps_hook="shouldHideAppListForCaller(ILandroid/content/ContentResolver;Ljava/lang/String;I)Z"
fi

for required in "$baksmali" "$smali" "$toolbox_py" "$driver_dex" "$hide_apps_py"; do
    if [[ ! -f "$required" ]]; then
        echo "Missing required file: $required"
        exit 1
    fi
done

if (( sdkLevel >= 37 )) && [[ ! -f "$a17_patch_py" ]]; then
    echo "Missing Android 17 patcher: $a17_patch_py"
    exit 1
fi

temp_root="$work_dir/jar_temp/kousei"
rm -rf "$temp_root"
mkdir -p "$temp_root"

cleanup() {
    rm -rf "$temp_root"
}
trap cleanup EXIT

run_baksmali() {
    local dex="$1"
    local out="$2"
    rm -rf "$out"
    mkdir -p "$(dirname "$out")"
    java -jar "$baksmali" d --api "$sdkLevel" "$dex" -o "$out"
}

run_smali() {
    local src="$1"
    local out="$2"
    rm -f "$out"
    mkdir -p "$(dirname "$out")"
    java -jar "$smali" a --api "$sdkLevel" "$src" -o "$out"
    [[ -s "$out" ]]
}

find_jar() {
    local name="$1"
    local preferred="$work_dir/build/baserom/images/system/system/framework/$name"

    if [[ -f "$preferred" ]]; then
        printf '%s\n' "$preferred"
        return 0
    fi

    local found
    found=$(find "$work_dir/build/baserom/images" -type f -name "$name" | head -n 1)
    if [[ -z "$found" ]]; then
        echo "Cannot find $name" >&2
        return 1
    fi
    printf '%s\n' "$found"
}

contains_name() {
    local needle="$1"
    shift
    local item
    for item in "$@"; do
        [[ "$item" == "$needle" ]] && return 0
    done
    return 1
}

collect_and_disassemble() {
    local unpacked="$1"
    local smali_root="$2"
    shift 2
    local targets=("$@")
    local dex base rel owner
    local all_dexes=()

    MODIFIED_DEXES=()
    rm -rf "$smali_root"
    mkdir -p "$smali_root"

    # Disassemble every stock DEX for reliable class ownership discovery,
    # but only owner DEXes are reassembled later.
    shopt -s nullglob
    for dex in "$unpacked"/classes*.dex; do
        base=$(basename "$dex")
        all_dexes+=("$base")
        run_baksmali "$dex" "$smali_root/$base.out"
    done
    shopt -u nullglob

    if (( ${#all_dexes[@]} == 0 )); then
        echo "No classes*.dex found in JAR" >&2
        return 1
    fi

    for rel in "${targets[@]}"; do
        local matches=()
        for base in "${all_dexes[@]}"; do
            if [[ -f "$smali_root/$base.out/$rel" ]]; then
                matches+=("$base")
            fi
        done

        if (( ${#matches[@]} != 1 )); then
            echo "Expected exactly one owner DEX for $rel; found ${#matches[@]}" >&2
            return 1
        fi

        owner="${matches[0]}"
        if ! contains_name "$owner" "${MODIFIED_DEXES[@]}"; then
            MODIFIED_DEXES+=("$owner")
        fi
        echo "Kaorios target $rel -> $owner"
    done
}
add_modified_owner_for_hook() {
    local smali_root="$1"
    local hook="$2"
    local matches=()
    local file rel owner_dir owner

    while IFS= read -r file; do
        [[ -n "$file" ]] && matches+=("$file")
    done < <(grep -rlF --include='*.smali' -- "$hook" "$smali_root" || true)

    if (( ${#matches[@]} != 1 )); then
        echo "Expected exactly one patched Hide Installed Apps hook; found ${#matches[@]}" >&2
        return 1
    fi

    rel="${matches[0]#"$smali_root"/}"
    owner_dir="${rel%%/*}"

    if [[ ! "$owner_dir" =~ ^classes([0-9]*)\.dex\.out$ ]]; then
        echo "Cannot resolve owner DEX from $owner_dir" >&2
        return 1
    fi

    owner="${owner_dir%.out}"
    if ! contains_name "$owner" "${MODIFIED_DEXES[@]}"; then
        MODIFIED_DEXES+=("$owner")
    fi

    echo "Hide Installed Apps -> $owner"
}

reassemble_modified() {
    local smali_root="$1"
    local unpacked="$2"
    local rebuilt_root="$3"
    local dex

    mkdir -p "$rebuilt_root"

    for dex in "${MODIFIED_DEXES[@]}"; do
        run_smali "$smali_root/$dex.out" "$rebuilt_root/$dex"
        mv -f "$rebuilt_root/$dex" "$unpacked/$dex"
    done
}

verify_driver_dex() {
    local verify_root="$temp_root/driver_verify"
    run_baksmali "$driver_dex" "$verify_root"

    local hook="$verify_root/android/security/kaorios/KaoriosHook.smali"
    if [[ ! -f "$hook" ]]; then
        echo "KaoriosHook.smali not found in classes.dex"
        exit 1
    fi

    local required=(
        "initContext(Landroid/content/Context;)V"
        "hasSystemFeature(Ljava/lang/String;I)Ljava/lang/Boolean;"
        "initGenerateSoftwareKeyPair(Ljava/lang/Object;)Ljava/security/KeyPair;"
        "CertificateChainIfNeeded([Ljava/security/cert/Certificate;)[Ljava/security/cert/Certificate;"
        "shouldHideDevStatusFromNameValueCache(Landroid/content/ContentResolver;Ljava/lang/String;I)Z"
        "initSystemServer()V"
        "$hide_apps_hook"
    )

    if (( sdkLevel >= 37 )); then
        required+=("initActivityThread(Ljava/lang/Object;)V")
    fi

    local sig
    for sig in "${required[@]}"; do
        if ! grep -Fq -- "$sig" "$hook"; then
            echo "Kaorios classes.dex missing required hook: $sig"
            exit 1
        fi
    done

    echo "Kaorios driver verifier: PASS"
}

append_driver_dex() {
    local unpacked="$1"
    local smali_root="$2"
    local dex

    # Refuse only an actual KaoriosHook class definition, not ordinary references.
    if find "$smali_root" -type f -path "*/android/security/kaorios/KaoriosHook.smali" -print -quit | grep -q .; then
        echo "KaoriosHook class already exists in stock framework; refusing duplicate class"
        exit 1
    fi

    local max=0
    local base num
    shopt -s nullglob
    for dex in "$unpacked"/classes*.dex; do
        base=$(basename "$dex")
        if [[ "$base" == "classes.dex" ]]; then
            num=1
        elif [[ "$base" =~ ^classes([0-9]+)\.dex$ ]]; then
            num="${BASH_REMATCH[1]}"
        else
            continue
        fi
        (( num > max )) && max=$num
    done
    shopt -u nullglob

    local next=$((max + 1))
    local name="classes${next}.dex"
    cp -f "$driver_dex" "$unpacked/$name"
    echo "Kaorios driver -> $name"
}
verify_reassembled_framework() {
    local unpacked="$1"
    local verify_root="$temp_root/framework_verify"
    local dex

    rm -rf "$verify_root"
    mkdir -p "$verify_root"

    for dex in "${MODIFIED_DEXES[@]}"; do
        run_baksmali "$unpacked/$dex" "$verify_root/$dex.out"
    done

    python3 "$toolbox_py" "$verify_root" --verify-framework

    if (( sdkLevel >= 37 )); then
        local activity
        activity=$(find "$verify_root" -type f -path "*/android/app/ActivityThread.smali" | head -n 1)
        if [[ -z "$activity" ]] || ! grep -Fq -- "KaoriosHook;->initActivityThread(Ljava/lang/Object;)V" "$activity"; then
            echo "Android 17 ActivityThread verification failed"
            exit 1
        fi
    fi
}

verify_reassembled_services() {
    local unpacked="$1"
    local verify_root="$temp_root/services_verify"
    local dex

    rm -rf "$verify_root"
    mkdir -p "$verify_root"

    for dex in "${MODIFIED_DEXES[@]}"; do
        run_baksmali "$unpacked/$dex" "$verify_root/$dex.out"
    done

    if (( sdkLevel >= 37 )); then
        local ss
        ss=$(find "$verify_root" -type f -path "*/com/android/server/SystemServer.smali" | head -n 1)
        if [[ -z "$ss" ]] || ! grep -Fq -- "KaoriosHook;->initSystemServer()V" "$ss"; then
            echo "Android 17 SystemServer hook missing"
            exit 1
        fi
        if ! python3 - "$ss" <<'PY'
from pathlib import Path
import sys
text = Path(sys.argv[1]).read_text(encoding="utf-8")
h = text.find("KaoriosHook;->initSystemServer()V")
l = text.find("Landroid/os/Looper;->loop()V")
raise SystemExit(0 if h >= 0 and l >= 0 and h < l else 1)
PY
        then
            echo "Android 17 SystemServer hook is not before Looper.loop()"
            exit 1
        fi
        echo "Kaorios Android 17 services verifier: PASS"
    else
        python3 "$toolbox_py" "$verify_root" --verify-services
    fi

    python3 "$hide_apps_py" "$verify_root" --verify
}

pack_jar() {
    local unpacked="$1"
    local output="$2"
    local name="$3"
    local candidate="$temp_root/${name}.candidate.jar"
    local aligned="$temp_root/${name}.aligned.jar"

    rm -f "$candidate" "$aligned"
    (
        cd "$unpacked"
        7za a -tzip -mx=0 "$candidate" . >/dev/null
    )
    unzip -tq "$candidate" >/dev/null
    zipalign -f 4 "$candidate" "$aligned"
    sudo cp -f "$aligned" "$output"
}

patch_framework() {
    local jar
    jar=$(find_jar "framework.jar")
    local root="$temp_root/framework"
    local unpacked="$root/unpacked"
    local smali_root="$root/smali"
    local rebuilt="$root/rebuilt"

    rm -rf "$root"
    mkdir -p "$unpacked"
    unzip -q "$jar" -d "$unpacked"

    local targets=(
        "android/app/Instrumentation.smali"
        "android/app/ApplicationPackageManager.smali"
        "android/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi.smali"
        "android/security/keystore2/AndroidKeyStoreSpi.smali"
        "android/provider/Settings\$NameValueCache.smali"
    )

    if (( sdkLevel >= 37 )); then
        targets+=(
            "android/app/ActivityThread.smali"
            "android/os/Build.smali"
            "android/os/Build\$VERSION.smali"
        )
    fi

    collect_and_disassemble "$unpacked" "$smali_root" "${targets[@]}"

    python3 "$toolbox_py" "$smali_root" --framework

    if (( sdkLevel >= 37 )); then
        python3 "$a17_patch_py" "$smali_root" --framework
    fi

    reassemble_modified "$smali_root" "$unpacked" "$rebuilt"
    verify_reassembled_framework "$unpacked"
    append_driver_dex "$unpacked" "$smali_root"
    pack_jar "$unpacked" "$jar" "framework"

    echo "framework.jar: rebuilt only owner DEXes: ${MODIFIED_DEXES[*]}"
}

patch_services() {
    local jar
    jar=$(find_jar "services.jar")
    local root="$temp_root/services"
    local unpacked="$root/unpacked"
    local smali_root="$root/smali"
    local rebuilt="$root/rebuilt"

    rm -rf "$root"
    mkdir -p "$unpacked"
    unzip -q "$jar" -d "$unpacked"

    local targets=(
        "com/android/server/SystemServer.smali"
    )

    collect_and_disassemble "$unpacked" "$smali_root" "${targets[@]}"

    if (( sdkLevel >= 37 )); then
        python3 "$a17_patch_py" "$smali_root" --services
    else
        python3 "$toolbox_py" "$smali_root" --services
    fi

    # Hide Installed Apps is version-split because A13-16 and A17 use
    # different Package Manager classes and different Kaorios hook ABIs.
    python3 "$hide_apps_py" "$smali_root"
    add_modified_owner_for_hook "$smali_root" "$hide_apps_hook"

    reassemble_modified "$smali_root" "$unpacked" "$rebuilt"
    verify_reassembled_services "$unpacked"
    pack_jar "$unpacked" "$jar" "services"

    echo "services.jar: rebuilt only owner DEXes: ${MODIFIED_DEXES[*]}"
}

echo "Kaorios surgical patch mode: SDK $sdkLevel"
verify_driver_dex
patch_framework
patch_services
echo "Kaorios patch complete"
