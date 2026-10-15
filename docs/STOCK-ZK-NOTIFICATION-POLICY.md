# HAOTIAN PowerKeeper and notification policy

The Android 16 build uses the complete pinned ZKOS HAOTIAN PowerKeeper as the
code, manifest, resources and assets baseline. The current TNM `classes.dex`
contributes only the 20 per-app PerfHook classes, which are renamed to the TNM
namespace and initialized by ZKOS PowerKeeper. Other RYU policy/thermal code is
not overlaid.

ZK-specific build APIs/settings are adapted for TNM: `IS_ZK_BUILD` becomes
`IS_TNM_BUILD`, `com.zk.SettingsHelper` becomes
`com.android.tnm.TNMSettingsHelper`, and `zk_max_fps` becomes `tnm_max_fps`.
The donor's `ro.product.zk_device` property is preserved unchanged. The private
`/sys/class/thermal/thermal_message/zk_state` node is absent on HAOTIAN, so its
thermal-message state path maps to stock `temp_state`.

The global C2DM/FCM framework transport remains enabled for valid GMS
receivers; no app-wide Doze whitelist or per-app instant-notification backend
is added. `SecurityCenter` and `MiuiSystemUI` are not part of this port.
Vendor/ODM thermal, powerhint and performance configuration stays from the
base ROM. The donor is rebuilt rather than installed as a prebuilt APK.

The workflow downloads a SHA-pinned PowerKeeper donor from the manually run
`Collect ZKOS HAOTIAN PowerKeeper` workflow artifact. The build preserves
Xiaomi v1 signature metadata, but the modified APK is not cryptographically
Xiaomi-signed and still requires the ROM's audited v1/digest bypass. Runtime
behavior has not been tested on-device.
