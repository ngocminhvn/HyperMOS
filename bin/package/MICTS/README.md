# MICTS – experimental Xiaomi.eu Android 16 CSService-only hook

Location: `bin/package/MICTS`.

The existing MiCTS APK and its Quick Settings Tile are **unchanged**. This package is a build-time `services.jar` patch, applied after CorePatch / Kaorios.

### Trigger and compatibility

- Catch only `showSessionFromSession(...)` calls that carry the MiCTS `micts_trigger=true` Bundle flag.
- **No MiCTS APK signature, APK hash, or version pin in this hook.** App updates do not require changing this patch if they keep the same package name and request API.
- Keep a **UID → package-name** safety check for `com.parallelc.micts`. It is version-independent and prevents unrelated apps from activating a privileged contextual-search permission path by spoofing the Bundle.
- Send accepted invocations directly to `ContextualSearchManagerService`. The temporary permission hook is limited by a per-thread flag and is cleaned up after the call, restoring Binder identity.
- **Strict test mode:** CSService missing, UID mismatch, or invocation error logs `MiCTSBridge` and returns `false`; it does **not** invoke VIS as fallback. Unmarked requests retain normal Android behavior.

### Build constraints

- Only Xiaomi.eu / Android 16 is modified; China and other Android versions skip.
- Missing or unexpected JAR method/class, smali failure, and rebuilt-DEX verification errors abort the ROM build without replacing the original JAR.
- The hook **does not** depend on which MiCTS APK is staged by the downloader. The existing separate `Universal/downloadapp` preload still pins its initial official MiCTS v2.6 release; updates installed later on the device are not checked by this hook.

### Testing

- Not boot-tested against the actual HyperMOS EU `services.jar`; a successful smali build is necessary but not sufficient.
- Check `logcat | grep MiCTSBridge` to distinguish success from strict no-VIS failure.
- Compare the stock Circle to Search gesture with repeated MiCTS Quick Settings invocations.
- The official app's Tile delay defaults to 400 ms; changing this setting can independently reduce perceived latency.
- A 5-second Google startup cannot be ruled out even with CSService.

Do not merge or flash without a successful test build and a recovery image. Reverting the PR removes the hook.
