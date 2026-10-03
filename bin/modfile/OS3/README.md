# OS3 fixed system-app snapshots

HyperMOS builds use system-app payloads committed directly in this repository. Normal ROM builds do not resolve GitHub releases and do not download these apps at build time.

## Fixed snapshots

- HyperOS App Vault: V4.5
- ColorOS Control Center: V3
- HyperOS Launcher: V7.1
- HyperOS Security Center: V7
- HyperOS Theme Manager: V7
- InstallerX Revived source: 26.09

OS3 release ZIPs live in `bin/modfile/OS3/assets/`.
InstallerX source APK lives in `bin/modfile/Universal/packageinstaller/`.

Each build verifies the committed file against its pinned SHA-256 before extracting or patching it. Missing or modified assets stop the build instead of silently downloading another version.

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
