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

1. `bin/package/NOTIFICATION_FIX/A16/PowerKeeper.sh` now audits and
   performs **selective GMS and KillProcessController method patches** to the base PowerKeeper APK:
   in `GmsObserver.<init>` and `updateGoogleSync(Z)` RYUOS reads
   `com.projectryu.Build.IS_RYU_BUILD=true`, while Xiaomi stock reads
   `miui.os.Build.IS_INTERNATIONAL_BUILD=false` on CN ROMs. HyperMOS
   test changes only those original gate results to true and recompiles the
   base APK with the existing APKEditor path. The actual
   `isGmsControlEnabled()`, Millet, Doze and thermal code remain Xiaomi stock.
   The separate `ryu_killprocess_a16.py` applies the verified RYU changes
   only inside KillProcessController. Validate signing/package acceptance
   on device before treating this as production-ready.
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
   - `BroadcastQueueModernStubImpl.checkApplicationAutoStart(...)`: allow
     Xiaomi autostart for the exact FCM RECEIVE action; this does not change
     Android's sender/receiver permission enforcement.
   - `BroadcastQueueModernStubImpl.updateBlockBroadcast()`: after Xiaomi
     security-service setup, leave RYU's first-boot broadcast blocker off.
   - `ProcessSceneCleaner.killAppForHasOtherTask(...)`: on stock HAOTIAN
     Xiaomi already has a `hasForegroundServices()` guard, but executes it
     only when `IS_INTERNATIONAL_BUILD=true`. RYUOS uses
     `IS_RYU_BUILD=true` at precisely this gate. HyperMOS test changes
     only the guard input to `const/4 v2, 0x1`; no duplicate
     `hasForegroundServices()`, no modified `killOnce()`, and no change
     to the original common `return true` exit.
   All changes are guarded by exact method signatures and fail on drift.
6. No `miui-services.jar`, `services.jar`, `framework.jar`
   or `MiuiSystemUI.apk` RYU binaries are copied. The preexisting
   HyperMOS CorePatch/translation/font/TNM/root integration remains intact.

**Faithfulness limitation:** This is a selected *RYU-compatible policy*
experiment, NOT a claim that the ROM has bit-identical notification,
background, Doze or power behavior to RYU. Differences without a verified
portable equivalent stay HyperMOS/base stock.

## Verified Xiaomi-vs-RYU PowerKeeper method parity (2026-10-09)

Actual `RYUOS_HAOTIAN_PowerKeeper.apk` from RYUOS 3.0.309.0 was
compared against `PowerKeeper.apk` extracted from official HAOTIAN
Xiaomi 3.0.308.0 system_ext by the parity workflow:

- GmsObserver: **56 of 58 methods identical** (only two RYU-build gates).
  `isGmsControlEnabled()` itself is identical and must not be reimplemented.
- ActiveStateController: **49 of 49 identical**.
- DeviceIdleController **in PowerKeeper**: **28 of 28 identical**.
  This does not include the separate `miui-services.jar` Doze field patch.
- KillProcessController: RYU adds `shouldKillByCheckerPolicy(I)Z` and
  extends `setUidState(IZ)V` to run the conditional kill branch when the
  existing `mKillProcessAppRuleChecker` yields `POLICY=1` or `POLICY=2`.
  Xiaomi stock already declares the checker field and interface.
  **Ported on this TEST branch as a validated instruction delta**, using
  actual stock and RYU method hashes; method layout mismatches fail closed.
  Policy absent, other values, or checker errors => no newly added UID kill.
  Runtime behavior and battery impact still require testing on device.
- PowerKeeperApplication: RYU invokes a proprietary PerfHook on start.
  HyperMOS intentionally leaves the base APK's app lifecycle alone.

See `.github/workflows/ryu-powerkeeper-parity.yml` and
`bin/audit/ryu_powerkeeper_parity.py`.

A separate, opt-in, event-driven profile manager has been implemented
on the **isolated TNM test branch** `test-ryu-per-app-thermal` in repo
`ngocminhvn/app`. It is **not** a complete PerfHook clone, uses
no RYU-private classes, and has not been added to TNM main/release.

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

- RYU's `DeviceIdleControllerStubImpl.mIsLowPowerDozeDevice=false`
  **is now included** as an isolated one-field patch for HAOTIAN A16.
  This matches the final field value when `IS_RYU_BUILD=true`, not
  a full replacement of DeviceIdleController, and it can change battery
  or push behavior. It is not a claim of improved battery life.
- `ProcessManagerService.isForceStopEnable(...)=false`:
  broad inhibition of force-stop can keep apps alive unnecessarily.
- `NotificationManagerServiceImpl.checkFullScreenIntent` AppOp bypass:
  unrelated to FCM delivery and potentially changes user-facing security.
- RYU custom `ProjectRYU Build`, `PerfHook`, per-app governors, updater,
  fake-lock and RYU telemetry. These must remain native HyperMOS.
- Whole-method transplant of Xiaomi services or full RYU PowerKeeper.apk:
  risks dropping HyperMOS's patches and class/permission mismatches.

## RYU DeviceIdleController flag experiment

`bin/package/COREPATCH/ryu_doze_a16.py` runs in the existing A16
`miui-services.jar` decompile/recompile step under the branch-only
`--ryu-low-power-doze` switch. It changes the final static initialization
write of `mIsLowPowerDozeDevice` to `false`, equivalent to the RYUOS
HAOTIAN `IS_RYU_BUILD` path. It does not import RYU classes, disable the
Android Doze system, rewrite other methods or update root/boot/keystore.

Fail-fast protections: unique class, unique static initializer, unique field
assignment, safe existing register, and idempotency. The preflight exercises
these cases and the real-JAR check assembles the result against RYU JARs.

**Caveat:** This can alter idle/standby behavior and may increase drain;
the effect cannot be inferred from the field name alone. Keep thermal
safeguards and use the ROM test branch only.

## FCM ordering and focused RYU audits (2026-10-09)

- The actual Xiaomi and RYU methods **already contain the C2DM action**.
  The verified RYU delta is a single build flag read immediately after
  `ApplicationInfo.uid`, and before the existing C2DM equality check.
  HyperMOS now replaces the original Xiaomi `IS_INTERNATIONAL_BUILD` read
  at that exact gate with a constant true value, reproducing the effective
  `IS_RYU_BUILD=true` outcome on China ROMs. The original action, labels,
  registers, permission checks and non-FCM branches are preserved.
- The same one-instruction approach is used on
  `ProcessSceneCleaner.handleSwipeKill()`: enable its existing Xiaomi
  `hasForegroundServices()` guard without changing the swipe-kill operation
  or return values. The separate cross-task FGS guard remains unchanged.
- Both edits require the original surrounding instructions and reject
  mismatching layouts. No extra FCM helper, broad GMS whitelist, or daemon
  is installed.
- `bin/audit/ryu_targeted_notification_a16.py` performs a read-only
  cross-JAR comparison of `ProcessSceneCleaner.handleSwipeKill()`,
  `killAppForHasOtherTask()`, `NotificationManagerServiceImpl` methods,
  and `ProcessManagerService.isForceStopEnable()`.
- The actual-stock verification workflow runs this audit against the
  extracted original RYU JAR artifact before patching, and uploads Markdown
  and JSON results. Differences are **audit findings**, not automatic ports,
  because the Xiaomi and RYU base build labels differ.
- `PerfHook`, broad force-stop suppression, and full-screen notification
  AppOp bypasses remain excluded. This preserves device power policy,
  user control and notification permission enforcement.
- Synthetic preflight PASS only verifies patch logic; genuine smali
  reassembly and notification/idle-drain tests remain necessary.

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
