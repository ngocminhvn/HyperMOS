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
