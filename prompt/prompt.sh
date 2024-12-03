#!/bin/bash
#
# Copyright (c) Thomas Eriksson <thomas.eriksson@gmail.com>
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

# detect _MONORAIL_DIR
if ! [[ $_MONORAIL_DIR ]]; then
	if [[ ${BASH_ARGV[0]} != "/"* ]]; then
		_MONORAIL_DIR=$PWD/${BASH_ARGV[0]}
    else
	    _MONORAIL_DIR="${BASH_ARGV[0]}"
	fi

	_MONORAIL_DIR="${_MONORAIL_DIR%/*}"
fi

if [[ $ZSH_NAME ]]; then
	setopt KSH_ARRAYS
	setopt prompt_subst
fi
[[ $_PROMPT_BGCOLOR ]] || _PROMPT_BGCOLOR=ffffff
[[ $_PROMPT_FGCOLOR ]] || _PROMPT_FGCOLOR=444444
[[ $TTY ]] || TTY=$(tty)

. "${_MONORAIL_DIR}"/gradient/gradient.sh

# avoid opening /dev/null for stdout/stderr for each call to 'type -P'
# this improves startup time
{
# chrt(1) sets lowest priority on Linux and FreeBSD
if type -P chrt
then
_LOW_PRIO ()
{
    chrt -i 0 "$@"
}
else
# nice(1) is a fallback with higher priority than chrt can achieve
_LOW_PRIO ()
{
    nice -n19 "$@"
}
fi
_INTERACTIVE_COMMAND ()
{
# Disable nonsensical error from shellcheck:
#In prompt.sh line 68:
# type -P "${2}" && alias "${2}=_ICON ${1} _LOW_PRIO ${2}"
#                          ^--^ SC2139 (warning): This expands when defined, not when used. Consider escaping.
#
#shellcheck disable=SC2139
type -P "${2}" && alias "${2}=_ICON ${1} ${2}"
}
_BATCH_COMMAND ()
{
#shellcheck disable=SC2139
type -P "${2}" && alias "${2}=_ICON ${1} _LOW_PRIO ${2}"
}
alias interactive_command=_INTERACTIVE_COMMAND
alias batch_command=_BATCH_COMMAND
. "${_MONORAIL_DIR}"/default_commands.sh
}
#&>/dev/null

# vendored from https://github.com/rcaloras/bash-preexec (8926de0)
. "${_MONORAIL_DIR}"/bash-preexec/bash-preexec.sh

# load system git sh prompt
[ -f /usr/lib/git-core/git-sh-prompt ] && . /usr/lib/git-core/git-sh-prompt

function _PROMPT_ALERT() {
	(exec mplayer -quiet /usr/share/sounds/gnome/default/alerts/glass.ogg &>/dev/null &)
}

# TODO: make callback
function _PROMPT_MAGIC_SHELLBALL() {
	local ANSWER
	case "${RANDOM}" in
	*[0-4])
		case "${RANDOM}" in
		*0) ANSWER="IT IS CERTAIN." ;;
		*1) ANSWER="IT IS DECIDEDLY SO." ;;
		*2) ANSWER="WITHOUT A DOUBT." ;;
		*3) ANSWER="YES – DEFINITELY." ;;
		*4) ANSWER="YOU MAY RELY ON IT." ;;
		*5) ANSWER="AS I SEE IT, YES." ;;
		*6) ANSWER="MOST LIKELY." ;;
		*7) ANSWER="OUTLOOK GOOD." ;;
		*8) ANSWER="YES." ;;
		*) ANSWER="SIGNS POINT TO YES." ;;
		esac
		;;
	*)
		case "${RANDOM}" in
		*0) ANSWER="REPLY HAZY, TRY AGAIN." ;;
		*1) ANSWER="ASK AGAIN LATER." ;;
		*2) ANSWER="BETTER NOT TELL YOU NOW." ;;
		*3) ANSWER="CANNOT PREDICT NOW." ;;
		*4) ANSWER="CONCENTRATE AND ASK AGAIN." ;;
		*5) ANSWER="DON'T COUNT ON IT." ;;
		*6) ANSWER="MY REPLY IS NO." ;;
		*7) ANSWER="MY SOURCES SAY NO." ;;
		*8) ANSWER="OUTLOOK NOT SO GOOD." ;;
		*) ANSWER="VERY DOUBTFUL." ;;
		esac
		;;
	esac
	local SPACES=""
	local i=0
	while [ ${i} -lt $((COLUMNS / 2 - ${#ANSWER} / 2)) ]; do
		SPACES="${SPACES} "
		i=$((i + 1))
	done
	\echo -e "\e[?25l\e[3A\r\e[K${SPACES}${ANSWER}"
}

function _PROMPT_COMMAND() {
	local CMD_STATUS
	CMD_STATUS=$?
	# disconnect other clients and resize window to current size
	([ -n "$TMUX" ] && {
		LC_ALL=C tmux detach-client -a
		for CLIENT in 1 2 3; do LC_ALL=C tmux -L "$CLIENT" resize-window -A; done
	} &>/dev/null &)
	local _SOURCED=1
	# add trailing newline for last command if missing
	\printf "%$((COLUMNS - 1))s\\r"
	# https://unix.stackexchange.com/questions/226909/tell-if-last-command-was-empty-in-prompt-command
	HISTCONTROL=
	_PROMPT_HISTCMD_PREV=$(fc -l -1)
	_PROMPT_HISTCMD_PREV=${_PROMPT_HISTCMD_PREV%%$'[\t ]'*}
	if [[ -z $HISTCMD_before_last ]]; then
		# initial prompt
		CR_FIRST=1
		CR_LEVEL=0
		_PROMPT_CTRLC=""
		:
	elif [[ $HISTCMD_before_last = "$_PROMPT_HISTCMD_PREV" ]]; then
		# cancelled prompt
		if [[ -z "$CR_FIRST" ]] && [[ "$CMD_STATUS" = 0 ]] && [[ -z "$_PROMPT_CTRLC" ]]; then
			case "${CR_LEVEL}" in
			0)
				_LS_HIDDEN -w${COLUMNS}
				CR_LEVEL=3
				if LC_ALL=C \git status &>/dev/null; then
					CR_LEVEL=1
				else
					\printf "\e[J\n\n"
				fi
				;;
			2)
				CR_LEVEL=3
				\git -c color.status=always status | \head -n$((LINES - 2)) | \head -n$((LINES - 4))
				\echo -e "        ...\n\n"
				;;
			*) _PROMPT_MAGIC_SHELLBALL ;;
			esac
			CR_LEVEL=$((CR_LEVEL + 1))
		fi
		unset CR_FIRST
		:
	else
		:
		unset CR_FIRST
		CR_LEVEL=0
	fi
	_PROMPT_CTRLC=""
	HISTCMD_before_last=$_PROMPT_HISTCMD_PREV
	trap "_PROMPT_CTRLC=1;\echo -n" INT
	trap "_PROMPT_CTRLC=1;\echo -n" ERR
	LC_ALL=C stty echo 2>/dev/null
	if [[ $BASH_VERSION ]]; then
		history -a
	fi

}

function preexec() {
	{
		_TIMER_CMD="${1/$(\printf '\\\\a')/\\\\\a}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\b')/\\\\\b}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\c')/\\\\\c}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\d')/\\\\\d}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\e')/\\\\\e}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\f')/\\\\\f}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\g')/\\\\\g}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\h')/\\\\\h}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\i')/\\\\\i}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\j')/\\\\\j}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\k')/\\\\\k}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\l')/\\\\\l}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\m')/\\\\\m}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\n')/\\\\\n}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\o')/\\\\\o}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\p')/\\\\\p}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\q')/\\\\\q}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\r')/\\\\\r}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\s')/\\\\\s}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\t')/\\\\\t}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\u')/\\\\\u}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\v')/\\\\\v}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\w')/\\\\\w}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\x')/\\\\\x}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\y')/\\\\\y}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\z')/\\\\\z}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\033')/<ESC>}"
		_TIMER_CMD="${_TIMER_CMD/$(\printf '\\\\007')/<BEL>}"
		(
			local CHAR
			local SHORT_HOSTNAME
			local CMD
			case "${_TIMER_CMD}" in
			"c "* | "cd "* | ".."*) : ;;
			*)
				# TODO: break out
				local DATE
				DATE=$(date +%m-%d)
				case ${DATE} in
				10-2* | 10-3*)
					CHAR=🎃
					;;
				12*)
					CHAR=🎄
					;;
				*)
					CHAR=▶️
					;;
				esac
				;;
			esac
			LINE="${CHAR}  ${_TIMER_CMD}"
			if [ -n "$TMUX" ]; then
				SHORT_HOSTNAME=${HOSTNAME%%.*}
				SHORT_HOSTNAME=${SHORT_HOSTNAME,,}
				LINE="${LINE} on ${SHORT_HOSTNAME}"
			fi
			if [ -n "${SCHROOT_ALIAS_NAME}" ]; then
				LINE="${LINE} on ${SCHROOT_ALIAS_NAME}"
			fi
			CUSTOM_TITLE=0
			local CMD=${_TIMER_CMD%% *}
			local CMD=${CMD%%;*}
			alias "${CMD}" &>/dev/null && CUSTOM_TITLE=1
			for COMMAND in "${CUSTOM_TITLE_COMMANDS[@]}"; do
				if [ "${COMMAND}" = "${_TIMER_CMD:0:${#COMMAND}}" ]; then
					CUSTOM_TITLE=1
				fi
			done
			if [ ${CUSTOM_TITLE} = 0 ]; then
				_TITLE "$LINE"
			fi
		)
		_MEASURE=1
		_START_SECONDS=$SECONDS
		if [[ $COLORTERM = truecolor ]]; then
			\printf "\e]11;#%s\a\e]10;#%s\a\e]12;#%s\a" "${_PROMPT_BGCOLOR}" "${_PROMPT_FGCOLOR}" "${_PROMPT_FGCOLOR}"
		fi
    # bypass STDOUT/STDERR
	} &>"${TTY}"
}

function _PROMPT_STOP_TIMER() {
	{
		local SECONDS_M
		local DURATION_H
		local DURATION_M
		local DURATION_S
		local CURRENT_SECONDS
		local DURATION
		CURRENT_SECONDS=${SECONDS}
		local DIFF=$((CURRENT_SECONDS - _START_SECONDS))
		if [[ ${_MEASURE-0} -gt 0 ]] && [[ ${DIFF} -gt 29 ]]; then
			SECONDS_M=$((DIFF % 3600))

			DURATION_H=$((DIFF / 3600))
			DURATION_M=$((SECONDS_M / 60))
			DURATION_S=$((SECONDS_M % 60))
			\printf "\n\aCommand took "
			DURATION=""
			[ ${DURATION_H} -gt 0 ] && DURATION="${DURATION}${DURATION_H}h "
			[ ${DURATION_M} -gt 0 ] && DURATION="${DURATION}${DURATION_M}m "
			DURATION="${DURATION}${DURATION_S}s, finished at "$(date +%H:%M).""
			\echo "${DURATION}"
			(exec notify-send -a "Completed ${_TIMER_CMD}" -i terminal "${_TIMER_CMD}" "Command took ${DURATION}" &)
			_PROMPT_ALERT
			_PROMPT_LONGRUNNING=1
		fi
		_MEASURE=0
	} 2>/dev/null
}

function title() {
	TITLE_OVERRIDE="$*"
}
_PROMPT() {
	if [ -n "${_PROMPT_LONGRUNNING}" ]; then
		TITLE="✅ Completed ${_TIMER_CMD}"
		if [ -n "$SSH_CLIENT" ]; then
			local SHORT_HOSTNAME=${HOSTNAME%%.*}
			SHORT_HOSTNAME=${SHORT_HOSTNAME,,}
			TITLE="${TITLE} on ${SHORT_HOSTNAME}"
		fi
		if [ -n "${SCHROOT_ALIAS_NAME}" ]; then
			TITLE="${TITLE} on ${SCHROOT_ALIAS_NAME}"
		fi

		unset _PROMPT_LONGRUNNING
		return 0
	fi
	local _PROMPT_REALPWD
	_PROMPT_REALPWD="${PWD}"
	case "${PWD}" in
	/run/user/*/gvfs/*) _PROMPT_GIT_PS1="" ;;
	*)
		local _PROMPT_PWD
		local _PROMPT_REPO
		_PROMPT_PWD="${PWD}"
		_PROMPT_REPO=""

		while [ -n "${_PROMPT_PWD}" ]; do
			if [ -d "${_PROMPT_PWD}/.repo" ]; then
				_PROMPT_REPO=1
				break
			fi
			_PROMPT_PWD="${_PROMPT_PWD%/*}"
		done
		_PROMPT_GIT_PS1=$(NO_TITLE=1 LC_ALL=C __git_ps1 "" 2>/dev/null)
		;;
	esac

	if [ "${TITLE_OVERRIDE}" = "" ]; then
		local SHORT_HOSTNAME=${HOSTNAME%%.*}
		if [[ $ZSH_NAME ]]; then
			SHORT_HOSTNAME=$SHORT_HOSTNAME:l
		else
			SHORT_HOSTNAME=${SHORT_HOSTNAME,,}
		fi
		if [ -n "${_PROMPT_REPO}" ]; then
			TITLE="🏗️  ${PWD##*/}"
			if [ -n "$SSH_CLIENT" ]; then
				TITLE="${TITLE} on ${SHORT_HOSTNAME}"
			fi
			if [ -n "${SCHROOT_ALIAS_NAME}" ]; then
				TITLE="${TITLE} on ${SCHROOT_ALIAS_NAME}"
			fi
		elif [ -n "${_PROMPT_GIT_PS1}" ]; then
			TITLE="🚧  ${PWD##*/}"
			if [ -n "$SSH_CLIENT" ]; then
				TITLE="${TITLE} on ${SHORT_HOSTNAME}"
			fi
			if [ -n "${SCHROOT_ALIAS_NAME}" ]; then
				TITLE="${TITLE} on ${SCHROOT_ALIAS_NAME}"
			fi
		else
			case "${PWD}" in
			*/etc | */etc/*) TITLE="️🗂️  ${PWD##*/}" ;;
			*/bin | */sbin) TITLE="️⚙️  ${PWD##*/}" ;;
			*/lib | */lib64 | */lib32) TITLE="🔩  ${PWD##*/}" ;;
			*/tmp | */tmp/* | */.cache | */.cache/*) TITLE="🚽  ${PWD##*/}" ;;
			#"${HOME}/.local/share/Trash/files"*) PROMPT_REPO=""; ️TITLE="🗑️  ${PWD##*/}";;
			"${HOME}/.local/share/Trash/files"*) TITLE="♻️  ${PWD##*/}" ;;
			/boot | /boot/*) TITLE="🥾  ${PWD##*/}" ;;
			/) TITLE="💻  /" ;;
			*/.*) TITLE="📌  ${PWD##*/}" ;;
			/media/*) TITLE="💾  ${PWD##*/}" ;;
			/proc/* | /sys/* | /dev/* | /proc | /sys | /dev) TITLE="🤖  ${PWD##*/}" ;;
			*/Documents | */Documents/* | */doc | */docs | */doc/* | */docs/* | "${XDG_DOCUMENTS_DIR}" | "${XDG_DOCUMENTS_DIR}"/*) TITLE="📄  ${PWD##*/}" ;;
			*/out | */out/*) TITLE="🚀  ${PWD##*/}" ;;
			*/src | */src/* | */sources | */sources/*) TITLE="🚧  ${PWD##*/}" ;;
			"${XDG_MUSIC_DIR}" | "${XDG_MUSIC_DIR}"/*) TITLE="🎵  ${PWD##*}" ;;
			"${XDG_PICTURES_DIR}" | "${XDG_PICTURES_DIR}"/*) TITLE="🖼️  ${PWD##*/}" ;;
			"${XDG_VIDEOS_DIR}" | "${XDG_VIDEOS_DIR}"/*) TITLE="🎬  ${PWD##*/}" ;;
			*/Downloads | */Downloads/* | "${XDG_DOWNLOAD_DIR}" | "${XDG_DOWNLOAD_DIR}"/*) TITLE="📦  ${PWD##*/}" ;;
			*) TITLE="📂  ${PWD##*/}" ;;
			esac
			case "${_PROMPT_REALPWD}" in
			"${HOME}")
				if [ -n "${SCHROOT_ALIAS_NAME}" ]; then
					TITLE="🏠  ${SCHROOT_ALIAS_NAME}"
				else
					TITLE="🏠  ${SHORT_HOSTNAME}"
				fi
				;;
			*)
				if [ -n "$SSH_CLIENT" ]; then
					TITLE="${TITLE} on ${SHORT_HOSTNAME}"
				fi
				if [ -n "${SCHROOT_ALIAS_NAME}" ]; then
					TITLE="${TITLE} on ${SCHROOT_ALIAS_NAME}"
				fi
				;;
			esac
		fi
	else
		TITLE="${TITLE_OVERRIDE}"
	fi
	if [[ "$TERM" =~ "xterm"* ]] || [ "$TERM" = "alacritty" ]; then
		CHAR="▁"
		command printf "\e[0m"
	elif [[ $TERM = vt100 ]]; then
		CHAR=$(\printf "\xF3")
	else
		CHAR="_"
	fi

	local ESC
	ESC=$(\printf '\e')
	local CR
	CR=$(\printf '\r')

	if [[ $ZSH_NAME ]]; then
		local PREHIDE='%{'
		local POSTHIDE='%}'
	else
		local PREHIDE='\['
		local POSTHIDE='\]'
	fi
	local PREFG="${ESC}[38;2;"
	local PREBG="${ESC}[48;2;"
	local POST="m"
	local INDEX=0
	if [ "$TERM" = vt100 ]; then
		_PROMPT_LINE="${ESC}#6${ESC}(0"
		_PROMPT_ATTRIBUTE="${ESC}[7m"
	else
		_PROMPT_LINE=""
	fi
	while [ ${INDEX} -lt ${COLUMNS} ]; do
		# 16M colors broken in mosh
		if [ "${TERM}" = vt100 ]; then
			if [ ${INDEX} -lt $((COLUMNS / 2)) ]; then
				_PROMPT_LINE="${_PROMPT_LINE}${CHAR}"
			else
				:
			fi
		elif [[ $TERM = "linux" ]] || [[ "$TERM" = dumb ]] || [[ $TERM = vt52 ]]; then
			_PROMPT_LINE="${_PROMPT_LINE}${CHAR}"
		elif [[ $COLORTERM = truecolor ]]; then
			_PROMPT_LINE="${_PROMPT_LINE}${PREFG}${_PROMPT_LUT[$((${#_PROMPT_LUT[*]} * INDEX / $((COLUMNS + 1))))]}${POST}${CHAR}"
		fi
		INDEX=$((INDEX + 1))
	done
	local PWD_BASENAME="${PWD##*/}"
	[ -z "${PWD_BASENAME}" ] && PWD_BASENAME=/
	case ${PWD} in
	"${HOME}") _PROMPT_PWD_BASENAME="~" ;;
	*) _PROMPT_PWD_BASENAME="${NAME-${PWD_BASENAME}}" ;;
	esac
	PROMPT_TEXT=" ${_PROMPT_PWD_BASENAME}${_PROMPT_GIT_PS1} "$([ $UID = 0 ] && \echo "# ")

	local CURSORPOS
	local RGB_CUR_COLOR
	local RGB_CUR_R
	local RGB_CUR_GB
	local RGB_CUR_G
	local RGB_CUR_B
	local HEX_CUR_COLOR

	CURSORPOS=$((${#PROMPT_TEXT} + 1))
	RGB_CUR_COLOR=${_PROMPT_LUT[$((${#_PROMPT_LUT[*]} * CURSORPOS / $((COLUMNS + 1))))]}
	RGB_CUR_R=${RGB_CUR_COLOR%%;*}
	RGB_CUR_GB=${RGB_CUR_COLOR#*;}
	RGB_CUR_G=${RGB_CUR_GB%%;*}
	RGB_CUR_B=${RGB_CUR_GB##*;}
	HEX_CUR_COLOR=$(\printf "%.2x%.2x%.2x" "${RGB_CUR_R}" "${RGB_CUR_G}" "${RGB_CUR_B}")
	[ -z "${HEX_CUR_COLOR}" ] && HEX_CUR_COLOR="${_PROMPT_FGCOLOR}"
	if [[ "$TERM" =~ "xterm"* ]] || [ "$TERM" = "alacritty" ]; then
		\printf "\e]11;#%s\a\e]10;#%s\a\e]12;#%s\a" "${_PROMPT_BGCOLOR}" "${_PROMPT_FGCOLOR}" "${HEX_CUR_COLOR}"
	fi

	_PROMPT_TEXT=""
	local INDEX=0
	while [ ${INDEX} -lt ${#PROMPT_TEXT} ]; do
		if [ "$TERM" = "vt100" ] || [ "$TERM" = "linux" ]; then
			_PROMPT_TEXT="${_PROMPT_TEXT}${PROMPT_TEXT:${INDEX}:1}"
		else
			local LUT
			LUT=$((${#_PROMPT_LUT[*]} * INDEX / $((COLUMNS + 1))))
			if [ -z "${_PROMPT_TEXT_LUT[0]}" ]; then
				local _PROMPT_TEXT_LUT
				_PROMPT_TEXT_LUT[0]=$(\printf "%d;%d;%d" "${_PROMPT_BGCOLOR:0:2}" "${_PROMPT_BGCOLOR:2:2}" "${_PROMPT_BGCOLOR:4:2}")
			fi
			local TEXT_LUT=$(((${#_PROMPT_TEXT_LUT[*]} * INDEX) / $((COLUMNS + 1))))
			_PROMPT_TEXT="${_PROMPT_TEXT}${PREHIDE}${PREBG}${_PROMPT_LUT[${LUT}]}${POST}${PREFG}${_PROMPT_TEXT_LUT[${TEXT_LUT}]}${POST}${POSTHIDE}${PROMPT_TEXT:${INDEX}:1}"
		fi
		INDEX=$((INDEX + 1))
	done

	if [[ "$TERM" =~ "xterm"* ]] || [[ "$TERM" = "alacritty" ]] || [[ "$TERM" = "vt100" ]]; then
		PS1='$(_TITLE_RAW "${TITLE}"))'"${CR}"'${_PROMPT_LINE}'"
${PREHIDE}${ESC}(1${_PROMPT_ATTRIBUTE}${POSTHIDE}${_PROMPT_TEXT}${PREHIDE}${ESC}[0m${ESC}[?25h${POSTHIDE} "
	else
		PS1='${_PROMPT_LINE}'"
${PROMPT_TEXT}| "
	fi

}

PROMPT_COMMAND[0]="_PROMPT_STOP_TIMER;_PROMPT_COMMAND;_PROMPT"
precmd() {
	eval "${PROMPT_COMMAND[0]}"
}
_TITLE_RAW() {
	if [[ -z "$NO_TITLE" ]] && [[ "$TERM" =~ "xterm"* ]] || [ "$TERM" = "alacritty" ]; then
		\printf "\e]0;%s\a" "$*" 1>"${TTY}" 2>/dev/null
	fi
}

_INIT_CONFIG() {
	if [[ -n $XDG_CONFIG_HOME ]]; then
		_MONORAIL_CONFIG="${XDG_CONFIG_HOME}/monorail"
	else
		_MONORAIL_CONFIG="${HOME}/.config/monorail"
	fi
	mkdir -p "${_MONORAIL_CONFIG}"
	unset -f _INIT_CONFIG
	if [[ ! -f "${_MONORAIL_DIR}"/colors.sh ]]; then
		cp "${_MONORAIL_DIR}"/default_colors.sh "${_MONORAIL_CONFIG}"/colors.sh
	fi
	. "${_MONORAIL_CONFIG}"/colors.sh
}
_INIT_CONFIG

_PROMPT_CONTRAST() {
	COLOR1=$1
	COLOR2=$2

	r1="$((0x${COLOR1:0:2}))"
	g1="$((0x${COLOR1:2:2}))"
	b1="$((0x${COLOR1:4:2}))"

	r2="$((0x${COLOR2:0:2}))"
	g2="$((0x${COLOR2:2:2}))"
	b2="$((0x${COLOR2:4:2}))"

	# translate sRGB to CIE XYZ (only Y-component)
	Y1=$(echo "define vp(v){v=v/255.0;if(v<=0.04045)return v/12.92; return e(2.4*l((v+0.055)/1.055)) };0.2126729*vp($r1) + 0.71515122*vp($g1) + 0.0721750*vp($b1)" | bc -l)

	Y2=$(echo "define vp(v){v=v/255.0;if(v<=0.04045)return v/12.92; return e(2.4*l((v+0.055)/1.055)) };0.2126729*vp($r2) + 0.71515122*vp($g2) + 0.0721750*vp($b2)" | bc -l)

	# the contrast is the factor K of (Y_largest + 0.05) / (Y_smallest + 0.05)
	# according to WCAG as found on https://www.leserlich.info/werkzeuge/kontrastrechner/index-en.php
	CONTRAST=$(echo "
    define int(x){auto s;s=scale=0;x/=1;scale=s;return x}
    define round(x){return int(x+0.5)}
    define max(x,y){if(x>y)return x;return y}
    define min(x,y){if(x<y)return x;return y}
    if($Y1>$Y2)($Y1 + 0.05)/($Y2 + 0.05) else ($Y2 + 0.05)/($Y1 + 0.05)" | bc -l)
	INT_CONTRAST=$(\echo "define int(x){auto s;s=scale=0;x/=1;scale=s;return x};int(${CONTRAST}*100)" | \bc -l)
	# contrast 1.5 is set sufficiently low to be visible, but high enough to avoid shooting yourself in the foot.
	if [[ ${INT_CONTRAST} -lt 150 ]]; then
		\echo "ERROR: background and foreground are too similar, try setting either background or foreground to '7f7f7f' and the other to '000000' or 'ffffff'" 1>&2 | tee 1>/dev/null
		return 1
	else
		return 0
	fi
}

_BGCOLOR() {
	# reload in case user has manually modified colors.sh
	. "${_MONORAIL_CONFIG}"/colors.sh

	if [[ "${#1}" != 6 ]]; then
		\echo "ERROR: color must be hexadecimal and 6 hexadecimal characters" 1>&2 | tee 1>/dev/null
		return 1
	fi

	_PROMPT_CONTRAST "${_PROMPT_FGCOLOR}" "$1" || return 1

	_PROMPT_BGCOLOR="$1"
	{
		declare -p _PROMPT_LUT | cut -d" " -f3-1024
		declare -p _PROMPT_TEXT_LUT | cut -d" " -f3-1024
		declare -p _PROMPT_FGCOLOR | cut -d" " -f3-1024
		declare -p _PROMPT_BGCOLOR | cut -d" " -f3-1024
	} >"${_MONORAIL_CONFIG}"/colors.sh
}

_FGCOLOR() {
	# reload in case user has manually modified colors.sh
	. "${_MONORAIL_CONFIG}"/colors.sh

	if [ "${#1}" != 6 ]; then
		\echo "ERROR: color must be hexadecimal and 6 hexadecimal characters" 1>&2 | tee 1>/dev/null
		return 1
	fi

	_PROMPT_CONTRAST "${_PROMPT_BGCOLOR}" "$1" || return 1

	_PROMPT_FGCOLOR="$1"
	{
		declare -p _PROMPT_LUT | cut -d" " -f3-1024
		declare -p _PROMPT_TEXT_LUT | cut -d" " -f3-1024
		declare -p _PROMPT_FGCOLOR | cut -d" " -f3-1024
		declare -p _PROMPT_BGCOLOR | cut -d" " -f3-1024
	} >"${_MONORAIL_CONFIG}"/colors.sh
}

alias bgcolor=_BGCOLOR
alias fgcolor=_FGCOLOR

_TITLE() {
	_TITLE_RAW "$* in ${PWD##*/} at $(date +%H:%M)"
}

_ICON() {
	local ICON="$1"
	shift
	local FIRST_ARG="${1}"
	(
		case "${FIRST_ARG}" in
		_*)
			shift
			;;
		esac
		FIRST_ARG="${1}"

		FIRST_NON_OPTION="${2}"
		while [ "${FIRST_NON_OPTION:0:1}" = '-' ] || [ "${FIRST_NON_OPTION:0:1}" = '_' ] || [ "${FIRST_NON_OPTION}" = '.' ]; do
			if [ "${FIRST_NON_OPTION}" = '-u' ]; then
				shift 2
			else
				shift
			fi
			FIRST_NON_OPTION="${2}"
		done

		if [ -z "$FIRST_NON_OPTION" ]; then
			_TITLE "${ICON}  ${FIRST_ARG##*/}"
		else
			_TITLE "${ICON}  ${FIRST_NON_OPTION##*/}"
		fi
	) &>"${TTY}"
	"$@"
}

name() {
	NAME="$*"
}

task() {
	title "$*"

	name "$*"

	alias c='echo "Terminal is locked to task: ${NAME}\a";: '
	alias cd='echo "Terminal is locked to task: ${NAME}\a";: '
}
