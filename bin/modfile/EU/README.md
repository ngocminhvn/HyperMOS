# Xiaomi.eu ROM customization

This directory runs **only** for a ROM whose source filename starts with
`xiaomi.eu_`. The source identity is stored in
`bin/ddevice/rom_source.txt` independently of the ROM's China-derived version
suffix `CNXM` or the legacy `device_type.txt` region.

- EU-only `mi_ext/etc/build.prop` metadata edits are **disabled by default**, matching the bootable #170 behavior. Keep the original `ro.product.mod_device`, `ro.build.host`, `ro.xiaomi.developerid`, `ro.xiaomi.eu.ota_device`, and `ro.xiaomi.eu.version.code_time` untouched. The experimental #171 behavior (normalize `mod_device` to `<codename>_global` and delete the other four keys) is opt-in only with `HYPERMOS_EU_PROP_CLEANUP=1`. No property post-check in `verify.sh`. China builds are unchanged; `MiuiExtraPhoto` remains preserved.
- `System_MultiDisableFeature/update.sh` skips its memory-extension and priv-app property rewrites on EU when the target value is already absent (as on EU 3.0.309); it still applies them if a future EU base has a value needing replacement. Audio safety props, recovery-image cleanup and theme-permission logic retain their existing behavior. China is unchanged.
- `update.sh`: remove only the exact `XiaomiEUExt` and `XiaomiEUInject`
  app containers from the **extracted Xiaomi.eu build tree** in standard
  `app`/`priv-app` locations; missing components are ignored. Temporarily
  **preserve the original `MiuiExtraPhoto`** during bootloop investigation,
  consistent with the RYU-EU reference. China builds are untouched.
- `verify.sh`: after all shared mods, ensure neither of the two removed app
  containers has been reintroduced and Kashi MiuiHome is still installed.
  `MiuiExtraPhoto` is not a removal target or absence requirement.
- Every China-only mod checks `bin/ddevice/rom_source.txt` at the start
  of its **own** `update.sh`. There is no central EU skip-list and no special
  filtering in `Universal/insfile.sh` or `UpdateFile/insupdate.sh`.
- `gmsservices` and `gmsservices16` skip Google APK/framework injection.
  `MultiLang` skips China translation overlays.
- `Settings_GoogleShowUpCN`, `GPS_Fix`,
  `SystemUI_NotificationColorIcon`, `Settings_FixNotificationHistory` and
  `Framework_FixDevicePolicy` keep the Xiaomi.eu originals.
  `Framework_FixDevicePolicy` is China-only because the EU
  `SystemServerImpl` has no `enforceVersionPolicy()` to patch.
- `Framework_FixDelayPowerMenu` runs automatically on Xiaomi.eu OS3,
  without a workflow checkbox. It targets only the literal nested
  `MiuiShortcutTriggerHelper$ShortcutSettingsObserver` class, requires exactly
  three `IS_GLOBAL_BUILD` reads, and re-disassembles the rebuilt DEX before
  replacing the JAR. A mismatch fails the build while retaining the source JAR.
  China ROM behavior and the five EU build properties are unchanged. Device runtime
  behavior (power menu, key shortcuts, lock/unlock) still requires testing.
- `Provisions_RegionPatch` and `System_MultiDisableFeature`
  intentionally run for Xiaomi.eu. Provision requires exactly one
  `checkVersionConsistent()Z` method before changing smali. If it is absent
  the original APK is kept; malformed boundaries fail the build rather than
  overwriting another method.
- `bin/ddevice/DEBLOAT/debloat.sh` has its own EU-only checks preserving the
  stock Google apps and EU system updater; all other debloat remains active.
- `bin/package/NOTIFICATION_FIX/notificationFIX.sh` routes Android 16 Xiaomi.eu
  to its dedicated Global-aligned path. It does not import China PowerKeeper
  DEX or the old four FCM/wakelock exceptions. Only four DADA Global303
  cloud/region method deltas are applied to the original EU PowerKeeper DEX;
  the original APK signature becomes invalid after this change.
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
