"""Regression checks for the selected Xiaomi.eu Android 16 PowerKeeper route."""
import unittest
from pathlib import Path


REPO = Path(__file__).resolve().parents[6]
A16_DRIVER = REPO / "bin/package/NOTIFICATION_FIX/A16/patch.sh"
BUILD_DRIVER = REPO / "build.sh"


class EuPowerKeeperRoutingTests(unittest.TestCase):
    def test_framework_and_powerkeeper_ports_stay_enabled(self):
        driver = A16_DRIVER.read_text(encoding="utf-8")

        self.assertIn("donor_notification_policy_a16.py", driver)
        self.assertIn("donor_greeze_policy_port_a16.py", driver)
        self.assertIn('bash "$base/EU/PowerKeeper_donor.sh"', driver)

    def test_build_summary_matches_active_runtime_route(self):
        driver = BUILD_DRIVER.read_text(encoding="utf-8")

        self.assertIn(
            "EU PowerKeeper: ZK304 method port + original APK metadata preserved",
            driver,
        )
        self.assertNotIn("ZK304 61-method APK port disabled", driver)


if __name__ == "__main__":
    unittest.main()
