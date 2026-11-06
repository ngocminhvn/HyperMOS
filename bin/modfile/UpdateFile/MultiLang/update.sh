work_dir=$(pwd)
MAIN_FOLDER="$work_dir/build/baserom/images"
source "$work_dir/functions.sh"
# Xiaomi.eu ships this functionality natively. Check here so dispatchers stay generic.
if [[ -f "$work_dir/bin/ddevice/rom_source.txt" ]] &&
   [[ "$(tr -d '\r\n' < "$work_dir/bin/ddevice/rom_source.txt")" == "xiaomi_eu" ]]; then
    exit 0
fi

# The bundled 67 Nothings overlay APKs were built for OS3 only.
# OS4 has a separate XML source tree, NOT a compiled/validated overlay set.
# Do not silently install OS3 overlay APKs into Android 17 / HyperOS 4.
rom_os_file="$work_dir/bin/ddevice/rom_os.txt"
if [[ ! -s "$rom_os_file" ]]; then
  error "MultiLang: ROM OS identification missing"
  exit 1
fi
rom_os="$(tr -d '\r\n' < "$rom_os_file")"
if [[ "$rom_os" != "OS3" ]]; then
  mods "MultiLang: skip OS3-only RRO APKs for $rom_os (OS4 XML staged separately)"
  exit 0
fi

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
