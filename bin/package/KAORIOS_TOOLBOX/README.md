# KAORIOS_TOOLBOX — HyperMOS integration

This directory integrates Kaorios Toolbox using the maintained upstream patcher in `script/kaorios_patcher.py`.

Pinned runtime assets are grouped under `app/`: `KaoriosToolbox.apk`, the framework payload `classes.dex`, and `com.kousei.kaorios.xml`.

### Upstream ownership rule

Files copied from Kaorios upstream must remain byte-for-byte unmodified so a future Kaorios update can replace them wholesale. MOD-specific helpers live under `mod/`; `script/` is reserved for upstream Kaorios files. Current upstream script snapshot: `04a1cf4b58529c8f3a2450f0aa1e0fd2eb3dd48a`.

## Scope

HyperMOS deliberately uses only the Kaorios hooks that are still needed:

- process/context initialization;
- Play Integrity / keybox keystore hooks;
- `ApplicationPackageManager.hasSystemFeature(...)` spoof hook;
- `SystemServer` initialization;
- `ComputerEngine` package visibility / installer-source hooks;
- optional `Settings$NameValueCache` dev-status hook for Developer options / ADB;
- Android 17 `Build` / `Build$VERSION` spoof;
- Toolbox APK as a `system_ext` priv-app.

Kaorios permanently bypasses Secure Flag in `services.jar` and, when present, Xiaomi's `miui-services.jar`. Its CorePatch pass owns the static signature/downgrade bypass. HyperMOS CorePatch runs first with those overlapping methods disabled and retains only its Xiaomi-specific patches. The Toolbox APK remains byte-for-byte upstream, so its visible **Disable Secure Flag** switch does not change this build-time state.

`COREPATCH/update.sh` without an option remains the full standalone HyperMOS CorePatch. When `KAORIOS_ENABLE_COREPATCH=true`, the main package pipeline passes `--kaorios`, which disables only HyperMOS operations owned by Kaorios; it does not disable the remaining HyperMOS patch set. When the Kaorios CorePatch switch is false, the flag is omitted and HyperMOS runs its full profile instead.

## Per-feature config

`config.json` contains one top-level `KaoriosToolbox` array with exactly one configuration object. Set `enabled` to control the complete package, then enable or disable the user-facing features in that same object. Values must be the JSON booleans `true` or `false`; strings such as `"true"`, missing keys, duplicate keys and unknown keys stop the build. There is no secondary shell configuration file.

Environment variables remain optional CI overrides. When an override is present, it takes precedence over `config.json` and accepts `true/false`, `1/0`, `yes/no`, or `on/off`.

Custom boot animation is enabled by default: `bin/modfile/UpdateFile/Boot/update.sh` is active again and copies `bootanimation.zip` to `product/media/` on supported OS3/OS4 builds. Set `HYPERMOS_CUSTOM_BOOTANIMATION=false` to preserve the base ROM animation for a diagnostic build.

| JSON key | Effect |
|---|---|
| `enabled` | Master switch for the complete Kaorios integration |
| `pif_spoof` | PIF identity, process/context and system-feature hooks |
| `keybox` | Keystore hooks and validation of an optional builder-supplied keybox |
| `hidden_app` | Package visibility filtering in `ComputerEngine` |
| `installer_source` | Installer-source filtering in `ComputerEngine` when supported by the ROM layout |
| `devstatus` | `Settings$NameValueCache` hook for hiding Developer options / ADB |
| `build_spoof` | `Build` / `Build$VERSION` spoof on Android 17 only |
| `secure_flag` | Permanent Secure Flag bypass in `services.jar` and Xiaomi `miui-services.jar` |
| `corepatch` | Kaorios signature/downgrade pass after the non-overlapping HyperMOS CorePatch pass |

When `enabled` is true, the Toolbox APK and its privapp permission XML are installed automatically. The loader derives low-level `ActivityThread`, `Instrumentation`, `SystemServer` and framework-driver requirements from the feature switches. Advanced CI environment variables can still override the derived switches.

The framework driver DEX is added whenever an enabled feature needs `KaoriosHook`, including callers in `services.jar`. Build spoof does not force the driver by itself.

`KAORIOS_ENABLE_HIDDEN_APP` and `KAORIOS_ENABLE_INSTALLER_SOURCE` are independent; disabling one no longer implicitly disables/enables the other.

## v2.0.6.1 release coverage

| Upstream release feature | HyperMOS integration |
|---|---|
| RKP keybox extraction/generation and runtime keybox management | Provided by the pinned upstream Toolbox APK; no framework caller patch is added for this app-side root workflow |
| Custom PIF profiles and Play Store/DroidGuard identity isolation | Provided by the pinned `classes.dex`; process/context, system-feature and Android 17 Build callers are patched when their switches are enabled |
| Keybox-backed attestation and TEE warm-up fixes | Both keystore callers are patched and checked against the one-argument and contextual three-argument payload methods |
| HMA `installSourceSpoof` policy | `ComputerEngine` installer-source callers are patched when `installer_source` is true |
| Developer/ADB status policy | Uses the current upstream `Settings$NameValueCache` patch, not the retired HyperMOS-local hook shape |
| Android 13–17 patcher hardening | Current upstream scripts and complete caller manifest are vendored byte-for-byte; HyperMOS currently accepts Android 15–17 targets |

Runtime behavior implemented inside the APK or framework payload is not duplicated as a smali caller patch.

## Android 16 paths

For an Android 16 build, the integration resolves and updates these locations:

| Purpose | Path |
|---|---|
| Source APK | `bin/package/KAORIOS_TOOLBOX/app/KaoriosToolbox.apk` |
| Source framework payload | `bin/package/KAORIOS_TOOLBOX/app/classes.dex` |
| Framework target | `build/baserom/images/system/system/framework/framework.jar` |
| Services target | `build/baserom/images/system/system/framework/services.jar` |
| Installed Toolbox APK | `build/baserom/images/system_ext/priv-app/KaoriosToolbox/KaoriosToolbox.apk` |
| Installed permission allowlist | `build/baserom/images/system_ext/etc/permissions/com.kousei.kaorios.xml` |
| AdvancedPolicy service label | `build/baserom/images/system_ext/etc/selinux/system_ext_service_contexts` |
| AdvancedPolicy service policy | `build/baserom/images/system_ext/etc/selinux/system_ext_sepolicy.cil` |

If a preferred framework/services path is absent, the build requires exactly one matching artifact below `build/baserom/images`. The payload DEX is inserted into the next free `classesN.dex` slot inside `framework.jar`; it is not copied as a standalone system file. Android 16 uses mode 1 hooks and skips the Android 17-only Build spoof.

## Build order

`bin/package/patchpackage.sh` runs:

1. HyperMOS CorePatch with overlapping signature/downgrade and Secure Flag patches disabled
2. DISABLE_AVB
3. notification fix
4. Kaorios CorePatch signature/downgrade pass (controlled by `KAORIOS_ENABLE_COREPATCH`)
5. Kaorios upstream 2.0.6.1 hooks plus MOD-local static Secure Flag
6. TNM: post-fs property reporting + App Privacy (compatibility-gated)

Kaorios CorePatch and Toolbox patch after the HyperMOS-only pass and notification fix, so they see the resulting artifacts without reapplying overlapping methods. TNM then installs the post-fs integration and runs App Privacy with its own compatibility checks; unsupported App Privacy layouts are skipped before changing `framework.jar`.

## Build behavior

`patch.sh`:

- pins both reviewed v2.0.6.1 release payloads (`KaoriosToolbox.apk` SHA-256 `b6d7a83fef7dd5ec2f43319597def24371cd05d64d91fb9e5e3c161f2f407fcf`, `classes.dex` SHA-256 `94848e186f697e43f0274c545a1350eb2a84b517d3cf1d7e6f50c7b6aec7709d`);
- validates every generated hook call against the disassembled pinned payload before changing a ROM artifact;
- decompiles every `classes*.dex` separately;
- requires the expected target classes before modifying anything;
- uses upstream `kaorios_patcher.py --mode 1` for hook targets and `--mode 2` for the Android 17 Build spoof targets;
- uses the upstream 2.0.6.1 `Settings$NameValueCache` implementation and fails closed when that enabled hook is unsupported;
- rebuilds only DEX files whose smali tree actually changed;
- appends the Kaorios framework DEX to a new free `classesN.dex` slot;
- tests, re-extracts and disassembles every rebuilt candidate before installation;
- rejects duplicate class descriptors and re-validates selected callers against the pinned payload ABI;
- integrates and compiles the least-privilege AdvancedPolicy SELinux contract, then checks it again after TNM;
- preserves `SettingsProvider.apk` byte-for-byte at this stage;

The final artifact pass is intentionally fail-closed: a malformed archive, missing caller, caller/payload descriptor mismatch, duplicate class, invalid split policy, or stale precompiled policy cache aborts packaging.

## Keybox handling

No private attestation keybox is stored in this public repository.

The ROM contains the Kaorios keystore hooks and Toolbox support. Import and manage the keybox through Toolbox at runtime; the ROM build no longer reads or validates a local keybox file and never embeds private key material.

Do not copy upstream `Toolbox-data/Pif-props.json` blindly into an Android 16 build. The upstream profile can track a different Android/Pixel generation; manage the spoof profile through Toolbox instead.

## Upstream

- Kaorios Toolbox: `hzzmonetvn/Kaorios-Toolbox`
- Pinned release: `https://github.com/hzzmonetvn/Kaorios-Toolbox/releases/tag/v2.0.6.1`
- Maintained guide: `Toolbox-docs/2.0.6+/Patch_Guide_2.0.6.1_VI.md`

## AdvancedPolicy / SELinux

The extracted Xiaomi 15 Pro Android 16 image and device AVC identify the actual registration path as `system_server -> service_manager`, while the installed Toolbox Manager runs as `priv_app`. The build therefore adds one dedicated service type only:

- `kaorios_advanced_policy -> u:object_r:kaorios_advanced_policy_service:s0`;
- `system_server_service` plus an exact `system_server:add` rule supplies the producer-side service-manager contract;
- `app_api_service` supplies discovery to app processes where `Settings$NameValueCache` evaluates per-caller policy;
- an exact `priv_app:find` rule makes the observed Manager domain explicit and keeps the upstream diagnostic checker useful.

No permissive mode, wildcard service type, shell access, broad direct `appdomain` allow, or unrelated Binder allow is added. Existing platform app-to-system-server Binder communication covers the call path; the AdvancedPolicy implementation retains its own UID/package checks and per-caller evaluation. The integrator compiles the complete split CIL before replacing image files, removes stale vendor/ODM `precompiled_sepolicy*` caches, and rolls image files back on a staging error. A final check runs after TNM has made its own policy changes.

Upstream `script/check-advanced-policy-sepolicy.py` remains useful for device-side diagnostics after boot; the build-time policy contract does not by itself prove that Android started the service.

Upstream 2.0.6.1 policy: stock SettingsProvider is preserved. HyperMOS no longer adds caller-side Settings spoof or direct ContentResolver Settings hooks; only the documented Developer/ADB dev-status hook remains.
