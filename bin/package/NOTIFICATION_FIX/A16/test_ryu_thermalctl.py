import os, shutil, subprocess, tempfile, unittest
from pathlib import Path


@unittest.skipUnless(shutil.which('sh'), 'POSIX shell required; exercised on CI')
class ThermalControlTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        root = Path(self.temp.name)
        for name in ['normal', 'per-normal', 'hp-normal', 'cgame']:
            (root / ('thermal-' + name + '.conf')).write_text('profile fixture')
        self.script = Path(__file__).resolve().parents[4] / 'bin/modfile/UpdateFile/RYUPerfProfile/ryu-thermalctl'
        self.env = dict(os.environ, RYU_SETTINGS_BIN=shutil.which('echo'), RYU_PROFILE_ROOT=str(root))

    def call(self, *args):
        return subprocess.run(['sh', str(self.script), *args], env=self.env, capture_output=True, text=True)

    def test_global_profile_sets_observed_keys(self):
        result = self.call('global', 'game')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('put system projectryu_thermal_sconfig 700', result.stdout)
        self.assertIn('put system projectryu_thermal_per_app 0', result.stdout)

    def test_perapp_validates_entire_batch_before_write(self):
        result = self.call('perapp', 'com.game:game', 'com.bad:nolimits')
        self.assertEqual(result.returncode, 2)
        self.assertNotIn('put system', result.stdout)

    def test_perapp_sets_complete_map_before_activation(self):
        result = self.call('perapp', 'com.game:game', 'com.other:normal')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('com.game:700,com.other:0', result.stdout)
        self.assertLess(result.stdout.index('projectryu_thermal_profiles'), result.stdout.index('projectryu_thermal_per_app'))

    def test_missing_profile_refuses_write(self):
        Path(self.temp.name, 'thermal-cgame.conf').unlink()
        result = self.call('global', 'game')
        self.assertEqual(result.returncode, 2)
        self.assertNotIn('put system', result.stdout)
