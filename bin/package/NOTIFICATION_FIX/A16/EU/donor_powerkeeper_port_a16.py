#!/usr/bin/env python3
"""Port ZK304 PowerKeeper policy *methods* into the original EU PowerKeeper DEX.

Preserve EU classes, fields, methods and APK resources; replace only compatible
method bodies in power/notification policy controllers. A rejected ZK method is
reported, not silently copied. Compile/boot/on-device verification is required.
"""
import argparse
import json
import re
from pathlib import Path

METHOD = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$")
CLASS = re.compile(r"(?m)^\.class[^\n]*\s+(L[^;\s]+;)[ \t]*$")
FIELD = re.compile(r"(?m)^\.field[^\n]*\s+([\w$<>-]+:[^\s=]+)")
MEMBER_REF = re.compile(r"(L[\w/$-]+;)->([^\s,{}\t\r\n]+)")
CLASS_REF = re.compile(r"Lcom/miui/powerkeeper/[^;\s]+;")
TARGETS = (
    "Lcom/miui/powerkeeper/utils/GmsObserver;",
    "Lcom/miui/powerkeeper/controller/DeviceIdleController;",
    "Lcom/miui/powerkeeper/controller/DeviceIdleController$1;",
    "Lcom/miui/powerkeeper/controller/DeviceIdleController$2;",
    "Lcom/miui/powerkeeper/controller/ActiveStateController;",
    "Lcom/miui/powerkeeper/controller/KillProcessController;",
)
# ZK_BUILD is a renamed native international property in the EU integration.
ZK_FIELD = "Lmiui/zk/Build;->IS_ZK_BUILD:Z"
NATIVE_FIELD = "Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z"
ZK_THERMAL = "/sys/class/thermal/thermal_message/zk_state"
NATIVE_THERMAL = "/sys/class/thermal/thermal_message/temp_state"


def index(root):
    entries = {}
    for path in root.rglob("*.smali"):
        source = path.read_text(encoding="utf-8")
        hit = CLASS.search(source)
        if not hit:
            continue
        owner = hit.group(1)
        if owner in entries:
            raise ValueError("Duplicate smali class: " + owner)
        methods = {}
        for m in METHOD.finditer(source):
            signature = m.group().splitlines()[0].strip().split()[-1]
            if signature in methods:
                raise ValueError("Duplicate method: " + owner + "->" + signature)
            methods[signature] = m.group()
        fields = set(FIELD.findall(source))
        entries[owner] = {"path": path, "source": source,
                          "methods": methods, "fields": fields}
    return entries


def dependencies_ok(method, eu):
    if "Lcom/zk/" in method or "Lmiui/zk/" in method.replace(ZK_FIELD, ""):
        return "requires_ZK_private_API"
    for cls in CLASS_REF.findall(method):
        if cls not in eu:
            return "missing_EU_class:" + cls
    for owner, member in MEMBER_REF.findall(method):
        if not owner.startswith("Lcom/miui/powerkeeper/"):
            continue
        if owner not in eu:
            return "missing_EU_owner:" + owner
        if "(" in member:
            if member not in eu[owner]["methods"]:
                return "missing_EU_method:" + owner + "->" + member
        elif ":" in member and member not in eu[owner]["fields"]:
            return "missing_EU_field:" + owner + "->" + member
    return None


def normalized(method):
    return tuple(line.strip() for line in method.splitlines()
                 if line.strip() and not line.strip().startswith(
                     ("#", ".line", ".prologue", ".local", ".end local", ".restart local")))


def transform(donor):
    donor = donor.replace(ZK_FIELD, NATIVE_FIELD)
    donor = donor.replace(ZK_THERMAL, NATIVE_THERMAL)
    if ZK_FIELD in donor or ZK_THERMAL in donor:
        raise ValueError("ZK-specific compatibility rewrite failed")
    return donor


def port(eu_root, zk_root):
    eu, zk = index(eu_root), index(zk_root)
    pending, changed, skipped, unchanged, missing = {}, [], [], [], []
    for owner in TARGETS:
        if owner not in eu or owner not in zk:
            missing.append(owner)
            continue
        src = eu[owner]["source"]
        replacements = {}
        for signature, donor in zk[owner]["methods"].items():
            key = owner + "->" + signature
            if signature not in eu[owner]["methods"]:
                missing.append(key)
                continue
            donor = transform(donor)
            original = eu[owner]["methods"][signature]
            if normalized(original) == normalized(donor):
                unchanged.append(key)
                continue
            problem = dependencies_ok(donor, eu)
            if problem is not None:
                skipped.append({"method": key, "reason": problem})
                continue
            replacements[signature] = donor
            changed.append(key)
        if replacements:
            parts, last = [], 0
            for m in METHOD.finditer(src):
                parts.append(src[last:m.start()])
                signature = m.group().splitlines()[0].strip().split()[-1]
                parts.append(replacements.get(signature, m.group()))
                last = m.end()
            parts.append(src[last:])
            pending[eu[owner]["path"]] = "".join(parts)
    # All target classes must be present. Missing donor methods are acceptable
    # only because EU must preserve ABI, not because a whole-class swap is safe.
    if any(x in TARGETS for x in missing):
        raise ValueError("Missing mandatory policy class: " + str(missing))
    if len(changed) < 1:
        raise ValueError("No compatible ZK policy methods to port; refusing false success")
    for path, content in pending.items():
        path.write_text(content, encoding="utf-8")
    return {
        "donor": "original_ZK304_PowerKeeper",
        "method_level_merge": True,
        "eu_original_classes_methods_fields_preserved": True,
        "ported_count": len(changed),
        "ported_methods": changed,
        "unchanged_count": len(unchanged),
        "rejected_count": len(skipped),
        "rejected_methods": skipped,
        "eu_missing_donor_signatures": missing,
        "mapped_IS_ZK_BUILD_to_IS_INTERNATIONAL_BUILD": True,
        "stock_thermal_device_node": True,
        "not_byte_identical_to_ZK": True,
        "runtime_tested": False
    }


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--eu", type=Path, required=True)
    p.add_argument("--zk", type=Path, required=True)
    p.add_argument("--report", type=Path, required=True)
    args = p.parse_args()
    try:
        report = port(args.eu, args.zk)
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n")
        print("[EU ZK304 POWERKEEPER] " + json.dumps({k: v for k, v in report.items()
             if k not in ("ported_methods", "rejected_methods", "eu_missing_donor_signatures")}))
    except (OSError, ValueError) as exc:
        raise SystemExit("[EU ZK304 POWERKEEPER] FAIL: " + str(exc))


if __name__ == "__main__":
    main()
