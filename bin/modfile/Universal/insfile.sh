work_dir=$(pwd)
source $work_dir/functions.sh

mods "Starting Apply Universal File..."
TARGET_DIR="$work_dir/bin/modfile/Universal"
noexecute=( "insfile" )

while read -r script; do
    base="$(basename "$script" .sh)"

    skip=false
    for ex in "${noexecute[@]}"; do
        if [[ "$base" == "$ex" ]]; then
            skip=true
            break
        fi
    done

    if [[ $skip == false ]]; then
        if ! bash "$script"; then
            error "Universal mod failed: $script"
            exit 1
        fi
    fi
done < <(find "$TARGET_DIR" -type f -name "*.sh" | LC_ALL=C sort)
