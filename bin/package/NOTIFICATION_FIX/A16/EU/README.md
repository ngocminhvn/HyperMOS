# Xiaomi.eu A16: minimal FCM wake fix, stock power and thermal

The original Xiaomi.eu #170 skipped the notification stage, but earlier
EU logs recorded Greezer Denial for GMS C2DM broadcast when an app was frozen.
This patch targets the two relevant delivery points rather than copying RYU's
entire power policy or Global/ZK donor files.

- **miui-services.jar / BroadcastQueueModernStubImpl.checkApplicationAutoStart**:
  allow only C2DM intents with the Google Play services caller package.
  Otherwise run the original EU Autostart method, including original
  international-build checks.
- **miui-services.jar / GreezeManagerService.isAllowBroadcast**:
  allow the same GMS/C2DM event to any eligible app, screen on or off.
  Keep native isRestrictReceiver -> thawUidAsync / cached broadcast flow.
  No manually-maintained app whitelist.
- **Four independent old patches retained** in ryu_policy.json:
  ProcessPolicy ContentCatcher, PackageManagerServiceImpl canBeUpdate,
  verifyIsolationViolation, and ActivitySecurityHelper malware gate.
- The other **15 broad RYU overrides** are removed from this active policy:
  ActivityManagerServiceImpl, ProcessSceneCleaner,
  NotificationManagerServiceImpl, AppOpsServiceStubImpl,
  AlarmManagerServiceStubImpl, PolicyManager.CN_MODEL=false and unrelated
  BroadcastQueue international overrides.
- **PowerKeeper.apk** is preserved byte-for-byte including its signature.
  No thermal / FPS / Doze modifications, service/daemon, wake loop or
  root manager dependency.

Patch scripts use exact class/method checks and verify post-assembly
opcode sequences even when baksmali renames labels and drops comments.

**Experimental:** source checks are not proof of boot or reliable FCM.
Run a real EU309 build and test Messenger, Zalo, Gmail, Wi-Fi/LTE,
24–72h standby and heat/power before judging success.
