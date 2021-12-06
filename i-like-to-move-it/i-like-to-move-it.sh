#!/bin/bash

function _ILIKETOMOVEIT ()
{
    local MV_SRC="${PWD}"
    local MV_DST=""
    MV_SRC="${MV_SRC##*/}"
    read -e -i "${MV_SRC}" MV_DST
    test -z "${MV_DST}" && return 1
    MV_DST="${MV_DST// /_}"
    MV_DST="${MV_DST##*/}"
    (
        command cd ..
        command mv "${MV_SRC}" "${MV_DST}" || exit 1
        exit 0
    ) && { command cd ..; command cd "${MV_DST}"; return 0; }
    return $?
}

function rencwd ()
{
    if [ -z "${1}" ]
    then
        _ILIKETOMOVEIT
    else
        mv "${@}"
    fi
}

function unspace ()
{
    for FILE in "${@}"
    do
        if [ -d "${FILE}" ]
        then
            unspace "${FILE}"/*
        fi
        command mv "${FILE}" "${FILE// /_}"
    done
}