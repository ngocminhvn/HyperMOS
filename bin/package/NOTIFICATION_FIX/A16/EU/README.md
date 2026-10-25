# Xiaomi.eu A16: scoped GMS FCM delivery and wakelock protection

The original Xiaomi.eu #170 skipped notification patches. HyperMOS's EU A16
path now changes **only** the following sites inside
`/system_ext/framework/miui-services.jar`:

- **BroadcastQueueModernStubImpl.checkApplicationAutoStart**: allow only GMS
  `com.google.android.c2dm.intent.RECEIVE` broadcasts; original EU checks
  remain for all other traffic.
- **GreezeManagerService.isAllowBroadcast**: allow the matching GMS C2DM event
  to eligible apps, preserving the original frozen-receiver thaw/cache path
  and unrelated broadcasts.
- **PowerManagerServiceImpl.isWakelockDisabledByPolicy**: when PowerKeeper
  would block a wake lock, permit the exception only if the lock tag is
  `GCM_WORK` or `GCM_CONN_ALARM`, its actual owner package is
  `com.google.android.gms`, and its real-owner UID equals the WakeLock's
  `mOwnerUid`. Continue into the existing Greeze `UidFrozen` and
  `isWakeLockLimit` checks; those are **not bypassed**.
- **PowerManagerServiceImpl.setUidPartialWakeLockDisabledState**: handle the
  *existing-lock* path as well. When PowerKeeper attempts to disable an
  already-held protected GMS lock, re-evaluate the regular policy (including
  Greeze) instead of forcing disabled. Otherwise use original behavior.

All other wakelocks (including other GMS wakelocks), UIDs, broadcasts,
freeze/kill controls, Doze, thermal, and policy methods are unchanged.
The GMS UID is obtained dynamically from the actual lock: `10140` is not
hardcoded. No PackageManager IPC, keepalive worker, timer, or daemon is added.
`PowerKeeper.apk`, including its original Xiaomi.eu signature, is untouched.
`services.jar` and `miui-framework.jar` are untouched.

Why both sites? EU309 PowerKeeper's `GmsObserver` can block all wakelocks
for the Google-app UID set after `googleNetworkDisconnect`; the blocking
policy is evaluated when wakelocks are acquired, **and** an immediate
`setUidPartialWakeLockDisabledState` call can change locks already held.
Protecting just one path is insufficient. The underlying network feedback,
GMS network/DNS restrictions, and alarm policies remain original and may
still affect FCM reliability.

Only `ProcessPolicy.updateContentCatcherWhitelist()` remains in the EU
`ryu_policy.json`. The three unrelated overrides
`PackageManagerServiceImpl.canBeUpdate()`,
`PackageManagerServiceImpl.verifyIsolationViolation()` and
`ActivitySecurityHelper.getMalwareBlockingIntent()` have been removed
**from NOTIFICATION_FIX only**. The independent CorePatch pipeline is
unchanged; it may still patch overlapping package-manager methods when enabled.
The other 15 broad RYU overrides remain removed.

Build process:
1. Decode `miui-services.jar` using existing CorePatch helper.
2. Apply independent methods, FCM Autostart/Greeze, then
   `fcm_wakelock.py`. The wakelock patch aborts on unexpected method ABI.
3. Recompile, ZIP-test, decompile the final DEX and structurally verify
   all patches (including GMS wakelock guard and preserved Greeze checks).
4. Replace the build's system_ext JAR only if verification passes.

**Experimental:** Smali patching and local source verification do not prove
that the complete ROM boots or that missed notifications are fixed. Verify
a real EU309 build, cold boot, FCM with screen off, prolonged standby, and
Wi-Fi/mobile transitions. Compare battery temperature and idle drain before
and after. If a wake lock's owning package differs from
`com.google.android.gms`, the exception is intentionally not applied.
