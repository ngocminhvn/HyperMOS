# RYUOS vs HyperMOS: concrete battery/background and thermal deltas

Device: Xiaomi 15 Pro / HAOTIAN / Android 16. Baselines compared: existing HyperMOS main code; RYU original HAOTIAN PowerKeeper APK extracted by GitHub Actions; experimental branch test-ryu-performance-haotian. Source-level conclusions only: no actual on-device A/B measurement has passed.

## 1. Background apps, PowerKeeper and notifications

| Component | HyperMOS main build script | RYU original confirmed behavior | Current test branch |
| --- | --- | --- | --- |
| GmsObserver.isGmsControlEnabled() | Replaces method with constant false (skips Xiaomi GMS control logic) | Method logic intact, same as Xiaomi stock according to original PowerKeeper parity | Retains original implementation |
| GmsObserver constructor and updateGoogleSync(Z) | Not matched to RYU's two original build gates | Uses IS_RYU_BUILD instead of IS_INTERNATIONAL_BUILD; 56/58 GmsObserver methods match stock | Patches both build gates to the RYU=true outcome |
| Millet no-restrict list | Boot-time helper forcibly appends com.google.android.gms to MILLET_NO_RESTRICT_APP | No equivalent forcibly-appending helper demonstrated in original RYU APK | Helper not added |
| KillProcessController.setUidState(IZ)V | Script tries to remove ProcessManager.kill() and change stop uid log to ignore stop uid (ZKOS technique); build may fail if its expected old layout does not exist | Adds shouldKillByCheckerPolicy(I)Z, invokes ProcessManager.kill only for matching policy states (documented POLICY 1/2) | Method-level RYU selective patch, with exact original-hash guards |
| GMS sysconfig allowances | GMS, GSF and Play Store all get allow-in-power-save, allow-in-data-usage-save and bg-restriction-exemption in custom file | The exact original RYU complete effective sysconfig has NOT been exhaustively compared | Retains only the three GMS entries; removes six *additional* GSF/Play Store entries in custom XML, but other sysconfig may still grant exemptions |
| ActiveStateController | From Xiaomi base plus any other HyperMOS integration | Actual RYU vs Xiaomi stock: all 49 of 49 methods identical | No transplant needed for that class |
| DeviceIdleController within PowerKeeper | Xiaomi base | Actual RYU vs stock: all 28 of 28 methods identical | No transplant needed for that class |
| framework BroadcastQueueModernStubImpl.checkApplicationAutoStart | Xiaomi/HyperMOS notification logic | RYU checks existing ResolveInfo / ApplicationInfo / UID then the C2DM action with its RYU build gate | Test replaces precisely the effective gate in Xiaomi branch |
| framework ProcessSceneCleaner | Previous HyperMOS CN/notification fixes | RYU enables stock foreground-service guard and uses FGS during swipe/task cleanup | RYU-compatible selective FGS gate patch |
| framework DeviceIdleControllerStubImpl.mIsLowPowerDozeDevice | Stock/previous ROM value | Effective false under RYU build flag | Field forced false as a targeted A16 experiment |
| framework ProcessManagerService.isForceStopEnable | Existing base handling | RYU differs with false for its relevant gate | Intentionally NOT ported: maintaining user-requested force-stop |
| framework NotificationManagerServiceImpl.checkFullScreenIntent | Existing Android/AppOp guard | RYU has an AppOp-related bypass | Intentionally NOT ported: unrelated to battery and changes permission protection |

Evidence: genuine RYU APK and docs/RYU-A16-NOTIFICATION-BATTERY-TEST.md; on-main bin/package/NOTIFICATION_FIX/A16/PowerKeeper.sh; this-branch PowerKeeper.sh; the separate GMS XMLs. Main's script is **not proof the patch succeeded in the last flashed ROM**; runtime requires a successful build and APK verification.

Important: The code-level differences can change wakeups, app persistence and GMS processes, but CANNOT by themselves establish what causes TikTok screen-on heat. Video decoding, FPS, brightness and SoC scheduling also matter.

## 2. RYU thermal files — what was actually extracted

Original RYU archive has 23 ODM thermal-*.conf profiles, including:

| Original path | Bytes | Format observed | Installed by test branch? |
| --- | ---: | --- | --- |
| odm/etc/thermal-normal.conf | 5968 | Opaque binary | No |
| odm/etc/thermal-hp-normal.conf | 4352 | Opaque binary | No |
| odm/etc/thermal-per-normal.conf | 6064 | Opaque binary | No |
| odm/etc/thermal-video.conf | 4240 | Opaque binary | No |
| odm/etc/thermal-per-video.conf | 4240 | Opaque binary | No |
| odm/etc/thermal-mgame.conf | 2880 | Opaque binary | No |
| odm/etc/thermal-hp-mgame.conf | 3120 | Opaque binary | No |
| odm/etc/thermal-charge.conf | 4336 | Opaque binary | No |
| odm/etc/thermal-chg-only.conf | 3519 | Readable text, thermal/charge controls | No |
| odm/etc/thermal-odm-map.conf | 3888 | Opaque binary, mapping purpose inferred from filename | No |
| odm/etc/thermal-tgame.conf | 16 | Opaque, same SHA256 as nolimits | No |
| odm/etc/thermal-nolimits.conf | 16 | Opaque, same SHA256 as tgame | No |

Do not infer temperature thresholds or safety behavior from opaque binary filenames. We also lack actual Xiaomi-stock hashes for these files, so **we have NOT proven which are custom edits**. Some may be byte-identical stock files.

The existing test branch imports 10 RYU XML configurations, including vendor/etc/perf/thermalbreakboostconfig.xml, **not** these ODM thermal safety profiles. These XMLs control perf/powerhint behavior and do not replace the thermal-service safeguards.

Example from genuine RYU XML for scroll hint 4224, scene 0/1: at 35 Celsius, Target0 and Target1 CPU6 ceiling is 4,089,600 kHz while Target2 is 3,072,000 kHz. At 37 Celsius, Target0/Target1 = 2,649,600 kHz, Target2 = 2,438,400 kHz. At 39 Celsius, all three are 2,246,400 kHz. These are event boosts, not permanent CPU caps; Target labels are not automatically one-to-one with PerfHook modes.

## 3. Why thermal.conf was not blindly copied

Replacing a normal/video/game/charging profile can change hardware thermal mitigations, not just energy/perf choices. RYU and Xiaomi stock share device code HAOTIAN, but the actual loaded thermal engine, file format, sensor mapping and firmware/driver compatibility must be established first. Same device label does not establish byte-for-byte compatibility or that protection cutoffs are preserved.

**To determine the differences precisely:** run .github/workflows/ryu-vs-stock-thermal.yml on this test branch against Xiaomi stock OS3.0.308.0 Fastboot from MiFirm. Compare each thermal-*.conf SHA256. Binary changes need format-aware decoding and on-device thermal safety validation; simply seeing different hashes is not enough to conclude a configuration is cooler.

The RYU PerfHook source is wired for a separate test APK recompilation; compilation and real-device execution have not yet been confirmed. Treat claimed complete parity as unverified.

All experimental work stays on test-ryu-performance-haotian; main remains unchanged.
