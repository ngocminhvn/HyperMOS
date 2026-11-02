# Kaorios PIF Native Property Bridge

Source-built native ELF libraries that create a process-local view of selected Android read-only properties in DroidGuard (`com.google.android.gms.unstable`).

## Architecture & Binaries

- **`arm64-v8a/`** (target: `/system/lib64/`):
  - `libkaoripif.so`
- **`armeabi-v7a/`** (target: `/system/lib/`):
  - `libkaoripif.so`

## Installation

### Manual Installation
Copy the libraries to the target ROM partition:
- Copy `arm64-v8a/libkaoripif.so` to `/system/lib64/`
- Copy `armeabi-v7a/libkaoripif.so` to `/system/lib/`
- Set permissions to `0644`, owner `root:root`
- Set SELinux context to `u:object_r:system_lib_file:s0`

### Script Installation
Run on device or against extracted ROM directory:
```sh
sh install.sh /path/to/rom_root
```

## Security & Verification
- The MOD-owned framework bridge loads `libkaoripif.so` in the GMS unstable process and passes a selected set of Toolbox PIF values to it.
- The backend replaces only the relevant Bionic property pages in that process, verifies every readback and restores the original values on verification failure. It does not install a linker hook or use ShadowHook.
- Check `KaoriosNativePIF` in logcat and the GMS unstable process maps to confirm the bridge is active. Integrity labels are decided by Google and are not guaranteed by this library.
