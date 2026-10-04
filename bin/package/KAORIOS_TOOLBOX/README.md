# KAORIOS_TOOLBOX — HyperMOS integration

This directory integrates **Kaorios Toolbox v2.0.6.0** using the maintained upstream patcher in `script/kaorios_patcher.py`.

## Scope

HyperMOS deliberately uses only the Kaorios hooks that are still needed:

- process/context initialization;
- Play Integrity / keybox keystore hooks;
- `ApplicationPackageManager.hasSystemFeature(...)` spoof hook;
- `SystemServer` initialization;
- `ComputerEngine` package visibility / installer-source hooks;
- `SettingsProvider.call()/query()` per-app Settings spoof hooks;
- Toolbox APK as a `system_ext` priv-app.

Kaorios **FLAG_SECURE** and **CorePatch** are intentionally not applied here because HyperMOS already owns those patches in `bin/package/COREPATCH`.

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
- uses upstream `kaorios_patcher.py --mode 1`;
- rebuilds only DEX files whose smali tree actually changed;
- appends the Kaorios framework DEX to a new free `classesN.dex` slot;
- re-disassembles the candidate artifacts and verifies the required hooks before replacing ROM files;
- keeps the original manifest/resources of `SettingsProvider.apk`.

Required final feature checks include:

- `initGenerateSoftwareKeyPair` + `CertificateChainIfNeeded` for Play Integrity/keybox;
- `hasSystemFeature` for system-feature spoofing;
- `filterSettingsCall` and, when present, `filterSettingsQueryResult` for Settings spoofing.

## Keybox handling

No private attestation keybox is stored in this public repository.

The ROM contains the Kaorios keystore hooks and Toolbox support. Import the keybox through Toolbox at runtime. If a builder supplies `KAORIOS_KEYBOX_XML=/path/to/keybox.xml` (or a local untracked `keybox.xml` beside `patch.sh`), the build only runs `script/validate_keybox.py` to validate XML structure; it intentionally does **not** bake the private key into the ROM.

Do not copy upstream `Toolbox-data/Pif-props.json` blindly into an Android 16 build. The upstream profile can track a different Android/Pixel generation; manage the spoof profile through Toolbox instead.

## Upstream

- Kaorios Toolbox: `hzzmonetvn/Kaorios-Toolbox`
- Maintained guide: `Toolbox-docs/V2.0.3+/Patch_Guide_2.0.6.0_VI.md`
