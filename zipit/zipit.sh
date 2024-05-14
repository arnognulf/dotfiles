#!/bin/bash
function _SHOVEIT
(
    local FILE
    for FILE in "$@"
    do
        :
    done

    if [ ! -t 1 ]
    then
        \echo "${FILE}"
    elif [ -t 0 ]
    then
        local FILE
        for FILE in "$@"
        do
            :
        done
        case "${FILE}" in
        /*) :;; 
        *) FILE="${PWD}/${FILE}"
        esac

        if [ -n "${WAYLAND_DISPLAY}${DISPLAY}" ]
        then
            \nautilus -q &>/dev/null
            if [ ${#@} = 0 ]
            then
                ( exec nautilus "${PWD}" &>/dev/null & )
            else
                ( exec nautilus -s "${FILE}" &>/dev/null & )
            fi
        elif [ -n "${SSH_CLIENT}" ]
        then
            \echo "sftp://${HOSTNAME}${FILE// /%20}"
        else
            \echo "${FILE}"
        fi
    elif [ -n "$1" ]
    then
        \sort|\uniq|\grep "$@"
    else
        \sort|\uniq
    fi
)


function _ZIPIT
(
    FOLDER='/tmp/Zip it!/'
    \rm -rf "${FOLDER}"
    \mkdir -p "${FOLDER}" &>/dev/null
    UNDERSCORE_NAME="${1// /_}"
    NAME="${UNDERSCORE_NAME##*/}"
    [ -z "${NAME}" ] && NAME="${UNDERSCORE_NAME//\//}"
    DEST="${FOLDER}/$(\date +%Y-%m-%d_%H-%M-%S)_${NAME}".zip
    _SPINNER_START
    \zip -r "${DEST}" "$@" &>/dev/null
    _SPINNER_STOP
    if [ -s "${DEST}" ]
    then
        _SHOVEIT "${DEST}"
    else
        _NO
    fi
)

function _XZIBIT
(
    FOLDER='/tmp/Yo Dawg!/'
    \rm -rf "${FOLDER}"
    \mkdir -p "${FOLDER}" &>/dev/null
    UNDERSCORE_NAME="${1// /_}"
    NAME="${UNDERSCORE_NAME##*/}"
    [ -z "${NAME}" ] && NAME="${UNDERSCORE_NAME//\//}"
    DEST="${FOLDER}/$(\date +%Y-%m-%d_%H-%M-%S)_${NAME}".tar.xz
    _SPINNER_START
    \tar -I'pixz -e' -cf "${DEST}" "$@" &>/dev/null
    _SPINNER_STOP
    if [ -s "${DEST}" ]
    then
        _SHOVEIT "${DEST}"
    else
        _NO
    fi
)
alias x=_XZIBIT
alias z=_ZIPIT
alias s=_SHOVEIT

