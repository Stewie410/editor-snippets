#!/usr/bin/env bash

_cleanup() {
    rv="$?"

    log.cleanup

    return "${rv}"
}

show_help() {
    cat << EOF
{{ DESCRIPTION }}

USAGE: ${0##*/} [OPTIONS]

OPTIONS:
    -h, --help      Show this help message
        --debug     Include DEBUG in logging
EOF
}

main() {
    local opts
    opts="$(
        getopt \
            --options h \
            --longoptions help,debug \
            --name "${0##*/}" \
            -- "${@}"
    )"

    eval set -- "${opts}"
    while true; do
        case "${1}" in
            "-h" | "--help")
                show_help
                return 0
                ;;
            "--debug")
                debug="1"
                ;;
            "--")
                shift
                break
                ;;
            *)
                break
                ;;
        esac
        shift
    done

    :
}

me="${BASH_SOURCE[0]##*/}"
# LOGGER_ERR=()
# LOGGER_USE_COLOR="auto"
# LOGGER_EXTENDED_FD="1"
# LOGGER_DEBUG="1"

# shellcheck disable=SC1091
source "${BASH_LIB}/log/log.systemd.sh"

trap _cleanup EXIT

main "${@}"
