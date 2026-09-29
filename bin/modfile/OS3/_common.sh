#!/usr/bin/env bash

work_dir=${work_dir:-$(pwd)}
source "$work_dir/functions.sh"

OS3_MOD_CACHE="$work_dir/build/os3_modscenter"
OS3_IMAGES="$work_dir/build/baserom/images"
MODSCENTER_ARCHIVE=""
MODSCENTER_TAG=""

modscenter_remove_named_dirs() {
    local root="$1"
    shift
    local name path
    for name in "$@"; do
        while IFS= read -r -d '' path; do
            mods "Remove stock/staged dir: $path"
            rm -rf "$path"
        done < <(find "$root" -type d -name "$name" -prune -print0 2>/dev/null)
    done
}

modscenter_resolve_latest() {
    local repo="$1"

    python3 - "$repo" <<'PY'
import json
import sys
import urllib.request

repo = sys.argv[1]
api = f"https://api.github.com/repos/{repo}/releases/latest"
req = urllib.request.Request(api, headers={
    "Accept": "application/vnd.github+json",
    "User-Agent": "HyperMOS-OS3-ModsCenter"
})

with urllib.request.urlopen(req, timeout=30) as r:
    data = json.load(r)

assets = [
    a for a in data.get("assets", [])
    if str(a.get("name", "")).lower().endswith(".zip")
]

if not assets:
    raise SystemExit("No ZIP release asset found")

asset = assets[0]
tag = str(data.get("tag_name", "latest"))
url = str(asset.get("browser_download_url", ""))
digest = str(asset.get("digest") or "")
name = str(asset.get("name") or "module.zip")

if not url:
    raise SystemExit("Release asset has no download URL")

if digest.startswith("sha256:"):
    digest = digest.split(":", 1)[1]
else:
    digest = ""

print(tag)
print(url)
print(digest)
print(name)
PY
}

modscenter_download_latest() {
    local label="$1"
    local repo="$2"

    local meta url sha256 asset_name archive safe_tag
    local -a release_meta

    if ! meta=$(modscenter_resolve_latest "$repo"); then
        error "$label: cannot resolve latest GitHub release"
        return 1
    fi

    mapfile -t release_meta <<< "$meta"
    MODSCENTER_TAG="${release_meta[0]:-}"
    url="${release_meta[1]:-}"
    sha256="${release_meta[2]:-}"
    asset_name="${release_meta[3]:-module.zip}"

    if [[ -z "$MODSCENTER_TAG" || -z "$url" ]]; then
        error "$label: invalid latest release metadata"
        return 1
    fi

    safe_tag=$(printf '%s' "$MODSCENTER_TAG" | tr -cd 'A-Za-z0-9._-')
    archive="$OS3_MOD_CACHE/${repo//\//_}-${safe_tag}.zip"
    mkdir -p "$OS3_MOD_CACHE"

    if [[ -s "$archive" ]]; then
        if [[ -n "$sha256" ]]; then
            if printf '%s  %s\n' "$sha256" "$archive" | sha256sum -c - >/dev/null 2>&1; then
                MODSCENTER_ARCHIVE="$archive"
                mods "$label: latest $MODSCENTER_TAG (cached, SHA256 OK)"
                return 0
            fi
        else
            MODSCENTER_ARCHIVE="$archive"
            mods "$label: latest $MODSCENTER_TAG (cached, no upstream digest)"
            return 0
        fi
    fi

    rm -f "$archive"
    mods "$label: latest release $MODSCENTER_TAG -> $asset_name"

    if ! aria2c -q --allow-overwrite=true --auto-file-renaming=false --file-allocation=none -x8 -s8 \
        -d "$(dirname "$archive")" -o "$(basename "$archive")" "$url"; then
        error "$label: download failed"
        return 1
    fi

    if [[ -n "$sha256" ]]; then
        if ! printf '%s  %s\n' "$sha256" "$archive" | sha256sum -c - >/dev/null 2>&1; then
            rm -f "$archive"
            error "$label: SHA256 mismatch for $MODSCENTER_TAG"
            return 1
        fi
        mods "$label: SHA256 verified"
    else
        mods "$label: warning - latest asset has no SHA256 digest from GitHub"
    fi

    MODSCENTER_ARCHIVE="$archive"
    return 0
}

modscenter_unpack_latest() {
    local label="$1"
    local repo="$2"
    local extract_dir="$3"

    modscenter_download_latest "$label" "$repo" || return 1

    rm -rf "$extract_dir"
    mkdir -p "$extract_dir"
    if ! unzip -q "$MODSCENTER_ARCHIVE" -d "$extract_dir"; then
        error "$label: unzip failed"
        return 1
    fi
}

modscenter_module_root() {
    local extract_dir="$1"
    local module_prop
    module_prop=$(find "$extract_dir" -type f -name module.prop -print -quit 2>/dev/null)
    if [[ -n "$module_prop" ]]; then
        dirname "$module_prop"
    else
        printf '%s\n' "$extract_dir"
    fi
}

modscenter_extract_native_libs() {
    local label="$1"
    local apk="$2"
    local app_dir="$3"
    local required="$4"

    local apk_abi rom_abi entry out count=0
    local -a entries

    for mapping in "arm64-v8a:arm64" "armeabi-v7a:arm"; do
        apk_abi="${mapping%%:*}"
        rom_abi="${mapping##*:}"
        mapfile -t entries < <(unzip -Z1 "$apk" 2>/dev/null | grep -E "^lib/${apk_abi}/[^/]+[.]so$" || true)

        if [[ ${#entries[@]} -eq 0 ]]; then
            continue
        fi

        mkdir -p "$app_dir/lib/$rom_abi"
        for entry in "${entries[@]}"; do
            out="$app_dir/lib/$rom_abi/$(basename "$entry")"
            if ! unzip -p "$apk" "$entry" > "$out"; then
                rm -f "$out"
                error "$label: failed extracting native lib $entry"
                return 1
            fi
            chmod 0644 "$out"
            count=$((count + 1))
        done
    done

    if [[ "$required" == "1" && "$count" -eq 0 ]]; then
        error "$label: latest APK contains no arm/arm64 native .so files; refusing incomplete ROM layout"
        return 1
    fi

    mods "$label: extracted $count native libraries from latest APK"
    return 0
}

modscenter_stage_permission() {
    local label="$1"
    local module_root="$2"
    local stage_root="$3"
    local permission_name="$4"

    [[ -n "$permission_name" && "$permission_name" != "-" ]] || return 0

    local src=""
    src=$(find "$module_root" -type f -name "$permission_name" -print -quit 2>/dev/null || true)

    if [[ -z "$src" ]]; then
        src=$(find "$OS3_IMAGES" -type f -name "$permission_name" -print -quit 2>/dev/null || true)
    fi

    if [[ -z "$src" ]]; then
        error "$label: required permission XML not found: $permission_name"
        return 1
    fi

    mkdir -p "$stage_root/product/etc/permissions"
    cp -a "$src" "$stage_root/product/etc/permissions/$permission_name" || {
        error "$label: failed staging $permission_name"
        return 1
    }

    mods "$label: staged permission $permission_name"
}

modscenter_copy_system_tree() {
    local label="$1"
    local system_root="$2"
    local entry base target
    local logical_parts="product system_ext vendor odm mi_ext mi_product product_dlkm system_dlkm vendor_dlkm odm_dlkm"

    [[ -d "$system_root" ]] || {
        error "$label: staged system tree missing"
        return 1
    }

    while IFS= read -r -d '' entry; do
        base=$(basename "$entry")
        case " $logical_parts " in
            *" $base "*)
                target="$OS3_IMAGES/$base"
                mkdir -p "$target"
                cp -a "$entry/." "$target/" || return 1
                ;;
            *)
                target="$OS3_IMAGES/system/system"
                mkdir -p "$target"
                cp -a "$entry" "$target/" || return 1
                ;;
        esac
    done < <(find "$system_root" -mindepth 1 -maxdepth 1 -print0)
}

modscenter_apply_privapp() {
    local label="$1"
    local repo="$2"
    local expected_apk="$3"
    local target_dir_name="$4"
    local target_apk_name="$5"
    local permission_name="$6"
    local require_native_libs="$7"
    shift 7

    local extract_dir="$OS3_MOD_CACHE/extract-${repo##*/}"
    local stage_root="$OS3_MOD_CACHE/stage-${repo##*/}"
    local module_root system_root source_apk target_dir

    modscenter_unpack_latest "$label" "$repo" "$extract_dir" || return 1
    module_root=$(modscenter_module_root "$extract_dir")

    source_apk=$(find "$module_root" -type f -iname "$expected_apk" -print -quit 2>/dev/null || true)
    if [[ -z "$source_apk" ]]; then
        error "$label: expected APK '$expected_apk' not found in latest release"
        rm -rf "$extract_dir"
        return 1
    fi

    rm -rf "$stage_root"
    mkdir -p "$stage_root"

    system_root="$module_root/system"
    if [[ -d "$system_root" ]]; then
        cp -a "$system_root/." "$stage_root/" || {
            error "$label: failed staging upstream system tree"
            rm -rf "$extract_dir" "$stage_root"
            return 1
        }
    fi

    # Normalize the app itself to the same ROM layout used by HalcyonOS.
    modscenter_remove_named_dirs "$stage_root" "$@"
    target_dir="$stage_root/product/priv-app/$target_dir_name"
    mkdir -p "$target_dir"
    cp -a "$source_apk" "$target_dir/$target_apk_name" || {
        error "$label: failed staging latest APK"
        rm -rf "$extract_dir" "$stage_root"
        return 1
    }

    modscenter_extract_native_libs "$label" "$target_dir/$target_apk_name" "$target_dir" "$require_native_libs" || {
        rm -rf "$extract_dir" "$stage_root"
        return 1
    }

    modscenter_stage_permission "$label" "$module_root" "$stage_root" "$permission_name" || {
        rm -rf "$extract_dir" "$stage_root"
        return 1
    }

    modscenter_remove_named_dirs "$OS3_IMAGES" "$@"
    modscenter_copy_system_tree "$label" "$stage_root" || {
        error "$label: failed copying staged tree into ROM"
        rm -rf "$extract_dir" "$stage_root"
        return 1
    }

    rm -rf "$extract_dir" "$stage_root"
    mods "$label: integrated latest $MODSCENTER_TAG with Halcyon-style APK/lib/permissions layout"
}

modscenter_replace_existing_apk() {
    local label="$1"
    local repo="$2"
    local expected_apk="$3"
    local target_dir_name="$4"
    local target_apk_name="$5"

    local extract_dir="$OS3_MOD_CACHE/extract-${repo##*/}"
    local module_root source_apk target_dir

    modscenter_unpack_latest "$label" "$repo" "$extract_dir" || return 1
    module_root=$(modscenter_module_root "$extract_dir")

    source_apk=$(find "$module_root" -type f -iname "$expected_apk" -print -quit 2>/dev/null || true)
    if [[ -z "$source_apk" ]]; then
        error "$label: expected APK '$expected_apk' not found in latest release"
        rm -rf "$extract_dir"
        return 1
    fi

    target_dir=$(find "$OS3_IMAGES" -type d -name "$target_dir_name" -print -quit 2>/dev/null || true)
    if [[ -z "$target_dir" ]]; then
        error "$label: stock target directory '$target_dir_name' not found"
        rm -rf "$extract_dir"
        return 1
    fi

    rm -f "$target_dir"/*.apk
    cp -a "$source_apk" "$target_dir/$target_apk_name" || {
        error "$label: failed replacing APK"
        rm -rf "$extract_dir"
        return 1
    }

    rm -rf "$extract_dir"
    mods "$label: replaced stock APK with latest $MODSCENTER_TAG"
}
