# Fake Lock

Enabled by default by the package stage. Set `HYPERMOS_FAKE_LOCK=false` in the build environment to omit it from a clean build.

This restores the ARM64 `xeutoolbox` payload from the repository's earlier ResetProp implementation (Git blob `dd58ca45deae0c2c0e9704d46d8c63adb061c473`). It uses a single non-blocking, disabled/oneshot init service. When `sys.boot_completed=1` is observed, init starts the helper immediately with no intentional startup delay or `sleep`. The `timeout_period 5` entry is only a five-second watchdog that kills a stuck helper; it is not a five-second delay. The helper loads these three values serially using `-n -f`:

```properties
ro.boot.vbmeta.device_state=locked
ro.boot.verifiedbootstate=green
ro.secureboot.lockstate=locked
```

The `-n` mode avoids property-service notifications. The overrides are runtime-only. Bootloader state, AVB images, hardware attestation and the initial boot-time properties are unchanged. Apps that read before boot completion can see the original state; apps that cache it may need restarting.

## Build validation

`install.py` verifies the pinned ELF64/AArch64 payload, resolves the three property contexts from the extracted ROM and stages the SELinux addition. It requires `secilc` and compiles the combined platform, vendor, system_ext and available product/odm policy, using the vendor's mapping version, before writing any image files. Compilation errors abort the package stage.

The service runs as root in the dedicated `hypermos_fake_lock` domain. The old implementation's `init` execution domain and `execute_no_trans` rule are not restored. CIL comments use semicolons. Execution labels and root/0755 ownership are written to the repacking config so `bin/fix_selinux.py` preserves them. The system_ext fingerprint changes to invalidate the stock precompiled-policy cache and make Android init load the policy addition.

This follows Android init's [split-policy compilation](https://android.googlesource.com/platform/system/core/+/master/init/selinux.cpp) options, including its normal `-N` setting; it does not validate source-build neverallow assertions. [A16 init policy](https://android.googlesource.com/platform/system/sepolicy/+/refs/heads/android16-release/private/init.te) prohibits running an executable without leaving the init domain.

Always rebuild from clean base images. Running the installer twice on an already patched image is rejected instead of duplicating policy types.

## Verification

```sh
python3 -B bin/package/ResetProp/test_install.py
```

Host tests compile a synthetic split policy with real `secilc`, check failure leaves the image unchanged, check property-context precedence/conflicts, and run the real repacking-label fixer. The ARM64 payload uses the Android linker and has 16 KiB-aligned load segments. Device execution and Xiaomi 15 Pro A16/OS3 boot have not been verified.

After a device boot, inspect `getprop ro.boot.vbmeta.device_state`, `getprop ro.boot.verifiedbootstate`, `getprop ro.secureboot.lockstate`, and `getprop init.svc.hypermos_fake_lock`. If values remain unchanged, preserve the helper's init/SELinux errors from logcat rather than treating host tests as a runtime success.
