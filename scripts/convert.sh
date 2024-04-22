#!/bin/bash

set -eu

GPP_USERMODE_START='<!--#'
GPP_USERMODE_END='-->'
GPP_USERMODE_ARG_START='\B'
GPP_USERMODE_ARG_SEPARATOR=' '
GPP_USERMODE_ARG_END='-->'
GPP_USERMODE_CHARACTER_STACK='('
GPP_USERMODE_CHARACTER_UNSTACK=')'
GPP_USERMODE_NUMBER='#'
GPP_USERMODE_QUOTE=''

# Path of the script directory
# https://stackoverflow.com/a/246128
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Path of the project directory
PROJECT_DIR=$(dirname "$SCRIPT_DIR")

convert () {
    local input_file="$1"
    local output_file="$2"

    if [[ ! -f "$input_file" ]]
    then
        echo "Not such file $input_file"
        return 1
    fi

    gpp \
        -U \
            "$GPP_USERMODE_START" \
            "$GPP_USERMODE_END" \
            "$GPP_USERMODE_ARG_START" \
            "$GPP_USERMODE_ARG_SEPARATOR" \
            "$GPP_USERMODE_ARG_END" \
            "$GPP_USERMODE_CHARACTER_STACK" \
            "$GPP_USERMODE_CHARACTER_UNSTACK" \
            "$GPP_USERMODE_NUMBER" \
            "$GPP_USERMODE_QUOTE" \
        -DPRINT \
        "$input_file" \
         | \
    pandoc \
        --defaults "$PROJECT_DIR/configs/print.yaml" \
        --include-in-header "$PROJECT_DIR/styles/header/print.tex" \
        --include-before-body "$PROJECT_DIR/styles/before_body/print.tex" \
        --include-after-body "$PROJECT_DIR/styles/after_body/print.tex" \
        --filter "$PROJECT_DIR/filters/print.py" \
        --output "$PWD/$output_file"

    echo "Converted to $output_file"
}

patch_modifs () {
    local output_file_diff="$1"

    patchfile="$PROJECT_DIR/patches/print/$output_file_diff"

    if [[ ! -f "$patchfile" ]]
    then
        echo "No patch to apply"
        return
    fi

    # patch
    # Note: If there are parts of the patch that cannot be applied, the patch
    # command returns non-0 and stores them in a specific reject file. First,
    # the call is marked to never fail, and second, this reject file is
    # discarded.
    patch --quiet --forward --reject-file - --no-backup-if-mismatch <"$patchfile" || true

    echo "Applied patch from $output_file_diff"
}

usage () {
    cat <<EOF
convert.sh [-h] FILE

Convert a Markdown file to LaTeX with pre-processing, custom filtering and custom templating.

Positional arguments:
    FILE
        Input Markdown file.

Optional arguments:
    -h
        Show this help message and exit.
EOF
}

get_out_file () {
    local input_file="$1"
    echo "$(basename ${input_file%.*}.tex)"
}

get_out_file_diff () {
    local output_file="$1"
    echo "$(basename $output_file.diff)"
}

main () {
    while getopts ":h" option
    do
        case $option in
            h) # help
                usage
                return 0
                ;;

            *)
                echo "Unknown option $OPTARG"
                usage
                return 1
                ;;
        esac
    done
    shift $((OPTIND-1))

    if [[ -z "${1+_}" ]]
    then
        echo "Missing argument"
        usage
        return 1
    fi

    local input_file="$1"
    local output_file="$(get_out_file $input_file)"
    local output_file_diff="$(get_out_file_diff $output_file)"

    convert "$input_file" "$output_file"
    patch_modifs "$output_file_diff"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
    main "$@"
fi
