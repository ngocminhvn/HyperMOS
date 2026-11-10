# SecurityCountdown — OS3 / OS4 China

Changes only the permission-confirmation countdown of stock `com.miui.securitycenter` from 10 seconds to 0 seconds, using the former OS3 Kashi `securitycenter_countdown.py` algorithm unchanged. The APK from the downloaded ROM is preserved except for that one DEX constant; the Kashi SecurityCenter V7 ZIP remains inactive.

The module is discovered automatically by `UpdateFile/insupdate.sh`. Supported builds: **OS3 China / Android 16** and **OS4 China / Android 17**. Xiaomi.eu is skipped as in the original OS3 Kashi pipeline. Other OS/Android combinations are skipped.

- `patch.py`: requires a single `InterceptPermissionFragment` match and exactly one protected no-argument integer-returning method whose entire executable body is `const 0xa` and `return`. This fail-closed behavior avoids changing ADB input/install timers.
- `update.sh`: identifies the stock app by package, checks its Xiaomi signing certificate, unpacks with APKEditor, runs the patcher, validates the JSON patch report, rebuilds the APK and verifies its ZIP and package name **before** replacing the original. It removes the old oat cache afterward.
- If the countdown already equals zero, the module leaves the original signed APK byte-for-byte unchanged. On **OS4**, a missing or ambiguous method is skipped safely; on OS3 the existing fail-build behavior is retained.
- The rebuild retains the Xiaomi signing block but changes the DEX and therefore invalidates its signature digest. **Kaorios CorePatch must be enabled** in the ROM. Compile success alone does not prove Android 17 installation/boot compatibility.

`bin/modfile/ModApp/OS3/kashimod.sh` no longer patches SecurityCenter. `InfoChanger/update.sh` is a separate, shared OS3/A16 and OS4/A17 patch for `MiuiSystemUI.apk`.

Validate on the actual ROM and a test phone before distributing.
