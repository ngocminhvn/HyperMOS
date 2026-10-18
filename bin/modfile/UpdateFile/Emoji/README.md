# Emoji-only module (Android 15 / 16 / 17)

Replaces only existing NotoColorEmoji.ttf inside unpacked ROM images.
No changes to text fonts, MiSans, Roboto, fonts.xml, ThemeManager or system font settings.

The NotoColorEmoji.ttf payload reuses the identical Git blob formerly located at
Fonts/Shared/NotoColorEmoji.ttf. The old Fonts module, variable font generator,
font libraries, classic MIUI assets and unused font definitions were removed.

insupdate.sh automatically discovers Emoji/update.sh. Android releases outside
15/16/17 are skipped. Supported ROMs with no existing NotoColorEmoji.ttf fail
rather than inject a font at an unknown location. No device-specific payload.
