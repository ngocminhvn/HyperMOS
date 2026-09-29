#!/usr/bin/env bash

work_dir=${work_dir:-$(pwd)}
source "$work_dir/functions.sh"

OS3_MOD_CACHE="$work_dir/build/os3_modscenter"
OS3_IMAGES="$work_dir/build/baserom/images"
MODSCENTER_ARCHIVE=""
MODSCENTER_TAG=""

modscenter_resolve_latest() {
    local repo="$1"

    python3 - "$repo" <<'PY'
import json
import os
import sys
import urllib.request

repo = sys.argv[1]
api = f"https://api.github.com/repos/{repo}/releases/latest"
headers = {
    "Accept": "application/vnd.github+json",
    "User-Agent": "HyperMOS-OS3-ModsCenter",
}
token = os.environ.get("GITHUB_TOKEN", "").strip()
if token:
    headers["Authorization"] = f"Bearer {token}"

req = urllib.request.Request(api, headers=headers)
with urllib.request.urlopen(req, timeout=30) as r:
    data = json.load(r)

assets = [
    a for a in data.get("assets", [])
    if str(a.get("name", "")).lower().endswith(".zip")
]

if len(assets) != 1:
    names = ", ".join(str(a.get("name", "")) for a in assets) or "<none>"
    raise SystemExit(f"Expected exactly one ZIP release asset, found {len(assets)}: {names}")

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

    module_prop=$(find "$extract_dir" -type f -name module.prop -print -quit 2>/dev/null || true)
    if [[ -n "$module_prop" ]]; then
        dirname "$module_prop"
    else
        printf '%s\n' "$extract_dir"
    fi
}

modscenter_find_apk() {
    local root="$1"
    local pattern="$2"
    local -a matches

    mapfile -d '' -t matches < <(find "$root" -type f -iname "$pattern" -print0 2>/dev/null)

    if (( ${#matches[@]} != 1 )); then
        printf 'Expected exactly one APK matching %s, found %d\n' "$pattern" "${#matches[@]}" >&2
        if (( ${#matches[@]} > 0 )); then
            printf '  %s\n' "${matches[@]}" >&2
        fi
        return 1
    fi

    printf '%s\n' "${matches[0]}"
}

modscenter_inspect_app_folder() {
    local label="$1"
    local app_dir="$2"
    local file_count so_count xml_count

    file_count=$(find "$app_dir" -type f | wc -l)
    so_count=$(find "$app_dir" -type f -name '*.so' | wc -l)
    xml_count=$(find "$app_dir" -type f -name '*.xml' | wc -l)

    mods "$label: inspect extracted app folder BEFORE replacing stock"
    echo "----- $label app folder: $app_dir -----"
    (
        cd "$app_dir" || exit 1
        find . -mindepth 1 -printf '%y %p\n' | LC_ALL=C sort
    )
    echo "----- end app folder ($file_count files, $so_count .so, $xml_count .xml) -----"
}

modscenter_remove_named_dirs() {
    local root="$1"
    shift
    local name path

    for name in "$@"; do
        while IFS= read -r -d '' path; do
            mods "Remove stock app dir: $path"
            rm -rf "$path"
        done < <(find "$root" -type d -name "$name" -prune -print0 2>/dev/null)
    done
}

modscenter_collect_named_dirs() {
    local root="$1"
    shift
    local name path

    for name in "$@"; do
        while IFS= read -r -d '' path; do
            printf '%s\0' "$path"
        done < <(find "$root" -type d -name "$name" -prune -print0 2>/dev/null)
    done
}

modscenter_map_system_path() {
    local system_root="$1"
    local source_path="$2"
    local rel first rest
    local logical_parts="product system_ext vendor odm mi_ext mi_product product_dlkm system_dlkm vendor_dlkm odm_dlkm"

    rel="${source_path#"$system_root"/}"
    first="${rel%%/*}"

    if [[ "$rel" == "$first" ]]; then
        rest=""
    else
        rest="${rel#*/}"
    fi

    case " $logical_parts " in
        *" $first "*)
            printf '%s\n' "$OS3_IMAGES/$first/$rest"
            ;;
        *)
            if [[ "$first" == "system" ]]; then
                printf '%s\n' "$OS3_IMAGES/system/system/$rest"
            else
                printf '%s\n' "$OS3_IMAGES/system/system/$rel"
            fi
            ;;
    esac
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
                cp -a "$entry/." "$target/" || return 1
                ;;
            *)
                target="$OS3_IMAGES/system/system"
                mkdir -p "$target"
                if [[ "$base" == "system" && -d "$entry" ]]; then
                    cp -a "$entry/." "$target/" || return 1
                else
                    cp -a "$entry" "$target/" || return 1
                fi
                ;;
        esac
    done < <(find "$system_root" -mindepth 1 -maxdepth 1 -print0)

    mods "$label: copied module system tree exactly as provided by release ZIP"
}

modscenter_verify_folder_shape() {
    local label="$1"
    local source_dir="$2"
    local target_dir="$3"
    local src_list dst_list

    [[ -d "$target_dir" ]] || {
        error "$label: target app folder missing after copy: $target_dir"
        return 1
    }

    src_list=$(mktemp)
    dst_list=$(mktemp)

    (
        cd "$source_dir" || exit 1
        find . -mindepth 1 -printf '%y %p\n' | LC_ALL=C sort
    ) > "$src_list"

    (
        cd "$target_dir" || exit 1
        find . -mindepth 1 -printf '%y %p\n' | LC_ALL=C sort
    ) > "$dst_list"

    if ! diff -u "$src_list" "$dst_list" >/dev/null; then
        error "$label: copied app folder shape differs from release ZIP"
        diff -u "$src_list" "$dst_list" || true
        rm -f "$src_list" "$dst_list"
        return 1
    fi

    rm -f "$src_list" "$dst_list"
    mods "$label: app folder shape verified against extracted release"
}

modscenter_apply_native_module() {
    local label="$1"
    local repo="$2"
    local expected_apk="$3"
    shift 3

    local extract_dir="$OS3_MOD_CACHE/extract-${repo##*/}"
    local module_root source_apk source_app_dir system_root target_app_dir
    local -a stock_dirs

    modscenter_unpack_latest "$label" "$repo" "$extract_dir" || return 1
    module_root=$(modscenter_module_root "$extract_dir")

    source_apk=$(modscenter_find_apk "$module_root" "$expected_apk") || {
        error "$label: cannot identify the mod APK in latest release"
        rm -rf "$extract_dir"
        return 1
    }

    source_app_dir=$(dirname "$source_apk")
    modscenter_inspect_app_folder "$label" "$source_app_dir" || {
        rm -rf "$extract_dir"
        return 1
    }

    system_root="$module_root/system"

    if [[ -d "$system_root" && "$source_apk" == "$system_root/"* ]]; then
        target_app_dir=$(modscenter_map_system_path "$system_root" "$source_app_dir")

        # The mod's own app folder must win exactly, without leftovers from stock.
        modscenter_remove_named_dirs "$OS3_IMAGES" "$@"
        rm -rf "$target_app_dir"

        modscenter_copy_system_tree "$label" "$system_root" || {
            error "$label: failed copying native module payload"
            rm -rf "$extract_dir"
            return 1
        }

        modscenter_verify_folder_shape "$label" "$source_app_dir" "$target_app_dir" || {
            rm -rf "$extract_dir"
            return 1
        }

        mods "$label: stock app replaced using native module path -> $target_app_dir"
    else
        # Some releases may ship only a standalone app folder instead of system/.
        # In that case preserve the real stock partition/path and mirror the
        # extracted app folder contents exactly into it.
        mapfile -d '' -t stock_dirs < <(modscenter_collect_named_dirs "$OS3_IMAGES" "$@")

        if (( ${#stock_dirs[@]} == 0 )); then
            error "$label: standalone app payload found, but no stock app directory matched"
            rm -rf "$extract_dir"
            return 1
        fi

        target_app_dir="${stock_dirs[0]}"
        if (( ${#stock_dirs[@]} > 1 )); then
            mods "$label: multiple stock aliases found; keeping first path and removing the rest"
        fi

        modscenter_remove_named_dirs "$OS3_IMAGES" "$@"
        mkdir -p "$target_app_dir"
        cp -a "$source_app_dir/." "$target_app_dir/" || {
            error "$label: failed mirroring standalone app folder"
            rm -rf "$extract_dir"
            return 1
        }

        modscenter_verify_folder_shape "$label" "$source_app_dir" "$target_app_dir" || {
            rm -rf "$extract_dir"
            return 1
        }

        mods "$label: stock app replaced in-place using standalone release folder -> $target_app_dir"
    fi

    rm -rf "$extract_dir"
    mods "$label: latest $MODSCENTER_TAG integrated from its OWN release layout"
}
