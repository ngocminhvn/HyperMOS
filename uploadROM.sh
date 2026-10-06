#!/usr/bin/env bash

work_dir=$(pwd)
source "$work_dir/functions.sh"

RCLONE_CONFIG_GDRIVE="$work_dir/rclone.conf"


if [ "${1:-}" = "setup" ]; then
    RCLONE_TOKEN_PATH="${2:-${RCLONE_TOKEN_PATH:-}}"

    if [ -z "$RCLONE_TOKEN_PATH" ]; then
        echo "[ERROR] - RCLONE_TOKEN_PATH URL is missing"
        exit 1
    fi

    RCLONE_TOKEN_PATH="$(printf '%s' "$RCLONE_TOKEN_PATH" | xargs)"

    case "$RCLONE_TOKEN_PATH" in
        http://*|https://*) ;;
        //*) RCLONE_TOKEN_PATH="https:${RCLONE_TOKEN_PATH}" ;;
        *)   RCLONE_TOKEN_PATH="https://${RCLONE_TOKEN_PATH}" ;;
    esac

    echo "Downloading rclone config from: $RCLONE_TOKEN_PATH"
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

# Inspect the actual images destined for the ROM archive.
bash "$work_dir/bin/package/verify_boot_chain.sh" final \
    --images "$work_dir/out/${os_type}_${device_code}_${base_rom_code}/images" || exit 1
cp -a "$work_dir/build/boot-chain" "$work_dir/out/${os_type}_${device_code}_${base_rom_code}/boot-chain"

cp -rf "$work_dir/bin/script2flash/cust.img" "$work_dir/out/${os_type}_${device_code}_${base_rom_code}/images/" 2>/dev/null || true
cp -rf "$work_dir/bin/script2flash/"*.install "$work_dir/out/${os_type}_${device_code}_${base_rom_code}/"
cp -f "$work_dir/bin/script2flash/FLASH.bat" "$work_dir/out/${os_type}_${device_code}_${base_rom_code}/FLASH.bat"

# Bundle Windows fastboot runtime so the extracted ROM can be flashed immediately.
if [ -d "$work_dir/bin/script2flash/META-INF" ]; then
    cp -a "$work_dir/bin/script2flash/META-INF" "$work_dir/out/${os_type}_${device_code}_${base_rom_code}/META-INF"
fi

if [ ! -f "$work_dir/out/${os_type}_${device_code}_${base_rom_code}/META-INF/fastboot.exe" ]; then
    echo "[WARN] META-INF/fastboot.exe is missing from output package"
fi

find "out/${os_type}_${device_code}_${base_rom_code}" -exec touch {} +
if ! command -v 7zz >/dev/null 2>&1; then
    echo "[ERROR] 7zz is required for multi-threaded ROM ZIP packaging"
    exit 1
fi
pushd "out/${os_type}_${device_code}_${base_rom_code}/" || exit 1
archive="${os_type}_${device_code}_${base_rom_code}.zip"
rm -f "$archive"
echo "[REPACK] - Creating ROM ZIP with 7zz (Deflate, mx=1, multithreaded)"
7zz a -tzip -mx=1 -mmt=on "$archive" ./*
mv "$archive" ../
popd || exit 1

# Build output filename:
# ROM_HAOTIAN_OS3.0.309.0.WOBCNXM_EU290926.zip
device_name="$(echo "$device_f" | tr '[:lower:]' '[:upper:]' | tr -cd 'A-Z0-9_-')"

case "$regionTYPE" in
    EEAGlobal|EEA|EU) region_short="EU" ;;
    INGlobal|IN)      region_short="IN" ;;
    IDGlobal|ID)      region_short="ID" ;;
    RUGlobal|RU)      region_short="RU" ;;
    TWGlobal|TW)      region_short="TW" ;;
    TRGlobal|TR)      region_short="TR" ;;
    JPGlobal|JP)      region_short="JP" ;;
    Global|GLOBAL)    region_short="GLOBAL" ;;
    China|CN)         region_short="CN" ;;
    *)                region_short="$(echo "$regionTYPE" | tr '[:lower:]' '[:upper:]' | tr -cd 'A-Z0-9')" ;;
esac

build_date="$(date +%d%m%y)"
# Debug builds use the GitHub Actions run number instead of HHMM.
# Example: ROM_HAOTIAN_OS3.0.308.0.WOBCNXM_CN041026_#50.zip
# Normal builds keep the existing filename without a debug suffix.
if [[ "${DEBUG_BUILD:-false}" == "true" ]]; then
    build_number="${GITHUB_RUN_NUMBER:-local}"
    final_name="ROM_${device_name}_${base_rom_code}_${region_short}${build_date}_#${build_number}.zip"
else
    final_name="ROM_${device_name}_${base_rom_code}_${region_short}${build_date}.zip"
fi

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

UPLOAD_METHOD="${UPLOAD_METHOD:-drive}"
echo "[UPLOAD] Method: $UPLOAD_METHOD"

if [ "$UPLOAD_METHOD" = "pixeldrain" ]; then
    upload "ROM package is ready for Pixeldrain upload"
    echo "$output_file" > "$work_dir/bin/ddevice/output_file.txt"
    upload "Build ${os_type}_${polyxver} for ${device_code} packaged successfully!"
    exit 0
fi

if [ "$UPLOAD_METHOD" != "drive" ]; then
    upload "Error: unsupported UPLOAD_METHOD=$UPLOAD_METHOD"
    exit 1
fi

if [ ! -s "$RCLONE_CONFIG_GDRIVE" ]; then
    upload "Error: missing rclone config: $RCLONE_CONFIG_GDRIVE"
    exit 1
fi

if ! command -v rclone >/dev/null 2>&1; then
    upload "Error: rclone is not installed"
    exit 1
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
