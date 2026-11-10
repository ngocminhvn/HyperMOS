#!/usr/bin/env bash
# Minimal JAR decode/rebuild helpers for Android 17 / OS4 notification patch.

log() { printf '%s\n' "[INFO] $*" >&2; }
warn() { printf '%s\n' "[WARN] $*" >&2; }
err() { printf '%s\n' "[ERROR] $*" >&2; }

init_env() {
  : "${TOOLS_DIR:=$work_dir/bin/apktool}"
  : "${WORK_DIR:=$work_dir}"
}

ensure_tools() {
  local program
  for program in java unzip zip; do
    command -v "$program" >/dev/null 2>&1 || {
      err "missing host tool: $program"
      return 1
    }
  done
  [[ -f "$TOOLS_DIR/baksmaliv2.jar" ]] || {
    err "baksmali JAR not found in $TOOLS_DIR"
    return 1
  }
  [[ -f "$TOOLS_DIR/smaliv2.jar" ]] || {
    err "smali JAR not found in $TOOLS_DIR"
    return 1
  }
  [[ -f "$TOOLS_DIR/timestamp.jar" ]] || {
    err "timestamp.jar not found at $TOOLS_DIR/timestamp.jar"
    return 1
  }
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

  [[ -f "$jar_file" ]] || { err "JAR not found: $jar_file"; return 1; }
  unzip -t "$jar_file" >/dev/null 2>&1 || {
    err "invalid JAR archive: $jar_file"
    return 1
  }

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
  log "Decompiled $jar_file"
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
  [[ -d "$output_dir" ]] || { err "decode directory missing: $output_dir"; return 1; }

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
    java -jar "$smali" a "${api_args[@]}" "$smali_dir" \
      -o "$output_dir/$dex_name" || return 1
    rm -rf "$smali_dir"
  done

  rm -f "$output_dir/apktool.yml" "$patched_jar"
  if command -v 7z >/dev/null 2>&1; then
    (cd "$output_dir" && 7z a -tzip -mx=0 "$patched_jar" . >/dev/null) || return 1
  else
    (cd "$output_dir" && zip -qr -0 "$patched_jar" .) || return 1
  fi
  java -jar "$TOOLS_DIR/timestamp.jar" "$patched_jar" 1199145600
  log "Created patched JAR: $patched_jar"
  printf '%s\n' "$patched_jar"
}
