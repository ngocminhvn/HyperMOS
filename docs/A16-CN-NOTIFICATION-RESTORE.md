# Android 16 CN notification policy — HyperMOS HAOTIAN

## Build execution

CorePatch is executed first and, on Android 16, now accepts only
--disable-signature-verification and --disable-secure-flag.
The old HyperMOS --cn-notification-fix switch and its broad class/region
rewrites have been removed from the Android 16 CorePatch engine.

The existing NOTIFICATION_FIX dispatcher runs:
1. A16/FrameworkPatcher.sh
2. A16/PowerKeeper.sh

FrameworkPatcher A16 port:
- bin/package/NOTIFICATION_FIX/A16/FrameworkPatcher.sh
- bin/package/NOTIFICATION_FIX/A16/frameworkpatcher_cn_a16.py

Reference: https://github.com/FrameworksForge/FrameworkPatcher/blob/master/scripts/patcher_a16.sh

Port only the upstream notification behavior in miui-services.jar:
- Force IS_INTERNATIONAL_BUILD reads to true in the eight upstream classes:
  BroadcastQueueModernStubImpl, ActivityManagerServiceImpl,
  ProcessSceneCleaner, JobServiceContextImpl, AlarmManagerServiceStubImpl,
  NotificationManagerServiceImpl, AppOpsServiceStubImpl,
  and ActivitySecurityHelper.
- Force Greeze PolicyManager.CN_MODEL=false.

Compared to previous HyperMOS --cn-notification-fix, this **does not**
rewrite DeviceIdleControllerStubImpl, ProcessManagerService or other extra
SmartPower / location / input classes.

This is a self-contained, pinned-in-repository port; ROM builds do not
download the upstream project. Integration adds fail-closed checks when no
gates or Greeze assignment are found, supports differing Greeze registers,
and reports gate counts at
build/reports/frameworkpatcher-a16/notification-gates.json.

Do NOT import upstream FrameworkPatcher signature bypass, FLAG_SECURE,
Gboard, Kaorios, optimization, or Magisk/KSU module packaging. Those paths
are already managed independently by HyperMOS.

The two-method EU NotificationFilterHelper port in miui-framework.jar remains
enabled through CorePatch; it does not overlap FrameworkPatcher's
miui-services.jar notification classes. PowerInsightPolicy is not changed.

The current EU PowerKeeper DEX, scoped gates, thermal configuration and
TNM CPU controller are left untouched. A full ROM build and physical
HAOTIAN idle/notificaton tests are still required to establish runtime parity.

## Compact ZKOS gate evidence (PowerKeeper)

The PowerKeeper EU build no longer requires an uploaded ZKOS `classes.dex`.
Its six originally compared methods and seven gate counts, the removed
ZK Git blob ID, EU source/output SHA-256 and KillProcessController fingerprint
are pinned in `bin/package/NOTIFICATION_FIX/A16/zk_gate_reference_a16.json`.
`eu_zk_scoped_gates.py` now verifies this manifest, patches EU source only,
then checks exact output bytes with the audited SHA-256. The older donor
remains recoverable from Git history, not from the current checkout.

The independent `tnm-perfhook-source.dex` is still required as a **compression
reference** for reconstructing EU PowerKeeper from `eu-powerkeeper-from-ryu.zst`;
it is not a runtime PerfHook import and must not be deleted as part of this
cleanup.
