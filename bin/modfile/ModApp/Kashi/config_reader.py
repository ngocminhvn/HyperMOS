#!/usr/bin/env python3
"""
JSON / JSONC Configuration Reader for Kashi Mods in HyperMOS.
"""
import sys
import os
import json
import re

def load_config():
    dir_path = os.path.dirname(os.path.abspath(__file__))
    json_path = os.path.join(dir_path, "kashi.json")
    if not os.path.isfile(json_path):
        json_path = os.path.join(dir_path, "kashi.jsonc")
        if not os.path.isfile(json_path):
            return {}

    with open(json_path, "r", encoding="utf-8") as f:
        text = f.read()

    # Strip single line comments // ...
    text = re.sub(r"//.*", "", text)
    # Strip multi-line comments /* ... */
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.DOTALL)

    return json.loads(text)

def main():
    if len(sys.argv) < 2:
        sys.exit(1)

    cmd = sys.argv[1]
    cfg = load_config()

    if cmd == "get_zip_dir":
        print(cfg.get("zip_dir", "bin/modfile/ModApp/Kashi/Zip"))
        return

    if cmd == "is_enabled":
        if len(sys.argv) < 4:
            print("0")
            return
        mod_key = sys.argv[2]
        rom_os = sys.argv[3].lower()  # "os3" or "os4"
        mod_info = cfg.get("mods", {}).get(mod_key, {})
        key = f"{rom_os}_china"
        enabled = mod_info.get(key, mod_info.get("enabled", True))
        print("1" if enabled else "0")
        return

    if cmd == "get_zip":
        if len(sys.argv) < 4:
            print("")
            return
        mod_key = sys.argv[2]
        rom_os = sys.argv[3].lower()  # "os3" or "os4"
        mod_info = cfg.get("mods", {}).get(mod_key, {})
        # Check OS specific zip first (e.g. selected_zip_os4), then selected_zip
        os_key = f"selected_zip_{rom_os}"
        selected = mod_info.get(os_key, mod_info.get("selected_zip", ""))
        print(selected)
        return

if __name__ == "__main__":
    main()
