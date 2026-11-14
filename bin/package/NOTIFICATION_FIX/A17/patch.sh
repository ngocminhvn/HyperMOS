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
miui_jar="$work_dir/build/baserom/images/system_ext/framework/miui-services.jar"
report_dir="$work_dir/build/reports/frameworkpatcher-a17"
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

stage_jar() {
  local jar="$1" patcher="$2" report="$3" output="$4" decoded changed
  info "[A17 Notification] Checking $(basename "$jar")"
  decoded="$(decompile_jar "$jar")"
  python3 "$base/$patcher" "$decoded" --report "$report"
  changed="$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["changed"])' "$report")"
  if [[ "$changed" == "False" ]]; then
    info "[A17 Notification] $(basename "$jar") already patched"
    return
  fi
  recompile_jar "$jar" >/dev/null
  [[ -s "$output" ]] && unzip -t "$output" >/dev/null || {
    error "A17 Notification: invalid rebuilt $(basename "$jar")"
    return 1
  }
}

ensure_tools
mkdir -p "$report_dir"
trap 'rm -rf "$work_dir/miui-services_decompile" "$miui_output"' EXIT
rm -f "$miui_output"

# 1. Patch miui-services.jar: activate InternationalPolicyManager (isCnModel = false)
stage_jar "$miui_jar" frameworkpatcher_a17.py "$report_dir/notification-gates.json" "$miui_output"

if [[ -f "$miui_output" ]]; then
  mv -f "$miui_output" "$miui_jar"
fi

# 2. Patch PowerKeeper: Global cloud sync & identity preservation
bash "$base/PowerKeeper.sh"

log "[A17 Notification] Android 17 Pure Global notification patch complete"
