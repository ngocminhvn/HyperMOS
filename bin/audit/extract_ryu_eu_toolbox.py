#!/usr/bin/env python3
"""Extract original RYU-EU apps and audit Toolbox thermal references (read-only)."""
from __future__ import annotations

import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path

from audit_xiaomi_eu_apps import call, filesystem, make_super, read_partition_names

TARGETS = (
    "com.android.updater",
    "com.miui.packageinstaller",
    "com.projectryu.toolbox",
)
PARTITIONS = ("product", "system_ext", "system", "mi_ext", "mi_product",
              "vendor", "odm", "vendor_dlkm", "odm_dlkm")
APP_PARTITIONS = set(PARTITIONS[:5])
THERMAL_RX = re.compile(r"thermal|thermald|therm_mgr|therm-engine|cooling", re.I)
SMALI_RX = re.compile(
    r"thermal|thermald|therm_mgr|cooling|/sys/class/thermal|"
    r"persist\.[A-Za-z0-9._-]*therm|vendor\.[A-Za-z0-9._-]*therm|"
    r"heat[_-]?mode|temperature", re.I)
PKG_RX = re.compile(r"^package:\s+name='([^']+)'", re.M)
MAX_THERMAL_FILE = 16 * 1024 * 1024
MAX_THERMAL_TOTAL = 160 * 1024 * 1024


def digest(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def is_app_path(path: Path) -> bool:
    return any(segment in ("app", "priv-app") for segment in path.parts[:-1])


def package_name(apk: Path) -> str | None:
    run = subprocess.run(["aapt", "dump", "badging", str(apk)],
                         capture_output=True, text=True, errors="replace",
                         timeout=35, check=False)
    result = PKG_RX.search(run.stdout)
    return result.group(1) if result else None


def record_file(source: Path, output: Path, group: str, part: str,
                relative: Path, entries: list[dict], extra: dict | None = None):
    if source.is_symlink() or not source.is_file() or not source.stat().st_size:
        return
    if ".." in relative.parts or relative.is_absolute():
        raise RuntimeError("Unsafe partition path: " + str(relative))
    destination = output / group / part / relative
    if destination.exists():
        return
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, destination)
    item = {
        "category": group, "partition": part,
        "original_path": "/" + relative.as_posix(),
        "zip_path": destination.relative_to(output).as_posix(),
        "bytes": destination.stat().st_size,
        "sha256": digest(destination),
    }
    if extra:
        item.update(extra)
    entries.append(item)
    print("[COPY]", item["zip_path"], flush=True)


def scan_apps(root: Path, part: str, output: Path, entries: list[dict]):
    apks = [p for p in root.rglob("*.apk")
            if p.is_file() and not p.is_symlink()
            and is_app_path(p.relative_to(root))]
    # The first pass is fast; the second catches renamed/obfuscated APK filenames.
    guessed = [p for p in apks if re.search(
        r"updat|packageinstall|toolbox|projectryu|ryutool", str(p), re.I)]
    checked: set[Path] = set()
    found = {e["package"] for e in entries if e["category"] == "apks"}
    for group in (guessed, apks):
        if group is apks and found == set(TARGETS):
            break
        for apk in group:
            if apk in checked:
                continue
            checked.add(apk)
            pkg = package_name(apk)
            if pkg not in TARGETS:
                continue
            rel = apk.relative_to(root)
            # Verify the APK container before preserving unmodified bytes.
            with zipfile.ZipFile(apk) as z:
                if "AndroidManifest.xml" not in z.namelist() or z.testzip():
                    raise RuntimeError("Invalid original APK: " + str(apk))
            record_file(apk, output, "apks", part, rel, entries,
                        {"package": pkg, "apk_role": "identified_by_manifest"})
            found.add(pkg)
        if found == set(TARGETS):
            break


def thermal_candidate(path: Path, root: Path) -> bool:
    rel = path.relative_to(root)
    if path.is_symlink() or not path.is_file():
        return False
    if path.stat().st_size > MAX_THERMAL_FILE or path.stat().st_size == 0:
        return False
    allowed = {".conf", ".cfg", ".xml", ".json", ".ini", ".rc",
               ".txt", ".sh", ".prop", ".bin", ".pb"}
    if path.suffix.lower() not in allowed:
        return False
    if THERMAL_RX.search(rel.as_posix()):
        return True
    # Some vendor init services have generic names but launch thermal daemons.
    if path.suffix.lower() in (".rc", ".sh") and path.stat().st_size < 512000:
        if "init" in rel.parts or "etc" in rel.parts:
            try:
                return bool(THERMAL_RX.search(path.read_text(errors="replace")))
            except OSError:
                return False
    return False


def scan_thermal(root: Path, part: str, output: Path, entries: list[dict],
                 bytes_copied: list[int]):
    for file in root.rglob("*"):
        if not thermal_candidate(file, root):
            continue
        size = file.stat().st_size
        if bytes_copied[0] + size > MAX_THERMAL_TOTAL:
            raise RuntimeError("Thermal evidence exceeds bounded 160 MiB archive limit")
        count = len(entries)
        record_file(file, output, "thermal", part, file.relative_to(root),
                    entries, {"relation": "ROM_thermal_candidate"})
        if len(entries) != count:
            bytes_copied[0] += size


def unpack_partition(image: Path, scratch: Path):
    root = scratch / "root"
    root.mkdir(parents=True, exist_ok=True)
    kind = filesystem(image)
    print("[FILESYSTEM]", image.name, kind, flush=True)
    if kind == "erofs":
        call("fsck.erofs", "--extract=" + str(root), image)
    elif kind == "ext4":
        # Slower fallback; RYU-EU HAOTIAN is usually EROFS.
        run = subprocess.run(["debugfs", "-R", "rdump / " + str(root), str(image)],
                             capture_output=True, text=True, check=False, timeout=1200)
        if run.returncode != 0:
            raise RuntimeError("debugfs rdump failed: " + run.stderr[-1000:])
        if not any(root.iterdir()):
            raise RuntimeError("debugfs returned an empty directory")
    else:
        raise RuntimeError("Unsupported filesystem: " + kind)
    return root, kind


def scan_zip_thermal(rom: Path, output: Path, entries: list[dict]):
    """Capture thermal scripts directly shipped next to super.img, if any."""
    with zipfile.ZipFile(rom) as archive:
        for info in archive.infolist():
            name = info.filename
            if (info.is_dir() or info.file_size > MAX_THERMAL_FILE
                    or not THERMAL_RX.search(name)
                    or not name.lower().endswith((".conf", ".xml", ".sh", ".rc", ".prop", ".json"))
                    or name.startswith("/") or ".." in Path(name).parts):
                continue
            dest = output / "rom-thermal" / name
            dest.parent.mkdir(parents=True, exist_ok=True)
            with archive.open(info) as src, dest.open("wb") as dst:
                shutil.copyfileobj(src, dst)
            entries.append({"category": "rom-thermal", "partition": "ROM_ZIP",
                            "original_path": name, "zip_path": dest.relative_to(output).as_posix(),
                            "bytes": dest.stat().st_size, "sha256": digest(dest),
                            "relation": "ROM_thermal_candidate"})


def toolbox_analysis(output: Path, entries: list[dict]):
    analysis = output / "analysis"
    analysis.mkdir(parents=True, exist_ok=True)
    matches = [e for e in entries if e.get("package") == "com.projectryu.toolbox"]
    report = {"decompile_success": False, "toolbox_apks": [e["zip_path"] for e in matches],
              "static_thermal_references": [], "smali_files_with_matches": [],
              "error": None}
    if not matches:
        report["error"] = "Toolbox package not found; thermal files are only candidates."
        return report
    source = output / matches[0]["zip_path"]
    destination = analysis / "apktool-decode"
    try:
        run = subprocess.run(
            ["java", "-Xmx3g", "-jar", "bin/apktool/apktool.jar", "d", "-f",
             "-r", "-o", str(destination), str(source)],
            capture_output=True, text=True, errors="replace", timeout=600, check=False)
        report["decompile_success"] = run.returncode == 0
        (analysis / "apktool-log.txt").write_text(
            (run.stdout + "\n" + run.stderr)[-60000:], encoding="utf-8")
        if not report["decompile_success"]:
            report["error"] = "apktool exit code " + str(run.returncode)
    except (OSError, subprocess.TimeoutExpired) as exc:
        report["error"] = str(exc)
    references: list[dict] = []
    evidence_lines: list[str] = []
    # Preserve only relevant excerpts, not the entire reconstructed APK.
    for smali in sorted(destination.rglob("*.smali")) if destination.exists() else []:
        method = ""
        lines = smali.read_text(errors="replace").splitlines()
        found_in_file = 0
        for idx, line in enumerate(lines):
            if line.lstrip().startswith(".method"):
                method = line.strip()
            if not SMALI_RX.search(line):
                continue
            if len(references) >= 500:
                break
            snippet = "\n".join(lines[max(0, idx - 2):min(len(lines), idx + 3)])
            item = {"class_file": str(smali.relative_to(destination)),
                    "method": method, "line": idx + 1, "instruction": line.strip()}
            references.append(item)
            evidence_lines.append("FILE: " + item["class_file"] + "\n"
                                  + "METHOD: " + method + "\n" + snippet + "\n")
            found_in_file += 1
        if found_in_file:
            report["smali_files_with_matches"].append(str(smali.relative_to(destination)))
    # APK resource and assets can contain non-Dex thermal scripts/configuration.
    for member in sorted(source.parent.glob("*.apk")):
        try:
            with zipfile.ZipFile(member) as z:
                for info in z.infolist():
                    if info.is_dir() or info.file_size > 2 * 1024 * 1024:
                        continue
                    if re.search(r"thermal|cooling|thermald", info.filename, re.I):
                        references.append({"asset": info.filename, "instruction": "APK asset path"})
                    if info.filename.startswith(("assets/", "res/raw/")):
                        data = z.read(info)
                        try:
                            decoded = data.decode("utf-8")
                        except UnicodeDecodeError:
                            continue
                        for index, line in enumerate(decoded.splitlines(), 1):
                            if SMALI_RX.search(line) and len(references) < 500:
                                references.append({"asset": info.filename,
                                                   "line": index,
                                                   "instruction": line[:500]})
        except zipfile.BadZipFile:
            pass
    report["static_thermal_references"] = references
    (analysis / "toolbox-thermal-smali-excerpts.txt").write_text(
        "\n---\n".join(evidence_lines) + "\n", encoding="utf-8")
    shutil.rmtree(destination, ignore_errors=True)
    return report


def classify(entries: list[dict], analysis: dict):
    lines = [ref.get("instruction", "").lower()
             for ref in analysis["static_thermal_references"]]
    for entry in entries:
        if entry["category"] not in ("thermal", "rom-thermal"):
            continue
        full = entry["original_path"].lower()
        basename = Path(full).name
        # A concrete constant pointing to this config name is evidence of a link.
        concrete = [line for line in lines if (full in line or
                    (len(basename) >= 8 and basename in line))]
        entry["relation"] = ("referenced_in_toolbox_static_code" if concrete
                             else "ROM_thermal_candidate_not_proven_used_by_toolbox")
        if concrete:
            entry["matched_code_lines"] = concrete[:8]


def main(rom: Path, work: Path, lpunpack: Path):
    output = work / "output"
    output.mkdir(parents=True, exist_ok=True)
    entries: list[dict] = []
    scan_zip_thermal(rom, output, entries)
    super_image = make_super(rom, work)
    names = read_partition_names(super_image, lpunpack.resolve())
    scanned = []
    total_thermal = [0]
    try:
        for part in PARTITIONS:
            selected = next((candidate for candidate in (part + "_a", part, part + "_b")
                             if candidate in names), None)
            if not selected:
                continue
            stage = work / "partition"
            scratch = work / "scratch"
            stage.mkdir(exist_ok=True)
            try:
                call(sys.executable, lpunpack, "-p", selected, super_image, stage)
                image = stage / (selected + ".img")
                if not image.is_file() or not image.stat().st_size:
                    raise RuntimeError("Missing partition image " + selected)
                root, kind = unpack_partition(image, scratch)
                if part in APP_PARTITIONS:
                    scan_apps(root, part, output, entries)
                scan_thermal(root, part, output, entries, total_thermal)
                scanned.append({"partition": part, "image": selected, "filesystem": kind})
            finally:
                shutil.rmtree(stage, ignore_errors=True)
                shutil.rmtree(scratch, ignore_errors=True)
    finally:
        super_image.unlink(missing_ok=True)
    analysis = toolbox_analysis(output, entries)
    classify(entries, analysis)
    present = sorted({e["package"] for e in entries if e["category"] == "apks"})
    missing = sorted(set(TARGETS) - set(present))
    manifest = {
        "source_url": os.environ.get("ROM_URL", ""),
        "preserved_original_bytes": True,
        "target_packages": list(TARGETS),
        "packages_found": present,
        "packages_missing": missing,
        "partitions_scanned": scanned,
        "thermal_static_analysis": analysis,
        "files": sorted(entries, key=lambda e: e["zip_path"]),
        "qualification": ("Static references only; runtime mode switching may be mediated "
                          "by system services, props, native libraries or root scripts."),
    }
    (output / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    originals = sorted(entries, key=lambda e: e["zip_path"])
    (output / "SHA256SUMS.txt").write_text(
        "".join(e["sha256"] + "  " + e["zip_path"] + "\n" for e in originals),
        encoding="utf-8")
    lines = [
        "# RYU-EU Updater / PackageInstaller / Toolbox thermal audit", "",
        "Source ROM: " + os.environ.get("ROM_URL", ""),
        "Source APKs and thermal files preserved byte-for-byte (no resigning).", "",
        "## Requested packages", "",
        "| Package | Status | Original partition and path |",
        "| --- | --- | --- |",
    ]
    for pkg in TARGETS:
        hits = [e for e in entries if e.get("package") == pkg]
        paths = "; ".join(e["partition"] + ":" + e["original_path"] for e in hits) or "—"
        lines.append("| " + pkg + " | " + ("FOUND" if hits else "MISSING") + " | " + paths + " |")
    related = [e for e in entries if e["category"] in ("thermal", "rom-thermal")]
    confirmed = [e for e in related if e["relation"] == "referenced_in_toolbox_static_code"]
    lines.extend([
        "", "## Toolbox thermal evidence", "",
        "apktool decode: " + ("PASS" if analysis["decompile_success"] else
                            "FAILED / INCOMPLETE: " + str(analysis["error"])),
        "Static matching instructions/assets: " + str(len(analysis["static_thermal_references"])),
        "Thermal files directly named in Toolbox static references: " + str(len(confirmed)),
        "Other thermal files retained for inspection: " + str(len(related) - len(confirmed)),
        "",
        "| Relation | Original file |",
        "| --- | --- |",
    ])
    for e in related:
        lines.append("| " + ("STATIC REFERENCE" if e in confirmed else "CANDIDATE") +
                     " | " + e["partition"] + ":" + e["original_path"] + " |")
    lines.extend([
        "", "Static matching does NOT establish that a mode is actively used.",
        "If no references match, inspect analysis/toolbox-thermal-smali-excerpts.txt and "
        "manifest.json; a service or a script outside these partitions may own thermal switching.",
        "Missing packages or unresolved paths are never invented.",
    ])
    report = "\n".join(lines) + "\n"
    (output / "report.md").write_text(report, encoding="utf-8")
    zip_path = output / "ryu-eu-updater-installer-toolbox-thermal.zip"
    with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED,
                         compresslevel=4, allowZip64=True) as archive:
        for file in sorted(output.rglob("*")):
            if file.is_file() and not file.is_symlink() and file != zip_path:
                archive.write(file, file.relative_to(output).as_posix())
    with zipfile.ZipFile(zip_path) as archive:
        corrupted = archive.testzip()
        if corrupted:
            raise RuntimeError("Output ZIP corruption: " + corrupted)
    print(report, flush=True)
    print("[ZIP]", zip_path, zip_path.stat().st_size, "bytes", flush=True)
    if missing:
        raise RuntimeError("Requested APK(s) not found: " + ", ".join(missing))


if __name__ == "__main__":
    if len(sys.argv) != 4:
        raise SystemExit("Usage: extract_ryu_eu_toolbox.py ROM.zip WORKDIR bin/lpunpack.py")
    try:
        main(Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve(),
             Path(sys.argv[3]).resolve())
    except (OSError, ValueError, RuntimeError, zipfile.BadZipFile,
            subprocess.CalledProcessError) as exc:
        raise SystemExit("[RYU EU THERMAL AUDIT ERROR] " + str(exc))
