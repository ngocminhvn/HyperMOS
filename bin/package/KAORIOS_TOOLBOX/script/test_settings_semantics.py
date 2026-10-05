"""Guard mutations and real smali/baksmali round trips for Settings hooks."""
import importlib.util
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[3]


def load(name):
    spec = importlib.util.spec_from_file_location(name, HERE / (name + ".py"))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


caller = load("patch-settings-caller")
resolver = load("patch-settings-contentresolver")
TEMPLATE = (HERE.parent / "framework/HyperMOSSettingsSpoof.smali").read_text()


def resolver_fixture(directive=".locals 2"):
    return f""".class public Landroid/content/ContentResolver;
.super Ljava/lang/Object;
.method public {resolver.METHOD_ANCHOR}
    {directive}
    const/4 v0, 0x0
    return-object v0
.end method
"""


def cache_fixture():
    return f""".class public final {caller.dev.CLASS_DESC}
.super Ljava/lang/Object;
.field private final mCallGetCommand:Ljava/lang/String;
.method public {caller.dev.METHOD_ANCHOR}
    .locals 4
    const/4 v0, 0x0
    return-object v0
.end method
"""


class SemanticTests(unittest.TestCase):
    def verify_bridge(self, text):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            path = root / "android/security/kaorios/HyperMOSSettingsSpoof.smali"
            path.parent.mkdir(parents=True)
            path.write_text(text)
            caller.verify_bridge(root)

    def test_security_mutations_fail(self):
        changes = [
            ("if-lt v2, v3, :stock", "if-gt v2, v3, :stock"),
            ("if-gt v2, v3, :stock", "if-lt v2, v3, :stock"),
            ("if-ne p2, v2, :stock", "if-eq p2, v2, :stock"),
            ("if-ne v0, v1, :stock", "if-eq v0, v1, :stock"),
            ("if-nez v0, :stock", "if-eqz v0, :stock"),
            ("if-ne v1, v0, :stock", "if-eq v1, v0, :stock"),
            ('"settings"', '"other"'),
            ('"_user"', '"wrong_user"'),
            ("0x186a0", "0x186a1"),
            ("0x2710", "0x270f"),
            ("0x4e1f", "0x4e20"),
            ("if-lt v2, v3, :stock", "if-lt v2, v3, :policy_start"),
            ("ThreadLocal;->set(Ljava/lang/Object;)V", "ThreadLocal;->get()Ljava/lang/Object;"),
            ("invoke-static {p0, p1}", "invoke-static {p1, p0}"),
            (".catchall {:policy_start .. :policy_end} :policy_error", ""),
            (".catchall {:try_start .. :try_end} :unavailable", ""),
            (".catchall {:policy_start .. :policy_end} :policy_error",
             ".catchall {:policy_end .. :policy_error} :policy_error"),
            (".catchall {:policy_start .. :policy_end} :policy_error",
             ".catchall {:policy_start .. :policy_end} :unavailable"),
            (".catchall {:policy_start .. :policy_end} :policy_error",
             ".catchall {:policy_start .. :missing} :policy_error"),
            ("invoke-virtual {v3}, Ljava/lang/ThreadLocal;->remove()V\n    return-object v0",
             "return-object v0"),
            ("invoke-virtual {v3}, Ljava/lang/ThreadLocal;->remove()V\n    goto :stock",
             "goto :stock"),
            (":stock\n    const/4 v0, 0x0", ":stock\n    const/4 v0, 0x1"),
            ("goto :stock", "goto :policy_start"),
            ("sput-object v0", "sput-object p0"),
        ]
        for old, new in changes:
            with self.subTest(mutation=old):
                self.assertIn(old, TEMPLATE)
                with self.assertRaises(ValueError):
                    self.verify_bridge(TEMPLATE.replace(old, new))
        policy = "    invoke-static {p0, p1}, Landroid/security/kaorios/KaoriosHook;->filterSettingsCall(Ljava/lang/String;Ljava/lang/String;)Landroid/os/Bundle;\n"
        with self.assertRaises(ValueError):
            self.verify_bridge(TEMPLATE.replace(policy, policy + policy))

    def test_aliases_labels_encodings_and_catch_directive_order(self):
        text = TEMPLATE
        for descriptor, params in [("<clinit>()V", 0),
                ("getOverrideForCall(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Landroid/os/Bundle;)Landroid/os/Bundle;", 4),
                ("getOverride(Ljava/lang/String;Ljava/lang/String;I)Landroid/os/Bundle;", 3)]:
            body = caller.semantics.method(text, descriptor)
            base = int(re.search(r"\.locals (\d+)", body)[1])
            changed = body.replace(f".locals {base}", f".registers {base + params}")
            changed = re.sub(r"\bp(\d+)\b", lambda m: f"v{base + int(m[1])}", changed)
            text = text.replace(body, changed)
        text = re.sub(r"(?<![\w;]):(\w+)", r":renamed_\1", text)
        text = text.replace("const/4", "const/16").replace("const/16", "const")
        text = text.replace("const-string ", "const-string/jumbo ").replace("goto ", "goto/32 ")
        text = text.replace("move-result-object", ".line 42\n    move-result-object")
        # Directives can move without changing the protected instruction ranges.
        catches = re.findall(r"(?m)^    \.catchall.*$", text)
        override = caller.semantics.method(text, "getOverride(Ljava/lang/String;Ljava/lang/String;I)Landroid/os/Bundle;")
        changed = re.sub(r"(?m)^    \.catchall.*\n", "", override)
        changed = changed.replace(".end method", "\n".join(reversed(catches[1:])) + "\n.end method")
        self.verify_bridge(text.replace(override, changed))

    def test_resolver_arguments_and_branches(self):
        for directive, base in [(".locals 20", 20), (".registers 25", 20)]:
            patched, _ = resolver.patch(resolver_fixture(directive))
            resolver.verify(patched, roundtrip=True)
            aliased = patched.replace("{p1 .. p4}", "{v21 .. v24}")
            resolver.verify(aliased, roundtrip=True)
            for changed in [patched.replace("{p1 .. p4}", "{p1 .. p3}"),
                            patched.replace("if-eqz v0", "if-nez v0"),
                            patched.replace("if-eqz v0, " + resolver.LABEL, "if-eqz v0, :missing"),
                            patched.replace("move-result-object v0", "move-result-object p1")]:
                with self.assertRaises(ValueError):
                    resolver.verify(changed, roundtrip=True)
        patched, _ = resolver.patch(resolver_fixture())
        normal = patched.replace("invoke-static/range {p1 .. p4}", "invoke-static {p1, p2, p3, p4}")
        resolver.verify(normal, roundtrip=True)

    def test_caller_equivalent_invokes_moves_and_colocated_labels(self):
        text, _ = caller.patch(cache_fixture())
        text = text.replace("move-object/from16", "move-object/16").replace("move/from16", "move/16")
        text = text.replace("invoke-static/range {v0 .. v2}", "invoke-static {v0, v1, v2}")
        text = text.replace("invoke-virtual {v0, v1}", "invoke-virtual/range {v0 .. v1}")
        text = text.replace("    " + caller.LABEL + "\n", "    " + caller.LABEL + "\n    :stock_try_start\n")
        caller.verify(text, roundtrip=True)

    @unittest.skipUnless(shutil.which("java"), "requires Java")
    def test_real_dex_roundtrip(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            src, out, dex = root / "src", root / "out", root / "classes.dex"
            cache, _ = caller.dev.patch(cache_fixture())
            cache, _ = caller.patch(cache)
            content, _ = resolver.patch(resolver_fixture())
            for relative, text in [("android/security/kaorios/HyperMOSSettingsSpoof.smali", TEMPLATE),
                    (caller.TARGET, cache), (resolver.TARGET_REL, content)]:
                path = src / relative
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(text)
            for smali, baksmali in [("smaliv2.jar", "baksmaliv2.jar"), ("smali.jar", "baksmali.jar")]:
                with self.subTest(assembler=smali):
                    subprocess.run(["java", "-jar", str(REPO / "bin/apktool" / smali), "a", str(src), "-o", str(dex)], check=True, capture_output=True)
                    if out.exists():
                        shutil.rmtree(out)
                    subprocess.run(["java", "-jar", str(REPO / "bin/apktool" / baksmali), "d", str(dex), "-o", str(out)], check=True, capture_output=True)
                    caller.verify_bridge(out)
                    caller.verify((out / caller.TARGET).read_text(), roundtrip=True)
                    resolver.verify((out / resolver.TARGET_REL).read_text(), roundtrip=True)


if __name__ == "__main__":
    unittest.main()
