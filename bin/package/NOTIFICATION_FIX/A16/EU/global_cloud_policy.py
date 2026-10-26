#!/usr/bin/env python3
"""Portable, fail-closed smali patching for Xiaomi.eu Android 16.

No device-specific method SHA-256 is used.  Edits are located by their old
instruction spans inside a uniquely resolved class/method.  Original offsets
are only disambiguation hints, never mandatory offsets.  Rebuilt bytecode is
validated by stable instructions, not baksmali-generated label addresses.
"""
import argparse
import json
import re
from pathlib import Path

METHOD = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$")
IGNORE = ("#", ".line ", ".local ", ".end local", ".restart local",
          ".param ", ".end param", ".prologue", ".epilogue", ".source ")
EXPECTED = {"global-cloud": 4}
ZK_MARKERS = ("Lmiui/zk/", "Lcom/zk/", "IS_ZK_BUILD", "zk_state", "Lcom/projectryu/")


def norm(src):
    return [s for line in src.splitlines() if (s := line.strip())
            and not s.startswith(IGNORE)]


def one_file(root, rel):
    found = list(root.glob("smali*/" + rel))
    if not found:
        # Different ROM versions may package a class under a different owner.
        found = list(root.rglob(rel.rsplit("/", 1)[-1]))
    if len(found) != 1:
        raise ValueError(f"{rel}: expected exactly one class; found {len(found)}")
    return found[0]


def one_method(src, sig):
    found = [m for m in METHOD.finditer(src)
             if m.group().splitlines()[0].strip().split()[-1] == sig]
    if len(found) != 1:
        raise ValueError(f"{sig}: expected exactly one method, found {len(found)}")
    return found[0]


def validate_edits(edits):
    end = -1
    for edit in edits:
        if set(edit) != {"at", "remove", "insert"}:
            raise ValueError("invalid delta entry")
        at, old, new = edit["at"], edit["remove"], edit["insert"]
        if not isinstance(at, int) or at < 0 or not isinstance(old, list) or not isinstance(new, list):
            raise ValueError("invalid delta position/instructions")
        if any(not isinstance(x, str) or "\n" in x for x in old + new):
            raise ValueError("invalid instruction text")
        if at < end:
            raise ValueError("overlapping or disordered donor edit spans")
        end = at + len(old)


def load_manifest(file):
    data = json.loads(file.read_text(encoding="utf-8"))
    if data.get("format") != "hypermos_a16_method_deltas_v1":
        raise ValueError("unsupported policy delta format")
    amounts = {k: 0 for k in EXPECTED}
    seen = set()
    for entry in data["methods"]:
        bucket = entry["bucket"]
        if bucket not in amounts:
            raise ValueError("unexpected donor bucket")
        identity = (bucket, entry["path"], entry["signature"])
        if identity in seen:
            raise ValueError("duplicate donor method")
        seen.add(identity)
        amounts[bucket] += 1
        if "before_sha256" in entry or "after_sha256" in entry:
            raise ValueError("method SHA pins are not supported")
        validate_edits(entry["changes"])
        if bucket.startswith("zk"):
            for edit in entry["changes"]:
                if any(marker in line for line in edit["insert"] for marker in ZK_MARKERS):
                    raise ValueError("ZK-only class/property reference is forbidden")
    if amounts != EXPECTED:
        raise ValueError(f"incomplete policy delta set: {amounts}")
    return data


def instruction_key(line):
    """For verification: stable opcode/operands; ignore DEX label offsets."""
    line = re.sub(r"\bconst-string/jumbo\b", "const-string", line.strip())
    return re.sub(r":(cond|goto|try_start|try_end|catchall)_[0-9a-fA-F]+",
                  lambda m: ":" + m.group(1) + "_*", line)


def meaningful(line):
    v = line.strip()
    return (v and not v.startswith((".", ":"))
            and not re.match(r"^(?:goto|if-)", v))


def verify_effect(source, edits, sig):
    """Check the bytecode effects, including removed functional instructions."""
    if not edits:
        return
    body = [instruction_key(x) for x in norm(source)]
    before = [instruction_key(x) for e in edits for x in e["remove"] if meaningful(x)]
    after = [instruction_key(x) for e in edits for x in e["insert"] if meaningful(x)]
    for instruction in set(after):
        if instruction not in body:
            raise ValueError(f"{sig}: missing inserted opcode: {instruction}")
    # Deleted opcodes must stay absent, except for semantically identical
    # re-encodings (const-string -> const-string/jumbo) and duplicates.
    for instruction in set(before) - set(after):
        if instruction.startswith(("invoke-", "sput-", "filled-new-array")):
            if instruction in body:
                raise ValueError(f"{sig}: removed instruction still present: {instruction}")
    if sig == "getImportantApps()Ljava/util/List;":
        raw = "\n".join(body)
        token = "InternationalPolicyManager;->tmpImportantApps:Ljava/util/List;"
        if raw.count(token) < 2 or "return-object v0" not in body:
            raise ValueError("getImportantApps: cache early return is missing")


def positions(lines, fragment):
    size = len(fragment)
    return [i for i in range(len(lines) - size + 1)
            if lines[i:i + size] == fragment]


def apply_edits(lines, edits):
    """Relocate edits by exact old instructions, with offsets as hints only.

    Reject missing/ambiguous anchors. Never silently replace an unknown
    method body from another phone or HyperOS revision.
    """
    anchored = {}
    shift = 0
    last_end = 0
    for number, change in enumerate(edits):
        old = change["remove"]
        if not old:
            continue
        candidates = [x for x in positions(lines, old) if x >= last_end]
        if not candidates:
            raise ValueError(f"delta {number}: old instructions not found")
        expected = change["at"] + shift
        distances = [abs(pos - expected) for pos in candidates]
        lowest = min(distances)
        selected = [pos for pos, distance in zip(candidates, distances) if distance == lowest]
        if len(selected) != 1:
            raise ValueError(f"delta {number}: old opcode anchor ambiguous")
        at = selected[0]
        anchored[number] = at
        shift = at - change["at"]
        last_end = at + len(old)
    for number, change in enumerate(edits):
        if change["remove"]:
            continue
        earlier = max((i for i in anchored if i < number), default=None)
        later = min((i for i in anchored if i > number), default=None)
        guesses = []
        if earlier is not None:
            guesses.append(anchored[earlier] + change["at"] - edits[earlier]["at"])
        if later is not None:
            guesses.append(anchored[later] - (edits[later]["at"] - change["at"]))
        if not guesses:
            raise ValueError(f"delta {number}: insertion has no structural anchors")
        if len(set(guesses)) != 1:
            raise ValueError(f"delta {number}: insertion context differs on target")
        anchored[number] = guesses[0]
    end = -1
    for i, change in enumerate(edits):
        pos = anchored[i]
        if pos < end or pos < 1 or pos > len(lines):
            raise ValueError(f"delta {i}: invalid or overlapping opcode anchors")
        if lines[pos:pos + len(change["remove"])] != change["remove"]:
            raise ValueError(f"delta {i}: opcode anchor changed")
        end = pos + len(change["remove"])
    result = list(lines)
    for i in reversed(range(len(edits))):
        c = edits[i]
        pos = anchored[i]
        result[pos:pos + len(c["remove"])] = c["insert"]
    return result


def apply(root, manifest, bucket, verify, report):
    items = [x for x in manifest["methods"] if x["bucket"] == bucket]
    modified, preserved, no_op = [], [], []
    for entry in items:
        path = one_file(root, entry["path"])
        source = path.read_text(encoding="utf-8")
        method = one_method(source, entry["signature"])
        sig = entry["signature"]
        changes = entry["changes"]
        ident = entry["path"] + "->" + sig
        if verify:
            verify_effect(method.group(), changes, sig)
            preserved.append(ident)
            continue
        if not changes:
            verify_effect(method.group(), changes, sig)
            no_op.append(ident)
            continue
        current = norm(method.group())
        try:
            target = apply_edits(current, changes)
        except ValueError:
            # Already-transformed target: only accept when every functional
            # instruction effect is verifiably present.
            verify_effect(method.group(), changes, sig)
            preserved.append(ident)
            continue
        rebuilt = "\n".join(target)
        verify_effect(rebuilt, changes, sig)
        if target == current:
            preserved.append(ident)
        else:
            path.write_text(source[:method.start()] + rebuilt + source[method.end():],
                            encoding="utf-8")
            modified.append(ident)
    result = {"policy": bucket, "patched": modified, "already_applied": preserved,
              "original_equal": no_op, "method_count": len(items),
              "verify_only": verify, "SHA_pinning": False,
              "donor_archives_required": False}
    if report:
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print("[EU POLICY DELTAS] " + json.dumps(result))


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--root", required=True, type=Path)
    p.add_argument("--manifest", required=True, type=Path)
    p.add_argument("--policy", required=True, choices=EXPECTED)
    p.add_argument("--verify", action="store_true")
    p.add_argument("--report", type=Path)
    a = p.parse_args()
    try:
        apply(a.root, load_manifest(a.manifest), a.policy, a.verify, a.report)
    except (OSError, ValueError, KeyError, TypeError, IndexError) as exc:
        raise SystemExit("[EU POLICY DELTAS] FAIL: " + str(exc))


if __name__ == "__main__":
    main()
