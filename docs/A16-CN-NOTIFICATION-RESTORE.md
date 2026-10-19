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

The existing FrameworkPatcher entrypoint applies these scoped miui-services rules:
- Force IS_INTERNATIONAL_BUILD reads to true in six upstream classes:
  BroadcastQueueModernStubImpl, ActivityManagerServiceImpl,
  ProcessSceneCleaner, JobServiceContextImpl, NotificationManagerServiceImpl,
  and ActivitySecurityHelper.
- Match the inspected RYU donor by preserving the original international-build
  reads in AlarmManagerServiceStubImpl (1) and AppOpsServiceStubImpl (4).
  Neither true nor false is forced in those two classes.
- Select the enabled RYU-style branches in PreStartFeedbackImpl (1 read) and
  ProcessPolicy (4 reads), using local const true instead of adding a dependency
  on com.projectryu.Build.IS_RYU_BUILD. These are the audited donor callsites;
  the RYU Build field definition was not available, so this explicitly selects
  its enabled branch rather than claiming measured runtime parity.
- Force Greeze PolicyManager.CN_MODEL=false.

The four RYU-adjusted classes are handled inside the existing
frameworkpatcher_cn_a16.py, not a separate patch or workflow. The build fails
if their original read counts differ from the inspected Android 16 layout.
On the supplied China baseline the replacement count remains 20 (plus the
separate EU force-stop gate): five former Alarm/AppOps replacements are removed
and five PreStartFeedback/ProcessPolicy replacements are added.

PreStartFeedback's build gate is only the fallback when
ro.mi.os.custfeatureresolve is false; otherwise config_td_prestart_intercept
still controls it. ProcessPolicy retains the China resource IDs and all other
instructions, including its conditional cust-feature whitelist loading. The
RYU systemReady resource ID difference is not transplanted into China resources.
No whole RYU classes, extra global build flags or resources are imported.
OneKeyClean/SwipeUpClean, the separate EU force-stop method and PowerKeeper's
seven-gate DEX are unchanged. This change is not proof of an FCM reconnect fix;
device/network-transition validation is still required.

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

The historical seven PowerKeeper gates, thermal configuration and
TNM CPU controller are retained. See the additional GMS policy fix below.
A full ROM build and physical
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

## GMS reachability control — #157 runtime finding

The uploaded #157 PowerKeeper classes.dex exactly matched EU + seven gates
(SHA-256 64efd5ef111c27b7040c6d89054b72bef9e01d5363075dd348098e866fa6e2f1).
Device evidence showed persisted gms_control=true, newChina cloud sync, and
both Gms observer/application control enabled. GMS was UID 10203. Reachability
turned false at 16:39:37 and 16:58:18; the retained wakelock history records
UID 10203 blocked at 16:58:18 and unblocked at 17:10:47. This confirms that
selecting defaultState=false alone did not disable the runtime controller.

GmsObserver.init() and onCloudUpdated() read the persisted flag in preference
to that default. onGoogleReachabilityChanged(false) requests wakelock blocking
and queues updateGmsState(true), whose guarded path requests gms_wall, a DNS
UID rule and alarm policy. The device history confirms the wakelock manager
call returned without RemoteException; it does not prove backend firewall/DNS
success or identify the exact MCS socket failure. Diagnostics causality and
an end-to-end reconnect fix remain unverified.

The existing eu_zk_scoped_gates.py now first verifies the original seven-gate
output against the frozen manifest, then changes only the move-result v0 after
Misc.getBoolean(Context,String,boolean) in those two methods to const/4 v0, 0.
Both are one code unit; instruction lengths, branches, try ranges and DEX size
stay unchanged. The original read executes but its result is ignored.
Existing disableGms() cleanup remains intact. Exact input/output hashes and
the two method-scoped invocation patterns are checked before writing output.
Final DEX SHA-256: c5f3d2d47c9c49e1fdb2715b93ee04f2407f2848f599717561ccb692ce09e3f1.

This is an additional HyperMOS policy fix based on device evidence, not a
claim of exact RYU parity. Cloud endpoint selection, Sleep Mode, thermal,
PerfHook, EU KillProcessController, Android Doze/standby/network policy and
the existing EU OneKeyClean/SwipeUpClean behavior are not modified.
No daemon, polling, global build flag, settings/database deletion or blanket
application whitelist is introduced. The stored gms_control may still read
true; the runtime observer must report disabled after flashing and rebooting.

Validation on the new build: verify observer disabled after boot and after a
normal cloud update; repeat Wi-Fi/mobile transitions with screen off and send
timestamped messages without opening Diagnostics. There must be no new
GmsObserver wakelock-block history. Confirm idle drain and normal app cleanup.
Full ROM/ART/device tests remain required; disabling this OEM control can
change GMS network retry/idle drain where Google endpoints are unreachable.


