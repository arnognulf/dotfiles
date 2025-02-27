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

# move the latest downloaded file to the current directory with the 'm' command.

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
_SECOND_LATEST ()
{
    local SECOND_NEWEST_FILE
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
    for FILE in "${@}"
    do
        if [[ -z "${SECOND_NEWEST_FILE}" || "${FILE}" -nt "${SECOND_NEWEST_FILE}" ]] && [ "${FILE}" != "${NEWEST_FILE}" ]
        then
            SECOND_NEWEST_FILE="${FILE}"
        fi
    done
    echo "${SECOND_NEWEST_FILE}"
    return 0
}


