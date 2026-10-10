# HyperMOS HAOTIAN A16: RYU CPU/thermal + Xiaomi stock PowerKeeper

**Scope:** `test-powerkeeper-ryu-uid-identity` only. No changes to `main`.

## Final architecture

- PowerKeeper: **byte-for-byte stock Xiaomi APK**, preserved signature; no RYU
  DEX replacement, no signing with testkey, no runtime hook.
- RYU notification policy: use the existing Android 16 framework patch
  (`--ryu-notification-policy`, `--ryu-low-power-doze`,
  `--cn-notification-fix`). Do not duplicate notification interception
  inside PowerKeeper.
- RYU CPU, scheduler, boosts, power limits: port the **ten hash-pinned RYU
  powerhint/perf XMLs** in `port_ryu_perf.py`. This includes
  `odm/etc/powerhint.xml`, `vendor/etc/powerhint.xml`,
  `vendor/etc/perf/targetsysnodesconfigs.xml`,
  `vendor/etc/perf/commonsysnodesconfigs.xml`,
  `vendor/etc/perf/perfboostsconfig.xml`,
  `vendor/etc/perf/thermalbreakboostconfig.xml` and the remaining four
  pinned perf config files. **No arbitrary hard-coded CPU MHz cap is added.**
- RYU ODM thermal app-facing profiles: selected original `thermal-*.conf`
  files imported from a verified manifest, with `normal`, `video`,
  `per-normal`, `hp-normal` mandatory.
- Xiaomi charging, no-limits, TGame, kernel, thermald and hardware safety
  controls: remain stock. Their recorded hashes must survive later MOS mods.
- TNM: retain the signed app, on-demand root bridge, Eco/Stock tools and
  existing update flow. No **new** CPU/thermal polling daemon or runtime hook.
- At end of build, `verify_ryu_perf_final.py` verifies every pinned RYU
  performance XML and installed RYU ODM thermal profile after all other ROM
  modifications. The build fails if any file was overwritten.

## HyperMOS features worth retaining

| Feature | Decision | Grounding |
|---|---|---|
| RYU-style CN/FCM and foreground-service guards in framework | Keep | `bin/package/COREPATCH/ryu_policy_a16.py` |
| Minimal GMS exemption set, with correct C2DM receiver | Keep | `bin/modfile/Universal/gmsservices16/validate-sysconfig.py` |
| TNM system app and one-shot / on-demand backend | Keep | `bin/modfile/UpdateFile/TNM/update.sh`, `tnm-bridge` |
| Stock Smart FPS / LTPO preservation and optional 1-Hz entry | Keep | `bin/package/RefreshRate/1hz.sh` |
| Google services/keyboards needed on the China base | Keep | `bin/modfile/Universal/gmsservices16/update.sh` |
| Existing selective app debloat | Keep (independent) | `bin/ddevice/DEBLOAT/debloat.sh` |
| Unlimited GMS wakelock/alarm/network whitelist, forced CPU boost | Do **not** add | Can increase wakeups or oppose RYU limits |
| Old `ThermalServices/update.sh.0` no-limits edits | Do **not** enable | Disabled by file extension; conflicts with safety goals |
| RYU PowerKeeper GmsObserver, UID policy, PerfHook | Omit in this profile | They require altering or hooking Xiaomi-signed PowerKeeper |

## Limits of the comparison

The imported RYU configs retain the source values byte-for-byte; **runtime
CPU frequency caps are not guaranteed identical to RYUOS** because kernel,
thermal service, process management and PowerKeeper behaviour also matter.
In particular, RYU's PowerKeeper-specific PerfHook and app-based UID policy
are deliberately excluded. The TNM thermal *interface* remains installed,
but successful app-specific control must be verified on the actual HAOTIAN.

The existing HyperMOS CorePatch signature-verification changes are outside
this PowerKeeper selection, and should be separately audited before release.
This profile does not add any additional signature bypass or disable SELinux.

## Build and test

1. Run the `PowerKeeper A16 Safety Checks` workflow and the ROM build from
   the dedicated test branch, not `main`.
2. Build output must contain `HyperMOS-PowerKeeper-Xiaomi-Stock-Identity`
   and `HyperMOS-RYU-CPU-Thermal-Audit` (hash and node data).
3. Inspect `build/reports/performance/ryu-cpu-thermal-final.json` to see
   the RYU-provided CPU/scheduler-related XML nodes. Do not confuse XML
   requests with measured kernel policy decisions.
4. After flashing, verify `pidof com.miui.powerkeeper` and `getenforce`.
5. Read actual CPU policies on-device:
   `for p in /sys/devices/system/cpu/cpufreq/policy*; do echo "$p"; cat "$p/scaling_min_freq" "$p/scaling_max_freq" "$p/scaling_governor"; done`
6. Test Messenger, Zalo, screen-off notifications, TNM Eco/Stock switching,
   idle drain, thermal throttling and CPU clocks under comparable conditions.

A successful CI build is **not** proof of a working PowerKeeper process or
identical battery life. Flash validation and runtime observations are still required.
