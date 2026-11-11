# TNM build-time integrations

This package combines mandatory post-fs property reporting with a signature-gated
Hide App List patch for Android 16 and Android 17, required on China and Xiaomi.eu.
The `TNM_ENABLE_APP_PRIVACY` override is honored for `other` ROM sources only.
China/EU do not have an opt-out; incompatible inputs fail during patching.
The on-device feature remains controlled by TNM App, not by the build input.

## App Privacy (Android 16 / signature-verified Android 17)

This independent client-side `ApplicationPackageManager` patch mirrors only the
six Hide App List call sites proven in the supplied ProjectRYU framework. It does
not copy RYU binaries and does not touch Kaorios, Keybox, Activation, developer
options, notifications, battery or thermal code.

On both `china` and `xiaomi_eu`, an absent/unsupported framework or
conflicting package-visibility hook stops the build instead of silently omitting Hide App List.
All six APM call sites and the helper are checked directly after patching.
The redundant *pre-pack* Hide App List audit is removed, but the separate
pre-pack LOCK staging check remains. This does not establish boot/runtime
compatibility or direct Binder/query-API filtering. Both Android versions use bin/apktool/smaliv2.jar and baksmaliv2.jar,
upgraded together to Smali/Baksmali 3.0.10. Build scripts normalize SDK 36/37 to supported --api 34 when using the unmodified
upstream Smali/Baksmali 3.0.10 pair; the resulting DEX 040 is supported on
Android 16 and Android 17. The API-level normalization affects only the DEX
tool invocation, not the detected Android OS or enabled mods. This changes
assembled DEX headers from legacy 039 to 040 (supported by Android 16/17),
so both OS3 and OS4 require full ROM regression testing.
Android 16 remains the established reference. Android 17 attempts the same six
precise APM hooks using the shared SDK-37-compatible smali tools, only if all exact
method signatures match. It fails closed on incompatible layouts, missing tools,
assembly failures, or post-build verification failures; a successful build is
not proof of Android 17 runtime/boot compatibility.
Successful Android 16 patching writes
`/system/etc/tnm/app-privacy-v1`; TNM App exposes controls only when that marker
and its on-demand backend capability are available.

Runtime configuration uses `Settings.Global` keys
`tnm_privacy_schema`, `tnm_privacy_enabled`,
`tnm_privacy_hidden_packages`, and `tnm_privacy_generation`. Odd generations
are incomplete transactions and fail open. Schema 1 accepts a sorted,
comma-separated package list. No resident process is used. The A16 helper caches successfully validated caller identity per app process, and refreshes the hidden list when a new even `tnm_privacy_generation` is committed. When disabled, it avoids the per-call package-manager Binder query.


## Post-fs property reporting (former LOCK package)

The build installs `system_ext/xbin/tnm_helper` and appends one managed
`on post-fs` action to Xiaomi's `/system/etc/init/hw/init.rc`. Original init
content is preserved. No standalone LOCK rc, blacklist or daemon is installed.

The helper bytes are unchanged (SHA-256
`6d82fc8e92089ce24226636ec4d24deb15655d7a7473d37d24fa4ae53588c1df`).
It is ARM64 PIE, uses `/system/bin/linker64`, `libc.so` and `libdl.so`.
The installed mode is 0755, fs_config ownership 0:2000 and SELinux context
`u:object_r:tnm_helper_exec:s0`. Candidate split CIL must compile before image
writes. The native init verifier runs when available. Exact repeat installs
are idempotent; changed or partial managed blocks require a clean image.

`TNM/patch.sh --check-lock` validates final LOCK staging before packing. Production
validation is consolidated into `integrate_lock.py`; the temporary comparison workflows and
offline test suite have been removed. Rebuild from clean images after this
rename; previously staged helper paths and managed policy blocks are obsolete.

The seventeen helper commands overwrite reported security properties. They do not
physically lock a bootloader, sign AVB images or change hardware attestation.
Policy compilation and file checks do not establish runtime compatibility;
full-build, boot, linker namespace and AVC checks remain separate requirements.

The LOCK staging and SELinux helpers are consolidated into
`TNM/integrate_lock.py`; original managed init/CIL markers and helper bytes
are unchanged. `integrate_lock.py` also isolates `ro.boot.vbmeta.device_state`
into a dedicated `vbmeta_device_state_prop` type readable by `(and domain (not untrusted_app_all))`
in `system_ext_sepolicy.cil` and `system_ext_property_contexts` (removing
conflicting entries from other `*property_contexts`) so third-party user apps
cannot read it directly while system/GMS domains continue reading `locked`.
`TNM/patch.sh --check-lock` validates LOCK and vbmeta SELinux staging during
Pack ROM. The six-API verifier now lives in `TNM/patch_app_privacy.py --verify`.
Reports are written to `build/reports/tnm/lock`.
