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

input_file=$1
output_file="${input_file%.*}.tex"

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
