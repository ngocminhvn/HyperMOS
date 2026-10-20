work_dir=$(pwd)
source $work_dir/functions.sh

mods "Starting Apply Universal File..."
TARGET_DIR="$work_dir/bin/modfile/Universal"

# Read Xiaomi.eu skip policy once; China keeps the exact original module set.
EU_SKIP_ACTIVE=0
EU_POLICY="$work_dir/bin/modfile/EU/policy.sh"
if [[ -s "$work_dir/bin/ddevice/rom_source.txt" ]] &&
   [[ "$(tr -d '\r\n' < "$work_dir/bin/ddevice/rom_source.txt")" == "xiaomi_eu" ]]; then
    [[ -s "$EU_POLICY" ]] || { error "Xiaomi.eu skip policy missing: $EU_POLICY"; exit 1; }
    source "$EU_POLICY"
    EU_SKIP_ACTIVE=1
    mods "Xiaomi.eu: skip China-only GMS/translation/region/notification patches"
fi

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

    if [[ "$EU_SKIP_ACTIVE" == "1" ]] &&
       eu_skip_mod "${script#"$work_dir/bin/modfile/"}"; then
        mods "Xiaomi.eu: SKIP ${script#"$work_dir/bin/modfile/"}"
        continue
    fi

    if [[ $skip == false ]]; then
        if ! bash "$script"; then
            error "Universal mod failed: $script"
            exit 1
        fi
    fi
done < <(find "$TARGET_DIR" -type f -name "*.sh" | LC_ALL=C sort)
