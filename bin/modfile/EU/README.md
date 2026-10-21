# Xiaomi.eu ROM customization

This directory runs **only** for a ROM whose source filename starts with
`xiaomi.eu_`. The source identity is stored in
`bin/ddevice/rom_source.txt` independently of the ROM's China-derived version
suffix `CNXM` or the legacy `device_type.txt` region.

- EU-only `mi_ext/etc/build.prop` metadata edits are **disabled by default** during bootloop diagnosis: all five properties (`ro.product.mod_device`, `ro.build.host`, `ro.xiaomi.developerid`, `ro.xiaomi.eu.ota_device`, `ro.xiaomi.eu.version.code_time`) are preserved from the source. The old normalization/removal logic is available only when `HYPERMOS_EU_PROP_CLEANUP=1` is explicitly set. China builds are unchanged; EU app cleanup remains active.
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
- Xiaomi.eu SecurityCenter is verified to already return a zero-second permission countdown through `InterceptBaseFragment.j0()`. The build verifies the signed APK and call path, then preserves the original APK byte-for-byte. If a future EU release changes this structure, the build fails before replacing the APK.
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
