package com.android.trinhngocminh

enum class RebootTarget(val description: String) {
    SYSTEM("Khởi động lại Android bình thường"),
    BOOTLOADER("Khởi động vào bootloader fastboot"),
    FASTBOOTD("Khởi động vào userspace fastbootd"),
    RECOVERY("Khởi động vào recovery"),
}

data class RebootResult(
    val ok: Boolean,
    val message: String,
)

object RebootManager {
    fun reboot(target: RebootTarget): RebootResult {
        if (!RootShell.hasRoot()) {
            return RebootResult(false, "Cần cấp quyền root cho TNM")
        }

        val command = when (target) {
            RebootTarget.SYSTEM -> "reboot"
            RebootTarget.BOOTLOADER -> "reboot bootloader"
            RebootTarget.FASTBOOTD -> "reboot fastboot"
            RebootTarget.RECOVERY -> "reboot recovery"
        }

        val result = RootShell.run(command)
        return if (result.code == 0) {
            RebootResult(true, "Đang khởi động lại…")
        } else {
            RebootResult(
                false,
                "Không thể khởi động: " + result.err.ifBlank { result.out.ifBlank { "lệnh root thất bại" } },
            )
        }
    }
}
