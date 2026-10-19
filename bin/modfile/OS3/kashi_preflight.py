#!/usr/bin/env python3
"""Update Kashi releases transactionally; verify the real OS3 installer on a mock ROM.

This is a *static and integration* preflight, NOT a device boot/compatibility test.
No downloaded module scripts are executed.
"""
from __future__ import annotations

import filecmp
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import stat
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET
import zipfile
from dataclasses import dataclass

ROOT = Path(__file__).resolve().parents[3]
KASHI = ROOT / "bin/modfile/OS3/kashi"

@dataclass(frozen=True)
class Source:
    label: str
    repo: str
    prefix: str
    package: str
    mode: str = "native"

SOURCES = (
    Source("App Vault", "Mods-Center/HyperOS-App-Vault", "HyperOS_AppVault", "com.miui.personalassistant"),
    Source("ColorOS Control Center", "Mods-Center/ColorOS_Control_Center", "ColorOS_plugin_mod_", "miui.systemui.plugin"),
    Source("FreeStyle Control Center", "Mods-Center/FreeStyle-Control-Center", "FreeStyle_CC_mod_", "miui.systemui.plugin", "reference"),
    Source("Screenshot", "Mods-Center/HyperOS-Screenshot-mod", "HyperOS_Screenshot", "com.miui.screenshot", "screenshot"),
    Source("Launcher", "Mods-Center/HyperOS-Launcher", "HyperOS_Launcher", "com.miui.home", "launcher"),
    Source("Security Center", "Mods-Center/HyperOS-Security-Center", "HyperOS_Security", "com.miui.securitycenter", "reference"),
    Source("Theme Manager", "Mods-Center/HyperOS-Theme-Manager", "HyperOS_ThemeManager", "com.android.thememanager"),
)

@dataclass
class Plan:
    source: Source
    path: Path
    main: str
    overlay: str | None = None
    whitelist: str | None = None
    libraries: int = 0
    system_files: int = 0

def run(*args: str, timeout: int = 300, env=None) -> str:
    result = subprocess.run(args, cwd=ROOT, env=env, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                            timeout=timeout)
    if result.returncode:
        raise RuntimeError(
            f"Command failed ({result.returncode}): {' '.join(args)}\n"
            f"{result.stdout[-5000:]}\n{result.stderr[-7000:]}"
        )
    return result.stdout

def apk_package(apk: Path) -> str:
    badging = run("aapt", "dump", "badging", str(apk), timeout=120)
    match = re.search(r"^package: name='([^']+)'", badging, re.MULTILINE)
    if not match:
        raise ValueError(f"Unreadable Android package name: {apk}")
    return match.group(1)

def safe_system_member(name: str) -> bool:
    parts = PurePosixPath(name).parts
    if "system" not in parts:
        return True
    i = parts.index("system")
    rest = list(parts[i + 1:])
    if not rest:
        return True
    if rest[0] in ("product", "system_ext", "vendor", "odm", "mi_ext", "mi_product", "system"):
        rest = rest[1:]
    if not rest:
        return True
    if rest[0] in ("app", "priv-app", "overlay", "lib", "lib64"):
        return True
    if len(rest) > 1 and rest[0] == "etc" and rest[1] in ("permissions", "sysconfig"):
        return True
    return False

def inspect_archive(path: Path, source: Source) -> Plan:
    with zipfile.ZipFile(path) as archive, tempfile.TemporaryDirectory(prefix="kashi-apk-scan-") as temp:
        entries = archive.infolist()
        if not entries or len(entries) > 4000:
            raise ValueError(f"{source.label}: unexpected ZIP entry count")
        seen = set()
        apk_members = []
        expanded = 0
        libraries = 0
        system_files = 0
        for entry in entries:
            name = entry.filename
            parts = PurePosixPath(name).parts
            mode = stat.S_IFMT(entry.external_attr >> 16)
            if (not name or name.startswith("/") or "\\" in name or ".." in parts
                    or name in seen or mode == stat.S_IFLNK):
                raise ValueError(f"{source.label}: unsafe ZIP entry {name!r}")
            seen.add(name)
            if entry.flag_bits & 1:
                raise ValueError(f"{source.label}: encrypted ZIP entry {name}")
            expanded += entry.file_size
            if expanded > 1024 * 1024 * 1024:
                raise ValueError(f"{source.label}: ZIP expands beyond 1 GiB")
            if entry.is_dir():
                continue
            if not safe_system_member(name):
                raise ValueError(
                    f"{source.label}: unreviewed system target {name!r}. "
                    "Do not apply framework, boot, init or executable changes automatically."
                )
            if "system" in parts:
                system_files += 1
            if name.endswith(".so"):
                libraries += 1
            if name.lower().endswith(".apk"):
                apk_members.append(name)
        if archive.testzip():
            raise ValueError(f"{source.label}: ZIP CRC failure")
        if not apk_members or len(apk_members) > 80:
            raise ValueError(f"{source.label}: unreasonable APK inventory")

        packages: dict[str, str] = {}
        for index, member in enumerate(apk_members):
            out = Path(temp) / f"{index}.apk"
            with archive.open(member) as src, out.open("wb") as dst:
                shutil.copyfileobj(src, dst)
            packages[member] = apk_package(out)
        main = [member for member, package in packages.items() if package == source.package]
        if len(main) != 1:
            raise ValueError(
                f"{source.label}: expected ONE APK for {source.package}, "
                f"found {len(main)}: {main}"
            )

        plan = Plan(source, path, main[0], libraries=libraries, system_files=system_files)
        if source.mode == "launcher":
            overlay = [
                member for member, package in packages.items()
                if package == "android.miui.home.launcher.res"
            ]
            if len(overlay) != 1:
                raise ValueError(f"Launcher: expected one launcher resource overlay, found {overlay}")
            plan.overlay = overlay[0]
            permissions = []
            for entry in entries:
                if entry.is_dir() or not entry.filename.lower().endswith(".xml"):
                    continue
                try:
                    root = ET.fromstring(archive.read(entry))
                except ET.ParseError:
                    continue
                if any(
                    node.tag.rsplit("}", 1)[-1] == "privapp-permissions"
                    and node.attrib.get("package") == "com.miui.home"
                    for node in root.iter()
                ):
                    permissions.append(entry.filename)
            if len(permissions) != 1:
                raise ValueError(f"Launcher: expected one com.miui.home privapp permission XML, got {permissions}")
            plan.whitelist = permissions[0]
        print(
            f"[STRUCTURE OK] {source.label}: {plan.main}; "
            f"overlay={plan.overlay or '-'}, xml={plan.whitelist or '-'}, "
            f"so={libraries}, system-files={system_files}",
            flush=True,
        )
        return plan

def smoke_install(plans: dict[str, Plan], staged: Path, tmp: Path) -> None:
    # The actual OS3 Bash installer runs with staged ZIPs and an isolated
    # stock-shaped tree. This checks package selection, system path mapping,
    # native libraries, XML/overlay placement and copied folder shape.
    image = tmp / "mock-images"
    archive_dir = tmp / "mock-extracted"
    cache = tmp / "mock-cache"
    stock = {
        "App Vault": "product/priv-app/MIUIPersonalAssistant/MIUIPersonalAssistant.apk",
        "ColorOS Control Center": "product/priv-app/MIUISystemUIPlugin/MIUISystemUIPlugin.apk",
        "Screenshot": "product/priv-app/MIUIScreenshot/MIUIScreenshot.apk",
        "Launcher": "product/priv-app/MiuiHome/MiuiHome.apk",
        "Theme Manager": "product/priv-app/MIUIThemeManager/MIUIThemeManager.apk",
    }
    archive_dir.mkdir(parents=True)
    for label, target in stock.items():
        plan = plans[label]
        out = image / target
        out.parent.mkdir(parents=True, exist_ok=True)
        with zipfile.ZipFile(plan.path) as archive:
            with archive.open(plan.main) as src, out.open("wb") as dst:
                shutil.copyfileobj(src, dst)
    env = dict(os.environ,
               KASHI_PREFLIGHT="1",
               OS3_IMAGES=str(image),
               OS3_MOD_CACHE=str(cache),
               OS3_KASHI_DIR=str(staged))
    stdout = run("bash", "bin/modfile/OS3/kashimod.sh", timeout=300, env=env)
    print("\n".join(stdout.splitlines()[-45:]), flush=True)

    # Check that the actual installer produced one installed APK per active
    # package, not merely that its shell process exited with code 0.
    apk_list = list(image.rglob("*.apk"))
    installed: dict[str, list[Path]] = {}
    for apk in apk_list:
        package = apk_package(apk)
        installed.setdefault(package, []).append(apk)
    for label, plan in plans.items():
        if plan.source.mode == "reference":
            continue
        actual = installed.get(plan.source.package, [])
        if len(actual) != 1:
            raise ValueError(f"[INTEGRATION FAILED] {label}: installed APKs={actual}")
    expected_packages = {
        plan.source.package for plan in plans.values()
        if plan.source.mode != "reference"
    }
    expected_packages.add("android.miui.home.launcher.res")
    unexpected = sorted(set(installed) - expected_packages)
    if unexpected:
        raise ValueError(
            "Unreviewed additional APK packages would be installed: "
            f"{unexpected}. Review the changed upstream overlay/app payload."
        )
    overlay_path = image / "product/overlay/MiuiHomeLauncherResOverlay.apk"
    whitelist_path = image / "product/etc/permissions/privapp_whitelist_com.miui.home.xml"
    if not overlay_path.is_file() or not whitelist_path.is_file():
        raise ValueError("Launcher: integrated overlay or privapp whitelist missing")
    if apk_package(overlay_path) != "android.miui.home.launcher.res":
        raise ValueError("Launcher: installed overlay has incorrect package")
    root = ET.parse(whitelist_path).getroot()
    if not any(
        node.tag.rsplit("}", 1)[-1] == "privapp-permissions"
        and node.attrib.get("package") == "com.miui.home"
        for node in root.iter()
    ):
        raise ValueError("Launcher: installed whitelist identity changed")
    print("[INTEGRATION OK] 5 active modules installed into isolated ROM tree; "
          "2 inactive reference ZIPs validated but not installed", flush=True)

def main() -> int:
    KASHI.mkdir(parents=True, exist_ok=True)
    prefixes = [s.prefix for s in SOURCES]
    if len(set(prefixes)) != len(prefixes):
        raise ValueError("Duplicate source prefix")
    old_zips = [p for p in KASHI.iterdir() if p.is_file() and p.suffix.lower() == ".zip"]
    unmapped = [p.name for p in old_zips if sum(p.name.startswith(s.prefix) for s in SOURCES) != 1]
    if unmapped:
        raise ValueError(f"Unmapped local Kashi ZIP(s): {unmapped}")
    print(f"[COVERAGE] {len(old_zips)} ZIPs; {len(SOURCES)} upstream sources", flush=True)
    rows = []
    updates = []
    with tempfile.TemporaryDirectory(prefix="kashi-transaction-") as temp:
        workspace = Path(temp)
        staged = workspace / "kashi"
        staged.mkdir()
        for old in old_zips:
            shutil.copy2(old, staged / old.name)
        plans: dict[str, Plan] = {}
        for source in SOURCES:
            existing = sorted(staged.glob(source.prefix + "*.zip"))
            if len(existing) != 1:
                raise ValueError(f"{source.label}: expected exactly one local snapshot, got {len(existing)}")
            old = existing[0]
            release = json.loads(run("gh", "api", f"repos/{source.repo}/releases/latest"))
            tag = release.get("tag_name", "")
            if release.get("draft") or release.get("prerelease") or not tag:
                raise ValueError(f"{source.repo}: stable latest release unavailable")
            zips = [a for a in release.get("assets", [])
                    if a["name"].lower().endswith(".zip")]
            if not zips:
                raise ValueError(f"{source.repo}: latest release {tag} has no ZIP")
            preferred = [a for a in zips if a["name"].startswith(source.prefix)]
            candidates = preferred if preferred else zips
            if len(candidates) > 8:
                raise ValueError(f"{source.repo}: too many candidate ZIPs; refusing to guess")
            valid = []
            rejected = []
            for asset in candidates:
                name = asset["name"]
                size = int(asset.get("size", 0))
                if (Path(name).name != name
                        or not re.fullmatch(r"[A-Za-z0-9._@+-]+\.zip", name)
                        or not 1024 <= size <= 95 * 1024 * 1024):
                    rejected.append(f"{name}: unsafe filename/size ({size})")
                    continue
                download_dir = workspace / f"download-{prefixes.index(source.prefix)}"
                download_dir.mkdir(exist_ok=True)
                try:
                    run("gh", "release", "download", tag, "--repo", source.repo,
                        "--pattern", name, "--dir", str(download_dir),
                        "--clobber", timeout=600)
                    downloaded = download_dir / name
                    if not downloaded.is_file() or downloaded.stat().st_size != size:
                        raise ValueError("downloaded ZIP size mismatch")
                    plan = inspect_archive(downloaded, source)
                    valid.append((asset, downloaded, plan))
                except (ValueError, RuntimeError, zipfile.BadZipFile) as exc:
                    rejected.append(f"{name}: {exc}")
            if len(valid) != 1:
                raise ValueError(
                    f"{source.repo} release {tag}: expected exactly one "
                    f"compatible ZIP, got {len(valid)}. "
                    f"Rejected: {rejected}; compatible: {[x[0]['name'] for x in valid]}"
                )
            asset, downloaded, _ = valid[0]
            filename = asset["name"]
            dest_name = filename if filename.startswith(source.prefix) else source.prefix + filename
            changed = not (old.name == dest_name and filecmp.cmp(old, downloaded, shallow=False))
            if changed:
                old.unlink()
                shutil.copy2(downloaded, staged / dest_name)
                updates.append((source, dest_name))
            current = staged / dest_name
            plans[source.label] = inspect_archive(current, source)
            rows.append((source.label, old.name, f"{tag} / {filename}",
                         "Validated update" if changed else "Unchanged"))
            print(f"[{'STAGED' if changed else 'UNCHANGED'}] {source.label}: {tag} -> {dest_name}",
                  flush=True)

        smoke_install(plans, staged, workspace)
        # Publish staged files only AFTER every upstream ZIP and the full
        # integration smoke test have passed. Failures leave git untouched.
        if updates:
            for old in old_zips:
                old.unlink()
            for new_zip in staged.glob("*.zip"):
                shutil.copy2(new_zip, KASHI / new_zip.name)

    summary = ["## Kashi newest-release and installer preflight", "",
               "| Module | Existing ZIP | Latest stable release | Result |",
               "|---|---|---|---|"]
    summary.extend(f"| {label} | {before} | {latest} | {result} |"
                   for label, before, latest, result in rows)
    summary += ["", "Verified: ZIP safety/CRC, package identity, system payload paths, "
                "Launcher overlay/permissions and real OS3 installer integration "
                "in an isolated mock ROM.", "",
                "**Device boot, signatures and runtime behavior are not established by this preflight.**"]
    text = "\n".join(summary) + "\n"
    if os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(os.environ["GITHUB_STEP_SUMMARY"], "a", encoding="utf-8") as report:
            report.write(text)
    if os.environ.get("GITHUB_OUTPUT"):
        with open(os.environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as outputs:
            outputs.write(f"changed={'true' if updates else 'false'}\n")
    print(f"Kashi: {len(updates)} verified update(s); "
          "all seven ZIPs and the OS3 integration smoke test passed")
    return 0

if __name__ == "__main__":
    try:
        sys.exit(main())
    except (RuntimeError, ValueError, OSError, zipfile.BadZipFile, ET.ParseError) as error:
        print(f"::error::Kashi preflight failed; repository ZIPs preserved: {error}",
              file=sys.stderr)
        sys.exit(1)
