#!/bin/bash

set -eu

# Path of the script directory
# https://stackoverflow.com/a/246128
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Path of the project directory
PROJECT_DIR=$(dirname "$SCRIPT_DIR")

source "$SCRIPT_DIR/convert.sh"

get_out_file_ref () {
    local output_file="$1"
    echo ".$output_file"
}

start_patch () {
    local input_file="$1"
    local output_file="$2"
    local output_file_ref="$3"
    local output_file_diff="$4"

    # convert once and save a reference "raw" file (i.e. without current patches)
    convert "$input_file" "$output_file"
    cp "$output_file" "$output_file_ref"

    patch_modifs "$output_file_diff"
}

end_patch () {
    local input_file="$1"
    local output_file="$2"
    local output_file_ref="$3"
    local output_file_diff="$4"

    if [[ ! -f "$output_file_ref" ]]
    then
        relative_path=$(realpath --relative-to "$PWD" "$SCRIPT_DIR")
        echo "Please call \"$relative_path/generate_patch.sh $input_file start\" first!"
        return 1
    fi

    mkdir -p "$PROJECT_DIR/patches/print"

    # generate diff
    # Note: If there is an actual difference between the two files, the diff
    # command returns non-0. Consequently, the call is marked to never fail.
    diff -au "$output_file_ref" "$output_file" >"$PROJECT_DIR/patches/print/$output_file_diff" || true

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
    local output_file_diff="$(get_out_file_diff $output_file)"

    if [[ -z "${2+_}" ]]
    then
        echo "Missing argument"
        usage
        return 1
    fi

    local mode="$2"

    case $mode in
        "start")
            start_patch "$input_file" "$output_file" "$output_file_ref" "$output_file_diff"
            echo "You can modify $output_file for final edits"
            return 0
            ;;

        "end")
            end_patch "$input_file" "$output_file" "$output_file_ref" "$output_file_diff"
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
