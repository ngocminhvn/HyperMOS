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
METHOD = re.compile(r"^\s*\.method\s+[^\n]*?\b(canShowBadge|canFloat|canShowOnKeyguard)\([^\n]*\)Z\s*$")
END = re.compile(r"^\s*\.end method\s*$")
CONTAINS = "Landroid/content/SharedPreferences;->contains(Ljava/lang/String;)Z"
MOVE = re.compile(r"^\s*move-result(?:/from16)?\s+([vp]\d+)\s*$")
CONST4 = re.compile(r"^\s*const/4\s+[vp]\d+,\s*(?:-?0x[\da-fA-F]+|-?\d+)\s*$")
BRANCH = re.compile(r"^(\s*)if-(eqz|nez)\s+([vp]\d+),\s*(:[\w$]+)\s*$")
VENDOR_KEY = ("FilterHelperCompat;", "getBadgeKey", "getFloatKey", "getKeyguardKey")
MARK = "# HyperMOS NotificationDefaults: only missing user preference"


class PatchError(RuntimeError):
    pass


# HyperOS 3 / Android 16 (haotian) stores its keys in the nested $Prefs
# class, not FilterHelperCompat. Only the *absence-of-saved-choice* fallback
# may change. Direct user and per-channel choices remain untouched.
WHITE_LIST_LOAD = re.compile(
    r"^([ \t]*)sget-boolean[ \t]+([vp]\d+),[ \t]*"
    r"Lcom/miui/systemui/notification/NotificationSettingsManager;"
    r"->USE_WHITE_LISTS:Z[ \t]*$", re.M
)


def patch_xiaomi_prefs(lines: list[str], name: str) -> tuple[list[str], int] | None:
    """Patch Xiaomi's verified two-stage pref layout, or return None for legacy.

    No extra locals/registers are used. First missing app preference defaults
    to allow but continues checking the channel choice. The second missing
    channel preference returns true directly. Existing choices still flow
    through the original getBoolean/getInt methods.
    """
    source = "".join(lines)
    if "NotificationSettingsManager$Prefs;->getNotif(" not in source:
        return None
    expectations = {
        "canShowBadge": (1, "getBoolean(", None),
        "canFloat": (2, "getInt(", "getFloatKey("),
        "canShowOnKeyguard": (2, "getBoolean(", "getKeyguardKey("),
    }
    n, getter, key = expectations[name]
    loads = list(WHITE_LIST_LOAD.finditer(source))
    pref_contains = source.count(CONTAINS)
    if (len(loads) != n or pref_contains != n or getter not in source
            or (key is not None and key not in source)):
        raise PatchError(
            f"unsupported Xiaomi preference layout in {name}: "
            f"whitelist_loads={len(loads)}, contains={pref_contains}, "
            f"expected={n}"
        )
    # Every fallback must be an if-eqz branch from a contains result.
    if len(re.findall(r"(?m)^\s*if-eqz\s+[vp]\d+,\s*:[\w$]+\s*$", source)) < n:
        raise PatchError(f"no guarded missing-pref branch in {name}")

    order = 0

    def replace_load(m: re.Match[str]) -> str:
        nonlocal order
        idx = order
        order += 1
        indent, register = m.group(1), m.group(2)
        result = indent + MARK + "\n" + indent + f"const/4 {register}, 0x1"
        if idx == n - 1:
            # Badge has one pref; float/keyguard have a second, channel pref.
            result += "\n" + indent + f"return {register}"
        return result

    result, count = WHITE_LIST_LOAD.subn(replace_load, source)
    if count != n:
        raise PatchError(f"unexpected Xiaomi edit count in {name}: {count}")
    # Revisit after a second pass without ever changing a saved choice.
    return result.splitlines(keepends=True), 1


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
    xiaomi = patch_xiaomi_prefs(lines, name)
    if xiaomi is not None:
        return xiaomi
    # Require the Xiaomi preference-key and read patterns; another same-named
    # method must not be patched solely because it returns a boolean.
    # HyperOS 3.0.308.0 stock uses NotificationSettingsManager$Prefs
    # rather than FilterHelperCompat. Both are known Xiaomi key providers.
    if not any(tag in source for tag in ("FilterHelperCompat;", "NotificationSettingsManager$Prefs;")):
        return lines, 0
    if not any(x in source for x in ("->getBoolean(", "->getInt(")):
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
        # Stock HyperOS emits 1–3 const/4 setup operations between
        # move-result and if-eqz. Skipping these does not affect the test
        # register; reject any other instruction before the preference branch.
        branch_at = next_instruction(lines, move_at + 1)
        const_count = 0
        while branch_at < len(lines) and CONST4.match(lines[branch_at]) and const_count < 4:
            branch_at = next_instruction(lines, branch_at + 1)
            const_count += 1
        if branch_at >= len(lines):
            continue
        bm = BRANCH.match(lines[branch_at])
        if not bm or bm.group(3) != mm.group(1):
            continue
        # Ensure the branch's saved-value path reads the same Xiaomi
        # SharedPreferences. A similarly named boolean function is not enough.
        value_reader = "".join(lines[branch_at + 1:branch_at + 14])
        if not any("Landroid/content/SharedPreferences;->" + method in value_reader
                   for method in ("getBoolean(", "getInt(")):
            continue
        if "NotificationSettingsManager$Prefs;" in source:
            earlier = "".join(lines[:i])
            if ("NotificationSettingsManager$Prefs;->getNotif(" not in earlier
                    or not any(x in earlier for x in (
                        "NotificationSettingsManager$Prefs;->getFloatKey(",
                        "NotificationSettingsManager$Prefs;->getKeyguardKey(",
                        'const-string'))):
                continue
        matches.append((branch_at, i, bm.group(1), bm.group(2), mm.group(1)))

    # Xiaomi can check a package key and then a channel key. The first
    # matching contains() branch is the initial per-app preference. Modify
    # only that initial missing-key path. Leave the channel branch untouched.
    if not matches:
        return lines, 0
    branch_at, _, indent, kind, register = matches[0]
    original = lines[branch_at]
    marker = f":tnm_notification_keep_{name}"
    existing_labels = set(re.findall(r"(?m)^\s*(:[\w$]+)", source))
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
    # Real OS3 layout: Prefs helpers, const/4 setup between result and
    # if-eqz, and a secondary channel SharedPreferences.contains() check.
    actual = [
        ".method public final canShowOnKeyguard(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)Z\n",
        "    .locals 5\n",
        "    invoke-static {p2, p3}, Lcom/miui/systemui/notification/NotificationSettingsManager$Prefs;->getKeyguardKey(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;\n",
        "    move-result-object v0\n",
        "    invoke-static {p1}, Lcom/miui/systemui/notification/NotificationSettingsManager$Prefs;->getNotif(Landroid/content/Context;)Landroid/content/SharedPreferences;\n",
        "    move-result-object v1\n",
        "    invoke-interface {v1, v0}, Landroid/content/SharedPreferences;->contains(Ljava/lang/String;)Z\n",
        "    move-result v2\n",
        "    const/4 v3, 0x1\n",
        "    const/4 v4, 0x0\n",
        "    if-eqz v2, :cond_default\n",
        "    invoke-interface {v1, v0, v4}, Landroid/content/SharedPreferences;->getBoolean(Ljava/lang/String;Z)Z\n",
        "    move-result v0\n",
        "    return v0\n",
        "    :cond_default\n",
        "    invoke-interface {v1, v0}, Landroid/content/SharedPreferences;->contains(Ljava/lang/String;)Z\n",
        "    move-result v0\n",
        "    if-eqz v0, :cond_final\n",
        "    invoke-interface {v1, v0, v4}, Landroid/content/SharedPreferences;->getBoolean(Ljava/lang/String;Z)Z\n",
        "    move-result v0\n",
        "    return v0\n",
        "    :cond_final\n",
        "    return v4\n",
        ".end method\n",
    ]
    patched_real, found_real = patch_file("".join(actual))
    assert found_real["canShowOnKeyguard"] == 1, found_real
    assert patched_real.count(MARK) == 1
    assert patched_real.count("Landroid/content/SharedPreferences;->contains(") == 2
    assert patched_real.count("invoke-interface") == 4
    assert patched_real == patch_file(patched_real)[0]
    # An incompatible class is a no-op (directory-level validation rejects it).
    unchanged, zeroes = patch_file(".class public La;\n")
    assert unchanged == ".class public La;\n"
    assert not any(zeroes.values())
    # The actual Android 16 Xiaomi SystemUI uses a different method layout
    # with a primary package setting followed by a channel setting.
    for name, number, getter, key in (
        ("canShowBadge", 1, "getBoolean", ""),
        ("canFloat", 2, "getInt", "getFloatKey"),
        ("canShowOnKeyguard", 2, "getBoolean", "getKeyguardKey"),
    ):
        fixture = [f".method public {name}(Landroid/content/Context;Ljava/lang/String;)Z\n",
                   "    .locals 9\n"]
        fixture += [
            "    invoke-static {p1}, Lcom/miui/systemui/notification/"
            "NotificationSettingsManager$Prefs;->getNotif(Landroid/content/Context;)"
            "Landroid/content/SharedPreferences;\n",
        ]
        if key:
            fixture += [
                "    invoke-static {p1}, Lcom/miui/systemui/notification/"
                f"NotificationSettingsManager$Prefs;->{key}(Ljava/lang/String;)"
                "Ljava/lang/String;\n",
            ]
        for i in range(number):
            fixture += [
                "    invoke-interface {v0, v1}, Landroid/content/"
                "SharedPreferences;->contains(Ljava/lang/String;)Z\n",
                "    move-result v2\n",
                f"    if-eqz v2, :missing_{i}\n",
                "    invoke-interface {v0, v1, v2}, Landroid/content/"
                f"SharedPreferences;->{getter}(Ljava/lang/String;Z)Z\n",
                "    move-result v3\n",
                "    return v3\n",
                f"    :missing_{i}\n",
                "    sget-boolean v4, Lcom/miui/systemui/notification/"
                "NotificationSettingsManager;->USE_WHITE_LISTS:Z\n",
            ]
        fixture += ["    return v4\n", ".end method\n"]
        original = "".join(fixture)
        changed, how_many = patch_file(original)
        assert how_many[name] == 1
        assert changed.count(MARK) == number
        assert changed.count("const/4 v4, 0x1") == number
        assert changed.count(f"SharedPreferences;->{getter}") == number
        assert changed.count("return v4") == 2
        again, again_count = patch_file(changed)
        assert changed == again and again_count[name] == 1

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
