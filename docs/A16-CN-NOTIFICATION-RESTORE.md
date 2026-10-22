# Android 16 CN notification policy — HyperMOS HAOTIAN

## Build execution

CorePatch is executed first and, on Android 16, now accepts only
--disable-signature-verification and --disable-secure-flag.
The old HyperMOS --cn-notification-fix switch and its broad class/region
rewrites have been removed from the Android 16 CorePatch engine.

The existing NOTIFICATION_FIX dispatcher runs:
1. A16/patch.sh (selects China method patch)
2. A16/CN/PowerKeeper.sh (called from A16/patch.sh on China)

FrameworkPatcher A16 port:
- bin/package/NOTIFICATION_FIX/A16/patch.sh
- bin/package/NOTIFICATION_FIX/A16/CN/frameworkpatcher_cn_a16.py

Reference: https://github.com/FrameworksForge/FrameworkPatcher/blob/master/scripts/patcher_a16.sh

The existing FrameworkPatcher entrypoint applies these scoped miui-services rules:
- Force IS_INTERNATIONAL_BUILD reads to true in six upstream classes:
  BroadcastQueueModernStubImpl, ActivityManagerServiceImpl,
  ProcessSceneCleaner, JobServiceContextImpl, NotificationManagerServiceImpl,
  and ActivitySecurityHelper.
- Match the inspected RYU donor by preserving the original international-build
  reads in AlarmManagerServiceStubImpl (1) and AppOpsServiceStubImpl (4).
  Neither true nor false is forced in those two classes.
- Select the enabled RYU-style branches in PreStartFeedbackImpl (1 read) and
  three ProcessPolicy reads using local const true without introducing the
  com.projectryu.Build.IS_RYU_BUILD dependency.
- Preserve the fourth ProcessPolicy read, in
  updateContentCatcherWhitelist()V, as const false per CN ContentExtension.
  This allows settings-driven updates to the com.miui.contentcatcher whitelist.
  Fail closed unless the exact method contains one original v0 field read and
  the three other region reads still exist. No global international-build
  spoofing, new resources, or change to other RYU branches.
- Force Greeze PolicyManager.CN_MODEL=false.
- Match RYU DeviceIdleControllerStubImpl.<clinit> outcome: set
  mIsLowPowerDozeDevice=false immediately before its single static write.
  No other Doze methods, constants, or system-wide DeviceIdle settings change.

The four RYU-adjusted classes are handled inside the existing
frameworkpatcher_cn_a16.py, not a separate patch or workflow. The build fails
if their original read counts differ from the inspected Android 16 layout.
On the supplied China baseline the audited total remains 20 (plus the
separate EU force-stop gate), with ContentCatcher=false and the three other
ProcessPolicy locations=true. Alarm/AppOps preserved policies are unchanged.

Build #160 originally failed because CorePatch's ContentExtension step ran
first, converted one of ProcessPolicy's four IS_INTERNATIONAL_BUILD reads to
const false, and the subsequent FrameworkPatcher strictly expected four
unmodified source reads but found only three. The full ROM patchpackage.sh
now passes HYPERMOS_DEFER_A16_CN_PROCESSPOLICY=1 to CorePatch. On A16 China,
CorePatch skips only that overlapping ProcessPolicy edit; FrameworkPatcher
receives all 4 original reads, retains the ContentCatcher=false branch,
and selects true at the other 3 sites. Standalone CorePatch (without the flag)
and Global ROMs retain their original behavior. Validation still requires all
4 gates; GMS, PowerKeeper, thermal and force-stop gates remain unchanged.
A complete ROM build and on-device test are required for final validation.

PreStartFeedback's build gate is only the fallback when
ro.mi.os.custfeatureresolve is false; otherwise config_td_prestart_intercept
still controls it. ProcessPolicy retains the China resource IDs and all other
instructions, including its conditional cust-feature whitelist loading. The
RYU systemReady resource ID difference is not transplanted into China resources.
No whole RYU classes, extra global build flags or resources are imported.
OneKeyClean/SwipeUpClean, the separate EU force-stop method and PowerKeeper's
seven-gate DEX are unchanged. This change is not proof of an FCM reconnect fix;
device/network-transition validation is still required.

Compared with the retired --cn-notification-fix, only the single
DeviceIdleControllerStubImpl.mIsLowPowerDozeDevice assignment is now adjusted.
Extra SmartPower/location/input classes and all other DeviceIdle methods remain
stock CN. This is a RYU outcome port, not proof of better FCM reconnect or
battery life; measure on-device idle power and notification delivery.

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
PowerKeeper uses the seven-gate EU DEX without the former extra GMS Millet
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
Its six originally compared methods and seven gate counts, the removed
ZK Git blob ID, EU source/output SHA-256 and KillProcessController fingerprint
are pinned in `bin/package/NOTIFICATION_FIX/A16/CN/gate_reference_a16.json`.
`A16/CN/eu_scoped_gates.py` now verifies this manifest, patches EU source only,
then checks exact output bytes with the audited SHA-256. The older donor
remains recoverable from Git history, not from the current checkout.

EU PowerKeeper is now stored in a standalone `eu-powerkeeper.dex.zst`
archive. The historical RYU dictionary DEX and dictionary-based delta are
removed from the active tree. Decompression preserves the exact EU source
and seven-gate runtime output hashes; no PerfHook code is installed.

## GMS control follows the inspected RYU policy

The temporary HyperMOS override from b575b10 is removed at the user's request.
PowerKeeper again installs the exact EU + seven-gate DEX:
64efd5ef111c27b7040c6d89054b72bef9e01d5363075dd348098e866fa6e2f1.
GmsObserver's constructor selects defaultState=false locally, equivalent to
!IS_RYU_BUILD with the inspected RYU Build field set to true. init() and
onCloudUpdated() retain the original Misc.getBoolean("gms_control", default)
result. Persisted/cloud true can enable the observer; false can disable it
through the original cleanup path. No forced-false setting read is retained.

This matches the inspected RYU GmsObserver policy, not the entire RYU ROM.
Cloud endpoint selection, local feature XML, Sleep Mode and other RYU
customizations are not ported by this change. Data is not deleted or rewritten.
In particular, #157's persisted gms_control=true remains effective after a
dirty flash; selecting a false default does not reset it.

#157 evidence remains relevant: observer and application control were enabled,
and the wakelock history shows GMS UID 10203 blocked at 16:58:18 and unblocked
at 17:10:47. Restoring donor behavior is not a demonstrated fix for that event.
The newly supplied miui-frameworkRYU.jar (SHA-256
2b5394d7c5a0a3fcc7bcecb6743fa8bec34de480af82345f19d7c14d420c4696)
contains the same disassembled PowerKeeperPolicy family as #157 (5 classes,
112 methods), including the HTTP network-check backend. RYU runtime cloud
payload and resulting observer state are still unknown.

Validate on device after building/flashing: record persisted flag, observer
and application-control state, reachability/block history during screen-off
Wi-Fi/mobile handovers, actual notifications and idle drain. The expected
observer state now follows persisted/cloud policy; disabled is not an
unconditional PASS criterion. EU cleaner/force-stop logic and thermal remain
unchanged.

