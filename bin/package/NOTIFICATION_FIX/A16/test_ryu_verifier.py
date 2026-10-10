import unittest
from verify_powerkeeper_rom_verifier import check

APK = '''.method public static getMinimumSignatureSchemeVersionForTargetSdk(I)I
    .registers 2
    const/4 v0, 0x0
    return v0
.end method
.method private static verifyV3AndBelowSignatures(Ljava/lang/Object;Ljava/lang/String;IZ)V
    .registers 5
    const p3, 0x0
    invoke-static {p0, p1, p3}, Landroid/util/apk/ApkSignatureVerifier;->verifyV1Signature(Ljava/lang/Object;Ljava/lang/String;Z)Ljava/lang/Object;
    return-object v0
.end method
'''
JAR = '''.method private verifyMessageDigest([B)Z
    .registers 3
    const/4 v0, 0x1
    return v0
.end method
'''


class VerifierTest(unittest.TestCase):
    def test_audited_gates(self): check(APK, JAR)

    def test_scheme_gate_missing(self):
        with self.assertRaises(ValueError): check(APK.replace('const/4 v0, 0x0', 'const/4 v0, 0x2'), JAR)

    def test_fallback_gate_missing(self):
        with self.assertRaises(ValueError): check(APK.replace('const p3, 0x0', 'const p3, 0x1'), JAR)

    def test_digest_gate_missing(self):
        with self.assertRaises(ValueError): check(APK, JAR.replace('const/4 v0, 0x1', 'const/4 v0, 0x0'))


if __name__ == '__main__': unittest.main()
