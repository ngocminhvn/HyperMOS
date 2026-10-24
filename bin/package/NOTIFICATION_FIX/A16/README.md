# HyperMOS Android 16: independent China and Xiaomi.eu policies

Entry point: bin/package/NOTIFICATION_FIX/A16/patch.sh.

- China: CN/frameworkpatcher_cn_a16.py and CN/PowerKeeper.sh are unchanged.
- Xiaomi.eu (main): EU/patch.sh, EU/ryu_policy.py, EU/ryu_policy.json.
  Exactly 17 selected RYU EU309 method changes in miui-services.jar.
- Xiaomi.eu PowerKeeper.apk: **no RYU power/notification DEX deltas**
  distinct from the excluded PerfHook, custom thermal sysfs, and
  custom FPS-hook changes. Preserve original PowerKeeper completely,
  including its valid digital signature. There is no PowerKeeper
  "verification-only" placeholder pretending to patch the APK.
- No RYU-only class or IS_RYU_BUILD property transplant. The selected
  conditions are taken from miui.os.Build.IS_INTERNATIONAL_BUILD.
- Do not transplant NetworkBoost/game/security hooks unrelated to
  notification delivery. Original EU MiuiBatteryIntelligence
  and device-specific MAP_APP remain untouched.
- The previous Global303/ZK304 policies were preserved on the
  eu_global branch; backupzk.zip remains an inactive reference.
- Patching is method-scoped, with fail-closed smali anchors rather than
  donor JAR/DEX archives or device-specific method SHA256 pins.

No new tests establish on-device boot, notification reliability, idle
battery drain, or heat. These still require a real ROM/device run.
