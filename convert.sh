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
        --defaults "configs/print.yaml" \
        --include-in-header "styles/header/print.tex" \
        --include-before-body "styles/before_body/print.tex" \
        --include-after-body "styles/after_body/print.tex" \
        --filter "filters/print.py" \
        --output "$output_file"

    echo "Converted to $output_file"
}

patch_modifs () {
    local file="$1"

    version="$(cat VERSION)"
    patchfile="patches/print/$version"

    if [[ ! -f "$patchfile" ]]
    then
        echo "No patch to apply for $version"
        return
    fi

    patch --quiet --forward <"$patchfile"

    echo "Applied patch for $version"
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
    echo "${input_file%.*}.tex"
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

    convert "$input_file" "$output_file"
    patch_modifs "$output_file"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
    main "$@"
fi
