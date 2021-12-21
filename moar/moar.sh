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

function _MOAR_DECODE_DOC
{
    [ "${_MOAR_STDOUT}" != 1 ] && local _MOAR_COLOROPT=-c
    case "${1,,}" in
    *.cs|*.vala|*.java|*.js|*.c|*.xml|*.kt)
        if [ "${_MOAR_STDOUT}" = 1 ]
        then
            command batcat --theme=GitHub -pp --color always "${1}" || command cat "${1}"
            return 0
        fi
        ;;
    *.mk)
        if [ "${_MOAR_STDOUT}" = 1 ]
        then
            command batcat --theme=GitHub -pp --color always -l Makefile "${1}" || command cat "${1}"
            return 0
        fi
    ;;
    *.bp)
        if [ "${_MOAR_STDOUT}" = 1 ]
        then
            command batcat --theme=GitHub -pp --color always -l json "${1}" || command cat "${1}"
            return 0
        fi

    esac

    case $(command file -L "${1}") in #case2
        *" PEM certificate")
        command openssl x509 -in "${1}" -text -noout
        ;;
        *)
        case "${_MOAR_MIME}" in
        *" "text/x-c|*" "text/x-c++) 
            command batcat --theme=GitHub -pp --language=c++ --color always "${1}" || command cat "${1}"
            return 0
            ;;
        *" "text/x-ecmascript|*" "text/x-javascript|*" "text/javascript)
            command batcat --theme=GitHub -pp --language=js --color always "${1}" || command cat "${1}"
            return 0
            ;;
        *" "text/x-diff) 
            command batcat --theme=GitHub -pp --language=diff --color always "${1}" || command cat "${1}"
            return 0
            ;;
        *" "text/x-makefile) 
            command batcat --theme=GitHub -pp --language=makefile --color always "${1}" || command cat "${1}"
            return 0
            ;;
        *" "text/xml) 
            command batcat --theme=GitHub -pp --language=xml --color always "${1}" || command cat "${1}"
            return 0
            ;;
        *" "text/x-java)
            command batcat --theme=GitHub -pp --language=java -color always "${1}" || command cat "${1}"
            return 0
            ;;
        *" "text/x-sql)
            command batcat --theme=GitHub -pp --language=sql -color always "${1}" || command cat "${1}"
            return 0
            ;;
        *" "text/rtf) : ;;
        *" "text/*)
        local _MOAR_ENCODING=$(command file -L --mime-encoding "$1")
        case ${_MOAR_ENCODING} in #case3
        *": ebcdic")
        command iconv -f EBCDIC-CP-SE -t UTF-8 "${1}"
        return 0
        ;;
        *": utf-16le")
        command iconv -f UTF-16LE -t UTF-8 "${1}"
        return 0
        ;;
        *": utf-16be")
        command iconv -f UTF-16BE -t UTF-8 "${1}"
        return 0
        ;;
        *": utf-32le")
        command iconv -f UTF-32LE -t UTF-8 "${1}"
        return 0
        ;;
        *": utf-32be")
        command iconv -f UTF-32BE -t UTF-8 "${1}"
        return 0
        ;;
        *": iso-8859-1")
        command iconv -f CP437 -t UTF-8 "${1}"
        return 0
        esac #end case3
        esac
    esac #end case2

    local TEMP="/tmp/.MOAR.${RANDOM}.${1##*.}"
    if command cp -s "${PWD}/${1}" "${TEMP}" 2>/dev/null
    then
        :
    else
        command cp "${1}" "${TEMP}"  
    fi

    case "${1,,}" in
    *.htm|*.html) command elinks -dump -dump-width 80 "${TEMP}";return 0;;
    esac

    case "${1,,}" in #case1
    *.wri) command unoconv --format=doc "${TEMP}" -o "${TEMP}.doc";command pandoc -s --from=html --to=man "${TEMP}.doc";;
    *.markdown|*.mdown|*.mkdn|*.md) command pandoc -s --from=gfm --to=man "${TEMP}";;
    *.textile) command pandoc -s --from=textile --to=man "${TEMP}";;
    *.mediawiki) command pandoc -s --from=mediawiki --to=man "${TEMP}";;
    *.creole) command pandoc -s --from=creole --to=man "${TEMP}";;
    *.rdoc) command pandoc -s --from=rdoc --to=man "${TEMP}";;
    *.org) command pandoc -s --from=org --to=man "${TEMP}";;
    *.tex) command pandoc -s --from=latex --to=man "${TEMP}";;
    *.rst) command pandoc -s --from=rst --to=man "${TEMP}";;
    *.man) command cat "${1}";;
    *.asciidoc|*.adoc|*.asc) pandoc -s --from=asciidoc --to=man "${TEMP}";;
    esac > "${TEMP}.man" #end case1

    [ -s "${TEMP}.man" ] || case ${_MOAR_ENCODING} in #case994
    *": "us-ascii|*" "utf-8)
        if [ "${_MOAR_STDOUT}" = 1 ]
        then
            command batcat --theme=GitHub -pp --color always "${1}" || command cat "${1}"
            return 0
        else
            command cat "${1}"
        fi
        ;;
    *)
        command unoconv --stdout -f docx "${TEMP}" > "${TEMP}.docx" 2>/dev/null && command pandoc -s --to=man "${TEMP}.docx" > "${TEMP}.man"
    esac
    if [ -s "${TEMP}.man" ]
    then
        command nroff ${_MOAR_COLOROPT} -man "${TEMP}.man" 2>/dev/null | command sed 's/()//g'
        command rm -f "${TEMP}" "${TEMP}.man" "${TEMP}.docx"
    else
        command strings "${TEMP}"
    fi
}

function _MOAR_DECODE
{
    local FILE
    for FILE in "$@"
    do
        local TEMP=$(mktemp -u /tmp/.MOAR.XXXXXXXXXXXX)
        if [ ! -s "${FILE}" ] && command cat "${FILE}" &>"${TEMP}" && [ ! -s "${TEMP}" ]
        then
            printf "\e[91m<EMPTY>\e[0m" 2>/dev/null
        elif [ -f "${FILE}" ]
        then
            {
            local _MOAR_MIME=$(command file -L --mime-type "${FILE}")
            case "${_MOAR_MIME}" in
            *" "application/x-sqlite3)
            for TABLE in $(command sqlite3 "${FILE}" "SELECT name FROM sqlite_master WHERE type ='table' AND name NOT LIKE 'sqlite_%';")
            do
            {
            echo ".headers on"
            echo ".mode csv"
            echo "SELECT '${TABLE}',* FROM ${TABLE}"
            } | command sqlite3 "${FILE}" |command sed -e s/\"\'//g -e s/\'\"//g
            done
            ;;
            *" "font/*|*" "application/vnd.ms-opentype)
                local TEMP_PNM=${TEMP}.pnm
                command convert -background white -fill black -font "${FILE}" -pointsize 300 label:"Abc" "${TEMP_PNM}"
                [ -f "${TEMP_JPG}" ] && command chafa -s ${COLUMNS}x$((LINES-3)) "${TEMP_PNM}"
                command rm -f "${TEMP_PNM}"
            ;;
            *" "video/*|*" "audio/*)
            DISPLAY="" command mplayer -really-quiet -vo caca -framedrop -monitorpixelaspect 0.5 "${FILE}" 1>${TTY}
            reset
            ;;
            *" "image/*)
            [ "${_MOAR_STDOUT}" = 1 ] && command chafa -s ${COLUMNS}x$((LINES-3)) "${FILE}"
            command tesseract "${FILE}" - 2>/dev/null
            ;;
            *" text/"*|*" "application/vnd.apple.keynote|*" "application/vnd.wordperfect|*" "application/rtf|*" "application/vnd.oasis.opendocument.text|*" "application/vnd.openxmlformats-officedocument.presentationml.presentation|*" "application/vnd.openxmlformats-officedocument.wordprocessingml.document|*" "application/vnd.openxmlformats-officedocument.presentationml.presentation|*" "application/doc|*" "application/ms-doc|*" "application/msword)
            _MOAR_DECODE_DOC "${FILE}"
            ;;
            *" "application/x-sharedlib|*" "application/x-pie-executable|*" "application/x-executable|*" application/x-dosexec")
            case $(command file -L "${FILE}") in
                *"ELF 32-bit LSB executable, ARM,"*)
                command arm-linux-gnueabi-objdump -d "${FILE}"
                return 0
                ;;
                *"ELF 64-bit LSB pie executable, x86-64,"*|*"ELF 64-bit LSB executable, x86-64,"*)
                command x86_64-linux-gnu-objdump -d "${FILE}"
                return 0
                ;;
                *"ELF 32-bit LSB executable, Intel 80386,"*)
                command i686-linux-gnu-objdump -d "${FILE}"
                return 0
                ;;
                *"PE32+ executable "*"("*") x86-64"*)
                command x86_64-w64-mingw32-objdump -d "${FILE}"
                return 0
                ;;
                *"PE32 executable "*"("*") Intel 80386"*)
                command i686-w64-mingw32-objdump -d "${FILE}"
                return 0
                ;;
                *"ELF 64-bit LSB shared object, ARM aarch64,"*)
                command aarch64-linux-gnu-objdump -d "${FILE}"
                return 0
                ;;
                *"ELF 64-bit MSB executable, IBM S/390"*)
                command s390x-linux-gnu-objdump -d "${FILE}"
                return 0
                ;;
                *)
                command hexdump -C "${FILE}"
                return 0
            esac
            ;;
            *" "application/octet-stream)
            case "${FILE,,}" in
            *.wri)
            _MOAR_DECODE_DOC "${FILE}";;
            *.dlt)
            local TEMP=$(mktemp -u /tmp/.MOAR.XXXXXXXXXXXX.txt)
            command dlt-viewer -c "${FILE}" "${TEMP}"
            command cat "${TEMP}"
            command rm -f "${TEMP}"
            ;;
            *.psm|*.nsf)
            DISPLAY="" command mplayer -really-quiet -vc null -vo null "${FILE}" 1>/dev/null
            reset
            ;;
            *)
            command iconv -f CP437 -t UTF-8 "${FILE}"
            esac
            ;;
            *" "application/pdf)
            command pdftotext -layout "${FILE}" -
            ;;
            *" "application/excel|*" "application/vnd.ms-excel|*" "application/x-excel|*" "application/x-msexcel|*" "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet)
            local TEMP="/tmp/.MOAR.${RANDOM}.${FILE##*.}"
            if command cp -l "${FILE}" "${TEMP}"
            then
                TEMP=$(mktemp /tmp/.MOAR.XXXXXXXXXXXX.${FILE##*.})
                command cp "${FILE}" "${TEMP}"
            fi
            command unoconv -f csv --stdout "${TEMP}"
            command rm -f "${TEMP}"
            ;;
            *)
                command cat "${FILE}"
            esac
            }
        elif [ -d "${FILE}" ]
        then
        continue
        else
            case "${FILE}" in
            "https://www.youtube.com/"*)
            {
            command youtube-dl -o - -f '(best[height<=1080])[protocol^=https]' "${FILE}" | DISPLAY="" command mplayer -vo caca -monitorpixelaspect 0.5 -framedrop -really-quiet -cache 30720 -cache-min 2 /dev/fd/3 3<&0 </dev/tty >${TTY}
            reset
            } 2>/dev/null
            ;;
            "http://"*|"https://"*|"ftp://"*)
            {
            local TEMP_HTML=${TEMP_HTML}
            command curl -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Safari/537.36' "${FILE}" >"${TEMP_HTML}"
            _MOAR_DECODE_HTML "${TEMP_HTML}"
            } 2>/dev/null
            ;;
            *)
            command printf "\e[91m<NONEXISTANT>\e[0m" 2>/dev/null
            esac
        fi
    done
}

function _MOAR
{
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
    d)
        if [ "${#@}" = 1 ]
        then
            shift
            for FILE in README README.md README.rst README.asc README.doc readme.doc README.txt readme.txt README.* *.txt
            do
                if [ -f "${FILE}" ]
                then
                    _MOAR_DECODE "${FILE}" | command less -R -X -F -K
                    RETURN=$?
                    break
                fi
            done
        fi
        TTY=$(tty) 2>/dev/null
        shift
        if [ "${_MOAR_STDOUT}" = 1 ]
        then
            _MOAR_DECODE "${@}" 2>${_MOAR_STDERR_FILE} | command less -R -X -F -K
        else
            _MOAR_DECODE "${@}"
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
eval "alias d=_MOAR_d"
}
_MOAR_DEFINE
unset -f _MOAR_DEFINE
