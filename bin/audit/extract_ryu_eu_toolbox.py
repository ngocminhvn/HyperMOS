#!/usr/bin/env python3
"""Forensic, read-only RYU-EU thermal extraction; never infer a live profile mapping."""
from __future__ import annotations

import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

from audit_xiaomi_eu_apps import call, filesystem, make_super, read_partition_names

PARTITIONS = ("system", "system_ext", "product", "mi_ext", "mi_product",
              "vendor", "odm", "vendor_dlkm", "odm_dlkm")
APP_PARTITIONS = set(PARTITIONS)
APKS = ("com.android.updater", "com.miui.packageinstaller",
        "com.projectryu.toolbox", "com.miui.powerkeeper", "com.miui.securitycenter")
JARS = ("framework.jar", "services.jar", "miui-framework.jar", "miui-services.jar")
REQUIRED_CONFIGS = (
    "thermal-map.conf", "thermal-normal.conf", "thermal-per-normal.conf",
    "thermal-hp-normal.conf", "thermal-cgame.conf", "thermal-mgame.conf",
    "thermal-nolimits.conf",
)
SETTINGS_KEYS = ("projectryu_thermal_profiles", "projectryu_thermal_sconfig",
                 "projectryu_thermal_per_app")
SYSFS_KEY = "/sys/class/thermal/thermal_message/sconfig"
TERMS = re.compile(
    r"thermal|thermald|thermalservice|therm_mgr|therm-engine|"
    r"therm[_-]?engine|sconfig|PerfHook|powerhint|power_hint|"
    r"projectryu_thermal|cooling|heat[_-]?mode|ThermalManager", re.I)
LIBRARY = re.compile(r"^(?:libthermal|libtherm|libpower|libperf).*\.so$|^libryu_core\.so$", re.I)
EXECUTABLE = re.compile(r"thermal-engine|thermald|thermalservice|mi_thermald|therm_mgr", re.I)
PACKAGE_LINE = re.compile(r"^package:\s+name='([^']+)'", re.M)
PATH_TOKEN = re.compile(r"/(?:vendor|odm|system_ext|system|product|mi_ext)/[A-Za-z0-9_./@+-]+")
SMALI_CONST = re.compile(r"\bconst(?:/4|/16|/high16)?\s+[vp]\d+,\s+(-?0x[0-9a-f]+|-?\d+)", re.I)
MAX_FILE = 256 * 1024 * 1024
MAX_REFERENCE_LINES = 3000


def hash_file(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def logical_parts(part: str, rel: Path) -> tuple[str, ...]:
    parts = rel.parts
    if parts and parts[0] == part:
        parts = parts[1:]
    return parts


def target_group(part: str, rel: Path, path: Path) -> str | None:
    parts = logical_parts(part, rel)
    if not parts:
        return None
    name = parts[-1].lower()
    lower = tuple(p.lower() for p in parts)
    if name in JARS and "framework" in lower:
        return "framework"
    if name.endswith(".ko") and TERMS.search(name) and part.endswith("_dlkm"):
        return "binaries"
    if name.endswith(".so") and LIBRARY.fullmatch(name) and any(
            p in lower for p in ("lib", "lib64", "hw")):
        return "libraries"
    if ("bin" in lower or "xbin" in lower or "hw" in lower) and EXECUTABLE.search(name):
        return "binaries"
    if name in ("build.prop", "default.prop") or (
            name.endswith(".prop") and TERMS.search(name)):
        return "properties"
    if len(parts) >= 3 and parts[0] == "etc" and parts[1] == "perf" and part in ("vendor", "odm"):
        return "perf"
    if name.endswith(".rc") and ("init" in lower or name.startswith("init")):
        # Capture all init RCs that reference relevant services or properties.
        if TERMS.search(rel.as_posix()) or file_contains(path, TERMS, 2 * 1024 * 1024):
            return "init-services"
    if "etc" in lower and (
            name.startswith(("thermal", "therm", "powerhint", "power_hint"))
            or "thermal" in lower or "thermald" in lower
            or name in REQUIRED_CONFIGS):
        return "thermal"
    if name.startswith(("thermal", "therm")) and name.endswith((
            ".conf", ".cfg", ".xml", ".json", ".ini", ".pb", ".prop", ".rc", ".txt")):
        return "thermal"
    return None


def file_contains(file: Path, pattern: re.Pattern, max_bytes: int) -> bool:
    if file.stat().st_size > max_bytes:
        return False
    return bool(pattern.search(file.read_text(errors="replace")))


def original_device_path(part: str, rel: Path) -> str:
    parts = logical_parts(part, rel)
    return "/" + part + "/" + "/".join(parts)


def keep_file(source: Path, out: Path, part: str, rel: Path,
              group: str, entries: list[dict], **extra) -> dict | None:
    if not source.is_file() or source.is_symlink():
        return None
    size = source.stat().st_size
    if size > MAX_FILE:
        raise RuntimeError("Required evidence too large: " + part + ":/" + rel.as_posix())
    if not size or rel.is_absolute() or ".." in rel.parts:
        return None
    # Keep true partition-relative path, even if an EROFS root contains a nested prefix.
    target = out / group / part / rel
    if target.exists():
        return next((e for e in entries if e["zip_path"] ==
                     target.relative_to(out).as_posix()), None)
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, target)
    row = {"group": group, "partition": part,
           "partition_relative_path": "/" + rel.as_posix(),
           "device_path_candidate": original_device_path(part, rel),
           "zip_path": target.relative_to(out).as_posix(),
           "bytes": size, "sha256": hash_file(target)}
    row.update(extra)
    entries.append(row)
    print("[SAVE]", row["zip_path"], size, flush=True)
    return row


def package_name(apk: Path) -> str | None:
    result = subprocess.run(["aapt", "dump", "badging", str(apk)],
                            text=True, capture_output=True, errors="replace",
                            check=False, timeout=40)
    m = PACKAGE_LINE.search(result.stdout)
    return m.group(1) if m else None


def scan_apks(root: Path, part: str, out: Path, entries: list[dict]):
    if part not in APP_PARTITIONS:
        return
    candidates = [p for p in root.rglob("*.apk") if p.is_file() and not p.is_symlink()
                  and any(x in ("app", "priv-app") for x in p.relative_to(root).parts[:-1])]
    # Name-first ordering speeds up typical ROMs without guessing package names.
    candidates.sort(key=lambda p: (not bool(re.search(
        r"updat|packageinstall|toolbox|projectryu|powerkeeper|securitycenter",
        str(p), re.I)), str(p)))
    for apk in candidates:
        pkg = package_name(apk)
        if pkg not in APKS:
            continue
        with zipfile.ZipFile(apk) as archive:
            if "AndroidManifest.xml" not in archive.namelist() or archive.testzip():
                raise RuntimeError("Original APK is corrupt: " + str(apk))
        keep_file(apk, out, part, apk.relative_to(root), "apks", entries,
                  package=pkg, verified_from="aapt AndroidManifest")


def scan_partition(root: Path, part: str, out: Path, entries: list[dict],
                   references: dict[str, list[dict]]):
    scan_apks(root, part, out, entries)
    # Preserve service-config paths exactly when referenced by init or text configuration.
    discovered: list[tuple[Path, Path, str]] = []
    for p in sorted(root.rglob("*")):
        if not p.is_file() or p.is_symlink():
            continue
        rel = p.relative_to(root)
        group = target_group(part, rel, p)
        if group:
            keep_file(p, out, part, rel, group, entries)
            discovered.append((p, rel, group))
    for p, rel, group in discovered:
        if group not in ("thermal", "perf", "init-services", "properties"):
            continue
        if p.stat().st_size > 4 * 1024 * 1024:
            continue
        try:
            lines = p.read_text(errors="replace").splitlines()
        except OSError:
            continue
        for idx, line in enumerate(lines, 1):
            # Paths may occur on continuation lines without the word "thermal".
            if TERMS.search(line) and len(references["config"]) < MAX_REFERENCE_LINES:
                references["config"].append({
                    "source": part + ":/" + rel.as_posix(),
                    "line": idx, "text": line[:500], "kind": group})
            for token in PATH_TOKEN.findall(line):
                token = token.rstrip(",:;)")
                # Capture configs/thermal binaries invoked from init; do not
                # archive unrelated /system/bin commands just because an RC cites them.
                if ("/etc/" not in token and
                        not EXECUTABLE.search(Path(token).name) and
                        not LIBRARY.fullmatch(Path(token).name)):
                    continue
                item = {"source": part + ":/" + rel.as_posix(),
                        "line": idx, "referenced_path": token}
                if item not in references["paths"]:
                    references["paths"].append(item)
    # Extract additional named files referenced by the discovered init/config lines.
    for ref in references["paths"]:
        token = ref["referenced_path"]
        if not token.startswith("/" + part + "/"):
            continue
        tail = Path(token[len(part) + 2:])
        if tail.is_absolute() or ".." in tail.parts:
            continue
        for candidate in (root / tail, root / part / tail):
            if candidate.is_file() and not candidate.is_symlink():
                keep_file(candidate, out, part, candidate.relative_to(root),
                          "init-services" if candidate.suffix == ".rc" else "thermal",
                          entries, referenced_from=ref["source"])
                break



def follow_cross_partition_refs(super_image: Path, names: set[str], lpunpack: Path,
                                work: Path, out: Path, entries: list[dict],
                                refs: dict, errors: list[str]):
    """Resolve paths declared by ROM init/config files, including cross-partition links.

    Operates on partition images sequentially, never bundles image bytes. A path
    mentioned by a file is evidence of a *reference*, not proof it was invoked.
    """
    for pass_number in range(2):
        archive_paths = {e["device_path_candidate"] for e in entries
                         if e.get("device_path_candidate")}
        wanted: dict[str, set[str]] = {}
        for item in refs["paths"]:
            token = item["referenced_path"]
            part = next((x for x in PARTITIONS if token.startswith("/" + x + "/")), None)
            if not part or token in archive_paths:
                continue
            wanted.setdefault(part, set()).add(token)
        if not wanted:
            break
        progress = 0
        for part, paths in wanted.items():
            selected = next((name for name in (part + "_a", part, part + "_b")
                             if name in names), None)
            if not selected:
                continue
            stage, scratch = work / "ref-partition", work / "ref-scratch"
            stage.mkdir(exist_ok=True)
            try:
                call(sys.executable, lpunpack, "-p", selected, super_image, stage)
                image = stage / (selected + ".img")
                root, _ = unpack(image, scratch)
                for token in sorted(paths):
                    rel = Path(token[len(part) + 2:])
                    if rel.is_absolute() or ".." in rel.parts:
                        continue
                    found = next((p for p in (root / rel, root / part / rel)
                                  if p.is_file() and not p.is_symlink()), None)
                    if not found:
                        continue
                    group = ("init-services" if found.suffix == ".rc" else
                             "libraries" if LIBRARY.fullmatch(found.name) else
                             "binaries" if EXECUTABLE.search(found.name) else "thermal")
                    row = keep_file(found, out, part, found.relative_to(root),
                                    group, entries,
                                    service_referenced=True)
                    if row:
                        progress += 1
                        if found.suffix.lower() in (".rc", ".conf", ".xml",
                                                    ".cfg", ".json", ".prop",
                                                    ".sh", ".txt"):
                            if found.stat().st_size <= 4 * 1024 * 1024:
                                for idx, line in enumerate(
                                        found.read_text(errors="replace").splitlines(), 1):
                                    for candidate in PATH_TOKEN.findall(line):
                                        candidate = candidate.rstrip(",:;)")
                                        if "/etc/" in candidate:
                                            item = {
                                                "source": row["partition"] + ":" +
                                                row["partition_relative_path"],
                                                "line": idx, "referenced_path": candidate}
                                            if item not in refs["paths"]:
                                                refs["paths"].append(item)
            finally:
                shutil.rmtree(stage, ignore_errors=True)
                shutil.rmtree(scratch, ignore_errors=True)
        if not progress:
            break
    captured = {e["device_path_candidate"] for e in entries
                if e.get("device_path_candidate")}
    for ref in refs["paths"]:
        ref["resolution"] = ("FOUND" if ref["referenced_path"] in captured
                             else "MISSING_OR_OUT_OF_SCOPE")
    unresolved = sorted({i["referenced_path"] for i in refs["paths"]
                         if i["resolution"] != "FOUND"})
    if unresolved:
        errors.append("Unresolved paths named by ROM init/config: " +
                      str(len(unresolved)) + "; see service-references.txt")

def unpack(image: Path, scratch: Path):
    root = scratch / "root"
    root.mkdir(parents=True)
    kind = filesystem(image)
    if kind == "erofs":
        call("fsck.erofs", "--extract=" + str(root), image)
    elif kind == "ext4":
        proc = subprocess.run(
            ["debugfs", "-R", "rdump / " + str(root), str(image)],
            text=True, capture_output=True, errors="replace", timeout=1200)
        if proc.returncode or not any(root.iterdir()):
            raise RuntimeError("debugfs ext4 extraction failed: " + proc.stderr[-1000:])
    else:
        raise RuntimeError("Unsupported filesystem type: " + kind)
    return root, kind


def extract_zip_thermal(source: Path, out: Path, entries: list[dict]):
    # Direct ROM ZIP may also have thermal scripts outside dynamic partitions.
    with zipfile.ZipFile(source) as archive:
        for info in archive.infolist():
            if (info.is_dir() or not TERMS.search(info.filename)
                    or not info.filename.lower().endswith((".rc", ".conf", ".xml", ".cfg", ".sh", ".prop", ".json"))
                    or info.file_size > MAX_FILE or info.filename.startswith("/")
                    or ".." in Path(info.filename).parts or "\\" in info.filename):
                continue
            target = out / "thermal" / "ROM_ZIP" / info.filename
            target.parent.mkdir(parents=True, exist_ok=True)
            with archive.open(info) as stream, target.open("wb") as dst:
                shutil.copyfileobj(stream, dst)
            entries.append({
                "group": "thermal", "partition": "ROM_ZIP",
                "partition_relative_path": info.filename, "device_path_candidate": None,
                "zip_path": target.relative_to(out).as_posix(),
                "bytes": target.stat().st_size, "sha256": hash_file(target)})


def append_hits(lines: list[str], origin: str, references: list[dict],
                limit: int = MAX_REFERENCE_LINES, radius: int = 8):
    method = ""
    for index, line in enumerate(lines):
        if line.lstrip().startswith(".method"):
            method = line.strip()
        if not TERMS.search(line):
            continue
        if len(references) >= limit:
            return
        start, stop = max(0, index - radius), min(len(lines), index + radius + 1)
        excerpt = "\n".join(f"{n + 1}: {lines[n]}" for n in range(start, stop))
        references.append({
            "source": origin, "line": index + 1, "method": method or None,
            "match": line[:450], "context": excerpt})


def smali_evidence(tree: Path, identity: str, results: list[dict]):
    for smali in sorted(tree.rglob("*.smali")):
        if len(results) >= MAX_REFERENCE_LINES:
            break
        append_hits(smali.read_text(errors="replace").splitlines(),
                    identity + "!/" + smali.relative_to(tree).as_posix(), results)


def scan_archive_strings(path: Path, identity: str, results: list[dict]):
    with zipfile.ZipFile(path) as z:
        members = [x for x in z.infolist() if x.filename.endswith(".dex")]
        for info in members:
            if info.file_size > MAX_FILE:
                continue
            data = z.read(info)
            # Raw ASCII scan yields leads only, not proof of a method call.
            candidates = sorted(set(
                m.group(0).decode("utf-8", errors="replace")
                for m in re.finditer(rb"[\x20-\x7e]{6,}", data)
                if TERMS.search(m.group(0).decode("utf-8", errors="replace"))))
            for item in candidates[:150]:
                if len(results) < MAX_REFERENCE_LINES:
                    results.append({
                        "source": identity + "!/" + info.filename,
                        "line": None, "method": None, "match": item[:450],
                        "context": "", "evidence_type": "DEX_string_only"})
    return [i.filename for i in members]


def scan_apk_internals(path: Path, row: dict, out: Path, entries: list[dict],
                       res_refs: list[dict]):
    with zipfile.ZipFile(path) as z:
        for info in z.infolist():
            name = info.filename
            if info.is_dir() or name.startswith("/") or ".." in Path(name).parts:
                continue
            is_dex = bool(re.fullmatch(r"classes\d*\.dex", Path(name).name))
            relevant = (is_dex or name.startswith(("assets/", "res/raw/"))
                        or name == "libryu_core.so" or name.endswith("/libryu_core.so"))
            if not relevant or info.file_size > MAX_FILE:
                continue
            # Preserve exact APK-contained bytes independently for analysis.
            embedded_lib = name == "libryu_core.so" or name.endswith("/libryu_core.so")
            folder = ("libraries/apk-embedded" if embedded_lib
                      else "analysis/toolbox-apk-internals")
            target = out / folder / row["partition"] / Path(row["partition_relative_path"].lstrip("/")) / name
            target.parent.mkdir(parents=True, exist_ok=True)
            with z.open(info) as inp, target.open("wb") as dst:
                shutil.copyfileobj(inp, dst)
            entries.append({
                "group": "libraries" if embedded_lib else "analysis",
                "partition": row["partition"],
                "partition_relative_path": row["partition_relative_path"],
                "device_path_candidate": row["device_path_candidate"],
                "zip_path": target.relative_to(out).as_posix(),
                "source_apk": row["zip_path"], "apk_member": name,
                "bytes": target.stat().st_size, "sha256": hash_file(target)})
            if name.startswith(("assets/", "res/raw/")) and info.file_size < 2 * 1024 * 1024:
                try:
                    lines = target.read_text(encoding="utf-8").splitlines()
                except (UnicodeDecodeError, OSError):
                    continue
                append_hits(lines, row["zip_path"] + "!/" + name, res_refs)


def decompile_apk(path: Path, identity: str, analysis_dir: Path,
                  smali_refs: list[dict], res_refs: list[dict], errors: list[str]):
    with tempfile.TemporaryDirectory(prefix="ryu-apk-") as tmp:
        target = Path(tmp) / "decoded"
        for args in ([], ["-r"]):
            proc = subprocess.run(
                ["java", "-Xmx3g", "-jar", "bin/apktool/apktool.jar", "d", "-f",
                 *args, "-o", str(target), str(path)],
                capture_output=True, text=True, errors="replace", timeout=600)
            if proc.returncode == 0:
                smali_evidence(target, identity, smali_refs)
                for path2 in sorted(target.rglob("*")):
                    if not path2.is_file() or path2.suffix.lower() not in (
                            ".xml", ".json", ".txt", ".conf", ".properties"):
                        continue
                    if path2.stat().st_size < 1024 * 1024 and len(res_refs) < MAX_REFERENCE_LINES:
                        append_hits(path2.read_text(errors="replace").splitlines(),
                                    identity + "!/" + path2.relative_to(target).as_posix(), res_refs)
                return
            errors.append(identity + ": apktool " + ("resources" if not args else "no-resources")
                          + " decode failed: " + proc.stderr[-700:])
            shutil.rmtree(target, ignore_errors=True)


def decompile_dex_archive(path: Path, identity: str,
                          refs: list[dict], errors: list[str]):
    with tempfile.TemporaryDirectory(prefix="ryu-baksmali-") as tmp:
        parent = Path(tmp)
        with zipfile.ZipFile(path) as z:
            dex_members = [i for i in z.infolist()
                           if re.fullmatch(r"classes\d*\.dex", Path(i.filename).name)]
            for no, member in enumerate(dex_members):
                if member.file_size > MAX_FILE:
                    errors.append(identity + ": oversized dex " + member.filename)
                    continue
                dex = parent / ("in-%d.dex" % no)
                with z.open(member) as src, dex.open("wb") as dst:
                    shutil.copyfileobj(src, dst)
                destination = parent / ("smali-%d" % no)
                try:
                    proc = subprocess.run([
                        "java", "-Xmx3g", "-jar", "bin/apktool/baksmali-3.0.5.jar",
                        "d", str(dex), "-o", str(destination)],
                        capture_output=True, text=True, errors="replace", timeout=240)
                    if proc.returncode:
                        errors.append(identity + ": baksmali failed for " +
                                      member.filename + ": " + proc.stderr[-700:])
                    else:
                        smali_evidence(destination, identity + "!/" + member.filename, refs)
                except (OSError, subprocess.TimeoutExpired) as ex:
                    errors.append(identity + ": baksmali " + member.filename + ": " + str(ex))
                finally:
                    dex.unlink(missing_ok=True)
                    shutil.rmtree(destination, ignore_errors=True)


def binary_leads(out: Path, entries: list[dict], references: list[dict], errors: list[str]):
    for row in entries:
        if row["group"] not in ("binaries", "libraries"):
            continue
        path = out / row["zip_path"]
        if path.stat().st_size > 100 * 1024 * 1024:
            errors.append("Binary string scan skipped (size): " + row["zip_path"])
            continue
        try:
            run = subprocess.run(["strings", "-a", "-n", "6", str(path)],
                                 capture_output=True, text=True, errors="replace",
                                 timeout=40)
            lines = run.stdout.splitlines()
            for idx, line in enumerate(lines):
                if TERMS.search(line) and len(references) < MAX_REFERENCE_LINES:
                    references.append({
                        "source": row["zip_path"], "line": idx + 1,
                        "text": line[:350], "evidence_type": "ELF_string_only"})
        except (OSError, subprocess.TimeoutExpired) as ex:
            errors.append("Binary scan: " + row["zip_path"] + ": " + str(ex))


def analyze(out: Path, entries: list[dict], refs: dict, errors: list[str]):
    code_refs: list[dict] = []
    resource_refs: list[dict] = []
    dex_refs: list[dict] = []
    frameworks: list[dict] = []
    watched = [e for e in entries if e["group"] in ("apks", "framework")]
    for row in watched:
        identity = row["zip_path"]
        path = out / identity
        pkg = row.get("package")
        try:
            dex_files = scan_archive_strings(path, identity, dex_refs)
            if pkg == "com.projectryu.toolbox":
                scan_apk_internals(path, row, out, entries, resource_refs)
                decompile_apk(path, identity, out / "analysis", code_refs, resource_refs, errors)
            elif pkg in ("com.miui.powerkeeper", "com.miui.securitycenter") or row["group"] == "framework":
                decompile_dex_archive(path, identity, code_refs, errors)
            frameworks.append({"source": identity, "dex_members": dex_files,
                               "decompilation_attempted": True})
        except (OSError, ValueError, zipfile.BadZipFile, subprocess.TimeoutExpired) as ex:
            errors.append("Static analysis " + identity + ": " + str(ex))
    binary_refs: list[dict] = list(refs["binary"])
    binary_leads(out, [e for e in entries if e.get("apk_member")
                       and e["group"] == "libraries"], binary_refs, errors)
    for label, collection in (
            ("SMALI", code_refs), ("resources", resource_refs),
            ("DEX", dex_refs), ("ELF", binary_refs)):
        if len(collection) >= MAX_REFERENCE_LINES:
            errors.append(label + " evidence hit extraction cap of " +
                          str(MAX_REFERENCE_LINES) + " (partial evidence)")
    refs["code"] = code_refs
    refs["resources"] = resource_refs
    refs["dex"] = dex_refs
    refs["binary"] = binary_refs
    refs["archives_scanned"] = frameworks


def possible_numeric_leads(refs: dict) -> list[dict]:
    candidates = []
    seen = set()
    for row in refs["code"]:
        if not re.search(r"sconfig|projectryu_thermal", row["context"], re.I):
            continue
        for m in SMALI_CONST.finditer(row["context"]):
            value = m.group(1)
            evidence = (row["source"], row["method"], value)
            if evidence in seen:
                continue
            seen.add(evidence)
            candidates.append({
                "value": value, "status": "candidate",
                "reason": "Constant near thermal/sconfig reference; register/control-flow unverified",
                "evidence": [{"source": row["source"], "line": row["line"],
                              "method": row["method"], "excerpt": row["context"][:1600]}]})
            if len(candidates) >= 60:
                return candidates
    return candidates



def find_config_mapping_leads(out: Path, entries: list[dict]) -> list[dict]:
    """Only quote literal mapping statements, never deduce indices from a filename."""
    leads = []
    for row in entries:
        if row["group"] not in ("thermal", "perf"):
            continue
        path = out / row["zip_path"]
        if (path.suffix.lower() not in (".conf", ".cfg", ".xml", ".json", ".txt", ".ini")
                or path.stat().st_size > 8 * 1024 * 1024):
            continue
        for line_no, line in enumerate(path.read_text(errors="replace").splitlines(), 1):
            if not re.search(r"thermal[-_][\w.-]+\.conf", line, re.I):
                continue
            evidence = {
                "source": row["partition"] + ":" + row["partition_relative_path"],
                "line": line_no, "exact_line": line[:500]}
            # Same-line mention is a lead only. Numeric values require
            # explicit sconfig syntax; never use a number inferred from the mode name.
            match = re.search(r"\bsconfig\s*[:= ]+\s*(0x[0-9a-f]+|\d+)", line, re.I)
            leads.append({
                "status": "candidate",
                "sconfig": match.group(1) if match else None,
                "configuration_names_mentioned": sorted(set(
                    re.findall(r"thermal[-_][\w.-]+\.conf", line, re.I))),
                "reason": "Config text co-occurrence, not proven applied by a running service",
                "evidence": [evidence]})
            if len(leads) >= 250:
                return leads
    return leads


def find_init_service_leads(out: Path, entries: list[dict]) -> list[dict]:
    candidates = []
    for row in entries:
        if row["group"] != "init-services":
            continue
        path = out / row["zip_path"]
        if path.stat().st_size > 4 * 1024 * 1024:
            continue
        lines = path.read_text(errors="replace").splitlines()
        for i, line in enumerate(lines):
            declaration = re.match(r"^\s*service\s+(\S+)\s+(\S+)(.*)$", line)
            if not declaration:
                continue
            next_service = next((j for j in range(i+1, len(lines)) if
                                 re.match(r"^(?:service|on)\s+", lines[j])), len(lines))
            block = lines[i:next_service]
            if not any(TERMS.search(x) for x in block):
                continue
            candidates.append({
                "status": "candidate", "service": declaration.group(1),
                "binary": declaration.group(2),
                "reason": "Init service declared in ROM; runtime execution / sconfig handling unverified",
                "evidence": [{"source": row["partition"] + ":" +
                              row["partition_relative_path"], "line": i + 1,
                              "excerpt": "\n".join(block[:35])[:3000]}]})
            if len(candidates) >= 200:
                return candidates
    return candidates


def write_analysis(out: Path, entries: list[dict], refs: dict,
                   scanned: list[dict], errors: list[str]) -> dict:
    directory = out / "analysis"
    directory.mkdir(parents=True, exist_ok=True)
    file_lookup = {}
    for name in REQUIRED_CONFIGS:
        hits = [e for e in entries if e["group"] in ("thermal", "perf")
                and Path(e["partition_relative_path"]).name.lower() == name]
        file_lookup[name] = {
            "status": "FOUND" if hits else "MISSING",
            "original_paths": [
                e["partition"] + ":" + e["partition_relative_path"] for e in hits],
            "zip_paths": [e["zip_path"] for e in hits],
        }
    def format_hits(items: list[dict]) -> str:
        chunks = []
        for e in items:
            chunks.append(
                "SOURCE: " + e["source"] + "\n" +
                ("METHOD: " + str(e.get("method")) + "\n" if e.get("method") else "") +
                ("LINE: " + str(e.get("line")) + "\n" if e.get("line") else "") +
                (e.get("context") or e.get("text") or e.get("match") or "") + "\n")
        return "\n---\n".join(chunks) or "NO STATIC REFERENCES FOUND\n"
    (directory / "toolbox-thermal-references.txt").write_text(
        "# SMALI reference excerpts, APK resources, and DEX leads (all static)\n" +
        format_hits(refs["code"] + refs["resources"] + refs["dex"]), encoding="utf-8")
    config_refs = [
        {"source": r["source"], "line": r["line"], "text": r["text"]}
        for r in refs["config"]]
    service_text = [
        "# Init/config excerpts\n",
        format_hits(config_refs),
        "\n# Referenced absolute device paths (not automatically validated)\n",
        json.dumps(refs["paths"], indent=2, ensure_ascii=False),
        "\n# ELF string leads (not evidence of service execution)\n",
        format_hits(refs["binary"]),
    ]
    (directory / "service-references.txt").write_text(
        "\n".join(service_text), encoding="utf-8")
    mapping_leads = find_config_mapping_leads(out, entries)
    service_leads = find_init_service_leads(out, entries)
    ui_candidates = [
        {"source": r["source"], "line": r["line"], "excerpt": r["context"][:600]}
        for r in refs["resources"]
        if re.search(r"thermal|sconfig|profile|balanced|performance|game", r["match"], re.I)
    ][:100]
    mapping = {
        "schema_version": 2,
        "assessment": "static analysis only",
        "mapping_status": "unknown",
        "confirmation_rule": (
            "confirmed requires a traced UI selection -> Settings/IPC/sysfs write -> "
            "service interpretation -> profile config and runtime state evidence; "
            "filenames and code/binary strings alone never confirm a mapping"),
        "watched_settings": {key: {"status": "unknown", "runtime_test_required": True}
                             for key in SETTINGS_KEYS},
        "watched_sysfs": {SYSFS_KEY: {"status": "unknown", "runtime_test_required": True}},
        "required_config_files": file_lookup,
        "ui_choices": [],
        "ui_label_leads": ui_candidates,
        "init_declared_service_candidates": service_leads,
        "sconfig_value_leads": possible_numeric_leads(refs),
        "profile_mappings": mapping_leads,
        "actual_cpu_gpu_limit_changes": {"status": "unknown", "runtime_test_required": True},
        "per_app_application": {"status": "unknown", "runtime_test_required": True},
        "default_restore": {"status": "unknown", "runtime_test_required": True},
        "service_receiver": {"status": "unknown", "runtime_test_required": True,
                             "candidates": service_leads},
        "static_evidence_counts": {k: len(refs[k]) for k in (
            "code", "resources", "dex", "config", "paths", "binary")},
        "runtime_test_guidance": [
            "Read-only snapshots before/after EACH Toolbox UI choice.",
            "settings get system/global/secure projectryu_thermal_profiles",
            "settings get system/global/secure projectryu_thermal_sconfig",
            "settings get system/global/secure projectryu_thermal_per_app",
            "cat /sys/class/thermal/thermal_message/sconfig (only if node exists)",
            "dumpsys thermalservice; getprop | grep -i thermal",
            "Record CPU cpufreq and GPU devfreq policy readouts before/after.",
            "Repeat with per-app selection, app foreground/background, and reboot.",
            "Compare service logs and init service state; no write operations required."
        ],
    }
    (directory / "profile-mapping.json").write_text(
        json.dumps(mapping, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    lines = [
        "# RYU EU thermal map and service evidence", "",
        "**Status: static analysis; runtime mapping is not confirmed.**", "",
        "## Required configuration names (real ZIP scan)", "",
        "| Filename | Status | Original locations |",
        "| --- | --- | --- |",
    ]
    for name, hit in file_lookup.items():
        lines.append("| " + name + " | " + hit["status"] + " | " +
                     (", ".join(hit["original_paths"]) or "—") + " |")
    lines += [
        "", "## Package & framework discovery", "",
        "| Requested item | Status | Source |",
        "| --- | --- | --- |",
    ]
    for pkg in APKS:
        hits = [e for e in entries if e.get("package") == pkg]
        lines.append("| " + pkg + " | " + ("FOUND" if hits else "MISSING") + " | " +
                     (", ".join(e["partition"] + ":" + e["partition_relative_path"]
                                for e in hits) or "—") + " |")
    for name in JARS:
        hits = [e for e in entries if e["group"] == "framework"
                and Path(e["partition_relative_path"]).name == name]
        lines.append("| " + name + " | " + ("FOUND" if hits else "MISSING") + " | " +
                     (", ".join(e["partition"] + ":" + e["partition_relative_path"]
                                for e in hits) or "—") + " |")
    lines += [
        "", "## Investigation", "",
        "Partitions scanned: " + ", ".join(e["image"] for e in scanned),
        "Files preserved unchanged: " + str(len(entries)),
        "Static SMALI excerpts: " + str(len(refs["code"])),
        "Resource leads: " + str(len(refs["resources"])),
        "DEX-only string leads: " + str(len(refs["dex"])),
        "Init/config matched lines: " + str(len(refs["config"])),
        "Service/binary string leads: " + str(len(refs["binary"])),
        "Init service declarations (candidates): " + str(len(service_leads)),
        "Literal config mapping leads (candidates): " + str(len(mapping_leads)),
        "", "Related files are collected because of their actual paths/content; "
        "collection is not proof that Toolbox calls them.",
        "The UI -> sconfig -> file -> service mapping remains **unknown** until "
        "control-flow evidence and, if necessary, read-only runtime comparisons.",
        "See profile-mapping.json for candidate constants and all required runtime tests.",
        "", "## Unresolved/static analysis warnings", "",
    ]
    lines += ["- " + error for error in errors] or ["- None recorded"]
    (directory / "thermal-map-report.md").write_text(
        "\n".join(lines) + "\n", encoding="utf-8")
    return mapping


def validate_original_files(out: Path, entries: list[dict]):
    for row in entries:
        path = out / row["zip_path"]
        if path.stat().st_size != row["bytes"] or hash_file(path) != row["sha256"]:
            raise RuntimeError("Checksum or size mismatch: " + row["zip_path"])



def self_test():
    """Lightweight fixture test, before downloading multi-GB ROM in CI."""
    with tempfile.TemporaryDirectory(prefix="ryu-thermal-test-") as tmp:
        home = Path(tmp)
        root, out = home / "vendor-files", home / "out"
        (root / "etc" / "perf").mkdir(parents=True)
        (root / "etc" / "init").mkdir(parents=True)
        (root / "bin").mkdir(parents=True)
        (root / "etc" / "thermal-map.conf").write_text(
            "sconfig=2 profile=thermal-normal.conf\n", encoding="utf-8")
        (root / "etc" / "thermal-normal.conf").write_text(
            "sensor=cpu-therm\n", encoding="utf-8")
        (root / "etc" / "perf" / "profile.json").write_text(
            '{"hint":"ryu"}\n', encoding="utf-8")
        (root / "etc" / "init" / "init.vendor.thermal.rc").write_text(
            "service mi_thermald /vendor/bin/mi_thermald\n"
            "    class main\n"
            "    --config /vendor/etc/thermal-normal.conf\n", encoding="utf-8")
        (root / "bin" / "mi_thermald").write_bytes(b"\x7fELFtest\n")
        entries: list[dict] = []
        refs: dict = {"code": [], "resources": [], "dex": [], "config": [],
                      "paths": [], "binary": [], "archives_scanned": []}
        scan_partition(root, "vendor", out, entries, refs)
        saved = {row["zip_path"] for row in entries}
        assert "thermal/vendor/etc/thermal-map.conf" in saved
        assert "thermal/vendor/etc/thermal-normal.conf" in saved
        assert "perf/vendor/etc/perf/profile.json" in saved
        assert "init-services/vendor/etc/init/init.vendor.thermal.rc" in saved
        assert "binaries/vendor/bin/mi_thermald" in saved
        assert any(e["referenced_path"] == "/vendor/etc/thermal-normal.conf"
                   for e in refs["paths"])
        append_hits([
            ".method public choose()V", "const/4 v0, 0x2",
            'const-string v1, "projectryu_thermal_sconfig"',
            ".end method"], "toolbox!/smali/X.smali", refs["code"])
        result = write_analysis(out, entries, refs, [], [])
        assert result["required_config_files"]["thermal-map.conf"]["status"] == "FOUND"
        assert result["required_config_files"]["thermal-hp-normal.conf"]["status"] == "MISSING"
        assert result["profile_mappings"][0]["status"] == "candidate"
        assert result["mapping_status"] == "unknown"
        assert result["init_declared_service_candidates"][0]["service"] == "mi_thermald"
        assert (out / "analysis" / "profile-mapping.json").is_file()
        validate_original_files(out, entries)
    print("[SELFTEST] thermal/config/perf/binary/init classification & evidence: PASS", flush=True)


def main(rom: Path, work: Path, lpunpack: Path):
    out = work / "output"
    out.mkdir(parents=True, exist_ok=True)
    entries: list[dict] = []
    refs: dict = {"code": [], "resources": [], "dex": [], "config": [],
                  "paths": [], "binary": [], "archives_scanned": []}
    errors: list[str] = []
    extract_zip_thermal(rom, out, entries)
    super_image = make_super(rom, work)
    names = read_partition_names(super_image, lpunpack.resolve())
    scanned: list[dict] = []
    try:
        for part in PARTITIONS:
            selected = next((x for x in (part + "_a", part, part + "_b") if x in names), None)
            if selected is None:
                errors.append("Partition not present in super: " + part)
                continue
            stage = work / "partition"
            scratch = work / "scratch"
            stage.mkdir(exist_ok=True)
            try:
                call(sys.executable, lpunpack, "-p", selected, super_image, stage)
                image = stage / (selected + ".img")
                if not image.is_file() or not image.stat().st_size:
                    raise RuntimeError("Unpacked partition missing: " + selected)
                root, kind = unpack(image, scratch)
                scan_partition(root, part, out, entries, refs)
                scanned.append({"image": selected, "partition": part, "filesystem": kind})
            except (OSError, RuntimeError, subprocess.CalledProcessError) as exc:
                errors.append("Partition extraction incomplete: " + selected + ": " + str(exc))
                print("::warning::Partition extraction incomplete: " + selected +
                      ": " + str(exc), flush=True)
            finally:
                shutil.rmtree(stage, ignore_errors=True)
                shutil.rmtree(scratch, ignore_errors=True)
        # Native thermal services may reference configs using literal paths.
        # Preserve these leads and follow them before discarding super.img.
        binary_leads(out, entries, refs["binary"], errors)
        for hit in refs["binary"]:
            for candidate in PATH_TOKEN.findall(hit["text"]):
                candidate = candidate.rstrip(",:;)")
                if "/etc/" not in candidate:
                    continue
                item = {"source": hit["source"], "line": hit["line"],
                        "referenced_path": candidate,
                        "evidence_type": "ELF_string_only"}
                if item not in refs["paths"]:
                    refs["paths"].append(item)
        follow_cross_partition_refs(super_image, names, lpunpack, work, out,
                                    entries, refs, errors)
    finally:
        super_image.unlink(missing_ok=True)
    analyze(out, entries, refs, errors)
    mapping = write_analysis(out, entries, refs, scanned, errors)
    validate_original_files(out, entries)
    packages_found = sorted({e.get("package") for e in entries if e.get("package")})
    missing = sorted(set(APKS) - set(packages_found))
    manifest = {
        "source_url": os.environ.get("ROM_URL", ""),
        "original_files_unmodified": True,
        "partitions_scanned": scanned,
        "requested_packages": list(APKS), "packages_found": packages_found,
        "packages_missing": missing, "framework_requested": list(JARS),
        "mapping_status": mapping["mapping_status"],
        "analysis_warnings": errors,
        "files": sorted(entries, key=lambda e: e["zip_path"])}
    (out / "manifest.json").write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    (out / "SHA256SUMS.txt").write_text(
        "".join(e["sha256"] + "  " + e["zip_path"] + "\n"
                for e in sorted(entries, key=lambda x: x["zip_path"])), encoding="utf-8")
    archive = out / "RYU-Thermal-Analysis.zip"
    with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED,
                         compresslevel=4, allowZip64=True) as z:
        for folder in ("apks", "framework", "thermal/odm", "thermal/vendor",
                       "perf", "binaries", "libraries", "init-services",
                       "properties", "analysis"):
            z.writestr(folder + "/", "")
        for file in sorted(out.rglob("*")):
            if file.is_file() and not file.is_symlink() and file != archive:
                z.write(file, file.relative_to(out).as_posix())
    with zipfile.ZipFile(archive) as z:
        if z.testzip() is not None:
            raise RuntimeError("Artifact ZIP checksum test failed")
        if "analysis/profile-mapping.json" not in z.namelist():
            raise RuntimeError("Incomplete analysis ZIP")
    print((out / "analysis" / "thermal-map-report.md").read_text(), flush=True)
    print("[ZIP]", archive, archive.stat().st_size, flush=True)
    if missing:
        print("::warning::Missing requested packages: " + ", ".join(missing), flush=True)


if __name__ == "__main__":
    if sys.argv[1:] == ["--self-test"]:
        self_test()
        sys.exit(0)
    if len(sys.argv) != 4:
        raise SystemExit("Usage: extract_ryu_eu_toolbox.py ROM.zip WORKDIR bin/lpunpack.py")
    try:
        main(Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve(),
             Path(sys.argv[3]).resolve())
    except (OSError, ValueError, RuntimeError, zipfile.BadZipFile,
            subprocess.CalledProcessError) as exc:
        raise SystemExit("[RYU THERMAL EXTRACTION ERROR] " + str(exc))
