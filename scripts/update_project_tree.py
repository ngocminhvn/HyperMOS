#!/usr/bin/env python3
from pathlib import Path
import subprocess

START = "<!-- PROJECT_TREE_START -->"
END = "<!-- PROJECT_TREE_END -->"
README = Path("README.md")

def tracked_files():
    output = subprocess.check_output(["git", "ls-files", "-z"])
    return [p.decode("utf-8", "surrogateescape") for p in output.split(b"\0") if p]

def build_tree(paths):
    root = {}
    for path in sorted(paths, key=lambda s: (s.lower(), s)):
        node = root
        parts = path.split("/")
        for part in parts:
            node = node.setdefault(part, {})

    lines = ["HyperMOS/"]
    def walk(node, prefix=""):
        items = list(node.items())
        for index, (name, children) in enumerate(items):
            last = index == len(items) - 1
            branch = "└── " if last else "├── "
            suffix = "/" if children else ""
            lines.append(f"{prefix}{branch}{name}{suffix}")
            if children:
                walk(children, prefix + ("    " if last else "│   "))
    walk(root)
    return "\n".join(lines)

def main():
    tree = build_tree(tracked_files())
    block = f"""{START}
## Project Structure

> Tự động cập nhật từ toàn bộ file đang được Git theo dõi bằng `git ls-files`. Không chỉnh sửa thủ công phần này.

```text
{tree}
```
{END}"""

    if README.exists():
        content = README.read_text(encoding="utf-8")
        if START in content and END in content:
            before = content.split(START, 1)[0].rstrip()
            after = content.split(END, 1)[1].lstrip()
            content = before + "\n\n" + block
            if after:
                content += "\n\n" + after
            content += "\n"
        else:
            content = content.rstrip() + "\n\n" + block + "\n"
    else:
        content = "# HyperMOS\n\n" + block + "\n"

    README.write_text(content, encoding="utf-8")

if __name__ == "__main__":
    main()
