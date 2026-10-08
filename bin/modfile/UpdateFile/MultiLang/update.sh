work_dir=$(pwd)
MAIN_FOLDER="$work_dir/build/baserom/images"
source "$work_dir/functions.sh"
deviceTYPE=$(cat "$work_dir/bin/ddevice/device_type.txt")

if [[ "$deviceTYPE" == "China" ]]; then
  mods "Adding existing MultiLanguage overlays to ROM..."
  src="$work_dir/bin/modfile/UpdateFile/MultiLang/updatesource"
  extra="$work_dir/bin/modfile/UpdateFile/MultiLang/supplemental"
  target="$MAIN_FOLDER/product/overlay"
  mkdir -p "$target"

  # Preserve the 67 bundled overlays unchanged; never rebuild framework jars.
  shopt -s nullglob
  bundled=("$src"/*.apk)
  [[ ${#bundled[@]} -gt 0 ]] || {
    echo "[ERROR] - MultiLang: no bundled overlay APKs found" >&2
    exit 1
  }
  cp -f "${bundled[@]}" "$target/"

  # Optional, separately reviewed Vietnamese overlays. Do not overwrite existing
  # overlay names or stock files; a valid ZIP alone does not imply a valid RRO.
  supplemental=("$extra"/*.apk)
  for apk in "${supplemental[@]}"; do
    name=$(basename "$apk")
    if [[ -e "$target/$name" ]]; then
      echo "[ERROR] - MultiLang: supplemental filename collision: $name" >&2
      exit 1
    fi
    if ! unzip -tq "$apk" >/dev/null 2>&1; then
      echo "[ERROR] - MultiLang: invalid supplemental APK: $name" >&2
      exit 1
    fi
    cp -f "$apk" "$target/$name" || exit 1
  done
  shopt -u nullglob
  mods "MultiLanguage overlays ready: ${#bundled[@]} bundled, ${#supplemental[@]} supplemental."
fi
