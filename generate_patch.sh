#!/bin/bash

set -eu

source convert.sh

get_out_file_ref () {
    local output_file="$1"
    echo ".$output_file"
}

start_patch () {
    local input_file="$1"
    local output_file="$2"
    local output_file_ref="$3"

    # convert once and save a reference "raw" file (i.e. without current patches)
    convert "$input_file" "$output_file"
    cp "$output_file" "$output_file_ref"

    patch_modifs "$output_file"
}

end_patch () {
    local input_file="$1"
    local output_file="$2"
    local output_file_ref="$3"

    if [[ ! -f "$output_file_ref" ]]
    then
        echo "Please call \"generate_patch.sh $input_file start\" first!"
        return 1
    fi

    local version="$(cat VERSION)"
    mkdir -p "patches/print"

    # generate diff
    # Note: The diff command has a non 0 return value if there is an actual
    # difference between the two files. Consequently, the call is marked to
    # never fail.
    diff -au "$output_file_ref" "$output_file" >"patches/print/$version" || true

    # remove reference file
    rm --force "$output_file_ref"
}

usage () {
    cat <<EOF
generate_patch.sh [-h] FILE {start|end}

Generate a patch for the final document.

Positional arguments:
    FILE
        Input Markdown file.

Subcommands:
    start
        Start the patch generation.
    end
        Finalize the patch generation.

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

    local input_file="$1"
    local output_file="$(get_out_file $input_file)"
    local output_file_ref="$(get_out_file_ref $output_file)"

    if [[ -z "${2+_}" ]]
    then
        echo "Missing argument"
        usage
        return 1
    fi

    local mode="$2"

    case $mode in
        "start")
            start_patch "$input_file" "$output_file" "$output_file_ref"
            echo "You can modify $output_file for final edits"
            return 0
            ;;

        "end")
            end_patch "$input_file" "$output_file" "$output_file_ref"
            echo "Patch generated"
            return 0
            ;;

        *)
            echo "Unknown mode $mode"
            usage
            return 1
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
    main "$@"
fi
