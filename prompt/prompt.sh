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

XDG_DESKTOP_DIR="$HOME/"
XDG_DOWNLOAD_DIR="$HOME/Downloads"
XDG_TEMPLATES_DIR="$HOME/Templates"
XDG_PUBLICSHARE_DIR="$HOME/Public"
XDG_DOCUMENTS_DIR="$HOME/Documents"
XDG_MUSIC_DIR="$HOME/Music"
XDG_PICTURES_DIR="$HOME/Pictures"
XDG_VIDEOS_DIR="$HOME/Videos"

[[ -f ~/.config/user-dirs.dirs ]] || xdg-user-dirs-update 2>/dev/null
. ~/.config/user-dirs.dirs &>/dev/null

function _PROMPT_ALERT ()
{
( exec mplayer -quiet /usr/share/sounds/gnome/default/alerts/glass.ogg &>/dev/null & )
}

function _FASD_PROMPT_FUNC ()
{
:
}
if [ -n "${SSH_CLIENT}" ]
then
case $((16#$(command echo -n "${HOSTNAME}"|command sum|command cut -c1))) in
0|5) _PROMPTHOSTDOT="\[\033[102m\]• \[\033[0;7m\]";;
1|6) _PROMPTHOSTDOT="\[\033[103m\]• \[\033[0;7m\]";;
2|7) _PROMPTHOSTDOT="\[\033[104m\]• \[\033[0;7m\]";;
3|8) _PROMPTHOSTDOT="\[\033[105m\]• \[\033[0;7m\]";;
4|9) _PROMPTHOSTDOT="\[\033[106m\]• \[\033[0;7m\]";;
esac
fi
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
  command echo -e "\033[?25l\033[D \033[3A\033[994D\033[99D\033[K${SPACES}${ANSWER}                       \033[D "
}

function _PROMPT_COMMAND ()
{
  # disconnect other clients and resize window to current size
  ( [ -n "$TMUX" ] && { tmux detach-client -a;tmux resize-window -A; } &>/dev/null & )
  local _SOURCED=1
  # add trailing newline for last command if missing
  command printf "%$((COLUMNS-1))s\\r"
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
        if command git status &>/dev/null
        then
        CR_LEVEL=1
        else
        command echo -ne "\033[D \n\n" 
        fi
        ;;
            2) CR_LEVEL=3;command git -c color.status=always status |head -n$((LINES - 2)) | command head -n$((LINES - 4)); command echo -e "        ...\n\n";;
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
    # only append to fasd if any non navigational command is executed in cwd
    case "${_PROMPT_HISTCMD_PREV}" in
    c|cd|find|ls|l|ll)
    :
    ;;
    *)
    _FASD_PROMPT_FUNC
    esac
  fi
  _PROMPT_CTRLC=""
  HISTCMD_before_last=$_PROMPT_HISTCMD_PREV
  trap "_PROMPT_CTRLC=1;command echo -n" INT
  trap "_PROMPT_CTRLC=1;command echo -n" ERR
  stty echo 2>/dev/null
  history -a
  [ -n "${GNOME_TERMINAL_SCREEN}" ] && command echo -ne "\033]11;${BGCOLOR}\007\033]10;${FGCOLOR}\007\033]12;#312D2A\007"
}
function _PREEXEC ()
{
_TIMER_CMD="${1/$(command echo -ne '\\\\033')/<ESC>}"
_TIMER_CMD="${_TIMER_CMD/$(command echo -ne '\\\\e')/<ESC>}"
_TIMER_CMD="${_TIMER_CMD/$(command echo -ne '\\\\007')/<BEL>}"
_TIMER_CMD="${_TIMER_CMD/$(command echo -ne '\\\\a')/<BEL>}"
case "${_TIMER_CMD}" in
"c "*|"cd "*|".."*) :;;
*)
case "${_TIMER_CMD}" in
sudo*)
local CHAR="#"
;;
*)
local CHAR="🌈"
esac
(
{
case "${_TIMER_CMD}" in
"nano "*|"emacs "*|"vim "*|"v "*)
DOC=${_TIMER_CMD#  }
DOC=${DOC#* }
DOC=${DOC##*/}
LINE="📝  ${DOC}"
;;
"serial"*)
LINE="💻  serial"
;;
*)
LINE="${CHAR}  ${_TIMER_CMD} in ${PWD##*/} at "$(date +%H:%M)
esac
if [ -n "$SSH_CLIENT" ]
then
local SHORT_HOSTNAME=${HOSTNAME%%.*}
SHORT_HOSTNAME=${SHORT_HOSTNAME,,}
LINE="${LINE} on ${SHORT_HOSTNAME}"
fi
if [ -n "${SCHROOT_ALIAS_NAME}" ]
then
LINE="${LINE} on ${SCHROOT_ALIAS_NAME}"
fi
command echo -ne "\033]0;$LINE\007"
} &
)
esac
_MEASURE=1
_START_SECONDS=$SECONDS
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
case "${_TIMER_CMD%% *}" in
top|htop|vim|nano|sudo|ssh|man|info)
:
;;
*)
if [ ${_MEASURE-0} -gt 0 -a ${DIFF} -gt 29 ]
then
SECONDS_M=$((DIFF % 3600))

DURATION_H=$((DIFF / 3600))
DURATION_M=$((SECONDS_M / 60))
DURATION_S=$((SECONDS_M % 60))
command echo -ne "\n\007Command took "
DURATION=""
[ ${DURATION_H} -gt 0 ] && DURATION="${DURATION}${DURATION_H}h "
[ ${DURATION_M} -gt 0 ] && DURATION="${DURATION}${DURATION_M}m "
DURATION="${DURATION}${DURATION_S}s, finished at "$(date +%H:%M).""
command echo "${DURATION}"
( exec notify-send -a "Completed ${_TIMER_CMD}" -i terminal "${_TIMER_CMD}" "Command took ${DURATION}" & )
_PROMPT_ALERT
_PROMPT_LONGRUNNING=1
fi
esac
_MEASURE=0
  } 2>/dev/null
}

function _PROMPT_LINE ()
(
local LINE=""
if [ ${TERM} = linux ]
then
local CHAR="_"
command echo -ne "\e[0m"
else
local CHAR=" "
fi
while [ ${#LINE} -lt ${COLUMNS} ]
do
LINE="${LINE}${CHAR}"
done
command echo -n "${LINE}"
)
function _PROMPT_PWD_BASENAME ()
{
local PWD_BASENAME="${PWD##*/}"
[ -z "${PWD_BASENAME}" ] && PWD_BASENAME=/
case ${PWD} in
${HOME}) command echo -n "~";;
*) command echo "${NAME-${PWD_BASENAME}}"
esac
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
    _PROMPT_GIT_PS1=$(__git_ps1 2>/dev/null)
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
}

PROMPT_COMMAND="_PROMPT_STOP_TIMER;_PROMPT_COMMAND;_PROMPT"
PS1="\[\r\e]0;"'${TITLE}'"\a\e[0;4m"'$([ ${UID} = 0 ] && command echo -e "\e[31m")\]$(_PROMPT_LINE)'"
\[\e(1\e[0;7m"'$([ ${UID} = 0 ] && command echo -e "\e[31m")'"\] ${_PROMPTHOSTDOT}"'$(_PROMPT_PWD_BASENAME)'""'${_PROMPT_GIT_PS1}'" "'$([ $UID = 0 ] && echo "# ")'"\[\e[0m\e[?25h\] "

function name ()
{
NAME="$*"
}

function task ()
{
title "$*"

name "$*"

alias c='echo "Terminal is locked to task: ${NAME}\007";: '
alias cd='echo "Terminal is locked to task: ${NAME}\007";: '
}
