#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

src_rc="$work_dir/bin/modfile/UpdateFile/TNM/tnm-hosts.rc"
src_ctl="$work_dir/bin/modfile/UpdateFile/TNM/tnm-hostsctl.sh"
images="$work_dir/build/baserom/images"

[[ -f "$src_rc" ]] || { error "TNM Hosts: tnm-hosts.rc missing"; exit 1; }
[[ -f "$src_ctl" ]] || { error "TNM Hosts: tnm-hostsctl.sh missing"; exit 1; }

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

tnm_release_base="https://github.com/ngocminhvn/HyperMOS/releases/download/tnm-latest"
tnm_update_json="$tnm_tmp/update.json"
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

url = str(data.get("apkUrl", "")).strip()
sha = str(data.get("sha256", "")).strip().lower()
if url != base + "/TNM.apk":
    raise SystemExit("unexpected TNM apkUrl")
if len(sha) != 64 or any(c not in "0123456789abcdef" for c in sha):
    raise SystemExit("invalid TNM sha256")

print(url)
print(sha)
PY
)

tnm_apk_url="${tnm_meta[0]:-}"
tnm_expected_sha="${tnm_meta[1]:-}"
[[ -n "$tnm_apk_url" && -n "$tnm_expected_sha" ]] || {
  error "TNM App: invalid update metadata"
  exit 1
}

python3 - "$tnm_apk_url" "$tnm_apk" <<'PY'
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

tnm_actual_sha="$(sha256sum "$tnm_apk" | awk '{print $1}')"
[[ "$tnm_actual_sha" == "$tnm_expected_sha" ]] || {
  error "TNM App: SHA-256 mismatch"
  exit 1
}

tnm_pkg="$(aapt dump badging "$tnm_apk" 2>/dev/null | sed -n "s/^package: name='\([^']*\)'.*/\1/p" | head -n1)"
[[ "$tnm_pkg" == "com.android.trinhngocminh" ]] || {
  error "TNM App: unexpected package '$tnm_pkg'"
  exit 1
}

install -d "$tnm_part/priv-app/TNM" "$tnm_part/etc/permissions"
install -m 0644 "$tnm_apk" "$tnm_part/priv-app/TNM/TNM.apk"
install -m 0644 "$src_priv" "$tnm_part/etc/permissions/privapp-permissions-tnm.xml"

[[ -s "$tnm_part/priv-app/TNM/TNM.apk" ]] || {
  error "TNM App: APK staging failed"
  exit 1
}
[[ -s "$tnm_part/etc/permissions/privapp-permissions-tnm.xml" ]] || {
  error "TNM App: permission XML staging failed"
  exit 1
}

mods "TNM privileged app -> Installed at ${tnm_runtime_partition}/priv-app/TNM"

