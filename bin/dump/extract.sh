#!/usr/bin/env bash
# Read-only unpack. Never calls build.sh, mod scripts or ROM repacking.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ZIP="$1"; WORK="$2"
mkdir -p "$WORK/partitions" "$WORK/images" "$WORK/input"
PARTS="system system_ext product vendor odm mi_ext mi_product system_dlkm vendor_dlkm odm_dlkm product_dlkm"
unzip -Z1 "$ZIP" > "$WORK/entries.txt"
python3 - "$WORK/entries.txt" <<'PY'
from pathlib import PurePosixPath
import sys
for row in open(sys.argv[1],errors='replace'):
    name=row.strip()
    if name.startswith('/') or '..' in PurePosixPath(name).parts or '\\' in name:
        raise SystemExit('Unsafe ZIP entry: '+name)
PY
chmod +x "$ROOT/bin/Linux/x86_64/gettype" "$ROOT/bin/Linux/x86_64/extract.erofs" "$ROOT/bin/Linux/x86_64/payload-extract" || true

if grep -Fxq payload.bin "$WORK/entries.txt"; then
  echo '[DUMP] OTA payload.bin'
  unzip -p "$ZIP" payload.bin > "$WORK/input/payload.bin"
  "$ROOT/bin/Linux/x86_64/payload-extract" extract -o "$WORK/partitions" "$WORK/input/payload.bin"
  rm -f "$WORK/input/payload.bin"
elif grep -Eq '^(images/)?super\.img(\.[0-9]+)?$' "$WORK/entries.txt"; then
  echo '[DUMP] Fastboot super.img'
  mapfile -t entries < <(grep -E '^(images/)?super\.img(\.[0-9]+)?$' "$WORK/entries.txt" | sort -V)
  segments=()
  for entry in "\${entries[@]}"; do
    dest="$WORK/input/$(basename "$entry")"
    unzip -p "$ZIP" "$entry" > "$dest"
    segments+=("$dest")
  done
  if (( \${#segments[@]} > 1 )); then
    simg2img "\${segments[@]}" "$WORK/input/super.raw.img"
  elif python3 - "\${segments[0]}" <<'PY'
import sys
with open(sys.argv[1],'rb') as f:
    sys.exit(0 if f.read(4)==b'\x3a\xff\x26\xed' else 1)
PY
  then
    simg2img "\${segments[0]}" "$WORK/input/super.raw.img"
  else
    mv "\${segments[0]}" "$WORK/input/super.raw.img"
  fi
  rm -f "\${segments[@]}"
  requested=""
  for part in $PARTS; do requested+="$part,$part""_a,$part""_b,"; done
  python3 "$ROOT/bin/lpunpack.py" -p "\${requested%,}" "$WORK/input/super.raw.img" "$WORK/partitions"
  rm -f "$WORK/input/super.raw.img"
elif grep -Eq '\.new\.dat\.br$' "$WORK/entries.txt"; then
  echo '[DUMP] new.dat.br'
  for part in $PARTS; do
    entry="$(grep -E "(^|/)$part\.new\.dat\.br$" "$WORK/entries.txt" | head -1 || true)"
    [[ -n "$entry" ]] || continue
    transfer="\${entry%.new.dat.br}.transfer.list"
    if ! grep -Fxq "$transfer" "$WORK/entries.txt"; then
      echo "[WARN] Missing transfer.list for $part"; continue
    fi
    unzip -p "$ZIP" "$entry" | brotli -d > "$WORK/input/$part.new.dat"
    unzip -p "$ZIP" "$transfer" > "$WORK/input/$part.transfer.list"
    python3 "$ROOT/bin/Linux/x86_64/sdat2img.py" "$WORK/input/$part.transfer.list" "$WORK/input/$part.new.dat" "$WORK/partitions/$part.img"
    rm -f "$WORK/input/$part.new.dat" "$WORK/input/$part.transfer.list"
  done
else
  echo '[ERROR] Need payload.bin, super.img or *.new.dat.br'
  exit 1
fi

count=0
for part in $PARTS; do
  img="$WORK/partitions/$part.img"
  if [[ ! -f "$img" && -f "$WORK/partitions/$part""_a.img" ]]; then img="$WORK/partitions/$part""_a.img"; fi
  [[ -s "$img" ]] || continue
  mkdir -p "$WORK/images/$part"
  kind="$("$ROOT/bin/Linux/x86_64/gettype" -i "$img" || true)"
  if [[ "$kind" != erofs && "$kind" != ext ]]; then
    if [[ "$(od -An -tx4 -N4 "$img" | tr -d ' ')" == ed26ff3a ]]; then
      simg2img "$img" "$WORK/input/$part.raw.img"
      rm -f "$img"
      img="$WORK/input/$part.raw.img"
      kind="$("$ROOT/bin/Linux/x86_64/gettype" -i "$img" || true)"
    fi
  fi
  echo "[DUMP] Partition $part ($kind)"
  case "$kind" in
    erofs) "$ROOT/bin/Linux/x86_64/extract.erofs" -x -i "$img" -o "$WORK/images/$part" ;;
    ext) python3 "$ROOT/bin/imgextractor/imgextractor.py" "$img" "$WORK/images/$part" ;;
    *) echo "[WARN] Unsupported: $part"; continue ;;
  esac
  count=$((count + 1))
  rm -f "$img" "$WORK/input/$part.raw.img"
done
(( count > 0 )) || { echo '[ERROR] No supported filesystem extracted'; exit 1; }
echo "[DUMP] Extracted $count partitions"
