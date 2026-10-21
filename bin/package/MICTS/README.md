# MICTS (experimental, Xiaomi.eu Android 16)

This package patches `/system/framework/services.jar` **after CorePatch and Kaorios**. It keeps the unmodified, checksum-pinned official MiCTS v2.6 APK and its Quick Settings tile.

When `showSessionFromSession` receives a MiCTS request, the bridge validates:
1. `micts_trigger=true` in the Bundle.
2. Binder calling UID belongs to `com.parallelc.micts`.
3. APK signer SHA-256 matches the officially pinned APK used at build time.

Only then does the bridge call Contextual Search. A ThreadLocal guard limits the `ContextualSearchManagerService.enforcePermission` shortcut to that specific request on the current system_server thread. Binder identity is restored and the guard is removed in a finally-equivalent handler. Calls not meeting these checks follow the original VIS path. No persistent daemon is added.

**Build constraints:** `xiaomi_eu` + Android 16 only; all others quietly skip. The build fails closed on unknown method signatures, missing signed APK, invalid APK digest, missing target classes, or DEX assembly/verification errors. No system JAR is overwritten on validation failure.

**Unverified:** Needs an actual EU OS3 services.jar build and a boot test. It is not proven to fix 5-second Google launch stalls. The unmodified MiCTS app still defaults to 400ms tile delay; users can reduce that in MiCTS settings. The direct Contextual Search service may still be rejected at runtime if Google changes its requirements.

**Rollback:** revert the branch/PR or remove the `MICTS/update.sh` call in `bin/package/patchpackage.sh` and rebuild. Do not flash untested framework modifications onto a device without a recoverable stock ROM.
