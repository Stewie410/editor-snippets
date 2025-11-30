#!/usr/bin/env bash

cleanup() {
    exec >&6-
    exec >&7-
}

# level, message[]|<stdin
log() {
    if (( $# == 1 )); then
        mapfile -t largs
        set -- "${1}" "${largs[@]}"
        unset largs
    fi

    local level
    case "${1,,}" in
        emerg )     level="0";;
        alert )     level="1";;
        crit )      level="2";;
        err )       level="3";;
        warn )      level="4";;
        notice )    level="5";;
        info )      level="6";;
        debug )     level="7";;
    esac
    shift

    while (( $# > 0 )); do
        printf '<%d>%s\n' "${level}" "${1}" >&4
        shift
    done
}

die() {
    log emerg "${@}"
    exit 1
}

cmd_exec() {
    log debug ">> ${*}"
    (exec "${@}") 1>&6 2>&7
}

show_help() {
    cat << EOF
Description

USAGE: ${0##*/} [OPTIONS]

OPTIONS:
    -h, --help      Show this help message
EOF
}

main() {
    if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        show_help
        return 0
    fi
}

exec 6> >(log info)
exec 7> >(log err)
trap cleanup EXIT

main "${@}"
