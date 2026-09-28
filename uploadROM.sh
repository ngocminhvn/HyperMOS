#!/usr/bin/env bash

work_dir=$(pwd)
source "$work_dir/functions.sh"

RCLONE_CONFIG_GDRIVE="$work_dir/rclone.conf"

# Setup rclone config from a direct URL.
# Usage: uploadROM.sh setup <RCLONE_TOKEN_PATH>
# Example: https://ngocminhvn.github.io/rclone.conf
if [ "${1:-}" = "setup" ]; then
    RCLONE_TOKEN_PATH="${2:-${RCLONE_TOKEN_PATH:-}}"

    if [ -z "$RCLONE_TOKEN_PATH" ]; then
        echo "[ERROR] - RCLONE_TOKEN_PATH URL is missing"
        exit 1
    fi

    case "$RCLONE_TOKEN_PATH" in
        http://*|https://*) ;;
        *)
            echo "[ERROR] - RCLONE_TOKEN_PATH must be a direct http(s) URL"
            exit 1
            ;;
    esac

    echo "Downloading rclone config from RCLONE_TOKEN_PATH..."
    curl --fail --silent --show-error --location \
        --retry 5 --retry-delay 2 --retry-all-errors \
        "$RCLONE_TOKEN_PATH" \
        -o "$RCLONE_CONFIG_GDRIVE"

    if [ ! -s "$RCLONE_CONFIG_GDRIVE" ]; then
        echo "[ERROR] - Cannot download a valid rclone.conf"
        exit 1
    fi

    if ! rclone listremotes --config="$RCLONE_CONFIG_GDRIVE" | grep -q ':$'; then
        echo "[ERROR] - rclone.conf does not contain any valid remote"
        exit 1
    fi

    echo "[OK] - rclone config is ready"
    exit 0
fi

if [ ! -s "$RCLONE_CONFIG_GDRIVE" ]; then
    echo "[ERROR] - Missing rclone config: $RCLONE_CONFIG_GDRIVE"
    echo "Run uploadROM.sh setup first."
    exit 1
fi

if ! command -v rclone >/dev/null 2>&1; then
    echo "[ERROR] - rclone is not installed"
    exit 1
fi

os_type=$(cat "$work_dir/bin/ddevice/os_type.txt")
base_rom_code=$(cat "$work_dir/bin/ddevice/base_rom_code.txt")
androidVER=$(cat "$work_dir/bin/ddevice/androidver.txt")
rom_os=$(cat "$work_dir/bin/ddevice/rom_os.txt")
regionTYPE=$(cat "$work_dir/bin/ddevice/device_type.txt")
device_code=$(cat "$work_dir/bin/ddevice/device_code.txt")
baserom_type=$(cat "$work_dir/bin/ddevice/romtype.txt")
device_f=$(cat "$work_dir/bin/ddevice/device_f.txt")

if [[ $(git branch --show-current) == "beta" ]]; then
    polyxver="$(cat Version)"
    status="Development"
else
    polyxver="$(cat Version)"
    status="Official"
fi

if [[ $rom_os == "MIUI" ]]; then
    os_type="MIUI"
else
    os_type="HyperOS"
fi

repack "Generating flashing script"
if [[ ${baserom_type} == 'payload' ]]; then
    mkdir -p "$work_dir/out/${os_type}_${device_code}_${base_rom_code}/images/"
    mkdir -p "$work_dir/out/${os_type}_${device_code}_${base_rom_code}/super/"
    mv -f "$work_dir/build/baserom/images/super.img" "$work_dir/out/${os_type}_${device_code}_${base_rom_code}/super/"
    mv -f "$work_dir/build/baserom/images/"*.img "$work_dir/out/${os_type}_${device_code}_${base_rom_code}/images/"
elif [[ ${baserom_type} == 'br' ]]; then
    mkdir -p "$work_dir/out/${os_type}_${device_code}_${base_rom_code}/images/"
    mkdir -p "$work_dir/out/${os_type}_${device_code}_${base_rom_code}/super/"
    mv -f "$work_dir/build/baserom/firmware-update/"* "$work_dir/out/${os_type}_${device_code}_${base_rom_code}/images/"
    mv -f "$work_dir/build/baserom/images/super.img" "$work_dir/out/${os_type}_${device_code}_${base_rom_code}/super/"
fi

cp -rf "$work_dir/bin/script2flash/cust.img" "$work_dir/out/${os_type}_${device_code}_${base_rom_code}/images/" 2>/dev/null || true
cp -rf "$work_dir/bin/script2flash/"*.install "$work_dir/out/${os_type}_${device_code}_${base_rom_code}/"

find "out/${os_type}_${device_code}_${base_rom_code}" -exec touch {} +
pushd "out/${os_type}_${device_code}_${base_rom_code}/" || exit 1
zip -r "${os_type}_${device_code}_${base_rom_code}.zip" ./*
mv "${os_type}_${device_code}_${base_rom_code}.zip" ../
popd || exit 1

hash=$(md5sum "out/${os_type}_${device_code}_${base_rom_code}.zip" | head -c 5)
final_name="${os_type}_${polyxver}_${device_code}_${base_rom_code}_${hash}_${status}.zip"
mv "out/${os_type}_${device_code}_${base_rom_code}.zip" "out/${final_name}"

repack "Build completed"
repack "Output: "
repack "$(pwd)/out/${final_name}"

upload "Uploading"
output_file="out/${final_name}"
echo "${final_name}" > "$work_dir/bin/ddevice/output_zip.txt"

if [[ $rom_os == "MIUI" ]]; then
    uploaddir="MIUI"
else
    uploaddir="HyperOS"
fi

# Upload to Google Drive directly with rclone.
# Use RCLONE_REMOTE if provided; otherwise use the first remote in rclone.conf.
RCLONE_REMOTE="${RCLONE_REMOTE:-$(rclone listremotes --config="$RCLONE_CONFIG_GDRIVE" | head -n1 | sed 's/:$//')}"

if [ -z "$RCLONE_REMOTE" ]; then
    upload "Error: no rclone remote found in rclone.conf"
    exit 1
fi

remote_path="${RCLONE_REMOTE}:${uploaddir}/${polyxver}/${device_code}/"

upload "Uploading to Google Drive with rclone..."
echo "[RCLONE] Remote: ${RCLONE_REMOTE}"
echo "[RCLONE] Destination: ${remote_path}"

RCLONE_EXTRA_ARGS=()
remote_type="$(rclone config show "$RCLONE_REMOTE" --config="$RCLONE_CONFIG_GDRIVE" 2>/dev/null | awk -F' = ' '/^type = / {print $2; exit}')"

# Optimized for a single large ROM archive (~8 GiB).
# Google Drive benefits from a larger resumable-upload chunk; one transfer avoids
# wasting RAM/connections when only one output ZIP is being uploaded.
if [ "$remote_type" = "drive" ]; then
    RCLONE_EXTRA_ARGS+=(--drive-chunk-size=256M)
fi

if ! rclone copyto "$output_file" "${remote_path}${final_name}" \
    --config="$RCLONE_CONFIG_GDRIVE" \
    --progress \
    --stats=10s \
    --stats-one-line \
    --transfers=1 \
    --checkers=4 \
    --buffer-size=128M \
    --retries=8 \
    --retries-sleep=10s \
    --low-level-retries=20 \
    --timeout=10m \
    --contimeout=30s \
    "${RCLONE_EXTRA_ARGS[@]}"; then
    upload "Error uploading file to Google Drive with rclone"
    exit 1
fi

download_url=""
if download_url="$(rclone link "${remote_path}${final_name}" --config="$RCLONE_CONFIG_GDRIVE" 2>/dev/null)" && [ -n "$download_url" ]; then
    echo "$download_url" > "$work_dir/bin/ddevice/download_url.txt"
    echo "[RCLONE] Download URL: $download_url"
    if [ -n "${GITHUB_ENV:-}" ]; then
        echo "RCLONE_DOWNLOAD_URL=$download_url" >> "$GITHUB_ENV"
    fi
else
    echo "[RCLONE] Remote does not provide a public link; Telegram will use the workflow fallback link."
fi

upload "Upload to Google Drive completed"
upload "Clean Workflow.."
upload "Build ${os_type}_${polyxver} for ${device_code} successfull!"
