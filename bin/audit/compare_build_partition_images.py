#!/usr/bin/env python3
"""Compare the real file contents of two built super images and export only changed .img files.

Uses bundled lpunpack plus fsck.erofs / debugfs. Does not flash or modify sources.
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
from audit_xiaomi_eu_apps import filesystem, read_partition_names  # noqa: E402


def run(*args):
    print("[CMD]", " ".join(map(str, args)), flush=True)
    subprocess.run([str(x) for x in args], check=True)


def sha256(path):
    hasher = hashlib.sha256()
    with path.open("rb") as handle:
        for part in iter(lambda: handle.read(4 * 1024 * 1024), b""):
            hasher.update(part)
    return hasher.hexdigest()


def partition_names(super_file):
    names = read_partition_names(super_file, REPO / "bin/lpunpack.py")
    # V-AB images contain unpopulated, zero-extent _b entries.
    return sorted(n for n in names if not n.endswith("_b"))


def extract_image(super_file, part, dest):
    dest.mkdir(parents=True, exist_ok=True)
    run(sys.executable, REPO / "bin/lpunpack.py", "-p", part, super_file, dest)
    image = dest / (part + ".img")
    if not image.is_file() or image.stat().st_size < 4096:
        raise RuntimeError("Partition missing or empty: " + part)
    return image


def extract_tree(image, dest):
    dest.mkdir(parents=True, exist_ok=True)
    kind = filesystem(image)
    if kind == "erofs":
        run("fsck.erofs", "--extract=" + str(dest), image)
    elif kind == "ext4":
        run("debugfs", "-R", "rdump / " + str(dest), image)
    else:
        raise RuntimeError("Unsupported filesystem for " + str(image))
    return kind


def file_index(root):
    # Ignore build timestamps but compare file names/bytes/types/modes/links.
    # Filesystem xattrs and SELinux labels are not exhaustively checked.
    records = {}
    for directory, dirs, files in os.walk(root, followlinks=False):
        here = Path(directory)
        for name in sorted(dirs + files):
            full = here / name
            relative = full.relative_to(root).as_posix()
            st = full.lstat()
            perm = format(stat.S_IMODE(st.st_mode), "o")
            if stat.S_ISLNK(st.st_mode):
                records[relative] = ["symlink", os.readlink(full), perm]
            elif stat.S_ISREG(st.st_mode):
                records[relative] = ["file", st.st_size, perm, sha256(full)]
            elif stat.S_ISDIR(st.st_mode):
                records[relative] = ["directory", perm]
            else:
                records[relative] = ["special", stat.S_IFMT(st.st_mode), perm]
    return records


def compare(base, target, part, scratch):
    old_image = extract_image(base, part, scratch / "base-image")
    new_image = extract_image(target, part, scratch / "new-image")
    old_hash, new_hash = sha256(old_image), sha256(new_image)
    info = {"partition": part, "base_sha256": old_hash,
            "target_sha256": new_hash, "bytes": new_image.stat().st_size}
    if old_hash == new_hash:
        info.update(status="identical_image", changed=False, changed_paths=[])
        return info, new_image
    old_type = extract_tree(old_image, scratch / "base-tree")
    new_type = extract_tree(new_image, scratch / "new-tree")
    if old_type != new_type:
        raise RuntimeError("Different filesystem types for " + part)
    a, b = file_index(scratch / "base-tree"), file_index(scratch / "new-tree")
    differences = [p for p in sorted(a.keys() | b.keys()) if a.get(p) != b.get(p)]
    info.update(status="file_tree_changed" if differences else "repacked_metadata_only",
                changed=bool(differences), changed_path_count=len(differences),
                changed_paths=differences[:50], filesystem=new_type)
    return info, new_image


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--base-super", required=True, type=Path)
    p.add_argument("--new-super", required=True, type=Path)
    p.add_argument("--work", required=True, type=Path)
    p.add_argument("--output", required=True, type=Path)
    p.add_argument("--include-product", action="store_true")
    args = p.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    args.work.mkdir(parents=True, exist_ok=True)
    old_names = partition_names(args.base_super)
    new_names = partition_names(args.new_super)
    if set(old_names) != set(new_names):
        raise RuntimeError("Different partition sets: base=" + repr(old_names)
                           + ", target=" + repr(new_names))
    if not {"system_a", "system_ext_a"}.issubset(set(new_names)):
        raise RuntimeError("Not the expected HAOTIAN V-AB super partition layout")
    rows, exported = [], []
    for idx, part in enumerate(new_names, 1):
        print("[COMPARE {}/{}] {}".format(idx, len(new_names), part), flush=True)
        scratch = args.work / "partition-compare"
        try:
            row, target_image = compare(args.base_super, args.new_super, part, scratch)
            if row["changed"] and (args.include_product or part != "product_a"):
                dst = args.output / (part + ".img")
                shutil.move(str(target_image), str(dst))
                row["exported"] = True
                exported.append(part)
            else:
                row["exported"] = False
                if row["changed"] and part == "product_a":
                    row["reason"] = "Excluded product: install MiCTS APK manually; other product updates omitted"
                elif row["status"] == "repacked_metadata_only":
                    row["reason"] = "File contents same; image metadata/xattrs not completely compared"
            rows.append(row)
            print("[RESULT] {}: {} (export={})".format(part, row["status"], row["exported"]), flush=True)
        finally:
            shutil.rmtree(scratch, ignore_errors=True)
    report = {
        "base": "HyperMOS EU #170", "target": "HyperMOS EU #176",
        "source_firmware": "HAOTIAN OS3.0.309.0.WOBCNXM",
        "product_included": args.include_product,
        "exported": exported, "partitions": rows,
        "warning": "Comparisons exclude some filesystem metadata/xattrs. A matching base ROM "
                   "does not guarantee that cross-build partition mixes will boot. "
                   "Verify active slot, dynamic partition size and rollback plan."
    }
    (args.output / "comparison.json").write_text(json.dumps(report, indent=2) + "\n")
    md = [
        "# HyperMOS EU #170 to #176 - changed partition images", "",
        "Filesystem contents compared to avoid treating repack timestamps as changes.",
        "", "| Partition | Comparison | Exported | File changes |",
        "|---|---|---|---:|"
    ]
    for row in rows:
        md.append("| {} | {} | {} | {} |".format(
            row["partition"], row["status"], "yes" if row["exported"] else "no",
            row.get("changed_path_count", 0)))
    md += ["", "## Output IMG", ""]
    md += ["- " + x + ".img" for x in exported] or ["- No changed partitions selected"]
    md += ["", "By default product_a.img is omitted to let the user install MiCTS APK.",
           "This also omits unrelated product changes, as detailed in comparison.json.",
           "All other changed image files are copied unmodified from build #176.",
           "This does not compare every SELinux label or xattr. Not boot-tested.",
           "Do not flash an entire super image for this narrowly-scoped test.", ""]
    report_md = "\n".join(md)
    (args.output/"comparison.md").write_text(report_md)
    if os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(os.environ["GITHUB_STEP_SUMMARY"], "a") as handle:
            handle.write(report_md + "\n")
    print("[SUCCESS] Exported: " + (", ".join(exported) or "none"), flush=True)


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, ValueError, OSError, subprocess.CalledProcessError) as error:
        sys.exit("[ERROR] Partition comparison failed: " + str(error))
