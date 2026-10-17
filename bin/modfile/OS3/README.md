# OS3 fixed system-app snapshots

HyperMOS builds use system-app payloads committed directly in this repository,
except for SecurityCenter, which is taken from the downloaded Xiaomi base ROM
and patched during the build. Normal ROM builds do not resolve GitHub releases
for these apps.

## Local ZIP naming

ROM builds use local snapshots from bin/modfile/OS3/kashi/; no release downloads
take place in the normal ROM build. Keep exactly one ZIP per active prefix:

- HyperOS_AppVault*.zip
- ColorOS_plugin_mod_V3_@kashis_cringey_stuffs.zip (active Control Center)
- HyperOS_Screenshot*.zip (Screenshot)
- HyperOS_Launcher*.zip
- HyperOS_ThemeManager*.zip

The older FreeStyle_CC_mod_*.zip is retained only as an inactive archive.
Normal builds use the existing local ColorOS V3 ZIP and do not fetch updates.

## Kashi mods

bin/modfile/OS3/kashimod.sh installs App Vault, ColorOS Control Center V3,
Screenshot, Theme Manager, and Launcher. The Xiaomi SecurityCenter extracted
from the downloaded base ROM is retained and patched in place: the
InterceptPermission confirmation count becomes 0 and the ADB input/install
handler delays become 0 ms.

The old HyperOS_Security*.zip remains only as an inactive reference archive.
It is not read by normal ROM builds.

- ColorOS_plugin_mod_V3_@kashis_cringey_stuffs.zip: find the unique APK
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

The manual Update Kashi Apps workflow checks the other Mods-Center releases.
ColorOS V3 remains pinned to the named local ZIP and will not be auto-updated.


## Integration flow

1. Read the fixed local ZIP/APK from the repository (except SecurityCenter,
   which always comes from the downloaded base ROM).
2. Check ZIP readability and the required APK's presence.
3. Extract the selected APK.
4. Identify its expected Android package with `aapt dump badging`.
5. Preserve native libraries provided by the module; when absent, extract embedded ARM libraries into `lib/arm` and `lib/arm64`. No SHA-256 calculation is performed.
6. Replace the stock app at its expected system path.
7. Verify the copied app-folder shape before continuing the ROM build.

No app payload is taken from HalcyonOS or another ROM project.
