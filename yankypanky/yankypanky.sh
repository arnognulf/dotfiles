#!/bin/bash

function _YANKY
{
    if [[ -t 0 ]]
    then
    local FILE
    local COUNT=0
    for FILE in "$@"
    do
        case "${FILE}" in
        *@*:*) let COUNT=${COUNT}+1; command echo "${FILE}";;
        /*) test -e "${FILE}" && { let COUNT=${COUNT}+1; command echo "${FILE}";};;
        *) test -e "${FILE}" && { let COUNT=${COUNT}+1; command echo "${PWD}/${FILE}";};;
        esac
    done >${XDG_CONFIG_HOME-${HOME}/.config}/yankypanky
    echo "${COUNT} files yanked" 1>&2 | command cat 1>/dev/null
    else
    local YANKYPANKY_STDIO_FILE=/tmp/yankypanky-${UID}
    command less -R -X -F -K -O${YANKYPANKY_STDIO_FILE}
    wl-copy <${YANKYPANKY_STDIO_FILE} &>/dev/null || \
    xclip <${YANKYPANKY_STDIO_FILE} &>/dev/null
    local YANKED_LINES=$(wc -l <${YANKYPANKY_STDIO_FILE})
    command echo -e "\n${YANKED_LINES} lines yanked" 1>&2 | command cat 1>/dev/null
    fi
}

function _PANKY
{
    if [[ -t 1 ]]
    then
    local FILE
    local COUNT=0
    local IFS="
"
    for FILE in $(cat ${XDG_CONFIG_HOME-${HOME}/.config}/yankypanky)
    do
        echo ${FILE##*/}
        command cp -r "${FILE}" . &>/dev/null
        let COUNT=COUNT+1
    done
    echo -e "\n${COUNT} more files" 1>&2 | command cat 1>/dev/null
    else
    local YANKYPANKY_STDIO_FILE=/tmp/yankypanky-${UID}
    if [ -f ${YANKYPANKY_STDIO_FILE} ]
    then
        cat ${YANKYPANKY_STDIO_FILE}
        local PANKED_LINES=$(wc -l <${YANKYPANKY_STDIO_FILE})
        echo -e "\n${PANKED_LINES} more lines" 1>&2 | command cat 1>/dev/null
    else
    wl-paste 2>/dev/null || \
    xclip -o 2>/dev/null
    fi
    fi
}
