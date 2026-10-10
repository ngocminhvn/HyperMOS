#!/usr/bin/env python3
"""RYU-derived scroll boost eco patch for Xiaomi 15 Pro.

Only change CPU6 ceilings for scroll hint 4224 in Balanced (Target1) and
Power (Target2), at 35/37 C. Never raise an existing value. Leave Performance,
launch hints, thermal service, battery/charger and GPU configurations untouched.

Reference: RYUOS_HAOTIAN_OS3.0.309.0.WOBCNXM_CN261005.zip
  vendor/etc/perf/thermalbreakboostconfig.xml
  SHA256 7e5fbfc12305b5425b85710ebe70083e57a40843eaa4c5f3423182d66061765f
  The values below are its Target2 for Hint=4224, Scence=0/1.
This is a HyperMOS Balanced-mode adaptation, NOT an unchanged RYU profile.
"""
import argparse
import os
from pathlib import Path
import re
import sys
import tempfile
import xml.etree.ElementTree as ET

# milliCelsius trigger -> RYU Power (Target2) cpu6 maximum in kHz
CAPS = {35000: 3072000, 37000: 2438400}
SCENES = {"0", "1"}
CONFIG_RE = re.compile(r"<Config\b[^>]*>.*?</Config\s*>", re.S)
CHILD_RE = re.compile(r"<Child\b[^>]*?/\s*>", re.S)
ATTR_RE = re.compile(r'(\b(?:Target1|Target2)=")([^"]*)(")')
CPU6_RE = re.compile(r"(\bcpu6:)(\d+)\b")


def attr(tag, name):
    found = re.search(r'\b' + re.escape(name) + r'="([^"]*)"', tag)
    return found.group(1) if found else None


def patch(source):
    # Validate the source before touching the ROM, preserve its original bytes/layout
    # by editing only the specific attributes rather than rewriting the XML tree.
    ET.fromstring(source)
    modified = []
    matched_scenes = set()

    def config_cb(match):
        block = match.group()
        opening = block[:block.index(">") + 1]
        if attr(opening, "Hint") != "4224" or attr(opening, "Scence") not in SCENES:
            return block
        scene = attr(opening, "Scence")
        if scene in matched_scenes:
            raise ValueError("Duplicate RYU-compatible scroll scene " + scene)
        matched_scenes.add(scene)
        trigs_seen = set()

        def child_cb(child_match):
            tag = child_match.group()
            trigger_text = attr(tag, "Trig")
            if trigger_text is None or not trigger_text.isdigit():
                return tag
            trig = int(trigger_text)
            if trig not in CAPS:
                return tag
            if trig in trigs_seen:
                raise ValueError(f"Duplicate trigger {trig} in scene {scene}")
            trigs_seen.add(trig)

            def target_cb(atr_match):
                name, old_value, close = atr_match.groups()
                original = CPU6_RE.search(old_value)
                if not original:
                    raise ValueError(f"Missing cpu6 in {name} scene={scene} trigger={trig}")
                old_cpu6 = int(original.group(2))
                # Never increase stock's CPU6 ceiling (including Power mode).
                new_cpu6 = min(old_cpu6, CAPS[trig])
                if new_cpu6 == old_cpu6:
                    return atr_match.group()
                changed = CPU6_RE.sub(
                    lambda m: m.group(1) + str(new_cpu6), old_value, count=1)
                modified.append((scene, trig, name[:-2], old_cpu6, new_cpu6))
                return name + changed + close

            found_names = set(re.findall(r'\b(Target[12])="', tag))
            if found_names != {"Target1", "Target2"}:
                raise ValueError(f"Missing Target1/Target2 scene={scene} trigger={trig}")
            return ATTR_RE.sub(target_cb, tag)

        result = CHILD_RE.sub(child_cb, block)
        if trigs_seen != set(CAPS):
            raise ValueError(f"Scene {scene} missing scroll triggers: {set(CAPS)-trigs_seen}")
        return result

    out = CONFIG_RE.sub(config_cb, source)
    if "0" not in matched_scenes:
        raise ValueError("Hint=4224 Scence=0 scroll profile missing")
    ET.fromstring(out)
    return out, modified


def self_test():
    fixture = '''<?xml version="1.0"?>
<BoostConfigs><PerfBreak>
<Config Hint="4225" Scence="0"><Child Trig="35000" Target0="cpu6:4089600" Target1="cpu6:4089600" Target2="cpu6:4089600"/></Config>
<Config Hint="4224" Scence="0">
  <Child Trig="35000" Target0="boost:1 cpu0:2784000 cpu6:4089600" Target1="boost:1 cpu0:2784000 cpu6:4089600" Target2="boost:1 cpu0:2784000 cpu6:4089600"/>
  <Child Trig="37000" Target0="cpu6:2649600" Target1="cpu6:2649600" Target2="cpu6:2000000"/>
  <Child Trig="39000" Target0="cpu6:2246400" Target1="cpu6:2246400" Target2="cpu6:2246400"/>
</Config></PerfBreak></BoostConfigs>'''
    changed, details = patch(fixture)
    root = ET.fromstring(changed)
    launch = root.find(".//Config[@Hint='4225']/Child")
    assert launch.get("Target1") == "cpu6:4089600"
    childs = root.findall(".//Config[@Hint='4224']/Child")
    assert "cpu6:3072000" in childs[0].get("Target1")
    assert "cpu6:3072000" in childs[0].get("Target2")
    assert "cpu6:4089600" in childs[0].get("Target0")
    assert "cpu6:2438400" in childs[1].get("Target1")
    assert "cpu6:2000000" in childs[1].get("Target2")
    assert "cpu6:2246400" in childs[2].get("Target1")
    assert len(details) == 3, details
    rerun, changes = patch(changed)
    assert rerun == changed and not changes, "patch must be idempotent"
    print("[RYU ECO] self-test PASS: conservative scroll cap; no launch or hot-path changes")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--file", type=Path)
    ap.add_argument("--self-test", action="store_true")
    args = ap.parse_args()
    if args.self_test:
        self_test()
        return
    if not args.file or not args.file.is_file():
        ap.error("Existing HAOTIAN vendor/etc/perf/thermalbreakboostconfig.xml required")
    original = args.file.read_bytes()
    try:
        source = original.decode("utf-8")
        result, changes = patch(source)
    except (UnicodeDecodeError, ET.ParseError, ValueError) as exc:
        raise SystemExit("[RYU ECO] unsupported vendor profile; original left unchanged: " + str(exc))
    if not changes:
        print("[RYU ECO] compatible profile already at/below RYU power caps; no change")
        return
    # Atomic replacement, preserving existing filesystem permissions.
    fd, temp = tempfile.mkstemp(prefix=".ryu-scroll-", dir=str(args.file.parent))
    try:
        with os.fdopen(fd, "wb") as file:
            file.write(result.encode("utf-8"))
        os.chmod(temp, args.file.stat().st_mode & 0o777)
        os.replace(temp, args.file)
    finally:
        if os.path.exists(temp):
            os.unlink(temp)
    for scene, trig, name, old, new in changes:
        print(f"[RYU ECO] scroll scene={scene} {trig/1000:g}C {name} cpu6: {old} -> {new} kHz")


if __name__ == "__main__":
    main()
