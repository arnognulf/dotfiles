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

# detect _CATT_DIR
if ! [[ $_CATT_DIR ]]; then
	if [[ ${BASH_ARGV[0]} != "/"* ]]; then
		_CATT_DIR=$PWD/${BASH_ARGV[0]}
	else
		_CATT_DIR="${BASH_ARGV[0]}"
	fi

	_CATT_DIR="${_CATT_DIR%/*}"
fi
#alias c=cd "${_CATT_DIR}/chdir-all-the-things.sh"
. ${_CATT_DIR}/chdir-all-the-things.sh
		c() {
            local PREVPWD=$PWD
			_CHDIR_ALL_THE_THINGS "$@" && {
                \rm -d "$PREVPWD" &>/dev/null
				local TMP FILE
				if [[ -w "/run/user/${UID}" ]]; then
					TMP="/run/user/${UID}/ls-${RANDOM}.txt"
				else
					TMP="/tmp/ls-${RANDOM}.txt"
				fi
				for FILE in README.md README.txt README README.doc README.rst README.android README.* "READ *" "Read *" "Read *" "readme"*; do
					if [ -f "${FILE}" ]; then
						\printf "\n   \e[1;4m"
						\sed -e '/^=.*/d' -e 's/^[[:space:]]*//g' -e '/^!.*/d' -e '/^\[!.*/d' -e 's/# //g' -e 's/<[^>]*>//g' -e '/^[[:space:]]*$/d' "${FILE}" | \head -n1
						\printf "\e[0m\n"
						break
					fi
				done
				if [ -d .git ]; then
					local MAXLINES=$((LINES - 8))
				else
					local MAXLINES=$((LINES - 6))
				fi
				_LS_HIDDEN -v -C -w${COLUMNS} | \tee "${TMP}" | \head -n${MAXLINES}
				local LS_LINES=$(wc -l <$TMP)
				[ ${LS_LINES} -gt ${MAXLINES} ] && \printf "...\n"
				if [ ${LS_LINES} = 0 ]; then
					local COUNT=0
					local FILES
					for FILES in .*; do
						let COUNT++
					done
					if [ ${COUNT} -gt 2 ]; then
						_LS_HIDDEN -v -A -C -w${COLUMNS} | \tee "${TMP}" | \head -n${MAXLINES}
						local LS_LINES=$(wc -l <$TMP)
						[ ${LS_LINES} -gt ${MAXLINES} ] && \printf "...\n"
					else
						\printf "<empty>\n"
					fi
				fi
				[ -d ".git" ] && {
					\printf "\n"
					PAGER= $(type -P git) log --oneline -1 --color=never 2>/dev/null
				}
				(/bin/rm -f "${TMP}" &>/dev/null &)
			}
		}


		_LS_HIDDEN() {
			case "${PWD}" in
			${HOME}/Network/* | /run/user/*/gvfs/* | /mnt/* | /media/*)
				# do not print colors on network drives
				# this is faster since `ls(1)` do not need to run statx(2) or getdents64(2)
				# on listed files
				_MOAR ls -C "$@"
				;;
			*)
				local hide=()
				if [ -f .hidden ]; then
					while IFS="
" read -r line; do
						hide+=("--hide=${line}")
					done <.hidden
				fi
				_MOAR ls "${hide[@]}" --color=$(_DOTFILES_COLOR) "$@"
				;;
			esac
		}


