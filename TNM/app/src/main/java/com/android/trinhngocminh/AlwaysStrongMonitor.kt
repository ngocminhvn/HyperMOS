package com.android.trinhngocminh

data class AlwaysStrongStatus(
    val installed: Boolean,
    val enabled: Boolean,
    val version: String,
    val engine: String,
    val autoFingerprint: String,
    val autoKeybox: String,
    val interval: String,
    val lastState: String,
)

object AlwaysStrongMonitor {
    fun read(): AlwaysStrongStatus {
        if (!RootShell.hasRoot()) {
            return AlwaysStrongStatus(
                installed = false,
                enabled = false,
                version = "—",
                engine = "—",
                autoFingerprint = "—",
                autoKeybox = "—",
                interval = "—",
                lastState = "Cần quyền root để đọc trạng thái module",
            )
        }

        val command = listOf(
            "if [ ! -f /data/adb/modules/tricky_store/module.prop ] || ! grep -q '^name=AlwaysStrong$' /data/adb/modules/tricky_store/module.prop 2>/dev/null; then",
            "  echo installed=0",
            "  exit 0",
            "fi",
            "echo installed=1",
            "[ -e /data/adb/modules/tricky_store/disable ] && echo enabled=0 || echo enabled=1",
            "sed -n 's/^version=/version=/p' /data/adb/modules/tricky_store/module.prop | head -1",
            "sed -n 's/^kb_engine=/engine=/p' /data/adb/tricky_store/alwaysstrong/state 2>/dev/null | head -1",
            "sed -n 's/^auto_fp=/auto_fp=/p' /data/adb/tricky_store/alwaysstrong/config 2>/dev/null | head -1",
            "sed -n 's/^auto_keybox=/auto_keybox=/p' /data/adb/tricky_store/alwaysstrong/config 2>/dev/null | head -1",
            "sed -n 's/^interval_sec=/interval=/p' /data/adb/tricky_store/alwaysstrong/config 2>/dev/null | head -1",
            "sed -n 's/^last_log=/last_state=/p' /data/adb/tricky_store/alwaysstrong/state 2>/dev/null | head -1",
        ).joinToString("\n")

        val result = RootShell.run(command)
        if (result.code != 0) {
            return AlwaysStrongStatus(
                installed = false,
                enabled = false,
                version = "—",
                engine = "—",
                autoFingerprint = "—",
                autoKeybox = "—",
                interval = "—",
                lastState = result.err.ifBlank { "Không đọc được trạng thái" },
            )
        }

        val values = result.out.lineSequence()
            .mapNotNull { line ->
                val index = line.indexOf('=')
                if (index <= 0) null
                else line.substring(0, index) to line.substring(index + 1)
            }
            .toMap()

        val installed = values["installed"] == "1"
        val intervalSec = values["interval"]?.toLongOrNull()
        val intervalText = when {
            intervalSec == null -> "—"
            intervalSec % 3600L == 0L -> "${intervalSec / 3600L} giờ"
            intervalSec % 60L == 0L -> "${intervalSec / 60L} phút"
            else -> "$intervalSec giây"
        }

        fun toggle(key: String): String = when (values[key]) {
            "1" -> "Bật"
            "0" -> "Tắt"
            else -> "—"
        }

        return AlwaysStrongStatus(
            installed = installed,
            enabled = installed && values["enabled"] != "0",
            version = values["version"].orEmpty().ifBlank { "—" },
            engine = values["engine"].orEmpty().ifBlank { "—" },
            autoFingerprint = toggle("auto_fp"),
            autoKeybox = toggle("auto_keybox"),
            interval = intervalText,
            lastState = values["last_state"].orEmpty().ifBlank {
                if (installed) "Không có trạng thái gần đây"
                else "Không phát hiện AlwaysStrong"
            },
        )
    }
}
