work_dir=$(pwd)
source $work_dir/functions.sh

mods "Starting Apply Universal File..."
TARGET_DIR="$work_dir/bin/modfile/Universal"
noexecute=( "insfile" )

find "$TARGET_DIR" -type f -name "*.sh" | while read -r script; do
    base="$(basename "$script" .sh)"

    # YouTubeMorphe must run last so GMS/Google integration cannot overwrite it.
    if [[ "$script" == */YouTubeMorphe/update.sh ]]; then
        continue
    fi

    # Kaorios has version-specific entrypoints and must never be auto-run.
    if [[ "$script" == */KaoriosToolbox/* ]]; then
        continue
    fi

    skip=false
    for ex in "${noexecute[@]}"; do
        if [[ "$base" == "$ex" ]]; then
            skip=true
            break
        fi
    done

    if [[ $skip == false ]]; then
        bash "$script"
    fi
done

MORPHE_SCRIPT="$TARGET_DIR/YouTubeMorphe/update.sh"
if [[ -f "$MORPHE_SCRIPT" ]]; then
    mods "Applying YouTube Morphe last..."
    bash "$MORPHE_SCRIPT"
fi


# Run exactly one Kaorios implementation selected by workflow/build.sh.
case "${KAORIOS_OPTION:-disabled}" in
    a16)
        KAORIOS_SCRIPT="$TARGET_DIR/KaoriosToolbox/A16/update.sh"
        [[ -f "$KAORIOS_SCRIPT" ]] || { error "Kaorios A16 script not found: $KAORIOS_SCRIPT"; exit 1; }
        mods "Applying Kaorios Toolbox for Android 16..."
        bash "$KAORIOS_SCRIPT"
        ;;
    a17)
        KAORIOS_SCRIPT="$TARGET_DIR/KaoriosToolbox/A17/update.sh"
        [[ -f "$KAORIOS_SCRIPT" ]] || { error "Kaorios A17 script not found: $KAORIOS_SCRIPT"; exit 1; }
        mods "Applying Kaorios Toolbox for Android 17..."
        bash "$KAORIOS_SCRIPT"
        ;;
esac
