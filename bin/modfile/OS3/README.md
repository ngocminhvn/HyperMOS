# OS3 Mods Center integration

HyperMOS uses each Mods Center release ZIP as the primary source of the mod payload.

Build flow for every OS3 module:

1. Resolve the latest GitHub release and verify its ZIP digest when available.
2. Extract the ZIP.
3. Scan every APK with `aapt dump badging` and identify the correct mod by Android package name. Filename matching is only a fallback.
4. Print the extracted app-folder tree before touching the ROM.
5. If the release already contains external `lib/arm` or `lib/arm64` native libraries, keep them exactly as supplied.
6. If those external folders are absent but the mod APK contains `lib/arm64-v8a/*.so` or `lib/armeabi-v7a/*.so`, extract the same bytes into system-app style:
   - APK `lib/arm64-v8a/*.so` -> app `lib/arm64/*.so`
   - APK `lib/armeabi-v7a/*.so` -> app `lib/arm/*.so`
   Each extracted library is SHA-256 checked against the APK stream.
7. Replace the stock app using the module's own `system/` path when present. For standalone payloads, preserve an existing stock path; App Vault has an OS3 fallback because the debloat stage may remove its stock folder before OS3 mods run.
8. Compare the prepared source app tree and copied ROM app tree; mismatch stops the build.

The builder does not import .so files from HalcyonOS or another project. Any generated external native library comes only from the exact latest mod APK being integrated.

Other files already present in a module `system/` tree (permissions, overlays, system_ext, vendor, odm, product, etc.) are copied with the module payload. Magisk/KernelSU runtime scripts are not executed.
