# HyperOS 4 Kashi mods

The HyperOS 4 build uses the locally staged Kashi/Mods-Center ZIPs in `bin/modfile/ModApp/Kashi/`. It does not download new Kashi releases during the ROM build.

## Active OS4 integrations

- **App Vault** (V5): installs `com.miui.personalassistant`, native libraries and the corresponding permission XML.
- **ColorOS Control Center** (V4): installs `MIUISystemUIPlugin.apk` for OS4. This mod is enabled, with no HyperLight dependency.
- **Screenshot** (V1.1): installs the shared screenshot mod.
- **Theme Manager** (V7): installs the shared theme manager mod.
- **Launcher** (V7.5F): installs `MiuiHome.apk`, native libraries, launcher overlay and privileged-permission whitelist. The OS4 variant is preferred; OS3-only variants are rejected.

`FreeStyle_CC_mod_V1` is a separate alternative Control Center implementation, **not an additional simultaneous mod**. It is retained as a reference archive rather than replacing the active ColorOS Control Center. Applying both variants to the same target would overwrite one with the other.

## Security Center

The Kashi SecurityCenter V7 replacement is **not installed**. The downloaded ROM's stock SecurityCenter is handled separately by `bin/modfile/UpdateFile/SecurityCountdown/` on China OS3/A16 and OS4/A17. Xiaomi.eu is skipped by that module. This avoids competing replacements and keeps the countdown patch isolated.

## Build flow

`build.sh` calls `ModApp/OS4/insmod.sh` for OS4 after the OS3 entrypoint (which skips OS4). `_common.sh` reuses OS3 validation and file-copy helpers while selecting OS4-specific ZIP members before shared members. No OS3-only APK is chosen as an OS4 fallback.

## Validation

The ROM build statically replaces system APKs; it does not execute the original Kashi ZIP's Magisk installation hooks. Successful extraction, APK package verification or CI build **do not guarantee runtime compatibility** on Android 17. Validate OS4 China and EU with an unlocked test device, especially Launcher, SystemUIPlugin and SecurityCenter. Kaorios and CorePatch are not changed by this OS4 integration.
