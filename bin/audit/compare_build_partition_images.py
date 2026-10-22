#!/usr/bin/env python3
"""Export ALL logical partition images whose FILE CONTENT differs: EU #170 -> #176.

Both full built super images are compared offline. No flashing is performed.
Image-level metadata/xattrs may differ even when extracted file trees match.
"""
import argparse
import hashlib
import json
import os
import shutil
import stat
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / "bin/audit"))
from audit_xiaomi_eu_apps import filesystem, read_partition_names


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(4 * 1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def cmd(*args):
    print("[CMD]", " ".join(map(str, args)), flush=True)
    subprocess.run([str(x) for x in args], check=True)


def names(super_image):
    parts = read_partition_names(super_image, REPO / "bin/lpunpack.py")
    # V-AB #170/#176 have zero-sized _b placeholders; compare populated _a only.
    return sorted(x for x in parts if x.endswith("_a"))


def unpack(super_image, name, dest):
    dest.mkdir(parents=True, exist_ok=True)
    cmd(sys.executable, REPO / "bin/lpunpack.py", "-p", name, super_image, dest)
    img = dest / (name + ".img")
    if not img.is_file() or img.stat().st_size < 4096:
        raise RuntimeError("Missing/nonpopulated logical partition: " + name)
    return img


def extract(img, dest):
    dest.mkdir(parents=True, exist_ok=True)
    typ = filesystem(img)
    if typ == "erofs":
        cmd("fsck.erofs", "--extract=" + str(dest), img)
    elif typ == "ext4":
        cmd("debugfs", "-R", "rdump / " + str(dest), img)
    else:
        raise RuntimeError("Unsupported filesystem: " + typ)
    return typ


def walk(root):
    out = {}
    for directory, dirs, files in os.walk(root, followlinks=False):
        for name in sorted(dirs + files):
            item = Path(directory) / name
            rel = item.relative_to(root).as_posix()
            st = item.lstat()
            mode = format(stat.S_IMODE(st.st_mode), "o")
            if stat.S_ISLNK(st.st_mode):
                out[rel] = ["link", os.readlink(item), mode]
            elif stat.S_ISREG(st.st_mode):
                out[rel] = ["file", st.st_size, mode, sha256(item)]
            elif stat.S_ISDIR(st.st_mode):
                out[rel] = ["dir", mode]
            else:
                out[rel] = ["special", stat.S_IFMT(st.st_mode), mode]
    return out


def diff(base_super, target_super, part, tmp, output):
    old = unpack(base_super, part, tmp / "old-img")
    new = unpack(target_super, part, tmp / "new-img")
    old_hash, new_hash = sha256(old), sha256(new)
    row = {"name": part, "base_sha256": old_hash,
           "target_sha256": new_hash, "size": new.stat().st_size}
    if old_hash == new_hash:
        row.update(status="identical", modified_count=0, modified_paths=[])
        return row
    if extract(old, tmp / "old-files") != extract(new, tmp / "new-files"):
        raise RuntimeError("Filesystem format changed for " + part)
    a, b = walk(tmp / "old-files"), walk(tmp / "new-files")
    changes = [{"path": p, "change": (
                    "added" if p not in a else "removed" if p not in b else "modified")}
               for p in sorted(a.keys() | b.keys()) if a.get(p) != b.get(p)]
    row.update(
        status="content_changed" if changes else "metadata_only",
        modified_count=len(changes),
        modified_paths=changes
    )
    if changes:
        path = output / (part + ".img")
        shutil.copyfile(new, path)
        if sha256(path) != new_hash:
            raise RuntimeError("Exported image digest mismatch: " + part)
        row["exported"] = str(path.name)
        print("[EXPORT]", path, flush=True)
    return row


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--base-super", type=Path, required=True)
    parser.add_argument("--new-super", type=Path, required=True)
    parser.add_argument("--work", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    opt = parser.parse_args()
    opt.output.mkdir(parents=True, exist_ok=True)
    opt.work.mkdir(parents=True, exist_ok=True)
    base, new = names(opt.base_super), names(opt.new_super)
    if base != new or not {"system_a", "system_ext_a", "product_a"}.issubset(set(base)):
        raise RuntimeError("Unexpected mismatch in populated V-AB partition metadata: "
                           + repr(base) + " vs " + repr(new))
    rows = []
    for number, name in enumerate(new, 1):
        print("[COMPARE {}/{}] {}".format(number, len(new), name), flush=True)
        tmp = opt.work / "compare"
        try:
            row = diff(opt.base_super, opt.new_super, name, tmp, opt.output)
            rows.append(row)
            print("[RESULT] {} {} {} changed paths".format(
                name, row["status"], row["modified_count"]), flush=True)
        finally:
            shutil.rmtree(tmp, ignore_errors=True)
    exported = [row["exported"] for row in rows if row.get("exported")]
    if not exported:
        raise RuntimeError("No changed partition images; wrong ROM archives?")
    result = {
        "base": "HyperMOS EU build #170",
        "target": "HyperMOS EU build #176",
        "same_original_firmware": "Xiaomi.eu HAOTIAN OS3.0.309.0.WOBCNXM",
        "exported_logical_images": exported,
        "comparisons": rows,
        "important": "Full partitions, not isolated MiCTS/ColorOS changes. "
                     "File-level comparison ignores some filesystem metadata/xattrs. "
                     "Do not mix slots and do not flash without backups and rollback."
    }
    (opt.output / "logical-differences.json").write_text(json.dumps(result, indent=2) + "\n")
    lines = ["## Logical partition changes, HyperMOS EU #170 to #176",
             "", "| Partition | Changed files | Exported? |",
             "|---|---:|---|"]
    for row in rows:
        lines.append("| {} | {} | {} |".format(
            row["name"], row["modified_count"],
            row.get("exported", "no")))
    lines += ["", "Actual paths are in logical-differences.json.",
              "APK/ColorOS/MICTS differences in product_a are INCLUDED.",
              "This is a full-partition image comparison, NOT a boot compatibility test.",
              ""]
    report = "\n".join(lines)
    (opt.output / "logical-differences.md").write_text(report)
    if os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(os.environ["GITHUB_STEP_SUMMARY"], "a") as stream:
            stream.write(report + "\n")
    print("[SUCCESS] Logical IMG: " + ", ".join(exported), flush=True)


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, ValueError, OSError, subprocess.CalledProcessError) as error:
        sys.exit("[ERROR] Logical IMG comparison failed: " + str(error))
