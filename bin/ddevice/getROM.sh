#!/bin/bash

baserom="$1"
work_dir=$(pwd)
source $work_dir/functions.sh
# Check whether it is a local package or a link
if [ ! -f "${baserom}" ] && [ "$(echo $baserom |grep http)" != "" ]; then
    info "Download link detected, starting a download..."
    # Detect SourceForge by actual URL host and project ZIP path, not a ROM
    # filename or a "sourceforge" substring. Works for CN and Xiaomi.eu ZIPs.
    # Empty output means non-SourceForge: leave their download path unchanged.
    sf_zip_name="$(python3 - "$baserom" <<'PY'
import re
import sys
from pathlib import PurePosixPath
from bin.dump.sourceforge_download import normalize

result = normalize(sys.argv[1])
if result is not None:
    name = PurePosixPath(result[2]).name
    # This build pipeline uses unquoted ZIP names in a few existing steps.
    # Reject exotic names here rather than risking path/glob interpretation.
    if not re.fullmatch(r"[A-Za-z0-9._+()-]+\.zip", name, flags=re.I):
        raise SystemExit("Invalid/unsafe SourceForge ROM ZIP filename")
    print(name)
PY
    )" || {
        error "Invalid SourceForge ROM download URL"
        return 1
    }

    if [[ -n "$sf_zip_name" ]]; then
        mkdir -p "$work_dir/build"
        info "SourceForge ROM detected: checking mirror speed; using automatic fallback if probes are blocked"
        python3 "$work_dir/bin/dump/sourceforge_download.py" \
            --url "$baserom" \
            --output "$work_dir/$sf_zip_name" \
            --report "$work_dir/build/sourceforge-mirror-report.json" || {
                error "SourceForge ROM download/ZIP verification failed"
                return 1
            }
        baserom="$sf_zip_name"
        # Only downloaded Xiaomi.eu ZIPs are disposable after extraction.
        if [[ "$baserom" == xiaomi.eu_* ]]; then
            eu_rom_downloaded=1
        fi
    elif [[ "$baserom" == *"xiaomi.eu_"* ]]; then
        # Preserve Xiaomi.eu ZIP filename (SourceForge URLs end with /download#).
        # Reuse the dump workflow's tested auto-mirror downloader.
        eu_basename=$(printf '%s\n' "$baserom" | grep -oE 'xiaomi[.]eu_[A-Za-z0-9._-]+[.]zip' | head -n 1)
        [[ -n "$eu_basename" && "$eu_basename" != */* ]] || {
            error "EU: unable to determine a safe ZIP filename from ROM URL"
            return 1
        }
        mkdir -p "$work_dir/build"
        python3 "$work_dir/bin/dump/sourceforge_download.py" \
            --url "$baserom" \
            --output "$work_dir/$eu_basename" \
            --report "$work_dir/build/eu-mirror-report.json" || {
                error "EU: source ZIP download failed"
                return 1
            }
        baserom="$eu_basename"
        eu_rom_downloaded=1
        info "EU source downloaded: $baserom"
    else
        # Leave the existing Xiaomi China/Global downloader unchanged.
        aria2c --max-download-limit=1024M --file-allocation=none -s16 -x16 -j"$(nproc)" -c -U "Mozilla/5.0" "${baserom}"
        baserom=$(basename ${baserom} | sed 's/\?t.*//')
        if [ -f $work_dir/topaz-ota_full-OS3.0.2.0.WMGCNXM-user-16.0-b487e82659.zip ]; then
            baserom="topaz-ota_full-OS3.0.2.0.WMGCNXM-user-16.0-b487e82659.zip"
            info "BASEROM: ${baserom}"
        elif [ -f $work_dir/munch-ota_full-OS2.0.215.0.VLMCNXM-user-15.0-7df6d5ee94.zip ]; then
            baserom="munch-ota_full-OS2.0.215.0.VLMCNXM-user-15.0-7df6d5ee94.zip"
            info "BASEROM: ${baserom}"
        elif [ ! -f "${baserom}" ]; then
            error "Download error!"
            return 1
        fi
    fi
elif [ -f "${baserom}" ]; then
    info "BASEROM: ${baserom}"
else
    error "BASEROM: Invalid parameter"
    exit
fi


# Get ROM Info
if [ "$(echo $baserom |grep miui_)" != "" ]; then
    device_code=$(basename $baserom |cut -d '_' -f 2)
    base_rom_code=$(echo "$baserom" | awk -F'_' '{print $3}')
elif [[ "${baserom##*/}" == xiaomi.eu_* ]]; then
    # xiaomi.eu_HAOTIAN_OS3.0.309.0.WOBCNXM_16_<hash>.zip
    # The codename is field 2, *not* field 3 (the version).
    eu_filename="${baserom##*/}"
    device_code=$(printf '%s\n' "$eu_filename" | cut -d '_' -f 2)
    base_rom_code=$(printf '%s\n' "$eu_filename" | cut -d '_' -f 3)
    if [[ ! "$device_code" =~ ^[A-Za-z0-9]+$ || ! "$base_rom_code" =~ ^(OS[0-9]|V1[34]) ]]; then
        error "EU: unexpected filename, cannot determine device/version: $eu_filename"
        return 1
    fi
elif [ "$(echo $baserom | grep -E '.*-ota_full-.*')" != "" ]; then
    device_code=$(basename $baserom | cut -d '-' -f 1)
    base_rom_code=$(basename $baserom | cut -d '-' -f 3)

    # Transform device_code
    device_code=$(echo $device_code | awk -F '_' '{
        if (NF == 1) {
            # If one part, e.g., shennong
            print toupper($1)
        } else if (NF == 2) {
            # If two parts, e.g., tapas_global
            print toupper($1) toupper(substr($2, 1, 1)) substr($2, 2)
        } else if (NF == 3) {
            # If three parts, e.g., houji_tw_global
            printf toupper($1) toupper($2) toupper(substr($3, 1, 1)) substr($3, 2)
        }
    }')
else
    device_code="YourDevice"
    base_rom_code="Unknown"
fi

device_f=$(echo $device_code | sed 's/\(Global\|EEAGlobal\|INGlobal\|IDGlobal\|RUGlobal\|TWGlobal\|TRGlobal\|JPGlobal\)$//' | tr '[:upper:]' '[:lower:]')

# Determine Device Type
info "Get Device Type"
if echo "$device_code" | grep -q 'EEAGlobal'; then
    DEVICE_TYPE="EEAGlobal"
elif echo "$device_code" | grep -q 'INGlobal'; then
    DEVICE_TYPE="INGlobal"
elif echo "$device_code" | grep -q 'IDGlobal'; then
    DEVICE_TYPE="IDGlobal"
elif echo "$device_code" | grep -q 'RUGlobal'; then
    DEVICE_TYPE="RUGlobal"
elif echo "$device_code" | grep -q 'JPGlobal'; then
    DEVICE_TYPE="JPGlobal"
elif echo "$device_code" | grep -q 'Global'; then
    DEVICE_TYPE="Global"
elif echo "$device_code" | grep -q 'TWGlobal'; then
    DEVICE_TYPE="TWGlobal"
elif echo "$device_code" | grep -q 'TRGlobal'; then
    DEVICE_TYPE="TRGlobal"
else
    DEVICE_TYPE="China"
fi

#Check MIUI or Hyper
if echo "$base_rom_code" | grep -q "OS1"; then
    ROM_OS="OS1"
elif echo "$base_rom_code" | grep -q "OS2"; then
    ROM_OS="OS2"
elif echo "$base_rom_code" | grep -q "OS3"; then
    ROM_OS="OS3"
elif echo "$base_rom_code" | grep -q "OS4"; then
    ROM_OS="OS4"
elif echo "$base_rom_code" | grep -q "V14"; then
    ROM_OS="MIUI"
elif echo "$base_rom_code" | grep -q "V13"; then
    ROM_OS="MIUI"
else
    echo "Unsupport ROM Exiting..."
    exit 1
fi

echo $base_rom_code > $work_dir/bin/ddevice/base_rom_code.txt
echo $base_rom_code > $work_dir/bin/ddevice/os_code.txt
echo $device_code > $work_dir/bin/ddevice/device_code.txt
echo $DEVICE_TYPE > $work_dir/bin/ddevice/device_type.txt
echo $ROM_OS > $work_dir/bin/ddevice/rom_os.txt

# Source identity is independent of regionTYPE (Xiaomi.eu often uses CNXM).
if [[ "${baserom##*/}" == xiaomi.eu_* ]]; then
    ROM_SOURCE="xiaomi_eu"
elif [[ "$DEVICE_TYPE" == "China" ]]; then
    ROM_SOURCE="china"
else
    ROM_SOURCE="other"
fi
printf '%s\n' "$ROM_SOURCE" > "$work_dir/bin/ddevice/rom_source.txt"
info "ROM source: $ROM_SOURCE | region: $DEVICE_TYPE | device: $device_code | version: $base_rom_code"


