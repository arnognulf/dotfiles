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

[[ -f ~/.config/user-dirs.dirs ]] || xdg-user-dirs-update
. ~/.config/user-dirs.dirs

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
case $((16#$(\echo -n "${HOSTNAME}"|\sum|\cut -c1))) in
0|5) _PROMPTHOSTDOT="\[\e[102m\]⬤ \[\e[0;7m\]";;
1|6) _PROMPTHOSTDOT="\[\e[103m\]⬤ \[\e[0;7m\]";;
2|7) _PROMPTHOSTDOT="\[\e[104m\]⬤ \[\e[0;7m\]";;
3|8) _PROMPTHOSTDOT="\[\e[105m\]⬤ \[\e[0;7m\]";;
4|9) _PROMPTHOSTDOT="\[\e[106m\]⬤ \[\e[0;7m\]";;
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
        \echo -ne "\e[J\n\n" 
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
  trap "_PROMPT_CTRLC=1;\echo -n" INT
  trap "_PROMPT_CTRLC=1;\echo -n" ERR
  LC_ALL=C stty echo 2>/dev/null
  history -a
  \echo -ne "\e]11;#${BGCOLOR}\a\e]10;#${FGCOLOR}\a\e]12;#${FGCOLOR}\a"
}

function _PREEXEC ()
{
_TIMER_CMD="${1/$(\echo -ne '\\\\a')/\\\\\a}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\b')/\\\\\b}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\c')/\\\\\c}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\d')/\\\\\d}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\e')/\\\\\e}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\f')/\\\\\f}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\g')/\\\\\g}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\h')/\\\\\h}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\i')/\\\\\i}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\j')/\\\\\j}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\k')/\\\\\k}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\l')/\\\\\l}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\m')/\\\\\m}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\n')/\\\\\n}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\o')/\\\\\o}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\p')/\\\\\p}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\q')/\\\\\q}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\r')/\\\\\r}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\s')/\\\\\s}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\t')/\\\\\t}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\u')/\\\\\u}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\v')/\\\\\v}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\w')/\\\\\w}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\x')/\\\\\x}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\y')/\\\\\y}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\z')/\\\\\z}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\033')/<ESC>}"
_TIMER_CMD="${_TIMER_CMD/$(\echo -ne '\\\\007')/<BEL>}"
(
case "${_TIMER_CMD}" in
"c "*|"cd "*|".."*) :;;
*)
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
case "${_TIMER_CMD}" in
"serial"*)
LINE="💻  serial"
;;
*)
LINE="${CHAR}  ${_TIMER_CMD}"
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
_title "$LINE"
fi
)
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
if [ ${_MEASURE-0} -gt 0 -a ${DIFF} -gt 29 ]
then
SECONDS_M=$((DIFF % 3600))

DURATION_H=$((DIFF / 3600))
DURATION_M=$((SECONDS_M / 60))
DURATION_S=$((SECONDS_M % 60))
\echo -ne "\n\aCommand took "
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
#if [ ${TERM} = linux ]
#then
#local CHAR="_"
#command echo -ne "\e[0m"
#else
local CHAR=" "
#fi
_PROMPT_FLOW_90 ()
{
# flow rotated 90 degrees
_PROMPT_LUT=("187;89;149" "182;77;136" "186;82;136" "240;162;179" "240;142;153" "238;78;92" "226;64;80" "225;65;84" "233;74;97" "235;80;104" "237;87;108" "238;101;113" "240;106;114" "242;111;116" "243;120;121" "244;133;130" "245;153;145" "246;169;157" "246;180;164" "247;186;169" "247;173;161" "247;180;168" "246;208;198" "246;218;212" "247;220;218" "247;220;221" "247;219;222" "246;218;220" "246;221;222" "189;216;211" "168;212;202" "168;212;202" "165;212;202" "164;212;202" "165;211;202" "155;210;203" "139;205;204" "107;189;202" "109;195;212" "124;208;225" "132;212;227" "150;216;227" "157;217;227" "152;217;226" "140;216;223" "129;213;219" "109;206;213" "92;200;208" "115;209;212" "90;200;206" "75;191;199" "71;188;196" "107;206;210" "121;213;216" "117;211;214" "112;208;211" "61;162;179" "40;146;168" "31;141;164" "24;125;154" )
}
_PROMPT_FLOW ()
{
# https://basicappleguy.com/haberdashery/flow
_PROMPT_LUT=("8;72;126" "8;73;127" "8;73;127" "8;72;127" "9;70;125" "11;70;125" "13;70;125" "17;65;121" "25;65;122" "39;73;134" "48;81;144" "51;106;162" "50;145;187" "54;146;189" "60;134;185" "66;125;182" "73;118;179" "83;114;177" "114;122;182" "198;172;212" "198;141;187" "205;134;182" "210;108;158" "227;118;157" "236;149;173" "237;174;189" "241;185;197" "243;198;206" "245;209;215" "246;215;220" "246;219;223" "246;220;224" "246;219;223" "247;218;219" "247;217;216" "248;215;212" "248;213;206" "248;210;200" "248;209;196" "248;210;195" "247;214;196" "247;214;192" "247;213;187" "247;212;181" "247;210;173" "247;203;162" "247;195;152" "246;190;148" "245;192;154" "244;197;161" "244;201;165" "245;202;160" "247;203;153" "247;203;147" "248;204;141" "248;205;138" "248;205;135" "249;204;132" "249;175;100" "249;151;69" )
}
_PROMPT_FLOW_90
_PROMPT_FAUXFUR ()
{
# https://basicappleguy.com/haberdashery/faux-fur
_PROMPT_LUT=("212;158;72" "229;171;77" "237;180;84" "236;179;83" "233;173;75" "233;172;73" "226;165;67" "225;164;67" "226;166;69" "226;168;74" "230;175;83" "232;179;90" "239;186;92" "241;187;92" "233;177;82" "229;170;72" "223;163;65" "218;158;61" "214;155;60" "214;156;63" "212;154;61" "219;164;71" "221;163;68" "216;159;65" "216;161;68" "201;153;71" "192;146;66" "186;143;66" "197;149;64" "189;139;51" "144;100;29" "101;69;28" "63;41;23" "33;24;21" "32;25;20" "31;26;21" "25;21;22" "16;17;22" "17;19;22" "25;23;21" "78;55;27" "164;124;57" "212;163;77" "226;175;83" "231;184;97" "235;187;99" "230;172;73" "218;159;62" "180;126;41" "176;120;36" "168;109;25" "177;118;29" "201;142;45" "205;145;46" "198;142;47" "178;129;41" "160;118;41" "99;68;25" "46;34;21" "26;23;21" )
}
_PROMPT_TRANS_COLORS ()
{
unset _PROMPT_LUT
_PROMPT_LUT[0]="91;206;250"
_PROMPT_LUT[1]="245;169;184"
_PROMPT_LUT[2]="255;255;255"
_PROMPT_LUT[3]="${_PROMPT_LUT[1]}"
_PROMPT_LUT[4]="${_PROMPT_LUT[0]}"
}

_PROMPT_PRIDE_COLORS ()
{
unset _PROMPT_LUT
_PROMPT_LUT[0]="229;00;00"
_PROMPT_LUT[1]="255;141;00"
_PROMPT_LUT[2]="255;238;00"
_PROMPT_LUT[3]="02;129;33"
_PROMPT_LUT[4]="00;76;255"
_PROMPT_LUT[5]="119;00;136"
}

_MAKELUTNOTWAR ()
{
{
\echo -n "_PROMPT_LUT=(\""; \chafa --optimize=0 --scale=max --fg-only --symbols=solid --fill=solid "${1}" |\tail -n$((LINES / 2)) |\head -n1|LC_ALL=C \sed -e "s/$(\printf '\e')\[0m//g" -e 's/█/" "/g' -e 's/m//g' -e 's/38;2;//g' -e "s/$(\printf '\e')\[//g" -e 's/\"39$/)/g'
} >/tmp/tmp.lut
. /tmp/tmp.lut
}

_PROMPT_RAINBOW ()
{
unset _PROMPT_SUPER
_PROMPT_LUT=("254;6;0" "254;18;0" "254;31;0" "254;44;0" "254;57;0" "254;69;0" "254;82;0" "254;94;0" "254;107;0" "254;120;0" "254;133;0" "254;146;0" "254;158;0" "254;171;0" "254;184;0" "254;197;0" "254;209;0" "254;222;0" "254;235;0" "254;248;0" "241;254;0" "215;254;0" "189;254;0" "164;254;0" "139;254;0" "114;254;0" "88;254;0" "63;254;0" "37;254;0" "11;254;0" "0;254;12" "0;254;38" "0;254;63" "0;254;89" "0;254;115" "0;254;140" "0;254;166" "0;254;191" "0;254;217" "0;254;243" "0;241;254" "0;215;254" "0;189;254" "0;164;254" "0;138;254" "0;113;254" "0;87;254" "0;63;254" "0;37;254" "0;11;254" "12;0;254" "38;0;254" "64;0;254" "88;0;254" "114;0;254" "139;0;254" "165;0;254" "190;0;254" "216;0;254" "242;0;254" )
}

_PROMPT_SUPER ()
{
unset _PROMPT_SUPER
BGCOLOR=ffffff
FGCOLOR=2e3032
_PROMPT_LUT=("148;33;48" "148;33;48" "149;34;49" "149;34;49" "149;34;49" "149;34;49" "149;34;49" "149;34;49" "149;34;49" "149;34;49" "158;35;51" "178;38;57" "178;38;57" "179;38;57" "178;38;56" "176;31;43" "174;24;26" "174;24;25" "183;22;25" "211;19;26" "211;19;26" "210;19;26" "210;19;26" "210;19;26" "210;19;26" "210;19;26" "210;19;26" "210;19;26" "210;19;26" "210;19;26" "210;19;26" "211;19;26" "188;29;56" "137;51;123" "118;53;134" "104;54;138" "100;55;140" "98;56;140" "95;56;140" "92;57;141" "89;58;142" "85;59;142" "82;60;143" "78;61;142" "75;62;143" "71;63;143" "67;63;143" "62;64;143" "53;58;132" "49;57;129" "45;56;128" "40;57;127" "35;57;125" "33;58;125" "31;58;124" "31;59;122" "27;61;131" "26;62;133" "27;62;133" "27;62;133" "27;62;132" "28;61;132" "28;61;132" "28;61;132" "29;61;131" "29;61;131" "29;60;131" "30;60;130" "30;60;130" "35;55;130" "37;54;130" "37;54;130" "35;81;153" "35;93;164" "35;93;164" "35;93;164" "35;93;164" "35;93;164" "35;93;164" "35;93;164" "39;122;178" "40;128;182" "40;127;182" "40;127;182" "40;127;182" "40;127;182" "39;131;183" "31;163;202" "32;164;202" "33;164;202" "33;164;202" "34;164;202" "34;164;202" "34;164;202" "34;164;202" "35;164;202" "36;164;201" "36;165;201" "37;165;201" "6;163;201" "0;163;201" "0;163;201" "0;163;201" "0;162;201" "0;163;201" "0;163;201" "0;163;201" "0;158;141" "0;154;95" "0;154;95" "0;153;95" "0;153;95" "0;153;96" "0;153;96" "0;153;96" "0;153;96" "0;154;97" "0;154;97" "0;154;97" "1;154;97" "108;180;108" "134;186;111" "135;187;112" "135;187;112" "135;187;112" "134;186;111" "134;186;112" "130;185;109" "38;156;62" "26;140;59" "26;138;59" "26;138;59" "26;138;59" "26;138;59" "26;138;59" "26;138;59" "26;138;59" "26;138;59" "27;138;59" "37;132;70" )
}

#_PROMPT_SUPER
_PROMPT_LINE="${REVERSE}"

local ESC=$(\printf '\e')
local PRE="${ESC}[38;2;"
local POST="m"
local INDEX=0
local REVERSE="${ESC}[4m"
while [ ${INDEX} -lt ${COLUMNS} ]
do
# 16M colors broken in mosh
if [ -n "$SSH_CLIENT" ]
then
_PROMPT_LINE="${_PROMPT_LINE}${CHAR}"
else
_PROMPT_LINE="${_PROMPT_LINE}${PRE}${_PROMPT_LUT[$((${#_PROMPT_LUT[*]} * ${INDEX} / $((${COLUMNS} + 1))))]}${POST}${CHAR}"
fi
let INDEX++
done
local PWD_BASENAME="${PWD##*/}"
[ -z "${PWD_BASENAME}" ] && PWD_BASENAME=/
case ${PWD} in
${HOME}) _PROMPT_PWD_BASENAME="~";;
*) _PROMPT_PWD_BASENAME="${NAME-${PWD_BASENAME}}"
esac
local PROMPT_TEXT=" ${_PROMPTHOSTDOT}${_PROMPT_PWD_BASENAME}${_PROMPT_GIT_PS1} "$([ $UID = 0 ] && \echo "# ")

_PROMPT_TEXT=""
local INDEX=0
while [ ${INDEX} -lt ${#PROMPT_TEXT} ]
do
if [ -n "$SSH_CLIENT" ]
then
_PROMPT_TEXT="${_PROMPT_TEXT}${PROMPT_TEXT:${INDEX}:1}"
else
_PROMPT_TEXT="${_PROMPT_TEXT}\[${PRE}${_PROMPT_LUT[$((${#_PROMPT_LUT[*]} * ${INDEX} / $((${COLUMNS} + 1))))]}${POST}\]${PROMPT_TEXT:${INDEX}:1}"
fi
let INDEX++
done

PS1="\[\r\e]0;"'${TITLE}'"\a\e[0;4m"'$([ ${UID} = 0 ] && \echo -e "\e[31m")\]${_PROMPT_LINE}'"
\[\e(1\e[0;7m"'$([ ${UID} = 0 ] && \echo -e "\e[31m")'"\]${_PROMPT_TEXT}\[\e[0m\e[?25h\] "
}

PROMPT_COMMAND="_PROMPT_STOP_TIMER;_PROMPT_COMMAND;_PROMPT"


_title ()
{
[ -z "${TTY}" ] && TTY=$(tty)
[ -n "$*" ] && [ -t 0 ] && \echo -ne "\e]0;$* in ${PWD##*/} at $(date +%H:%M)\a" >${TTY}
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
_title "${ICON}  ${FIRST_ARG##*/}"
else
_title "${ICON}  ${FIRST_NON_OPTION##*/}"
fi
)
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
