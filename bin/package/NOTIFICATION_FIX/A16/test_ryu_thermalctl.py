import os, shutil, subprocess, tempfile, time, unittest
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
        self.store = root
        self.original = {
            'projectryu_thermal_profiles': 'com.old:700',
            'projectryu_thermal_sconfig': '50',
            'projectryu_thermal_per_app': '1',
        }
        for key, value in self.original.items():
            (root / key).write_text(value)
        settings = root / 'settings'
        settings.write_text("""#!/bin/sh
shift 2
verb="$1"; key="$3"; value="${4:-}"
case "$verb" in
get) cat "$STORE/$key" 2>/dev/null || echo null ;;
put)
    printf 'put system %s %s\\n' "$key" "$value"
    if [ -f "$STORE/fail" ] && [ "$key" = "${FAIL_AT:-}" ]; then
        rm "$STORE/fail"; exit 4
    fi
    if [ -f "$STORE/ignore" ] && [ "$key" = "${IGNORE_AT:-}" ]; then
        rm "$STORE/ignore"; exit 0
    fi
    if [ "$key" = "${PAUSE_AT:-}" ]; then
        touch "$STORE/paused"
        while [ ! -f "$STORE/resume" ]; do sleep 0.05; done
    fi
    printf '%s' "$value" > "$STORE/$key"
    ;;
delete) rm -f "$STORE/$key" ;;
*) exit 2 ;;
esac
""", newline='\n')
        settings.chmod(0o755)
        self.env = dict(os.environ, RYU_SETTINGS_BIN=settings.as_posix(),
                        RYU_PROFILE_ROOT=root.as_posix(), STORE=root.as_posix(),
                        RYU_STATE_ROOT=(root / 'state').as_posix(), RYU_BOOT_ID='fixture')

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
        self.assertLess(result.stdout.index('projectryu_thermal_profiles'), result.stdout.rindex('projectryu_thermal_per_app'))

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

    def assert_original_restored(self):
        for key, value in self.original.items():
            self.assertEqual((self.store / key).read_text(), value)
        self.assertFalse((self.store / 'state/thermal-fixture.lock').exists())

    def test_failure_after_partial_write_restores_all_settings(self):
        self.env['FAIL_AT'] = 'projectryu_thermal_sconfig'
        (self.store / 'fail').touch()
        result = self.call('perapp', 'com.new:game')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('previous Settings restored', result.stderr)
        self.assert_original_restored()

    def test_successful_but_ignored_write_rolls_back(self):
        self.env['IGNORE_AT'] = 'projectryu_thermal_profiles'
        (self.store / 'ignore').touch()
        result = self.call('perapp', 'com.new:game')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Setting not confirmed', result.stderr)
        self.assert_original_restored()

    def test_global_failure_restores_active_perapp_mode(self):
        self.env['FAIL_AT'] = 'projectryu_thermal_sconfig'
        (self.store / 'fail').touch()
        result = self.call('global', 'game')
        self.assertNotEqual(result.returncode, 0)
        self.assert_original_restored()

    def test_invalid_or_duplicate_batch_does_not_write(self):
        for entries in [('com.game:game', 'com.game:normal'), ('invalid:game',),
                        tuple(f'com.app{i}:normal' for i in range(33))]:
            result = self.call('perapp', *entries)
            self.assertNotEqual(result.returncode, 0)
            self.assertNotIn('put system', result.stdout)
            self.assert_original_restored()

    def test_separate_clients_cannot_interleave(self):
        env = {**self.env, 'PAUSE_AT': 'projectryu_thermal_profiles'}
        first = subprocess.Popen(['sh', str(self.script), 'perapp', 'com.first:game'],
                                 env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        try:
            deadline = time.monotonic() + 5
            while not (self.store / 'paused').exists() and time.monotonic() < deadline:
                time.sleep(0.02)
            self.assertTrue((self.store / 'paused').exists())
            blocked = self.call('global', 'hp')
            self.assertEqual(blocked.returncode, 11, blocked.stderr)
            self.assertNotIn('put system', blocked.stdout)
            self.assertEqual(self.call('profiles').returncode, 0)
        finally:
            (self.store / 'resume').touch()
            out, err = first.communicate(timeout=5)
        self.assertEqual(first.returncode, 0, err)
        self.assertEqual((self.store / 'projectryu_thermal_profiles').read_text(), 'com.first:700')
        self.assertEqual((self.store / 'projectryu_thermal_per_app').read_text(), '1')
        self.assertEqual((self.store / 'projectryu_thermal_sconfig').read_text(), '0')
        self.assertFalse((self.store / 'state/thermal-fixture.lock').exists())

    def test_missing_original_settings_remain_missing_after_failure(self):
        for key in self.original:
            (self.store / key).unlink()
        self.env['FAIL_AT'] = 'projectryu_thermal_sconfig'
        (self.store / 'fail').touch()
        result = self.call('perapp', 'com.new:game')
        self.assertNotEqual(result.returncode, 0)
        for key in self.original:
            self.assertFalse((self.store / key).exists(), key)
        self.assertFalse((self.store / 'state/thermal-fixture.lock').exists())

    def test_stale_owner_is_not_reaped_by_racing_clients(self):
        lock = self.store / 'state/thermal-fixture.lock'
        lock.mkdir(parents=True)
        (lock / 'pid').write_text('99999999')
        result = self.call('global', 'game')
        self.assertEqual(result.returncode, 11)
        self.assertNotIn('put system', result.stdout)
        self.assertTrue(lock.exists())
        # A different kernel boot ID naturally uses a new lock namespace.
        self.env['RYU_BOOT_ID'] = 'next-boot'
        self.assertEqual(self.call('global', 'game').returncode, 0)
        self.assertFalse((self.store / 'state/thermal-next-boot.lock').exists())
