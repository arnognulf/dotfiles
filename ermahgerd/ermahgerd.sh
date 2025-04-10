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

# rm emulator which puts the files in the XDG trash if possible
# restore files with 'doh'

function _ERMAHGERD
{
    local RMDIR
    local RMFORCE
    local ARG
    RMFORCE=''
    RMDIR=''
    test -z "${*}" && { $(type -P rm); return $?;}
    for ARG in "${@}"
    do
    case "${ARG}" in
    -h|--|--help|--version|-d|--dir|-fd|-df|--preserve-root*|--no-preserve-root|--one-file-system|--interactive*|-I|-i)
    $(type -P rm) "${@}"
    return $?
    esac
    done
    for ARG in "${@}"
    do
    case "${ARG}" in
    -rf|-Rf|-fR|-fr)
    RMFORCE=-f
    RMDIR=-r
    ;;
    -f|--force)
    RMFORCE=-f
    ;;
    -r|-R|--recursive)
    RMDIR=-r
    ;;
    esac
    done

    for ARG in "${@}"
    do
    case "${ARG}" in
    -rf|-Rf|-fR|-fr|-r|-f|-R|--recursive) : ;;
    *)
    if [ -d "${ARG}" -a -z "${RMDIR}" ]
    then
        $(type -P rm) ${RMDIR} ${RMFORCE} "${ARG}"
    else
        gio trash "${ARG}" &>/dev/null || $(type -P rm) ${RMFORCE} ${RMDIR} "${ARG}"
    fi
    esac
    done
}
_ERMAHGERD "$@"

