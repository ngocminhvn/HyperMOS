#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"
[[ -f "$work_dir/bin/ddevice/androidver.txt" ]] || {
  error "downloadapp: androidver.txt missing"
  exit 1
}
androidVER="$(cat "$work_dir/bin/ddevice/androidver.txt")"

SRC_DIR="$work_dir/bin/modfile/Universal/downloadapp"
DEST_ROOT="$work_dir/build/baserom/images/product/data-app"
CACHE_DIR="$work_dir/build/downloadapp-cache"

# MiCTS is pinned so ROM builds stay reproducible.
MICTS_VERSION="2.6"
MICTS_NAME="MiCTS_${MICTS_VERSION}.apk"
MICTS_URL="https://github.com/parallelcc/MiCTS/releases/download/v${MICTS_VERSION}/${MICTS_NAME}"
MICTS_SHA256="4680d24112fbf0d7ff5bbc055b760f2d67173d7d5879ec5411540d5caa7a97b8"
MICTS_CACHE="$CACHE_DIR/$MICTS_NAME"
MICTS_SELECTED=""

[[ -d "$SRC_DIR" ]] || {
  error "downloadapp: source directory missing: $SRC_DIR"
  exit 1
}

ensure_micts() {
  local local_micts=""

  shopt -s nullglob
  local candidates=("$SRC_DIR"/MiCTS*.apk)
  shopt -u nullglob

  if (( ${#candidates[@]} > 0 )); then
    local_micts="${candidates[0]}"
    mods "downloadapp: using local MiCTS -> $(basename "$local_micts")"
    MICTS_SELECTED="$local_micts"
    return 0
  fi

  mkdir -p "$CACHE_DIR"

  if [[ -s "$MICTS_CACHE" ]]; then
    local cached_sha
    cached_sha="$(sha256sum "$MICTS_CACHE" | awk '{print $1}')"
    if [[ "$cached_sha" == "$MICTS_SHA256" ]]; then
      mods "downloadapp: using cached $MICTS_NAME"
      MICTS_SELECTED="$MICTS_CACHE"
      return 0
    fi
    rm -f "$MICTS_CACHE"
  fi

  mods "downloadapp: downloading pinned MiCTS v$MICTS_VERSION"
  local tmp="$MICTS_CACHE.tmp"
  rm -f "$tmp"

  if ! curl -fL --retry 3 --retry-delay 2 --connect-timeout 20 \
      -o "$tmp" "$MICTS_URL"; then
    rm -f "$tmp"
    error "downloadapp: failed to download MiCTS v$MICTS_VERSION"
    return 1
  fi

  local downloaded_sha
  downloaded_sha="$(sha256sum "$tmp" | awk '{print $1}')"
  if [[ "$downloaded_sha" != "$MICTS_SHA256" ]]; then
    rm -f "$tmp"
    error "downloadapp: MiCTS SHA-256 mismatch"
    return 1
  fi

  mv -f "$tmp" "$MICTS_CACHE"
  chmod 0644 "$MICTS_CACHE"
  mods "downloadapp: MiCTS v$MICTS_VERSION verified"
  MICTS_SELECTED="$MICTS_CACHE"
}

if [[ "$androidVER" == "16" ]]; then
  ensure_micts || {
    error "FAST-FAIL: MiCTS preload preparation failed"
    exit 1
  }
  [[ -n "$MICTS_SELECTED" && -s "$MICTS_SELECTED" ]] || {
    error "downloadapp: MiCTS selected payload missing or empty"
    exit 1
  }
else
  info "downloadapp: Android $androidVER -> skip automatic MiCTS preload"
fi

shopt -s nullglob
apks=("$SRC_DIR"/*.apk)
shopt -u nullglob

# If the repository does not contain a local MiCTS APK, stage the pinned cached release.
if [[ "$MICTS_SELECTED" == "$MICTS_CACHE" ]]; then
  apks+=("$MICTS_CACHE")
fi

if (( ${#apks[@]} == 0 )); then
  info "downloadapp: no APK found, skipped"
  exit 0
fi

mkdir -p "$DEST_ROOT"

mods "Installing downloadapp APKs"

for apk in "${apks[@]}"; do
  file="$(basename "$apk")"

  # When the ROM is patched with KernelSU Next, do not preload its manager
  # (or a competing SukiSU/KernelSU manager). The matching signed APK is
  # copied to the phone's Download directory after first unlock instead.
  # Stock mode deliberately preserves existing HyperMOS preload behavior.
  if [[ "${ROOT_MODE:-stock}" == "root" ]]; then
    case "$file" in
      SukiSU*.apk|KernelSU*.apk|KSU*.apk)
        mods "downloadapp: skip competing/preinstalled root manager: $file"
        continue
        ;;
    esac
  fi

  name="${file%.apk}"
  safe_name="$(printf '%s' "$name" | tr -cs 'A-Za-z0-9._-' '_')"

  if [[ -z "$safe_name" ]]; then
    error "downloadapp: invalid APK name: $file"
    exit 1
  fi

  dest_dir="$DEST_ROOT/$safe_name"
  mkdir -p "$dest_dir"
  cp -f "$apk" "$dest_dir/$file"
  chmod 0644 "$dest_dir/$file"

  if [[ ! -s "$dest_dir/$file" ]]; then
    error "downloadapp: failed to stage $file"
    exit 1
  fi

  src_size=$(stat -c '%s' "$apk")
  dst_size=$(stat -c '%s' "$dest_dir/$file")
  if [[ "$src_size" != "$dst_size" ]]; then
    error "downloadapp: staged size mismatch for $file ($src_size != $dst_size)"
    exit 1
  fi

  mods "downloadapp: $file -> product/data-app/$safe_name/"
done

mods "downloadapp -> Done"
