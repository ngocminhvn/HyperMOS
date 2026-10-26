#!/usr/bin/env python3
"""Port scoped *original ZK304* freeze/broadcast/Doze methods to EU309.

No full-class transplantation: preserves every EU-only method, field and
constructor. ZK custom boolean is mapped to stock IS_INTERNATIONAL_BUILD.
Rejects unresolvable intra-framework field/method references; no blanket
allowlisted apps, background wakelocks, polling, or freezer disabling.
"""
import argparse
import json
import re
from pathlib import Path

METHOD = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$")
FIELD = re.compile(r"(?m)^\.field[^\n]*?\s+([\w$<>-]+:[^\s=]+)")
OWNER = re.compile(r"(?m)^\.class[^\n]*?\s+(L[^;\s]+;)\s*$")
REFERENCES = re.compile(r"(L[\w/$-]+;)->([\w$<>-]+(?:\([^)]*\)[VZBCSIJFDL\[/;$0-9a-zA-Z_<>-]*|:[^\s,}{]+))")
TARGETS = {
    "com/miui/server/greeze/GreezeManagerService.smali": (
        "freezeAction(", "freezeUids(", "isAllowBroadcast(",
        "updateDynamicIsLandInfo(",
    ),
    "com/miui/server/greeze/InternationalPolicyManager.smali": (
        "getImportantApps(", "updateDeviceIdleApps(",
    ),
    "com/android/server/DeviceIdleControllerStubImpl.smali": (
        "isLowPowerDozeEnable(",
    ),
    "com/android/server/am/ProcessManagerService.smali": (
        "notifyProcessStarted(",
    ),
}
ALIASES = {
    "Lmiui/zk/Build;->IS_ZK_BUILD:Z":
        "Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z",
}
# Do not transplant constructors, EU static field initialization, or an
# unrelated Android system class from a different base version.
ZK_PRIVATE = ("Lcom/zk/", "Lmiui/zk/")


def one(root, suffix):
    found = list(root.glob("smali*/" + suffix))
    if len(found) != 1:
        raise ValueError(f"{suffix}: expected exactly one class, got {len(found)}")
    return found[0]


def method_info(block):
    signature = block.splitlines()[0].strip().split()[-1]
    return signature, signature.split("(", 1)[0]


def members(root, suffix):
    f = one(root, suffix)
    src = f.read_text(encoding="utf-8")
    owner_match = OWNER.search(src)
    if not owner_match:
        raise ValueError("Class declaration missing in " + suffix)
    methods = {}
    for match in METHOD.finditer(src):
        signature, _ = method_info(match.group())
        if signature in methods:
            raise ValueError("Duplicate " + signature + " in " + suffix)
        methods[signature] = match.group()
    return {"path": f, "source": src, "owner": owner_match.group(1),
            "methods": methods, "fields": set(FIELD.findall(src))}


def normalize(block):
    return tuple(line.strip() for line in block.splitlines()
                 if line.strip() and not line.strip().startswith(
                    ("#", ".line", ".param", ".prologue", ".local",
                     ".end local", ".restart local", ".source")))


def verify_internal_dependencies(block, eu):
    for marker in ZK_PRIVATE:
        if marker in block:
            raise ValueError("Unsupported ZK-private API: " + marker)
    # Only same-class references can be resolved here. Other framework
    # references remain original EU types and are checked by smali assembly.
    for own, member in REFERENCES.findall(block):
        if own != eu["owner"]:
            continue
        if "(" in member:
            if member not in eu["methods"]:
                raise ValueError("Missing EU method: " + own + "->" + member)
        elif member not in eu["fields"]:
            raise ValueError("Missing EU field: " + own + "->" + member)


def patch_pair(eu, zk, names):
    pending = {}
    statuses = {}
    for prefix in names:
        if prefix.startswith("<"):
            raise ValueError("Never port constructors/initializers with this helper")
        donors = [(k, v) for k, v in zk["methods"].items()
                  if k.startswith(prefix)]
        originals = [(k, v) for k, v in eu["methods"].items()
                     if k.startswith(prefix)]
        if len(donors) != 1 or len(originals) != 1 or donors[0][0] != originals[0][0]:
            raise ValueError(f"{eu['owner']}/{prefix}: method signature mismatch")
        signature, body = donors[0]
        for old, new in ALIASES.items():
            body = body.replace(old, new)
        verify_internal_dependencies(body, eu)
        target = originals[0][1]
        statuses[signature] = ("already_equal" if normalize(body) == normalize(target)
                               else "ported_zk304")
        pending[signature] = body
    source = eu["source"]
    parts, last = [], 0
    for m in METHOD.finditer(source):
        parts.append(source[last:m.start()])
        sig, _ = method_info(m.group())
        parts.append(pending.get(sig, m.group()))
        last = m.end()
    parts.append(source[last:])
    edited = "".join(parts)
    # Existing EU method inventory and class declaration must be preserved.
    methods_after = [method_info(m.group())[0] for m in METHOD.finditer(edited)]
    if set(methods_after) != set(eu["methods"]) or len(methods_after) != len(eu["methods"]):
        raise ValueError("EU method inventory changed unexpectedly")
    if OWNER.search(edited).group(1) != eu["owner"]:
        raise ValueError("EU class identity changed")
    if set(FIELD.findall(edited)) != eu["fields"]:
        raise ValueError("EU field inventory changed")
    return edited, statuses


def port(eu_root, zk_root, report):
    planned, results = {}, {}
    for rel, target_names in TARGETS.items():
        eu = members(eu_root, rel)
        zk = members(zk_root, rel)
        if eu["owner"] != zk["owner"]:
            raise ValueError("Mismatched owner class: " + rel)
        edited, statuses = patch_pair(eu, zk, target_names)
        planned[eu["path"]] = edited
        results[rel] = statuses
    count = sum(v == "ported_zk304" for methods in results.values()
                for v in methods.values())
    if count == 0:
        raise ValueError("No ZK-specific changes found; refusing false-success")
    # Fail closed: no output is written until all targets pass their checks.
    for path, src in planned.items():
        if path.read_text(encoding="utf-8") != src:
            path.write_text(src, encoding="utf-8")
    result = {
        "source": "ZK304 original miui-services.jar",
        "eu_runtime_classes_preserved": True,
        "eu_only_apis_preserved": True,
        "mode": "selective_donor_method_body_port",
        "changed_methods": count,
        "method_results": results,
        "policy_source_build_flag": "Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z",
        "apk_powerkeeper": "unchanged_by_this_step",
        "runtime_verified": False,
        "note": "Not a whole-JAR port. Greeze constructors and EU-only callbacks remain EU309."
    }
    report.parent.mkdir(parents=True, exist_ok=True)
    report.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("decoded_eu", type=Path)
    parser.add_argument("decoded_zk", type=Path)
    parser.add_argument("--report", type=Path, required=True)
    args = parser.parse_args()
    try:
        result = port(args.decoded_eu, args.decoded_zk, args.report)
        print("[ZK304 EU GREEZE] " + json.dumps({
            "changed_methods": result["changed_methods"],
            "method_results": result["method_results"]}, sort_keys=True))
    except (OSError, ValueError) as exc:
        raise SystemExit("[ZK304 EU GREEZE] FAIL: " + str(exc))
