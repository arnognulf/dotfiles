#!/bin/bash

function _YASSIFY
(
    command rm -rf "/tmp/.YASS/"
    command mkdir -p /tmp/.YASS/
    DEST="/tmp/.YASS/$(date +%Y-%m-%d_%H-%M-%S)_${1// /_}".7z
    if TTY=$(tty) && SPINNER_PID_FILE=$(mktemp); then
        (
             function spinner ()
             {
             command printf "\\e[?25l"
             while sleep 0.05; do
             command printf "\\e[?25l\\e[99D   "
             sleep 0.04
             command printf "\\e[?25l\\e[99D  ."
             sleep 0.04
             command printf "\\e[?25l\\e[99D .."
             sleep 0.04
             command printf "\\e[?25l\\e[99D..."
             sleep 0.04
             command printf "\\e[?25l\\e[99D.. "
             sleep 0.04
             command printf "\\e[?25l\\e[99D.  "
             done
             };
             if [[ -t 0 || -p /dev/stdin ]]
             then
                spinner "${TTY}" &
             fi
             command echo $! > "${SPINNER_PID_FILE}"
        )
    fi
 
    command 7z a "${DEST}" "$@" &>/dev/null
    kill -9 $(<"${SPINNER_PID_FILE}") &>/dev/null
    test -f "${DEST}" && exec nautilus -s "${DEST}" &>/dev/null &
)

alias y=_YASSIFY