# KAORIOS_TOOLBOX — HyperMOS integration

This directory integrates Kaorios Toolbox using the maintained upstream patcher in `script/kaorios_patcher.py`.

### Upstream ownership rule

Files copied from Kaorios upstream must remain byte-for-byte unmodified so a future Kaorios update can replace them wholesale. MOD-specific ComputerEngine feature selection lives only in `script/mod-kaorios-adapter.py`; The dev-status helper remains HyperMOS-local and does not modify the upstream patcher. Current upstream script snapshot: `8c752fd2692ee9e469433cc2e6e2f0ee8bf54cd4`.

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

Kaorios **FLAG_SECURE** and **CorePatch** are intentionally not applied here because HyperMOS already owns those patches in `bin/package/COREPATCH`.

## Per-feature config

Edit `config.sh` to enable/disable each feature independently. Feature defaults are `true`. 
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
| `KAORIOS_ENABLE_DEVSTATUS` | `Settings$NameValueCache` hook for hiding Developer options / ADB |
| `KAORIOS_ENABLE_BUILD_SPOOF` | `Build` / `Build$VERSION` spoof on Android 17 only |
| `KAORIOS_INSTALL_TOOLBOX` | Install `KaoriosToolbox.apk` and its privapp permission XML |
| `KAORIOS_VALIDATE_KEYBOX` | Validate a supplied keybox XML without embedding it |
| `KAORIOS_DEVSTATUS_STRICT` | Fail instead of warning when the dev-status layout is unsupported |

Accepted boolean values are `true/false`, `1/0`, `yes/no`, and `on/off`. Environment variables override the defaults, so CI can change a switch without editing the file.

The framework driver DEX is added whenever an enabled feature needs `KaoriosHook`, including callers in `services.jar`. Build spoof does not force the driver by itself.

`KAORIOS_ENABLE_HIDDEN_APP` and `KAORIOS_ENABLE_INSTALLER_SOURCE` are independent; disabling one no longer implicitly disables/enables the other.

## Build order

`bin/package/patchpackage.sh` runs:

1. HyperMOS COREPATCH
2. DISABLE_AVB
3. notification fix
4. Kaorios upstream 2.0.6.1 integration
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

Required final feature checks include:

- `initGenerateSoftwareKeyPair` + `CertificateChainIfNeeded` for Play Integrity/keybox;
- `hasSystemFeature` for system-feature spoofing;

## Keybox handling

No private attestation keybox is stored in this public repository.

The ROM contains the Kaorios keystore hooks and Toolbox support. Import the keybox through Toolbox at runtime. If a builder supplies `KAORIOS_KEYBOX_XML=/path/to/keybox.xml` (or a local untracked `keybox.xml` beside `patch.sh`), the build only runs `script/validate_keybox.py` to validate XML structure; it intentionally does **not** bake the private key into the ROM.

Do not copy upstream `Toolbox-data/Pif-props.json` blindly into an Android 16 build. The upstream profile can track a different Android/Pixel generation; manage the spoof profile through Toolbox instead.

## Upstream

- Kaorios Toolbox: `hzzmonetvn/Kaorios-Toolbox`
- Maintained guide: `Toolbox-docs/V2.0.3+/Patch_Guide_2.0.6.1_VI.md`

## AdvancedPolicy / SELinux

Upstream includes `script/check-advanced-policy-sepolicy.py` as a read-only deployment checker. This integration does not invent Xiaomi-specific SELinux rules during the build, because the correct SettingsProvider domain and split-policy layout must come from the actual ROM; broad guessed rules can cause policy compilation failure or a boot loop.

After the first boot, use the upstream checker/logcat to confirm the AdvancedPolicy Binder path. If there is a real SELinux denial, add the smallest device-specific rule for the observed domain.

Upstream 2.0.6.1 policy: stock SettingsProvider is preserved. HyperMOS no longer adds caller-side Settings spoof or direct ContentResolver Settings hooks; only the documented Developer/ADB dev-status hook remains.
