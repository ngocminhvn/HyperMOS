#!/usr/bin/env python3
"""Install late-boot fake-lock services only after split SELinux policy compiles."""
from __future__ import annotations

import argparse
import hashlib
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

PROPERTIES = {
    "ro.boot.flash.locked": "1",
    "ro.boot.vbmeta.device_state": "locked",
    "ro.boot.verifiedbootstate": "green",
    "ro.boot.veritymode": "enforcing",
    "ro.secureboot.lockstate": "locked",
    "sys.oem_unlock_allowed": "0",
    "ro.oem_unlock_supported": "0",
}
DOMAIN = "hypermos_fake_lock"
EXEC = DOMAIN + "_exec"
MARKER = "; HyperMOS Fake Lock v3"
PAYLOAD_BLOB = "dd58ca45deae0c2c0e9704d46d8c63adb061c473"


def select_context(name: str, files: list[Path]) -> str:
    matches = []
    for path in files:
        for raw in path.read_text().splitlines():
            fields = raw.split("#", 1)[0].split()
            if len(fields) < 2 or not fields[1].startswith("u:object_r:"):
                continue
            key, context = fields[:2]
            exact = len(fields) > 2 and fields[2] == "exact"
            if (exact and name == key) or (not exact and (key == "*" or name.startswith(key))):
                score = (len(key) if key != "*" else 0, exact)
                matches.append((score, context.split(":")[2]))
    if not matches:
        raise ValueError(f"No property context found for {name}")
    best = max(score for score, _ in matches)
    types = {context for score, context in matches if score == best}
    if len(types) != 1:
        raise ValueError(f"Conflicting property contexts for {name}: {types}")
    return types.pop()


def policy_block(property_types: set[str]) -> str:
    # CIL uses semicolon comments. Never execute a child in init's own domain.
    lines = [
        MARKER, f"(type {DOMAIN})", f"(roletype r {DOMAIN})",
        f"(typeattributeset domain ({DOMAIN}))",
        f"(typeattributeset coredomain ({DOMAIN}))",
        f"(type {EXEC})", f"(roletype object_r {EXEC})",
        f"(typeattributeset file_type ({EXEC}))",
        f"(typeattributeset exec_type ({EXEC}))",
        f"(typeattributeset system_file_type ({EXEC}))",
        f"(allow init {DOMAIN} (process (transition)))",
        f"(allow {DOMAIN} init (process (sigchld)))",
        f"(allow init {EXEC} (file (read open getattr execute map)))",
        f"(allow {DOMAIN} {EXEC} (file (read open getattr execute map entrypoint)))",
        f"(allow {DOMAIN} properties_device (dir (search read open getattr)))",
        f"(allow {DOMAIN} property_info (file (read open getattr map)))",
        f"(allow {DOMAIN} properties_serial (file (read write open getattr map)))",
        f"(allow {DOMAIN} system_file (dir (search getattr)))",
        f"(allow {DOMAIN} system_file (file (read open getattr map)))",
        f"(allow {DOMAIN} system_lib_file (file (read open getattr execute map)))",
    ]
    for kind in sorted(property_types):
        lines.append(f"(allow {DOMAIN} {kind} (file (read write open getattr map)))")
    return "\n".join(lines) + "\n"


def init_rc() -> str:
    commands = [
        f"    exec u:r:{DOMAIN}:s0 root root -- /system_ext/xbin/xeutoolbox -n {key} {value}"
        for key, value in PROPERTIES.items()
    ]
    lines = [
        "# HyperMOS Fake Lock: runtime properties only; never relock hardware.",
        "# Early pass follows BEACHEAD/Xiaomi resetprop timing so apps do not cache unlocked state.",
        "on post-fs-data",
        *commands,
        "",
        "# Reinforce once more after Xiaomi services finish booting; no intentional delay.",
        "on property:sys.boot_completed=1",
        *commands,
    ]
    return "\n".join(lines) + "\n"


def policy_inputs(images: Path, candidate: Path) -> list[Path]:
    system = images / "system/system/etc/selinux"
    if not system.is_dir():
        system = images / "system/etc/selinux"
    vendor = images / "vendor/etc/selinux"
    version = (vendor / "plat_sepolicy_vers.txt").read_text().strip()
    if not re.fullmatch(r"[0-9]+(?:\.[0-9]+)?", version):
        raise ValueError("Invalid vendor policy mapping version")
    required = [system / "plat_sepolicy.cil", system / f"mapping/{version}.cil",
                vendor / "plat_pub_versioned.cil", vendor / "vendor_sepolicy.cil"]
    for path in required:
        if not path.is_file():
            raise ValueError(f"Missing policy input: {path}")
    inputs = required[:2]
    for path in [system / f"mapping/{version}.compat.cil", candidate,
                 images / f"system_ext/etc/selinux/mapping/{version}.cil",
                 images / f"system_ext/etc/selinux/mapping/{version}.compat.cil",
                 images / "product/etc/selinux/product_sepolicy.cil",
                 images / f"product/etc/selinux/mapping/{version}.cil", *required[2:],
                 images / "odm/etc/selinux/odm_sepolicy.cil"]:
        if path.is_file():
            inputs.append(path)
    genfs = vendor / "genfs_labels_version.txt"
    if genfs.is_file():
        genfs_version = genfs.read_text().strip()
        if not genfs_version.isdigit():
            raise ValueError("Invalid vendor genfs labels version")
        genfs_policy = system / f"plat_sepolicy_genfs_{genfs_version}.cil"
        if genfs_policy.is_file():
            inputs.append(genfs_policy)
    return inputs


def replace_entry(path: Path, key: str, entry: str) -> None:
    old = path.read_text() if path.is_file() else ""
    lines = [line for line in old.splitlines() if not line.split() or line.split()[0] != key]
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join([*lines, entry]) + "\n")


def inject_xiaomi_prop_whitelist(images: Path) -> int:
    """Expose spoofed boot/unlock keys through Xiaomi's custom-property whitelist."""
    count = 0
    for path in images.rglob("cust_prop_white_keys_list"):
        old = path.read_text(errors="ignore").splitlines()
        existing = {line.strip() for line in old if line.strip()}
        additions = [name for name in PROPERTIES if name not in existing]
        if not additions:
            continue
        path.write_text("\n".join([*old, *additions]) + "\n")
        count += 1
    return count


def install(workspace: Path) -> None:
    images = workspace / "build/baserom/images"
    package = workspace / "bin/package/ResetProp"
    payload = package / "system_ext/xbin/xeutoolbox"
    data = payload.read_bytes()
    blob = hashlib.sha1(f"blob {len(data)}\0".encode() + data).hexdigest()
    if blob != PAYLOAD_BLOB or data[:6] != b"\x7fELF\x02\x01" or int.from_bytes(data[18:20], "little") != 183:
        raise ValueError("Fake Lock requires the pinned ARM64 xeutoolbox payload")
    policy = images / "system_ext/etc/selinux/system_ext_sepolicy.cil"
    original = policy.read_text()
    if MARKER in original:
        raise ValueError("Fake Lock already installed; rebuild from clean ROM input")
    compiler = shutil.which("secilc")
    if not compiler:
        raise ValueError("secilc is required to validate Fake Lock before installing it")
    contexts = list(images.rglob("*_property_contexts"))
    types = {select_context(name, contexts) for name in PROPERTIES}
    with tempfile.TemporaryDirectory(prefix="hypermos-fake-lock-") as scratch:
        candidate = Path(scratch) / "system_ext_sepolicy.cil"
        candidate.write_text(original.rstrip() + "\n\n" + policy_block(types))
        inputs = policy_inputs(images, candidate)
        # Match Android init's split-policy compile options, including -N.
        result = subprocess.run([compiler, "-m", "-M", "true", "-G", "-N", "-c", "30",
                                 *map(str, inputs), "-o", str(Path(scratch) / "policy"),
                                 "-f", "/dev/null"], capture_output=True, text=True)
        if result.returncode:
            raise ValueError(f"Fake Lock split policy failed compilation:\n{result.stderr}")
        if not (Path(scratch) / "policy").is_file():
            raise ValueError("secilc did not produce a compiled policy")
        new_policy = candidate.read_bytes()
    target = images / "system_ext/xbin/xeutoolbox"
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(data)
    target.chmod(0o755)
    rc = images / "system_ext/etc/init/hypermos-fake-lock.rc"
    rc.parent.mkdir(parents=True, exist_ok=True)
    rc.write_text(init_rc())
    rc.chmod(0o644)
    config = images / "config"
    replace_entry(config / "system_ext_file_contexts", "/system_ext/xbin/xeutoolbox",
                  f"/system_ext/xbin/xeutoolbox u:object_r:{EXEC}:s0")
    replace_entry(config / "system_ext_fs_config", "system_ext/xbin/xeutoolbox",
                  "system_ext/xbin/xeutoolbox 0 0 0755")
    replace_entry(config / "system_ext_fs_config", "system_ext/etc/init/hypermos-fake-lock.rc",
                  "system_ext/etc/init/hypermos-fake-lock.rc 0 0 0644")
    whitelist_count = inject_xiaomi_prop_whitelist(images)
    policy.write_bytes(new_policy)
    # Change the platform-side fingerprint so stock vendor precompiled policy
    # cannot conceal the new domain. Android init will compile the checked CIL.
    fingerprint = hashlib.sha256(new_policy).hexdigest()
    (policy.parent / "system_ext_sepolicy_and_mapping.sha256").write_text(fingerprint + "\n")
    print(
        "Fake Lock: split policy compiled; early post-fs-data + boot-complete resetprop installed; "
        f"{len(PROPERTIES)} properties, {whitelist_count} Xiaomi whitelist file(s) updated"
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("workspace", type=Path)
    args = parser.parse_args()
    try:
        install(args.workspace.resolve())
    except (ValueError, OSError) as error:
        parser.exit(1, f"ERROR: {error}\n")
