# MiCTS: HyperMOS native Contextual Search integration

Upstream reference: https://github.com/parallelcc/MiCTS

This package targets HyperOS 3 / Android 16. It activates the Android
framework's built-in VoiceInteractionManagerService **CSHelper** route for
MiCTS's `omni.entry_point` event, pointing it to the factory-installed
`com.google.android.googlequicksearchbox` Google app.

Implementation: static Android framework resource overlay
(`/product/overlay/HyperMOSMiCTSOverlay.apk`), not an LSPosed module.
There are no daemons, timers, periodic rebinds, or runtime polling.

## Scope and safety

- Preflights AOSP CSHelper references in services.jar.
- Checks both framework-res resource symbols exist.
- Requires at least one system Google APK; Android uses MATCH_FACTORY_ONLY for
  the native Contextual Search launch intent.
- Does not modify system JARs, PowerKeeper, signed MiuiHome, app privileges,
  or ContextualSearchManagerService.enforcePermission().
- Installs last during bin/package/patchpackage.sh.
- Cleans up only a stale CTS_NATIVE resource overlay.

## Limitations

This enables the app-icon and Quick Settings tile trigger through the native
CSHelper path, not the separate Xiaomi-specific LSPosed long-press hooks.
Long press requires a stock Launcher native trigger or a separate, carefully
validated Launcher integration. Google can also withhold Circle to Search
based on device or server-side eligibility.

The ROM build checks structure and signing. Whether Android 16 enables the
static overlay through idmap must be checked **after flashing**.

## Verify on the phone

```bat
adb shell cmd overlay list --user 0 android
adb shell pm path com.google.android.googlequicksearchbox
adb shell service list | findstr /I "contextual_search voiceinteraction"
adb logcat -d | findstr /I "MiCTS ContextualSearch"
```

Launch MiCTS or tap its quick tile and inspect logs if it does not trigger.
