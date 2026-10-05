# KAORIOS_TOOLBOX — HyperMOS integration

This directory integrates **Kaorios Toolbox v2.0.6.0** using the maintained upstream patcher in `script/kaorios_patcher.py`.

## Scope

HyperMOS deliberately uses only the Kaorios hooks that are still needed:

- process/context initialization;
- Play Integrity / keybox keystore hooks;
- `ApplicationPackageManager.hasSystemFeature(...)` spoof hook;
- `SystemServer` initialization;
- `ComputerEngine` package visibility / installer-source hooks;
- framework `Settings$NameValueCache` per-app Settings spoof hook + targeted `ContentResolver.call()` runtime-probe hook;
- optional `Settings$NameValueCache` dev-status hook for Developer options / ADB;
- Android 17 `Build` / `Build$VERSION` spoof;
- Toolbox APK as a `system_ext` priv-app.

Kaorios **FLAG_SECURE** and **CorePatch** are intentionally not applied here because HyperMOS already owns those patches in `bin/package/COREPATCH`.

## Per-feature config

Edit `config.sh` to enable/disable each feature independently. Feature defaults are `true`. Settings spoof uses a framework caller hook so the Kaorios stage preserves the input `SettingsProvider.apk` without requiring the Xiaomi platform private key.

The caller backend evaluates `KaoriosHook.filterSettingsCall` before the stock NameValueCache lookup for same-user `Settings.System/Secure/Global.get*` reads by ordinary application UIDs. It also hooks the framework `ContentResolver.call(String authority, ...)` path only when `authority == "settings"`, so Kaorios Toolbox runtime probes and apps that use the public resolver call path can reach the same policy without modifying `SettingsProvider.apk`. A returned Bundle overrides the value, including an explicit null; no decision runs the stock cache/provider path. The bridge excludes system UIDs and foreign Binder identities, prevents recursive policy evaluation, and falls back to stock if policy evaluation throws. `KAORIOS_ENABLE_SYSTEM_SERVER` must be enabled to initialize the policy service.

`ContentResolver.call()` to the `settings` authority is covered, but direct `IContentProvider` access, `ContentResolver.query`, bulk reads, system-process reads and cross-user reads remain outside this backend; this is still not full provider-side coverage. The original provider hooks remain in the upstream patcher sources but the main build no longer applies them. The Xiaomi 15 Pro Android 16 / OS3 bootloop reported for build #59 is not yet confirmed by device logs. Host verification does not establish device boot, Binder/SELinux access, or runtime spoof compatibility; test a configured target app after first boot.

Custom bootanimation is enabled by default in `bin/modfile/UpdateFile/Boot/update.sh`. Set `HYPERMOS_CUSTOM_BOOTANIMATION=false` in the build environment to preserve the base ROM animation for diagnostics.

| Switch | Effect |
|---|---|
| `KAORIOS_MASTER` | Master switch for the entire Kaorios integration |
| `KAORIOS_ENABLE_ACTIVITY_THREAD` | `ActivityThread` process-init hook |
| `KAORIOS_ENABLE_INSTRUMENTATION` | `Instrumentation` context-init hook |
| `KAORIOS_ENABLE_KEYBOX` | Both Play Integrity/keybox keystore hooks |
| `KAORIOS_ENABLE_SYSTEM_FEATURE_SPOOF` | `ApplicationPackageManager.hasSystemFeature(...)` spoof |
| `KAORIOS_ENABLE_SYSTEM_SERVER` | `SystemServer` initialization hook |
| `KAORIOS_ENABLE_HIDDEN_APP` | Package visibility / hidden-app filtering in `ComputerEngine` |
| `KAORIOS_ENABLE_INSTALLER_SOURCE` | Installer-source filtering in `ComputerEngine` when supported by the ROM layout |
| `KAORIOS_ENABLE_SETTINGS_SPOOF` | Per-app framework `Settings.*` reads + `settings` ContentResolver.call runtime probes; provider APK preserved |
| `KAORIOS_ENABLE_DEVSTATUS` | `Settings$NameValueCache` hook for hiding Developer options / ADB |
| `KAORIOS_ENABLE_BUILD_SPOOF` | `Build` / `Build$VERSION` spoof on Android 17 only |
| `KAORIOS_INSTALL_TOOLBOX` | Install `KaoriosToolbox.apk` and its privapp permission XML |
| `KAORIOS_VALIDATE_KEYBOX` | Validate a supplied keybox XML without embedding it |
| `KAORIOS_DEVSTATUS_STRICT` | Fail instead of warning when the dev-status layout is unsupported |

Accepted boolean values are `true/false`, `1/0`, `yes/no`, and `on/off`. Environment variables override the defaults, so CI can change a switch without editing the file.

The framework driver DEX is added whenever an enabled feature needs `KaoriosHook`, even when the caller lives in `services.jar` or `SettingsProvider.apk`. Build spoof does not force the driver by itself.

`KAORIOS_ENABLE_HIDDEN_APP` and `KAORIOS_ENABLE_INSTALLER_SOURCE` are independent; disabling one no longer implicitly disables/enables the other.

## Build order

`bin/package/patchpackage.sh` runs:

1. HyperMOS COREPATCH
2. DISABLE_AVB
3. notification fix
4. Kaorios v2.0.6.0
5. refresh-rate patch

Kaorios therefore patches and verifies the final framework/services state instead of being overwritten by a later framework patch.

## Safety / verification

`patch.sh`:

- pins the reviewed `classes.dex` and `KaoriosToolbox.apk` Git blobs;
- decompiles every `classes*.dex` separately;
- requires the expected target classes before modifying anything;
- uses upstream `kaorios_patcher.py --mode 1` for hook targets and `--mode 2` for the Android 17 Build spoof targets;
- rebuilds only DEX files whose smali tree actually changed;
- appends the Kaorios framework DEX to a new free `classesN.dex` slot;
- re-disassembles the candidate artifacts and verifies the required hooks before replacing ROM files;
- preserves `SettingsProvider.apk` byte-for-byte at this stage;
- adds a caller bridge beside NameValueCache without changing its register count, hooks the framework `ContentResolver.call(String, ...)` path for the `settings` authority, and verifies both hooks after DEX assembly.

Required final feature checks include:

- `initGenerateSoftwareKeyPair` + `CertificateChainIfNeeded` for Play Integrity/keybox;
- `hasSystemFeature` for system-feature spoofing;
- `filterSettingsCall`, the NameValueCache caller hook, the direct `ContentResolver.call()` hook and their guarded bridge for Settings spoofing.

## Keybox handling

No private attestation keybox is stored in this public repository.

The ROM contains the Kaorios keystore hooks and Toolbox support. Import the keybox through Toolbox at runtime. If a builder supplies `KAORIOS_KEYBOX_XML=/path/to/keybox.xml` (or a local untracked `keybox.xml` beside `patch.sh`), the build only runs `script/validate_keybox.py` to validate XML structure; it intentionally does **not** bake the private key into the ROM.

Do not copy upstream `Toolbox-data/Pif-props.json` blindly into an Android 16 build. The upstream profile can track a different Android/Pixel generation; manage the spoof profile through Toolbox instead.

## Upstream

- Kaorios Toolbox: `hzzmonetvn/Kaorios-Toolbox`
- Maintained guide: `Toolbox-docs/V2.0.3+/Patch_Guide_2.0.6.0_VI.md`


## AdvancedPolicy / SELinux

Upstream includes `script/check-advanced-policy-sepolicy.py` as a read-only deployment checker. This integration does not invent Xiaomi-specific SELinux rules during the build, because the correct SettingsProvider domain and split-policy layout must come from the actual ROM; broad guessed rules can cause policy compilation failure or a boot loop.

After the first boot, use the upstream checker/logcat to confirm the AdvancedPolicy Binder path. If there is a real SELinux denial, add the smallest device-specific rule for the observed domain.
