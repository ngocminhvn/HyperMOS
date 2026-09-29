#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILE="LiteGapps-arm64-16.0-20260709-official.zip"
URL="https://github.com/litegapps/litegapps/releases/download/lite-build-20260709-3/$FILE"
SHA256="6cc8c534d9e949d8242d63e4ceeb73510e87d3d55dd114eb0c7e7dd6c7be1ec3"

cd "$SCRIPT_DIR"

if command -v aria2c >/dev/null 2>&1; then
  aria2c -x 8 -s 8 -c -o "$FILE" "$URL"
else
  curl -fL --retry 3 -o "$FILE" "$URL"
fi

echo "$SHA256  $FILE" | sha256sum -c -
echo "LiteGapps A16 arm64 downloaded and verified: $SCRIPT_DIR/$FILE"
