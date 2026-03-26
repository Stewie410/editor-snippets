#!/usr/bin/env bash

cleanup() {
    :
}

# shellcheck disable=SC1091
source "${BASH_LIB}/log.sh"

# level, message...|<stdin
log() { log.prety "${@}"; }

# message...
die() { log.pretty.die "${@}"; }

# cmd, [args...]
exec_log() { log.pretty.exec "${@}"; }
exec_out() { log.pretty.exec.stdout "${@}"; }
exec_err() { log.pretty.exec.stderr "${@}"; }

show_help() {
    cat << EOF
Description

USAGE: ${me} [OPTIONS]

OPTIONS:
    -h, --help      Show this help message
    -C, --cron      Do not print colored status messages
        --log FILE  Write logs to FILE (default: ~/.local/logs/${me%.*}/${me%.*})
        --debug     Write debugging logs
EOF
}

main() {
    local opts nocolor
    opts="$(getopt \
        --options hC \
        --longoptions help,cron,log:,debug \
        --name "${0##*/}" \
        -- "${@}" \
    )"

    eval set -- "${opts}"
    while true; do
        case "${1}" in
            "-h" | "--help" )   show_help; return 0;;
            "-C" | "--cron" )   nocolor="1";;
                   "--log" )    log="${2}"; shift;;
                   "--debug" )  debug="1";;
            "--" )              shift; break;;
            * )                 break;;
        esac
        shift
    done

    mkdir --parents "${log%/*}"
    touch -a "${log}"
}

# shellcheck disable=SC2034
declare nocolor debug
me="${0##*/}"
log="${HOME}/.local/logs/${me%.*}/${me%.*}.log"
trap cleanup EXIT

main "${@}"
