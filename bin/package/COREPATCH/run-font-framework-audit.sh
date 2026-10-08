#!/usr/bin/env bash
set -Eeuo pipefail

# Standalone read-only HyperOS font diagnostic.
# No ROM patching, no framework rebuild, no flashable output.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
ROM_URL="${ROM_URL:?ROM_URL (full stock OTA ZIP HTTPS URL) is required}"
OUT="${FONT_AUDIT_OUT:-$ROOT/font-framework-audit}"
WORK="${RUNNER_TEMP:-$ROOT/build}/hypermos-font-audit"
BIN="$ROOT/bin/Linux/x86_64"
PAYLOAD_TOOL="$BIN/payload-extract"
IMAGES="$WORK/images"
EXTRACTED="$WORK/unpacked"
DECOMPILED="$WORK/smali"
DOWNLOAD="$WORK/download"
PAYLOAD="$DOWNLOAD/payload.bin"
ZIP="$DOWNLOAD/stock-ota.zip"

log() { printf '[FONT-AUDIT] %s\n' "$*"; }
fatal() { printf '[FONT-AUDIT] ERROR: %s\n' "$*" >&2; exit 1; }

[[ "$ROM_URL" == https://* ]] || fatal "Please supply a full HTTPS OTA ZIP URL."
[[ "$ROM_URL" == *".zip"* ]] || fatal "Expected a full OTA ZIP URL (not incremental/fastboot image)."

mkdir -p "$OUT" "$WORK" "$IMAGES" "$EXTRACTED" "$DECOMPILED" "$DOWNLOAD"
for tool in "$PAYLOAD_TOOL" "$BIN/gettype" "$BIN/extract.erofs"; do
    [[ -f "$tool" ]] || fatal "Missing bundled extraction binary: $tool"
    chmod +x "$tool"
done

# Extract only necessary payload ranges, or download one full ZIP if HTTP
# range requests are unavailable. Never rebuild or write to the source ROM.
ensure_local_payload() {
    [[ -s "$PAYLOAD" ]] && return 0
    log "Remote partition extraction unavailable; downloading OTA once as fallback"
    command -v aria2c >/dev/null || fatal "aria2c is needed for local fallback"
    aria2c -q -x 8 -s 8 --file-allocation=none -d "$DOWNLOAD" -o stock-ota.zip "$ROM_URL"
    [[ -s "$ZIP" ]] || fatal "OTA ZIP download failed"
    unzip -l "$ZIP" payload.bin >/dev/null || fatal "ZIP has no payload.bin"
    unzip -p "$ZIP" payload.bin > "$PAYLOAD" || fatal "Cannot extract payload.bin"
    [[ -s "$PAYLOAD" ]] || fatal "Empty payload.bin"
}

extract_image() {
    local part="$1" image input
    image="$IMAGES/$part.img"
    if [[ ! -s "$image" ]]; then
        if [[ -s "$PAYLOAD" ]]; then
            input="$PAYLOAD"
        else
            input="$ROM_URL"
        fi
        log "Extracting partition: $part"
        if ! "$PAYLOAD_TOOL" extract "$input" -p "$part" -o "$IMAGES" -j 2; then
            if [[ "$input" == "$PAYLOAD" ]]; then
                fatal "Unable to extract $part from local OTA payload"
            fi
            rm -f "$image"
            ensure_local_payload
            "$PAYLOAD_TOOL" extract "$PAYLOAD" -p "$part" -o "$IMAGES" -j 2 ||
                fatal "Unable to extract $part from downloaded OTA"
        fi
    fi
    [[ -s "$image" ]] || fatal "OTA has no $part.img"
    local type
    type=$("$BIN/gettype" -i "$image" || true)
    [[ "$type" == "erofs" ]] ||
        fatal "Unexpected filesystem type for $part: '$type' (this workflow targets EROFS HyperOS OTAs)"
    log "Unpacking EROFS: $part"
    "$BIN/extract.erofs" -x -i "$image" -o "$EXTRACTED" > /dev/null ||
        fatal "Unable to unpack $part"
    rm -f "$image"
}

find_settings() {
    find "$EXTRACTED" -type f -name Settings.apk -print -quit | grep -q .
}

extract_image system_ext

mapfile -t jars < <(find "$EXTRACTED" -type f -path '*/framework/miui-framework.jar' -print)
[[ "${#jars[@]}" -eq 1 ]] ||
    fatal "Expected one stock miui-framework.jar in system_ext; found ${#jars[@]}"
JAR="${jars[0]}"
log "Found framework: ${JAR#"$EXTRACTED"/}"

# Xiaomi may ship Settings.apk in system_ext, product, or system. Do not
# extract the latter partitions unless necessary.
if ! find_settings; then
    extract_image product
fi
if ! find_settings; then
    extract_image system
fi
find_settings || fatal "Settings.apk missing from system_ext/product/system"

# Inspect native stock DEX as-is. No modified JAR is written back to the ROM.
DEXDIR="$WORK/dex"
mkdir -p "$DEXDIR"
mapfile -t dex_files < <(unzip -Z1 "$JAR" | grep -E '^classes[0-9]*[.]dex$')
[[ "${#dex_files[@]}" -gt 0 ]] || fatal "miui-framework.jar has no classes*.dex"
for dex in "${dex_files[@]}"; do
    log "Disassembling $dex (SDK 36)"
    unzip -p "$JAR" "$dex" > "$DEXDIR/$dex"
    java -jar "$ROOT/bin/apktool/baksmaliv2.jar" d --api 36 \
        "$DEXDIR/$dex" -o "$DECOMPILED/${dex%.dex}" > /dev/null ||
        fatal "baksmali failed for $dex"
done

python3 "$ROOT/bin/package/COREPATCH/font-framework-audit.py" \
    "$DECOMPILED" "$OUT/font-framework-audit.json" --images-root "$EXTRACTED"

# Include provenance without re-packaging original system JAR/APK.
python3 - "$ROM_URL" "$JAR" "$OUT/README.txt" <<'PY'
import hashlib
import sys
from pathlib import Path
from urllib.parse import urlsplit
rom_url, jar_path, output = sys.argv[1:]
jar = Path(jar_path)
source = urlsplit(rom_url)
Path(output).write_text(
    "HyperMOS standalone font-framework-audit\n"
    "Mode: read-only; no ROM build/repack/flash\n"
    f"OTA host: {source.netloc}\n"
    f"OTA path: {source.path}\n"
    f"miui-framework.jar sha256: {hashlib.sha256(jar.read_bytes()).hexdigest()}\n"
    "Output: font-framework-audit.json\n"
    "Review font manager methods and Settings font-weight gate before patching.\n",
    encoding="utf-8",
)
PY

log "SUCCESS: $OUT/font-framework-audit.json"
