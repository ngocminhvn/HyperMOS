#!/system/bin/sh
# Password-free snapshot of selected files from the running Android ROM.
# Read only: no flashing, mount changes, root requests, or installer execution.
set -eu

if [ "$#" -ge 1 ]; then OUT="$1"; else OUT="/sdcard/Download/Installed-ROM-dump"; fi
case "$OUT" in
  /sdcard/Download/*|/storage/emulated/0/Download/*) ;;
  *) echo "[ERROR] Output must be under Download." >&2; exit 2 ;;
esac
if [ -e "$OUT" ]; then
  echo "[ERROR] Output folder already exists, choose a fresh name: $OUT" >&2
  exit 2
fi
umask 077
mkdir -p "$OUT/files" "$OUT/pack-meta"
MAPPING="$OUT/pack-meta/source-map.tsv"
printf 'filename\tsource\tstatus\n' > "$MAPPING"
FOUND=0
MISSING=0

file_for() {
  name="$1"
  shift
  picked=""
  for location in "$@"; do
    if [ -f "$location" ] && [ -r "$location" ]; then
      picked="$location"
      break
    fi
  done
  if [ -n "$picked" ]; then
    if cp "$picked" "$OUT/files/$name"; then
      printf '%s\t%s\tFOUND\n' "$name" "$picked" >> "$MAPPING"
      FOUND=$((FOUND + 1))
      echo "[DUMP] $name <- $picked"
      return
    fi
  fi
  printf '%s\t\tMISSING\n' "$name" >> "$MAPPING"
  MISSING=$((MISSING + 1))
  echo "[WARN] Not readable on this ROM: $name"
}

file_for framework.jar \
  /system/framework/framework.jar \
  /system/system/framework/framework.jar
file_for services.jar \
  /system/framework/services.jar \
  /system/system/framework/services.jar
file_for miui-framework.jar \
  /system_ext/framework/miui-framework.jar \
  /system/framework/miui-framework.jar
file_for miui-services.jar \
  /system_ext/framework/miui-services.jar \
  /system/framework/miui-services.jar
file_for powerkeeper.apk \
  /system_ext/app/PowerKeeper/PowerKeeper.apk \
  /system_ext/priv-app/PowerKeeper/PowerKeeper.apk \
  /system_ext/app/PowerKeeper/PowerKeeperZK.apk \
  /product/app/PowerKeeper/PowerKeeper.apk \
  /product/priv-app/PowerKeeper/PowerKeeper.apk

{
  echo "SOURCE=RUNNING_ANDROID_FILESYSTEM"
  echo "DISCLAIMER=NOT_A_DECRYPTED_ELITEROM_ZIP"
  echo "NOTE=Files come from the currently installed ROM only."
  echo "TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || echo unknown)"
  echo "PRODUCT=$(getprop ro.product.device 2>/dev/null || echo unknown)"
  echo "MODEL=$(getprop ro.product.model 2>/dev/null || echo unknown)"
  echo "BUILD=$(getprop ro.build.display.id 2>/dev/null || echo unknown)"
  echo "INCREMENTAL=$(getprop ro.build.version.incremental 2>/dev/null || echo unknown)"
  echo "FOUND=$FOUND"
  echo "MISSING=$MISSING"
} > "$OUT/pack-meta/installed-source.txt"

if command -v sha256sum >/dev/null 2>&1; then
  (
    cd "$OUT/files"
    for file in *; do
      if [ -f "$file" ]; then sha256sum "$file"; fi
    done
  ) > "$OUT/pack-meta/SHA256SUMS.txt"
fi

ARCHIVE=""
if command -v zip >/dev/null 2>&1; then
  ARCHIVE="$OUT.zip"
  (cd "$OUT" && zip -q -1 -r "$ARCHIVE" .) || ARCHIVE=""
elif command -v tar >/dev/null 2>&1; then
  ARCHIVE="$OUT.tar.gz"
  (cd "$OUT" && tar -czf "$ARCHIVE" .) || ARCHIVE=""
fi
echo "[DUMP] Found=$FOUND Missing=$MISSING"
echo "[DUMP] Folder: $OUT"
if [ -n "$ARCHIVE" ] && [ -f "$ARCHIVE" ]; then
  echo "[DUMP] Archive: $ARCHIVE"
else
  echo "[DUMP] No archive utility, use the output folder."
fi
if [ "$FOUND" -eq 0 ]; then exit 3; fi
echo "[DUMP] Only installed-ROM files are included, NOT the encrypted offline ZIP."
