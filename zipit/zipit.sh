#!/bin/bash

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
        exec nautilus -s "${DEST}" &>/dev/null &
    else
        command echo "COMPUTER SAYS NO" 1>&2 | tee /dev/null 1>/dev/null
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
        exec nautilus -s "${DEST}" &>/dev/null &
    else
        command echo "COMPUTER SAYS NO" 1>&2 | tee /dev/null 1>/dev/null
    fi
)
alias x=_XZIBIT
alias z=_ZIPIT