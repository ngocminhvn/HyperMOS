# HyperMOS dump

Read-only ROM component snapshot with a source file map.

## Workflow inputs

- `rom_url` — direct ROM ZIP URL. Supports regular HTTP(S) ZIP URLs and SourceForge links of the forms `...zip`, `...zip/download`, `...zip*/*`, or `https://downloads.sourceforge.net/project/...`.
- `dump_mode` — `base` by default (five original ROM JAR/APK filenames: framework.jar, miui-framework.jar, miui-services.jar, powerkeeper.apk, services.jar); `full` uses all targets in `targets.txt`.
- `upload_method` — `artifact` or `drive`.

## SourceForge mirror detection

For SourceForge links, `sourceforge_download.py` normalizes the URL, probes a bounded 1 MiB range from several SourceForge mirror choices in parallel, filters out non-ZIP/HTML/error responses and duplicate actual mirror hosts, and ranks the verified mirrors by measured throughput from the GitHub Actions runner. For ordinary project links, the fastest verified direct CDN mirror is tried first. If an actual mirror URL (such as `master.dl.sourceforge.net/project/...`) is supplied, that original URL (including its temporary signature/query) is tried first so valid SourceForge download tokens are not discarded. If all small range probes fail or the web download page returns HTTP 403, the downloader still tries the binary download router (`downloads.sourceforge.net/project/...`), direct mirror URLs, and other fallbacks instead of aborting after `autoselect`. A temporary signed direct link may expire; in that case use the permanent SourceForge project URL.

The output ZIP includes `pack-meta/mirror-report.json` with measured mirrors and the one selected. If SourceForge does not support range checks, there may be no valid benchmark results; the downloader falls back to SourceForge's automatic mirror selection. Actual full-file performance can differ from the small sample benchmark.

Non-SourceForge URLs retain direct aria2 downloading and ZIP integrity checks. No modifications are made to ROM contents.

Offline tests: `python3 -m unittest discover -s bin/dump -p 'test_sourceforge*.py' -v`.

## Custom installers with firmware-update/ only

If the ZIP exposes only `META-INF/` and `firmware-update/` entries (as in EliteRomLite HAOTIAN OS3.0.307.0's observed run #38827659686), it is not safe to assume that `firmware-update/custom.img` contains Android `system` or `product`. The dump extractor now examines ZIP member sizes and signatures, accepts a renamed `custom.img` as a `super` container **only when Android logical-partition metadata is verified**, and otherwise reports an explicit unsupported-layout error instead of a Python traceback. It never executes recovery `update-binary` scripts.

On failure the GitHub Actions diagnostic artifact includes `zip-layout.json`, `zip-layout.txt`, `entries.txt`, and (when small enough) `updater-script.txt`. These allow identifying which ZIP entries contain the actual ROM data without guessing. If the package genuinely contains firmware images only, obtaining framework JAR/APK files requires a full system-containing ROM ZIP, not a different extractor flag.

## Fast preflight for a verified encrypted release

The dump workflow now blocks the **exact** SourceForge `eliteroms` release
`EliteRomLite_v4.05_HAOTIAN_OS3.0.307.0_ChinaStable-A16.zip` before package
installation or an ~7.5 GiB download. Runs #38829480282, #38835073204, and
#38840382765 confirmed that this ZIP contains `firmware-update/custom.img`
with the OpenSSL `Salted__` header. Changing `base` to `full` cannot read
encrypted plaintext. This is not a general ban on EliteRom files or a
preflight guess based only on the project name; unverified ROM sources continue
through normal processing. The job ends with a clear explanation and an Actions
Step Summary instead of generating a false empty result.

For this encrypted build, use the read-only device ADB alternative below,
**but only if that exact build is installed on the connected device**, or
provide a ROM ZIP that genuinely contains unencrypted system partitions.

## EliteRom encrypted custom.img — password-free alternative

In [run #38835073204](https://github.com/ngocminhvn/HyperMOS/actions/runs/38835073204), the ~7 GiB firmware-update/custom.img begins with "Salted__" (encrypted payload). GitHub's standard hosted runner has no access to an already mounted Android ROM, and cannot extract this image directly without the correct decryption information.

There is **no DUMP_IMAGE_PASSWORD secret** in this repository's dump workflow anymore. The action fails explicitly with ENCRYPTED-ROM-IMAGE when given an encrypted ZIP, rather than pretending to produce a correct dump.

### Read files from the installed ROM over authorized ADB

If **that particular ROM is already running on a phone you control**, connect the phone to a computer with Android platform-tools and authorize USB debugging. With Python 3 installed, from the HyperMOS repository checkout:

```bash
python3 bin/dump/adb_dump.py --mode base --output HyperMOS-device-base.zip
```

For the larger target set:

```bash
python3 bin/dump/adb_dump.py --mode full --output HyperMOS-device-full.zip
```

Windows also accepts `py -3` in place of `python3`. The script uses local ADB and, when already authorized, optional `su` solely to read mounted system paths. It does **not** flash the phone, change partition mounts, install an app, or execute ROM installers. `--no-root` limits it to files the Android shell can already read. Output includes `map.tsv`, `map.json`, SHA256 checksums and `pack-meta/device-source.json` identifying the **installed device** as the source.

**Important:** This local script cannot operate from a normal GitHub-hosted Actions runner because the runner does not have a USB connection to the user's phone. It also cannot recover modifications from an encrypted EliteRom ZIP if EliteRom is not installed on the connected device. An unencrypted ROM ZIP is the alternative for cloud-only extraction.

One-shot tests: `python3 -m unittest discover -s bin/dump -p 'test_*.py' -v`.
