#!/usr/bin/env bash
# HyperMOS/XM_build - experimental YouTube Morphe integration.
# Patches the YouTube APK already present in the extracted ROM.
# No MicroG/MicroRE: Morphe's "GmsCore support" patch is explicitly disabled.
#
# Non-fatal by default: an unsupported/missing YouTube keeps the stock APK.
# Set MORPHE_REQUIRED=1 if you want patch failure to abort the ROM build.

set -u

work_dir="${work_dir:-$(pwd)}"
images_dir="$work_dir/build/baserom/images"
morphe_work="$work_dir/build/morphe"
result_dir="$work_dir/bin/ddevice"
required="${MORPHE_REQUIRED:-0}"
enabled="${YOUTUBE_MORPHE:-true}"
patch_channel="${MORPHE_PATCH_CHANNEL:-latest}"

action_log() { echo "[YouTubeMorphe] $*"; }
warn()       { echo "[YouTubeMorphe][WARN] $*" >&2; }

finish_skip() {
    warn "$*"
    if [ "$required" = "1" ]; then
        exit 1
    fi
    exit 0
}

case "${enabled,,}" in
    1|true|yes|on|enabled) ;;
    *) action_log "Disabled by YOUTUBE_MORPHE=$enabled"; exit 0 ;;
esac

if [ ! -d "$images_dir" ]; then
    finish_skip "ROM images directory not found: $images_dir"
fi

if ! command -v aapt >/dev/null 2>&1; then
    finish_skip "aapt is unavailable; cannot identify YouTube safely."
fi
if ! command -v jq >/dev/null 2>&1; then
    finish_skip "jq is unavailable."
fi
if ! command -v curl >/dev/null 2>&1; then
    finish_skip "curl is unavailable."
fi

mkdir -p "$morphe_work" "$result_dir"

youtube_apk=""
while IFS= read -r apk; do
    badging="$(aapt dump badging "$apk" 2>/dev/null | head -n1 || true)"
    case "$badging" in
        *"package: name='com.google.android.youtube'"*)
            if [[ "$badging" != *" split='"* ]]; then
                youtube_apk="$apk"
                break
            fi
            ;;
    esac
done < <(find "$images_dir" -type f -name '*.apk' -print 2>/dev/null)

if [ -z "$youtube_apk" ]; then
    finish_skip "Stock YouTube (com.google.android.youtube) was not found in this ROM."
fi

youtube_dir="$(dirname "$youtube_apk")"
apk_count="$(find "$youtube_dir" -maxdepth 1 -type f -name '*.apk' | wc -l | tr -d ' ')"
if [ "${apk_count:-0}" -gt 1 ]; then
    finish_skip "YouTube is a split APK set in $youtube_dir; skipping to avoid mixed-signature splits."
fi

badging="$(aapt dump badging "$youtube_apk" 2>/dev/null | head -n1 || true)"
youtube_version="$(printf '%s\n' "$badging" | sed -n "s/.*versionName='\([^']*\)'.*/\1/p")"
youtube_version_code="$(printf '%s\n' "$badging" | sed -n "s/.*versionCode='\([^']*\)'.*/\1/p")"
action_log "Found YouTube: $youtube_apk"
action_log "Version: ${youtube_version:-unknown} (${youtube_version_code:-unknown})"

java_bin="$(command -v java || true)"
java_major=""
if [ -n "$java_bin" ]; then
    java_major="$("$java_bin" -version 2>&1 | head -n1 | sed -E 's/.*version "([0-9]+).*/\1/' || true)"
fi

if ! [[ "$java_major" =~ ^[0-9]+$ ]] || [ "$java_major" -lt 21 ]; then
    action_log "Java 21+ not found; downloading temporary Temurin JRE 21..."
    jre_archive="$morphe_work/temurin-jre21.tar.gz"
    jre_dir="$morphe_work/jre21"
    rm -rf "$jre_dir"
    mkdir -p "$jre_dir"

    if ! curl -fL --retry 4 --retry-delay 3 --connect-timeout 30 \
        "https://api.adoptium.net/v3/binary/latest/21/ga/linux/x64/jre/hotspot/normal/eclipse" \
        -o "$jre_archive"; then
        finish_skip "Unable to download Java 21 runtime."
    fi

    if ! tar -xzf "$jre_archive" -C "$jre_dir" --strip-components=1; then
        finish_skip "Unable to extract Java 21 runtime."
    fi
    java_bin="$jre_dir/bin/java"
fi

if [ ! -x "$java_bin" ]; then
    finish_skip "Java 21 executable is unavailable."
fi
action_log "Java: $("$java_bin" -version 2>&1 | head -n1)"

curl_api=(curl -fsSL --retry 4 --retry-delay 3 --connect-timeout 30)
if [ -n "${MORPHE_GITHUB_TOKEN:-}" ]; then
    curl_api+=(-H "Authorization: Bearer ${MORPHE_GITHUB_TOKEN}")
fi
curl_api+=(-H "Accept: application/vnd.github+json")

desktop_json="$morphe_work/morphe-desktop-releases.json"
if ! "${curl_api[@]}" \
    "https://api.github.com/repos/MorpheApp/morphe-desktop/releases?per_page=20" \
    -o "$desktop_json"; then
    finish_skip "Unable to query Morphe Desktop releases."
fi

morphe_url="$(jq -r '[.[] | select(.draft == false) | .assets[]? | select(.name | test("^morphe-desktop-.*-all\\.jar$")) | .browser_download_url][0] // empty' "$desktop_json")"
morphe_name="$(jq -r '[.[] | select(.draft == false) | .assets[]? | select(.name | test("^morphe-desktop-.*-all\\.jar$")) | .name][0] // empty' "$desktop_json")"
morphe_version="$(printf '%s' "$morphe_name" | sed -E 's/^morphe-desktop-(.*)-all\.jar$/\1/')"

if [ -z "$morphe_url" ]; then
    finish_skip "No Morphe Desktop all-in-one JAR found in recent releases."
fi

morphe_jar="$morphe_work/morphe-desktop-all.jar"
action_log "Downloading Morphe Desktop ${morphe_version:-latest}..."
if ! curl -fL --retry 4 --retry-delay 3 --connect-timeout 30 "$morphe_url" -o "$morphe_jar"; then
    finish_skip "Unable to download Morphe Desktop."
fi

patched_apk="$morphe_work/YouTube-Morphe.apk"
patch_result="$morphe_work/patch-result.json"
rm -f "$patched_apk" "$patch_result"

export MORPHE_DATA_DIR="$morphe_work/data"
mkdir -p "$MORPHE_DATA_DIR"

patch_args=(
    patch
    --patches "https://github.com/MorpheApp/morphe-patches"
)
if [ "$patch_channel" = "latest" ] || [ "$patch_channel" = "dev" ] || [ "$patch_channel" = "prerelease" ]; then
    patch_args+=(--prerelease)
fi
patch_args+=(
    -d "GmsCore support"
    -d "Custom branding"
    --bytecode-mode STRIP_SAFE
    --result-file "$patch_result"
    --out "$patched_apk"
    "$youtube_apk"
)

action_log "Patching with Morphe patches channel: $patch_channel"
action_log "GmsCore support disabled: no MicroG/MicroRE dependency is added."

if ! "$java_bin" -jar "$morphe_jar" "${patch_args[@]}"; then
    [ -f "$patch_result" ] && cp -f "$patch_result" "$result_dir/morphe_patch_result.json" 2>/dev/null || true
    finish_skip "Morphe could not patch YouTube ${youtube_version:-unknown}; stock YouTube is kept."
fi

if [ ! -s "$patched_apk" ]; then
    finish_skip "Morphe reported success but no patched APK was produced."
fi

patched_badging="$(aapt dump badging "$patched_apk" 2>/dev/null | head -n1 || true)"
if [[ "$patched_badging" != *"package: name='com.google.android.youtube'"* ]]; then
    finish_skip "Patched APK package changed unexpectedly; refusing to replace the stock system app."
fi

printf '%s\n' "${youtube_version:-unknown}" > "$result_dir/morphe_youtube_version.txt"
printf '%s\n' "${morphe_version:-unknown}" > "$result_dir/morphe_desktop_version.txt"
printf '%s\n' "$patch_channel" > "$result_dir/morphe_patch_channel.txt"
[ -f "$patch_result" ] && cp -f "$patch_result" "$result_dir/morphe_patch_result.json" 2>/dev/null || true

stock_name="$(basename "$youtube_apk")"
cp -f "$youtube_apk" "$morphe_work/${stock_name}.stock"
tmp_target="$youtube_dir/.${stock_name}.morphe.tmp"
cp -f "$patched_apk" "$tmp_target"
chmod --reference="$youtube_apk" "$tmp_target" 2>/dev/null || chmod 0644 "$tmp_target"
touch -r "$youtube_apk" "$tmp_target" 2>/dev/null || true
mv -f "$tmp_target" "$youtube_apk"

rm -rf "$youtube_dir/oat" 2>/dev/null || true
rm -f "$youtube_dir"/*.dm "$youtube_dir"/*.prof 2>/dev/null || true

action_log "Integrated YouTube Morphe successfully."
action_log "Package kept as com.google.android.youtube; GmsCore/MicroRE support was not applied."
exit 0
