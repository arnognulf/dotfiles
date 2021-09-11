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

# calling 'o' without arguments will open the current folder in the file manager 
# calling 'o' with a file will try to open it with xdg-open
# calling 'o' with a program and argument will put the program in the background, debug output will be hidden.
#
# Can Opened commands can be disabled by prepending \ eg \xterm
# 
# most known graphical programs will be Can Opened.
#

function _CAN_OPENER_ALL ()
{
    local FILE
    for FILE in "$@"
    do
        ( exec xdg-open "${FILE}" &>/dev/null & )
    done
}
function _CAN_OPENER ()
{
    if [ -f "$*" ]
    then
        _CAN_OPENER_ALL "$*"
    elif [ -d "$1" ] && [ "${1/\//}" != "${1}" ]
    then
        _CAN_OPENER_ALL "$@"
    elif [ ! -d "${1}" ] && [ -x "$1" ]
    then
    local HELP
    local ARG
    HELP=0
    for ARG in "$@"
    do
    case "${ARG}" in
    -h|--help*|--version)
    HELP=1
    esac
    done
    if [ ${HELP} = 1 ]
    then
    command "$@"
    else
        ( exec "$@" &>/dev/null & )
    fi
    elif [ -f "$1" ]
    then
        _CAN_OPENER_ALL "$@"
    elif type -p "${1}" &>/dev/null
    then
    local HELP
    local ARG
    HELP=0
    for ARG in "$@"
    do
    case "${ARG}" in
    -h|--help*|--version)
    HELP=1
    esac
    done
    if [ ${HELP} = 1 ]
    then
    command "$@"
    else
    if [ "$1" = mplayer ] && command mplayer -vo null -ao null -identify -frames 0 "$2" 2>/dev/null|command grep "Video: no video" &>/dev/null
    then
        command "$@"
        return $?
    else
        ( exec "$@" &>/dev/null & )
        fi
        fi
    elif [ -n "$1" ]
    then
    case "${1,,}" in
    *".txt"|*".pdf"|*".docx"|*".cpp"|*".h"|*".c"|*".kt"|*".java")
        echo "COMPUTER SAYS NO" 1>&2 | tee /dev/null 1>/dev/null
        return 1
        ;;
    *"://"*|*"."*)
        ( exec x-www-browser "$1" &>/dev/null & )
        ;;
        *)
        echo "COMPUTER SAYS NO" 1>&2 | tee /dev/null 1>/dev/null
        return 1
    esac
    elif [ -d "$PWD" ]
    then
        _CAN_OPENER_ALL .
    else
        echo "COMPUTER SAYS NO" 1>&2 | tee /dev/null 1>/dev/null
        return 1
    fi
    return 0
}
# shellcheck disable=2139,2140
alias o &>/dev/null || alias "o"="_CAN_OPENER"

function _CMD_PARSER ()
{
local CMD
for CMD in \
/usr/bin/gnome-* \
loffice \
loimpress \
localc \
lowriter \
spotify \
firefox \
google-chrome \
google-chrome-beta \
libreoffice \
evince \
fontforge \
eog \
nautilus \
gimp \
meld \
keepassxc \
vlc \
sky \
krita \
shotwell \
darktable \
rawtherapee \
dia \
audacity \
dvdisaster \
handbrake \
dconf-editor \
display \
xv \
vinagre \
ocrfeeder \
inkscape \
/usr/bin/qemu* \
transmission-gtk \
eclipse \
gcr-viewer \
digikam \
thunderbird \
ghex \
pitivi \
karbon \
ardour \
gucharmap \
pinta \
scribus \
mypaint \
gitg \
zim \
giggle \
blender \
skype \
okular \
acroread \
mplayer \
steam \
fs-uae \
BasiliskII \
xsnow \
xvidtune \
xedit \
xbiff \
nvidia-settings \
oneko \
wireshark \
winefile \
wineconsole \
/usr/bin/calligra* \
xcalc \
xfontsel \
xload \
xmag \
xournal \
xmore \
xterm \
rxvt \
rxvt-unicode \
mlterm \
cool-retro-term \
x-www-browser \
xclipboard \
x-terminal-emulator \
86box \
alacritty \
alleyoop \
animate \
aranym \
calibre \
cheese \
chromium-browser \
discord \
dosbox \
ekiga \
emacs \
ephoto \
Eterm \
freemat \
gdebi \
gedit \
ghidra \
gv \
gvim \
herculesstudio \
hexchat \
jamovi \
kate \
teams \
kdenlive \
kdevelop \
kile \
kitty \
matlab \
midori \
mozilla \
mupdf \
netscape \
octave \
pcem \
pidgin \
qpdfview \
qtcreator \
radare2 \
rage \
remmina \
ristretto \
/usr/bin/rxvt* \
scilab \
signal \
synaptic \
telegram \
terminology \
tme \
totem \
umbrello \
uxterm \
wine \
wine64 \
winecfg \
winecmd \
x11perf \
x3270 \
xchat \
xconsole \
xemacs \
xevil \
xfterminal \
xlogo \
xmame \
xmess \
xmms \
xpdf \
xroach \
xwpe \
mpv \
gnome-mpv \
lyx \
cmake-gui \
konsole \
lxterminal \
google-earth-pro \
zoom \
paraview \
audacious \
mayavi2 \
vrrender \
grass \
qgis \
icedove \
baobab \
bijiben \
bless \
blueman \
brasero \
deja-dup \
drawing \
empathy \
geary \
evolution \
ghemical \
gip \
gnumeric \
gpaint \
grig \
gthumb \
gwyddion \
oregano \
plotdrop \
polari \
yelp \
telegnome \
sound-juicer \
signal-desktop \
wesnoth \
quake \
quake2 \
quake3 \
quake4 \
hedgewars \
obs \
alacarte \
rasmol \
gpicview \
gmsh \
pcmanfm \
spacefm \
dlt-viewer \
unison-gtk \
milkytracker \
kicad \
studio.sh \
workrave \
ico \
oclock \
xclock \
rendercheck \
transset \
xbiff \
xcalc \
xclipboard \
xconsole \
xditvie \
xedit \
VirtualBox \
VirtualBoxVM \
xeyes \
xgc \
xlogo \
xmag \
xman \
xmore \
xevil \
xoscope \
OpenHantek \
musescore \
microsoft-edge \
microsoft-edge-beta \
pulseview \
grafx2 \
file-roller \
sqlitebrowser \
netsurf \
dillo \
pycharm \
mousepad \
parole \
catfish \
thunar \
xfconf \
xfce4-appfinder \
wbar \
seahorse \
/usr/games/gnome-* \
/usr/games/sol \
/usr/games/darkplaces \
/usr/games/five-or-more \
darkplaces \
five-or-more \
four-in-a-row \
hedgewars \
hitori \
iagno \
lightsoff \
mame \
quadrapassel \
swell-foop \
gnome-disks \
tali \
slack
do
if type -P "${CMD}" &>/dev/null
then
eval function _CAN_OPENER_${CMD##*/} { if [ \"\${_SOURCED}\" = 1 ]\; then \"${CMD/_CAN_OPENER/}\" \"\${@}\"\; else o \"${CMD##*/}\" \"\${@}\"\;fi\;}
eval "alias ${CMD##*/}=_CAN_OPENER_${CMD##*/}"
fi
done
}
_CMD_PARSER
unset -f _CMD_PARSER
function _FLATPAK_PARSER ()
{
local APPLICATION
for APPLICATION in $(flatpak list --columns=application 2>/dev/null)
do
local APPLICATION_LOWER=${APPLICATION,,}
local APPLICATION_SHORT=${APPLICATION##*.}
case ${APPLICATION} in
*'.sdk'*|*'.Plugin'*|'org.gtk.'*|*'.Platform'*|*'qt5client')
:;;
*'.Client')
local APPLICATION_NAME=${APPLICATION#*.}
local APPLICATION_NAME=${APPLICATION_NAME%.*}
alias ${APPLICATION_NAME}="flatpak run ${APPLICATION}"
;;
*)
alias ${APPLICATION_SHORT}="flatpak run ${APPLICATION}"
esac
done
}
_FLATPAK_PARSER
unset -f _FLATPAK_PARSER

function _APP_PARSER ()
{
local DESKTOP_FILE
for DESKTOP_FILE in /usr/share/applications/*.desktop
do
if grep Terminal=false "${DESKTOP_FILE}" &>/dev/null
then
    local NAME=$(grep "^Name=" "${DESKTOP_FILE}"|sed -e 's/Name=//g' -e 's/ -/-/g' -e 's/- /-/g' -e 's/ /-/g' -e 's/\(.*\)/\L\1/' -e 's/(//g' -e 's/)//g' -e 's/\//∕/g' -e 's/\&/and/g' -e 's/->//g'|head -n1)
    local NAME_LOCALIZED=$(grep "^Name\[${LANG%%_*}\]=" "${DESKTOP_FILE}"|cut -d= -f2|sed -e 's/ -/-/g' -e 's/- /-/g' -e 's/ /-/g' -e 's/\(.*\)/\L\1/' -e 's/(//g' -e 's/)//g' -e 's/\//∕/g' -e 's/\&/and/g' -e 's/->//g'|head -n1)
    local COMMAND=$(grep "^Exec=" "${DESKTOP_FILE}"|sed -e 's/Exec=//g' -e 's/\%f//g' -e 's/\%F//g' -e 's/\%u//g' -e 's/\%U//g'|head -n1)
    eval alias \""${NAME}"\"=\"o ${COMMAND}\"
    test -n "${NAME_LOCALIZED}" && { eval alias \""${NAME_LOCALIZED}"\"=\"o ${COMMAND}\"; }
    NAME=""
    NAME_LOCALIZED=""
    COMMAND=""
fi
done
}
true || _APP_PARSER
unset -f _APP_PARSER
