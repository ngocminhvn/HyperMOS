# OS3 Mods Center integration

The OS3 integration follows each Mods Center release ZIP itself. It does not reconstruct the app layout from HalcyonOS or another ROM project.

For every module HyperMOS:

1. Resolves the repository's latest GitHub release and requires one ZIP asset.
2. Downloads the ZIP and verifies GitHub's SHA-256 digest when available.
3. Extracts the ZIP and finds the expected mod APK.
4. Prints the complete extracted app-folder tree to the build log before changing the ROM.
5. Replaces the stock app using the release's own layout.
6. Verifies that the resulting app folder has the same file/directory shape as the extracted release folder.

If the APK is inside a Magisk-style `system/` tree, the complete `system/` payload is copied with its native structure. Therefore files are preserved only when the release actually contains them, including any:

- app-local `lib/arm` or `lib/arm64`
- permissions XML
- overlays
- `system_ext`, `vendor`, `odm`, `product`, and related payloads

If a release instead contains a standalone app folder, HyperMOS mirrors that folder exactly into the existing stock app path.

HyperMOS does **not** manufacture missing native libraries, extract .so files from inside the APK, or import permission XML from another ROM project. Missing files remain missing if the Mods Center release does not provide them.

Magisk/KernelSU runtime scripts such as `service.sh`, `post-fs-data.sh`, and `customize.sh` are not executed during ROM building.
