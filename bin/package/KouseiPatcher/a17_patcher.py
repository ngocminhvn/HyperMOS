#!/usr/bin/env python3
from __future__ import annotations

import argparse
import os
import re
import sys


ACTIVITY_METHOD = "handleBindApplication(Landroid/app/ActivityThread$AppBindData;)V"
ACTIVITY_ANCHOR = (
    "iput-object p1, p0, "
    "Landroid/app/ActivityThread;->mBoundApplication:"
    "Landroid/app/ActivityThread$AppBindData;"
)
ACTIVITY_HOOK = (
    "invoke-static {p1}, "
    "Landroid/security/kaorios/KaoriosHook;->initActivityThread(Ljava/lang/Object;)V"
)

SYSTEMSERVER_HOOK = (
    "invoke-static {}, "
    "Landroid/security/kaorios/KaoriosHook;->initSystemServer()V"
)
LOOPER_ANCHOR = "invoke-static {}, Landroid/os/Looper;->loop()V"

BUILD_STRING_FIELDS = {
    "BRAND",
    "BRAND_FOR_ATTESTATION",
    "DEVICE",
    "DEVICE_FOR_ATTESTATION",
    "FINGERPRINT",
    "HARDWARE",
    "ID",
    "MANUFACTURER",
    "MANUFACTURER_FOR_ATTESTATION",
    "MODEL",
    "MODEL_FOR_ATTESTATION",
    "PRODUCT",
    "PRODUCT_FOR_ATTESTATION",
    "TAGS",
    "TYPE",
    "USER",
}

BUILD_VERSION_FIELDS = {
    "RELEASE",
    "RELEASE_OR_CODENAME",
    "RELEASE_OR_PREVIEW_DISPLAY",
    "SECURITY_PATCH",
    "DEVICE_INITIAL_SDK_INT",
}


def find_one(base_dir: str, relative_path: str) -> str:
    normalized_target = os.path.normpath(relative_path)
    matches: list[str] = []

    for root, _dirs, files in os.walk(base_dir):
        for name in files:
            path = os.path.normpath(os.path.join(root, name))
            if path.endswith(normalized_target):
                matches.append(path)

    if len(matches) != 1:
        raise RuntimeError(
            f"Expected exactly one {relative_path}; found {len(matches)}"
        )
    return matches[0]


def method_span(content: str, signature: str) -> tuple[int, int]:
    pattern = re.compile(
        r"(?m)^\.method[^\r\n]*\s"
        + re.escape(signature)
        + r"[^\r\n]*(?:\r?\n|$)"
    )
    matches = list(pattern.finditer(content))
    if len(matches) != 1:
        raise RuntimeError(
            f"Expected exactly one method {signature}; found {len(matches)}"
        )

    end = re.search(
        r"(?m)^[ \t]*\.end method[ \t]*(?:\r?\n|$)",
        content[matches[0].end():],
    )
    if end is None:
        raise RuntimeError(f"Unterminated method {signature}")

    start_pos = matches[0].start()
    end_pos = matches[0].end() + end.end()
    return start_pos, end_pos


def patch_activity_thread(base_dir: str) -> None:
    path = find_one(base_dir, "android/app/ActivityThread.smali")
    content = open(path, "r", encoding="utf-8").read()
    start, end = method_span(content, ACTIVITY_METHOD)
    body = content[start:end]

    count = body.count("KaoriosHook;->initActivityThread(Ljava/lang/Object;)V")
    if count == 1:
        print("A17 ActivityThread hook already present")
        return
    if count > 1:
        raise RuntimeError("A17 ActivityThread hook is duplicated")

    matches = list(
        re.finditer(
            r"(?m)^(?P<indent>[ \t]*)"
            + re.escape(ACTIVITY_ANCHOR)
            + r"[ \t]*(?:\r?\n|$)",
            body,
        )
    )
    if len(matches) != 1:
        raise RuntimeError(
            f"ActivityThread anchor count is {len(matches)}, expected 1"
        )

    newline = "\r\n" if "\r\n" in body else "\n"
    m = matches[0]
    injection = f"{m.group('indent')}{ACTIVITY_HOOK}{newline}"
    patched_body = body[:m.end()] + injection + body[m.end():]

    if patched_body.count("KaoriosHook;->initActivityThread(Ljava/lang/Object;)V") != 1:
        raise RuntimeError("ActivityThread post-patch verification failed")

    patched = content[:start] + patched_body + content[end:]
    open(path, "w", encoding="utf-8").write(patched)
    print("Patched A17 ActivityThread.initActivityThread")


def patch_system_server(base_dir: str) -> None:
    path = find_one(base_dir, "com/android/server/SystemServer.smali")
    content = open(path, "r", encoding="utf-8").read()
    start, end = method_span(content, "run()V")
    body = content[start:end]

    count = body.count("KaoriosHook;->initSystemServer()V")
    if count == 1:
        print("A17 SystemServer hook already present")
        return
    if count > 1:
        raise RuntimeError("A17 SystemServer hook is duplicated")

    matches = list(
        re.finditer(
            r"(?m)^(?P<indent>[ \t]*)"
            + re.escape(LOOPER_ANCHOR)
            + r"[ \t]*(?:\r?\n|$)",
            body,
        )
    )
    if len(matches) != 1:
        raise RuntimeError(
            f"SystemServer Looper.loop anchor count is {len(matches)}, expected 1"
        )

    newline = "\r\n" if "\r\n" in body else "\n"
    m = matches[0]
    injection = f"{m.group('indent')}{SYSTEMSERVER_HOOK}{newline}{newline}"
    patched_body = body[:m.start()] + injection + body[m.start():]

    hook_pos = patched_body.find(SYSTEMSERVER_HOOK)
    loop_pos = patched_body.find(LOOPER_ANCHOR)
    if hook_pos < 0 or loop_pos < 0 or hook_pos > loop_pos:
        raise RuntimeError("SystemServer post-patch verification failed")

    patched = content[:start] + patched_body + content[end:]
    open(path, "w", encoding="utf-8").write(patched)
    print("Patched A17 SystemServer before Looper.loop")


def _field_name(line: str) -> str | None:
    m = re.search(r"\s([A-Z0-9_]+):", line)
    return m.group(1) if m else None


def patch_build(base_dir: str) -> None:
    path = find_one(base_dir, "android/os/Build.smali")
    lines = open(path, "r", encoding="utf-8").readlines()
    seen: set[str] = set()
    out: list[str] = []

    for line in lines:
        name = _field_name(line) if line.lstrip().startswith(".field") else None
        if name in BUILD_STRING_FIELDS and ":Ljava/lang/String;" in line:
            seen.add(name)
            line = re.sub(r"\bfinal\s+", "", line)
            if "=" not in line:
                line = line.rstrip("\r\n") + " = null" + (
                    "\r\n" if line.endswith("\r\n") else "\n"
                )
        elif name == "TIME" and ":J" in line:
            seen.add("TIME")
            line = re.sub(r"\bfinal\s+", "", line)
        out.append(line)

    missing = sorted((BUILD_STRING_FIELDS | {"TIME"}) - seen)
    if missing:
        raise RuntimeError(f"Build.smali missing fields: {missing}")

    open(path, "w", encoding="utf-8").writelines(out)
    print("Patched A17 Build fields")


def patch_build_version(base_dir: str) -> None:
    path = find_one(base_dir, "android/os/Build$VERSION.smali")
    lines = open(path, "r", encoding="utf-8").readlines()
    seen: set[str] = set()
    out: list[str] = []

    for line in lines:
        name = _field_name(line) if line.lstrip().startswith(".field") else None
        if name in BUILD_VERSION_FIELDS:
            seen.add(name)
            line = re.sub(r"\bfinal\s+", "", line)
        out.append(line)

    missing = sorted(BUILD_VERSION_FIELDS - seen)
    if missing:
        raise RuntimeError(f"Build$VERSION.smali missing fields: {missing}")

    open(path, "w", encoding="utf-8").writelines(out)
    print("Patched A17 Build$VERSION fields")


def main() -> None:
    parser = argparse.ArgumentParser(description="HyperMOS Kaorios Android 17 patcher")
    parser.add_argument("base_dir", help="Disassembled framework.jar/services.jar smali tree")
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--framework", action="store_true")
    mode.add_argument("--services", action="store_true")
    args = parser.parse_args()

    if not os.path.isdir(args.base_dir):
        raise RuntimeError(f"Directory not found: {args.base_dir}")

    if args.framework:
        patch_activity_thread(args.base_dir)
        patch_build(args.base_dir)
        patch_build_version(args.base_dir)
    else:
        patch_system_server(args.base_dir)


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"A17 patch failed: {exc}", file=sys.stderr)
        sys.exit(1)
