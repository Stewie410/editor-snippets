#!/bin/sh

log() {
    printf '%s|%s\n' "$(date --iso-8601=sec)" "${1}" \
        | tee --append "${log:-/dev/null}" \
        | cut --fields="2-" --delimiter="|"
}

show_help() {
    cat << EOF
Description

USAGE: ${0##*/} [OPTIONS]

OPTIONS:
    -h      Show this help message
EOF
}

main() {
    while getopts ":h" arg; do
        case "${arg}" in
            h )     show_help; return 0;;
            # o )     var="${OPTARG}";;
            * )     show_help >&2; return 1;;
        esac
    done
    shift "$(( OPTIND - 1 ))"

    mkdir --parents "${log%/*}"
    touch -a "${log}"
}

log="${HOME}/.local/logs/$(basename "${0%.*}").log"
here="$(cd "$(dirname "${@}")" && pwd)"

main "${@}"
