#!/usr/bin/env python3
"""Read-only, narrowly scoped collection of RYU/ProjectRYU app payloads and grants.

Call --scan for each unpacked partition, then --finish once all partitions are done.
No patches, signing changes, or system installations are performed.
"""
import argparse
import hashlib
import json
import re
import shutil
import subprocess
from pathlib import Path

TAG = re.compile(r"project[._-]?ryu|ryuos|ryu", re.I)
PACKAGE_RE = re.compile(r"^package:\s+name='([^']+)'", re.M)
XML_FOLDERS = ("permissions", "sysconfig", "default-permissions", "init", "selinux")
CONFIG_EXTS = {".xml", ".rc", ".prop", ".conf", ".json", ".txt", ".sh", ".ini"}
MAX_CONFIG = 8 * 1024 * 1024


def is_candidate_config(rel: Path) -> bool:
    parts = [p.lower() for p in rel.parts]
    if not any(p in XML_FOLDERS for p in parts):
        return False
    return rel.suffix.lower() in CONFIG_EXTS


def apk_package(path: Path) -> str:
    try:
        proc = subprocess.run(
            ["aapt", "dump", "badging", str(path)],
            text=True, capture_output=True, timeout=25, check=False,
        )
        match = PACKAGE_RE.search(proc.stdout)
        return match.group(1) if match else ""
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return ""


def copy_file(src: Path, out: Path) -> None:
    if src.is_symlink() or not src.is_file():
        return
    out.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, out)


def load_json(path: Path, default):
    return json.loads(path.read_text(encoding="utf-8")) if path.is_file() else default


def write_json(path: Path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def scan(root: Path, partition: str, out: Path):
    if not root.is_dir():
        raise ValueError(f"Missing filesystem: {root}")
    apps_file = out / "_work" / "apps.json"
    existing = load_json(apps_file, [])
    results = []
    scanned = 0
    for apk in sorted(root.rglob("*")):
        if apk.suffix.lower() != ".apk" or apk.is_symlink() or not apk.is_file():
            continue
        scanned += 1
        rel = apk.relative_to(root)
        pkg = apk_package(apk)
        # Select by APK path / parent directory or actual Android package id.
        if not (TAG.search(rel.as_posix()) or TAG.search(pkg)):
            continue
        appdir = apk.parent
        for src in appdir.rglob("*"):
            if not src.is_file() or src.is_symlink():
                continue
            relative = src.relative_to(root)
            copy_file(src, out / "files" / partition / relative)
        entry = {"partition": partition, "source_apk": "/" + rel.as_posix(),
                 "package": pkg}
        if entry not in existing and entry not in results:
            results.append(entry)
        print(f"[RYU-APP] {partition}: /{rel} package={pkg or '(unknown)'}", flush=True)

    # Retain small candidate XML/configs until all app package IDs are known.
    # This catches grants that refer to an app without "RYU" in their XML filename.
    candidate_count = 0
    for src in sorted(root.rglob("*")):
        if src.is_symlink() or not src.is_file():
            continue
        rel = src.relative_to(root)
        if not is_candidate_config(rel) or src.stat().st_size > MAX_CONFIG:
            continue
        copy_file(src, out / "_work" / "candidate_config" / partition / rel)
        candidate_count += 1
    write_json(apps_file, existing + results)
    print(f"[RYU-APP] {partition}: searched {scanned} APKs; "
          f"{len(results)} matching APKs; {candidate_count} candidate configs")


def finish(out: Path, source: str):
    apps = load_json(out / "_work" / "apps.json", [])
    packages = sorted({a["package"].lower() for a in apps if a["package"]})
    matched_configs = []
    candidates = out / "_work" / "candidate_config"
    if candidates.exists():
        for src in sorted(candidates.rglob("*")):
            if not src.is_file() or src.is_symlink():
                continue
            rel = src.relative_to(candidates)
            raw = src.read_bytes()
            low = raw.lower()
            # Match exact-ish package ids via literal substring; filename and
            # content keywords catch non-package config references to RYU.
            relevant = bool(TAG.search(rel.as_posix()) or TAG.search(
                raw.decode("utf-8", errors="ignore")
            ))
            if not relevant:
                relevant = any(p.encode("utf-8") in low for p in packages)
            if relevant:
                copy_file(src, out / "files" / rel)
                matched_configs.append("/" + rel.as_posix())
    # Save each APK's manifest-requested permissions separately from
    # privileged grant XMLs; these are different sources of authority.
    requested = []
    for app in apps:
        apk = out / "files" / app["partition"] / app["source_apk"].lstrip("/")
        perms = []
        if apk.is_file():
            try:
                proc = subprocess.run(
                    ["aapt", "dump", "permissions", str(apk)],
                    capture_output=True, text=True, timeout=25, check=False,
                )
                if proc.returncode == 0:
                    perms = sorted(set(re.findall(
                        r"uses-permission(?:-sdk-[0-9]+)?:\\s+name='([^']+)'",
                        proc.stdout,
                    )))
            except (FileNotFoundError, subprocess.TimeoutExpired):
                pass
        requested.append({**app, "requested_permissions": perms})
    write_json(out / "app-permissions.json", requested)
    files_root = out / "files"
    entries = []
    if files_root.is_dir():
        for src in sorted(files_root.rglob("*")):
            if not src.is_file() or src.is_symlink():
                continue
            rel = src.relative_to(out)
            sha = hashlib.sha256()
            with src.open("rb") as stream:
                for block in iter(lambda: stream.read(1024 * 1024), b""):
                    sha.update(block)
            entries.append({
                "path": rel.as_posix(), "size": src.stat().st_size,
                "sha256": sha.hexdigest(),
            })
    write_json(out / "manifest.json", {
        "source": source, "apps": apps, "app_permissions_report": "app-permissions.json",
        "packages": packages, "related_config_paths": matched_configs,
        "files": entries,
    })
    (out / "SHA256SUMS.txt").write_text(
        "".join(f"{i['sha256']}  {i['path']}\n" for i in entries),
        encoding="utf-8",
    )
    (out / "README.txt").write_text(
        "RYUOS / ProjectRYU application audit, original files only.\n"
        f"Source: {source}\n"
        f"Matched APKs: {len(apps)}; related configs: {len(matched_configs)}.\n"
        "See manifest.json for original paths, Android package IDs and hashes.\n"
        "App directories preserve all APK splits, compiled artifacts and libraries.\n"
        "Related XML/RC/PROP files are copied if their name/content mentions RYU\n"
        "or references a discovered package ID. Unrelated APKs are excluded.\n"
        "Do not blindly install another ROM's privileged APK or permissions.\n",
        encoding="utf-8",
    )
    print(f"[RYU-APP] Result: {len(apps)} APK matches, "
          f"{len(matched_configs)} related configs, {len(entries)} files")
    if not apps:
        raise SystemExit("No RYU/ProjectRYU APK found: check release or filters")
    shutil.rmtree(out / "_work", ignore_errors=True)


def main():
    parser = argparse.ArgumentParser()
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--scan", action="store_true")
    mode.add_argument("--finish", action="store_true")
    parser.add_argument("--root", type=Path)
    parser.add_argument("--partition")
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--source", default="")
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    if args.scan:
        if not args.root or not args.partition:
            parser.error("--scan needs --root and --partition")
        scan(args.root, args.partition, args.output)
    else:
        finish(args.output, args.source)


if __name__ == "__main__":
    main()
