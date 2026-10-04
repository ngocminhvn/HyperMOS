#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

rom_os=$(cat "$work_dir/bin/ddevice/rom_os.txt")
MAIN_FOLDER="$work_dir/build/baserom/images"

BOOT_SOURCE="$work_dir/bin/modfile/UpdateFile/Boot/bootanimation.zip"
MEDIA_TARGET="$MAIN_FOLDER/product/media"
BOOT_TARGET="$MEDIA_TARGET/bootanimation.zip"

mods "Boot Animation"

case "$rom_os" in
    OS3|OS4)
        ;;
    *)
        mods "Boot Animation: $rom_os -> skipped"
        exit 0
        ;;
esac

if [[ ! -s "$BOOT_SOURCE" ]]; then
    error "Boot Animation: bootanimation.zip missing or empty"
    exit 1
fi

if ! unzip -tq "$BOOT_SOURCE" >/dev/null 2>&1; then
    error "Boot Animation: bootanimation.zip is not a valid ZIP"
    exit 1
fi

mkdir -p "$MEDIA_TARGET"

if ! cp -f "$BOOT_SOURCE" "$BOOT_TARGET"; then
    error "Boot Animation: failed to copy bootanimation.zip"
    exit 1
fi

chmod 0644 "$BOOT_TARGET"

if [[ ! -s "$BOOT_TARGET" ]]; then
    error "Boot Animation: installed bootanimation.zip missing or empty"
    exit 1
fi

if ! cmp -s "$BOOT_SOURCE" "$BOOT_TARGET"; then
    error "Boot Animation: copy verification failed"
    exit 1
fi

mods "Boot Animation -> product/media/bootanimation.zip Done"
