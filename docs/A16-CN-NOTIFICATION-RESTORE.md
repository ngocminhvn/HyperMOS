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

Compared with the retired --cn-notification-fix, this no longer rewrites
DeviceIdleControllerStubImpl or extra SmartPower/location/input classes.

### Scoped Xiaomi.eu force-stop decision (Messenger OneKeyClean fix)

Source comparison: user-supplied A16 Xiaomi.eu `miui-servicesEU.jar`
(SHA-256 `a1b7aeba7347d7722d7c293111537d17d68f8792d58fe176fd2bc48fb0a78b94`)
vs the China A16 `miui-services.jar`
(SHA-256 `00561c82eccd541a1935a4ed608283afdba712234aa5f884f4ba276c17104144`).
Both have a 48-code-unit (28-instruction)
`ProcessManagerService.isForceStopEnable(ProcessRecord,int)` with identical
logic and a single `Build.IS_INTERNATIONAL_BUILD` read; the runtime value
selects EU vs China behavior. EU and China differ in other
`ProcessManagerService` methods (including its constructor), so copying the
whole EU class would risk an incompatible ProcessStarter/PowerManager ABI.

The HyperMOS port changes **only that one read** inside the matching
`isForceStopEnable` method to `const/4 v0, 0x1` (EU international branch),
leaving the remainder of the CN method and class intact. For the observed
`OneKeyClean` and `SwipeUpClean` policies (1 and 7), this chooses the EU
decision not to force-stop packages just to clean recents. It does **not**
disable task/process cleanup itself. The pre-existing policy 13 early return
remains unchanged.

Safety gates fail the build if the method/signature, the unique build-field
read, register v0 or the policy-13 guard/early return differ unexpectedly.
A report is written to `build/reports/frameworkpatcher-a16/notification-gates.json`
under `scoped_eu_force_stop`. Existing FrameworkPatcher
`ProcessSceneCleaner.handleSwipeKill` / `killAppForHasOtherTask` gates
and the `OneKeyClean` invocation are unmodified by this force-stop edit.
PowerKeeper uses three DisplayFrameSetting-only gates and EU-native GMS/Doze
bytecode without the former extra GMS Millet
allowlist injection. No daemon, timer, process pinning or blanket auto-start
permission is added.

**Runtime verification still needed:** on a fresh ROM build, launch Messenger,
clean all recents, verify `stopped=false` and examine
`dumpsys activity exit-info com.facebook.orca`. Then repeat a direct
user-requested Force stop through Settings to make sure that feature remains
functional. Compare notification receipt and idle drain before declaring fixed.

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
Its six originally compared methods and seven *historical* gate counts, the
removed ZK Git blob ID, original EU source SHA-256, retired seven-gate output
SHA-256 and KillProcessController fingerprint are pinned in
`bin/package/NOTIFICATION_FIX/A16/zk_gate_reference_a16.json`.
`eu_zk_scoped_gates.py` verifies the exact EU source, retains native EU
GmsObserver/DeviceIdleController bytes, and checks that only three
DisplayFrameSetting gates (plus DEX header) changed. The new output SHA-256
is reported by the build but is not yet pinned. The older donor
remains recoverable from Git history, not from the current checkout.

The independent `tnm-perfhook-source.dex` is still required as a **compression
reference** for reconstructing EU PowerKeeper from `eu-powerkeeper-from-ryu.zst`;
it is not a runtime PerfHook import and must not be deleted as part of this
cleanup.
