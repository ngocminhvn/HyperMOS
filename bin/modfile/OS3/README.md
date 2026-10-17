# OS3 fixed system-app snapshots

HyperMOS builds use system-app payloads committed directly in this repository. Normal ROM builds do not resolve GitHub releases and do not download these apps at build time.

## Local ZIP naming

ROM builds use local snapshots from bin/modfile/OS3/kashi/; no release downloads
take place in the normal ROM build. Keep exactly one ZIP per active prefix:

- HyperOS_AppVault*.zip
- FreeStyle_CC_mod_*.zip (FreeStyle Control Center)
- HyperOS_Screenshot*.zip (Screenshot)
- HyperOS_Launcher*.zip
- HyperOS_Security*.zip
- HyperOS_ThemeManager*.zip

The previous ColorOS_plugin_mod_*.zip is no longer used by the ROM build.
It may be removed separately once no longer needed as an archive.

## Kashi mods

bin/modfile/OS3/kashimod.sh installs App Vault, FreeStyle Control Center,
Screenshot, Theme Manager, Launcher, and Security Center.

For the two replacement packages, install only these exact ZIP members:

- FreeStyle_CC_mod_*.zip: files/OS3/MIUISystemUIPlugin.apk
  (miui.systemui.plugin)
- HyperOS_Screenshot*.zip: files/MIUIScreenshot.apk
  (com.miui.screenshot)

Both APKs replace the matching stock package **in its current partition**.
Other APK variants or installation scripts inside the ZIP are not injected.
The build fails if the ZIP, expected APK member, package name, or stock target
is missing.

## System APKs

bin/modfile/OS3/system/update.sh now installs only MIUIGallery.apk and the
optional external libraries in MIUIGallery/lib/. Deleted LLions APKs are no
longer mandatory. The Gallery APK is stored in Git LFS, so CI must fetch LFS
objects before the build.

The manual Update Kashi Apps workflow checks the matching Mods-Center releases,
validates integrity and Android package identity, and updates local snapshots
on main when dry-run is disabled.


## Integration flow

1. Read the fixed local ZIP/APK from the repository.
2. Check ZIP readability and the required APK's presence.
3. Extract the selected APK.
4. Identify its expected Android package with `aapt dump badging`.
5. Preserve native libraries provided by the module; when absent, extract embedded ARM libraries into `lib/arm` and `lib/arm64`. No SHA-256 calculation is performed.
6. Replace the stock app at its expected system path.
7. Verify the copied app-folder shape before continuing the ROM build.

No app payload is taken from HalcyonOS or another ROM project.
