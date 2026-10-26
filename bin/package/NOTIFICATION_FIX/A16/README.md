# Android 16 notification patches

- **China:** existing CN FrameworkPatcher/PowerKeeper flow is unchanged.
- **Xiaomi.eu:** `EU/zk_patch.py` selectively ports ZK304 notification,
  broadcast, Greeze/freeze/Doze and PowerKeeper methods onto the original EU
  `miui-services.jar` and `PowerKeeper.apk`. It then ports exactly seven
  selected methods from the original Global303 PowerKeeper DEX.
- **Stock EU exceptions:** `KillProcessController.setUidState(IZ)V` and
  `InternationalPolicyManager.getImportantApps()` are never ported from ZK.
- **ZK/Global conflicts:** the patcher rejects overlapping target methods,
  rather than silently letting Global overwrite ZK.
- **PowerModeAdapter:** the GPS app list contains only
  `com.google.android.apps.maps`. The 18-app
  `MiuiBatteryIntelligence.MAP_APP` list in `miui-services.jar` stays EU.
- **Global/Taiwan:** the 7 method bodies common to both ROMs are loaded
  from verified **Global303 Xiaomi 15 (dada, WOCMIXM)** `global.dex`, not
  reconstructed with regular-expression smali patches. Taiwan-only tablet
  `PadSleepModeController` changes are intentionally excluded.
- **Original EU ABI:** classes, fields and method inventories are kept;
  non-DEX PowerKeeper ZIP members remain unchanged. APK signing becomes
  invalid when DEX content changes; device compatibility must be verified.
- **Donors:** the EU folder requires exactly these three DEX inputs:
  `class/miui-services/classes.dex`, `class/powerkeeper/classes.dex` (ZK304)
  and `class/powerkeeper/global.dex` (Global303). No Zstandard, extra
  APK/JAR donors, JSON manifests, resident services or duplicate scripts.
- **Validation:** smali assembly/disassembly, ABI checks, field dependency
  checks, and zipalign. The patch writes its JSON report to
  `build/reports/zk304-eu/port.json` at build time. Actual boot, notification
  delivery and battery behavior still require on-device testing.
