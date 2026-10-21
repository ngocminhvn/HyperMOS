#!/usr/bin/env bash
set -euo pipefail
# EU/Android 16 only. Uses the existing signed MiCTS 2.6 APK as the Tile UI.
work_dir="$(pwd)"
source "$work_dir/functions.sh"
mod_dir="$work_dir/bin/package/MICTS"
src_file="$work_dir/bin/ddevice/rom_source.txt"
android_file="$work_dir/bin/ddevice/androidver.txt"
if [[ ! -s "$src_file" || ! -s "$android_file" ]] ||
   [[ "$(tr -d '\r\n' < "$src_file")" != xiaomi_eu ]] ||
   [[ "$(tr -d '\r\n' < "$android_file")" != 16 ]]; then
  info 'MICTS: skip non-EU / non-Android16 build'
  exit 0
fi
services="$work_dir/build/baserom/images/system/framework/services.jar"
apk="$work_dir/build/downloadapp-cache/MiCTS_2.6.apk"
if [[ ! -s "$apk" ]]; then
  apk="$work_dir/bin/modfile/Universal/downloadapp/MiCTS_2.6.apk"
fi
if [[ ! -s "$apk" ]]; then
  error 'MICTS: MiCTS_2.6.apk missing; downloadapp staging must run first'
  exit 1
fi
if [[ "$(sha256sum "$apk" | cut -d' ' -f1)" != '4680d24112fbf0d7ff5bbc055b760f2d67173d7d5879ec5411540d5caa7a97b8' ]]; then
  error 'MICTS: official APK SHA-256 mismatch'
  exit 1
fi
sdk="$(tr -d '\r\n' < "$work_dir/bin/ddevice/sdkLevel.txt")"
for f in "$services" "$work_dir/bin/apktool/baksmaliv2.jar" "$work_dir/bin/apktool/smaliv2.jar"; do
  [[ -s "$f" ]] || { error "MICTS: missing $f"; exit 1; }
done
for cmd in python3 java unzip zip zipalign; do
  command -v "$cmd" >/dev/null || { error "MICTS: missing $cmd"; exit 1; }
done
scratch="$(mktemp -d "$work_dir/jar_temp.micts.XXXXXX")"
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/original" "$scratch/smali"
unzip -q "$services" -d "$scratch/original"
mapfile -t dexes < <(find "$scratch/original" -maxdepth 1 -name 'classes*.dex' -printf '%f\n' | sort -V)
(( ${#dexes[@]} > 0 )) || { error 'MICTS: no services.jar DEX'; exit 1; }
for dex in "${dexes[@]}"; do
  java -jar "$work_dir/bin/apktool/baksmaliv2.jar" d -l --api "$sdk" "$scratch/original/$dex" -o "$scratch/smali/$dex.out" >/dev/null
done
python3 "$mod_dir/patch.py" --root "$scratch/smali" --apk "$apk"
cp "$services" "$scratch/patched.jar"
for dex in "${dexes[@]}"; do
  if find "$scratch/smali/$dex.out" -type f \( -name 'MiCTSBridge.smali' -o -name '*VoiceInteractionManagerServiceStub.smali' -o -name 'ContextualSearchManagerService.smali' \) -print -quit | grep -q .; then
    java -jar "$work_dir/bin/apktool/smaliv2.jar" a --api "$sdk" "$scratch/smali/$dex.out" -o "$scratch/$dex" >/dev/null
    java -jar "$work_dir/bin/apktool/baksmaliv2.jar" d -l --api "$sdk" "$scratch/$dex" -o "$scratch/verified-$dex" >/dev/null
    [[ -d "$scratch/verified-$dex/com/android/server" ]] || { error "MICTS: DEX verification failed: $dex"; exit 1; }
    # Verify the exact smali callsite survives reassembly, not just valid DEX syntax.
    if [[ -f "$scratch/smali/$dex.out/com/android/server/micts/MiCTSBridge.smali" ]]; then
      [[ -s "$scratch/verified-$dex/com/android/server/micts/MiCTSBridge.smali" ]] || { error "MICTS: bridge lost after reassembly"; exit 1; }
    fi
    for rel in 'com/android/server/contextualsearch/ContextualSearchManagerService.smali' 'com/android/server/voiceinteraction/VoiceInteractionManagerService$VoiceInteractionManagerServiceStub.smali'; do
      if [[ -f "$scratch/smali/$dex.out/$rel" ]]; then
        grep -Fq 'Lcom/android/server/micts/MiCTSBridge;' "$scratch/verified-$dex/$rel" || {
          error "MICTS: callsite lost after reassembly: $rel"
          exit 1
        }
      fi
    done
    (cd "$scratch" && zip -q -0 patched.jar "$dex")
  fi
done
zipalign -f 4 "$scratch/patched.jar" "$scratch/aligned.jar"
unzip -tq "$scratch/aligned.jar" >/dev/null
[[ -s "$scratch/aligned.jar" ]] || { error 'MICTS: invalid patched JAR'; exit 1; }
cp -f "$scratch/aligned.jar" "$services"
mods 'MICTS: EU CSService bridge installed; stock MiCTS APK/Tile kept'
