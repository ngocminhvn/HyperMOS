#!/usr/bin/env python3
import importlib.util
import subprocess
import tempfile
import unittest
from pathlib import Path


MODULE = Path(__file__).resolve().parents[1] / "mod" / "corepatch.py"
SPEC = importlib.util.spec_from_file_location("kaorios_corepatch", MODULE)
corepatch = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(corepatch)


class CorePatchTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        (self.root / "classes.dex.out").mkdir()

    def tearDown(self):
        self.temp.cleanup()

    def smali(self, relative, body):
        path = self.root / "classes.dex.out" / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        descriptor = "L" + relative.removesuffix(".smali") + ";"
        header = f".class public {descriptor}\n.super Ljava/lang/Object;\n\n"
        path.write_text(header + body.strip() + "\n", encoding="utf-8")
        return path

    def assemble(self, root=None):
        root = root or self.root
        jar = Path(__file__).resolve().parents[3] / "apktool" / "smaliv2.jar"
        output = root / "classes.dex"
        subprocess.run(
            ["java", "-jar", str(jar), "a", "--api", "36", str(root / "classes.dex.out"), "-o", str(output)],
            check=True, capture_output=True, text=True,
        )
        self.assertGreater(output.stat().st_size, 0)

    def test_full_framework_recipe_and_idempotence(self):
        self.smali("android/content/pm/PackageParser.smali", r'''
.method public parse(Ljava/lang/Object;Ljava/lang/Object;I)V
    .locals 8
    const-string v0, "<manifest> specifies bad sharedUserId name \""
    if-nez v7, :ok
    invoke-static {v2, v0, p3}, Landroid/util/apk/ApkSignatureVerifier;->unsafeGetCertsWithoutVerification(Landroid/content/pm/parsing/result/ParseInput;Ljava/lang/String;I)Landroid/content/pm/parsing/result/ParseResult;
    :ok
    return-void
.end method''')
        self.smali("android/content/pm/PackageParser$PackageParserException.smali", r'''
.method public constructor <init>(I)V
    .locals 0
    iput p1, p0, Landroid/content/pm/PackageParser$PackageParserException;->error:I
    return-void
.end method''')
        self.smali("android/content/pm/PackageParser$SigningDetails.smali", r'''
.method public checkCapability(I)Z
    .locals 1
    const/4 v0, 0x0
    return v0
.end method''')
        self.smali("android/content/pm/SigningDetails.smali", r'''
.method public checkCapability(I)Z
    .locals 1
    const/4 v0, 0x0
    return v0
.end method
.method public checkCapabilityRecover(I)Z
    .locals 1
    const/4 v0, 0x0
    return v0
.end method
.method public hasAncestorOrSelf()Z
    .locals 1
    const/4 v0, 0x0
    return v0
.end method''')
        digest = r'''
.method public digest([B[B)Z
    .locals 12
    invoke-static {v9, v3}, Ljava/security/MessageDigest;->isEqual([B[B)Z
    move-result v11
    return v11
.end method'''
        self.smali("android/util/apk/ApkSignatureSchemeV2Verifier.smali", digest)
        self.smali("android/util/apk/ApkSignatureSchemeV3Verifier.smali", digest)
        self.smali("android/util/apk/ApkSigningBlockUtils.smali", digest)
        self.smali("android/util/apk/ApkSignatureVerifier.smali", r'''
.method public static getMinimumSignatureSchemeVersionForTargetSdk(I)I
    .locals 1
    const/4 v0, 0x3
    return v0
.end method
.method public verify(Landroid/content/pm/parsing/result/ParseInput;Ljava/lang/String;Z)V
    .locals 1
    invoke-static {p0, p1, p3}, Landroid/util/apk/ApkSignatureVerifier;->verifyV1Signature(Landroid/content/pm/parsing/result/ParseInput;Ljava/lang/String;Z)Landroid/content/pm/parsing/result/ParseResult;
    return-void
.end method''')
        self.smali("android/util/jar/StrictJarVerifier.smali", r'''
.method private verifyMessageDigest([B[B)Z
    .locals 1
    const/4 v0, 0x0
    return v0
.end method''')
        self.smali("android/util/jar/StrictJarFile.smali", r'''
.method public find()V
    .locals 7
    invoke-virtual {p0, v5}, Landroid/util/jar/StrictJarFile;->findEntry(Ljava/lang/String;)Ljava/util/zip/ZipEntry;
    move-result-object v6
    if-eqz v6, :missing
    :missing
    return-void
.end method''')
        self.smali("com/android/internal/pm/pkg/parsing/ParsingPackageUtils.smali", r'''
.method public parse()V
    .locals 5
    const-string v3, "<manifest> specifies bad sharedUserId name \""
    if-eqz v4, :bad
    :bad
    return-void
.end method''')

        applied = corepatch.apply_framework(self.root)
        self.assertGreater(sum(applied.values()), 0)
        verified = corepatch.verify_framework(self.root)
        self.assertGreater(sum(verified.values()), 0)
        second = corepatch.apply_framework(self.root)
        self.assertEqual(sum(value for key, value in second.items() if key.endswith(".changed")), 0)
        self.assemble()

        parser = (self.root / "classes.dex.out/android/content/pm/PackageParser.smali").read_text()
        self.assertIn("const/16 p3, 0x1", parser)
        self.assertIn("const/16 v7, 0x1", parser)

    def test_services_and_miui_recipes(self):
        self.smali("com/android/server/pm/PackageManagerServiceUtils.smali", r'''
.method public static checkDowngrade(I)V
    .locals 0
    return-void
.end method
.method public static verifySignatures(I)Z
    .locals 1
    const/4 v0, 0x1
    return v0
.end method
.method public static compareSignatures(I)I
    .locals 1
    const/4 v0, 0x1
    return v0
.end method
.method public static matchSignaturesCompat(I)Z
    .locals 1
    const/4 v0, 0x0
    return v0
.end method''')
        self.smali("com/android/server/pm/KeySetManagerService.smali", r'''
.method public shouldCheckUpgradeKeySetLocked()Z
    .locals 1
    const/4 v0, 0x1
    return v0
.end method''')
        self.smali("com/android/server/pm/InstallPackageHelper.smali", r'''
.method public reconcile(Lcom/android/server/pm/pkg/AndroidPackage;)V
    .locals 4
    invoke-interface {p1}, Lcom/android/server/pm/pkg/AndroidPackage;->isLeavingSharedUser()Z
    move-result v3
    if-eqz v3, :stock
    :stock
    return-void
.end method''')
        self.smali("com/android/server/pm/ReconcilePackageUtils.smali", r'''
.method static constructor <clinit>()V
    .locals 1
    const/4 v0, 0x0
    sput-boolean v0, Lfixture;->FLAG:Z
    return-void
.end method''')

        applied = corepatch.apply_services(self.root)
        self.assertGreater(sum(applied.values()), 0)
        corepatch.verify_services(self.root)
        second = corepatch.apply_services(self.root)
        self.assertEqual(sum(value for key, value in second.items() if key.endswith(".changed")), 0)
        self.assemble()

        miui_root = self.root / "miui"
        (miui_root / "classes.dex.out").mkdir(parents=True)
        old_root = self.root
        self.root = miui_root
        self.smali("com/miui/server/pm/Updater.smali", r'''
.method public verifyIsolationViolation()V
    .locals 1
    const/4 v0, 0x1
    return-void
.end method
.method public canBeUpdate()V
    .locals 1
    const/4 v0, 0x1
    return-void
.end method''')
        self.root = old_root
        corepatch.apply_miui_services(miui_root)
        verified = corepatch.verify_miui_services(miui_root)
        self.assertEqual(verified["miui.update"], 2)
        self.assemble(miui_root)

    def test_duplicate_class_owner_fails_closed(self):
        self.smali("android/content/pm/SigningDetails.smali", r'''
.method public checkCapability(I)Z
    .locals 1
    const/4 v0, 0x0
    return v0
.end method''')
        duplicate = self.root / "classes2.dex.out/android/content/pm/SigningDetails.smali"
        duplicate.parent.mkdir(parents=True)
        duplicate.write_text(
            ".class public Landroid/content/pm/SigningDetails;\n.super Ljava/lang/Object;\n",
            encoding="utf-8",
        )
        with self.assertRaises(corepatch.CorePatchError):
            corepatch.apply_framework(self.root)


if __name__ == "__main__":
    unittest.main()
