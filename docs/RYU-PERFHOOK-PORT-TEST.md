# RYU PerfHook on Xiaomi 15 Pro — isolated integration test

Branch: **test-ryu-performance-haotian**. Do not merge into main based on compilation alone.

## Ported

- Original PerfHook class family, taken at build time from the original RYUOS HAOTIAN PowerKeeper APK archived by the user's own GitHub Actions.
- Recursive RYU-private class dependency closure; validate that Xiaomi PowerKeeper classes referenced by PerfHook exist in the base.
- Original two-stage initialization: `PerfHook.getInstance(Context)` **followed by** `PerfHook.init()`, run near the end of stock `PowerKeeperApplication.onCreate()`.
- A separate new DEX stores the RYU classes; the original Xiaomi application class receives one guarded helper call. No global RYU APK replacement.
- RYU PowerKeeper selective GMS gates, conditional UID-kill logic, notification/Doze changes already on this test branch.
- Ten original RYU `powerhint.xml` and Qualcomm `perf/*.xml` configuration files. SHA256 and XML structure are verified before replacement.

Original PowerKeeper APK SHA256: `7783b8581deeaf2c39d4fdf04d68a724b9f9c2d0fdf2604b866b399efca27108`.

## Tests and safeguards

- Verified against actual RYU `classes.dex` metadata: `getInstance(Context)` and `init()V` are both invoked in the original PowerKeeper `onCreate`.
- `ryu-perfhook-port-preflight.yml`: source APK decode, original callsite detection, dependency closure, unit tests, synthetic multidex APK reassembly.
- `ryu-powerkeeper-parity.yml`: downloads real Xiaomi stock PowerKeeper and runs GMS, KillProcessController, PerfHook insertion plus full APKEditor reassembly.
- `build.yml`: one-click test branch workflow now regenerates the RYU reference config artifact first, then fetches the SHA256-pinned original RYU PowerKeeper APK, validates all inputs and builds the ROM.
- Tests fail on unknown class dependencies, changed original callsite, duplicate initialization or unsupported stock APK structure; never silently build a partial fake-RYU ROM.
- Keep Xiaomi thermal trip points, thermal engine and charging protections; only the RYU perf/power hint configs and PerfHook runtime were introduced.

## Verify on the actual phone (read-only diagnostics)

After flashing the **test branch only**, from a computer with Android platform-tools:

```bash
adb shell pidof com.miui.powerkeeper
adb shell logcat -d -s ProjectRYU-Perf:I '*:S'
adb shell settings get system projectryu_thermal_profiles
adb shell settings get system projectryu_thermal_per_app
adb shell settings get system projectryu_thermal_sconfig
adb shell dumpsys thermalservice
```

Use ordinary scrolling, video playback and screen-off notification tests for comparison with a known-good HyperMOS build; do not disable the device's thermal safety limits.

**Not yet verified:** actual device boot, startup log, active per-app transitions, CPU/GPU frequency changes, battery life and temperature. A successful static/multidex CI test is necessary but not sufficient for these outcomes. The effective modes also depend on RYU's settings keys and kernel interfaces being available and configured. No claim of 100% behavioral parity until the real device tests pass.
