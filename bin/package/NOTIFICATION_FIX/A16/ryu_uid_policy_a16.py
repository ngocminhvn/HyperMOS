#!/usr/bin/env python3
"""Port the missing RYU UID-policy declarations and Bundle helper into Xiaomi PowerKeeper.

The RYU KillProcessController call path is already present in HyperMOS test
builds. The original APK is supplied by the builder, SHA-256 pinned there.
No APK signing or global policy changes are made by this script.
"""
import argparse
import json
import re
from pathlib import Path

METHOD = "getUidPolicy(I)Landroid/os/Bundle;"
INTERFACE = "PowerKeeperInterface$l.smali"
IMPLEMENTATION = "AppRuleChecker.smali"
CONTROLLER = "KillProcessController.smali"
HELPER = "AppRuleChecker$j.smali"


def one(root: Path, name: str) -> Path:
    found = list(root.rglob(name))
    if len(found) != 1:
        raise ValueError(f"{name}: expected exactly 1 class, found {len(found)}")
    return found[0]


def method(text: str, signature: str) -> str | None:
    pattern = re.compile(
        r"(?ms)^\.method[^\n]*\s" + re.escape(signature)
        + r"\s*$.*?^\.end method\s*$"
    )
    matches = list(pattern.finditer(text))
    if len(matches) > 1:
        raise ValueError(f"{signature}: duplicate method definition")
    return matches[0].group() if matches else None


def port(ryu: Path, stock: Path, name: str, expected_class: str) -> bool:
    source = one(ryu, name)
    target = one(stock, name)
    original = source.read_text(encoding="utf-8")
    current = target.read_text(encoding="utf-8")
    descriptor = "Lcom/miui/powerkeeper/" + expected_class + ";"
    for label, value in (("RYU", original), ("target", current)):
        if not re.search(r"(?m)^\.class[^\n]*\s" + re.escape(descriptor) + r"\s*$", value):
            raise ValueError(f"{label} {name}: unexpected class descriptor")
    required_signature = "d()Landroid/os/Bundle;" if name == HELPER else METHOD
    added_method = method(original, required_signature)
    if not added_method:
        raise ValueError(f"RYU {name} is missing {required_signature}")
    if "Lcom/projectryu/" in added_method:
        raise ValueError("RYU UID policy method requires external ProjectRYU dependency")
    existing = method(current, required_signature)
    if existing:
        if re.sub(r"\s+", "", existing) != re.sub(r"\s+", "", added_method):
            raise ValueError(f"{name}: target has a different method; refusing overwrite")
        return False
    if name == INTERFACE:
        if "abstract" not in added_method.splitlines()[0]:
            raise ValueError("RYU interface method must be abstract")
    elif name == IMPLEMENTATION:
        if "Lcom/miui/powerkeeper/AppRuleChecker;->q(I)" not in added_method:
            raise ValueError("RYU AppRuleChecker.getUidPolicy has unknown implementation")
        if "Lcom/miui/powerkeeper/AppRuleChecker$j;->d()" not in added_method:
            raise ValueError("RYU AppRuleChecker.getUidPolicy lost Bundle getter dependency")
        if "q(I)Lcom/miui/powerkeeper/AppRuleChecker$j;" not in current:
            raise ValueError("Stock AppRuleChecker has no q(I) helper")
        # The getter is not present in Xiaomi/HyperMOS #101. Port it below.
        checker = one(stock, HELPER).read_text(encoding="utf-8")
        if "Lcom/miui/powerkeeper/AppRuleChecker$i;" not in checker:
            raise ValueError("Stock AppRuleChecker$j has incompatible policy state")
    elif name == HELPER:
        required_fields = [
            "e:Lcom/miui/powerkeeper/AppRuleChecker$i;",
            "f:Lcom/miui/powerkeeper/AppRuleChecker$i;",
        ]
        for field in required_fields:
            if field not in current:
                raise ValueError(f"Stock AppRuleChecker$j missing expected field {field}")
        state = one(stock, "AppRuleChecker$i.smali").read_text(encoding="utf-8")
        for field in ["a:I", "b:J"]:
            if field not in state:
                raise ValueError(f"Stock AppRuleChecker$i missing {field}")
        if not all(x in added_method for x in
                   ['"POLICY"', '"DELAY_MINUTE"', '"HOT_POLICY"', '"HOT_DELAY_MINUTE"']):
            raise ValueError("RYU Bundle helper missing expected UID policy keys")
    target.write_text(current.rstrip() + "\n\n" + added_method.rstrip() + "\n", encoding="utf-8")
    return True


def run(ryu: Path, stock: Path, report: Path) -> None:
    if not ryu.is_dir() or not stock.is_dir():
        raise ValueError("Decoded source/target directories are required")
    ctrl = one(stock, CONTROLLER).read_text(encoding="utf-8")
    if not method(ctrl, "shouldKillByCheckerPolicy(I)Z"):
        raise ValueError("RYU controller policy gate has not been ported")
    if "PowerKeeperInterface$l;->getUidPolicy(I)Landroid/os/Bundle;" not in ctrl:
        raise ValueError("Controller does not call the expected RYU UID policy interface")
    changes = {}
    for file, cls in (
        (INTERFACE, "PowerKeeperInterface$l"),
        (HELPER, "AppRuleChecker$j"),
        (IMPLEMENTATION, "AppRuleChecker"),
    ):
        changes[file] = "added" if port(ryu, stock, file, cls) else "already_present"
    # Strictly limit the delta to the three missing method definitions.
    report.parent.mkdir(parents=True, exist_ok=True)
    report.write_text(json.dumps({"method": METHOD, "changes": changes,
                                  "controller": "unchanged"}, indent=2) + "\n",
                      encoding="utf-8")
    print("[RYU UID POLICY] PASS: interface + Bundle helper + implementation synchronized; controller unchanged")


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--ryu", type=Path, required=True)
    p.add_argument("--stock", type=Path, required=True)
    p.add_argument("--report", type=Path, required=True)
    args = p.parse_args()
    run(args.ryu, args.stock, args.report)
