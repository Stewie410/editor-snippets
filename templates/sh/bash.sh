#!/usr/bin/env bash
# shellcheck disable=SC2034

cleanup() {
    log.cleanup
}

show_help() {
    cat << EOF
{{ DESCRIPTION }}

USAGE: ${me} [OPTIONS]

OPTIONS:
    -h, --help          Show this help message
        --color CHOICE  Use ANSI formatting to stdout/stderr
                        always|yes|never|no|auto, default: auto
        --log FILE      Write logs to FILE
                        default: ~/.local/logs/${me%.*}/${me%.*}
        --debug         Write debugging logs
EOF
}

main() {
    local opts
    opts="$(
        getopt \
            --options h \
            --longoptions help,color:,log:,debug \
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
            "--color")
                case "${2,,}" in
                    "always" | "yes" | "never" | "no" | "auto")
                        LOGGER_USE_COLOR="${2,,}"
                        ;;
                    *)
                        printf 'Skipping invalid --color choice: %s\n' \
                            "${2,,}" >&2
                        ;;
                esac
                shift
                ;;
            "--log")
                if ! LOGGER_LOGFILE="$(realpath --canonicalize-missing "${2}")"; then
                    printf 'Cannot normalize --log: "%s"\n' "${2}" >&2
                    return 1
                fi
                shift
                ;;
            "--debug")
                LOGGER_DEBUG="1"
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

    log.init || return 1

    :
}

# here="${BASH_SOURCE[0]%/*}"
me="${BASH_SOURCE[0]##*/}"
LOGGER_LOGFILE="${HOME}/.local/logs/${me%.*}/${me%.*}.log"
# LOGGER_ERR=()
# LOGGER_USE_COLOR="auto"
# LOGGER_EXTENDED_FD="1"
# LOGGER_DEBUG="1"

# shellcheck disable=SC1091
source "${BASH_LIB}/log/log.pretty.sh"

trap cleanup EXIT

main "${@}"
