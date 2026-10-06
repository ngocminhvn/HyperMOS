#!/usr/bin/env python3
"""FK_LOCK: normalize visible ROM identity and reinforce FakeLock after boot.

Build-time identity normalization is limited to system/system_ext/product.
Vendor/odm fingerprints are intentionally preserved because Xiaomi may ship
those partitions from an older Android base.

The runtime component reinforces the software lock-state properties after
Android reports boot completion. It never relocks the hardware bootloader.
"""
from __future__ import annotations

import argparse
import hashlib
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

PARTITIONS = ("system", "system_ext", "product")
SUSPICIOUS = re.compile(r"(?:^|[/_.:-])(missi|miproduct|qssi|generic|mainline)(?:$|[/_.:-])", re.I)

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


def parse_prop_file(path: Path) -> dict[str, str]:
    result: dict[str, str] = {}
    if not path.is_file():
        return result
    for raw in path.read_text(errors="ignore").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        result[key.strip()] = value.strip()
    return result


def all_build_props(images: Path) -> list[Path]:
    return sorted(p for p in images.rglob("build.prop") if p.is_file())


def partition_props(images: Path, partition: str) -> list[Path]:
    root = images / partition
    if not root.is_dir():
        return []
    return sorted(p for p in root.rglob("build.prop") if p.is_file())


def first_value(paths: list[Path], keys: tuple[str, ...]) -> str:
    for key in keys:
        for path in paths:
            value = parse_prop_file(path).get(key, "")
            if value:
                return value
    return ""


def canonical_prop_file(images: Path, partition: str) -> Path:
    root = images / partition
    candidates = [
        root / "build.prop",
        root / "etc/build.prop",
    ]
    if partition == "system":
        candidates.insert(0, root / "system/build.prop")
    for candidate in candidates:
        if candidate.is_file():
            return candidate
    found = partition_props(images, partition)
    if found:
        return found[0]
    raise ValueError(f"FK_LOCK: no build.prop found for {partition}")


def set_key_in_file(path: Path, key: str, value: str) -> bool:
    text = path.read_text(errors="ignore")
    lines = text.splitlines()
    changed = False
    found = False
    out: list[str] = []
    for line in lines:
        stripped = line.strip()
        if stripped.startswith(key + "="):
            found = True
            replacement = f"{key}={value}"
            if line != replacement:
                changed = True
            out.append(replacement)
        else:
            out.append(line)
    if not found:
        out.append(f"{key}={value}")
        changed = True
    if changed:
        path.write_text("\n".join(out) + "\n")
    return changed


def set_property_everywhere(images: Path, key: str, value: str, preferred_partition: str) -> int:
    touched = 0
    found_any = False
    for path in all_build_props(images):
        props = parse_prop_file(path)
        if key in props:
            found_any = True
            if set_key_in_file(path, key, value):
                touched += 1
    if not found_any:
        path = canonical_prop_file(images, preferred_partition)
        if set_key_in_file(path, key, value):
            touched += 1
    return touched


def choose_identity(workspace: Path, images: Path) -> tuple[str, str, str, str, str, str]:
    system_paths = partition_props(images, "system")
    vendor_paths = partition_props(images, "vendor")
    odm_paths = partition_props(images, "odm")
    all_paths = all_build_props(images)

    device_file = workspace / "bin/ddevice/device_f.txt"
    device = device_file.read_text().strip() if device_file.is_file() else ""
    if not device:
        device = first_value(vendor_paths + odm_paths + all_paths, (
            "ro.product.vendor.device", "ro.product.odm.device", "ro.product.device",
        ))
    if not device:
        raise ValueError("FK_LOCK: cannot resolve device codename")

    target_fp = first_value(system_paths, ("ro.build.fingerprint",))
    if not target_fp:
        target_fp = first_value(all_paths, ("ro.build.fingerprint",))
    if not target_fp or SUSPICIOUS.search(target_fp):
        raise ValueError(f"FK_LOCK: unsafe top-level fingerprint: {target_fp!r}")

    real_model = first_value(vendor_paths + odm_paths + all_paths, (
        "ro.product.vendor.model", "ro.product.odm.model", "ro.product.model",
    ))
    brand = first_value(vendor_paths + odm_paths + all_paths, (
        "ro.product.vendor.brand", "ro.product.odm.brand", "ro.product.brand",
    )) or "Xiaomi"
    manufacturer = first_value(vendor_paths + odm_paths + all_paths, (
        "ro.product.vendor.manufacturer", "ro.product.odm.manufacturer", "ro.product.manufacturer",
    )) or "Xiaomi"
    if not real_model:
        real_model = device

    return device, real_model, brand, manufacturer, target_fp, target_fp


def normalize_identity(workspace: Path, images: Path) -> None:
    try:
        device, model, brand, manufacturer, target_fp, _ = choose_identity(workspace, images)
    except ValueError as error:
        if str(error).startswith("FK_LOCK: unsafe top-level fingerprint:"):
            print(f"[FK_LOCK] identity normalization skipped: {error}")
            print("[FK_LOCK] preserving extracted ROM identity until a trusted stock fingerprint is available")
            return
        raise

    print(f"[FK_LOCK] target device: {device}")
    print(f"[FK_LOCK] target model: {model}")
    print(f"[FK_LOCK] target fingerprint: {target_fp}")

    for part in PARTITIONS:
        fp_key = f"ro.{part}.build.fingerprint"
        set_property_everywhere(images, fp_key, target_fp, part)

        identity = {
            f"ro.product.{part}.device": device,
            f"ro.product.{part}.name": device,
            f"ro.product.{part}.model": model,
            f"ro.product.{part}.brand": brand,
            f"ro.product.{part}.manufacturer": manufacturer,
        }
        for key, value in identity.items():
            set_property_everywhere(images, key, value, part)

    # Only repair top-level identity if it is obviously generic/ported.
    top_level = {
        "ro.build.product": device,
        "ro.product.device": device,
        "ro.product.name": device,
        "ro.product.model": model,
        "ro.product.brand": brand,
        "ro.product.manufacturer": manufacturer,
    }
    all_paths = all_build_props(images)
    for key, value in top_level.items():
        seen = [(p, parse_prop_file(p).get(key, "")) for p in all_paths if key in parse_prop_file(p)]
        if any(current and SUSPICIOUS.search(current) for _, current in seen):
            set_property_everywhere(images, key, value, "system")

    # Verify no stale cross-partition identity remains for the normalized keys.
    for part in PARTITIONS:
        expected = {
            f"ro.{part}.build.fingerprint": target_fp,
            f"ro.product.{part}.device": device,
            f"ro.product.{part}.name": device,
            f"ro.product.{part}.model": model,
            f"ro.product.{part}.brand": brand,
            f"ro.product.{part}.manufacturer": manufacturer,
        }
        for key, value in expected.items():
            values = []
            for path in all_build_props(images):
                props = parse_prop_file(path)
                if key in props:
                    values.append((path, props[key]))
            if not values:
                raise ValueError(f"FK_LOCK: {key} missing after normalization")
            wrong = [(p, v) for p, v in values if v != value]
            if wrong:
                detail = ", ".join(f"{p}:{v}" for p, v in wrong)
                raise ValueError(f"FK_LOCK: {key} still inconsistent: {detail}")

    # Deliberately do not rewrite ro.vendor/ro.odm build fingerprints.
    print("[FK_LOCK] identity normalization verified; vendor/odm fingerprints preserved")


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
    version = (vendor / "plat_sepolicy_vers.txt").read_text().strip()
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

    # Xiaomi property visibility: keep this idempotent and limited to lock state.
    for target_file in images.rglob("cust_prop_white_keys_list"):
        if not target_file.is_file():
            continue
        existing = set(target_file.read_text(errors="ignore").splitlines())
        with target_file.open("a") as out:
            for key in LOCK_PROPERTIES:
                if key not in existing:
                    out.write(key + "\n")

    print("[FK_LOCK] runtime installed: boot_completed only")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("workspace", type=Path)
    args = parser.parse_args()
    workspace = args.workspace.resolve()
    images = workspace / "build/baserom/images"
    if not images.is_dir():
        parser.exit(1, "ERROR: FK_LOCK: extracted images directory missing\n")

    try:
        normalize_identity(workspace, images)
        install_runtime(workspace, images)
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        parser.exit(1, f"ERROR: {error}\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
