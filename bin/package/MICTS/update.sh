#!/usr/bin/env bash
set -euo pipefail
# EU/Android 16 only. APK-independent framework hook; existing MiCTS Tile stays.
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
# Match the canonical HyperMOS system-as-root staging used by Kaorios.
# Never silently select a different JAR: patch the exact packed system path.
services="$work_dir/build/baserom/images/system/system/framework/services.jar"
# Do not pin/check MiCTS APK version, SHA-256, or signer here.
# The framework bridge is compatible with future APK updates as long as
# the request marker and method signature remain compatible.
sdk="$(tr -d '\r\n' < "$work_dir/bin/ddevice/sdkLevel.txt")"
for f in "$services" "$work_dir/bin/apktool/baksmaliv2.jar" "$work_dir/bin/apktool/smaliv2.jar"; do
  [[ -s "$f" ]] || { error "MICTS: missing $f"; exit 1; }
done
for cmd in python3 java unzip zip zipalign; do
  command -v "$cmd" >/dev/null || { error "MICTS: missing $cmd"; exit 1; }
done
# Audit actual DEX class definitions and method signatures before disassembly.
python3 "$mod_dir/dex_audit.py" "$services" --mode input
scratch="$(mktemp -d "$work_dir/jar_temp.micts.XXXXXX")"
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/original" "$scratch/smali"
unzip -q "$services" -d "$scratch/original"
mapfile -t dexes < <(find "$scratch/original" -maxdepth 1 -name 'classes*.dex' -printf '%f\n' | sort -V)
(( ${#dexes[@]} > 0 )) || { error 'MICTS: no services.jar DEX'; exit 1; }
for dex in "${dexes[@]}"; do
  java -jar "$work_dir/bin/apktool/baksmaliv2.jar" d -l --api "$sdk" "$scratch/original/$dex" -o "$scratch/smali/$dex.out" >/dev/null
done
python3 "$mod_dir/patch.py" --root "$scratch/smali"
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
# Audit final JAR after reassembly: target methods, bridge and DEX counts.
python3 "$mod_dir/dex_audit.py" "$scratch/aligned.jar" --mode output
cp -f "$scratch/aligned.jar" "$services"
mods 'MICTS: EU CSService bridge installed; stock MiCTS APK/Tile kept'
