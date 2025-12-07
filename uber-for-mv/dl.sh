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

main() {
	DIR="$1"
	PATTERN=$2
	if [[ $PATTERN ]]; then
		for FILE in ${DIR}/*; do
			case "$FILE" in
			${DIR}/*${PATTERN}*)
				MATCH_FILE="$FILE"
				break
				;;
            *)
                echo "COMPUTER SAYS NO"
                return 1
			esac
		done
		echo -e "${MATCH_FILE##*/}"
		if [[ -w "${DIR}" ]]; then
			mv "${MATCH_FILE}" .
		else
			if type -P pv &>/dev/null; then
				pv "${MATCH_FILE}" >"${MATCH_FILE##*/}"
			else
				dd status=progress if="${MATCH_FILE}" of="${MATCH_FILE##*/}"
			fi
		fi
	else
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
                [[ -e "${NEWEST_FILE}" ]] || { echo "COMPUTER SAYS NO"; exit 1;}
				echo -e "${NEWEST_FILE##*/}"
				if [[ -w "${DIR}" ]]; then
					mv "${NEWEST_FILE}" .
				else
					if type -P pv &>/dev/null; then
						pv "${NEWEST_FILE}" >"${NEWEST_FILE##*/}"
					else
						dd status=progress if="${NEWEST_FILE}" of="${NEWEST_FILE##*/}"
					fi
				fi
				((COUNT++))
				return 0
				;;
			esac
		done
	fi
}
main "$@"
