# TNM App Privacy (Android 16)

This independent client-side `ApplicationPackageManager` patch mirrors only the
six Hide App List call sites proven in the supplied ProjectRYU framework. It does
not copy RYU binaries and does not touch Kaorios, Keybox, Activation, developer
options, notifications, battery or thermal code.

The package stage always runs the patch for Android 16; there is no build
checkbox or `TNM_ENABLE_APP_PRIVACY` opt-out. The gate verifies the six method
signatures before writing. Unknown method layouts and an existing RYU hook
are reported and skipped before the framework image is changed. This patches
`framework.jar` directly; it does not rebuild or re-sign any APK.
A successful patch writes
`/system/etc/tnm/app-privacy-v1`; TNM App exposes controls only when that marker
and its on-demand backend capability are available.

Runtime configuration uses `Settings.Global` keys
`tnm_privacy_schema`, `tnm_privacy_enabled`,
`tnm_privacy_hidden_packages`, and `tnm_privacy_generation`. Odd generations
are incomplete transactions and fail open. Schema 1 accepts a sorted,
comma-separated package list. No resident process is used.

