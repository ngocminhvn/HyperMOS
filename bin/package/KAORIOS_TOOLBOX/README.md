# KAORIOS_TOOLBOX — HyperMOS integration

This directory integrates Kaorios Toolbox using the maintained upstream patcher in `script/kaorios_patcher.py`.

### Upstream ownership rule

Files copied from Kaorios upstream must remain byte-for-byte unmodified so a future Kaorios update can replace them wholesale. MOD-specific helpers live under `mod/`; `script/` is reserved for upstream Kaorios files. The dev-status helper remains MOD-local and does not modify the upstream patcher. Current upstream script snapshot: `9a50d37fbe160279925218703653122c0671f383`.

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
| `KAORIOS_ENABLE_SECURE_FLAG` | Permanently bypass Secure Flag in `services.jar` and Xiaomi `miui-services.jar`; the unmodified Toolbox switch is informational only |
| `KAORIOS_ENABLE_COREPATCH` | Run the Kaorios CorePatch signature/downgrade pass after the non-overlapping HyperMOS CorePatch pass |
| `KAORIOS_INSTALL_TOOLBOX` | Install `KaoriosToolbox.apk` and its privapp permission XML |
| `KAORIOS_VALIDATE_KEYBOX` | Validate a supplied keybox XML without embedding it |
| `KAORIOS_DEVSTATUS_STRICT` | Fail instead of warning when the dev-status layout is unsupported |

Accepted boolean values are `true/false`, `1/0`, `yes/no`, and `on/off`. Environment variables override the defaults, so CI can change a switch without editing the file.

The framework driver DEX is added whenever an enabled feature needs `KaoriosHook`, including callers in `services.jar`. Build spoof does not force the driver by itself.

`KAORIOS_ENABLE_HIDDEN_APP` and `KAORIOS_ENABLE_INSTALLER_SOURCE` are independent; disabling one no longer implicitly disables/enables the other.

## Build order

`bin/package/patchpackage.sh` runs:

1. HyperMOS CorePatch with overlapping signature/downgrade and Secure Flag patches disabled
2. DISABLE_AVB
3. notification fix
4. Kaorios CorePatch signature/downgrade pass (controlled by `KAORIOS_ENABLE_COREPATCH`)
5. Kaorios upstream 2.0.6.1 hooks plus MOD-local static Secure Flag
6. TNM: post-fs property reporting + App Privacy (compatibility-gated)

Kaorios CorePatch and Toolbox patch after the HyperMOS-only pass and notification fix, so they see the resulting artifacts without reapplying overlapping methods. TNM then installs the post-fs integration and runs App Privacy with its own compatibility checks; unsupported App Privacy layouts are skipped before changing `framework.jar`.

## Safety / verification

`patch.sh`:

- pins both reviewed v2.0.6.1 release payloads (`KaoriosToolbox.apk` SHA-256 `b6d7a83fef7dd5ec2f43319597def24371cd05d64d91fb9e5e3c161f2f407fcf`, `classes.dex` SHA-256 `ca9489f388e8717463c1f33a56c298a4b6bd5785b82d11f20da1deb65c799c9a`);
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
- static `DevicePolicyCacheImpl` and `WindowState`/`WindowStateAnimator` Secure Flag bypasses;
- the static Xiaomi `WindowManagerServiceImpl.notAllowCaptureDisplay(...)` bypass when `miui-services.jar` is present;

The Secure Flag patcher replaces only the selected method bodies, allocates the minimum safe return register, then re-disassembles the saved candidate JAR and verifies every bypass before installation.

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
