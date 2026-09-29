#!/usr/bin/env bash

work_dir=${work_dir:-$(pwd)}
source "$work_dir/functions.sh"

OS3_MOD_CACHE="$work_dir/build/os3_modscenter"
OS3_IMAGES="$work_dir/build/baserom/images"

modscenter_remove_stock_dirs() {
    local name path
    for name in "$@"; do
        while IFS= read -r -d '' path; do
            mods "Remove stock: $path"
            rm -rf "$path"
        done < <(find "$OS3_IMAGES" -type d -name "$name" -prune -print0 2>/dev/null)
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

    local meta tag url sha256 asset_name archive safe_tag
    if ! meta=$(modscenter_resolve_latest "$repo"); then
        error "$label: cannot resolve latest GitHub release"
        return 1
    fi

    mapfile -t release_meta <<< "$meta"
    tag="${release_meta[0]:-}"
    url="${release_meta[1]:-}"
    sha256="${release_meta[2]:-}"
    asset_name="${release_meta[3]:-module.zip}"

    if [[ -z "$tag" || -z "$url" ]]; then
        error "$label: invalid latest release metadata"
        return 1
    fi

    safe_tag=$(printf '%s' "$tag" | tr -cd 'A-Za-z0-9._-')
    archive="$OS3_MOD_CACHE/${repo//\//_}-${safe_tag}.zip"
    mkdir -p "$OS3_MOD_CACHE"

    if [[ -s "$archive" ]]; then
        if [[ -n "$sha256" ]]; then
            if printf '%s  %s\n' "$sha256" "$archive" | sha256sum -c - >/dev/null 2>&1; then
                mods "$label: latest $tag (cached)"
                printf '%s\n' "$archive"
                return 0
            fi
        else
            mods "$label: latest $tag (cached, no upstream digest)"
            printf '%s\n' "$archive"
            return 0
        fi
    fi

    rm -f "$archive"
    mods "$label: latest release $tag -> $asset_name"

    if ! aria2c -q --allow-overwrite=true --auto-file-renaming=false --file-allocation=none -x8 -s8 \
        -d "$(dirname "$archive")" -o "$(basename "$archive")" "$url"; then
        error "$label: download failed"
        return 1
    fi

    if [[ -n "$sha256" ]]; then
        if ! printf '%s  %s\n' "$sha256" "$archive" | sha256sum -c - >/dev/null 2>&1; then
            rm -f "$archive"
            error "$label: SHA256 mismatch for $tag"
            return 1
        fi
        mods "$label: SHA256 verified"
    else
        mods "$label: warning - latest asset has no SHA256 digest from GitHub"
    fi

    printf '%s\n' "$archive"
    return 0
}

modscenter_copy_system_tree() {
    local label="$1"
    local system_root="$2"
    local entry base target
    local logical_parts="product system_ext vendor odm mi_ext mi_product product_dlkm system_dlkm vendor_dlkm odm_dlkm"

    [[ -d "$system_root" ]] || {
        error "$label: module has no system/ tree"
        return 1
    }

    while IFS= read -r -d '' entry; do
        base=$(basename "$entry")
        case " $logical_parts " in
            *" $base "*)
                target="$OS3_IMAGES/$base"
                mkdir -p "$target"
                if ! cp -a "$entry/." "$target/"; then
                    error "$label: failed to copy logical partition $base"
                    return 1
                fi
                ;;
            *)
                target="$OS3_IMAGES/system/system"
                mkdir -p "$target"
                if ! cp -a "$entry" "$target/"; then
                    error "$label: failed to copy /system/$base"
                    return 1
                fi
                ;;
        esac
    done < <(find "$system_root" -mindepth 1 -maxdepth 1 -print0)

    return 0
}

modscenter_apply_module() {
    local label="$1"
    local repo="$2"
    local expected_apk="$3"
    shift 3

    local archive extract_dir module_prop module_root system_root apk

    archive=$(modscenter_download_latest "$label" "$repo") || return 1
    extract_dir="$OS3_MOD_CACHE/extract-${repo##*/}"

    rm -rf "$extract_dir"
    mkdir -p "$extract_dir"

    if ! unzip -q "$archive" -d "$extract_dir"; then
        error "$label: unzip failed"
        return 1
    fi

    module_prop=$(find "$extract_dir" -type f -name module.prop -print -quit 2>/dev/null)
    if [[ -n "$module_prop" ]]; then
        module_root=$(dirname "$module_prop")
    else
        module_root="$extract_dir"
    fi

    system_root="$module_root/system"
    apk=$(find "$system_root" -type f -iname "$expected_apk" -print -quit 2>/dev/null)

    if [[ -z "$apk" ]]; then
        error "$label: expected APK '$expected_apk' not found in latest module"
        rm -rf "$extract_dir"
        return 1
    fi

    mods "$label: source APK $(basename "$apk")"

    # Copy the whole module system tree. This preserves:
    # - product/etc/permissions/*.xml
    # - priv-app/<app>/lib/arm*/*.so
    # - system_ext/vendor/odm files
    # - overlays and other module-owned system files
    modscenter_remove_stock_dirs "$@"
    modscenter_copy_system_tree "$label" "$system_root" || {
        rm -rf "$extract_dir"
        return 1
    }

    rm -rf "$extract_dir"
    mods "$label: integrated with full system tree"
    return 0
}
