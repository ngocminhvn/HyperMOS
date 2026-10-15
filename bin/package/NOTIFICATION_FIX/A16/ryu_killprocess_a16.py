#!/usr/bin/env python3
"""Port only RYU's conditional UID-kill decision into ZKOS PowerKeeper.

Uses the checked-in HAOTIAN RYU DEX, already decoded beside ZKOS. Preserves
ZKOS KillProcessController members and every other PowerKeeper class.
Fails closed if the two implementations have incompatible field/layout ABI.
"""
from pathlib import Path
import re

from powerkeeper import adapt as adapt_ryu_references

CLASS_NAME = "Lcom/miui/powerkeeper/controller/KillProcessController;"
CHECKER_FIELD = "mKillProcessAppRuleChecker:Lcom/miui/powerkeeper/PowerKeeperInterface$l;"
SET_UID = "setUidState(IZ)V"
RULE_CHECK = "shouldKillByCheckerPolicy(I)Z"
METHOD = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$")
FIELD = re.compile(r"(?m)^[ \t]*\.field[^\n]*$")
CLASS = re.compile(r"(?m)^\.class[^\n]*$")
SUPER = re.compile(r"(?m)^\.super[^\n]*$")


def one_class(root: Path) -> Path:
    matches = list(root.rglob("KillProcessController.smali"))
    if len(matches) != 1:
        raise ValueError(f"Expected one KillProcessController in {root}, got {len(matches)}")
    return matches[0]


def get_methods(src: str) -> dict[str, str]:
    methods = {}
    for hit in METHOD.finditer(src):
        signature = hit.group().splitlines()[0].strip().split()[-1]
        if signature in methods:
            raise ValueError(f"Duplicate method: {signature}")
        methods[signature] = hit.group()
    return methods


def check_abi(stock: str, donor: str) -> None:
    for matcher, label in ((CLASS, "class"), (SUPER, "superclass")):
        lhs, rhs = matcher.findall(stock), matcher.findall(donor)
        if len(lhs) != 1 or len(rhs) != 1 or lhs != rhs:
            raise ValueError(f"RYU/ZKOS KillProcessController {label} differs")
    if CLASS_NAME not in CLASS.findall(stock)[0]:
        raise ValueError("Unexpected KillProcessController descriptor")
    for name, source in (("ZKOS", stock), ("RYU", donor)):
        fields = FIELD.findall(source)
        if len([field for field in fields if CHECKER_FIELD in field]) != 1:
            raise ValueError(f"{name}: checker field absent or ambiguous")
    stock_methods, donor_methods = get_methods(stock), get_methods(donor)
    if SET_UID not in stock_methods or SET_UID not in donor_methods:
        raise ValueError("Missing UID state decision in donor or target")
    if RULE_CHECK not in donor_methods:
        raise ValueError("Missing RYU conditional UID kill helper")



def port(zk_root: Path, ryu_root: Path) -> dict:
    target, donor_path = one_class(zk_root), one_class(ryu_root)
    stock = target.read_text(encoding="utf-8")
    donor = donor_path.read_text(encoding="utf-8")
    check_abi(stock, donor)
    stock_methods, donor_methods = get_methods(stock), get_methods(donor)

    ryu_uid, _, uid_gates = adapt_ryu_references(donor_methods[SET_UID])
    ryu_checker, _, checker_gates = adapt_ryu_references(donor_methods[RULE_CHECK])
    if "Lmiui/process/ProcessManager;->kill(" not in ryu_uid:
        raise ValueError("RYU UID path lost the conditional ProcessManager.kill call")
    if "->" + RULE_CHECK not in ryu_uid:
        raise ValueError("RYU UID path does not call shouldKillByCheckerPolicy")
    if "Lmiui/process/ProcessManager;->isLockedApplication(" not in ryu_uid:
        raise ValueError("RYU locked-app exemption missing")
    if "->checkAppOnWindowsStatus(I)Z" not in ryu_uid:
        raise ValueError("RYU visible-window exemption missing")
    if ("->getUidPolicy(I)Landroid/os/Bundle;" not in ryu_checker
            or '"POLICY"' not in ryu_checker or "0x1" not in ryu_checker
            or "0x2" not in ryu_checker):
        raise ValueError("RYU conditional policy=1/2 checker layout differs")
    if "Lcom/projectryu/" in ryu_uid or "Lcom/projectryu/" in ryu_checker:
        raise ValueError("Unexpected private RYU dependency")

    # The RYU decision must be self-contained: only a helper defined here and
    # fields/interfaces verified above may be newly referenced in this class.
    if RULE_CHECK in stock_methods and stock_methods[RULE_CHECK] != ryu_checker:
        raise ValueError("Target already defines a different policy checker")
    old_uid = stock_methods[SET_UID]
    if stock.count(old_uid) != 1:
        raise ValueError("Ambiguous UID state method")
    output = stock.replace(old_uid, ryu_uid, 1)
    helper_added = RULE_CHECK not in stock_methods
    if helper_added:
        output = output.rstrip() + "\n\n" + ryu_checker + "\n"
    if get_methods(output).get(SET_UID) != ryu_uid or get_methods(output).get(RULE_CHECK) != ryu_checker:
        raise ValueError("Port postcondition failed")
    for name, body in stock_methods.items():
        if name not in (SET_UID, RULE_CHECK) and get_methods(output).get(name) != body:
            raise ValueError(f"Unexpected ZKOS method modified: {name}")
    if output != stock:
        target.write_text(output, encoding="utf-8")
    return {
        "ryu_uid_method_ported": True,
        "ryu_checker_method_ported": True,
        "new_checker_method_added": helper_added,
        "untouched_zkos_killprocess_methods": len(stock_methods) - 1 - int(RULE_CHECK in stock_methods),
        "ryu_build_gates_adapted": uid_gates + checker_gates,
        "gms_policy_exemption_added": False,
        "uid_kill_policy": "unchanged RYU HAOTIAN setUidState and shouldKillByCheckerPolicy",
    }
