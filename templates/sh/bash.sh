#!/usr/bin/env bash

cleanup() {
    :
}

log() {
    printf '%s|%s|%s\n' "$(date --iso-8601=sec)" "${FUNCNAME[1]}" "${1}" \
        | tee --append "${log:-/dev/null}" \
        | cut --fields="2-" --delimiter="|"
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
    local opts
    opts="$(getopt \
        --options h \
        --longoptions help \
        --name "${0##*/}" \
        -- "${@}" \
    )"

    eval set -- "${opts}"
    while true; do
        case "${1}" in
            -h | --help )       show_help; return 0;;
            -- )                shift; break;;
            * )                 break;;
        esac
        shift
    done

    mkdir --parents "${log%/*}"
    touch -a "${log}"
}

log="${HOME}/.local/logs/$(basename "${0%.*}").log"
trap cleanup EXIT

main "${@}"
