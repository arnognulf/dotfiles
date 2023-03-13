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
        command echo "${FILE}"
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
            command nautilus -q &>/dev/null
            if [ ${#@} = 0 ]
            then
                ( exec nautilus "${PWD}" &>/dev/null & )
            else
                ( exec nautilus -s "${FILE}" &>/dev/null & )
            fi
        elif [ -n "${SSH_CLIENT}" ]
        then
            command echo "sftp://${HOSTNAME}${FILE// /%20}"
        else
            command echo "${FILE}"
        fi
    elif [ -n "$1" ]
    then
        command sort|command uniq|command grep "$@"
    else
        command sort|command uniq
    fi
)


function _ZIPIT
(
    FOLDER='/tmp/Zip it!/'
    command rm -rf "${FOLDER}"
    command mkdir -p "${FOLDER}" &>/dev/null
    UNDERSCORE_NAME="${1// /_}"
    NAME="${UNDERSCORE_NAME##*/}"
    [ -z "${NAME}" ] && NAME="${UNDERSCORE_NAME//\//}"
    DEST="${FOLDER}/$(command date +%Y-%m-%d_%H-%M-%S)_${NAME}".zip
    if TTY=$(tty) && SPINNER_PID_FILE=$(command mktemp); then
        (
             function spinner ()
             {
             command printf "\\e[?25l"
             while sleep 0.05; do
             command printf "\\e[99D   "
             sleep 0.04
             command printf "\\e[99D  ."
             sleep 0.04
             command printf "\\e[99D .."
             sleep 0.04
             command printf "\\e[99D..."
             sleep 0.04
             command printf "\\e[99D.. "
             sleep 0.04
             command printf "\\e[99D.  "
             done
             };
             if [[ -t 0 || -p /dev/stdin ]]
             then
                spinner "${TTY}" &
             fi
             command echo $! > "${SPINNER_PID_FILE}"
        )
    fi
 
    command zip -r "${DEST}" "$@" &>/dev/null
    kill -9 $(<"${SPINNER_PID_FILE}") &>/dev/null
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
    command rm -rf "${FOLDER}"
    command mkdir -p "${FOLDER}" &>/dev/null
    UNDERSCORE_NAME="${1// /_}"
    NAME="${UNDERSCORE_NAME##*/}"
    [ -z "${NAME}" ] && NAME="${UNDERSCORE_NAME//\//}"
    DEST="${FOLDER}/$(command date +%Y-%m-%d_%H-%M-%S)_${NAME}".tar.xz
    if TTY=$(tty) && SPINNER_PID_FILE=$(command mktemp); then
        (
             function spinner ()
             {
             command printf "\\e[?25l"
             while sleep 0.05; do
             command printf "\\e[99D   "
             sleep 0.04
             command printf "\\e[99D  ."
             sleep 0.04
             command printf "\\e[99D .."
             sleep 0.04
             command printf "\\e[99D..."
             sleep 0.04
             command printf "\\e[99D.. "
             sleep 0.04
             command printf "\\e[99D.  "
             done
             };
             if [[ -t 0 || -p /dev/stdin ]]
             then
                spinner "${TTY}" &
             fi
             command echo $! > "${SPINNER_PID_FILE}"
        )
    fi

    command tar -I'pixz -e' -cf "${DEST}" "$@" &>/dev/null
    kill -9 $(<"${SPINNER_PID_FILE}") &>/dev/null
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

