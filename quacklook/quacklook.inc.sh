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

# This project enables these features for most non-interactive commands:
# * Invoke less if output is connected to stdout and is more than one screen
# * Convert input if possible to text,csv, or ascii graphic in readable format
#   videos will be played in ascii output, music will be played
# * Pipes are not affected by moar (except for conversion)
# * Moar-ified commands can be disabled by prepending backslash: '\' : eg. \grep

# detect _QUACKLOOK_DIR
if ! [[ $_QUACKLOOK_DIR ]]; then
	if [[ ${BASH_ARGV[0]} != "/"* ]]; then
		_QUACKLOOK_DIR=$PWD/${BASH_ARGV[0]}
	else
		_QUACKLOOK_DIR="${BASH_ARGV[0]}"
	fi

	_QUACKLOOK_DIR="${_QUACKLOOK_DIR%/*}"
fi

alias d="_ICON 🦆 _NO_MEASURE ${_QUACKLOOK_DIR}/quacklook.sh"
alias quacklook="_ICON 🦆 _NO_MEASURE ${_QUACKLOOK_DIR}/quacklook.sh"
_FUZZY_QUACKLOOK ()
{
local tmp=$(${_QUACKLOOK_DIR}/quacklook.sh "$@"|grep -E -v "$^"|grep -E -v "Script started"|grep -E -v "Script done"|fzf --no-mouse --tac)
f=$(for line in $tmp; do printf "%s\n" $line;done|fzf --no-mouse --tac)
[ -n "$f" ] && \echo "f=$f"
}
alias dz="_ICON 🦆 _FUZZY_QUACKLOOK"

