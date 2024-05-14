#!/bin/bash

function _ILIKETOMOVEIT ()
{
    local MV_SRC="${PWD}"
    local MV_DST="${1}"
    MV_SRC="${MV_SRC##*/}"
    if [ -z "$1" ]; then
    	read -e -i "${MV_SRC}" MV_DST
    fi
    test -z "${MV_DST}" && return 1
    MV_DST="${MV_DST// /_}"
    MV_DST="${MV_DST##*/}"
    (
        \cd ..
        \mv "${MV_SRC}" "${MV_DST}" || exit 1
        exit 0
    ) && { \cd ..; \cd "${MV_DST}"; return 0; }
    return $?
}
alias rencwd=_ILIKETOMOVEIT

function unspace ()
{
    for FILE in "${@}"
    do
        if [ -d "${FILE}" ]
        then
            unspace "${FILE}"/*
        fi
        \mv "${FILE}" "${FILE// /_}"
    done
}
