# Fake Lock

Enabled by default by the package stage. Set `HYPERMOS_FAKE_LOCK=false` in the build environment to omit it from a clean build.

This keeps the pinned ARM64 `xeutoolbox` payload but changes Fake Lock to run at `post-fs-data`, before normal apps can cache the real bootloader state. It then reinforces the same overrides once more when `sys.boot_completed=1`.

The runtime-only spoof now covers `ro.boot.flash.locked`, `ro.boot.vbmeta.device_state`, `ro.boot.verifiedbootstate`, and `ro.secureboot.lockstate`. Matching keys are also appended to Xiaomi `cust_prop_white_keys_list` files. Hardware bootloader state, AVB images and attestation hardware are still unchanged.

## Build validation

`install.py` verifies the pinned ELF64/AArch64 payload, resolves the active property contexts from the extracted ROM and stages the SELinux addition. It requires `secilc` and compiles the combined platform, vendor, system_ext and available product/odm policy, using the vendor's mapping version, before writing any image files. Compilation errors abort the package stage.

A disabled, oneshot service runs `xeutoolbox -n -f` against a four-key runtime file as root in the dedicated `hypermos_fake_lock` domain. `exec_start` waits for completion at both triggers; `timeout_period 5` bounds any init stall. The helper is not executed in init's own SELinux domain. The system_ext fingerprint is changed so Android init cannot silently reuse the stock precompiled policy and miss the new domain.

This follows Android init's [split-policy compilation](https://android.googlesource.com/platform/system/core/+/master/init/selinux.cpp) options, including its normal `-N` setting; it does not validate source-build neverallow assertions. [A16 init policy](https://android.googlesource.com/platform/system/sepolicy/+/refs/heads/android16-release/private/init.te) prohibits running an executable without leaving the init domain.

Always rebuild from clean base images. Running the installer twice on an already patched image is rejected instead of duplicating policy types.

## Verification

```sh
python3 -B bin/package/ResetProp/test_install.py
```

Host tests compile a synthetic split policy with real `secilc`, check failure leaves the image unchanged, check property-context precedence/conflicts, and run the real repacking-label fixer. The ARM64 payload uses the Android linker and has 16 KiB-aligned load segments. Device execution and Xiaomi 15 Pro A16/OS3 boot have not been verified.

After a device boot, inspect `getprop ro.boot.vbmeta.device_state`, `getprop ro.boot.verifiedbootstate`, `getprop ro.secureboot.lockstate`, and `getprop init.svc.hypermos_fake_lock`. If values remain unchanged, preserve the helper's init/SELinux errors from logcat rather than treating host tests as a runtime success.

## Audit constraints

`-n` bypasses Android's property service (the pinned ELF's help explicitly says
this); `-f` loads NAME=VALUE lines. The required SELinux access is read/write/map
on the resolved property area files and serial area, not `set_prop` or a socket
to property_service. The `domain` attribute also supplies Android's common
linker, APEX traversal and property-context read rules. The helper's execution
label is installed in both the repacker config and the on-device
`system_ext_file_contexts`, so restorecon retains it.

UID 0 alone is insufficient: [Android's property-area creator](https://android.googlesource.com/platform/bionic/+/refs/heads/android16-release/libc/system_properties/prop_area.cpp)
uses mode `0444`, while the pinned payload opens the existing area `O_RDWR`
(disassembled at ELF offsets `0x8cb8..0x8cbc`). Its domain therefore grants
`dac_override`, and the service explicitly retains only `DAC_OVERRIDE`.
SELinux still restricts writable mappings to the resolved property types and
serial area; this does not grant writes to arbitrary files.

Only init's active platform/system_ext/product/vendor/odm property contexts
participate in resolution. Backup/recovery files must not select an unused type.
The host split-policy compile mirrors Android 16 init's inputs and flags and
invalidates the system_ext hash used to choose precompiled vendor/odm policy.

The former OEM unlock properties describe unlock permission/capability, not the
current bootloader lock; verity mode describes dm-verity configuration. They are
excluded. No build.prop changes, AVB metadata spoof or vendor_boot repack are
made by this package. Whitelist injection is idempotent and restricted to the
same four keys; it changes Xiaomi property visibility, not hardware state.

Android init queues post-fs-data before zygote-start. This is the earliest
existing runtime hook here, but it cannot change a value already cached by an
earlier native service. The boot-completed pass restores late property changes;
it cannot invalidate framework/app caches. Neither host tests nor a successful
ROM build prove Xiaomi services never race these writes. Verify values and AVCs
on a device at both boot phases; do not promise hardware attestation, VNeID or
apps reading bootconfig/kernel interfaces will see a hardware-locked device.

Reference logic was inspected in HalcyonOS and PenguinOS
`bin/package/KouseiPatcher/fakelock_patch.sh`/`prop/cust.prop`, and BEACHEADVN's
`bin/package/ResetProp/update.sh`. Their build.prop packs, vendor_boot changes,
init-domain execution and vbmeta digest/size/version spoof were not adopted.
