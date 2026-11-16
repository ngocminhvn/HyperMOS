#!/usr/bin/env bash
# ==============================================================================
# Patch MiuiOsBuild_is_international_build in libhyper_os_system_public.so
# Allows HyperOS 4 Global apps (Weather, Gallery) to recognize international ROM
# without modifying ro.product.mod_device (which would break China MMS).
# Only runs on OS4 China builds.
# ==============================================================================
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"

identity="$work_dir/bin/ddevice"
rom_os="$(tr -d '\r\n' < "$identity/rom_os.txt" 2>/dev/null || true)"
rom_source="$(tr -d '\r\n' < "$identity/rom_source.txt" 2>/dev/null || true)"

if [[ "$rom_os" != "OS4" || "$rom_source" != "china" ]]; then
    mods "MiuiOsBuild_is_international_build: skip for rom_os=$rom_os rom_source=$rom_source (OS4 China only)"
    exit 0
fi

images="$work_dir/build/baserom/images"
module_dir="$work_dir/bin/modfile/UpdateFile/MiuiOsBuild_is_international_build"
patch_py="$module_dir/patch.py"

# Search for libhyper_os_system_public.so in system_ext/lib64
target_so=""
for candidate in \
    "$images/system_ext/lib64/libhyper_os_system_public.so" \
    "$work_dir/system_ext/lib64/libhyper_os_system_public.so"; do
    if [[ -f "$candidate" ]]; then
        target_so="$candidate"
        break
    fi
done

if [[ -z "$target_so" ]]; then
    # If not found directly, do a find under images
    target_so="$(find "$images" -type f -name "libhyper_os_system_public.so" 2>/dev/null | head -n 1 || true)"
fi

if [[ -z "$target_so" || ! -f "$target_so" ]]; then
    mods "MiuiOsBuild_is_international_build: libhyper_os_system_public.so not found, skipping"
    exit 0
fi

mods "MiuiOsBuild_is_international_build: patching $target_so"
python3 "$patch_py" "$target_so" || {
    error "MiuiOsBuild_is_international_build: patching failed"
    exit 1
}

mods "MiuiOsBuild_is_international_build: patch completed successfully"
