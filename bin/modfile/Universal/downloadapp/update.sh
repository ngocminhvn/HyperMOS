#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

SRC_DIR="$work_dir/bin/modfile/Universal/downloadapp"
DEST_ROOT="$work_dir/build/baserom/images/product/data-app"

shopt -s nullglob
apks=("$SRC_DIR"/*.apk)

if (( ${#apks[@]} == 0 )); then
  info "downloadapp: no APK found, skipped"
  exit 0
fi

mkdir -p "$DEST_ROOT"

mods "Installing downloadapp APKs"

for apk in "${apks[@]}"; do
  file="$(basename "$apk")"
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

  mods "downloadapp: $file -> product/data-app/$safe_name/"
done

mods "downloadapp -> Done"
