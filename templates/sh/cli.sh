#!/usr/bin/env bash

# level, message
# level, <stdin
log() {
    set -- "${1}" "${2:-$(</dev/stdin)}" "${@:3}"

    local rgb level
    case "${1,,}" in
        emerg )     level="EMERGENCY"; rgb=$'\e[1;31mEMERGENCY\e[0m';;
        alert )     level="ALERT    "; rgb=$'\e[1;36mALERT\e[0m    ';;
        crit )      level="CRITICAL "; rgb=$'\e[1;33mCRITICAL\e[0m ';;
        err )       level="ERROR    "; rgb=$'\e[0;31mERROR\e[0m    ';;
        warn )      level="WARNING  "; rgb=$'\e[0;33mWARNING\e[0m  ';;
        notice )    level="NOTICE   "; rgb=$'\e[1;37mNOTICE\e[0m   ';;
        info )      level="INFO     "; rgb=$'\e[0;37mINFO\e[0m     ';;
        debug )     level="DEBUG    "; rgb=$'\e[1;35mDEBUG\e[0m    ';;
    esac
    shift

    (( nocolor == 1 )) && rgb="${level}"

    while (( $# > 0 )); do
        printf '%(%FT%T%z)T|%s|%s: %s\n' -1 "${rgb}" "${FUNCNAME[1]}" "${1}"
        shift
    done
}

show_help() {
    cat << EOF
Description

USAGE: ${0##*/} [OPTIONS]

OPTIONS:
    -h, --help      Show this help message
        --no-color  Do not print colored text to terminal
EOF
}

main() {
    local opts nocolor
    opts="$(getopt \
        --options h \
        --longoptions help,no-color \
        --name "${0##*/}" \
        -- "${@}" \
    )"

    eval set -- "${opts}"
    while true; do
        case "${1}" in
            -h | --help )       show_help; return 0;;
            --no-color )        nocolor="1";;
            -- )                shift; break;;
            * )                 break;;
        esac
        shift
    done

    :
}

main "${@}"
