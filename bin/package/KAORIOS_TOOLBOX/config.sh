#!/usr/bin/env bash
# Internal loader for config.json. Source this file; edit config.json instead.

_kaorios_config_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
_kaorios_config_json="$_kaorios_config_dir/config.json"
_kaorios_config_loader="$_kaorios_config_dir/mod/load-config.py"

if [[ ! -f "$_kaorios_config_json" || ! -f "$_kaorios_config_loader" ]]; then
  printf 'KAORIOS: missing config.json or its loader\n' >&2
  return 1
fi

if ! _kaorios_config_values=$(python3 "$_kaorios_config_loader" "$_kaorios_config_json"); then
  return 1
fi

while IFS='=' read -r _kaorios_name _kaorios_value; do
  [[ -n "$_kaorios_name" ]] || continue
  if [[ ! -v "$_kaorios_name" ]]; then
    printf -v "$_kaorios_name" '%s' "$_kaorios_value"
  fi
done <<< "$_kaorios_config_values"

unset _kaorios_config_dir _kaorios_config_json _kaorios_config_loader
unset _kaorios_config_values _kaorios_name _kaorios_value
