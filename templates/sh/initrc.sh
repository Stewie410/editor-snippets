#!/bin/sh
#
# {{ SERVICE }}: {{ SUMMARY }}
#
# chkconfig:            - 98 02
# description:          {{ DESCRIPTION }}
# processname:          {{ SERVICE }}
# Required-Start:       $network
# Required-Stop:        $network
# Provides:             {{ SERVICE }}

### BEGIN INIT INFO
# Provides:             {{ SERVICE }}
# Required-Start:       $network
# Required-Stop:        $network
# Default-Start:
# Default-Stop:         0 1 2 3 4 5 6
# Short-Description:    {{ SUMMARY }}
# Description:          {{ DESCRIPTION }}
### END INIT INFO

# shellcheck disable=SC1090,SC1091
. "/etc/rc.d/init.d/functions"

prog="{{ SERVICE }}"
exec="/usr/bin/{{ SERVICE }}"

# Require binary exists
if ! [ -x "${exec}" ]; then
	printf '%s not found or nto executable: %s\n' "${prog}" "${exec}" >&2
	exit 5
fi

start() {
	# ...
	:
}

stop() {
	# ...
	:
}

restart() {
	stop
	start
}

status() {
	# ...
	:
}

case "${1}" in
"start") start ;;
"stop") stop ;;
"restart") restart ;;
"status") status ;;
*)
	printf 'Usage: %s {start|stop|status|restart|try-restart|status|test}\n' \
		"${0}"
	exit 2
	;;
esac

exit "$?"

# vi: ft=sh
