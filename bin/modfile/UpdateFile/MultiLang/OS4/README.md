# HyperOS 4 China — Vietnamese (Android 17)

The root \`MultiLang/update.sh\` runs \`OS4/update.sh\` only for China OS4.
Unlike the old XML-only validation, it now builds actual Vietnamese runtime
resource overlay (RRO) APKs using the bundled Xiaomi.eu XML in
\`Vietnamese/main\`. **No Xiaomi APK, SystemUI APK, framework-res APK, or DEX
is replaced by this module.** OS3's 67 prebuilt overlays remain unchanged.

## Build process

1. Locate each matching app APK in \`build/baserom/images\` to obtain its real
   Android target package name and eligible resource metadata automatically.
   No manual Xiaomi.eu-versus-China XML audit is required.
2. Compile Vietnamese \`values-vi\` and regional \`values-*-vi\` resources with
   AAPT2 and generate Android 11+ \`res/xml/overlays.xml\` resource maps.
   Skip names missing in the target or blocked by the target's overlayable
   policy. For targets defining overlayable groups, create separate overlays
   for groups permitting product overlays.
3. Link against the ROM's own \`framework-res.apk\`, zipalign, sign with the
   repository's shared AOSP test key, and verify using \`apksigner\`.
4. Put generated RRO APKs in
   \`product/overlay/HyperMOS-OS4-VI/\`. When
   \`product/overlay/config/config.xml\` exists, append immutable, enabled
   entries without deleting or disabling existing overlay entries.
5. Write \`build/baserom/os4-vietnamese-report.json\` listing compiled and
   skipped APKs. Fail the build if compilation/signing errors or no overlays
   were generated; never silently report XML validation as Vietnamese support.

## Tooling

GitHub-hosted Ubuntu Android SDK build-tools provide \`aapt2\`,
\`apksigner\` and \`zipalign\` under \`$ANDROID_HOME/build-tools/*/\`.
The builder also accepts these commands on \`PATH\`.

To run manually **after ROM extraction**:

\`\`\`bash
bash bin/modfile/UpdateFile/MultiLang/OS4/update.sh
\`\`\`

## Limitations & device verification

A compiled RRO is not proof that every string is translated or that the
device's \`idmap2\` will accept the overlay. Android 17 enforces overlayable
and partition policies. Resources absent from the source ROM or not
overlayable from product cannot be translated by this mechanism. Do not
force re-signing Xiaomi framework/SystemUI as a workaround.

After flashing the **complete matching build** on a test device:

\`\`\`sh
adb shell cmd overlay list --user 0
adb shell cmd overlay list --user current
adb shell cmd overlay dump com.hypermos.vi.os4.settings.r1
adb shell getprop persist.sys.locale
\`\`\`

Verify that the generated \`com.hypermos.vi.os4.*\` packages are **enabled**
and that Settings, SystemUI, and system dialogs show Vietnamese. If overlays
show errors, inspect \`adb shell ls /data/resource-cache\` and
\`adb logcat -b all | grep -iE 'idmap|OverlayManager'\`. Device boot and
locale switching must be tested; a successful build alone does not
guarantee them.
