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
        --template "templates/print.tex" \
        --filter "filters/print.py" \
        --output "$output_file"
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

    input_file=$1
    output_file="${input_file%.*}.tex"

    convert "$input_file" "$output_file"

    echo "Converted to $output_file"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
    main "$@"
fi