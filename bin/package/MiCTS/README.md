# MiCTS native services.jar patch (HyperOS 3 / Android 16)

Upstream reference: https://github.com/parallelcc/MiCTS

This package implements the **VIMSHooker/CSHelper routing behavior in the
existing Android framework**, using static smali/DEX patches to services.jar and, only if needed,
the Xiaomi miui-services.jar. It does **not** install a framework
resource overlay. It does **not** patch MiuiHome.apk or any Google APK.

Precisely two resource-derived String values are replaced, inside the
Android VoiceInteractionManagerService:
1. In `showSessionFromSession`, the native CSHelper key becomes
   `omni.entry_point` (matching the Bundle sent by MiCTS).
2. In `getContextualSearchIntent`, the package used to resolve the CTS
   handler becomes `com.google.android.googlequicksearchbox`.

The original Contextual Search launch, screenshot safety checks and
VoiceInteraction fallback logic are preserved. The patch never removes
`enforcePermission`, spoofs the global device identity, changes PowerKeeper,
or installs a daemon, timer, service, boot script or background polling.
There is no extra persistent process from this package.

## Build integration

`bin/package/patchpackage.sh` calls `MiCTS/update.sh` after CorePatch,
FrameworkPatcher, and Kaorios to avoid duplicate edits. The existing
decompiler, smali assembler and JAR utility are reused. The script requires
the known Android 16 CSHelper bytecode shape and aborts a build if it cannot
match it **uniquely**. Replacement is atomic and only after JAR ZIP validation.

## Functionality and limitations

MiCTS application launch and its Quick Settings tile can use this **native
CSHelper path without LSPosed**, provided the Google app supports CTS.

**Home long-press:** native MiCTS long-press hook now patches the owning
MiuiSingleKeyRule in services.jar or miui-services.jar, whichever contains it.
Only KEYCODE_HOME=3 is redirected; failures fall back to Xiaomi stock code.
This is event-driven with no persistent process.

**Gesture-handle long-press:** no APK patch. Inspection of the supplied
HyperOS 3 MiuiHome.apk confirms a native NavStubGestureEventManager.onLongPress
and launchInvoke -> CircleToSearchHelper.invokeCircleToSearch chain.
Launcher-specific gesture mapping and eligibility still control activation:
this integration does not guarantee every Launcher build enables it. The upstream
MiCTS APK continues to be staged by the existing downloadapp installer; its
APK is not modified by this package.

Google can also disable CTS on the app/server side; a native trigger cannot
override Google eligibility. The AOSP CSHelper resolves a **factory Google
application**, so removing both Velvet system APKs could break CTS even if an
updated Google app exists under /data/app.

## Check after flashing

```bat
adb shell pm path com.google.android.googlequicksearchbox
adb shell dumpsys package com.google.android.googlequicksearchbox | findstr /I "codePath= versionName="
adb logcat -d | findstr /I "MiCTS ContextualSearch VoiceInteraction"
```

Then launch MiCTS or tap its Quick Settings tile. Report:
`build/reports/micts-native.txt`.
