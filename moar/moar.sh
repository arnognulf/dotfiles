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

_MOAR_BUILTIN ()
{
    _NO_MEASURE
    if [ -t 1 ];then
        command "$@" | command less -Q -R -X -F -K -S 
    else
        command "$@"
    fi

}
alias declare="_MOAR_BUILTIN declare"

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
vdir \
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
pstree \
ps \
iconv \
xargs \
rg \
rga \
fd \
fdfind \
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
fc-list \
systemctl \
last \
ss \
tldr \
ansi2html \
ansi2txt \
2csv \
2html \
lolcat \
ip
do
if type -P "${CMD}" &>/dev/null 
then
    local BASECMD="${CMD##*/}"
    case ${BASECMD} in
    *" "*)
    eval "alias \"${BASECMD}\"=\"_MOAR \\\"${BASECMD}\\\"\""
    ;;
    *)
    eval "alias \"${BASECMD}\"=\"_MOAR ${BASECMD}\""
    esac
elif [ $(type -t "${CMD}") = "builtin" ]
then
    eval "alias \"${CMD}\"=\"_MOAR \\\"${CMD}\\\"\""
fi
done
eval "function _MOAR_d { _MOAR \"\${FUNCNAME/_MOAR_/}\" \"\$@\";}"
}
_MOAR_DEFINE
unset -f _MOAR_DEFINE
_MOAR true || PATH=$PATH:${DOTFILESDIR}/moar
_MOAR ()
{
_NO_MEASURE
if [[ -z "${FUNCNAME[1]}" ]] || { [[ "${FUNCNAME[1]}" = _ICON ]] && [[ -z "${FUNCNAME[2]}" ]]; }
then
(
unset -f _MOAR
_MOAR "$@"
)
else
"$@"
fi
}
