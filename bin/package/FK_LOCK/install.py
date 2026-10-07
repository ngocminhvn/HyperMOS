#!/usr/bin/env python3
"""FK_LOCK: reinforce software lock-state after Android boot completion.

This stage deliberately preserves all extracted ROM fingerprints and product
identity properties. It only installs the runtime lock-state helper.
"""
from __future__ import annotations

import argparse
import hashlib
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

LOCK_PROPERTIES = {
    "ro.boot.flash.locked": "1",
    "ro.boot.vbmeta.device_state": "locked",
    "ro.boot.verifiedbootstate": "green",
    "ro.secureboot.lockstate": "locked",
}

DOMAIN = "fk_lock"
EXEC = DOMAIN + "_exec"
MARKER = "; HyperMOS FK_LOCK runtime"
PAYLOAD_BLOB = "dd58ca45deae0c2c0e9704d46d8c63adb061c473"


def select_context(name: str, files: list[Path]) -> str:
    matches = []
    for path in files:
        for raw in path.read_text(errors="ignore").splitlines():
            fields = raw.split("#", 1)[0].split()
            if len(fields) < 2 or not fields[1].startswith("u:object_r:"):
                continue
            key, context = fields[:2]
            exact = len(fields) > 2 and fields[2] == "exact"
            if (exact and name == key) or (not exact and (key == "*" or name.startswith(key))):
                score = (len(key) if key != "*" else 0, exact)
                matches.append((score, context.split(":")[2]))
    if not matches:
        raise ValueError(f"FK_LOCK: no property context found for {name}")
    best = max(score for score, _ in matches)
    types = {context for score, context in matches if score == best}
    if len(types) != 1:
        raise ValueError(f"FK_LOCK: conflicting property contexts for {name}: {types}")
    return types.pop()


def policy_block(property_types: set[str]) -> str:
    lines = [
        MARKER,
        f"(type {DOMAIN})",
        f"(roletype r {DOMAIN})",
        f"(typeattributeset domain ({DOMAIN}))",
        f"(typeattributeset coredomain ({DOMAIN}))",
        f"(type {EXEC})",
        f"(roletype object_r {EXEC})",
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


def policy_inputs(images: Path, candidate: Path) -> list[Path]:
    system = images / "system/system/etc/selinux"
    if not system.is_dir():
        system = images / "system/etc/selinux"
    vendor = images / "vendor/etc/selinux"

    version_file = vendor / "plat_sepolicy_vers.txt"
    if not version_file.is_file():
        raise ValueError("FK_LOCK: plat_sepolicy_vers.txt missing")
    version = version_file.read_text().strip()
    if not re.fullmatch(r"[0-9]+(?:\.[0-9]+)?", version):
        raise ValueError("FK_LOCK: invalid vendor policy mapping version")

    required = [
        system / "plat_sepolicy.cil",
        system / f"mapping/{version}.cil",
        vendor / "plat_pub_versioned.cil",
        vendor / "vendor_sepolicy.cil",
    ]
    for path in required:
        if not path.is_file():
            raise ValueError(f"FK_LOCK: missing policy input: {path}")

    inputs = required[:2]
    optional = [
        system / f"mapping/{version}.compat.cil",
        candidate,
        images / f"system_ext/etc/selinux/mapping/{version}.cil",
        images / f"system_ext/etc/selinux/mapping/{version}.compat.cil",
        images / "product/etc/selinux/product_sepolicy.cil",
        images / f"product/etc/selinux/mapping/{version}.cil",
        *required[2:],
        images / "odm/etc/selinux/odm_sepolicy.cil",
    ]
    inputs.extend(path for path in optional if path.is_file())

    genfs = vendor / "genfs_labels_version.txt"
    if genfs.is_file():
        genfs_version = genfs.read_text().strip()
        if not genfs_version.isdigit():
            raise ValueError("FK_LOCK: invalid vendor genfs labels version")
        genfs_policy = system / f"plat_sepolicy_genfs_{genfs_version}.cil"
        if genfs_policy.is_file():
            inputs.append(genfs_policy)
    return inputs


def replace_entry(path: Path, key: str, entry: str) -> None:
    old = path.read_text(errors="ignore") if path.is_file() else ""
    lines = [line for line in old.splitlines() if not line.split() or line.split()[0] != key]
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join([*lines, entry]) + "\n")


def init_rc() -> str:
    return """# HyperMOS FK_LOCK: runtime property view only; never relock hardware.
service fk_lock /system_ext/xbin/xeutoolbox -n -f /system_ext/etc/fk-lock.prop
    disabled
    oneshot
    user root
    group root
    seclabel u:r:fk_lock:s0
    timeout_period 5

on property:sys.boot_completed=1
    start fk_lock
"""


def install_runtime(workspace: Path, images: Path) -> None:
    package = workspace / "bin/package/FK_LOCK"
    payload = package / "system_ext/xbin/xeutoolbox"
    if not payload.is_file():
        raise ValueError("FK_LOCK: xeutoolbox payload missing")

    data = payload.read_bytes()
    blob = hashlib.sha1(f"blob {len(data)}\0".encode() + data).hexdigest()
    if blob != PAYLOAD_BLOB or data[:6] != b"\x7fELF\x02\x01" or int.from_bytes(data[18:20], "little") != 183:
        raise ValueError("FK_LOCK: pinned ARM64 xeutoolbox payload mismatch")

    policy = images / "system_ext/etc/selinux/system_ext_sepolicy.cil"
    if not policy.is_file():
        raise ValueError("FK_LOCK: system_ext_sepolicy.cil not found")
    original = policy.read_text()
    if MARKER in original:
        raise ValueError("FK_LOCK: already installed; rebuild from clean base images")

    compiler = shutil.which("secilc")
    if not compiler:
        raise ValueError("FK_LOCK: secilc is required")

    contexts = list(images.rglob("*_property_contexts"))
    property_types = {select_context(name, contexts) for name in LOCK_PROPERTIES}

    with tempfile.TemporaryDirectory(prefix="fk-lock-") as scratch:
        scratch_path = Path(scratch)
        candidate = scratch_path / "system_ext_sepolicy.cil"
        candidate.write_text(original.rstrip() + "\n\n" + policy_block(property_types))
        result = subprocess.run(
            [
                compiler, "-m", "-M", "true", "-G", "-N", "-c", "30",
                *map(str, policy_inputs(images, candidate)),
                "-o", str(scratch_path / "policy"),
                "-f", "/dev/null",
            ],
            capture_output=True,
            text=True,
        )
        if result.returncode:
            raise ValueError(f"FK_LOCK: split policy failed compilation:\n{result.stderr}")
        if not (scratch_path / "policy").is_file():
            raise ValueError("FK_LOCK: secilc produced no policy")
        new_policy = candidate.read_bytes()

    system_ext = images / "system_ext"

    target = system_ext / "xbin/xeutoolbox"
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(data)
    target.chmod(0o755)

    rc = system_ext / "etc/init/fk-lock.rc"
    rc.parent.mkdir(parents=True, exist_ok=True)
    rc.write_text(init_rc())
    rc.chmod(0o644)

    prop_file = system_ext / "etc/fk-lock.prop"
    prop_file.write_text("".join(f"{key}={value}\n" for key, value in LOCK_PROPERTIES.items()))
    prop_file.chmod(0o644)

    config = images / "config"
    replace_entry(
        config / "system_ext_file_contexts",
        "/system_ext/xbin/xeutoolbox",
        f"/system_ext/xbin/xeutoolbox u:object_r:{EXEC}:s0",
    )
    replace_entry(
        config / "system_ext_fs_config",
        "system_ext/xbin/xeutoolbox",
        "system_ext/xbin/xeutoolbox 0 0 0755",
    )
    replace_entry(
        config / "system_ext_fs_config",
        "system_ext/etc/init/fk-lock.rc",
        "system_ext/etc/init/fk-lock.rc 0 0 0644",
    )
    replace_entry(
        config / "system_ext_fs_config",
        "system_ext/etc/fk-lock.prop",
        "system_ext/etc/fk-lock.prop 0 0 0644",
    )

    on_device_fc = system_ext / "etc/selinux/system_ext_file_contexts"
    if on_device_fc.is_file():
        replace_entry(
            on_device_fc,
            "/system_ext/xbin/xeutoolbox",
            f"/system_ext/xbin/xeutoolbox u:object_r:{EXEC}:s0",
        )

    policy.write_bytes(new_policy)
    fingerprint_file = policy.parent / "system_ext_sepolicy_and_mapping.sha256"
    fingerprint_file.write_text(hashlib.sha256(new_policy).hexdigest() + "\n")

    for target_file in images.rglob("cust_prop_white_keys_list"):
        if not target_file.is_file():
            continue
        existing = set(target_file.read_text(errors="ignore").splitlines())
        with target_file.open("a") as out:
            for key in LOCK_PROPERTIES:
                if key not in existing:
                    out.write(key + "\n")

    print("[FK_LOCK] runtime installed: boot_completed only")
    print("[FK_LOCK] build fingerprints and product identity left untouched")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("workspace", type=Path)
    args = parser.parse_args()

    workspace = args.workspace.resolve()
    images = workspace / "build/baserom/images"
    if not images.is_dir():
        parser.exit(1, "ERROR: FK_LOCK: extracted images directory missing\n")

    try:
        install_runtime(workspace, images)
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        parser.exit(1, f"ERROR: {error}\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
