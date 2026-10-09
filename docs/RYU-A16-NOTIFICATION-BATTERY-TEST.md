# HyperMOS A16 — RYU-style notification + battery experiment

Branch: `test-ryu-notification-battery-a16` (NOT main)

## Evidence from RYU HAOTIAN HyperOS 3 (Android 16)

Reference: `RYUOS_HAOTIAN_PowerKeeper.apk` extracted from RYUOS
`RYUOS_HAOTIAN_OS3.0.309.0.WOBCNXM_CN261005.zip`.

- `KillProcessController.setUidState(IZ)V` still contains
  `ProcessManager.kill(ProcessConfig)` and both `stop uid=` /
  `ignore stop uid=` branches. RYU does not globally delete this call.
- `GmsObserver.isGmsControlEnabled()Z` has real logic (nontrivial method),
  not an unconditional `false` stub.
- `ActiveStateController.dealNoRestrictApp()V` accesses
  `MILLET_NO_RESTRICT_APP` from settings.
- This RYU APK does **not** define a `MilletConfig` class used by the
  existing HyperMOS A16 patch. Porting that source-level patch from MOS or
  transplanting the full RYU APK would be misleading or incompatible.
- RYU includes `com.projectryu.perf.PerfHook`, custom notify code and
  thermal/per-application frequency hooks. They are **NOT** ported.
- RYU's framework JARs also depend on `com.projectryu.Build.IS_RYU_BUILD`.
  These references are **NOT** imported.

## Changes on this experiment

1. `bin/package/NOTIFICATION_FIX/A16/PowerKeeper.sh` no longer
   modifies, re-signs or replaces `PowerKeeper.apk`. It decodes solely for
   a fail-fast compatibility audit and keeps stock/base APK byte-for-byte.
   Thus the base PowerKeeper retains conditional UID killing, its own GMS
   control and device-specific Millet/Doze/wakelock/thermal policy.
2. `hypermos-google-push-keepalive.xml`: retain GMS FCM delivery
   exemptions and all three implicit-broadcast actions; remove the **extra**
   blanket GSF and Play Store exemptions from this specific custom XML.
   This does not remove GSF/Play Store apps, alter their normal permissions
   or erase any entries from other GMS XML.
3. `validate-sysconfig.py` validates the test variant, with an explicit
   guard against broad GSF/Play Store exemptions in the custom XML.
4. Android 16 CN notification framework policy including Greezer
   `PolicyManager.CN_MODEL=false` remains as on main. In RYU the actual
   `PolicyManager.<clinit>` also derives CN policy from `ro.miui.region`;
   do not fake `ro.miui.region=RYU` on HyperMOS.
5. `ryu_policy_a16.py` patches the *base* `miui-services.jar`
   during the normal A16 COREPATCH stage. It selectively matches RYU:
   - `BroadcastQueueModernStubImpl.checkApplicationAutoStart(...)`: after
     standard Xiaomi widget, NFC and provisioning logic, exempt the exact
     FCM action from the *autostart AppOp outcome only*, and only when
     both AMS-populated `callerPackage` and `callerApp.info.packageName`
     match `com.google.android.gms`. Never grant on action alone.
   - `BroadcastQueueModernStubImpl.updateBlockBroadcast()`: audit
     the target class, preserve unmodified Xiaomi `mSecurityInternal`,
     `isAllowedDeviceProvision()` and secure setting decisions. RYU's
     blanket first-boot override is not imported.
   - `ProcessSceneCleaner.killAppForHasOtherTask(...)`: check
     `hasForegroundServices()` *after* the original other-task decision,
     preserve the original success-return branch and cleanup behavior.
   All changes are guarded by exact method signatures and fail on drift.
6. No `miui-services.jar`, `services.jar`, `framework.jar`
   or `MiuiSystemUI.apk` RYU binaries are copied. The preexisting
   HyperMOS CorePatch/translation/font/TNM/root integration remains intact.

**Faithfulness limitation:** This is a selected *RYU-compatible policy*
experiment, NOT a claim that the ROM has bit-identical notification,
background, Doze or power behavior to RYU. Differences without a verified
portable equivalent stay HyperMOS/base stock.

## Building and testing

Select this branch in GitHub Actions **HyperMOS ROM Build**, use the same
OS3 Android 16 HAOTIAN base as the `main` control, and do not flash this
test onto a different device. A successful static preflight is not enough:
a full ROM build, boot, incoming notifications and real battery usage tests
are required.

Suggested A/B checks on both ROMs under matched conditions:

- 15 minutes ordinary scrolling in Zalo / Facebook / browser, same
  screen brightness, network type, refresh rate and room conditions.
- 20 minutes screen-off standby with 5+ test messages from each
  Zalo, Messenger and Gmail account, tracking sent vs received times.
- Check thermal and activity: `adb shell dumpsys cpuinfo`,
  `adb shell top -b -n 3 -d 2 -m 25`,
  `adb shell dumpsys battery`,
  `adb shell dumpsys batterystats --charged`,
  `adb shell dumpsys thermalservice`.
- Reject this trial if push delivery becomes noticeably slower, if
  PowerKeeper exits/crashes, or if temperature/power is not improved.

If notifications worsen, first restore this branch's PowerKeeper policy and
custom XML to main. Never disable thermal safety or use a RYU `PerfHook`
frequency write as a substitute for diagnosis.

## RYU changes deliberately NOT copied

These RYU behaviors are confirmed in RYU framework bytecode but intentionally
not enabled here to avoid increasing heat, breaking expected user-initiated
force-stop, weakening notification permissions or introducing unsupported
RYU-private classes:

- `updateBlockBroadcast()` first-boot blocker override: could skip
  Xiaomi's provisioning/security-control path, so we preserve the base
  behavior and keep only a structural audit of this method.
- `DeviceIdleControllerStubImpl.mIsLowPowerDozeDevice=false`:
  might worsen power consumption on a hot handset.
- `ProcessManagerService.isForceStopEnable(...)=false`:
  broad inhibition of force-stop can keep apps alive unnecessarily.
- `NotificationManagerServiceImpl.checkFullScreenIntent` AppOp bypass:
  unrelated to FCM delivery and potentially changes user-facing security.
- RYU custom `ProjectRYU Build`, `PerfHook`, per-app governors, updater,
  fake-lock and RYU telemetry. These must remain native HyperMOS.
- Whole-method transplant of Xiaomi services or full RYU PowerKeeper.apk:
  risks dropping HyperMOS's patches and class/permission mismatches.

## One-build trial and acceptance gates

The branch intentionally combines the vetted notification and battery policy
changes in a single build, to reduce the number of device flashes.
`ryu-a16-policy-preflight.yml` tests deterministic edits and unknown-layout
rejection; still **does not prove a working ROM**.

Only flash if the full Android 16 build completes, `miui-services.jar` is
rebuilt and the phone matches HAOTIAN. Compare with current HyperMOS on:
normal Zalo/Facebook browsing for thermal and 20 minutes screen-off push
latency. If it heats more or messages delay, roll back to the previous
known-booting ROM. Keep thermal protection on in both test runs.

## Verification status

- A previous implementation returned `true` immediately on the FCM action
  and returned early from `updateBlockBroadcast()`. Those patches have
  been replaced by an autostart-only conditional plus first-boot audit.
- The RYU real-JAR regression workflow and synthetic policy preflight now
  guard these changes; only a passing CURRENT commit counts.
- The official HAOTIAN 3.0.308.0 stock `system_ext` JAR check workflow
  extracts an independent base and fails on signature drift or assembly
  errors. A completed PASS from that workflow is required before considering
  this branch ready for a ROM flash test.
