#!/usr/bin/env python3
"""HyperMOS: permit lock-screen, floating and badge switches by default.

Only changes the *missing-preference* branch in Xiaomi's
NotificationSettingsManager. Existing explicit per-app/per-channel values (both
true and false) keep their original execution path. This does not grant
POST_NOTIFICATIONS, change channel importance, or alter PowerKeeper.

Usage: notification_defaults_patch.py <APKEditor raw decompile directory>
       notification_defaults_patch.py --self-test

The 3 groups are an atomic unit. For incompatible HyperOS versions, exit with
a clear reason before writing any file; do not guess at bytecode layouts.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

TARGETS = ("canShowBadge", "canFloat", "canShowOnKeyguard")
METHOD = re.compile(r"^\\s*\\.method\\s+[^\\n]*?\\b(canShowBadge|canFloat|canShowOnKeyguard)\\([^\\n]*\\)Z\\s*$")
END = re.compile(r"^\\s*\\.end method\\s*$")
CONTAINS = "Landroid/content/SharedPreferences;->contains(Ljava/lang/String;)Z"
MOVE = re.compile(r"^\\s*move-result(?:/from16)?\\s+([vp]\\d+)\\s*$")
BRANCH = re.compile(r"^(\\s*)if-(eqz|nez)\\s+([vp]\\d+),\\s*(:[\\w$]+)\\s*$")
VENDOR_KEY = ("FilterHelperCompat;", "getBadgeKey", "getFloatKey", "getKeyguardKey")
MARK = "# HyperMOS NotificationDefaults: only missing user preference"


class PatchError(RuntimeError):
    pass


def next_instruction(lines: list[str], start: int) -> int:
    i = start
    while i < len(lines) and (not lines[i].strip()
                              or lines[i].lstrip().startswith((".line ", ".prologue", ".local ", ".end local", ".restart local"))):
        i += 1
    return i


def patch_method(lines: list[str], name: str) -> tuple[list[str], int]:
    source = "".join(lines)
    if MARK in source:
        return lines, 1  # Idempotent on already-patched ROMs.
    # Require the Xiaomi preference-key and read patterns; another same-named
    # method must not be patched solely because it returns a boolean.
    if "FilterHelperCompat" not in source or not any(x in source for x in ("->getBoolean(", "->getInt(")):
        return lines, 0

    matches: list[tuple[int, int, str, str, str]] = []
    for i, line in enumerate(lines):
        if CONTAINS not in line:
            continue
        move_at = next_instruction(lines, i + 1)
        if move_at >= len(lines):
            continue
        mm = MOVE.match(lines[move_at])
        if not mm:
            continue
        branch_at = next_instruction(lines, move_at + 1)
        if branch_at >= len(lines):
            continue
        bm = BRANCH.match(lines[branch_at])
        if bm and bm.group(3) == mm.group(1):
            matches.append((branch_at, i, bm.group(1), bm.group(2), mm.group(1)))

    # One explicit user-preference existence check per overload. Refuse to
    # touch multi-gate methods rather than changing a non-default branch.
    if len(matches) != 1:
        return lines, 0
    branch_at, _, indent, kind, register = matches[0]
    original = lines[branch_at]
    marker = f":tnm_notification_keep_{name}"
    existing_labels = set(re.findall(r"(?m)^\\s*(:[\\w$]+)", source))
    if marker in existing_labels:
        raise PatchError("label collision in " + name)
    if kind == "eqz":
        # Original: if-eqz -> defaults, otherwise read user's saved choice.
        # New: return true only for missing key; continue the old path if set.
        replacement = [
            indent + MARK + "\n",
            indent + f"if-nez {register}, {marker}\n",
            indent + f"const/4 {register}, 0x1\n",
            indent + f"return {register}\n",
            indent + marker + "\n",
        ]
    else:
        # Original: if-nez -> saved choice, otherwise fall through to default.
        replacement = [
            original,
            indent + MARK + "\n",
            indent + f"const/4 {register}, 0x1\n",
            indent + f"return {register}\n",
        ]
    return lines[:branch_at] + replacement + lines[branch_at + 1:], 1


def patch_file(text: str) -> tuple[str, dict[str, int]]:
    lines = text.splitlines(keepends=True)
    out: list[str] = []
    tally = {name: 0 for name in TARGETS}
    i = 0
    while i < len(lines):
        match = METHOD.match(lines[i])
        if not match:
            out.append(lines[i])
            i += 1
            continue
        name = match.group(1)
        end = i + 1
        while end < len(lines) and not END.match(lines[end]):
            end += 1
        if end == len(lines):
            raise PatchError(f"unclosed smali method {name}")
        method, count = patch_method(lines[i:end + 1], name)
        out.extend(method)
        tally[name] += count
        i = end + 1
    return "".join(out), tally


def patch_directory(directory: Path) -> None:
    candidates = sorted(directory.glob("smali*/**/NotificationSettingsManager.smali"))
    if not candidates:
        raise PatchError("no NotificationSettingsManager.smali in this MiuiSystemUI APK")
    pending: dict[Path, str] = {}
    totals = {k: 0 for k in TARGETS}
    for path in candidates:
        orig = path.read_text(encoding="utf-8")
        patched, counts = patch_file(orig)
        if patched != orig:
            pending[path] = patched
        for name, n in counts.items():
            totals[name] += n
    missing = [name for name in TARGETS if totals[name] == 0]
    if missing:
        raise PatchError("incompatible Xiaomi notification methods: " +
                         ", ".join(missing) + " (nothing was written)")
    # Only after validating *all three* settings, write any modifications.
    for path, text in pending.items():
        path.write_text(text, encoding="utf-8")
    print("HyperMOS NotificationDefaults: " +
          ", ".join(f"{k}={v}" for k, v in totals.items()) +
          f"; changed_smali_files={len(pending)}")
    print("HyperMOS NotificationDefaults: preserved explicit user values, " +
          "unchanged POST_NOTIFICATIONS and channel importance")


def self_test() -> None:
    sample = [
        ".class public Lcom/android/systemui/statusbar/notification/NotificationSettingsManager;\n",
    ]
    for name, cond in zip(TARGETS, ("eqz", "nez", "eqz")):
        sample += [
            f".method public {name}(Landroid/content/Context;Ljava/lang/String;)Z\n",
            "    .locals 2\n",
            "    invoke-static {p2}, Lx/FilterHelperCompat;->getFloatKey(Ljava/lang/String;)Ljava/lang/String;\n",
            "    invoke-interface {v0, v1}, Landroid/content/SharedPreferences;->contains(Ljava/lang/String;)Z\n",
            "    move-result v0\n",
            f"    if-{cond} v0, :cond_a\n",
            "    invoke-interface {v0, v1, v1}, Landroid/content/SharedPreferences;->getBoolean(Ljava/lang/String;Z)Z\n",
            "    move-result v0\n",
            "    return v0\n",
            "    :cond_a\n",
            "    const/4 v0, 0x0\n",
            "    return v0\n",
            ".end method\n",
        ]
    result, totals = patch_file("".join(sample))
    assert all(totals[k] == 1 for k in TARGETS), totals
    assert result.count(MARK) == 3
    again, totals2 = patch_file(result)
    assert again == result and totals2 == totals
    assert result.count("invoke-interface") == 6
    # The no-pref path returns true while saved values remain delegated to the
    # original SharedPreferences getter.
    assert result.count("const/4 v0, 0x1") == 3
    # An incompatible class is a no-op (directory-level validation rejects it).
    unchanged, zeroes = patch_file(".class public La;\n")
    assert unchanged == ".class public La;\n"
    assert not any(zeroes.values())
    print("NotificationDefaults patch self-test: PASS (3 switches, " +
          "both conditional forms, idempotent, unknown layout skip)")


if __name__ == "__main__":
    try:
        if sys.argv[1:] == ["--self-test"]:
            self_test()
        elif len(sys.argv) == 2:
            patch_directory(Path(sys.argv[1]))
        else:
            raise PatchError("expected decompiled APK directory or --self-test")
    except (PatchError, AssertionError) as e:
        print(f"HyperMOS NotificationDefaults ERROR: {e}", file=sys.stderr)
        sys.exit(2)
