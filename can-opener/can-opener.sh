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
# calling 'o' with a URL will try to open a web browser
#
# Can Opened commands can be disabled by prepending \ eg \xterm
# 
# most known graphical programs will be Can Opened.
#
_LATEST ()
{
    local NEWEST_FILE
    local FILE
    NEWEST_FILE=
    for FILE in "${@}"
    do
        if [[ -z "${NEWEST_FILE}" || "${FILE}" -nt "${NEWEST_FILE}" ]]
        then
            NEWEST_FILE="${FILE}"
        fi
    done
    echo "${NEWEST_FILE}"
    return 0
}
function _CAN_OPENER_ALL ()
{
    local FILE
    local MIME
    FILE=$(_LATEST "$@")
        (
            if [ -h "${FILE}" ]
            then
                FILE=$(readlink "${FILE}")
            fi
            
            MIME=$(command file --mime-type "${FILE}")
            case "${MIME}" in
            *" "application/vnd.apple.keynote|*" "application/vnd.wordperfect|*" "application/rtf|*" "application/vnd.oasis.opendocument.text|*" "application/vnd.openxmlformats-officedocument.*|*" "application/doc|*" "application/ms-doc|*" "application/msword)
            exec loffice --norestore --view "${FILE}" &>/dev/null &
            ;;
            *" "application/x-pie-executable|*" "application/x-sharedlib|*" "application/x-executable|*" "text/x-perl|*" "text/x-shellscript|*" "text/x-script.python|*" "text/x-lisp|*" "text/x-java|*" "text/x-ruby)
            if [ -x "${FILE}" ]
            then
                case "$1" in
                    /usr/*/xscreensaver/*)
                        PATH=$PATH:${1%/*} exec chrt -i 0 "$@" &>/dev/null &
            ;;
            *)
                exec "${FILE}" &>/dev/null &
            esac
            else
                exec xdg-open "${FILE}" &>/dev/null &
            fi
            ;;
            *)
            case "${FILE,,}" in
            *.md)
                pandoc --standalone -c ../can-opener/github-markdown.css -f gfm -t html README.md 2>/dev/null >.${FILE}.html
                exec x-www-browser ".${FILE}.html" &>/dev/null &
                ( sleep 5; \rm -f ".${FILE}.html"; ) &
                ;;
            *)
                exec xdg-open "${FILE}" &>/dev/null &
            esac
            esac
        )
}
function _CAN_OPENER ()
{
    if [ -z "${WAYLAND_DISPLAY}${DISPLAY}" ]
    then
        _NO
        return 1
    fi
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
    -h|--help*|--version|-help)
    HELP=1
    esac
    done
    if [ ${HELP} = 1 ]
    then
    command "$@"
    else
    	( 
        unset GNOME_TERMINAL_SCREEN
        unset GNOME_TERMINAL_SERVICE
        unset TERM
        unset TERM
        unset COLORTERM
        exec "$@" &>/dev/null & )
    fi
    elif [ -f "$1" ]
    then
        _CAN_OPENER_ALL "$@"
    elif type -p "${1}" 1>/dev/null
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
    if [ -t 1 ]
    then
    command "$@" | command less -Q -R -X -F -K -S
    else
    command "$@"
    fi
    else
    if [ "$1" = mplayer ] && command mplayer -vo null -ao null -identify -frames 0 "$2" 2>/dev/null|\grep "Video: no video" &>/dev/null
    then
        command "$@"
        return $?
    else
        ( 
        {
        unset GNOME_TERMINAL_SCREEN
        unset GNOME_TERMINAL_SERVICE
        trap "" SIGINT
        exec "$@" &
        } &>/dev/null 
        )
        fi
        fi
    elif [ -n "$1" ]
    then
    case "${1,,}" in
    *".txt"|*".pdf"|*".docx"|*".cpp"|*".h"|*".c"|*".kt"|*".java")
        _NO
        return 1
        ;;
    *"://"*|*"."*)
        ( exec x-www-browser "$1" &>/dev/null & )
        ;;
        *)
        _NO
        return 1
    esac
    elif [ -d "$PWD" ]
    then
        _CAN_OPENER_ALL .
    else
        _NO
        return 1
    fi
    return 0
}

_CAN_OPENER "$@"
