#!/usr/bin/env python3
"""Synthetic tests: never execute or import actual protected installer."""
import json
import tempfile
import unittest
from pathlib import Path

from sandbox_probe import CRYPTO, SYSCALL, crypto_summary, sys_summary
from sandbox_report import render


class SandboxProbeTests(unittest.TestCase):
    def test_syscall_aggregation_redacts_arguments(self):
        with tempfile.TemporaryDirectory() as tmp:
            text = "\n".join([
                'execve("/analysis/installer", ["/analysis/installer"], 0x7f) = 0',
                'openat(AT_FDCWD, "/tmp/firmware-update/custom.img", O_RDONLY) = -1 ENOENT',
                'openat(AT_FDCWD, "/usr/lib/libcrypto.so.3", O_RDONLY) = 3',
                'connect(4, {sa_family=AF_INET, sin_port=htons(443)}, 16) = -1 ENETUNREACH',
                'mprotect(0x1234, 4096, PROT_WRITE|PROT_EXEC) = -1 EPERM',
            ])
            file = Path(tmp) / "strace.33"
            file.write_text(text)
            result = sys_summary([str(file)])
            self.assertEqual(result["syscall_counts"]["openat"], 2)
            self.assertTrue(result["observations"]["custom_img"])
            self.assertTrue(result["observations"]["connection_attempt"])
            self.assertTrue(result["observations"]["writable_executable_mapping"])
            self.assertNotIn("firmware-update/custom.img", json.dumps(result))

    def test_sigkill_target_attribution_uses_tracee_pid_only(self):
        with tempfile.TemporaryDirectory() as tmp:
            self_trace = Path(tmp) / "syscall.1234"
            self_trace.write_text("kill(1234, SIGKILL) = ?\n")
            peer_trace = Path(tmp) / "syscall.5678"
            peer_trace.write_text("kill(1234, SIGKILL) = 0\n")
            observation = sys_summary([str(self_trace), str(peer_trace)])["observations"]
            self.assertTrue(observation["sigkill_target_is_self"])
            self.assertTrue(observation["sigkill_target_is_tracee_peer"])
            self.assertFalse(observation["sigkill_target_other_or_group"])
            self.assertNotIn("1234", json.dumps(observation))

    def test_ltrace_only_function_names(self):
        with tempfile.TemporaryDirectory() as tmp:
            file = Path(tmp) / "libtrace"
            file.write_text(
                "PKCS5_PBKDF2_HMAC(0xdeadbeef, 99, SECRETINPUT) = 1\n"
                "EVP_DecryptInit_ex(0x1010, 0x2020) = 1\n"
            )
            result = crypto_summary(str(file))
            self.assertEqual(result["call_counts"]["PKCS5_PBKDF2_HMAC"], 1)
            self.assertNotIn("SECRETINPUT", json.dumps(result))
            self.assertNotIn("0xdeadbeef", json.dumps(result))

    def test_missing_tracer_is_not_counted_as_success(self):
        r = crypto_summary("/nonexistent/ltrace")
        self.assertFalse(r["trace_produced"])

    def test_summary_never_claims_to_have_a_key(self):
        case = {
            "syscall_tracing": {"state": "exited", "code": 1},
            "library_tracing": {"state": "timeout"},
            "observations": {"custom_img": False},
            "observed_crypto_calls": {"call_counts": {}},
        }
        result = render({"no-args": case, "help": case})
        self.assertIn("does not prove non-use", result)
        self.assertIn("undetermined", result)
        self.assertNotIn("SECRETINPUT", result)


if __name__ == "__main__":
    unittest.main()
