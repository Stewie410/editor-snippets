#!/bin/sh
# shellcheck disable=SC2317,SC2034

# exit
_cleanup() {
	exit "${1:-0}"
}

show_help() {
	cat << EOF
{{ DESCRIPTION }}

USAGE: ${me} [OPTIONS]

OPTIONS:
    -h, --help      Show this help message
        --color CHOICE  Use ANSI formatting
                        always|yes|never|no|auto, default: auto
        --log PATH      Write logs to PATH
                        default: ~/.local/logs/${me%.*}/${me%.*}.log
        --debug         Write debugging logs
EOF
}

# args[]?
parse_args() {
	while [ "$#" -gt 0 ]; do
		case "${1}" in
		"--help")
			show_help
			exit 0
			;;
		"--color" | "--color="*)
			case "${1}" in
			"--color")
				choice="${2:-auto}"
				shift
				;;
			"--color="*)
				choice="${1#*=}"
				choice="${choice#*[[:punct:]]}"
				choice="${choice%[[:punct:]]*}"
				;;
			esac

			choice="$(printf '%s' "${choice:-auto}" | tr '[:upper:]' '[:lower:]')"
			case "${choice}" in
			"always" | "yes" | "never" | "no" | "auto")
				LOGGER_USE_COLOR="${choice}"
				;;
			*)
				printf 'Ignoring invalid --color choice: %s\n' "${choice}" >&2
				;;
			esac
			unset choice
			;;
		"--log" | "--log="*)
			case "${1}" in
			"--log")
				choice="${2}"
				shift
				;;
			"--log="*)
				choice="${1#*=}"
				choice="${choice#*'"'}"
				choice="${choice#*"'"}"
				choice="${choice%'"'*}"
				choice="${choice%"'"*}"
				;;
			esac
			LOGGER_LOGFILE="${choice}"
			unset choice
			;;
		"--debug")
			LOGGER_DEBUG="1"
			;;
		"--")
			shift
			break
			;;
		"--"*)
			printf 'Unknown option: %s\n' "${1}" >&2
			return 1
			;;
		"-"*)
			optchars="${1#-}"
			while [ -n "${optchars}" ]; do
				opt="${optchars%"${optchars#?}"}"
				optchars="${optchars#?}"
				case "${opt}" in
				"h")
					show_help
					exit 0
					;;
				*)
					printf 'Unknown option: -%s\n' "${opt}" >&2
					return 1
					;;
				esac
			done
			unset optchars opt
			;;
		"*")
			break
			;;
		esac
		shift
	done
}

main() {
	parse_args "${@}"
	log_init || return 1

	:
}

# here="$(cd "$(dirname "${0}")"; pwd)"
me="$(basename "${0}")"
LOGGER_LOGFILE="${HOME}/.local/logs/${me%.*}/${me%.*}.log"
# LOGGER_ERR="$(mktemp)"
# LOGGER_USE_COLOR="auto"
# LOGGER_DEBUG="1"

# shellcheck disable=SC1091
. "${BASH_LIB}/log/log.posix.sh"

trap '_cleanup $?' EXIT
main "${@}"
