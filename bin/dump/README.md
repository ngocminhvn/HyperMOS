# HyperMOS dump

Read-only ROM component snapshot with a source file map.

## Workflow inputs

- `rom_url` — direct ROM ZIP URL. Supports regular HTTP(S) ZIP URLs and SourceForge links of the forms `...zip`, `...zip/download`, `...zip*/*`, or `https://downloads.sourceforge.net/project/...`.
- `dump_mode` — `base` by default (five original ROM JAR/APK filenames: framework.jar, miui-framework.jar, miui-services.jar, powerkeeper.apk, services.jar); `full` uses all targets in `targets.txt`.
- `upload_method` — `artifact` or `drive`.

## SourceForge mirror detection

For SourceForge links, `sourceforge_download.py` normalizes the URL and probes bounded 1 MiB ranges **through the SourceForge binary download router** (`downloads.sourceforge.net/project/...`) with `use_mirror` selection. This matches the signed/redirected path used for real downloads, rather than testing bare, unsigned direct CDN URLs that may reject valid files. The downloader accepts only HTTP 206 partial ZIP data for speed measurements, deduplicates the actual serving hosts and ranks verified mirrors by throughput from the GitHub Actions runner. The fastest verified mirror is then downloaded **through the same router**, so the mirror can receive a fresh SourceForge redirect/token. If an actual mirror URL (such as `master.dl.sourceforge.net/project/...`) is supplied, that original URL (including its temporary signature/query) is tried first so valid download tokens are not discarded. If all range probes fail (HTTP 403, ignored ranges, etc.), that does **not** mean every mirror is offline: the downloader tries `router-autoselect` and existing router/direct CDN fallbacks. A temporary signed direct link may expire; in that case use the permanent SourceForge project URL.

The output ZIP includes `pack-meta/mirror-report.json` with measured mirrors, per-mirror failure reasons, the probe method and the selected download route. A selected `router-autoselect` route may redirect individual aria2 connections to several actual CDN hosts, not a single fixed mirror. If SourceForge blocks range checks, there may be no verified benchmark results; the downloader uses SourceForge's automatic mirror selection rather than incorrectly marking the ROM unavailable. Actual full-file performance can differ from the small sample benchmark.

Non-SourceForge URLs retain direct aria2 downloading and ZIP integrity checks. No modifications are made to ROM contents.


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



## Experimental offline behavior probe (no device)

Run the manual workflow named **Probe EliteRom installer (offline sandbox)** to
perform a bounded, *in-container* startup-only behavior observation of the
previously extracted EliteRomLite Linux executable. The workflow reuses the
15 MB installer artifact from run #38856269819 and **does not re-download the
7.5 GiB ROM**.

The untrusted ELF is mounted **read-only** inside a Docker container that has:
no network, no host secrets, no attached phone or firmware images, a read-only
root filesystem, all Linux capabilities dropped, no privilege escalation,
a non-root UID, CPU/memory/PID limits and temporary in-memory storage. Only
no-argument / help invocations are allowed; none are flash commands. A short
timeout terminates any tracee process group still active.

System-call and optional imported-function observations are reduced to
**function names, counts and broad file-access categories** *inside the
container*. Raw traces, program output, process memory, arbitrary arguments,
possible passphrases and binary files are **not** exported. The artifact
contains only aggregated JSON and Markdown.

The sandbox's syscall or library tracer may itself fail under container
security restrictions; these outcomes are reported as instrumentation limits,
not proof that the installer lacks a crypto routine. Seeing EVP/PKCS5 symbols
in an import list is not proof of their runtime use, and **no installer
decryption password/key is expected to be recovered** by this limited test.
The workflow does not interact with or modify build/flash pipelines.
