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

    def test_extended_profiles_and_discovery(self):
        mapping = {'normal': (0, 'normal'), 'performance': (50, 'per-normal'), 'hp': (500, 'hp-normal'), 'game': (700, 'cgame'), 'huanji': (1, 'huanji'), 'phone': (5, 'phone'), 'class0': (7, 'class0'), 'arvr': (9, 'arvr'), 'navigation': (10, 'navigation'), 'video': (11, 'video'), 'videochat': (14, 'videochat'), 'camera': (15, 'camera'), '4k': (16, '4k'), 'mgame': (19, 'mgame'), 'per-class0': (57, 'per-class0'), 'per-video': (61, 'per-video'), 'hp-mgame': (501, 'hp-mgame'), 'cclassvideo': (701, 'cclassvideo')}
        for name, (identifier, filename) in mapping.items():
            Path(self.temp.name, 'thermal-' + filename + '.conf').write_text('fixture')
        listing = self.call('profiles')
        self.assertEqual(listing.returncode, 0, listing.stderr)
        self.assertNotIn('put system', listing.stdout)
        self.assertEqual(set(listing.stdout.splitlines()), {
            f'{key}:{identifier}:{filename}' for key, (identifier, filename) in mapping.items()
        })
        for name, (identifier, filename) in mapping.items():
            result = self.call('global', name)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn(f'put system projectryu_thermal_sconfig {identifier}', result.stdout)
        batch = self.call('perapp', 'com.camera:camera', 'com.game:hp-mgame', 'com.nav:navigation')
        self.assertEqual(batch.returncode, 0, batch.stderr)
        self.assertIn('com.camera:15,com.game:501,com.nav:10', batch.stdout)
        Path(self.temp.name, 'thermal-hp-mgame.conf').unlink()
        self.assertNotIn('hp-mgame:', self.call('profiles').stdout)
        failed = self.call('perapp', 'com.camera:camera', 'com.game:hp-mgame')
        self.assertNotEqual(failed.returncode, 0)
        self.assertNotIn('put system', failed.stdout)

    def test_protected_modes_are_not_manual_profiles(self):
        for name in ('nolimits', 'charge', 'chg-only', 'tgame'):
            result = self.call('global', name)
            self.assertNotEqual(result.returncode, 0)
            self.assertNotIn('put system', result.stdout)
