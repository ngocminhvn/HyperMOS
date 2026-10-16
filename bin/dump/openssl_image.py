#!/usr/bin/env python3
"""Decrypt an OpenSSL Salted__ image only with an explicitly supplied passphrase.

No guessing or password search. Candidate KDF profiles are fixed and are only
accepted when the decrypted bytes contain a verifiable Android super signature.
"""
import os
import shutil
import subprocess
from pathlib import Path

LP_GEOMETRY = b"\x67\x44\x6c\x61"
SPARSE_MAGIC = b"\x3a\xff\x26\xed"
PROFILES = (
    ("aes256-pbkdf2", ("-aes-256-cbc", "-pbkdf2")),
    ("aes256-sha256-legacy", ("-aes-256-cbc", "-md", "sha256")),
    ("aes256-md5-legacy", ("-aes-256-cbc", "-md", "md5")),
)


def looks_like_super(data):
    return data[:4] == SPARSE_MAGIC or data[4096:4100] == LP_GEOMETRY


def probe_profile(ciphertext, env=None):
    """Choose a known profile based on decrypted Android LP magic, not CBC padding.

    Input should contain the OpenSSL 16-byte header plus a multiple of 16
    encrypted bytes. -nopad allows decrypting a prefix without the final block.
    """
    if not ciphertext.startswith(b"Salted__"):
        return None
    env = os.environ if env is None else env
    if not env.get("DUMP_IMAGE_PASSWORD"):
        return None
    for profile_name, opts in PROFILES:
        cmd = [
            "openssl", "enc", "-d", *opts,
            "-nopad", "-pass", "env:DUMP_IMAGE_PASSWORD",
        ]
        try:
            response = subprocess.run(
                cmd, input=ciphertext, capture_output=True,
                env=env, timeout=20, check=False
            )
        except (OSError, subprocess.TimeoutExpired):
            continue
        if response.returncode == 0 and looks_like_super(response.stdout):
            return profile_name, opts
    return None


def decrypt_member(archive, member_name, output, opts, env=None):
    """Stream the full member to openssl; passphrase is never in argv/logs."""
    env = os.environ if env is None else env
    output = Path(output)
    output.parent.mkdir(parents=True, exist_ok=True)
    cmd = ["openssl", "enc", "-d", *opts, "-pass", "env:DUMP_IMAGE_PASSWORD"]
    try:
        with archive.open(member_name) as source, output.open("wb") as sink:
            process = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=sink,
                                       stderr=subprocess.PIPE, env=env)
            try:
                shutil.copyfileobj(source, process.stdin, 1024 * 1024)
            except Exception:
                process.kill()
                raise
            finally:
                process.stdin.close()
            _stdout, stderr = process.communicate()
            if process.returncode != 0:
                raise RuntimeError("OpenSSL could not decrypt image; wrong password or cipher")
        return output
    except BaseException:
        output.unlink(missing_ok=True)
        raise
