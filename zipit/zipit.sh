#!/bin/bash
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
function _SHOVEIT
(
    if [ -z "$1" ];then
        _NO
	return 1
    fi
    local FILE
    FILE=$(_LATEST "$@")
    if [ ! -t 1 ]
    then
        \echo "${FILE}"
    elif [ -t 0 ]
    then
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
	(
	    HOSTNAME=${HOST_OVERRIDE-${HOSTNAME}}
            \echo "sftp://${HOSTNAME}${FILE// /%20}"
	)
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

alias z=_ZIPIT
alias s=_SHOVEIT

