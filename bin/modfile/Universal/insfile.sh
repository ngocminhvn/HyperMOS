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
    bash "$MORPHE_SCRIPT"
fi

