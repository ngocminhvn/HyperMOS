# Xiaomi.eu Android 16: RYU-derived notification/power policy

The previous Global303/ZK304 implementation is preserved at branch
[eu_global](https://github.com/ngocminhvn/HyperMOS/tree/eu_global).
The active entry is patch.sh, which reads ryu_policy.json via ryu_policy.py.
backupzk.zip is an inactive historical reference.

## What is actually modified

- miui-services.jar: exactly **20** selected method-level RYU-vs-EU309
  changes, using the original EU309 class/method signatures and smali
  instruction anchors rather than copying foreign APK/JAR/DEX archives.
- Classes include BroadcastQueueModernStubImpl (4 methods),
  ActivityManagerServiceImpl (4), ProcessSceneCleaner (2),
  NotificationManagerServiceImpl (2), AppOpsServiceStubImpl,
  AlarmManagerServiceStubImpl, JobServiceContextImpl,
  ProcessPolicy.updateContentCatcherWhitelist and
  Greeze PolicyManager.<clinit> (CN_MODEL=false).
- PackageManagerServiceImpl.canBeUpdate() and
  PackageManagerServiceImpl.verifyIsolationViolation() are reduced to
  return-void, matching the inspected RYU methods.
- ActivitySecurityHelper.getMalwareBlockingIntent() forces its scoped
  international-build read to true, matching the inspected RYU branch.
- International branches use the original
  miui.os.Build.IS_INTERNATIONAL_BUILD checks as their anchors.
  No RYU-only IS_RYU_BUILD field or donor-only class is introduced.

## PowerKeeper.apk: NO patch

Direct DEX comparison between original Xiaomi.eu HAOTIAN EU309 and RYU EU309:

- 18,323 methods are unchanged; nine existing methods changed.
- RYU adds 143 methods in 21 new classes.
- Those nine method changes consist of PerfHook startup (one method),
  custom thermal sysfs paths (four methods), and custom
  projectryu_max_fps / SettingsHelper hooks (four methods).
- GmsObserver.isGmsControlEnabled(), enableGms(), disableGms(),
  ActiveStateController.dealNoRestrictApp() and the inspected
  KillProcessController methods do not have RYU functional changes.
- Therefore PowerKeeper.apk is preserved **byte-for-byte**, rather
  than inventing a no-op method patch. The original APK signing block,
  META-INF, and cryptographic signature remain intact.
- There is no active PowerKeeper script or powerkeeper JSON patch group.

## JAR exclusions and audit boundaries

- services.jar: no new RYU-versus-stock EU309 notification/Doze
  delta identified. Do not copy the China-versus-EU version differences.
- framework.jar changes are chiefly ProjectRYU app-list / feature hooks;
  miui-framework.jar changes do not target pin/FCM delivery.
- Remaining miui-services.jar changes involve NetworkBoost SLA,
  gaming/MiWill, window management, input, device/package security,
  or unrelated platform features. They are deliberately excluded.
- ZK304 getImportantApps(), Global303 PowerKeeper methods, and custom
  HyperMOS Greeze FCM exception are **not** active on main. Restore
  eu_global to test the older approach.
- Keep original EU MiuiBatteryIntelligence / MAP_APP and vendor
  thermal policies; do not add PerfHook, background daemons, or
  broad keepalive rules.

## Validation and limitations

Patcher verifies each target class/method and expected original flag
reads; incompatible layouts stop the build. JSON includes no method
SHA-256 pins. JAR smali is assembled and disassembled for verification.

No Android build or physical device testing is established by source
inspection. RYU-like bytecode does not guarantee RYU-like battery
runtime behavior or eliminate missed FCM messages. Test boot, GMS/FCM
over Wi-Fi and LTE after screen idle, and battery/thermal independently.
