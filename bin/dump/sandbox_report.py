#!/usr/bin/env python3
"""Render aggregate sandbox observations without crypto arguments or raw traces."""
import argparse
import json
from pathlib import Path


def render(cases):
    result = [
        "# EliteRomLite offline runtime probe",
        "",
        "The installer ran ONLY in a non-root, no-network, read-only Docker "
        "container with no actual ROM, phone or host secret attached.",
        "No plaintext passwords, memory buffers, binaries, program output "
        "or raw system-call traces are exported.", "",
        "| Metric | No args | Help |", "|---|---|---|"
    ]
    a, b = cases["no-args"], cases["help"]

    for key, title in [
        ("syscall_tracing", "System call tracer"),
        ("library_tracing", "OpenSSL call tracer"),
    ]:
        def label(case):
            item = case.get(key, {})
            return (str(item.get("state", "not-run")) +
                    (" (exit " + str(item["code"]) + ")" if "code" in item else ""))
        result.append("| " + title + " | " + label(a) + " | " + label(b) + " |")

    for key, title in [
        ("custom_img", "custom.img open attempted"),
        ("firmware_update", "firmware-update access"),
        ("libcrypto_open", "libcrypto library opened"),
        ("fastboot_path", "fastboot-related file opened"),
        ("device_path", "/dev file path accessed"),
        ("connection_attempt", "network connect attempted"),
        ("writable_executable_mapping", "RWX mprotect seen"),
    ]:
        result.append("| " + title + " | " +
                      str(a.get("observations", {}).get(key, False)) + " | " +
                      str(b.get("observations", {}).get(key, False)) + " |")

    result += ["", "## Observed crypto functions (names and counts only)", ""]
    for name, values in cases.items():
        events = values.get("observed_crypto_calls", {}).get("call_counts", {})
        description = ", ".join(
            key + "=" + str(count) for key, count in sorted(events.items())
        ) or "None observed"
        result.append("- " + name + ": " + description)
    result += ["", "## Limits", "",
               "- An exit status is not proof of normal installer execution. "
               "A tracer may be denied by container security controls.",
               "- No observed crypto calls does not prove non-use. The installer "
               "may require a ROM, phone or different startup arguments, "
               "or may evade ptrace-based instrumentation.",
               "- Key material, cipher/KDF parameters and the complete "
               "custom.img-to-partition path remain undetermined unless the "
               "observations explicitly prove otherwise.",
               "- No flashing, ROM image decryption or password guessing was done."]
    return "\n".join(result) + "\n"


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--input", type=Path, required=True)
    p.add_argument("--output", type=Path, required=True)
    args = p.parse_args()
    cases = {
        name: json.loads((args.input / (name + ".json")).read_text())
        for name in ("no-args", "help")
    }
    args.output.write_text(render(cases), encoding="utf-8")
    print("[REPORT] Aggregate-only installer probe report generated")


if __name__ == "__main__":
    main()
