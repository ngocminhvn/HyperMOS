import hashlib
import tempfile
import unittest
import zipfile
from pathlib import Path
from unittest.mock import patch
import preserve_powerkeeper_identity as identity


class IdentityTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.cert = b'\x30\x03\x02\x01\x07'
        self.reference = self.root / 'reference.apk'
        self.base = self.root / 'stock.apk'
        self.patched = self.root / 'compiled.apk'
        self.output = self.root / 'final.apk'
        self.meta = {'META-INF/CERT.RSA': b'\x30\x05' + self.cert,
                     'META-INF/CERT.SF': b'reference-sf', 'META-INF/MANIFEST.MF': b'reference-manifest'}
        self.write(self.reference, self.meta | {'classes.dex': b'original'})
        self.write(self.base, self.meta | {'AndroidManifest.xml': b'stock-manifest',
                              'resources.arsc': b'stock-resources', 'classes.dex': b'stock-dex'})
        self.write(self.patched, {'AndroidManifest.xml': b'changed-manifest',
                                 'resources.arsc': b'changed-resources', 'classes.dex': b'patched-dex',
                                 'META-INF/CERT.RSA': b'wrong-signer'})
        self.reference = self.base  # Stock, not a separate APK donor.
        self.cert_patch = patch.object(identity, 'XIAOMI', hashlib.sha256(self.cert).hexdigest())
        self.cert_patch.start(); self.addCleanup(self.cert_patch.stop)

    def write(self, path, members):
        with zipfile.ZipFile(path, 'w') as z:
            for name, data in members.items(): z.writestr(name, data)

    def build(self, cert=None):
        with patch.object(identity.subprocess, 'run') as run:
            run.return_value.stdout = 'Signer #1 certificate SHA-256 digest: ' + (cert or identity.XIAOMI)
            return identity.rebuild(self.base, self.patched, self.reference,
                                    self.output, Path('apksigner.jar'), 'java')

    def test_preserves_stock_non_dex_and_reference_identity(self):
        report = self.build()
        with zipfile.ZipFile(self.output) as z:
            self.assertEqual(z.read('classes.dex'), b'patched-dex')
            self.assertEqual(z.read('AndroidManifest.xml'), b'stock-manifest')
            self.assertEqual(z.read('resources.arsc'), b'stock-resources')
            for n, data in self.meta.items(): self.assertEqual(z.read(n), data)
        self.assertFalse(report['cryptographic_signature_valid'])

    def test_rejects_testkey_stock(self):
        with self.assertRaises(ValueError): self.build('a40da80a')
        self.assertFalse(self.output.exists())

    def test_preserves_stock_offsets_when_metadata_removed_and_dex_grows(self):
        self.write(self.base, self.meta | {'META-INF/OLD.SF': b'old-stock-signature',
                              'classes.dex': b'stock-dex',
                              'assets/policy': b'unchanged-policy',
                              'AndroidManifest.xml': b'stock-manifest'})
        self.write(self.patched, {'classes.dex': b'larger-patched-dex' * 20})
        before = self.base.read_bytes()
        self.build()
        self.assertEqual(self.base.read_bytes(), before)
        with zipfile.ZipFile(self.base) as original, zipfile.ZipFile(self.output) as final:
            self.assertEqual(original.read('assets/policy'), final.read('assets/policy'))
            self.assertEqual(original.read('AndroidManifest.xml'), final.read('AndroidManifest.xml'))
            self.assertEqual(final.read('classes.dex'), b'larger-patched-dex' * 20)

    def test_rejects_reference_tampering(self):
        with zipfile.ZipFile(self.reference, 'a') as z:
            z.writestr('META-INF/CERT.RSA', b'tamper')
        with self.assertRaisesRegex(ValueError, 'Duplicate reference metadata'): self.build()
        self.assertFalse(self.output.exists())

    def test_rejects_changed_final_certificate(self):
        self.build()
        with zipfile.ZipFile(self.output) as z: members = {n:z.read(n) for n in z.namelist()}
        members['META-INF/CERT.RSA'] = b'wrong'
        self.write(self.output, members)
        with self.assertRaisesRegex(ValueError, 'metadata'): identity.verify(self.output, self.reference)

    def test_rejects_extra_dex(self):
        with zipfile.ZipFile(self.patched, 'a') as z: z.writestr('classes2.dex', b'unexpected')
        with self.assertRaisesRegex(ValueError, 'DEX set'): self.build()

    def test_truncated_der_rejected(self):
        with self.assertRaises(ValueError): identity.cert_present(b'\x30\x82\x01')


if __name__ == '__main__': unittest.main()
