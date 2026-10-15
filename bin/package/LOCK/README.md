# LOCK RYU post-fs integration

update.sh now installs the verified RYU helper and stages the nine unconditional
ProjectRYU property writes in the extracted Xiaomi primary init:
`build/baserom/images/system/system/etc/init/hw/init.rc`, runtime
`/system/etc/init/hw/init.rc`, under `on post-fs`.

This changes reported property values, including locked/green security-state
fields. It does not physically lock the bootloader, sign AVB images, modify TEE
firmware, or generate an authentic hardware attestation. Existing Kaorios, root,
TNM, PowerKeeper and other patches are unchanged. No device flash is performed.

## Implemented integration

- A single BEGIN/END-managed init block contains the donor's nine foreground
  `exec u:r:init:s0 root root -- /system_ext/xbin/ryu_helper -n ...` commands.
  Every original Xiaomi init byte is preserved. No standalone LOCK tnm.rc,
  blacklist condition, daemon or service is installed.
- The payload is copied to `system_ext/xbin/ryu_helper` with mode 0755; repack
  fs_config records UID/GID 0:2000, matching the donor.
- Both runtime and repack file contexts map exactly that path to
  `u:object_r:ryu_helper_exec:s0`. A managed split-CIL block declares the type
  and grants init read/getattr/map/execute/open/execute_no_trans, matching donor
  execution staging. No generic system_file execution grant or permissive
  domain is introduced.
- Candidate split CIL is compiled with secilc before image writes. Native init
  verification runs when host_init_verifier is installed. A native init
  validation failure rolls back installer writes.
- Vendor/ODM precompiled policy caches are removed only after candidate
  compilation succeeds, so init cannot select a stale policy without the new
  type. Runtime policy remains enforcing; no setenforce change is made.
- Exact repeat installs are idempotent. Partial/changed/duplicate managed blocks,
  other helper triggers, conflicting labels or payloads cause failure instead
  of guessing how to rewrite them. Input paths escaping the image are rejected.
- The final workflow check uses `update.sh --check`: it verifies the installed
  helper, DAC metadata, contexts, block uniqueness, absence of stale caches and
  recompiles final split CIL without modifying the image.

## Verified donor

The supplied archive was inspected by
[LOCK ROM evidence](https://github.com/ngocminhvn/HyperMOS/actions/runs/38676092039):
https://psychz.dl.sourceforge.net/project/projectzk/ProjectRYU/RYU-CN/RYUOS_HAOTIAN_OS3.0.309.0.WOBCNXM_CN261005.zip

The bundled helper is byte-for-byte identical, SHA-256
`6d82fc8e92089ce24226636ec4d24deb15655d7a7473d37d24fa4ae53588c1df`.
It is AArch64 ELF64 PIE, interpreter `/system/bin/linker64`, DT_NEEDED
`libdl.so` and `libc.so`. Installer checks those fields with readelf and the
declared Bionic paths, recognizing Android runtime APEX symlinks without
following them into the build host. Runtime linker namespace behavior still
requires a boot test.

Donor init contains nine writes at post-fs and two further locale/blacklist
actions. Only the unconditional post-fs action is reproduced. The Xiaomi prefix
matches stock after trimming trailing whitespace. No donor init file is copied.

## Verification and build

```sh
bash -n bin/package/LOCK/update.sh
python3 bin/package/LOCK/test_update.py
bash bin/package/LOCK/update.sh
bash bin/package/LOCK/update.sh --check
```

The 15 offline installer tests cover staging, idempotence, conflicts and rollback.
Only native compiler/init calls are mocked in unit fixtures; the production
installer has no compile bypass. The separate LOCK integration validation
workflow applies the installer to real stock metadata/CIL from the evidence
artifact, runs native secilc, checks Xiaomi byte preservation and repeat builds,
and uploads its reports. A successful validation dispatches the existing full
main ROM build. Manual validation accepts another evidence run ID if the
seven-day artifact has expired.

Reports are written under `build/reports/lock` and uploaded by the full build.
Policy compilation uses Android runtime-style `-N` flags, so this is not a
neverallow analysis. Native verifier availability, full-build outcome and
device boot/AVC results must be reported separately. Foreground helper commands
can delay boot if the helper hangs. Nothing here certifies a physical relock,
genuine green AVB state or unchanged behavior of opaque donor code on a device.
