#!/usr/bin/env python3
"""Mock sysfs smoke tests for the root-only CPU 80..100% controller."""
from pathlib import Path
import subprocess
import tempfile

S = Path(__file__).with_name("tnm-cpuctl").read_text(encoding="utf-8")


def main():
    with tempfile.TemporaryDirectory(prefix="tnm-cpu-test-") as tmp:
        base = Path(tmp)
        freqroot = base / "cpufreq"
        freqroot.mkdir()
        for n, hw, frequencies in (
            (0, 3000000, [1000000, 2000000, 2400000, 2700000, 3000000]),
            (6, 3600000, [1000000, 2000000, 2800000, 3200000, 3600000]),
        ):
            p = freqroot / f"policy{n}"
            p.mkdir()
            for leaf, val in {
                "scaling_max_freq": hw,
                "scaling_min_freq": 800000,
                "cpuinfo_max_freq": hw,
                "scaling_available_frequencies": " ".join(map(str, frequencies)),
            }.items():
                (p / leaf).write_text(str(val) + "\n")
        boot = base / "boot_id"
        boot.write_text("12345678-abcd-1234-abcd-12345678abcd\n")
        sandbox = S
        replacements = [
            ("/sys/devices/system/cpu/cpufreq", str(freqroot)),
            ("/proc/sys/kernel/random/boot_id", str(boot)),
            ("/data/adb/tnm/state/cpu-percent", str(base / "state/cpu-percent")),
            ("/data/adb/tnm/state", str(base / "state")),
            ("/data/adb/tnm", str(base)),
            ("id -u", "printf 0"),
        ]
        for a, b in replacements:
            assert a in sandbox, f"source layout drifted: {a}"
            sandbox = sandbox.replace(a, b)
        helper = base / "tnm-cpuctl"
        helper.write_text(sandbox)
        subprocess.run(["sh", "-n", str(helper)], check=True)

        def run(*args, ok=True):
            result = subprocess.run(
                ["sh", str(helper), *map(str, args)],
                capture_output=True, text=True, timeout=5)
            if ok:
                assert result.returncode == 0, result.stderr
            else:
                assert result.returncode != 0, args
            return result.stdout

        def cap(n):
            return int((freqroot / f"policy{n}/scaling_max_freq").read_text())

        assert "cpu_percent_requested=100" in run("status")
        run("apply", 80)
        assert (cap(0), cap(6)) == (2400000, 2800000)
        assert "cpu_percent_requested=80" in run("status")
        run("apply", 90)
        assert (cap(0), cap(6)) == (2700000, 3200000)
        run("apply", 100)
        assert (cap(0), cap(6)) == (3000000, 3600000)
        for bad in ("79", "101", "-1", "080", "abc", "80;id"):
            run("apply", bad, ok=False)
        # External thermal cap cannot be raised by our next request.
        run("apply", 80)
        (freqroot / "policy0/scaling_max_freq").write_text("2000000\n")
        run("apply", 100)
        assert cap(0) == 2000000
        assert cap(6) == 3600000
        print("CPU percent controller PASS: 80, 90, 100, bounds, external thermal cap")


if __name__ == "__main__":
    main()
