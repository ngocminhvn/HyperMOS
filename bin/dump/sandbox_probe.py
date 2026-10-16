#!/usr/bin/env python3
"""Offline installer probe: no device, ROM image, network, or raw trace exported.

This must run *inside* the restricted Docker container. It executes installer
only with no arguments or --help. It drops syscall arguments and all program
output so that only aggregate behavioral observations reach GitHub artifacts.
"""
import argparse
import glob
import json
import os
import re
import signal
import subprocess
import time
from collections import Counter
from pathlib import Path

SYSCALL = re.compile(r"\b(execveat|execve|openat2|openat|open|connect|ioctl|mprotect|ptrace|clone3|clone|mmap|kill|tkill|tgkill|prctl|seccomp)\(")
CRYPTO = re.compile(r"\b(EVP_(?:aes_256_cbc|DecryptInit_ex|DecryptUpdate|DecryptFinal_ex|sha256|md5)|PKCS5_PBKDF2_HMAC)\s*\(")
LIMIT = 2 * 1024 * 1024


def trace(argv, timeout=7):
    start = time.monotonic()
    try:
        proc = subprocess.Popen(argv, stdin=subprocess.DEVNULL,
                                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                                start_new_session=True,
                                env={"PATH": "/usr/bin:/bin", "LANG": "C",
                                     "HOME": "/nonexistent"})
    except OSError as exc:
        return {"state": "unavailable", "error_type": type(exc).__name__}
    try:
        exitcode = proc.wait(timeout=timeout)
        return {"state": "exited", "code": exitcode,
                "seconds": round(time.monotonic()-start, 2)}
    except subprocess.TimeoutExpired:
        try:
            os.killpg(proc.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        proc.wait()
        return {"state": "timeout", "seconds": round(time.monotonic()-start, 2)}


def sys_summary(paths):
    calls = Counter()
    observations = dict(custom_img=False, firmware_update=False,
                        libcrypto_open=False, fastboot_path=False,
                        device_path=False, connection_attempt=False,
                        new_exec=False, writable_executable_mapping=False,
                        sigkill_syscall_seen=False, ptrace_syscall_seen=False)
    for file in paths:
        with open(file, "rb") as stream:
            lines = stream.read(LIMIT).decode("utf-8", "replace").splitlines()
        for line in lines:
            match = SYSCALL.search(line)
            if not match:
                continue
            name = match.group(1)
            calls[name] += 1
            lower = line.lower()
            if name in ("open", "openat", "openat2"):
                observations["custom_img"] |= "custom.img" in lower
                observations["firmware_update"] |= "firmware-update" in lower
                observations["libcrypto_open"] |= "libcrypto" in lower
                observations["fastboot_path"] |= "fastboot" in lower
                observations["device_path"] |= '"/dev/' in lower
            observations["connection_attempt"] |= name == "connect"
            observations["new_exec"] |= name in ("execve", "execveat")
            observations["sigkill_syscall_seen"] |= (
                name in ("kill", "tkill", "tgkill") and "sigkill" in lower
            )
            observations["ptrace_syscall_seen"] |= name == "ptrace"
            observations["writable_executable_mapping"] |= (
                name == "mprotect" and "prot_exec" in lower and "prot_write" in lower
            )
    return {"syscall_counts": dict(sorted(calls.items())),
            "observations": observations,
            "trace_file_count": len(paths)}


def crypto_summary(path):
    try:
        with open(path, "rb") as stream:
            raw = stream.read(LIMIT)
    except FileNotFoundError:
        return {"trace_produced": False, "call_counts": {}}
    funcs = Counter(CRYPTO.findall(raw.decode("utf-8", "replace")))
    return {"trace_produced": True, "call_counts": dict(sorted(funcs.items()))}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--installer", type=Path, required=True)
    parser.add_argument("--case", choices=("no-args", "help"), required=True)
    a = parser.parse_args()
    if not a.installer.is_file() or a.installer.stat().st_size < 100_000:
        raise SystemExit("Installer unavailable")
    argv = [str(a.installer)] + (["--help"] if a.case == "help" else [])
    sysroot = "/tmp/syscall"
    libfile = "/tmp/crypto"
    result = {
        "case": a.case,
        "no_network": True,
        "no_rom_image": True,
        "installer_executed_in_isolated_container": True,
        "raw_output_exported": False,
        "untraced_baseline": trace(argv, timeout=5),
        "syscall_tracing": trace([
            "/usr/bin/strace", "-ff", "-qq", "-s", "96",
            "-e", "trace=execve,execveat,open,openat,openat2,connect,ioctl,mprotect,ptrace,clone,clone3,mmap,kill,tkill,tgkill,prctl,seccomp",
            "-o", sysroot, *argv
        ]),
    }
    result.update(sys_summary(glob.glob(sysroot + "*")))
    result["library_tracing"] = trace([
        "/usr/bin/ltrace", "-f", "-s", "32",
        "-e", "EVP_aes_256_cbc+EVP_DecryptInit_ex+EVP_DecryptUpdate+EVP_DecryptFinal_ex+EVP_md5+EVP_sha256+PKCS5_PBKDF2_HMAC",
        "-o", libfile, *argv
    ])
    result["observed_crypto_calls"] = crypto_summary(libfile)
    result["limitations"] = (
        "No observed calls cannot establish non-use. Protected code may require "
        "real ROM/device input and might evade ltrace. No key data was recorded."
    )
    print(json.dumps(result, sort_keys=True))
    for path in [*glob.glob(sysroot + "*"), libfile]:
        try:
            os.unlink(path)
        except OSError:
            pass


if __name__ == "__main__":
    main()
