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

## EliteRom encrypted `custom.img`

Observed in [GitHub Actions run #38829480282](https://github.com/ngocminhvn/HyperMOS/actions/runs/38829480282):
`firmware-update/custom.img` is 7,707,418,240 bytes and begins with
`53616c7465645f5f` (ASCII `Salted__`), consistent with an OpenSSL encrypted
file. It is **not** directly readable as EROFS, EXT4, or super. The original
custom ROM files cannot be recovered by renaming the image.

Default behavior: the workflow fails explicitly with
`[ENCRYPTED-ROM-IMAGE]` and uploads a ZIP inventory. It never creates a
misleading empty dump.

Optional authorized decryption: if you have the **correct passphrase**, add
it as a repository **Actions secret** named `DUMP_IMAGE_PASSWORD` (Repository
Settings → Secrets and variables → Actions). Start a **new** `dump` run.
The secret is inherited by the callable workflow and passed only to the
extraction step; it is never provided as a workflow_dispatch text input or
printed. The extractor tests a small ciphertext prefix against three common
OpenSSL AES-256-CBC password derivations (PBKDF2, SHA-256 legacy, MD5 legacy).
A profile is accepted **only** if its plaintext contains the Android
sparse/super signature. Decryption of the complete image proceeds only after
that verification, and the resulting super image is verified again before
`lpunpack`. No password guessing or unknown-proprietary encryption bypass
is attempted.

The `Salted__` marker alone does not identify the actual cipher or passphrase.
If those known profiles are not supported by the ROM, you must obtain a
compatible unencrypted image or the appropriate decryption information from
the ROM author. Avoid re-running a 7+ GiB download expecting automatic
decryption without the key.
