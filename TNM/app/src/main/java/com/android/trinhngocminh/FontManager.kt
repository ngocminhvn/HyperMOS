package com.android.trinhngocminh

import android.content.Context
import android.net.Uri
import java.io.File

object FontManager {
    private const val target = "/data/system/theme/fonts"
    private const val backup = "/data/adb/TNM/font-backup"
    private const val marker = "/data/adb/TNM/font-backup.ready"

    private val aliases = listOf(
        "MI_Theme_VF.ttf",
        "Roboto-Regular.ttf", "Roboto-Italic.ttf", "Roboto-Bold.ttf", "Roboto-BoldItalic.ttf",
        "Roboto-Light.ttf", "Roboto-LightItalic.ttf", "Roboto-Medium.ttf", "Roboto-MediumItalic.ttf",
        "Roboto-Black.ttf", "Roboto-BlackItalic.ttf", "Roboto-Thin.ttf", "Roboto-ThinItalic.ttf",
        "Miui-Regular.ttf", "Miui-Bold.ttf", "MiuiEx-Regular.ttf", "MiuiEx-Bold.ttf", "MiuiEx-Light.ttf"
    )

    fun apply(context: Context, uri: Uri): String {
        if (!RootShell.hasRoot()) return "Cần quyền root"

        val tmp = File(context.cacheDir, "tnm-font.bin")
        context.contentResolver.openInputStream(uri)?.use { input ->
            tmp.outputStream().use(input::copyTo)
        } ?: return "Không đọc được file font"

        val quoted = tmp.absolutePath.replace("'", "'\\''")
        val script = buildString {
            append("set -e; mkdir -p /data/adb/TNM; ")
            append("if [ ! -f '$marker' ]; then rm -rf '$backup'; mkdir -p '$backup'; ")
            append("if [ -d '$target' ]; then cp -a '$target'/.' '$backup'/ 2>/dev/null || true; fi; touch '$marker'; fi; ")
            append("mkdir -p '$target'; ")
            aliases.forEach { alias ->
                append("cp '$quoted' '$target/$alias'; chmod 0644 '$target/$alias'; ")
            }
            append("chown -R system:system '$target' 2>/dev/null || true; ")
            append("restorecon -RF '$target' 2>/dev/null || true")
        }

        val r = RootShell.run(script)
        return if (r.code == 0) {
            "Đã áp dụng font. Khởi động lại máy để nạp sạch."
        } else {
            "Lỗi: ${r.err.ifBlank { r.out }}"
        }
    }

    fun restore(): String {
        if (!RootShell.hasRoot()) return "Cần quyền root"

        val aliasesToRemove = aliases.joinToString(" ") { "'$target/$it'" }
        val script = """
            set -e
            if [ -f '$marker' ]; then
                rm -rf '$target'
                mkdir -p '$target'
                cp -a '$backup'/.' '$target'/ 2>/dev/null || true
                rm -rf '$backup' '$marker'
            else
                rm -f $aliasesToRemove
            fi
            chown -R system:system '$target' 2>/dev/null || true
            restorecon -RF '$target' 2>/dev/null || true
        """.trimIndent()

        val r = RootShell.run(script)
        return if (r.code == 0) {
            "Đã khôi phục font trước đó. Khởi động lại máy."
        } else {
            "Lỗi: ${r.err.ifBlank { r.out }}"
        }
    }
}
