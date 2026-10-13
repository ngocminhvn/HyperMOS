#!/usr/bin/env bash
# Source is never modified. Fail closed on bad input or unsupported tools.
set -Eeuo pipefail
cd "${GITHUB_WORKSPACE:-$(pwd)}"
mkdir -p work/original work/extracted/partitions work/reports work/tools
python3 - <<'PY'
import json
from pathlib import Path
c=json.loads(Path("config.json").read_text())
Path("work/reports/config-summary.txt").write_text(
    "image SHA-256: "+c["source_sha256"]+"\n"+
    "OS3 source ref: "+c["os3_source_ref"]+"\n"+
    "Build mode: READ-ONLY AUDIT; no repack\n"
)
PY
echo "Disk before download:" | tee work/reports/disk.log
df -h . | tee -a work/reports/disk.log
python3 - <<'PY'
import json,subprocess
from pathlib import Path
c=json.loads(Path("config.json").read_text())
subprocess.run(["curl","--fail","--location","--retry","3","--connect-timeout","30",
                "--output","work/original/super.img",c["source_super_url"]],check=True)
PY
sha256sum work/original/super.img | tee work/reports/source-sha256.txt
python3 - <<'PY'
import hashlib,json
from pathlib import Path
c=json.loads(Path("config.json").read_text())
h=hashlib.sha256()
with Path("work/original/super.img").open("rb") as f:
    for block in iter(lambda:f.read(8*1024*1024),b""): h.update(block)
if h.hexdigest()!=c["source_sha256"].lower():
    raise SystemExit("SHA-256 mismatch or a hotlink-error response; aborting.")
PY
file work/original/super.img | tee work/reports/source-file.txt
# Pin tools to the same HyperMOS revision as the asset reference.
python3 - <<'PY'
import json,subprocess
from pathlib import Path
ref=json.loads(Path("config.json").read_text())["os3_source_ref"]
for name in ("simg2img","lpunpack"):
    url=f"https://raw.githubusercontent.com/ngocminhvn/HyperMOS/{ref}/bin/Linux/x86_64/{name}"
    subprocess.run(["curl","--fail","--location","--retry","3","--output",
                    f"work/tools/{name}",url],check=True)
PY
chmod +x work/tools/{simg2img,lpunpack}
image="work/original/super.img"
if file -b "$image" | grep -iq 'Android sparse'; then
  echo "Sparse source detected; converting read-only copy" | tee -a work/reports/source-file.txt
  work/tools/simg2img "$image" work/extracted/super.raw.img
  image="work/extracted/super.raw.img"
fi
work/tools/lpunpack "$image" work/extracted/partitions/ 2>&1 | tee work/reports/lpunpack.log
find work/extracted/partitions -maxdepth 1 -type f -name '*.img' -print0 |
  sort -z | xargs -0 -r file | tee work/reports/partition-types.txt
echo "Disk after unpack:" | tee -a work/reports/disk.log
df -h . | tee -a work/reports/disk.log
echo "AUDIT COMPLETE. No partition content was modified or repacked."
