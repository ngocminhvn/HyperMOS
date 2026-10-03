# OS3 fixed system-app snapshots

HyperMOS builds use system-app payloads committed directly in this repository. Normal ROM builds do not resolve GitHub releases and do not download these apps at build time.

## Local ZIP naming

Normal ROM builds locate exactly one local ZIP for each module by filename prefix:

- `HyperOS_AppVault*.zip`
- `ColorOS_plugin_mod_*.zip`
- `HyperOS_Launcher*.zip`
- `HyperOS_Security*.zip`
- `HyperOS_ThemeManager*.zip`

This makes later replacement simple: remove the old ZIP and put the new ZIP in `bin/modfile/OS3/assets/`. No script version or checksum needs to be edited. The build prints the actual SHA-256 for traceability and fails if zero or multiple files match a prefix.

InstallerX source remains local in `bin/modfile/Universal/packageinstaller/`.

The manual `Vendor fixed system apps` workflow is the only maintenance path that downloads these upstream assets. It uses exact pinned tags and exact filenames, verifies SHA-256, and commits the files into HyperMOS. Running the normal ROM build never invokes that workflow.

## Integration flow

1. Read the fixed local ZIP/APK from the repository.
2. Verify SHA-256.
3. Extract the ZIP.
4. Scan APKs with `aapt dump badging` and identify the expected Android package.
5. Preserve release-provided external native libraries. If they are absent but embedded ARM libraries exist inside the APK, rebuild `lib/arm` and `lib/arm64` byte-for-byte from that same APK and verify them.
6. Replace the stock app at its expected system path.
7. Verify the copied app-folder shape before continuing the ROM build.

No app payload is taken from HalcyonOS or another ROM project.
