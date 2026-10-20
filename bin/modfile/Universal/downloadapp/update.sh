#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"
SRC_DIR="$work_dir/bin/modfile/Universal/downloadapp"
DEST_ROOT="$work_dir/build/baserom/images/product/data-app"

[[ -d "$SRC_DIR" ]] || {
  error "downloadapp: source directory missing: $SRC_DIR"
  exit 1
}

shopt -s nullglob
apks=("$SRC_DIR"/*.apk)
shopt -u nullglob

if (( ${#apks[@]} == 0 )); then
  info "downloadapp: no APK found, skipped"
  exit 0
fi

mkdir -p "$DEST_ROOT"

mods "Installing downloadapp APKs"

for apk in "${apks[@]}"; do
  file="$(basename "$apk")"

  # Do not preload root managers through generic product/data-app staging.
  # Root mode stages ONLY the checksum-pinned official SukiSU v4.2.1 APK
  # outside system app paths, then PackageManager installs it once as a
  # normal user app under /data/app after first boot. Stock mode skips it.
  case "$file" in
    SukiSU*.apk|KernelSU*.apk|KSU*.apk)
      mods "downloadapp: skip competing/preinstalled root manager: $file"
      continue
      ;;
  esac

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
