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

function _MOAR
{
    command rm -rf /tmp/.MOAR* &>/dev/null
    local PIPEFAIL_ENABLED
    if set -o|command egrep -q "pipefail(.*)off"
    then
        set -o pipefail
        PIPEFAIL_ENABLED=0
    else
        PIPEFAIL_ENABLED=1
    fi

    local RETURN
    local _MOAR_STDERR_FILE=/tmp/.MOAR_STDERR."${RANDOM}"
    _MEASURE=0
    if [ -z "${_SOURCED}" ]
    then
    if [ -t 1 ]
    then
        local _MOAR_STDOUT=1 
    else
        local _MOAR_STDOUT=0 
    fi
    case "${1}" in
        *grep)
        local CMD="$1"
        shift
        if [ "${_MOAR_STDOUT}" = 1 ]
        then
            command "${CMD}" --color=yes "$@" 2>${_MOAR_STDERR_FILE} | command less -R -X -F -K
            RETURN=$?
        else
            command "${CMD}" "$@"
            RETURN=$?
        fi
        ;;
        apt)
        case "${2}" in
        list|search)
            if [ "${_MOAR_STDOUT}" = 1 ]
            then
                command "$@" 2>${_MOAR_STDERR_FILE} | command less -R -X -F -K
                RETURN=$?
            else
                command "$@"
                RETURN=$?
            fi
        ;;
        *)
            command "$@"
            RETURN=$?
        esac
        ;;
        *git)
        case "$2" in
        log|diff|status|remote)
        shift
        if [ "${_MOAR_STDOUT}" = 1 ]
        then
            command git -c color.ui=always "${@}"  2>${_MOAR_STDERR_FILE} | _EMOJIFY | command less -R -X -F -K
            RETURN=$?
        else
            command git -c color.ui=never "${@}" | _EMOJIFY
            RETURN=$?
        fi
        ;;
        *)
            command "$@"
            RETURN=$?
        esac
    ;;
    less|more)
        if [ "${_MOAR_STDOUT}" = 1 ]
        then
            command "$@"
            RETURN=$?
        else
            shift
            command cat "${@}"
            RETURN=$?
        fi
        ;;
    find|od|hexdump|declare)
        if [ "${_MOAR_STDOUT}" = 1 ]
        then
            command "$@" 2>${_MOAR_STDERR_FILE} | command less -R -X -F -K
            RETURN=$?
        else
            command "$@"
            RETURN=$?
        fi
    ;;
    echo)
        if [ "${_MOAR_STDOUT}" = 1 ]
        then
            command "$@" 2>${_MOAR_STDERR_FILE} | _EMOJIFY | command less -R -X -F -K
            RETURN=$?
        else
            command "$@"| _EMOJIFY
            RETURN=$?
        fi
    ;;
    rg)
        if [ "${_MOAR_STDOUT}" = 1 ]
        then
            command "$@" --color=always 2>${_MOAR_STDERR_FILE} | command less -R -X -F -K
            RETURN=$?
        else
            command "$@" --color=never
            RETURN=$?
        fi
    ;;
    fd|fdfind)
        if [ "${_MOAR_STDOUT}" = 1 ]
        then
            command "$@" --color always 2>${_MOAR_STDERR_FILE} | command less -R -X -F -K
            RETURN=$?
        else
            command "$@" --color never
            RETURN=$?
        fi
    ;;
    *)
        if [ "${_MOAR_STDOUT}" = 1 ]
        then
            command "$@" 2>${_MOAR_STDERR_FILE} | command less -R -X -F -K
            RETURN=$?
        else
            command "$@"
            RETURN=$?
        fi
    esac
    [ -s "${_MOAR_STDERR_FILE}" ] && { command less -R -X -F -K "${_MOAR_STDERR_FILE}"; command rm ${_MOAR_STDERR_FILE};}
else
    command "$@"
    RETURN=$?
fi
    if [ "${PIPEFAIL_ENABLED}" = 0 ]
    then
        set +o pipefail
    fi
    return ${RETURN}
}

_MOAR_DEFINE ()
{
local CMD
for CMD in \
apt \
col \
colrm \
column \
hexdump \
look \
rev \
echo \
cut \
dmesg \
tsort \
xxd \
diff \
curl \
jq \
find \
tr \
comm \
cat \
tac \
grep \
egrep \
sort \
uniq \
tail \
head \
apt-cache \
sed \
ls \
git \
awk \
lsar \
lsattr \
lscpu \
lsinitramfs \
lsipc \
lslocks \
lslogins \
lsmem \
lsns \
lsof \
lspci \
lspgpot \
lsscsi \
lsusb \
netstat \
strings \
nmap \
ps \
curl \
iconv \
xargs \
rg \
fd \
fdfind \
declare \
set \
objdump \
/usr/bin/*-objdump \
nm \
/usr/bin/*-nm \
file \
/usr/bin/*sum \
fastboot \
lsblk \
lsattrib \
/usr/bin/*info* \
usb-devices \
sensors \
acpidump \
ip
do
if type -P "${CMD##*/}" &>/dev/null 
then
    local BASECMD="${CMD##*/}"
    eval "alias \"${BASECMD}\"=\"_MOAR \\\"${BASECMD}\\\"\""
fi
done
eval "function _MOAR_d { _MOAR \"\${FUNCNAME/_MOAR_/}\" \"\$@\";}"
}
_MOAR_DEFINE
unset -f _MOAR_DEFINE
