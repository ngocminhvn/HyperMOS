package com.android.trinhngocminh

data class IntegrityState(
    val summary: String,
    val verifiedBoot: String,
    val bootloader: String,
    val vbmeta: String,
    val buildTags: String,
    val root: String,
)

object IntegrityDiagnostics {
    private fun prop(name: String): String = try {
        ProcessBuilder("getprop", name).start().inputStream.bufferedReader().readText().trim()
    } catch (_: Throwable) {
        ""
    }

    fun read(): IntegrityState {
        val verifiedBoot = prop("ro.boot.verifiedbootstate").ifBlank { "Không rõ" }
        val vbmeta = prop("ro.boot.vbmeta.device_state").ifBlank { "Không rõ" }
        val flashLocked = prop("ro.boot.flash.locked")
        val tags = prop("ro.build.tags").ifBlank { "Không rõ" }
        val root = if (RootShell.hasRoot()) "Có" else "Không"

        val bootloader = when {
            flashLocked == "1" || vbmeta.equals("locked", true) -> "Locked"
            flashLocked == "0" || vbmeta.equals("unlocked", true) -> "Unlocked"
            else -> "Không rõ"
        }

        val modified =
            root == "Có" ||
                bootloader == "Unlocked" ||
                !verifiedBoot.equals("green", true) ||
                (tags != "Không rõ" && !tags.contains("release-keys"))

        val summary = if (modified) {
            "Thiết bị có dấu hiệu hệ thống đã chỉnh sửa"
        } else {
            "Không thấy dấu hiệu chỉnh sửa rõ ràng từ kiểm tra cục bộ"
        }

        return IntegrityState(
            summary = summary,
            verifiedBoot = verifiedBoot,
            bootloader = bootloader,
            vbmeta = vbmeta,
            buildTags = tags,
            root = root,
        )
    }
}
