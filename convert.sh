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
PANDOC_VERSION_MAJOR=2

check_pandoc_version () {
    version=$(pandoc --version | grep "^pandoc" | sed 's/pandoc \([0-9]\+\).*/\1/')

    if [[ "$version" != "$PANDOC_VERSION_MAJOR" ]]
    then
        echo "Unsupported Pandoc version: $version" >&2
        return 1
    fi
}

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
    local output_file_diff="$1"

    patchfile="patches/print/$output_file_diff"

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
    patch --quiet --forward --reject-file - <"$patchfile" || true

    echo "Applied patch from $output_file_diff"
}

build () {
    local input_file="$1"
    pdflatex -interactive=nonstopmode "$input_file"
}

usage () {
    cat <<EOF
convert.sh [-b] [-h] FILE

Convert a Markdown file to LaTeX with pre-processing, custom filtering and custom templating.

Positional arguments:
    FILE
        Input Markdown file.

Optional arguments:
    -b
        Build the generated LaTeX file with pdflatex.
    -h
        Show this help message and exit.
EOF
}

get_out_file () {
    local input_file="$1"
    echo "${input_file%.*}.tex"
}

get_out_file_diff () {
    local output_file="$1"
    echo "$output_file.diff"
}

main () {
    local enable_build=false
    while getopts ":hb" option
    do
        case $option in
            h) # help
                usage
                return 0
                ;;

            b) # build
                enable_build=true
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

    if $enable_build
    then
        build "$output_file"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
    check_pandoc_version
    main "$@"
fi
