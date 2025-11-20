#!/bin/sh

# error[]
_die() {
    log emerg "${@}" >&2
    exit 1
}

_lower() {
    printf '%s\n' "${@}" \
        | tr '[:upper:]' '[:lower:]'
}

# level, message
# level, <stdin
log() {
    [ "$#" -eq 1 ] && set -- "${1}" "$(cat /dev/stdin)"
    case "$(_lower "${1}")" in
        emerg )     level="EMERGENCY"; rgb='\e[1;31mEMERGENCY\e[0m';;
        alert )     level="ALERT    "; rgb='\e[1;36mALERT\e[0m    ';;
        crit )      level="CRITICAL "; rgb='\e[1;33mCRITICAL\e[0m ';;
        err )       level="ERROR    "; rgb='\e[0;31mERROR\e[0m    ';;
        warn )      level="WARNING  "; rgb='\e[0;33mWARNING\e[0m  ';;
        notice )    level="NOTICE   "; rgb='\e[1;37mNOTICE\e[0m   ';;
        info )      level="INFO     "; rgb='\e[0;37mINFO\e[0m     ';;
        debug )     level="DEBUG    "; rgb='\e[1;35mDEBUG\e[0m    ';;
    esac
    shift

    [ -n "${nocolor}" ] && rgb="${level}"

    while [ "$#" -gt 0 ]; do
        printf '%s|%b|%s\n' "$(date --iso-8601='sec')" "${rgb}" "${1}"
        shift
    done
}

show_help() {
    cat << EOF
Description

USAGE: ${0##*/} [OPTIONS]

OPTIONS:
    -h      Show this help message
    -C      Do not use colored status messages
EOF
}

main() {
    while getopts "hC" arg; do
        case "${arg}" in
            h )     show_help; return 0;;
            C )     nocolor="1";;
            * )     _die "Unrecognized option: ${arg}";;
        esac
    done
    shift "$(( OPTIND - 1 ))"

    :
}

main "${@}"
