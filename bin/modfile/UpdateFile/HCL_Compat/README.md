# HyperMOS HCL compatibility adapter

Selective ROM-native adaptation of [HCL-Module](https://github.com/minhtritt1996/HCL-Module)
(source reviewed at `303c2062e7276d8e89cfdab343a4e81b8a7b340a`). See `LICENSE.HCL`.
No separate HCL module installation is needed. This replaces the earlier read-only integration.

## Included

- HyperOS/MIUI and AOSP-family environment detection.
- Device/model/name/brand/manufacturer resolution from vendor, ODM, then top-level properties.
  Missing or generic identity is skipped; no hard-coded Xiaomi/POCO model fallback.
- Allowlisted cross-partition identity normalization using an existing root `resetprop`.
  Product **name** is preserved independently of device codename (including regional suffixes).
- Fingerprint consistency across existing properties only. A candidate must match the real
  device and current Android release. No fabricated fingerprint/build ID/security patch level.
- `compat_build.prop` generated from the system file using exact property keys and verified
  effective runtime values; unrelated content and security properties remain intact.
- ROM component discovery (inventory), optional SuSFS path rules and property-file redirect.
- Persistent, root-only config/status under `/data/adb/hypermos_hcl`.
- Nonblocking init service, once on `sys.boot_completed=1`, with a 45-second timeout.
- Status/matrix/security/features/config CLI; read-only diagnostics still work without mutation.
- Fail-open skips for missing backend, source, unsupported kernel/features, failed native calls,
  invalid config, or an already-running invocation. Backend calls have a 3-second deadline.
  Per-property failures are recorded and the generated view uses the actual value after each call.

## Existing subsystem ownership and exclusions

Keystore, keybox and framework hooks stay with **Kaorios**. HMA stays an **external module**.
This adapter does not change either subsystem or their settings.

No Guardian daemon, uname spoofing, TrickyStore synchronization, TEESimulator synchronization,
HMA config synchronization, cache cleanup, bootloader/Verified Boot state changes, or kernel patching.
No shared SuSFS module config is edited. No APK is deleted. Original partition build.prop files,
boot.img and vendor_boot.img are not modified by this adapter.

## Root and kernel requirements

The default init service uses `u:r:su:s0`, supplied by KernelSU/SukiSU (including LKM root).
It does **not** create that domain or loosen SELinux. For a Magisk-based build, set
`HCL_SELINUX_DOMAIN=u:r:magisk:s0` in the build environment. Without the selected root domain,
init cannot start this optional service; Android still boots. Diagnose with `init_service` and
`last_run` in the CLI. Root plus a usable resetprop backend is needed for property normalization.

SuSFS is independent of root mode: the presence of LKM or a userspace binary is insufficient.
The adapter requires successful `show version` and `show enabled_features` responses, then
checks `CONFIG_KSU_SUSFS_SUS_PATH` and `CONFIG_KSU_SUSFS_OPEN_REDIRECT` individually.
It supports the two-argument redirect interface for 1.5.x/2.0.x and the UID-scheme interface
for 2.1+ (scheme 3, matching the HCL source); unknown major versions skip redirect.
Missing SuSFS leaves the other features available. No kernel or binary is downloaded.

The service runs after boot, so values already cached in Java `Build` fields or applications
may differ from updated getprop values. It does not restart zygote/apps or replace Kaorios hooks.
A generated compatibility file is only redirected when the SuSFS backend reports success.
This is not a guarantee about attestation or any application's compatibility decision.

## CLI

```sh
su -c 'hcl-compatctl all'
su -c 'hcl-compatctl config'
su -c 'hcl-compatctl set susfs false'
su -c 'hcl-compatctl apply'
su -c 'hcl-compatctl set enabled false'
```

If a partition's bin directory is absent from your shell PATH, invoke the installed command by
its full path (normally `/system_ext/bin/hcl-compatctl`).

Keys are `enabled`, `normalize_identity`, `normalize_fingerprint`, `generate_compat`,
`discover_components`, `susfs`; values are strictly `true` or `false`. All default to true,
with SuSFS capability-gated. Config is parsed as data and never sourced. Existing config is
preserved across ROM updates. Invalid config skips the whole run without property changes.

`set` only saves config. Disabling a feature does not undo rules/properties already applied
this boot: **reboot to restore baseline**. Successful earlier writes are not rolled back if a
later backend call fails. Only `boot` is forced to return success; invalid CLI usage returns an error.
Status includes boot ID, start time, changed/failed counters and skip reasons. `result=running`
left after a stopped service means it did not finish (for example a timeout); it is not success.

## Build and validation

Only `update.sh` has a `.sh` suffix. HyperMOS's `insupdate.sh` executes every `.sh` recursively,
so shipping Android runtime helpers with that suffix would execute them on the build host.
Installer supports system_ext, product, system-as-root and flat system layouts, and is repeatable.
No new GitHub secrets or workflow job is needed.

```sh
python3 -m unittest discover -s tests -p 'test_hcl_compat.py' -v
```

Host tests cover installation layouts, idempotence, security-state preservation, absent
backends/kernel support, old/new SuSFS ABI, feature gates, failed property writes, config
injection, excluded config keys, missing source and fingerprint release mismatch. Android
SELinux/kernel execution and full ROM boot still require testing on an actual device.
