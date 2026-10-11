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
    assert 'test-tnm-ryu-haotian' in (root / path).read_text(), path
assert 'tnm-thermalctl' in (root / 'bin/modfile/UpdateFile/RYUPerfProfile/update.sh').read_text()
assert 'TNM_TEST_APK_URL: ${{ inputs.tnm_test_apk_url }}' in workflow
assert 'TNM_TEST_APK_SHA256: ${{ inputs.tnm_test_apk_sha256 }}' in workflow
assert 'apksigner.jar" verify "$tnm_apk"' in installer
assert "apk.read('assets/tnm-backend/bin/tnmctl')" in installer

code = installer.split('readarray -t tnm_meta', 1)[1].split("<<'PY'\n", 1)[1].split('\nPY\n', 1)[0]
base = 'https://ngocminhvn.github.io/app'
test_url = 'https://example.org/TNM.apk'
with TemporaryDirectory() as temp:
    metadata = Path(temp) / 'update.json'
    def run(data, url=''):
        metadata.write_text(json.dumps(data))
        return subprocess.run([sys.executable, '-c', code, str(metadata), base, url], capture_output=True, text=True)
    result = run({'packageUrl': test_url, 'packageSha256': 'a' * 64, 'compression': 'none'}, test_url)
    assert result.returncode == 0, result.stderr
    assert result.stdout.splitlines() == [test_url, 'a' * 64, 'none']
    assert run({'packageUrl': test_url, 'packageSha256': 'bad'}, test_url).returncode != 0
    assert run({'packageUrl': test_url, 'packageSha256': 'a' * 64, 'compression': 'xz'}, test_url).returncode != 0
    assert run({'packageUrl': 'https://other.example/TNM.apk', 'sha256': 'a' * 64}, test_url).returncode != 0
    assert run({'packageUrl': test_url, 'sha256': 'a' * 64}).returncode != 0
    assert run({'packageUrl': base + '/TNM.apk.xz', 'packageSha256': 'b' * 64, 'compression': 'xz'}).returncode == 0
print('TNM branch / matching APK selection checks PASS')
