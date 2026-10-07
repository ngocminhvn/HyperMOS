#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

regionTYPE=$(cat "$work_dir/bin/ddevice/device_type.txt")
GPS_CONF="$work_dir/build/baserom/images/vendor/etc/gps.conf"

# Apply GPS NTP fix to China ROM bases only. Keep Global bases untouched.
if [[ "$regionTYPE" != *"China"* ]]; then
  info "GPS Fix: non-China ROM, skipped"
  exit 0
fi

if [[ ! -f "$GPS_CONF" ]]; then
  info "GPS Fix: vendor/etc/gps.conf not found, skipped"
  exit 0
fi

# Fail-safe layout check: patch only the three known NTP keys and nothing else.
count_ntp=$(grep -c '^NTP_SERVER=' "$GPS_CONF" || true)
count_ntp2=$(grep -c '^NTP_SERVER_2=' "$GPS_CONF" || true)
count_ntp3=$(grep -c '^NTP_SERVER_3=' "$GPS_CONF" || true)

if [[ "$count_ntp" -ne 1 || "$count_ntp2" -ne 1 || "$count_ntp3" -ne 1 ]]; then
  info "GPS Fix: unexpected gps.conf layout, skipped"
  exit 0
fi

mods "GPS Fix"

sed -i \
  -e 's|^NTP_SERVER=.*$|NTP_SERVER=time.cloudflare.com|' \
  -e 's|^NTP_SERVER_2=.*$|NTP_SERVER_2=0.asia.pool.ntp.org|' \
  -e 's|^NTP_SERVER_3=.*$|NTP_SERVER_3=0.vn.pool.ntp.org|' \
  "$GPS_CONF"

if ! grep -qx 'NTP_SERVER=time.cloudflare.com' "$GPS_CONF" || \
   ! grep -qx 'NTP_SERVER_2=0.asia.pool.ntp.org' "$GPS_CONF" || \
   ! grep -qx 'NTP_SERVER_3=0.vn.pool.ntp.org' "$GPS_CONF"; then
  error "GPS Fix: verification failed"
  exit 1
fi

mods "GPS Fix -> Done"
