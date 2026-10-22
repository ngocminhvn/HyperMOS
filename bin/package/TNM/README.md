# TNM build-time integrations

This package combines mandatory post-fs property reporting (formerly in
`bin/package/LOCK`) with the optional Android 16 App Privacy framework patch.
The `TNM_ENABLE_APP_PRIVACY=0` switch disables **only** App Privacy; it never
disables the post-fs stage.

## App Privacy (Android 16)

This independent client-side `ApplicationPackageManager` patch mirrors only the
six Hide App List call sites proven in the supplied ProjectRYU framework. It does
not copy RYU binaries and does not touch Kaorios, Keybox, Activation, developer
options, notifications, battery or thermal code.

The package stage enables the feature by default. Set
`TNM_ENABLE_APP_PRIVACY=0` only to opt out. Unknown method layouts and an
existing RYU hook are reported and skipped before the framework image is
changed. A successful patch writes
`/system/etc/tnm/app-privacy-v1`; TNM App exposes controls only when that marker
and its on-demand backend capability are available.

Runtime configuration uses `Settings.Global` keys
`tnm_privacy_schema`, `tnm_privacy_enabled`,
`tnm_privacy_hidden_packages`, and `tnm_privacy_generation`. Odd generations
are incomplete transactions and fail open. Schema 1 accepts a sorted,
comma-separated package list. No resident process is used.


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

`update.sh --check` validates final image staging before packing. Production
validation lives in `sepolicy.py`; the temporary comparison workflows and
offline test suite have been removed. Rebuild from clean images after this
rename; previously staged helper paths and managed policy blocks are obsolete.

The nine helper commands overwrite reported security properties. They do not
physically lock a bootloader, sign AVB images or change hardware attestation.
Policy compilation and file checks do not establish runtime compatibility;
full-build, boot, linker namespace and AVC checks remain separate requirements.

The staging implementation now lives in `TNM/integrate_lock.py` and
`TNM/lock_sepolicy.py`; the original managed init/CIL markers and helper bytes
remain unchanged. `TNM/lock.sh --check` validates the staged ROM in the Pack
ROM workflow. Reports are written to `build/reports/tnm/lock`.
