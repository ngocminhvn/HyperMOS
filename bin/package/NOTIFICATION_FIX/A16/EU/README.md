# Xiaomi.eu Android 16 — RYU-style power and notification policy

Previous Global303/ZK304 EU implementation was preserved on branch
eu_global before switching main. Historical policy_deltas.json and backupzk.zip
remain inactive. Active entry: patch.sh -> ryu_policy.json via ryu_policy.py.

## Scope

- miui-services.jar: 17 selected RYU EU309 method-level edits:
  BroadcastQueueModernStubImpl (4); ActivityManagerServiceImpl (4);
  ProcessSceneCleaner (2); AppOpsServiceStubImpl; AlarmManagerServiceStubImpl;
  JobServiceContextImpl; NotificationManagerServiceImpl (2);
  ProcessPolicy.updateContentCatcherWhitelist (RYU false);
  Greeze PolicyManager.<clinit> (RYU CN_MODEL=false).
- Exact target class, method, register and number of original flag reads;
  unknown layouts abort instead of trying donor class replacement.
- Flag mapping: do not add IS_RYU_BUILD or a RYU-only class; the original
  condition being overridden is miui.os.Build.IS_INTERNATIONAL_BUILD. RYU's
  constant true/false branches are reproduced in the selected methods.
- PowerKeeper.apk: RYU EU309 differs from stock EU309 only in PerfHook,
  custom thermal paths and a proprietary FPS setting hook. Those modifications
  are deliberately excluded. GmsObserver.isGmsControlEnabled, enableGms,
  disableGms and ActiveStateController.dealNoRestrictApp match stock EU.
  The script verifies those methods and leaves original EU PowerKeeper APK
  byte-for-byte intact, including ZIP members and valid original signatures.
- services.jar, framework.jar and miui-framework.jar have no new RYU-vs-EU
  FCM or Doze method delta to port. Do not import unrelated security bypasses,
  input-method changes or ProjectRYU hooks.
- The previous ZK304 getImportantApps patch, Global303 seven PowerKeeper
  methods and custom FCM Greeze exception are not invoked in the new main path.
  They remain available on eu_global.

## Limits

This change copies RYU policy choices without claiming improved notification
delivery, better battery or reduced heat. Boot and device tests remain necessary.
Neither vendor thermal protection nor TNM CPU control is changed. No PerfHook,
full donor DEX archives, method SHA-256 pinning or APK re-signing is used.

Keeping APK ZIP metadata when modifying DEX is NOT equal to preserving a
cryptographically valid APK signature. Here the PowerKeeper APK stays valid
because it is not modified at all.
