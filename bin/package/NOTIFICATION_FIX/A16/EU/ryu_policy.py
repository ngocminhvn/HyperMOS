#!/usr/bin/env python3
"""Strict method-level RYU EU309 policy changes, without donor JAR/APK binaries.

The JSON file is the only source of edits. Unrecognized code fails closed.
RYU-specific build flags are never introduced: international logic uses
the original Xiaomi miui.os.Build.IS_INTERNATIONAL_BUILD input.
"""
import argparse
import json
import re
from pathlib import Path

METHOD = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$")
INTERNATIONAL = "Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z"
GREEZE = "Lcom/miui/server/greeze/PolicyManager;->CN_MODEL:Z"
FIELD_RE = re.compile(r"(?m)^(\s*)sget-boolean\s+([vp]\d+),\s*" + re.escape(INTERNATIONAL) + r"\s*$")
GREEZE_RE = re.compile(r"(?m)^(\s*)sput-boolean\s+([vp]\d+),\s*" + re.escape(GREEZE) + r"\s*$")
ALIASES = ("IS_RYU_BUILD", "Lmiui/ryu/", "Lcom/projectryu/", "PerfHook", "projectryu_max_fps")


def load(path):
    data = json.loads(path.read_text(encoding="utf-8"))
    if data.get("format") != "hypermos_ryu_a16_policy_v1":
        raise ValueError("Unsupported RYU manifest format")
    if set(data.get("groups", {})) != {"miui-services"}:
        raise ValueError("Only miui-services method edits are supported")
    seen = set()
    allowed = {"force_international", "force_cn_model_false", "ryu_return_void"}
    for group, entries in data["groups"].items():
        if not isinstance(entries, list) or not entries:
            raise ValueError("Empty group: " + group)
        for row in entries:
            pair = (group, row["class"], row["signature"])
            if pair in seen:
                raise ValueError("Duplicate method: " + str(pair))
            seen.add(pair)
            if row["operation"] not in allowed:
                raise ValueError("Unsupported operation")
            if row["operation"] == "force_international":
                regs = row.get("registers")
                if not isinstance(regs, list) or not regs or any(
                    not re.fullmatch(r"[vp]\d+", x) for x in regs
                ):
                    raise ValueError("Invalid forced register set")
                if not isinstance(row.get("value"), bool):
                    raise ValueError("Missing international constant")
            elif row["operation"] == "force_cn_model_false":
                if "registers" in row or "value" in row:
                    raise ValueError("Unexpected register override")
            else:
                if not row["signature"].endswith(")V"):
                    raise ValueError("return-void operation requires a void method")
                if any(key in row for key in ("anchor", "registers", "value")):
                    raise ValueError("Unexpected return-void override")
            if "before_sha256" in row or "after_sha256" in row:
                raise ValueError("Method hash pins are forbidden")
            if any(alias in json.dumps(row) for alias in ALIASES):
                raise ValueError("Forbidden RYU-only dependency")
    if len(data["groups"]["miui-services"]) != 19:
        raise ValueError("Expected exactly 19 selected RYU JAR methods")
    return data


def one_class(root, rel):
    candidates = list(root.glob("smali*/" + rel))
    if len(candidates) != 1:
        raise ValueError("Expected exactly one smali class %s, found %d" % (rel, len(candidates)))
    return candidates[0]


def method_span(source, signature):
    matches = [m for m in METHOD.finditer(source)
               if m.group().splitlines()[0].strip().split()[-1] == signature]
    if len(matches) != 1:
        raise ValueError("Missing/ambiguous method %s (%d)" % (signature, len(matches)))
    return matches[0]


def is_return_void_stub(body):
    """Accept the minimal stub before or after a baksmali round trip."""
    lines = [line.strip() for line in body.splitlines() if line.strip()]
    return (len(lines) == 4 and lines[0].startswith(".method ") and
            re.fullmatch(r"\.(?:locals|registers) \d+", lines[1]) is not None and
            lines[2] == "return-void" and lines[3] == ".end method")


def check_policy(row, body, verify):
    operation = row["operation"]
    if operation == "force_international":
        wanted = row["registers"]
        value = "0x1" if row["value"] else "0x0"
        matches = list(FIELD_RE.finditer(body))
        if verify:
            if matches:
                raise ValueError("International field read remains after patch")
            for reg in set(wanted):
                if not re.search(r"(?m)^\s*const/4\s+" + re.escape(reg) +
                                 r",\s*" + value + r"\s*$", body):
                    raise ValueError("Missing RYU international assignment: " + reg)
            return body, "verified"
        actual = [m.group(2) for m in matches]
        if actual != wanted:
            raise ValueError("Unexpected IS_INTERNATIONAL_BUILD reads: %s vs %s" %
                             (actual, wanted))
        pos = 0
        pieces = []
        for m in matches:
            pieces.append(body[pos:m.start()])
            pieces.append(m.group(1) + "const/4 " + m.group(2) + ", " + value)
            pos = m.end()
        pieces.append(body[pos:])
        return "".join(pieces), "patched"
    if operation == "force_cn_model_false":
        matches = list(GREEZE_RE.finditer(body))
        if len(matches) != 1:
            raise ValueError("CN_MODEL must be stored exactly once")
        m = matches[0]
        reg = m.group(2)
        if verify:
            preceding = body[:m.start()].splitlines()
            if not preceding or preceding[-1].strip() != "const/4 " + reg + ", 0x0":
                raise ValueError("RYU CN_MODEL=false guard not found")
            return body, "verified"
        prefix = m.group(1) + "const/4 " + reg + ", 0x0\n"
        return body[:m.start()] + prefix + body[m.start():], "patched"
    if operation == "ryu_return_void":
        if is_return_void_stub(body):
            return body, "verified" if verify else "already_patched"
        if verify:
            raise ValueError("Method is not a minimal return-void stub")
        header = body.splitlines()[0]
        return header + "\n    .locals 0\n\n    return-void\n.end method", "patched"
    raise ValueError("Unreachable operation")


def run(root, manifest, group, verify, report):
    out = []
    changes = []
    for entry in manifest["groups"][group]:
        src = one_class(root, entry["class"])
        original = src.read_text(encoding="utf-8")
        method = method_span(original, entry["signature"])
        try:
            updated, status = check_policy(entry, method.group(), verify)
        except ValueError as error:
            target = entry["class"] + "->" + entry["signature"]
            raise ValueError(target + ": " + str(error)) from error
        if updated != method.group():
            if verify:
                raise ValueError("Verification unexpectedly modified smali")
            src.write_text(original[:method.start()] + updated + original[method.end():],
                           encoding="utf-8")
            changes.append(entry["class"] + "->" + entry["signature"])
        out.append({"class": entry["class"], "method": entry["signature"], "status": status})
    payload = {"group": group, "verified": verify, "methods": out,
               "modified": changes, "PowerKeeper_APK_modified": False,
               "donor_archives_required": False}
    if report:
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
                          encoding="utf-8")
    print("[EU RYU POLICY] " + json.dumps({"group": group, "count": len(out),
          "modified": len(changes), "verify": verify}))
    return payload


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", required=True, type=Path)
    parser.add_argument("--manifest", required=True, type=Path)
    parser.add_argument("--group", required=True, choices=("miui-services",))
    parser.add_argument("--verify", action="store_true")
    parser.add_argument("--report", type=Path)
    a = parser.parse_args()
    try:
        run(a.root, load(a.manifest), a.group, a.verify, a.report)
    except (ValueError, OSError, KeyError, TypeError) as error:
        raise SystemExit("[EU RYU POLICY] FAIL: " + str(error))


if __name__ == "__main__":
    main()
