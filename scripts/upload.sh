#!/usr/bin/env bash
set -Eeuo pipefail
source_file="${OUTPUT_FILE:?OUTPUT_FILE missing}"
method="${UPLOAD_METHOD:-drive}"
test -s "$source_file"
mkdir -p work/reports
if [[ "$method" == "drive" ]]; then
  test -n "${RCLONE_TOKEN_PATH:-}" || { echo "RCLONE_TOKEN_PATH secret is missing"; exit 1; }
  rclone_url="$(printf '%s' "$RCLONE_TOKEN_PATH" | xargs)"
  case "$rclone_url" in
    https://*|http://*) ;;
    //*) rclone_url="https:$rclone_url" ;;
    *) rclone_url="https://$rclone_url" ;;
  esac
  curl -fLsS --retry 4 "$rclone_url" -o work/rclone.conf
  chmod 600 work/rclone.conf
  remote="${RCLONE_REMOTE:-$(rclone listremotes --config work/rclone.conf | head -1 | sed 's/:$//')}"
  test -n "$remote"
  target="$remote:HyperMOS/super-img-editor/$(basename "$source_file")"
  rclone copyto "$source_file" "$target" --config work/rclone.conf --stats=20s --retries=8 --low-level-retries=20
  link="$(rclone link "$target" --config work/rclone.conf 2>/dev/null || true)"
  echo "${link:-Rclone upload completed, but remote does not provide a public link}" > work/reports/download-url.txt
elif [[ "$method" == "pixeldrain" ]]; then
  test -n "${PIXELDRAIN_API_KEY:-}" || { echo "PIXELDRAIN_API_KEY secret is missing"; exit 1; }
  upload_one() {
    local file="$1" json id
    json="$(curl -fsS --retry 4 -u ":${PIXELDRAIN_API_KEY}" -F "file=@$file" https://pixeldrain.com/api/file)"
    id="$(printf '%s' "$json" | jq -er .id)"
    printf 'https://pixeldrain.com/u/%s\n' "$id"
  }
  size="$(stat -c%s "$source_file")"
  if (( size > 9*1024*1024*1024 )); then
    7zz a -t7z -mx=0 -v9g "$source_file.7z" "$source_file" >/dev/null
    : > work/reports/download-url.txt
    for part in "$source_file.7z".*; do
      test -f "$part" || continue
      upload_one "$part" >> work/reports/download-url.txt
    done
  else
    upload_one "$source_file" > work/reports/download-url.txt
  fi
else
  echo "Invalid UPLOAD_METHOD: $method" >&2; exit 1
fi
cat work/reports/download-url.txt
if [[ -n "${GITHUB_ENV:-}" ]]; then
  first="$(head -1 work/reports/download-url.txt)"
  echo "NOTIFY_DOWNLOAD_URL=$first" >> "$GITHUB_ENV"
fi
