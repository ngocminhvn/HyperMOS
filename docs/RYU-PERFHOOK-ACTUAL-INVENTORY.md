# RYU HAOTIAN PerfHook — real APK dependency map

**Status: ANALYSIS ONLY — PerfHook is NOT ported by this workflow.**

RYU PowerKeeper classes: 2974; stock APK supplied: False.
PerfHook family: 20 classes, 124 methods.

## Perf-mode field definitions

- .field private static final KEY_SCONFIG:Ljava/lang/String; = "projectryu_thermal_sconfig"
- .field private static final PERF_MODE_DEFAULT:I = 0x0
- .field private static final PERF_MODE_PERFORMANCE:I = 0x1
- .field private static final PERF_MODE_POWERSAVE:I = 0x2
- .field private static final SCONFIG_PATH:Ljava/lang/String; = "/sys/class/thermal/thermal_message/sconfig"

## Activation call sites

- `Lcom/miui/powerkeeper/PowerKeeperApplication;` → `onCreate()V`

## RYU-private class dependencies

- `Lcom/projectryu/perf/PerfHook;`: 26 method references
- `Lcom/projectryu/perf/PerfHook$CpuPolicy;`: 18 method references
- `Lcom/projectryu/perf/PerfHook$GpuPolicy;`: 9 method references
- `Lcom/projectryu/perf/PerfHook$7;`: 5 method references
- `Lcom/projectryu/perf/PerfHook$FreqBounds;`: 4 method references
- `Lcom/projectryu/perf/PerfHook$10;`: 3 method references
- `Lcom/projectryu/perf/PerfHook$5;`: 3 method references
- `Lcom/projectryu/perf/PerfHook$8;`: 3 method references
- `Lcom/projectryu/perf/PerfHook$9;`: 3 method references
- `Lcom/projectryu/perf/PerfHook$10$1;`: 1 method references
- `Lcom/projectryu/perf/PerfHook$5$1;`: 1 method references
- `Lcom/projectryu/perf/PerfHook$7$1;`: 1 method references
- `Lcom/projectryu/perf/PerfHook$7$2;`: 1 method references
- `Lcom/projectryu/perf/PerfHook$8$1;`: 1 method references
- `Lcom/projectryu/perf/PerfHook$9$1;`: 1 method references
- `Lcom/projectryu/perf/PerfHook$1;`: 1 method references
- `Lcom/projectryu/perf/PerfHook$4;`: 1 method references
- `Lcom/projectryu/perf/PerfHook$6;`: 1 method references
- `Lcom/projectryu/ProjectRYUFramework;`: 1 method references
- `Lcom/projectryu/perf/PerfHook$2;`: 1 method references
- `Lcom/projectryu/perf/PerfHook$3;`: 1 method references

## Relevant PerfHook methods

- `Lcom/projectryu/perf/PerfHook$10$1;` / `<init>(Lcom/projectryu/perf/PerfHook$10;I)V` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook$10;` / `<init>(Lcom/projectryu/perf/PerfHook;Ljava/io/File;I)V` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook$1;` / `<init>(Lcom/projectryu/perf/PerfHook;Landroid/os/Looper;)V` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook$2;` / `<init>(Lcom/projectryu/perf/PerfHook;)V` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook$3;` / `<init>(Lcom/projectryu/perf/PerfHook;Landroid/os/Handler;)V` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook$4;` / `<init>(Lcom/projectryu/perf/PerfHook;Ljava/lang/String;)V` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook$5$1;` / `<init>(Lcom/projectryu/perf/PerfHook$5;)V` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook$5;` / `<init>(Lcom/projectryu/perf/PerfHook;Ljava/io/File;I)V` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook$6;` / `<init>(Lcom/projectryu/perf/PerfHook;)V` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook$7$1;` / `<init>(Lcom/projectryu/perf/PerfHook$7;)V` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook$7$2;` / `<init>(Lcom/projectryu/perf/PerfHook$7;)V` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook$7;` / `<init>(Lcom/projectryu/perf/PerfHook;ILandroid/os/Handler;)V` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook$8$1;` / `<init>(Lcom/projectryu/perf/PerfHook$8;I)V` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook$8;` / `<init>(Lcom/projectryu/perf/PerfHook;Ljava/io/File;ILjava/lang/String;Lcom/projectryu/perf/PerfHook$CpuPolicy;Ljava/lang/String;)V` (private deps: 2; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook$9$1;` / `<init>(Lcom/projectryu/perf/PerfHook$9;)V` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook$9;` / `<init>(Lcom/projectryu/perf/PerfHook;Ljava/io/File;ILcom/projectryu/perf/PerfHook$CpuPolicy;)V` (private deps: 2; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$fgetmAppliedPerfMode(Lcom/projectryu/perf/PerfHook;)I` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$fgetmCurrentForegroundPkg(Lcom/projectryu/perf/PerfHook;)Ljava/lang/String;` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$fgetmDesiredPerfMode(Lcom/projectryu/perf/PerfHook;)I` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$fgetmGlobalSconfigValue(Lcom/projectryu/perf/PerfHook;)I` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$fgetmGpuPolicy(Lcom/projectryu/perf/PerfHook;)Lcom/projectryu/perf/PerfHook$GpuPolicy;` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$fgetmHandler(Lcom/projectryu/perf/PerfHook;)Landroid/os/Handler;` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$fgetmIsHookEnabled(Lcom/projectryu/perf/PerfHook;)Z` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$fgetmIsScreenOn(Lcom/projectryu/perf/PerfHook;)Z` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$fgetmPendingFrequencyApply(Lcom/projectryu/perf/PerfHook;)Ljava/lang/Runnable;` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$fgetmPendingGovernorApply(Lcom/projectryu/perf/PerfHook;)Ljava/lang/Runnable;` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$fgetmPerAppMode(Lcom/projectryu/perf/PerfHook;)Z` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$fgetmPerfHandler(Lcom/projectryu/perf/PerfHook;)Landroid/os/Handler;` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$fgetmScheduledPerfMode(Lcom/projectryu/perf/PerfHook;)I` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$fgetmThermalConfigMap(Lcom/projectryu/perf/PerfHook;)Ljava/util/Map;` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$fputmAppliedPerfMode(Lcom/projectryu/perf/PerfHook;I)V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$fputmCurrentForegroundPkg(Lcom/projectryu/perf/PerfHook;Ljava/lang/String;)V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$fputmPendingFrequencyApply(Lcom/projectryu/perf/PerfHook;Ljava/lang/Runnable;)V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$fputmPendingGovernorApply(Lcom/projectryu/perf/PerfHook;Ljava/lang/Runnable;)V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$fputmPendingPerAppApply(Lcom/projectryu/perf/PerfHook;Ljava/lang/Runnable;)V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$fputmScheduledPerfMode(Lcom/projectryu/perf/PerfHook;I)V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$mapplyCpuMax(Lcom/projectryu/perf/PerfHook;Lcom/projectryu/perf/PerfHook$CpuPolicy;)Z` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$mapplyFrequencyPhase(Lcom/projectryu/perf/PerfHook;I)V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$mapplyGovernorPhase(Lcom/projectryu/perf/PerfHook;I)V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$mcancelPendingPerfTransitions(Lcom/projectryu/perf/PerfHook;)V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$mcheckAndApplyPerAppSconfig(Lcom/projectryu/perf/PerfHook;Ljava/lang/String;)V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$menforceGlobalSconfig(Lcom/projectryu/perf/PerfHook;)V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$menforceGpuMax(Lcom/projectryu/perf/PerfHook;)Z` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$menforceGpuMin(Lcom/projectryu/perf/PerfHook;)Z` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$mgovernorAvailable(Lcom/projectryu/perf/PerfHook;Lcom/projectryu/perf/PerfHook$CpuPolicy;Ljava/lang/String;)Z` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$mhandleScreenOff(Lcom/projectryu/perf/PerfHook;)V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$mhandleScreenOn(Lcom/projectryu/perf/PerfHook;)V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$minitializePerfCacheOnce(Lcom/projectryu/perf/PerfHook;)V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$mreadTrimmed(Lcom/projectryu/perf/PerfHook;Ljava/lang/String;)Ljava/lang/String;` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$mschedulePerAppSconfigApply(Lcom/projectryu/perf/PerfHook;Ljava/lang/String;)V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$mstopAllPerfObservers(Lcom/projectryu/perf/PerfHook;)V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$mupdateConfig(Lcom/projectryu/perf/PerfHook;)V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `-$$Nest$mwriteRawAndVerify(Lcom/projectryu/perf/PerfHook;Ljava/lang/String;Ljava/lang/String;)Z` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `addCpuPolicyToCache(Ljava/io/File;Ljava/util/Set;)V` (private deps: 2; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `applyCpuMax(Lcom/projectryu/perf/PerfHook$CpuPolicy;)Z` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `applyCurrentMode()V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `applyFrequencyPhase(I)V` (private deps: 2; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `applyGovernorPhase(I)V` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `cancelPendingPerfTransitions()V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `checkAndApplyPerAppSconfig(Ljava/lang/String;)V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `collectGovernorDirectoryCandidates(Ljava/io/File;Ljava/util/Set;Ljava/util/Set;)V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `detectNativeGovernor(Lcom/projectryu/perf/PerfHook$CpuPolicy;)Ljava/lang/String;` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `discoverCpuPoliciesOnce()V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `discoverGpuPolicyOnce()V` (private deps: 2; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `enforceGlobalSconfig()V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `enforceGpuMax()Z` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `enforceGpuMin()Z` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `getInstance(Landroid/content/Context;)Lcom/projectryu/perf/PerfHook;` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `governorAvailable(Lcom/projectryu/perf/PerfHook$CpuPolicy;Ljava/lang/String;)Z` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `handleScreenOff()V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `handleScreenOn()V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `initializePerfCacheOnce()V` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `isForcedGovernor(Ljava/lang/String;)Z` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `isPositiveFrequency(Ljava/lang/String;)Z` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `readAvailableGovernors(Ljava/lang/String;)Ljava/util/Set;` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `readCpuInfoBoundsFromSysfs(Lcom/projectryu/perf/PerfHook$CpuPolicy;)Lcom/projectryu/perf/PerfHook$FreqBounds;` (private deps: 2; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `readCurrentSconfig()I` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `readGpuAvailableBoundsFromSysfs(Lcom/projectryu/perf/PerfHook$GpuPolicy;)Lcom/projectryu/perf/PerfHook$FreqBounds;` (private deps: 2; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `requestPerfMode(I)V` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `requestPerfModeForSconfig(I)V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `restoreCpuFrequencyRange(Lcom/projectryu/perf/PerfHook$CpuPolicy;)Z` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `restoreCpuGovernor(Lcom/projectryu/perf/PerfHook$CpuPolicy;)Z` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `restoreGpuDefault()Z` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `schedulePerAppSconfigApply(Ljava/lang/String;)V` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `schedulePerfCacheInitialization()V` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `setupSconfigFileObserver()V` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `startPerfWorker()V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `stopAllPerfObservers()V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `stopObserverMap(Ljava/util/Map;)V` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `watchCpuGovernor(Lcom/projectryu/perf/PerfHook$CpuPolicy;Ljava/lang/String;)V` (private deps: 2; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `watchCpuPerformanceFrequency(Lcom/projectryu/perf/PerfHook$CpuPolicy;Ljava/lang/String;)V` (private deps: 2; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `watchGpuFrequency(Ljava/lang/String;)V` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `writeFrequencyAndVerify(Ljava/lang/String;Ljava/lang/String;)Z` (private deps: 0; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `writeGovernorAndVerify(Lcom/projectryu/perf/PerfHook$CpuPolicy;Ljava/lang/String;)Z` (private deps: 1; direct I/O: False)
- `Lcom/projectryu/perf/PerfHook;` / `writeSconfig(I)V` (private deps: 0; direct I/O: False)

## Referenced settings / node strings

- ` nativeGovernor=`
- `, snapdragonGpu=`
- `/available_frequencies`
- `/cpuinfo_max_freq`
- `/cpuinfo_min_freq`
- `/max_freq`
- `/min_freq`
- `/scaling_available_governors`
- `/scaling_governor`
- `/scaling_max_freq`
- `/scaling_min_freq`
- `/sys/class/kgsl/kgsl-3d0/devfreq`
- `/sys/class/thermal/thermal_message/sconfig`
- `/sys/devices/system/cpu`
- `/sys/devices/system/cpu/cpufreq`
- `Ambiguous global governor candidates for `
- `Ambiguous policy-local governor candidates for `
- `Cached CPU policy `
- `Cached Snapdragon GPU range: `
- `Error handling ForegroundInfo`
- `Failed to cache CPU policy: `
- `Failed to cache Snapdragon GPU devfreq`
- `Failed to initialize PerfHook`
- `Global sconfig=0: thermal/perf idle`
- `Ignoring invalid per-app thermal profile: `
- `Initial reset applied: sconfig=0`
- `Native governor fallback from scaling_governor for `
- `Native governor not resolved at init for `
- `Perf RAM cache ready: cpuPolicies=`
- `PerfHook`
- `PerfHook initialized`
- `PerfHook thermal disabled: `
- `ProjectRYU-Perf`
- `Screen OFF: sconfig=0, perf state returning to default`
- `Unable to watch CPU frequency `
- `Unable to watch CPU governor `
- `Unable to watch Snapdragon GPU frequency `
- `all thermal settings keys are null`
- `android.intent.action.SCREEN_OFF`
- `android.intent.action.SCREEN_ON`
- `cpu`
- `cpufreq`
- `performance`
- `policy`
- `projectryu_thermal_per_app`
- `projectryu_thermal_profiles`
- `projectryu_thermal_sconfig`
- `thermal configuration is incomplete or invalid`

## Guardrails

- Signatures and string hints are not a verified implementation specification.
- Do not assume PERF_MODE or sconfig values have identical effects on Xiaomi stock vs RYU.
- Do not transplant whole APK or unsafe per-app CPU/GPU governor enforcement.
- Device boot and battery/thermal measurements are required after an independent port.
