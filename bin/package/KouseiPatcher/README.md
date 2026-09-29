# KouseiPatcher — Kaorios Toolbox release 108

This HyperMOS integration is based on the KouseiPatcher flow from HalcyonOS, adapted for **KaoriosToolbox release 108** from tag **v2.0.6.0**.

## HyperMOS changes

- Downloads the exact release asset and verifies its SHA-256.
- Uses the official release-108 `classes.dex` as a separate framework dex.
- Does **not** copy the older KouseiPatcher smali driver snapshot; release 108 contains additional classes.
- Does **not** apply Kousei's fake-lock / Play Integrity property overrides, so it does not undo HyperMOS's current choice to keep the original boot/AVB state.
- Installs the release-108 toolbox APK and native arm64 library as a system priv-app.

## Compatibility note

The upstream v2.0.6.0 release notes say this version does not currently support Kaorios Patcher. Treat this integration as experimental and test boot + SystemServer before relying on it.
