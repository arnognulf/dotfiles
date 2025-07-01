#!/bin/bash
_MOAR_BUILTIN(){
_NO_MEASURE
if [ -t 1 ];then
command "$@"|\less -Q -R -X -F -K -S
else
command "$@"
fi
}
alias declare="_MOAR_BUILTIN declare"
_MOAR_DEFINE(){
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
ip;do
if type -P "$CMD" &>/dev/null;then
local BASECMD="${CMD##*/}"
case $BASECMD in
*" "*)eval "alias \"$BASECMD\"=\"_MOAR \\\"$BASECMD\\\"\""
;;
*)eval "alias \"$BASECMD\"=\"_MOAR $BASECMD\""
esac
elif [ $(type -t "$CMD") = "builtin" ];then
eval "alias \"$CMD\"=\"_MOAR \\\"$CMD\\\"\""
fi
done
eval 'function _MOAR_d { _MOAR "${FUNCNAME/_MOAR_/}" "$@";}'
}
_MOAR_DEFINE
unset -f _MOAR_DEFINE
_MOAR true||PATH=$PATH:$DOTFILESDIR/moar
_MOAR(){
_NO_MEASURE
if [[ -z $_MONORAIL_NOSTYLING ]]&&{ [[ -z ${FUNCNAME[1]} ]]||{ [[ ${FUNCNAME[1]} == "_ICON" ]]&&[[ -z ${FUNCNAME[2]} ]];}||[[ ${FUNCNAME[1]} == "_LS_HIDDEN" ]];};then
(unset -f _MOAR
_MOAR "$@")
else
"$@"
fi
}
