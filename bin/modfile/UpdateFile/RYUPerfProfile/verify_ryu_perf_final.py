#!/usr/bin/env python3
"""Fail closed if any verified RYU performance/CPU/thermal profile was overwritten.

Read-only verification of final staging after all MOS mods and framework patches.
SHA256 equality verifies the actual imported RYU configuration bytes; it does
not claim the kernel or PowerKeeper applies every value at runtime.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parent


def load(name: str):
    spec = importlib.util.spec_from_file_location(name, ROOT / (name + ".py"))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def digest(file: Path) -> str:
    return hashlib.sha256(file.read_bytes()).hexdigest()


def cpu_related_xml(file: Path):
    """Summarize RYU-provided CPU/scheduler/boost nodes without inventing caps."""
    root = ET.parse(file).getroot()
    terms = ("cpu", "freq", "cluster", "sched", "boost", "governor", "core", "policy")
    found = []
    for e in root.iter():
        parts = [e.tag, *e.attrib.keys(), *e.attrib.values()]
        if any(t in str(value).lower() for value in parts for t in terms):
            found.append({
                "tag": e.tag, "attributes": e.attrib,
                "text": (e.text or "").strip()[:160],
            })
    return found[:75]


def verify(images: Path, report_path: Path):
    perf = load("port_ryu_perf")
    thermal = load("port_ryu_thermal_profiles")
    perf_log = images.parent / "ryu-test-perf-manifest.json"
    thermal_log = images.parent / "ryu-test-thermal-profiles.json"
    if not perf_log.is_file() or not thermal_log.is_file():
        raise ValueError("Missing RYU installation audit: performance/thermal port did not run")

    perf_entries = json.loads(perf_log.read_text(encoding="utf-8"))
    thermal_data = json.loads(thermal_log.read_text(encoding="utf-8"))
    if len(perf_entries) != len(perf.EXPECTED):
        raise ValueError("Incomplete RYU powerhint/perf installation record")
    if {row["file"] for row in perf_entries} != set(perf.EXPECTED):
        raise ValueError("Unexpected RYU perf installation list")

    cpu_nodes = {}
    for row in perf_entries:
        rel = row["file"]
        expected = perf.EXPECTED[rel]
        file = images / rel
        if not file.is_file() or file.is_symlink():
            raise ValueError("RYU perf file missing or symlink: " + rel)
        if digest(file) != expected or row["ryu_sha256"] != expected:
            raise ValueError("RYU CPU/powerhint/perf config overwritten: " + rel)
        cpu_nodes[rel] = cpu_related_xml(file)

    installed = thermal_data.get("installed")
    if not isinstance(installed, list):
        raise ValueError("Missing RYU ODM thermal installation records")
    names = set()
    for row in installed:
        rel = row["file"]
        if not rel.startswith("odm/etc/thermal-") or not rel.endswith(".conf"):
            raise ValueError("Unexpected thermal profile destination " + rel)
        suffix = rel[len("odm/etc/thermal-"):-len(".conf")]
        if suffix not in thermal.PROFILES or suffix in thermal.PROTECTED:
            raise ValueError("Unexpected/protected RYU thermal profile " + rel)
        if suffix in names:
            raise ValueError("Duplicate thermal profile " + rel)
        names.add(suffix)
        file = images / rel
        if not file.is_file() or file.is_symlink():
            raise ValueError("Missing thermal profile " + rel)
        if digest(file) != row["ryu_sha256"]:
            raise ValueError("RYU thermal profile overwritten " + rel)
    if not thermal.REQUIRED <= names:
        raise ValueError("Missing required RYU thermal profiles " + repr(thermal.REQUIRED - names))

    # Verify no downstream module changed the charging/emergency/no-limits
    # profiles originally present when RYU profiles were imported.
    before = thermal_data.get("protected_stock_sha256", {})
    for rel, old_hash in before.items():
        file = images / rel
        if not file.is_file() or digest(file) != old_hash:
            raise ValueError("Protected Xiaomi thermal safety file changed: " + rel)

    report = {
        "mode": "RYU exact CPU/perf/powerhint + application-facing thermal profiles",
        "powerkeeper": "Xiaomi stock, no DEX patch",
        "perf_xml_verified": sorted(perf.EXPECTED),
        "ryu_thermal_profiles_verified": sorted(names),
        "stock_safety_profiles_unchanged": sorted(before),
        "ryu_cpu_related_xml_nodes": cpu_nodes,
        "runtime_kernel_frequency_caps_verified": False,
        "note": "CPU frequency/boost requests come from RYU XML. Kernel decisions require runtime verification.",
    }
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n",
                           encoding="utf-8")
    print("[RYU FINAL] PASS:", len(perf_entries), "verified powerhint/perf XMLs;",
          len(names), "thermal ODM profiles;", len(before), "protected safety files unchanged")
    print("[RYU FINAL] All RYU CPU/boost/powerhint configuration bytes survived later MOS patches")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--images", required=True, type=Path)
    parser.add_argument("--report", required=True, type=Path)
    args = parser.parse_args()
    verify(args.images, args.report)
