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

        val command = """
            MOD=/data/adb/modules/tricky_store
            AS=/data/adb/tricky_store/alwaysstrong
            if [ ! -f "$MOD/module.prop" ] || ! grep -q '^name=AlwaysStrong$' "$MOD/module.prop" 2>/dev/null; then
                echo installed=0
                exit 0
            fi
            echo installed=1
            [ -e "$MOD/disable" ] && echo enabled=0 || echo enabled=1
            sed -n 's/^version=/version=/p' "$MOD/module.prop" | head -1
            sed -n 's/^kb_engine=/engine=/p' "$AS/state" 2>/dev/null | head -1
            sed -n 's/^auto_fp=/auto_fp=/p' "$AS/config" 2>/dev/null | head -1
            sed -n 's/^auto_keybox=/auto_keybox=/p' "$AS/config" 2>/dev/null | head -1
            sed -n 's/^interval_sec=/interval=/p' "$AS/config" 2>/dev/null | head -1
            sed -n 's/^last_log=/last_state=/p' "$AS/state" 2>/dev/null | head -1
        """.trimIndent()

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
            .mapNotNull {
                val i = it.indexOf('=')
                if (i <= 0) null else it.substring(0, i) to it.substring(i + 1)
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
                if (installed) "Không có trạng thái gần đây" else "Không phát hiện AlwaysStrong"
            },
        )
    }
}
