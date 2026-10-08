#!/usr/bin/env bash
set -euo pipefail

# Shared emoji installer used by HyperOS and classic MIUI.
# Replace existing extracted ROM emoji, never ThemeManager text fonts.
source_font="${1:?usage: install-emoji.sh /path/to/Shared/NotoColorEmoji.ttf /path/to/rom/images}"
images_root="${2:?missing extracted ROM images root}"

if [[ ! -s "$source_font" ]]; then
    echo "[EMOJI] ERROR: shared emoji missing or empty: $source_font" >&2
    exit 1
fi
if [[ ! -d "$images_root" ]]; then
    echo "[EMOJI] ERROR: ROM images root missing: $images_root" >&2
    exit 1
fi

count=0
errors=0
while IFS= read -r -d '' target; do
    if cmp -s "$source_font" "$target" || {
        cp -f "$source_font" "$target" && cmp -s "$source_font" "$target"
    }; then
        count=$((count + 1))
    else
        echo "[EMOJI] ERROR: could not replace or verify $target" >&2
        errors=$((errors + 1))
    fi
done < <(find "$images_root" -type f -name 'NotoColorEmoji.ttf' -print0)

if [[ "$count" -eq 0 || "$errors" -ne 0 ]]; then
    echo "[EMOJI] ERROR: verified=$count failed=$errors; no valid shared emoji install" >&2
    exit 1
fi
echo "[EMOJI] OK: verified $count existing emoji font file(s)"
