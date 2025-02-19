#!/bin/bash
#
# Copyright (c) 2021 Thomas Eriksson <thomas.eriksson@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# move the latest downloaded file to the current directory with the 'm' command.
_SPINNER_START() {
	kill -9 "${_SPINNER_PID}" &>/dev/null
	unset _SPINNER_PID
	_SPINNER_PID_FILE=$(mktemp)
	(
		SPINNER() {
			{
				\echo $! >"${_SPINNER_PID_FILE}"
				\printf "\\e[?25l"
				while sleep 0.04 && [ -f "${_SPINNER_PID_FILE}" ]; do
					\printf "\\r\\e[J"
					sleep 0.04
					[ -f "${_SPINNER_PID_FILE}" ] && \printf "\\r\\e[J  ."
					sleep 0.04
					[ -f "${_SPINNER_PID_FILE}" ] && \printf "\\r\\e[J .."
					sleep 0.04
					[ -f "${_SPINNER_PID_FILE}" ] && \printf "\\r\\e[J..."
					sleep 0.04
					[ -f "${_SPINNER_PID_FILE}" ] && \printf "\\r\\e[J.. "
					sleep 0.04
					[ -f "${_SPINNER_PID_FILE}" ] && \printf "\\r\\e[J.  "
				done
			} >&2 | tee 2>/dev/null
		}
		SPINNER &
	)
	while [[ -n ${_SPINNER_PID} ]]; do
		sleep 0.1
		read _SPINNER_PID <_SPINNER_PID_FILE
	done
}

_SPINNER_STOP() {
	{
		/bin/rm -f "${_SPINNER_PID_FILE}"
		kill -9 "${_SPINNER_PID}"
		unset _SPINNER_PID_FILE _SPINNER_PID
	} &>/dev/null
	\printf "\\r\\e[J" >&2 | tee 2>/dev/null
}

_UBER_FOR_MV() {
	if [[ "$1" ]]; then
		DIR="$1"
	else
		DIR="$(xdg-user-dir DOWNLOAD)"
	fi
	while true; do
		local NEWEST_FILE
		local FILE
		NEWEST_FILE=
		local CAN_MOVE=0
		while [ "${CAN_MOVE}" = 0 ]; do
			for FILE in "${DIR}"/*; do
				if [[ -z ${NEWEST_FILE} || ${FILE} -nt ${NEWEST_FILE} ]]; then
					NEWEST_FILE=${FILE}
				fi
				case "${NEWEST_FILE}" in
				*.part | *.crdownload)
					if [[ -z $ONCE ]]; then
						echo -e "waiting for ${NEWEST_FILE} to be completed..."
						ONCE=1
					fi
					;;
				*)
					CAN_MOVE=1
					;;
				esac
			done
		done
		case "${NEWEST_FILE}" in
		*.crdownload | *.part)
			sleep 1
			;;
		*)
			echo -e "${NEWEST_FILE##*/}"
			if [[ -w "${DIR}" ]]; then
				mv "${NEWEST_FILE}" .
			else
				pv "${NEWEST_FILE}" >"${NEWEST_FILE##*/}" 2>/dev/null || dd status=progress if="${NEWEST_FILE}" of="${NEWEST_FILE##*/}"

			fi
			((COUNT++))
			return 0
			;;
		esac
	done
}
_UBER_FOR_MV "$@"
