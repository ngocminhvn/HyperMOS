#!/usr/bin/env bash

work_dir=$(pwd)
source "$work_dir/functions.sh"

RCLONE_CONFIG_GDRIVE="$work_dir/rclone.conf"

# Setup rclone config from private GitHub repository.
# Usage: uploadROM.sh setup <GH_TOKEN> <GH_REPO> <RCLONE_TOKEN_PATH>
if [ "${1:-}" = "setup" ]; then
    if [ -z "${2:-}" ] || [ -z "${3:-}" ] || [ -z "${4:-}" ]; then
        echo "[ERROR] - Usage: $0 setup <GH_TOKEN> <GH_REPO> <RCLONE_TOKEN_PATH>"
        exit 1
    fi

    GH_TOKEN="$2"
    GH_REPO="$3"
    RCLONE_TOKEN_PATH="$4"

    echo "Downloading rclone config from ${GH_REPO}/${RCLONE_TOKEN_PATH}..."
    curl --fail --silent --show-error --location \
        -H "Authorization: token ${GH_TOKEN}" \
        -H "Accept: application/vnd.github.v3.raw" \
        "https://api.github.com/repos/${GH_REPO}/contents/${RCLONE_TOKEN_PATH}" \
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

if ! rclone copy "$output_file" "$remote_path" \
    --config="$RCLONE_CONFIG_GDRIVE" \
    --progress \
    --stats=10s \
    --transfers=4 \
    --checkers=8 \
    --retries=5 \
    --low-level-retries=10; then
    upload "Error uploading file to Google Drive with rclone"
    exit 1
fi

upload "Upload to Google Drive completed"
upload "Clean Workflow.."
upload "Build ${os_type}_${polyxver} for ${device_code} successfull!"
