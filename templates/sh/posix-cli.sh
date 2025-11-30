#!/bin/sh
# shellcheck disable=SC2317

# exit
_cleanup() {
    exec >&3-
    exec >&4-
    exit "${1:-0}"
}

# level, message|<stdin
log() {
    if [ "$#" -gt 1 ]; then
        short="${1}"
        shift
        printf '%s\n' "${@}" | log "${short}"
        unset short
        return 0
    fi

    case "$(printf '%s\n' "${1}" | tr '[:upper:]' '[:lower:]')" in
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

    [ -n "${nocolor}" ] && unset rgb

    while read -r REPLY; do
        stamp="$(date --iso-8601='sec')"
        printf '%s|%b%-9s\e[0m|%s\n' "${stamp}" "${rgb}" "${lvl}" "${REPLY}"
        printf '%s|%-9s|%s\n' \
            "${stamp}" "${lvl}" "${REPLY}" >> "${log:-/dev/null}"
    done
}

# message...
die() {
    log emerg "${@}" >&2
    exit 1
}

# cmd, [args]
cmd_exec() {
    if ! pipedir="$(mktemp -d)"; then
        log crit "Cannot create tempdir for exec_log(): $*" >&2
        return 1
    fi

    stdout="${pipedir}/stdout"
    stderr="${pipedir}/stderr"

    if ! mkfifo "${stdout}" "${stderr}" >/dev/null 2>&1; then
        log crit "Cannot create named pipes for exec_log(): $*" >&2
        rm -rf "${pipedir}"
        unset pipedir stdout stderr
        return 1
    fi

    log info < "${stdout}" &
    pid_stdout="$!"
    log err < "${stderr}" &
    pid_stderr="$!"

    # log debug "EXEC: $*" >/dev/null
    ( exec "${@}" ) 1>"${stdout}" 2>"${stderr}"
    result="$?"

    (
        sleep 5
        kill "${pid_stdout}" "${pid_stderr}" 2>/dev/null
    ) &
    wait "${pid_stdout}" "${pid_stderr}"

    rm -rf "${pipedir}"
    unset pipedir stdout stderr pid_stdout pid_stderr

    return "${result:-0}"
}

show_help() {
    cat << EOF
Description

USAGE: ${me} [OPTIONS]

OPTIONS:
    -h          Show this help message
    -C          Do not use colored status messages
    -L PATH     Write logs to PATH
                (default: ~/.local/log/${me%.*}/${me%.*}.log)
EOF
}

main() {
    while getopts ":hCL:" arg; do
        case "${arg}" in
            h )     show_help; return 0;;
            C )     nocolor="0";;
            L )     log="${OPTARG}";;
            "?" )   show_help >&2; return 1;;
        esac
    done
    shift "$(( OPTIND - 1 ))"

    mkdir -p "${log%/*}"
    touch -a "${log}"

    :

    return 0
}

me="${0##*/}"
log="${HOME}/.local/log/${me%.*}/${me%.*}.log"

trap '_cleanup $?' EXIT INT HUP TERM

main "${@}"
