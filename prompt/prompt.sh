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

# TODO: move out
XDG_DESKTOP_DIR="$HOME/"
XDG_DOWNLOAD_DIR="$HOME/Downloads"
XDG_TEMPLATES_DIR="$HOME/Templates"
XDG_PUBLICSHARE_DIR="$HOME/Public"
XDG_DOCUMENTS_DIR="$HOME/Documents"
XDG_MUSIC_DIR="$HOME/Music"
XDG_PICTURES_DIR="$HOME/Pictures"
XDG_VIDEOS_DIR="$HOME/Videos"
[[ -f ~/.config/user-dirs.dirs ]] || xdg-user-dirs-update
. ~/.config/user-dirs.dirs

function _PROMPT_ALERT ()
{
( exec mplayer -quiet /usr/share/sounds/gnome/default/alerts/glass.ogg &>/dev/null & )
}

# TODO: make callback
function _PROMPT_MAGIC_SHELLBALL ()
{
  local ANSWER
  case "${RANDOM}" in
  *[0-4])
  case "${RANDOM}" in
  *0) ANSWER="IT IS CERTAIN.";;
  *1) ANSWER="IT IS DECIDEDLY SO.";;
  *2) ANSWER="WITHOUT A DOUBT.";;
  *3) ANSWER="YES – DEFINITELY.";;
  *4) ANSWER="YOU MAY RELY ON IT.";;
  *5) ANSWER="AS I SEE IT, YES.";;
  *6) ANSWER="MOST LIKELY.";;
  *7) ANSWER="OUTLOOK GOOD.";;
  *8) ANSWER="YES.";;
  *)  ANSWER="SIGNS POINT TO YES.";;
  esac
  ;;
  *)
  case "${RANDOM}" in
  *0) ANSWER="REPLY HAZY, TRY AGAIN.";;
  *1) ANSWER="ASK AGAIN LATER.";;
  *2) ANSWER="BETTER NOT TELL YOU NOW.";;
  *3) ANSWER="CANNOT PREDICT NOW.";;
  *4) ANSWER="CONCENTRATE AND ASK AGAIN.";;
  *5) ANSWER="DON'T COUNT ON IT.";;
  *6) ANSWER="MY REPLY IS NO.";;
  *7) ANSWER="MY SOURCES SAY NO.";;
  *8) ANSWER="OUTLOOK NOT SO GOOD.";;
  *)  ANSWER="VERY DOUBTFUL.";;
  esac
  esac
  local SPACES=""
  local i=0
  while [ ${i} -lt $((${COLUMNS} / 2 - ${#ANSWER} / 2)) ]
  do
  SPACES="${SPACES} "
  let i++
  done
  \echo -e "\e[?25l\e[3A\r\e[K${SPACES}${ANSWER}"
}

function _PROMPT_COMMAND ()
{
  # disconnect other clients and resize window to current size
  ( [ -n "$TMUX" ] && { LC_ALL=C tmux detach-client -a;for CLIENT in 1 2 3; do LC_ALL=C tmux -L "$CLIENT" resize-window -A; done; } &>/dev/null & )
  local _SOURCED=1
  # add trailing newline for last command if missing
  \printf "%$((COLUMNS-1))s\\r"
 # https://unix.stackexchange.com/questions/226909/tell-if-last-command-was-empty-in-prompt-command
  HISTCONTROL=
  _PROMPT_HISTCMD_PREV=$(fc -l -1); _PROMPT_HISTCMD_PREV=${_PROMPT_HISTCMD_PREV%%$'[\t ]'*}
  if [[ -z $HISTCMD_before_last ]]; then
    # initial prompt
    CR_FIRST=1
    CR_LEVEL=0
    _PROMPT_CTRLC=""
    :
  elif [[ $HISTCMD_before_last = "$_PROMPT_HISTCMD_PREV" ]]; then
    # cancelled prompt
    if [ -z "$CR_FIRST" -a "$?" = 0 -a -z "$_PROMPT_CTRLC" ]; then
        case "${CR_LEVEL}" in
        0)
        _LS_HIDDEN -w${COLUMNS}
        CR_LEVEL=3;
        if LC_ALL=C \git status &>/dev/null
        then
        CR_LEVEL=1
        else
        \printf "\e[J\n\n" 
        fi
        ;;
            2) CR_LEVEL=3;\git -c color.status=always status |\head -n$((LINES - 2)) | \head -n$((LINES - 4)); \echo -e "        ...\n\n";;
            *) _PROMPT_MAGIC_SHELLBALL
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
  history -a

}

function _PREEXEC ()
{
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
case "${_TIMER_CMD}" in
"c "*|"cd "*|".."*) :;;
*)
# TODO: break out
local DATE=$(date +%m-%d)
case ${DATE} in
10-2*|10-3*)
local CHAR=🎃
;;
12*)
local CHAR=🎄
;;
*)
local CHAR=▶️
esac
esac
LINE="${CHAR}  ${_TIMER_CMD}"
if [ -n "$TMUX" ]
then
local SHORT_HOSTNAME=${HOSTNAME%%.*}
SHORT_HOSTNAME=${SHORT_HOSTNAME,,}
LINE="${LINE} on ${SHORT_HOSTNAME}"
fi
if [ -n "${SCHROOT_ALIAS_NAME}" ]
then
LINE="${LINE} on ${SCHROOT_ALIAS_NAME}"
fi
CUSTOM_TITLE=0
local CMD=${_TIMER_CMD%% *}
local CMD=${CMD%%;*}
alias ${CMD} &>/dev/null && CUSTOM_TITLE=1
for COMMAND in ${CUSTOM_TITLE_COMMANDS[@]}
do
if [ "${COMMAND}" = "${_TIMER_CMD:0:${#COMMAND}}" ]
then
CUSTOM_TITLE=1
fi
done
if [ ${CUSTOM_TITLE} = 0 ]
then
_TITLE "$LINE"
fi
)
_MEASURE=1
_START_SECONDS=$SECONDS
if [[ "$TERM" =~ "xterm"* ]] || [ "$TERM" = "alacritty" ]
then
\printf "\e]11;#${BGCOLOR}\a\e]10;#${FGCOLOR}\a\e]12;#${FGCOLOR}\a"
fi
} &>"${TTY}"
}

function _PROMPT_STOP_TIMER ()
{
  {
local SECONDS_M
local DURATION_H
local DURATION_M
local DURATION_S
local CURRENT_SECONDS
local DURATION
CURRENT_SECONDS=${SECONDS}
local DIFF=$((CURRENT_SECONDS - _START_SECONDS))
if [ ${_MEASURE-0} -gt 0 -a ${DIFF} -gt 29 ]
then
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
( exec notify-send -a "Completed ${_TIMER_CMD}" -i terminal "${_TIMER_CMD}" "Command took ${DURATION}" & )
_PROMPT_ALERT
_PROMPT_LONGRUNNING=1
fi
_MEASURE=0
  } 2>/dev/null
}

function title ()
{
TITLE_OVERRIDE="$*"
}
_PROMPT ()
{
  if [ -n "${_PROMPT_LONGRUNNING}" ]
  then
  TITLE="✅ Completed ${_TIMER_CMD}"
  if [ -n "$SSH_CLIENT" ]
  then
    local SHORT_HOSTNAME=${HOSTNAME%%.*}
    SHORT_HOSTNAME=${SHORT_HOSTNAME,,}
    TITLE="${TITLE} on ${SHORT_HOSTNAME}"
  fi
  if [ -n "${SCHROOT_ALIAS_NAME}" ]
  then
    TITLE="${TITLE} on ${SCHROOT_ALIAS_NAME}"
  fi

  unset _PROMPT_LONGRUNNING
  return 0
  fi
  local _PROMPT_REALPWD="${PWD}"
  case "${PWD}" in
  /run/user/*/gvfs/*) GIT_PS1="";;
  *)
  local _PROMPT_PWD="${PWD}"
  local _PROMPT_REPO=""
  while [ -n "${_PROMPT_PWD}" ]
  do
    if [ -d "${_PROMPT_PWD}/.repo" ]
    then
      _PROMPT_REPO=1
      break
    fi
    _PROMPT_PWD="${_PROMPT_PWD%/*}"
  done
    _PROMPT_GIT_PS1=$(LC_ALL=C __git_ps1)
  esac

if [ "${TITLE_OVERRIDE}" = "" ]
then
local SHORT_HOSTNAME=${HOSTNAME%%.*}
SHORT_HOSTNAME=${SHORT_HOSTNAME,,}
if [ -n "${_PROMPT_REPO}" ]
then
    TITLE="🏗️  ${PWD##*/}"
    if [ -n "$SSH_CLIENT" ]
    then
        TITLE="${TITLE} on ${SHORT_HOSTNAME}"
    fi 
    if [ -n "${SCHROOT_ALIAS_NAME}" ]
    then
        TITLE="${TITLE} on ${SCHROOT_ALIAS_NAME}"
    fi
elif [ -n "${_PROMPT_GIT_PS1}" ]
then
    TITLE="🚧  ${PWD##*/}"
    if [ -n "$SSH_CLIENT" ]
    then
        TITLE="${TITLE} on ${SHORT_HOSTNAME}"
    fi
    if [ -n "${SCHROOT_ALIAS_NAME}" ]
    then
        TITLE="${TITLE} on ${SCHROOT_ALIAS_NAME}"
    fi
else
case "${PWD}" in
*/etc|*/etc/*) TITLE="️🗂️  ${PWD##*/}";;
*/bin|*/sbin) TITLE="️⚙️  ${PWD##*/}";;
*/lib|*/lib64|*/lib32) TITLE="🔩  ${PWD##*/}";;
*/tmp|*/tmp/*|*/.cache|*/.cache/*) TITLE="🚽  ${PWD##*/}";;
#${HOME}"/.local/share/Trash/files"*) PROMPT_REPO=""; ️TITLE="🗑️  ${PWD##*/}";;
${HOME}"/.local/share/Trash/files"*) TITLE="♻️  ${PWD##*/}";;
/boot|/boot/*) TITLE="🥾  ${PWD##*/}";;
/) TITLE="💻  /";;
*/.*) TITLE="📌  ${PWD##*/}";;
/media/*) TITLE="💾  ${PWD##*/}";;
/proc/*|/sys/*|/dev/*|/proc|/sys|/dev) TITLE="🤖  ${PWD##*/}";;
*/Documents|*/Documents/*|*/doc|*/docs|*/doc/*|*/docs/*|${XDG_DOCUMENTS_DIR}|${XDG_DOCUMENTS_DIR}/*) TITLE="📄  ${PWD##*/}";;
*/out|*/out/*) TITLE="🚀  ${PWD##*/}";;
*/src|*/src/*|*/sources|*/sources/*) TITLE="🚧  ${PWD##*/}";;
${XDG_MUSIC_DIR}|${XDG_MUSIC_DIR}/*) TITLE="🎵  ${PWD##*}";;
${XDG_PICTURES_DIR}|${XDG_PICTURES_DIR}/*) TITLE="🖼️  ${PWD##*/}";;
${XDG_VIDEOS_DIR}|${XDG_VIDEOS_DIR}/*) TITLE="🎬  ${PWD##*/}";;
*/Downloads|*/Downloads/*|${XDG_DOWNLOAD_DIR}|${XDG_DOWNLOAD_DIR}/*) TITLE="📦  ${PWD##*/}";;
*) TITLE="📂  ${PWD##*/}";;
esac
case "${_PROMPT_REALPWD}" in
${HOME}) 
    if [ -n "${SCHROOT_ALIAS_NAME}" ]
    then
        TITLE="🏠  ${SCHROOT_ALIAS_NAME}"
    else
        TITLE="🏠  ${SHORT_HOSTNAME}"
    fi
;;
*)
if [ -n "$SSH_CLIENT" ]
then
TITLE="${TITLE} on ${SHORT_HOSTNAME}"
fi
if [ -n "${SCHROOT_ALIAS_NAME}" ]
then
TITLE="${TITLE} on ${SCHROOT_ALIAS_NAME}"
fi
esac
fi
else
TITLE="${TITLE_OVERRIDE}"
fi
if [[ "$TERM" =~ "xterm"* ]] || [ "$TERM" = "alacritty" ]
then
local CHAR="▁"
command printf "\e[0m"
elif [ $TERM = vt100 ]
then
CHAR=$(\printf "\xF3")
else
local CHAR="_"
fi

_MAKELUTNOTWAR ()
{
{
\echo -n "_PROMPT_LUT=(\""; \chafa --optimize=0 --scale=max --fg-only --symbols=solid --fill=solid "${1}" |\tail -n$((LINES / 2)) |\head -n1|LC_ALL=C \sed -e "s/$(\printf '\e')\[0m//g" -e 's/█/" "/g' -e 's/m//g' -e 's/38;2;//g' -e "s/$(\printf '\e')\[//g" -e 's/\"39$/)/g'
} >/tmp/tmp.lut
. /tmp/tmp.lut
}


local ESC=$(\printf '\e')
local CR=$(\printf '\r')
local BEL=$(\printf '\a')
local PREFG="${ESC}[38;2;"
local PREBG="${ESC}[48;2;"
local POST="m"
local INDEX=0
if [ "$TERM" = vt100 ]
then
_PROMPT_LINE="${ESC}#6${ESC}(0"
_PROMPT_ATTRIBUTE="${ESC}[7m"
else
_PROMPT_LINE=""
fi
while [ ${INDEX} -lt ${COLUMNS} ]
do
# 16M colors broken in mosh
if [ "${TERM}" = vt100 ]
then
if [ ${INDEX} -lt $((COLUMNS / 2)) ]
then
_PROMPT_LINE="${_PROMPT_LINE}${CHAR}"
else
:
fi
elif [ "${TERM}" = "linux" ]
then
_PROMPT_LINE="${_PROMPT_LINE}${CHAR}"
else
_PROMPT_LINE="${_PROMPT_LINE}${PREFG}${_PROMPT_LUT[$((${#_PROMPT_LUT[*]} * ${INDEX} / $((${COLUMNS} + 1))))]}${POST}${CHAR}"
fi
let INDEX++
done
local PWD_BASENAME="${PWD##*/}"
[ -z "${PWD_BASENAME}" ] && PWD_BASENAME=/
case ${PWD} in
${HOME}) _PROMPT_PWD_BASENAME="~";;
*) _PROMPT_PWD_BASENAME="${NAME-${PWD_BASENAME}}"
esac
PROMPT_TEXT=" ${_PROMPT_PWD_BASENAME}${_PROMPT_GIT_PS1} "$([ $UID = 0 ] && \echo "# ")

local CURSORPOS=$((${#PROMPT_TEXT} + 1 ))
local RGB_CUR_COLOR=${_PROMPT_LUT[$((${#_PROMPT_LUT[*]} * ${CURSORPOS} / $((${COLUMNS} + 1))))]}
local RGB_CUR_R=${RGB_CUR_COLOR%%;*}
local RGB_CUR_GB=${RGB_CUR_COLOR#*;}
local RGB_CUR_G=${RGB_CUR_GB%%;*}
local RGB_CUR_B=${RGB_CUR_GB##*;}
local HEX_CUR_COLOR=$(\printf "%.2x%.2x%.2x" ${RGB_CUR_R} ${RGB_CUR_G} ${RGB_CUR_B})
[ -z "${HEX_CUR_COLOR}" ] && HEX_CUR_COLOR="${FGCOLOR}"
if [[ "$TERM" =~ "xterm"* ]] || [ "$TERM" = "alacritty" ]
then
\printf "\e]11;#${BGCOLOR}\a\e]10;#${FGCOLOR}\a\e]12;#${HEX_CUR_COLOR}\a"
fi

_PROMPT_TEXT=""
local INDEX=0
while [ ${INDEX} -lt ${#PROMPT_TEXT} ]
do
if [ "$TERM" = "vt100" ] || [ "$TERM" = "linux" ]
then
_PROMPT_TEXT="${_PROMPT_TEXT}${PROMPT_TEXT:${INDEX}:1}"
else
local LUT=$((${#_PROMPT_LUT[*]} * ${INDEX} / $((${COLUMNS} + 1))))
if [ -z "${_PROMPT_TEXT_LUT[*]}" ]
then
local _PROMPT_TEXT_LUT[0]="$((16#${BGCOLOR:0:2}));$((16#${BGCOLOR:2:2}));$((16#${BGCOLOR:4:2}))"
fi
local TEXT_LUT$((${#_PROMPT_TEXT_LUT[*]} * ${INDEX} / $((${COLUMNS} + 1))))
_PROMPT_TEXT="${_PROMPT_TEXT}\[${PREBG}${_PROMPT_LUT[${LUT}]}${POST}${PREFG}${_PROMPT_TEXT_LUT[${TEXT_LUT}]}${POST}\]${PROMPT_TEXT:${INDEX}:1}"
fi
let INDEX++
done

PS1='$([[ $TERM =~ xterm* ]] && \printf "\033]0;${TITLE}\007")'"${CR}"'${_PROMPT_LINE}'"
\[${ESC}(1${_PROMPT_ATTRIBUTE}\]${_PROMPT_TEXT}\[${ESC}[0m${ESC}[?25h\] "

}

PROMPT_COMMAND="_PROMPT_STOP_TIMER;_PROMPT_COMMAND;_PROMPT"

_TITLE_RAW ()
{
if [[ "$TERM" =~ "xterm"* ]] || [ "$TERM" = "alacritty" ]
then
\printf "\e]0;$*\a" &>"${TTY}"
fi
}

_TITLE ()
{
_TITLE_RAW "$* in ${PWD##*/} at $(date +%H:%M)"
}

_ICON ()
{
local ICON="$1"
shift
local FIRST_ARG="${1}"
(
case "${FIRST_ARG}" in
_*)
shift
esac
FIRST_ARG="${1}"

FIRST_NON_OPTION="${2}"
while [ "${FIRST_NON_OPTION:0:1}" = '-' ] || [ "${FIRST_NON_OPTION:0:1}" = '_' ]|| [ "${FIRST_NON_OPTION}" = '.' ]
do
if [ "${FIRST_NON_OPTION}" = '-u' ]
then
shift 2
else
shift
fi
FIRST_NON_OPTION="${2}"
done

if [ -z "$FIRST_NON_OPTION" ]
then
_TITLE "${ICON}  ${FIRST_ARG##*/}"
else
_TITLE "${ICON}  ${FIRST_NON_OPTION##*/}"
fi
) &>"${TTY}"
"$@"
}

name ()
{
NAME="$*"
}

task ()
{
title "$*"

name "$*"

alias c='echo "Terminal is locked to task: ${NAME}\a";: '
alias cd='echo "Terminal is locked to task: ${NAME}\a";: '
}
