#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

src_rc="$work_dir/bin/modfile/UpdateFile/TNM/tnm-hosts.rc"
src_ctl="$work_dir/bin/modfile/UpdateFile/TNM/tnm-hostsctl.sh"
images="$work_dir/build/baserom/images"

[[ -f "$src_rc" ]] || { error "TNM Hosts: tnm-hosts.rc missing"; exit 1; }
[[ -f "$src_ctl" ]] || { error "TNM Hosts: tnm-hostsctl.sh missing"; exit 1; }
# Fail fast on backend syntax errors before copying the controller into ROM.
sh -n "$src_ctl" || { error "TNM Hosts: controller shell syntax invalid"; exit 1; }

if [[ -d "$images/system_ext" ]]; then
  init_dst="$images/system_ext/etc/init"
  bin_dst="$images/system_ext/bin"
  runtime_ctl="/system_ext/bin/tnm-hostsctl"
elif [[ -d "$images/product" ]]; then
  init_dst="$images/product/etc/init"
  bin_dst="$images/product/bin"
  runtime_ctl="/product/bin/tnm-hostsctl"
elif [[ -d "$images/system/system" ]]; then
  init_dst="$images/system/system/etc/init"
  bin_dst="$images/system/system/bin"
  runtime_ctl="/system/bin/tnm-hostsctl"
else
  error "TNM Hosts: no init-capable partition found"
  exit 1
fi

mods "TNM Hosts backend"
mkdir -p "$init_dst" "$bin_dst"

sed "s|@TNM_HOSTSCTL@|$runtime_ctl|g" "$src_rc" > "$init_dst/tnm-hosts.rc"
cp -f "$src_ctl" "$bin_dst/tnm-hostsctl"
chmod 0644 "$init_dst/tnm-hosts.rc"
chmod 0755 "$bin_dst/tnm-hostsctl"

[[ -s "$init_dst/tnm-hosts.rc" ]] || { error "TNM Hosts: installed rc missing"; exit 1; }
[[ -x "$bin_dst/tnm-hostsctl" ]] || { error "TNM Hosts: controller not executable"; exit 1; }

grep -qF "$runtime_ctl boot" "$init_dst/tnm-hosts.rc" || {
  error "TNM Hosts: init controller verification failed"
  exit 1
}
grep -q 'mount --bind "$SRC" "$TARGET"' "$bin_dst/tnm-hostsctl" || {
  error "TNM Hosts: bind controller verification failed"
  exit 1
}
grep -q 'RESULT=RESOLVER_UNVERIFIED' "$bin_dst/tnm-hostsctl" || {
  error "TNM Hosts: resolver self-test missing"
  exit 1
}

mods "TNM Hosts backend -> Done"

# One-time ROM entrypoint for TNM's APK-updatable backend.
# This launcher is root-only and has no init service or persistent process.
src_bridge="$work_dir/bin/modfile/UpdateFile/TNM/tnm-bridge"
[[ -s "$src_bridge" ]] || { error "TNM Bridge: launcher missing"; exit 1; }
bridge_dst="$bin_dst/tnm-bridge"
install -m 0755 "$src_bridge" "$bridge_dst"
[[ -x "$bridge_dst" ]] || { error "TNM Bridge: launcher was not installed"; exit 1; }
grep -q 'BACKEND=/data/adb/tnm/bin/tnmctl' "$bridge_dst" || {
  error "TNM Bridge: backend dispatch verification failed"
  exit 1
}
mods "TNM Bridge -> ${runtime_ctl%/*}/tnm-bridge (on demand)"



# ---------------------------------------------------------------------------
# TNM privileged system app
# ---------------------------------------------------------------------------
src_priv="$work_dir/bin/modfile/UpdateFile/TNM/privapp-permissions-tnm.xml"
[[ -f "$src_priv" ]] || { error "TNM App: privapp permission XML missing"; exit 1; }

if [[ -d "$images/product" ]]; then
  tnm_part="$images/product"
  tnm_runtime_partition="/product"
elif [[ -d "$images/system_ext" ]]; then
  tnm_part="$images/system_ext"
  tnm_runtime_partition="/system_ext"
else
  error "TNM App: no product/system_ext partition available"
  exit 1
fi

tnm_tmp="$(mktemp -d)"
cleanup_tnm() { rm -rf "$tnm_tmp"; }
trap cleanup_tnm EXIT

tnm_release_base="https://ngocminhvn.github.io/app"
tnm_update_json="$tnm_tmp/update.json"
tnm_payload="$tnm_tmp/TNM.update"
tnm_apk="$tnm_tmp/TNM.apk"

mods "TNM privileged app -> Downloading latest signed APK"

python3 - "$tnm_release_base/update.json" "$tnm_update_json" <<'PY'
import sys
import urllib.request

url, out = sys.argv[1], sys.argv[2]
req = urllib.request.Request(url, headers={"User-Agent": "HyperMOS-TNM-Installer/1"})
with urllib.request.urlopen(req, timeout=60) as src, open(out, "wb") as dst:
    dst.write(src.read())
PY

readarray -t tnm_meta < <(python3 - "$tnm_update_json" "$tnm_release_base" <<'PY'
import json
import sys

path, base = sys.argv[1], sys.argv[2]
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

apk_url = str(data.get("apkUrl", "")).strip()
url = str(data.get("packageUrl", "")).strip() or apk_url
compression = str(data.get("compression", "")).strip().lower() or "none"
legacy_sha = str(data.get("sha256", "")).strip().lower()
sha = str(data.get("packageSha256", "")).strip().lower() or legacy_sha

allowed = {
    base + "/TNM.apk": "none",
    base + "/TNM.apk.xz": "xz",
}
if url not in allowed:
    raise SystemExit("unexpected TNM packageUrl")
if compression != allowed[url]:
    raise SystemExit("TNM compression/url mismatch")
if len(sha) != 64 or any(c not in "0123456789abcdef" for c in sha):
    raise SystemExit("invalid TNM package sha256")

print(url)
print(sha)
print(compression)
PY
)

tnm_package_url="${tnm_meta[0]:-}"
tnm_expected_sha="${tnm_meta[1]:-}"
tnm_compression="${tnm_meta[2]:-}"
[[ -n "$tnm_package_url" && -n "$tnm_expected_sha" && -n "$tnm_compression" ]] || {
  error "TNM App: invalid update metadata"
  exit 1
}

python3 - "$tnm_package_url" "$tnm_payload" <<'PY'
import sys
import urllib.request

url, out = sys.argv[1], sys.argv[2]
req = urllib.request.Request(url, headers={"User-Agent": "HyperMOS-TNM-Installer/1"})
with urllib.request.urlopen(req, timeout=180) as src, open(out, "wb") as dst:
    while True:
        chunk = src.read(1024 * 1024)
        if not chunk:
            break
        dst.write(chunk)
PY

tnm_actual_sha="$(sha256sum "$tnm_payload" | awk '{print $1}')"
[[ "$tnm_actual_sha" == "$tnm_expected_sha" ]] || {
  error "TNM App: package SHA-256 mismatch"
  exit 1
}

case "$tnm_compression" in
  xz)
    command -v xz >/dev/null 2>&1 || {
      error "TNM App: xz is required to unpack update"
      exit 1
    }
    xz -dc "$tnm_payload" > "$tnm_apk"
    ;;
  none)
    cp -f "$tnm_payload" "$tnm_apk"
    ;;
  *)
    error "TNM App: unsupported compression '$tnm_compression'"
    exit 1
    ;;
esac

# Do not preinstall TNM 1.3.32: 1.3.33 is the first version the
# user confirmed opens after an in-place APK update.
tnm_badging="$(aapt dump badging "$tnm_apk")" || {
  error "TNM App: aapt could not inspect downloaded APK"
  exit 1
}
tnm_pkg="$(printf '%s\n' "$tnm_badging" | sed -n "s/^package: name='\([^']*\)'.*/\1/p" | head -n1)"
tnm_version_name="$(printf '%s\n' "$tnm_badging" | sed -n "s/^package: .*versionName='\([^']*\)'.*/\1/p" | head -n1)"
tnm_version_code="$(printf '%s\n' "$tnm_badging" | sed -n "s/^package: .*versionCode='\([^']*\)'.*/\1/p" | head -n1)"
[[ "$tnm_pkg" == "com.android.trinhngocminh" ]] || {
  error "TNM App: unexpected package '$tnm_pkg'"
  exit 1
}
if ! python3 - "$tnm_update_json" "$tnm_version_name" "$tnm_version_code" <<'PY'
import json
import re
import sys

metadata_path, version_name, version_code = sys.argv[1:]
with open(metadata_path, encoding="utf-8") as file:
    metadata = json.load(file)
match = re.fullmatch(r"(\d+)\.(\d+)\.(\d+)", version_name)
if not match or tuple(map(int, match.groups())) < (1, 3, 33):
    sys.exit(f"TNM App: need version >= 1.3.33; APK contains {version_name!r}")
if metadata.get("versionName") != version_name:
    sys.exit("TNM App: update.json versionName disagrees with actual APK")
if str(metadata.get("versionCode")) != version_code:
    sys.exit("TNM App: update.json versionCode disagrees with actual APK")
print(f"[MODS] - TNM privileged app -> verified APK {version_name} (code {version_code})")
PY
then
  error "TNM App: downloaded APK version verification failed"
  exit 1
fi

tnm_app_dir="$tnm_part/priv-app/TNM"
install -d "$tnm_app_dir" "$tnm_part/etc/permissions"
install -m 0644 "$tnm_apk" "$tnm_app_dir/TNM.apk"
install -m 0644 "$src_priv" "$tnm_part/etc/permissions/privapp-permissions-tnm.xml"

# TNM launches through DuckDetector's NativeActivity. Preloaded APKs under
# /product/priv-app can behave differently from APK updates under /data/app:
# stage bundled arm64 native libraries at the recognized system-app lib path.
if ! python3 - "$tnm_apk" "$tnm_app_dir/lib/arm64" <<'PY'
import os
from pathlib import Path
import shutil
import sys
import zipfile

apk, lib_dir = sys.argv[1], Path(sys.argv[2])
prefix = "lib/arm64-v8a/"
with zipfile.ZipFile(apk) as source:
    members = sorted(
        (item for item in source.infolist()
         if item.filename.startswith(prefix)
         and item.filename.count("/") == 2
         and item.filename.endswith(".so")
         and not item.is_dir()),
        key=lambda item: item.filename
    )
    if not any(item.filename == prefix + "libduckdetector.so" for item in members):
        sys.exit("TNM App: libduckdetector.so (arm64-v8a) missing from APK")
    lib_dir.mkdir(parents=True, exist_ok=True)
    for item in members:
        target = lib_dir / Path(item.filename).name
        with source.open(item) as read, target.open("wb") as write:
            shutil.copyfileobj(read, write)
        os.chmod(target, 0o644)
        if target.stat().st_size == 0:
            sys.exit(f"TNM App: empty extracted native library: {target.name}")
print(f"[MODS] - TNM privileged app -> staged {len(members)} arm64 native libraries")
PY
then
  error "TNM App: native library staging failed"
  exit 1
fi

[[ -s "$tnm_part/priv-app/TNM/TNM.apk" ]] || {
  error "TNM App: APK staging failed"
  exit 1
}
[[ -s "$tnm_part/etc/permissions/privapp-permissions-tnm.xml" ]] || {
  error "TNM App: permission XML staging failed"
  exit 1
}

mods "TNM privileged app -> Installed at ${tnm_runtime_partition}/priv-app/TNM"

