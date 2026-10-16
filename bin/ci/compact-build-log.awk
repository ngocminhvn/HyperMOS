# Compact HyperMOS Actions console output without discarding the raw log.
# Usage: command 2>&1 | tee -a build_action.log | awk -f bin/ci/compact-build-log.awk
# Never filter the exit status: use bash "set -o pipefail" in the calling step.

function emit(line) {
    print line
    fflush()
}

function flush_progress() {
    if (extracted > 0) {
        emit("[PROGRESS] Extracted " extracted " partition image(s)")
        extracted = 0
    }
    if (packed > 0) {
        emit("[PROGRESS] Packed " packed " partition image(s)")
        packed = 0
    }
    hidden = 0
}

{
    line = $0
    sub(/\r$/, "", line)

    # Major checkpoints and GitHub diagnostic annotations are always visible.
    if (line ~ /^\[PHASE\]/ || line ~ /^::(error|warning|notice|group|endgroup)::/) {
        flush_progress()
        emit(line)
        next
    }

    # Summarise hundreds of partition-level extraction and packing messages.
    if (line ~ /^\[UNPACK\].*File .*\.img extracted/) {
        extracted++
        if (extracted % 5 == 0) {
            emit("[PROGRESS] " extracted " partitions extracted")
            extracted = 0
        }
        next
    }
    if (line ~ /^\[REPACK\].*Packing \[.*\.img\] success/) {
        packed++
        if (packed % 5 == 0) {
            emit("[PROGRESS] " packed " partitions packed")
            packed = 0
        }
        next
    }

    # Retain high-signal diagnostics and output links.
    if (line ~ /^\[(ERROR|WARN|OK|ROOT|OS3|UPLOAD)\]/ ||
        line ~ /^\[RCLONE\] Download URL:/ ||
        line ~ /^\[INFO\] - PATCH [0-9]+\// ||
        line ~ /^\[REPACK\].*(super\.img|ROM ZIP|Super image size|parallel jobs)/ ||
        line ~ /^\[MODS\].*(OS3 ->|Starting Apply OS3|Starting Update File|System APKs -> Done)/ ||
        line ~ /^\[UPLOADING\].*(completed|success|failed)/ ||
        line ~ /^(Traceback \(most recent call last\)|[[:space:]]*File ".*", line [0-9]+|Exception:|[[:space:]]*[A-Za-z0-9_.]+Error:)/ ||
        tolower(line) ~ /(^|[[:space:]:])(fatal:|error:|failed:|permission denied|no space left on device)/) {
        emit(line)
        next
    }

    # Repetitive module/zip/7zz/aria2/rclone output stays in build_action.log.
    hidden++
    if (hidden >= 200) {
        emit("[PROGRESS] Working... 200 detailed log lines hidden")
        hidden = 0
    }
}
END {
    flush_progress()
}
