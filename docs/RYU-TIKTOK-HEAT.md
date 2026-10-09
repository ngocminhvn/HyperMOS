# HAOTIAN RYU power/performance experiment (TikTok heat)

Branch: `test-ryu-performance-haotian`; **NOT main**.

## Why this exists

HyperMOS main on Xiaomi 15 Pro (HAOTIAN, Android 16) can run hot
while viewing TikTok. Notification push delivery and screen-off Doze
are not the same subsystem as foreground video decoding, display
refresh, GPU rendering or CPU scheduling. Importing all RYUOS binaries
would not establish the cause of higher temperature and may introduce
boot/dependency failures.

## Already inherited from the RYU A16 test branch

- FCM / broadcast policy method-level patches.
- Foreground-service protections for swipe and cross-task cleanup.
- Conditional KillProcessController UID-kill policy based on RYU.
- Two RYU GmsObserver build-gate equivalents, keeping real control logic.
- The isolated RYU low-power Doze field experiment.
- No forced thermal/scheduler governors or RYU-private binaries.

These are **experimental** and have not been established as cooler
under TikTok screen-on load. Do not assume that they will solve heating.

## What changed on this branch

- `bin/audit/ryu_performance_parity.py`: read-only PowerKeeper
  method/class diff for power, perf, boost, GPU, CPU, frequency, FPS,
  thermal, battery, scheduling and RYU-only dependencies.
- `.github/workflows/ryu-powerkeeper-parity.yml`: includes
  these reports **before** the tested Xiaomi APK receives patches.
  The workflow outputs `ryu-performance-parity.md` and JSON.
- `.github/workflows/ryu-heat-safety-preflight.yml`: checks that
  ThermalServices and Xiaomi_NoLowEnd scripts remain inactive.
- `bin/audit/collect-haotian-heat.cmd`: read-only Windows ADB
  performance/thermal log collector for TikTok.
- `bin/audit/collect-haotian-heat.sh`: equivalent Linux/macOS collector.

## Controls that must stay active

- Xiaomi/Qualcomm normal CPU and GPU thermal limiting.
- Hardware thermal emergency and battery charging protection.
- Stock LTPO/smart FPS; do not force persistent high refresh.
- Do not inject `-nolimit.conf`, fake thermals or overclock.
- Avoid importing RYU `PerfHook` until all dependencies and frequency
  effects have been assessed on a matching HAOTIAN base.
- Never copy an entire RYU APK/JAR or `vendor` partition onto stock
  merely because the ROM reports a similar version.

The existing `ThermalServices/update.sh.0` and
`Xiaomi_NoLowEnd/update.sh.0` are not called by the current
`insupdate.sh` dispatcher, which executes only `update.sh`.

## Minimal measurement protocol

1. Ensure a known-good ROM/backup. Disable charging for the test.
2. Fix brightness, refresh setting and network type. Record room
   conditions. Do not run a game or video editor in the background.
3. Open TikTok and watch ordinary videos. On Windows place
   `collect-haotian-heat.cmd` beside `adb.exe` and run it. On
   Linux/macOS use `bash collect-haotian-heat.sh`.
4. Compare output with the previous main ROM under matched usage.
   Review private information in dumpsys outputs before sharing.
5. Verify boot, app stability, FCM delay (Zalo, Messenger, Gmail)
   and screen-off drain separately. Screen-on heat is the target.
6. Merge to main **only** after real-device checks show a benefit.

## What has NOT been migrated

- RYU `PerfHook` private implementation and per-app governors.
- Vendor/odm thermal configuration or frequency tables.
- Thermal guard, emergency cutoffs, charging protections.
- RYU updater, device identity, fake-lock or additional services.

Their compatibility and thermal benefit remain unproven. The
performance-parity report only reads the PowerKeeper APK;
it is not a complete analysis of `vendor`, `odm` or kernel policy.
