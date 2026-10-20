# Xiaomi.eu ROM customization

This directory runs **only** for a ROM whose source filename starts with
`xiaomi.eu_`. The source identity is stored in
`bin/ddevice/rom_source.txt` independently of the ROM's China-derived version
suffix `CNXM` or the legacy `device_type.txt` region.

- EU-only `mi_ext/etc/build.prop` cleanup works across devices and versions: `ro.product.mod_device=<codename>_xiaomieu[_region]` becomes `ro.product.mod_device=<codename>_global` (preserves the international `_global` marker; compatibility with EU-specific runtime checks still needs on-device verification); delete the `ro.build.host` property key (any value) and property keys `ro.xiaomi.developerid`, `ro.xiaomi.eu.ota_device`, `ro.xiaomi.eu.version.code_time` regardless of their values. Other properties stay untouched; no property post-check in `verify.sh`. China builds are unchanged.
- `System_MultiDisableFeature/update.sh` skips its memory-extension and priv-app property rewrites on EU when the target value is already absent (as on EU 3.0.309); it still applies them if a future EU base has a value needing replacement. Audio safety props, recovery-image cleanup and theme-permission logic retain their existing behavior. China is unchanged.
- `update.sh`: remove the exact app containers `XiaomiEUExt`,
  `XiaomiEUInject` and `MiuiExtraPhoto` from the **extracted Xiaomi.eu build
  tree**, checking standard `app`/`priv-app` locations across relevant
  partitions. Missing components are silently ignored. This never touches
  the China build or a connected phone.
- `verify.sh`: after all shared mods, ensure none of these three app
  containers have been reintroduced and Kashi MiuiHome is still installed.
- Every China-only mod checks `bin/ddevice/rom_source.txt` at the start
  of its **own** `update.sh`. There is no central EU skip-list and no special
  filtering in `Universal/insfile.sh` or `UpdateFile/insupdate.sh`.
- `gmsservices` and `gmsservices16` skip Google APK/framework injection.
  `MultiLang` skips China translation overlays.
- `Settings_GoogleShowUpCN`, `GPS_Fix`, `Framework_FixDelayPowerMenu`,
  `SystemUI_NotificationColorIcon`, `Settings_FixNotificationHistory` and
  `Framework_FixDevicePolicy` keep the Xiaomi.eu originals.
  `Framework_FixDevicePolicy` is China-only because the EU
  `SystemServerImpl` has no `enforceVersionPolicy()` to patch.
- `Provisions_RegionPatch` and `System_MultiDisableFeature`
  intentionally **run for Xiaomi.eu** using the same mod logic as China.
- `bin/ddevice/DEBLOAT/debloat.sh` has its own EU-only checks preserving the
  stock Google apps and EU system updater; all other debloat remains active.
- `bin/package/NOTIFICATION_FIX/notificationFIX.sh` skips Xiaomi.eu. This
  prevents China-specific notification/PowerKeeper DEX transplants.
- On Android 16, CorePatch continues its requested signature/FLAG_SECURE
  patches but does **not** transplant China's Gboard/IME, ContentCatcher or
  NotificationFilterHelper behavior into Xiaomi.eu's native framework.
- Unlisted steps still use the existing HyperMOS pipeline, including Kashi
  launcher, CorePatch, AVB, Kaorios, TNM and other UpdateFile mods.
  No code or skip behavior for the China build is changed.

For Xiaomi.eu ZIPs with sparse `images/super.img.N`, the build merges and
extracts their logical partitions. SourceForge URLs use the same downloader as
the dump workflow.

The original China build path and its notification fix remain unchanged.
EU runtime compatibility with all China-oriented mods still requires a full
test build and device verification; do not mistake passing build steps for
proven runtime compatibility.
