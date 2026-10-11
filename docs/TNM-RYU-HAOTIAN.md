# TNM app / RYU HAOTIAN integration branch

ROM: `ngocminhvn/HyperMOS@test-tnm-ryu-haotian`, based on
`test-ryu-performance-haotian` at `4461ab0e25701ee92ed6e0097955705b0e69650a`.
App: `ngocminhvn/app@test-tnm-ryu-haotian`, based on
`codex/ryu-thermal-ui` at `0ff35e40e214bda7ea9a62093da555731e83ff94`.

## Matching ROM and APK

1. Build the app branch using **Build TNM APK**. Download its `TNM-updater`
   artifact. This branch builds with the existing TNM signing key and does
   not deploy to the stable Pages update channel.
   The experimental app does not fetch stable Pages updates; update it with
   the matching signed APK artifact from this branch.
2. Make the signed `TNM.apk` available at a direct HTTPS download URL. Use
   the APK's `sha256` from the artifact's `update.json` (not `packageSha256`,
   which hashes the compressed `.xz` file).
3. Run **HyperMOS ROM Build** on this ROM branch with `tnm_test_apk_url`
   and `tnm_test_apk_sha256`. Missing inputs fail before ROM download.
   The installer verifies SHA-256, APK signature, TNM package/version,
   embedded framework capability contract and native libraries before staging.
4. Test notifications, foreground app switching, screen-off restoration,
   battery drain and thermal behavior on Xiaomi 15 Pro / HAOTIAN Android 16.

## Framework, notifications and app behavior

The ROM retains the source branch's guarded framework FCM/FGS/Doze patches,
PowerKeeper GMS build gates, conditional UID kill policy and original PerfHook
dependency closure. It also retains the ten original performance XMLs and
nineteen selected thermal profiles, including final retention/SELinux audits.
These are inherited implementations, not newly proven runtime parity.

TNM app calls `tnm-bridge` -> its signed APK backend `tnmctl` ->
`/system_ext/bin/tnm-frameworkctl` -> `/system_ext/bin/tnm-thermalctl`.
The legacy `ryu-thermalctl` entrypoint remains compatible. Global and per-app
profiles use the original `projectryu_thermal_*` Settings keys because the
native PowerKeeper observer requires those exact names. TNM is the visible
brand; internal classes/keys are not blindly renamed.

The TNM app already includes ROM diagnostics, battery saver, display presets,
and notification tools from its base branch. This branch exposes the full
ROM command list, replaces visible RYU labels with TNM, allows up to 32
per-app profiles and confirms the saved per-app map after applying it.

`TNMFramework` is an on-demand adapter, not a replacement Binder service.
The source branch has not ported every RYU framework method or the original
RYU app UI. No claim of visual or device runtime identity is made. Full-screen
intent/force-stop bypasses, no-limit/charging profiles and hardware protection
changes remain outside the inherited port. A complete ROM build and device
test are still required before treating this as equivalent to RYU.
