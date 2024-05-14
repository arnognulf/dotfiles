#!/bin/bash

_FUUU ()
{
    if [ -t 0 ]
    then
    {
    local i=1
    local COLUMNS=$(stty size|cut -d" " -f2)
    command echo -n "F"
    while [ $i -lt ${COLUMNS} ]
    do
        command echo -n "U"
        let i++
    done
    command echo ""
    } >&2 | command tee /dev/null >/dev/null
    else
    case "${#*}" in
    3) command sed --unbuffered -e 's/\x1b\[[0-9;]*m//g' -e 's/\x1b\[K//g' | command awk -F"${1}" '{ print substr($0, index($0, $'"${2}"'), 2+index($0, $'"${3}"')) }';;
    2) 
    if [ "${1}" -le 0 -o "${1}" -ge 0 ] 2>/dev/null
    then
        command sed --unbuffered -e 's/\x1b\[[0-9;]*m//g' -e 's/\x1b\[K//g' | command awk '{ print substr($0, index($0, $'"${1}"'), index($0, $'"${2}"')) }'
    else
        command sed --unbuffered -e 's/\x1b\[[0-9;]*m//g' -e 's/\x1b\[K//g' | command awk -F"${1}" '{ print $'"${2}"' }'
    fi
    ;;
    *) command sed --unbuffered -e 's/\x1b\[[0-9;]*m//g' -e 's/\x1b\[K//g' | command awk '{ print $'"${1-0}"' }';;
    esac | command sed -e 's/\t/ /g' -e 's/  */ /g'
    fi
}

alias f=_FUUU
