# GoogleKeybroad — China Enhanced Keyboard (A15/A16/A17)

This is a script-only relocation of the original `MIUIFrequentPhrase.apk`
Enhanced Keyboard patch out of `Universal/LiteGapps/LiteGapps16/update.sh`.
No Gboard APK, GApps binaries, signatures or payload paths are moved.
`Universal/insfile.sh` stages LiteGapps first; `UpdateFile/insupdate.sh`
then executes this module's `update.sh`.

- **China only**: rewrite the legacy Baidu IME target in the extracted
  `MIUIFrequentPhrase.apk` to `com.google.android.inputmethod.latin`.
- **Gboard fallback**: require `product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk`
  before modifying the phrase APK. This fails safely if a China build has no
  system Gboard; it does not try to make a missing keyboard the default.
- **All OS/regions**: `bin/ddevice/DEBLOAT/debloat.sh` removes only
  `product/app/MiType/MiType.apk` and its containing `MiType` directory.
- **China JAR integration**: `patch_jar_smali.py` is called by the existing
  Android 15/16/17 CorePatch scripts while they already have Xiaomi JARs
  decompiled. It updates remaining literal Baidu IME references in relevant
  input-method classes; on A17, it prevents Xiaomi's removed IME from blocking
  the standard default-IME reset. It leaves Xiaomi-only SMS CAPTCHA APIs,
  feature/overlay allowlists and unrelated `com.xiaomi.type` constants alone.

The module does not re-sign an APK, patch unrelated framework packages,
alter Root/AVB/Kaorios or force a default IME into users' `/data`.
**A successful ROM build is not proof of first-boot IME selection**; verify on
an unlocked recoverable device after a clean initial setup.
