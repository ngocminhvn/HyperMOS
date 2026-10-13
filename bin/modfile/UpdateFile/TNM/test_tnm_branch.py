#!/usr/bin/env python3
"""Exercise APK metadata selection, checksums and branch integration gates."""
import json
from pathlib import Path
import subprocess
import sys
from tempfile import TemporaryDirectory

root = Path(__file__).resolve().parents[4]
installer = (root / 'bin/modfile/UpdateFile/TNM/update.sh').read_text()
workflow = (root / '.github/workflows/build.yml').read_text()
for path in ('build.sh', 'bin/modfile/UpdateFile/RYUPerfProfile/update.sh',
             'bin/modfile/UpdateFile/TNM/update.sh', '.github/workflows/build.yml'):
    text = (root / path).read_text()
    assert 'test-tnm-ryu-haotian' in text, path
    assert 'main' in text, f'production main gate missing: {path}'
assert 'tnm-thermalctl' in (root / 'bin/modfile/UpdateFile/RYUPerfProfile/update.sh').read_text()
assert 'tnm_test_apk_url' not in workflow
assert 'tnm_test_apk_sha256' not in workflow
assert 'TNM_TEST_APK_URL' not in installer
assert 'TNM_TEST_APK_SHA256' not in installer
assert 'https://ngocminhvn.github.io/app' in installer
assert 'apksigner.jar" verify "$tnm_apk"' in installer
assert "apk.read('assets/tnm-backend/bin/tnmctl')" in installer

code = installer.split('readarray -t tnm_meta', 1)[1].split("<<'PY'\n", 1)[1].split('\nPY\n', 1)[0]
base = 'https://ngocminhvn.github.io/app'
with TemporaryDirectory() as temp:
    metadata = Path(temp) / 'update.json'
    def run(data):
        metadata.write_text(json.dumps(data))
        return subprocess.run([sys.executable, '-c', code, str(metadata), base],
                              capture_output=True, text=True)

    release = {'packageUrl': base + '/TNM.apk.xz',
               'packageSha256': 'b' * 64, 'compression': 'xz'}
    result = run(release)
    assert result.returncode == 0, result.stderr
    assert result.stdout.splitlines() == [base + '/TNM.apk.xz', 'b' * 64, 'xz']
    assert run({'packageUrl': base + '/TNM.apk', 'packageSha256': 'a' * 64,
                'compression': 'none'}).returncode == 0
    assert run({'packageUrl': 'https://other.example/TNM.apk',
                'packageSha256': 'a' * 64}).returncode != 0
    assert run({'packageUrl': base + '/TNM.apk.xz', 'packageSha256': 'bad',
                'compression': 'xz'}).returncode != 0
    assert run({'packageUrl': base + '/TNM.apk.xz', 'packageSha256': 'b' * 64,
                'compression': 'none'}).returncode != 0

print('TNM latest app/main Pages metadata and SHA selection checks PASS')
