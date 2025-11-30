#!/usr/bin/env bash

cleanup() {
    exec >&3-
    exec >&4-
}

# level, message|<stdin
log() {
    if (( $# == 1 )); then
        local -a largs
        mapfile -t largs
        set -- "${1}" "${largs[@]}"
    fi

    local rgb lvl
    case "${1,,}" in
        emerg )     rgb='\e[1;31m'; lvl="EMERGENCY";;
        alert )     rgb='\e[1;36m'; lvl="ALERT";;
        crit )      rgb='\e[1;33m'; lvl="CRITICAL";;
        err )       rgb='\e[0;31m'; lvl="ERROR";;
        warn )      rgb='\e[0;33m'; lvl="WARNING";;
        notice )    rgb='\e[0;32m'; lvl="NOTICE";;
        info )      rgb='\e[1;37m'; lvl="INFO";;
        debug )     rgb='\e[1;35m'; lvl="DEBUG";;
    esac
    shift

    [[ -n "${nocolor}" ]] && unset rgb

    while (( $# > 0 )); do
        printf '%(%FT%T)T|%b%-9s\e[0m|%s|%s\n' -1 \
            "${rgb}" "${lvl}" "${FUNCNAME[1]}" "${1}"
        shift
    done | tee >(
        set --unbuffered $'s/\e[[][^a-zA-Z]*m//g' >> "${log:-/dev/null}"
    )
}

die() {
    log emerg "${@}" >&2
    exit 1
}

cmd_exec() {
    [[ -n "${debug}" ]] && log debug "RUN: ${*}" >&2
    (exec "${@}") 1>&3 2>&4
}

show_help() {
    cat << EOF
Description

USAGE: ${me} [OPTIONS]

OPTIONS:
    -h, --help      Show this help message
    -C, --cron      Do not print colored status messages
    -L, --no-log    Do not write status message to logfile
EOF
}

main() {
    local opts nocolor
    opts="$(getopt \
        --options hCL \
        --longoptions help,cron,no-log \
        --name "${0##*/}" \
        -- "${@}" \
    )"

    eval set -- "${opts}"
    while true; do
        case "${1}" in
            -h | --help )       show_help; return 0;;
            -C | --cron )       nocolor="1";;
            -L | --no-log )     log="/dev/null";;
            -- )                shift; break;;
            * )                 break;;
        esac
        shift
    done

    mkdir --parents "${log%/*}"
    touch -a "${log}"
}

exec 3> >(log info >&1)
exec 4> >(log err >&2)
me="${0##*/}"
log="${HOME}/.local/logs/${me%.*}/${me%.*}.log"
trap cleanup EXIT

main "${@}"
