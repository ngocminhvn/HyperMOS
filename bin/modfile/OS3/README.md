# OS3 locally staged system-app releases

HyperMOS builds use the latest validated system-app release ZIPs committed to
this repository by the Update Kashi Apps workflow. SecurityCenter installed in
the ROM is taken from the downloaded Xiaomi base ROM and patched during build.
Normal ROM builds do not fetch GitHub releases on their own.

## Local ZIP naming

ROM builds use locally staged snapshots from bin/modfile/OS3/kashi/; the updater
refreshes each ZIP from its own newest stable upstream release. Keep exactly one
ZIP per family prefix, regardless of version suffix:

- HyperOS_AppVault*.zip
- ColorOS_plugin_mod_*.zip (Control Center selected by ROM)
- FreeStyle_CC_mod_*.zip (updated reference ZIP; not installed in ROM)
- HyperOS_Screenshot*.zip
- HyperOS_Launcher*.zip
- HyperOS_Security*.zip (updated reference ZIP; not installed in ROM)
- HyperOS_ThemeManager*.zip

There are no pinned app versions. ColorOS V3, V4 and subsequent valid versions
are selected using the same `ColorOS_plugin_mod_` prefix; the updater also
removes the previous release ZIP when committing its replacement.

## Kashi mods

bin/modfile/OS3/kashimod.sh installs App Vault, the latest staged ColorOS
Control Center, Screenshot, Theme Manager, and Launcher. The Xiaomi SecurityCenter extracted
from the downloaded base ROM is retained and patched in place: only the
InterceptPermission confirmation count becomes 0. The ADB input/install
handler delays stay unchanged from the base ROM, following the observed ZKOS
behavior. The patch is deliberately limited to the InterceptPermissionFragment
smali file.

The HyperOS_Security*.zip snapshot is updated from upstream like the other
ZIPs but remains an inactive reference: it is not read by the ROM build.

- ColorOS_plugin_mod_*.zip: find the unique APK
  with Android package miui.systemui.plugin, keeping its app-local libs and
  supported system-tree overlays as in the original ColorOS module.
- HyperOS_Screenshot*.zip: install only files/MIUIScreenshot.apk
  (com.miui.screenshot) into the matching stock partition.

The ColorOS mod is restored in place of FreeStyle. Module runtime scripts
are not executed during ROM build. The build fails when a source ZIP, unique
expected package, or stock target is missing.

## System APKs

bin/modfile/OS3/system/update.sh now installs only MIUIGallery.apk and the
optional external libraries in MIUIGallery/lib/. Deleted LLions APKs are no
longer mandatory. The Gallery APK is stored in Git LFS, so CI must fetch LFS
objects before the build.

The manual Update Kashi Apps workflow checks all seven upstream sources:
App Vault, ColorOS Control Center, FreeStyle Control Center, Screenshot,
Launcher, Security Center and Theme Manager. The job retrieves the newest
stable release for every source, validates its ZIP and expected APK package
(and Launcher overlay), then replaces the old ZIP if the filename or bytes
have changed. It fails rather than silently skipping an unavailable,
ambiguous or invalid release. Changes are committed directly to main unless
the user selected dry-run.

The FreeStyle and Security Center ZIPs are also updated, but remain reference
archives and are not installed by the ROM build. Running the updater is a
separate manual action; normal ROM builds never fetch releases.


## Integration flow

1. Read the latest staged local ZIP/APK from the repository (except SecurityCenter,
   which always comes from the downloaded base ROM).
2. Check ZIP readability and the required APK's presence.
3. Extract the selected APK.
4. Identify its expected Android package with `aapt dump badging`.
5. Preserve native libraries provided by the module; when absent, extract embedded ARM libraries into `lib/arm` and `lib/arm64`. No SHA-256 calculation is performed.
6. Replace the stock app at its expected system path.
7. Verify the copied app-folder shape before continuing the ROM build.

No app payload is taken from HalcyonOS or another ROM project.
