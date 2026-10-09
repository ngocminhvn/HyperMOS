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
   `PolicyManager.CN_MODEL=false` remains as on main for the first
   iteration. No `miui-services.jar`, `services.jar`, `framework.jar`
   or `MiuiSystemUI.apk` RYU binaries are copied.

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

## Pending RYU FCM BroadcastQueue port

RYU has early handling of `com.google.android.c2dm.intent.RECEIVE`
in `BroadcastQueueModernStubImpl.checkApplicationAutoStart(...)`, but
that JAR also uses RYU-specific classes. Porting the method wholesale or
returning `true` before Android/Xiaomi permission/security checks may
bypass the wrong guard. This branch **does not yet patch that method**.
First compare decompiled method paths against the exact HAOTIAN base and
validate sender/receiver identity and permissions before implementing a
narrow conditional exception. Keeping FCM permissions and GMS sysconfig
prevents an untested notification regression in this round.
