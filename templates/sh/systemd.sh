#!/usr/bin/env bash

# level, message [...]
# level, <stdin
log() {
    set -- "${1}" "${2:-$(</dev/stdin)}" "${@:3}"
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
