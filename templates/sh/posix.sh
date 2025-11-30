#!/bin/sh

# shellcheck disable=SC2120
log() {
    if [ $# -gt 0 ]; then
        printf '%s\n' "${@}" | log
        return 0
    fi

    while read -r REPLY; do
        printf '%s|%s\n' "$(date --iso-8601='sec')" "${REPLY}" \
            | tee -a "${log:-/dev/null}" \
            | cut -f2- -d"|"
    done
}

show_help() {
    cat << EOF
Description

USAGE: ${me} [OPTIONS]

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

me="${0##*/}"
here="${0%/*}"
log="${HOME}/.local/logs/${me%.*}/${me%.*}"

main "${@}"
