package com.android.trinhngocminh

import android.content.Context
import android.util.Base64
import java.io.File

object ThermalManager {
    private val targets = listOf(
        "/odm/etc/thermal-normal.conf",
        "/odm/etc/thermal-per-normal.conf",
        "/odm/etc/thermal-hp-normal.conf",
        "/odm/etc/thermal-nolimits.conf"
    )

    fun applyEco(context: Context): String {
        if (!RootShell.hasRoot()) return "Cần quyền root"

        val encoded = context.assets.open("thermal/thermal-eco.b64")
            .bufferedReader()
            .use { it.readText().trim() }
        val bytes = runCatching { Base64.decode(encoded, Base64.DEFAULT) }
            .getOrElse { return "Profile Eco trong APK không hợp lệ" }

        val local = File(context.filesDir, "thermal-eco.conf")
        local.writeBytes(bytes)
        val localPath = local.absolutePath.replace("'", "'\\''")
        val rootPath = "/data/adb/TNM/thermal-eco.conf"

        var r = RootShell.run(
            "mkdir -p /data/adb/TNM && cp '$localPath' '$rootPath' && chmod 0644 '$rootPath'"
        )
        if (r.code != 0) return "Không chép được profile Eco: ${r.err.ifBlank { r.out }}"

        var mounted = 0
        for (target in targets) {
            if (RootShell.run("test -f '$target'").code != 0) continue
            RootShell.runMountMaster("umount '$target' 2>/dev/null || true")
            r = RootShell.runMountMaster("mount --bind '$rootPath' '$target'")
            if (r.code != 0) {
                applyStock(context, remember = false)
                return "Không mount được $target: ${r.err.ifBlank { r.out }}"
            }
            mounted++
        }

        if (mounted == 0) return "Không tìm thấy thermal Xiaomi tương thích"

        RootShell.run("echo 0 > /sys/class/thermal/thermal_message/sconfig 2>/dev/null || true")
        context.getSharedPreferences("tnm", Context.MODE_PRIVATE)
            .edit().putString("thermal", "eco").apply()
        return "Đã bật Eco"
    }

    fun applyStock(context: Context, remember: Boolean = true): String {
        if (!RootShell.hasRoot()) return "Cần quyền root"

        targets.forEach { target ->
            RootShell.runMountMaster("umount '$target' 2>/dev/null || true")
        }
        RootShell.run("echo 0 > /sys/class/thermal/thermal_message/sconfig 2>/dev/null || true")

        if (remember) {
            context.getSharedPreferences("tnm", Context.MODE_PRIVATE)
                .edit().putString("thermal", "stock").apply()
        }
        return "Đã khôi phục thermal stock Xiaomi"
    }

    fun selected(context: Context): String =
        context.getSharedPreferences("tnm", Context.MODE_PRIVATE)
            .getString("thermal", "stock") ?: "stock"
}
