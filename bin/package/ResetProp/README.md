# Fake Lock

Enabled by default by the package stage. Set `HYPERMOS_FAKE_LOCK=false` in the build environment to omit it from a clean build.

This keeps the pinned ARM64 `xeutoolbox` payload but changes Fake Lock to run at `post-fs-data`, before normal apps can cache the real bootloader state. It then reinforces the same overrides once more when `sys.boot_completed=1`.

The runtime-only spoof now covers `ro.boot.flash.locked`, `ro.boot.vbmeta.device_state`, `ro.boot.verifiedbootstate`, `ro.boot.veritymode`, `ro.secureboot.lockstate`, `sys.oem_unlock_allowed`, and `ro.oem_unlock_supported`. Matching keys are also appended to Xiaomi `cust_prop_white_keys_list` files. Hardware bootloader state, AVB images and attestation hardware are still unchanged.

## Build validation

`install.py` verifies the pinned ELF64/AArch64 payload, resolves the three property contexts from the extracted ROM and stages the SELinux addition. It requires `secilc` and compiles the combined platform, vendor, system_ext and available product/odm policy, using the vendor's mapping version, before writing any image files. Compilation errors abort the package stage.

Each resetprop command runs as root in the dedicated `hypermos_fake_lock` domain. The helper is not executed in init's own SELinux domain. The system_ext fingerprint is changed so Android init cannot silently reuse the stock precompiled policy and miss the new domain.

This follows Android init's [split-policy compilation](https://android.googlesource.com/platform/system/core/+/master/init/selinux.cpp) options, including its normal `-N` setting; it does not validate source-build neverallow assertions. [A16 init policy](https://android.googlesource.com/platform/system/sepolicy/+/refs/heads/android16-release/private/init.te) prohibits running an executable without leaving the init domain.

Always rebuild from clean base images. Running the installer twice on an already patched image is rejected instead of duplicating policy types.

## Verification

```sh
python3 -B bin/package/ResetProp/test_install.py
```

Host tests compile a synthetic split policy with real `secilc`, check failure leaves the image unchanged, check property-context precedence/conflicts, and run the real repacking-label fixer. The ARM64 payload uses the Android linker and has 16 KiB-aligned load segments. Device execution and Xiaomi 15 Pro A16/OS3 boot have not been verified.

After a device boot, inspect `getprop ro.boot.vbmeta.device_state`, `getprop ro.boot.verifiedbootstate`, `getprop ro.secureboot.lockstate`, and `getprop init.svc.hypermos_fake_lock`. If values remain unchanged, preserve the helper's init/SELinux errors from logcat rather than treating host tests as a runtime success.
