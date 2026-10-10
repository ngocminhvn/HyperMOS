# RYUOS HAOTIAN performance and application thermal experiment

**Test branch only:** `test-ryu-performance-haotian`.
Base: Xiaomi 15 Pro / HAOTIAN / HyperOS 3.0.308 / Android 16.
Reference: RYUOS HAOTIAN 3.0.309, extracted into the checked-in
`RYUOS-HAOTIAN-Thermal-Configs (1).zip` (181,360 bytes).

## What is ported

- **10 original RYU vendor/odm powerhint/perf XMLs** via `port_ryu_perf.py`,
  protected by manifest SHA256 + exact reference hashes.
- **19 original RYU ODM thermal app profiles** via
  `port_ryu_thermal_profiles.py`: 4k, arvr, camera, cclassvideo, cgame,
  class0, hp-mgame, hp-normal, huanji, mgame, navigation, normal,
  odm-map, per-class0, per-normal, per-video, phone, video, videochat.
- Original RYU `PerfHook` class family in PowerKeeper, behind guarded patch,
  compiled into the actual APK DEX and tested with genuine Xiaomi target.
- RYU-inspired GMS, FCM, FGS, Doze and conditional UID-kill policies already
  present on the isolated ROM test branch.

## Deliberately preserved for safety

**Not copied:** `thermal-nolimits.conf`, `thermal-tgame.conf` (both original
RYU files are 16 bytes, potentially bypass-like), `thermal-charge.conf`,
`thermal-chg-only.conf`, low-level vendor thermald, thermal daemon policy,
hardware protection, charging controls, kernel, boot chain and firmware.
Do not disable thermal service. "Full thermal" as *all files* has not been
performed because it could suppress hardware protection.

The original RYU binary thermal profiles are opaque, so matching sizes and
SHA256 prove origin and structural compatibility, **not** equivalent safety
thresholds or reliable device runtime. The ROM importer requires matching
stock paths and nontrivial 16-byte block encoding. It refuses a missing
required Normal/Video/Performance-Normal profile and records before/after
hashes in `ryu-test-thermal-profiles.json`.

## No redundant RYU downloads

The ROM build unpacks the already committed 181 KB ZIP, verifies its exact Git
blob and the per-file SHA256, then stages eligible profiles. It does **not**
download the large SourceForge RYU ROM or extract `super.img` on every build.
The dedicated RYU extractor is now manual-only.

## Native per-app TNM

The separate TNM test branch `ngocminhvn/app@test-ryu-per-app-thermal`
configures RYU's three `Settings.System` keys using explicit root permission:
`projectryu_thermal_per_app`, `projectryu_thermal_sconfig`,
`projectryu_thermal_profiles`. The native PowerKeeper PerfHook watches
foreground apps; TNM no longer needs its own AccessibilityService to switch
thermal settings. Supported app override values: stock Normal (0) and
Performance Normal (50, only if available). Do not use No Limits or confusing
RYU internal mode numbers as Xiaomi kernel sconfig values.

The main ROM build still bundles the **stable** TNM from its signed Pages
release, not the experimental TNM APK. Test them separately until an
update-compatible signed TNM build has been validated.

## Verification

`HAOTIAN RYU Thermal Safety Preflight #78` validates the genuine uploaded
archive and a complete safe-profile staging fixture. It is not a hardware
stress/charging safety test. Test ROM boot, thermal protection, app switching,
battery temperature, idle drain, notifications, and recovery before merging.
Nothing here alters the production `main` branch.
