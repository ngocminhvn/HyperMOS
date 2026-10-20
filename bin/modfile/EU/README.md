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
- Every China-only mod checks `bin/ddevice/rom_source.txt` at the start
  of its **own** `update.sh`. There is no central EU skip-list and no special
  filtering in `Universal/insfile.sh` or `UpdateFile/insupdate.sh`.
- `gmsservices` and `gmsservices16` skip Google APK/framework injection.
  `MultiLang` skips China translation overlays.
- `Settings_GoogleShowUpCN`, `GPS_Fix`, `Framework_FixDelayPowerMenu`,
  `Framework_FixDevicePolicy`, `Provisions_RegionPatch`,
  `System_MultiDisableFeature`, `SystemUI_NotificationColorIcon` and
  `Settings_FixNotificationHistory` each preserve the Xiaomi.eu original.
- `bin/ddevice/DEBLOAT/debloat.sh` has its own EU-only checks preserving the
  stock Google apps and EU system updater; all other debloat remains active.
- `bin/package/NOTIFICATION_FIX/notificationFIX.sh` skips Xiaomi.eu. This
  prevents China-specific notification/PowerKeeper DEX transplants.
- On Android 16, CorePatch continues its requested signature/FLAG_SECURE
  patches but does **not** transplant China's Gboard/IME, ContentCatcher or
  NotificationFilterHelper behavior into Xiaomi.eu's native framework.
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
