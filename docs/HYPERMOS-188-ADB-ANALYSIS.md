# HyperMOS #188 ADB analysis (HAOTIAN EU A16)

Analyzed firmware: `OS3.0.309.0.WOBCNXM`, Android 16. The supplied log was
captured from build #188 (`f5d705d6d433a45616d09328cd77bd745f795fba`).

## Findings

| Issue | Classification and cause | Repository path | Resolution / verification |
| --- | --- | --- | --- |
| PowerKeeper ART checksum / `kOatDexOutOfDate` | Confirmed runtime consequence of replacing `classes.dex`: the installed APK checksum did not match the stale `/data/dalvik-cache` artifacts. PowerKeeper stayed alive and ART fell back to `run-from-apk-fallback`; this was not an application crash. | `bin/package/NOTIFICATION_FIX/A16/patch.sh`; active porter under `A16/EU/PowerKeeper_donor.sh` | Keep the requested 61-method ZK304 port active. On the test device, targeted `cmd package compile -m verify -f com.miui.powerkeeper` changed dexopt state to `status=verify` without clearing all Dalvik cache. PowerKeeper remained running. This addresses the observed stale artifact on that installation but does not constitute a fresh-ROM runtime test. |
| FCM registration (`top.nkbe.niagram`) | Not confirmed as a ROM-policy failure. Firebase initialized successfully; Google endpoints were reached; Play services and the app were enabled; notification permission and `RUN_ANY_IN_BACKGROUND` were allowed. One non-retryable `FCM Registration failed!` response occurred after the app restarted. No Greeze denial or background restriction was adjacent to it. This points to the app/GMS/FCM registration exchange, but the supplied log does not expose the server error code needed to distinguish app configuration from GMS state. | No justified ROM change | Keep the scoped ZK304 Greeze/FCM framework path. Do not whitelist all apps or disable Doze/Greeze. Capture verbose Firebase/GMS logs during a fresh app-initiated token request before changing ROM policy. |
| `ProcessSceneCleaner: OneKeyClean` | Confirmed user-triggered cleanup. Immediately before `handleKillAll`, the log records `ACTION_UP` on `com.miui.home`; the cleaner then removes recent tasks and kills their processes in one batch. This is not a periodic SmartPower/Doze action. It can interrupt an in-flight token request, but Niagram restarted before the later FCM failure. | No change | Preserve requested one-key cleanup and RAM management. |
| Scout `JNI_ERR` | Confirmed optional native-load failure, but not attributable to HyperMOS from available evidence. Device `libscout.so` registers `ScoutSystemMonitor`, `ScoutLibraryTestManager`, and `ScoutDisplayMemoryManager`; the corresponding Java classes and observed native signatures exist in the device `miui-services.jar`. The log has no native tombstone and `system_server` continues. Deeper native decompilation was unavailable on this Windows host. | No HyperMOS file replaces `libscout.so` | Do not copy a China/other-ROM library or disable Scout. A matching Xiaomi.eu native/framework pair or a native registration trace is required before a patch. |
| `init` SIGABRT | One current-boot event is present for PID 2785 (not PID 1). `crash_dump` failed and `/data/tombstones` is empty, so the aborting init subprocess and abort message cannot be recovered. Boot completed. | No justified change | Treat as unresolved, non-repeating in the supplied capture. Collect pstore/tombstone data on recurrence. |
| `mNotificationPolicyService is null` | Repeats beyond early boot, so it is not merely a single initialization-order warning. It belongs to `AppContinuityRouterStub`; the supplied log shows no exception, notification drop, or FCM denial caused by it. | No justified change | Keep separate from FCM until a caller-to-drop path is captured. Do not manufacture or globally replace the service. |

## #181 versus #188

The decisive #188 change is in commit `f5d705d6`: it enabled
`PowerKeeper_donor.sh`, ported 61 ZK304 methods, and replaced the EU APK's
`classes.dex`. GitHub Actions run 39905527464 verified that the ROM built and
that non-DEX/META-INF members were preserved, but its own output explicitly
reported `runtime_tested: false`. The device log supplies the missing runtime
evidence: ART rejected the stale compiled artifacts for the modified APK.

The selected route keeps the additional 61-method PowerKeeper APK port active,
alongside the ZK304 NotificationManager policy and eight Greeze/Doze/process
methods. The observed ART state was remediated on the test device with a
package-scoped compile rather than by disabling the port.

## Device-only remediation used

The investigation ran this package-scoped command; it does not clear global
Dalvik cache and does not disable any power policy:

```sh
adb shell cmd package compile -m verify -f com.miui.powerkeeper
adb shell dumpsys package com.miui.powerkeeper
```

The resulting primary-ABI state was `status=verify`, `reason=cmdline`.

## Additional data needed

For a fresh FCM failure, enable focused tags and reproduce token registration
from Niagram without pressing one-key cleanup:

```sh
adb shell setprop log.tag.FirebaseMessaging VERBOSE
adb shell setprop log.tag.FirebaseInstallations VERBOSE
adb logcat -v threadtime FirebaseMessaging:V FirebaseInstallations:V GmsRpc:V MessengerIpcClient:V GCM-DMM:D GCM-GMS-DMM:D '*:S'
```

For a recurring init abort, collect immediately after reboot:

```sh
adb root
adb pull /sys/fs/pstore pstore
adb pull /data/tombstones tombstones
adb logcat -b all -d -v threadtime > boot-all.txt
```

## Verification boundary

Local tests validate patch routing, method porters, metadata preservation, and
shell syntax. Build #188 proves build/pack success only. Runtime notification
latency and idle-drain behavior still require a fresh ROM build and an
on-device idle/FCM test cycle with the active 61-method port.
