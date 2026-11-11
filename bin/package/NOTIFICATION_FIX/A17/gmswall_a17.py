"""Install a confined init action for the two GMS firewall chains."""

import argparse
import os
from pathlib import Path
import shutil
import sys

PROP = "sys.hypermos.notification.clear_gms_wall"
DOMAIN = "hypermos_gmswall"
EXEC_TYPE = DOMAIN + "_exec"
PROP_TYPE = DOMAIN + "_prop"
BIN_DIR = "/system_ext/bin/hypermos-gmswall"

INIT = f"""on property:{PROP}=1
    start hypermos_gmswall4
    start hypermos_gmswall6

service hypermos_gmswall4 {BIN_DIR}/iptables -w 5 -t filter -F gms_wall
    user root
    group root
    capabilities NET_ADMIN NET_RAW
    seclabel u:r:{DOMAIN}:s0
    disabled
    oneshot

service hypermos_gmswall6 {BIN_DIR}/ip6tables -w 5 -t filter -F gms_wall
    user root
    group root
    capabilities NET_ADMIN NET_RAW
    seclabel u:r:{DOMAIN}:s0
    disabled
    oneshot
"""

POLICY = f"""; BEGIN HyperMOS A17 GMS firewall
(type {DOMAIN})
(roletype r {DOMAIN})
(typeattributeset domain ({DOMAIN}))
(typeattributeset coredomain ({DOMAIN}))
(type {EXEC_TYPE})
(roletype object_r {EXEC_TYPE})
(typeattributeset file_type ({EXEC_TYPE}))
(typeattributeset exec_type ({EXEC_TYPE}))
(typeattributeset system_file_type ({EXEC_TYPE}))
(type {PROP_TYPE})
(roletype object_r {PROP_TYPE})
(typeattributeset property_type ({PROP_TYPE}))
(typeattributeset system_property_type ({PROP_TYPE}))
(typeattributeset system_internal_property_type ({PROP_TYPE}))
(allow init {DOMAIN} (process (transition)))
(allow {DOMAIN} init (process (sigchld)))
(allow init {EXEC_TYPE} (file (read open getattr map execute)))
(allow {DOMAIN} {EXEC_TYPE} (file (read open getattr map execute entrypoint)))
(allow {DOMAIN} self (capability (net_admin net_raw)))
(allow {DOMAIN} self (rawip_socket (create getopt setopt read write)))
(allow {DOMAIN} self (netlink_netfilter_socket (create bind read write getattr getopt setopt)))
(allow {DOMAIN} proc_net_type (dir (search read open getattr)))
(allow {DOMAIN} proc_net_type (file (read open getattr)))
(allow {DOMAIN} system_file (file (lock)))
(allow system_server {PROP_TYPE} (property_service (set)))
(allow system_server {PROP_TYPE} (file (read getattr map open)))
; END HyperMOS A17 GMS firewall
"""


def append_once(path, block):
    original = path.read_text(encoding="utf-8")
    if block in original:
        return original
    return original.rstrip("\n") + "\n" + block


def install(images, report_dir):
    # Reuse HyperMOS's split-policy verifier and metadata conflict checks.
    sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "TNM"))
    from integrate_lock import checked, replace_file, row, verify_init, verify_policy

    policy = checked(images, "system_ext/etc/selinux/system_ext_sepolicy.cil")
    contexts = (
        checked(images, "system_ext/etc/selinux/system_ext_file_contexts"),
        checked(images, "config/system_ext_file_contexts"),
    )
    properties = checked(images, "system_ext/etc/selinux/system_ext_property_contexts")
    dac = checked(images, "config/system_ext_fs_config")
    iptables = checked(images, "system/system/bin/iptables")
    ip6tables = images / "system/system/bin/ip6tables"
    if ip6tables.resolve() != iptables.resolve():
        raise ValueError("A17 gms_wall requires stock ip6tables multicall layout")
    if not shutil.which("secilc") and not os.environ.get("TNM_SECILC"):
        raise ValueError("A17 gms_wall needs the ROM split-policy compiler")

    proposed = report_dir / "gmswall-system_ext.cil"
    proposed.write_text(append_once(policy, POLICY), encoding="utf-8")
    result = verify_policy(images, report_dir, proposed, "gmswall-secilc.log")
    if result["returncode"]:
        raise ValueError(f"gms_wall split policy failed: {report_dir / 'gmswall-secilc.log'}")

    context_data = {}
    dac_data = dac.read_bytes()
    for path, mode in ((BIN_DIR, b"0755"), ("/system_ext/etc/init/hypermos-gmswall.rc", b"0644")):
        key = path.lstrip("/").encode()
        dac_data = row(dac_data, key, key + b" 0 0 " + mode + b" capabilities=0x0")
    for name in ("iptables", "ip6tables"):
        device_path = f"{BIN_DIR}/{name}"
        line = f"{device_path} u:object_r:{EXEC_TYPE}:s0".encode()
        for path in contexts:
            data = context_data.get(path, path.read_bytes())
            context_data[path] = row(data, device_path.encode(), line)
        key = device_path.lstrip("/").encode()
        dac_data = row(dac_data, key, key + b" 0 0 0755 capabilities=0x0")
    prop_line = f"{PROP} u:object_r:{PROP_TYPE}:s0 exact bool".encode()
    context_data[properties] = row(properties.read_bytes(), PROP.encode(), prop_line)
    context_data[dac] = dac_data

    binary = iptables.read_bytes()
    for name in ("iptables", "ip6tables"):
        replace_file(images / BIN_DIR.lstrip("/") / name, binary, 0o755)
    replace_file(images / "system_ext/etc/init/hypermos-gmswall.rc", INIT.encode(), 0o644)
    for path, data in context_data.items():
        replace_file(path, data, 0o644)
    replace_file(policy, proposed.read_bytes(), 0o644)
    for part in ("vendor", "odm"):
        for cache in (images / part / "etc/selinux").glob("precompiled_sepolicy*"):
            if cache.is_file():
                cache.unlink()
    if verify_init(images, report_dir)["status"] == "failed":
        raise ValueError("A17 gms_wall init configuration failed validation")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("images", type=Path)
    parser.add_argument("report_dir", type=Path)
    args = parser.parse_args()
    install(args.images, args.report_dir)
