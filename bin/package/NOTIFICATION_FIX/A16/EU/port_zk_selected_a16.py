#!/usr/bin/env python3
"""Method-only ZK304 Android 16 EU policy port; strict ABI/dependency checks."""
import argparse
import json
import re
from pathlib import Path

METHOD = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$")
CLASS = re.compile(r"(?m)^\.class\b[^\n]*\s(L[^;\n ]+;)\s*$")
REF = re.compile(r"(L[^;\s]+;)->([^\s,(:]+)(\([^)]*\)(?:\[*[VZIJFDBCS]|\[*L[^;]+;)|:[^\s,]+)")
FIELD = re.compile(r"(?m)^\.field\b[^\n]*?\s([^\s:]+:[^\s=]+)")
IGNORE = ("#", ".line ", ".local ", ".end local", ".restart local", ".param ",
          ".end param", ".prologue", ".epilogue", ".source ")
TARGETS = {
    "jar": {"InternationalPolicyManager": ("getImportantApps(",)},
    "power": {
        "GmsObserver": ("isGmsControlEnabled()Z", "enableGms()V", "disableGms()V"),
        "ActiveStateController": ("dealNoRestrictApp()V",),
    },
}
FORBIDDEN = ("Lmiui/zk/", "Lcom/zk/", "IS_ZK_BUILD", "zk_state",
             "ro.product.zk_device", "Lcom/projectryu/")
ALIAS_FROM = "Lmiui/zk/Build;->IS_ZK_BUILD:Z"
ALIAS_TO = "Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z"


def normalized(src):
    return tuple(line for raw in src.splitlines()
                 if (line := raw.strip()) and not line.startswith(IGNORE))


def methods(src):
    found = {}
    for m in METHOD.finditer(src):
        first = m.group().splitlines()[0].strip()
        sig = first.split()[-1]
        if sig in found:
            raise ValueError("duplicate method " + sig)
        found[sig] = (m, first)
    return found


def index(root):
    result = {}
    for path in root.rglob("*.smali"):
        src = path.read_text(encoding="utf-8")
        match = CLASS.search(src)
        if match is None:
            raise ValueError("missing class declaration: " + str(path))
        owner = match.group(1)
        if owner in result:
            raise ValueError("duplicate owner: " + owner)
        result[owner] = (path, src)
    if not result:
        raise ValueError("no decoded classes: " + str(root))
    return result


def selected_classes(idx, area):
    result = {}
    for name in TARGETS[area]:
        found = [(owner, entry) for owner, entry in idx.items()
                 if owner.endswith("/" + name + ";")]
        if len(found) != 1:
            raise ValueError(f"{area}: expected one {name}, got {len(found)}")
        result[name] = found[0]
    return result


def selected_signature(indexed, signature_prefix):
    options = [k for k in indexed if k.startswith(signature_prefix)]
    if len(options) != 1:
        raise ValueError(f"expected one method {signature_prefix}, got {options}")
    return options[0]


def validate_links(body, eu_index, class_owner):
    if any(token in body for token in FORBIDDEN):
        raise ValueError("ZK-private/RYU dependency within selected method")
    for owner, name, desc in REF.findall(body):
        if owner not in eu_index:
            if owner == class_owner:
                raise ValueError("selected method owner missing")
            continue
        src = eu_index[owner][1]
        if desc.startswith("("):
            if name + desc not in methods(src):
                raise ValueError(f"missing EU method dependency {owner}->{name}{desc}")
        elif name + desc not in FIELD.findall(src):
            raise ValueError(f"missing EU field dependency {owner}->{name}{desc}")


def perform(eu_root, donor_root, area, report, original_root=None):
    eu = index(eu_root)
    donor = index(donor_root)
    base = index(original_root) if original_root else None
    selected_eu = selected_classes(eu, area)
    selected_donor = selected_classes(donor, area)
    if base is not None:
        selected_base = selected_classes(base, area)
    changed, intact = [], []
    for name, signatures in TARGETS[area].items():
        owner, (path, src) = selected_eu[name]
        donor_owner, (_, donor_src) = selected_donor[name]
        if owner != donor_owner:
            raise ValueError("class owner mismatch for " + name)
        if base is not None and selected_base[name][0] != owner:
            raise ValueError("original class owner mismatch for " + name)
        current = methods(src)
        incoming = methods(donor_src)
        if base is not None:
            before_methods = methods(selected_base[name][1][1])
            if current.keys() != before_methods.keys():
                raise ValueError(f"{name} method ABI changed after assembly")
        for prefix in signatures:
            sig = selected_signature(current, prefix)
            donor_sig = selected_signature(incoming, prefix)
            if sig != donor_sig:
                raise ValueError(f"method ABI mismatch: {sig} / {donor_sig}")
            a, flags = current[sig]
            b, donor_flags = incoming[sig]
            if flags != donor_flags:
                raise ValueError("method access flags mismatch: " + sig)
            replacement = b.group().replace(ALIAS_FROM, ALIAS_TO)
            validate_links(replacement, eu, owner)
            record = name + "." + sig
            if base is None:
                if normalized(a.group()) == normalized(replacement):
                    intact.append(record)
                    continue
                if src.count(a.group()) != 1:
                    raise ValueError("ambiguous method boundary: " + record)
                src = src.replace(a.group(), replacement, 1)
                eu[owner] = (path, src)
                current = methods(src)
                changed.append(record)
            else:
                before = before_methods[sig][0].group()
                expected = replacement if normalized(before) != normalized(replacement) else before
                if normalized(a.group()) != normalized(expected):
                    raise ValueError("verification failed for " + record)
                if normalized(a.group()) == normalized(before):
                    intact.append(record)
                else:
                    changed.append(record)
        if base is None:
            path.write_text(src, encoding="utf-8")
    if base is not None:
        for owner, (_, src) in eu.items():
            if owner not in base:
                raise ValueError("unexpected class after assembly: " + owner)
            before, after = methods(base[owner][1]), methods(src)
            if before.keys() != after.keys():
                raise ValueError("method inventory changed for " + owner)
            for sig in before:
                if normalized(before[sig][0].group()) != normalized(after[sig][0].group()):
                    method_id = owner.split("/")[-1].rstrip(";") + "." + sig
                    if method_id not in changed:
                        raise ValueError("unrelated method changed: " + method_id)
    data = {
        "component": area, "donor": "verified_ZK304_HAOTIAN",
        "ported": changed, "already_equal": intact,
        "selected": sum(map(len, TARGETS[area].values())),
        "no_blanket_exemptions": True, "EU_only_abi_preserved": True,
        "no_background_worker_injected": True, "runtime_tested": False,
    }
    if report:
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
    print("[ZK304 SELECTED] " + json.dumps(data))


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--eu-root", type=Path, required=True)
    p.add_argument("--donor-root", type=Path, required=True)
    p.add_argument("--component", choices=TARGETS.keys(), required=True)
    p.add_argument("--report", type=Path)
    p.add_argument("--verify-original", type=Path)
    args = p.parse_args()
    try:
        perform(args.eu_root, args.donor_root, args.component, args.report, args.verify_original)
    except (OSError, ValueError) as exc:
        raise SystemExit("[ZK304 SELECTED] FAIL: " + str(exc))


if __name__ == "__main__":
    main()
