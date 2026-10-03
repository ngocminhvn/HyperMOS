#!/usr/bin/env bash
set -u

work_dir=$(pwd)
source "$work_dir/functions.sh"
[ -f "$work_dir/config.env" ] && source "$work_dir/config.env"

mode="${thermal_mode:-stock}"
mode="$(printf '%s' "$mode" | tr '[:upper:]' '[:lower:]')"

case "$mode" in
  stock)
    mods "[THERMAL] stock -> keep Xiaomi thermal unchanged"
    exit 0
    ;;
  eco)
    ;;
  *)
    mods "[THERMAL] unknown mode '$mode' -> fallback stock"
    exit 0
    ;;
esac

if ! command -v openssl >/dev/null 2>&1 || ! command -v python3 >/dev/null 2>&1; then
  mods "[THERMAL] eco skipped: openssl/python3 unavailable"
  exit 0
fi

odm="$work_dir/build/baserom/images/odm"
vendor="$work_dir/build/baserom/images/vendor"

normal=""
for candidate in "$odm/etc/thermal-normal.conf" "$vendor/etc/thermal-normal.conf"; do
  if [ -f "$candidate" ]; then
    normal="$candidate"
    break
  fi
done

if [ -z "$normal" ]; then
  mods "[THERMAL] eco skipped: thermal-normal.conf not found"
  exit 0
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
keyhex="746865726d616c6f70656e73736c2e68"

decrypt_conf() {
  src="$1"
  dst="$2"

  # Xiaomi thermal profiles can be plaintext or AES-128-CBC encrypted.
  # Try the stock Xiaomi format first; fall back to plaintext when needed.
  if openssl enc -d -aes-128-cbc -K "$keyhex" -iv "$keyhex"       -in "$src" -out "$dst" 2>/dev/null; then
    if grep -q '^\[' "$dst" 2>/dev/null; then
      printf '%s' encrypted
      return 0
    fi
  fi

  cp -f "$src" "$dst"
  if grep -q '^\[' "$dst" 2>/dev/null; then
    printf '%s' plaintext
    return 0
  fi

  return 1
}

encrypt_or_copy() {
  fmt="$1"
  src="$2"
  dst="$3"

  if [ "$fmt" = encrypted ]; then
    openssl enc -aes-128-cbc -K "$keyhex" -iv "$keyhex"       -in "$src" -out "$dst"
  else
    cp -f "$src" "$dst"
  fi
}

normal_plain="$tmp/thermal-normal.conf"
normal_fmt="$(decrypt_conf "$normal" "$normal_plain")" || {
  mods "[THERMAL] eco skipped: unsupported thermal-normal.conf"
  exit 0
}

# Eco policy:
# - Preserve Xiaomi sensors, charging limits, critical/emergency protection,
#   brightness, modem and GPU policy exactly as stock.
# - Only make CPU thermal caps step down one stock stage earlier once warm.
# - Every replacement uses a frequency already present in the stock profile.
python3 - "$normal_plain" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
lines = path.read_text(encoding="utf-8").splitlines()

sections = []
start = None
for i, line in enumerate(lines + ["[__END__]"]):
    if line.startswith("[") and line.endswith("]"):
        if start is not None:
            sections.append((start, i))
        start = i

changed = []
for start, end in sections:
    block = lines[start:end]
    device = None
    target_idx = None

    for rel, line in enumerate(block):
        parts = line.split()
        if len(parts) >= 2 and parts[0] == "device":
            device = parts[1]
        if parts and parts[0] == "target":
            target_idx = start + rel

    if device not in {"cpu0", "cpu6"} or target_idx is None:
        continue

    parts = lines[target_idx].split()
    vals = parts[1:]
    if len(vals) < 3:
        continue

    # Keep the coolest stock stage intact. From the next thermal stage onward,
    # use the following stock cap. This is deliberately mild to avoid UI lag.
    eco = [vals[0]] + [vals[min(i + 1, len(vals) - 1)] for i in range(1, len(vals))]
    if eco != vals:
        lines[target_idx] = "target\t" + "\t".join(eco)
        changed.append((device, vals, eco))

if not changed:
    raise SystemExit(3)

path.write_text("\n".join(lines) + "\n", encoding="utf-8")
for dev, old, new in changed:
    print(f"{dev}: {' '.join(old)} -> {' '.join(new)}")
PY
patch_status=$?

if [ "$patch_status" -ne 0 ]; then
  mods "[THERMAL] eco skipped: compatible CPU curves not found"
  exit 0
fi

normal_new="$tmp/thermal-normal.new"
encrypt_or_copy "$normal_fmt" "$normal_plain" "$normal_new" || {
  mods "[THERMAL] eco skipped: failed to rebuild thermal-normal.conf"
  exit 0
}

cp -f "$normal_new" "$normal"
chmod --reference="$normal" "$normal" 2>/dev/null || true

# Prevent normal-use performance modes from bypassing Eco.
# Only redirect normal/performance/nolimits profiles. Gaming/camera/charging
# profiles remain untouched so device-specific safety behavior stays stock.
for map in "$odm/etc/thermal-odm-map.conf" "$odm/etc/thermal-map.conf" "$vendor/etc/thermal-map.conf"; do
  [ -f "$map" ] || continue

  map_plain="$tmp/$(basename "$map").plain"
  map_fmt="$(decrypt_conf "$map" "$map_plain")" || continue

  python3 - "$map_plain" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text(encoding="utf-8")
replacements = {
    "[6:thermal-nolimits.conf]": "[6:thermal-normal.conf]",
    "[50:thermal-per-normal.conf]": "[50:thermal-normal.conf]",
    "[500:thermal-hp-normal.conf]": "[500:thermal-normal.conf]",
}
for old, new in replacements.items():
    s = s.replace(old, new)
p.write_text(s, encoding="utf-8")
PY

  map_new="$tmp/$(basename "$map").new"
  encrypt_or_copy "$map_fmt" "$map_plain" "$map_new" || continue
  cp -f "$map_new" "$map"
done

mods "[THERMAL] eco -> mild CPU saving profile enabled; safety limits kept stock"
exit 0
