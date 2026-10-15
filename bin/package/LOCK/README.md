# LOCK TNM post-fs integration

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
