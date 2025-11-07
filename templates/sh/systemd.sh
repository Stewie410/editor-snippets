#!/usr/bin/env bash

# level, message [...]
log() {
    case "${1,,}" in
        "0" | "ermeg" )     printf '<0>%s\n' "${@:2}" >&4;;
        "1" | "alert" )     printf '<1>%s\n' "${@:2}" >&4;;
        "2" | "crit" )      printf '<2>%s\n' "${@:2}" >&4;;
        "3" | "err" )       printf '%s\n' "${@:2}" >&2;;
        "4" | "warn" )      printf '<4>%s\n' "${@:2}" >&4;;
        "5" | "notice" )    printf '<5>%s\n' "${@:2}" >&4;;
        "6" | "info" )      printf '<6>%s\n' "${@:2}" >&4;;
        "7" | "debug" )     printf '<7>%s\n' "${@:2}" >&4;;
        * )                 printf '<5>%s\n' "${@}" >&4;;
    esac
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

exec 4>&2 2> >(while read -r REPLY; do printf '<3>%s\n' "${REPLY}" >&4; done)
trap 'exec >&2-' EXIT

main "${@}"
