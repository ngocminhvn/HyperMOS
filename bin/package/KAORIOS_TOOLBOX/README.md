# KAORIOS_TOOLBOX

HyperMOS integration for Kaorios Toolbox v2.0.6.0 on Android 16 / SDK 36.

Upstream:
- https://github.com/hzzmonetvn/Kaorios-Toolbox
- Guide: `Toolbox-docs/V2.0.3+/Patch_Guide_2.0.6.0_VI.md`

HyperMOS intentionally does not use Kaorios FLAG_SECURE or CorePatch logic.
Those features remain owned by HyperMOS COREPATCH.

Official v2.0.6.0 release payloads used at build time:
- `classes.dex`
- `KaoriosToolbox-fix_update_sign.apk`

Both are pinned by SHA-256 in `patch.sh`.

Patch coverage on A16:
- `framework.jar`: ActivityThread, Instrumentation, ApplicationPackageManager,
  AndroidKeyStoreKeyPairGeneratorSpi, AndroidKeyStoreSpi
- `services.jar`: ComputerEngine, SystemServer
- `SettingsProvider.apk`: SettingsProvider call/query hooks

Only owner DEXes that actually change are reassembled and the final DEXes are
disassembled again for verification before replacing ROM artifacts.

The old KouseiPatcher, toolbox.py, Kaorios FLAG_SECURE/CorePatch logic and old
standalone `libkaorios_toolbox.so` are not used.
