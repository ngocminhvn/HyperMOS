#!/usr/bin/env bash
# Only replace the existing NotoColorEmoji.ttf; never register text fonts.
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"
androidver="$(tr -d ' \r\n' < "$work_dir/bin/ddevice/androidver.txt")"
case "$androidver" in
  15|16|17) ;;
  *)
    mods "Emoji: Android $androidver unsupported (supports 15/16/17); skipped"
    exit 0
    ;;
esac
emoji_root="$work_dir/bin/modfile/UpdateFile/Emoji"
emoji_font="$emoji_root/NotoColorEmoji.ttf"
images_root="$work_dir/build/baserom/images"
[[ -s "$emoji_font" ]] || { error "Emoji font missing"; exit 1; }
[[ -d "$images_root" ]] || { error "Extracted ROM images missing"; exit 1; }
bash "$emoji_root/install-emoji.sh" "$emoji_font" "$images_root" || exit 1
mods "Emoji: NotoColorEmoji.ttf installed; system text fonts left original"
