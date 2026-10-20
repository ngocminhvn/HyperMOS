# Xiaomi.eu ROM customization

This directory runs **only** for a ROM whose source filename starts with
`xiaomi.eu_`. The source identity is stored in
`bin/ddevice/rom_source.txt` independently of the ROM's China-derived version
suffix `CNXM` or the legacy `device_type.txt` region.

- `update.sh`: delete exactly `/product/priv-app/XiaomiEUExt` from the
  **extracted build tree**, not from any connected device. Keep
  `/product/priv-app/MiuiExtraPhoto` untouched.
- `verify.sh`: after applying the normal China/shared mods, reject a result
  that has reintroduced XiaomiEUExt or lost the Kashi MiuiHome APK.
- `policy.sh` holds the Xiaomi.eu-only skip list, consumed by the existing
  `Universal/insfile.sh` and `UpdateFile/insupdate.sh` dispatchers.
- No Google APK / framework injection from `gmsservices` or `gmsservices16`.
  Preinstalled EU GMS, Google apps and its updater are preserved by debloat.
- Skip CN MultiLang overlays, Settings_GoogleShowUpCN, GPS_Fix,
  Framework_FixDelayPowerMenu, Framework_FixDevicePolicy,
  Provisions_RegionPatch, System_MultiDisableFeature,
  SystemUI_NotificationColorIcon, and Settings_FixNotificationHistory.
- `bin/package/NOTIFICATION_FIX/notificationFIX.sh` skips Xiaomi.eu. This
  prevents China-specific notification/PowerKeeper DEX transplants.
- Unlisted steps still use the existing HyperMOS pipeline, including Kashi
  launcher, CorePatch, AVB, Kaorios, MiCTS, TNM and other UpdateFile mods.
  No code or skip behavior for the China build is changed.

For Xiaomi.eu ZIPs with sparse `images/super.img.N`, the build merges and
extracts their logical partitions. SourceForge URLs use the same downloader as
the dump workflow.

The original China build path and its notification fix remain unchanged.
EU runtime compatibility with all China-oriented mods still requires a full
test build and device verification; do not mistake passing build steps for
proven runtime compatibility.
