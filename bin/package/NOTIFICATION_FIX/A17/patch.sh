#!/usr/bin/env bash
# Android 17 / OS4 Notification & Framework Integration for HyperMOS.
# Pure Global EEA policy: activates InternationalPolicyManager and Global PowerKeeper cloud sync.
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"
base="$work_dir/bin/package/NOTIFICATION_FIX/A17"
version="$work_dir/bin/ddevice/androidver.txt"

[[ -s "$version" ]] || { error "A17 Notification: missing androidver.txt"; exit 1; }
android_ver="$(tr -d '\r\n' < "$version")"
[[ "$android_ver" == "17" ]] || { error "A17 Notification: Android $android_ver unsupported"; exit 1; }

WORK_DIR="$work_dir"
TOOLS_DIR="$work_dir/bin/apktool"
API_LEVEL=36
image_root="$work_dir/build/baserom/images"
miui_jar="$image_root/system_ext/framework/miui-services.jar"
report_dir="$work_dir/build/reports/notification-a17"
miui_output="$work_dir/miui-services_patched.jar"

ensure_tools() {
  local program jar
  for program in java unzip python3; do
    command -v "$program" >/dev/null 2>&1 || {
      error "A17 Notification: missing host tool: $program"
      return 1
    }
  done
  for jar in baksmaliv2.jar smaliv2.jar timestamp.jar; do
    [[ -f "$TOOLS_DIR/$jar" ]] || {
      error "A17 Notification: $jar not found in $TOOLS_DIR"
      return 1
    }
  done
}

decompile_jar() {
  local jar_file="$1" base_name output_dir dex dex_name smali_dir baksmali
  local api_args=()
  base_name="$(basename "$jar_file" .jar)"
  output_dir="$WORK_DIR/${base_name}_decompile"
  local dex_api="${API_LEVEL:-}"
  case "$dex_api" in 36|37) dex_api=34 ;; esac
  [[ -n "$dex_api" ]] && api_args=(--api "$dex_api")

  baksmali="$TOOLS_DIR/baksmaliv2.jar"
  [[ -f "$jar_file" ]] || { error "JAR not found: $jar_file"; return 1; }
  unzip -t "$jar_file" >/dev/null 2>&1 || { error "invalid JAR archive: $jar_file"; return 1; }

  rm -rf "$output_dir"
  mkdir -p "$output_dir"
  unzip -oq "$jar_file" -d "$output_dir"
  for dex in "$output_dir"/*.dex; do
    [[ -f "$dex" ]] || continue
    dex_name="$(basename "$dex" .dex)"
    if [[ "$dex_name" == classes ]]; then
      smali_dir="$output_dir/smali"
    else
      smali_dir="$output_dir/smali_${dex_name}"
    fi
    java -jar "$baksmali" d "${api_args[@]}" "$dex" -o "$smali_dir" || return 1
    rm -f "$dex"
  done

  # Compatibility symlinks for classes/classesN
  [[ ! -d "$output_dir/smali" || -e "$output_dir/classes" ]] || ln -s smali "$output_dir/classes"
  local n
  for n in 2 3 4 5 6 7 8 9; do
    [[ ! -d "$output_dir/smali_classes$n" || -e "$output_dir/classes$n" ]] || \
      ln -s "smali_classes$n" "$output_dir/classes$n"
  done
  printf '%s\n' "$output_dir"
}

recompile_jar() {
  local jar_file="$1" base_name output_dir patched_jar smali_dir dir_name dex_name link smali
  local api_args=()
  base_name="$(basename "$jar_file" .jar)"
  output_dir="$WORK_DIR/${base_name}_decompile"
  patched_jar="$WORK_DIR/${base_name}_patched.jar"
  local dex_api="${API_LEVEL:-}"
  case "$dex_api" in 36|37) dex_api=34 ;; esac
  [[ -n "$dex_api" ]] && api_args=(--api "$dex_api")
  [[ -d "$output_dir" ]] || { error "decode directory missing: $output_dir"; return 1; }

  smali="$TOOLS_DIR/smaliv2.jar"
  for link in "$output_dir/classes" "$output_dir"/classes[0-9]*; do
    [[ -L "$link" ]] && rm -f "$link"
  done
  for smali_dir in "$output_dir/smali" "$output_dir"/smali_classes*; do
    [[ -d "$smali_dir" ]] || continue
    dir_name="$(basename "$smali_dir")"
    if [[ "$dir_name" == smali ]]; then
      dex_name=classes.dex
    else
      dex_name="${dir_name#smali_}.dex"
    fi
    java -jar "$smali" a "${api_args[@]}" "$smali_dir" -o "$output_dir/$dex_name" || return 1
    rm -rf "$smali_dir"
  done

  rm -f "$patched_jar"
  python3 -c '
import copy, re, struct, sys, zipfile
from pathlib import Path
orig, dec, out = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
with zipfile.ZipFile(orig) as src, zipfile.ZipFile(out, "w") as dst:
    dst.comment = src.comment
    for entry in src.infolist():
        meta = copy.copy(entry)
        data = src.read(entry)
        if re.fullmatch(r"classes(?:[2-9]|[1-9][0-9]+)?\.dex", entry.filename):
            data = (dec / entry.filename).read_bytes()
            meta.compress_type = zipfile.ZIP_STORED
            offset = dst.fp.tell() + 30 + len(entry.filename) + len(meta.extra)
            pad = -offset % 4
            if pad:
                meta.extra += struct.pack("<HH", 0xD935, pad) + bytes(pad)
        dst.writestr(meta, data)
' "$jar_file" "$output_dir" "$patched_jar" || return 1

  java -jar "$TOOLS_DIR/timestamp.jar" "$patched_jar" 1199145600
  printf '%s\n' "$patched_jar"
}

patch_miui_services() {
  info "[A17 Notification] Checking $(basename "$miui_jar")"
  local decoded changed
  decoded="$(decompile_jar "$miui_jar")"
  python3 "$base/framework_patcher.py" "$decoded" --report "$report_dir/notification-gates.json"
  changed="$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["changed"])' "$report_dir/notification-gates.json")"
  if [[ "$changed" == "False" ]]; then
    info "[A17 Notification] $(basename "$miui_jar") already patched"
    return
  fi
  recompile_jar "$miui_jar" >/dev/null
  [[ -s "$miui_output" ]] && unzip -t "$miui_output" >/dev/null || {
    error "A17 Notification: invalid rebuilt $(basename "$miui_jar")"
    return 1
  }
  mv -f "$miui_output" "$miui_jar"
  info "[A17 Notification] Successfully patched $(basename "$miui_jar")"
}

patch_powerkeeper() {
  local apks apk tmp final_apk
  mapfile -d '' apks < <(find "$image_root" -type f -name PowerKeeper.apk -print0)
  (( ${#apks[@]} == 1 )) || { error "PowerKeeper: exactly one stock Xiaomi APK required"; exit 1; }
  apk="${apks[0]}"
  [[ -s "$apk" ]] || { error "PowerKeeper: empty base APK"; exit 1; }

  local apksigner="$TOOLS_DIR/apksigner.jar"
  [[ -s "$apksigner" ]] || apksigner="$(find "$WORK_DIR/bin" -name "apksigner.jar" | head -n1)"
  [[ -s "$apksigner" ]] || { error "PowerKeeper: apksigner.jar not found"; exit 1; }

  info "[A17 Notification] Checking $(basename "$apk")"
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  # 1. Verify Xiaomi base signature
  python3 "$base/powerkeeper_patcher.py" \
    --check-base --apk "$apk" --reference "$apk" \
    --allow-stripped-base \
    --apksigner "$apksigner" \
    --report "$report_dir/stock-identity.json"

  # 2. Extract and disassemble classes.dex
  unzip -p "$apk" classes.dex > "$tmp/classes.dex"
  java -jar "$TOOLS_DIR/baksmaliv2.jar" d --api 34 "$tmp/classes.dex" -o "$tmp/smali"

  # 3. Patch PowerKeeper smali (GMS limiter bit 0, jupiter international sync, GLOBAL, xuanyuan)
  python3 "$base/powerkeeper_patcher.py" \
    --patch-smali "$tmp/smali" \
    --report "$report_dir/powerkeeper-patch-report.json"

  # 4. Reassemble patched classes.dex
  java -jar "$TOOLS_DIR/smaliv2.jar" a --api 34 "$tmp/smali" -o "$tmp/classes_patched.dex"
  [[ -s "$tmp/classes_patched.dex" ]] || { error "PowerKeeper: failed to assemble patched classes.dex"; exit 1; }

  # 5. Transplant patched classes.dex into stock APK with preserved Xiaomi identity
  python3 "$base/powerkeeper_patcher.py" \
    --rebuild --base "$apk" --patched "$tmp/classes_patched.dex" \
    --reference "$apk" --apksigner "$apksigner" \
    --allow-stripped-base \
    --apk "$tmp/PowerKeeper.preserved.apk" \
    --report "$report_dir/preserved-metadata.json"

  # 6. Zipalign if available
  if command -v zipalign >/dev/null 2>&1; then
    zipalign -p -f 4 "$tmp/PowerKeeper.preserved.apk" "$tmp/PowerKeeper.aligned.apk"
    zipalign -c -p 4 "$tmp/PowerKeeper.aligned.apk"
    final_apk="$tmp/PowerKeeper.aligned.apk"
  else
    final_apk="$tmp/PowerKeeper.preserved.apk"
  fi

  # 7. Final verification of preserved identity
  python3 "$base/powerkeeper_patcher.py" \
    --verify --apk "$final_apk" --reference "$apk" \
    --report "$report_dir/final-metadata.json"

  cp -f "$final_apk" "$apk"
  rm -rf "$(dirname "$apk")/oat"
  info "[A17 Notification] Successfully patched $(basename "$apk")"
}

ensure_tools
mkdir -p "$report_dir"
trap 'rm -rf "$work_dir/miui-services_decompile" "$miui_output"' EXIT
rm -f "$miui_output"

# 1. Patch miui-services.jar: activate InternationalPolicyManager (isCnModel = false)
patch_miui_services

# 2. Patch PowerKeeper: Global cloud sync & identity preservation
patch_powerkeeper

patch "[A17 Notification] Android 17 Pure Global notification patch complete"
