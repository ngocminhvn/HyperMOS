# HAOTIAN PowerKeeper and notification policy

Android 16 builds use the uploaded ZKOS PowerKeeper executable DEX in
`bin/package/NOTIFICATION_FIX/A16/classes.dex` (pinned Git blob
`f229fb0a5c67d41a55310a119ef64b18a86d6c04`). The historical RYU/TNM
PerfHook DEX is retained separately as `tnm-perfhook-source.dex` (pinned Git
blob `1b5a46ea3f9ead44a5467584e15dddd7ba4b0555`). It contributes only
20 per-app PerfHook classes and the embedded TNMFramework compatibility API.
No ZKOS ROM or donor APK is downloaded by the ROM build.

The ZK bytecode is adapted for TNM: IS_ZK_BUILD becomes IS_TNM_BUILD,
com.zk.SettingsHelper becomes com.android.tnm.TNMSettingsHelper, and
zk_max_fps becomes tnm_max_fps. The donor ro.product.zk_device reference is
preserved unchanged. The unavailable HAOTIAN zk_state thermal node is mapped
to stock temp_state. ZKOS power behavior comes from the executable classes,
not from its APK manifest/resources/assets or standalone apps.

KillProcessController uses two verified RYU HAOTIAN method bodies,
`setUidState(IZ)V` and `shouldKillByCheckerPolicy(I)Z`. The first retains
RYU's conditional UID kill call; the second returns true for checker POLICY
values 1 or 2, otherwise false. The remainder of KillProcessController and
the GmsObserver, ActiveStateController and other ZKOS classes remain ZKOS.
The port verifies the existing RYU-compatible checker field in both class
layouts, checks dependency references, and fails on unexpected method layouts.
No HyperMOS-specific package-name exception is injected for GMS. The RYU
`setUidState` and `shouldKillByCheckerPolicy` method bodies are installed
unchanged apart from existing compatibility adaptations. RYU's handling of
allowed UIDs, locked applications, visible windows and checker POLICY=1/2
is preserved. As with RYU, this controller can stop GMS if its effective
policy allows it; any independent GMS notification delivery settings remain
outside this port. Verify notifications and standby power on the device.

Only the compiled patched DEX replaces the stock PowerKeeper DEX. The final
APK keeps the stock Xiaomi AndroidManifest.xml, resources, assets, JNI and
META-INF entries byte-for-byte at the content level; the ROM's original stock
Xiaomi certificate metadata is retained without re-signing the modified DEX.
This is NOT a cryptographically valid Xiaomi signature. The existing ROM
signature handling is separate; no new bypass is added here.

Global C2DM/FCM framework transport remains enabled for valid GMS receivers.
No blanket Doze whitelist, all-app instant-notification backend, or dedicated
GMS wake/alarm/network unrestricted rule is added. Stock SecurityCenter,
MiuiSystemUI and vendor/ODM thermal services remain independent of this port;
TNM perf/powerhint/thermal XML is imported through its existing module.

The manual Collect ZKOS HAOTIAN PowerKeeper workflow may still be used for
future donor comparison, but it is no longer a dependency for build.yml.
Static DEX/metadata checks are performed; compatibility, battery and
notification behavior require a full build and on-device validation.
