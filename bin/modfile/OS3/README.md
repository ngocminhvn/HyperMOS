# OS3 Mods Center integration

HyperMOS resolves the latest GitHub release for each Mods Center package at build time.

For App Vault, Theme Manager and Security Center, the release ZIP is treated only as the source of the latest modified APK and any extra system files. HyperMOS then normalizes the app into a HalcyonOS-style ROM layout:

- product/priv-app/<App>/<App>.apk
- product/priv-app/<App>/lib/arm64/*.so
- product/priv-app/<App>/lib/arm/*.so
- product/etc/permissions/privapp_whitelist_*.xml

Native libraries are extracted from the same latest APK:
- APK lib/arm64-v8a/*.so -> ROM lib/arm64/*.so
- APK lib/armeabi-v7a/*.so -> ROM lib/arm/*.so

This avoids mixing old HalcyonOS native libraries with a newer Mods Center APK. If an app that is expected to have native libraries contains none, the build stops rather than silently producing an incomplete layout.

Permission XML files are taken from the upstream module when present, otherwise from the unpacked stock ROM for the same package. If the required permission XML is missing entirely, the build stops.

ColorOS Control Center follows HalcyonOS behavior: locate the existing MIUISystemUIPlugin directory and replace only its APK.

Magisk/KernelSU runtime scripts such as service.sh, post-fs-data.sh, customize.sh and system.prop are not executed.
