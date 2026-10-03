package com.android.trinhngocminh

object RootShell {
    data class Result(val code: Int, val out: String, val err: String)

    private fun exec(vararg args: String): Result = try {
        val p = ProcessBuilder(*args).redirectErrorStream(false).start()
        val out = p.inputStream.bufferedReader().readText().trim()
        val err = p.errorStream.bufferedReader().readText().trim()
        val code = p.waitFor()
        Result(code, out, err)
    } catch (t: Throwable) {
        Result(-1, "", t.message ?: t.javaClass.simpleName)
    }

    fun run(command: String): Result = exec("su", "-c", command)

    fun runMountMaster(command: String): Result {
        val magisk = exec("su", "-mm", "-c", command)
        if (magisk.code == 0) return magisk

        val escaped = command.replace("'", "'\\''")
        val nsenter = run("command -v nsenter >/dev/null 2>&1 && nsenter -t 1 -m -- sh -c '$escaped'")
        if (nsenter.code == 0) return nsenter

        return run(command)
    }

    fun hasRoot(): Boolean = run("id -u").let { it.code == 0 && it.out == "0" }
}
