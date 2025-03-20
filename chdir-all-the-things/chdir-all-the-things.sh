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

function _RECURSE_REVERSE_CD
{
    local COUNT=0
    local FILES=0
    for ENTRY in "${1}"/*
    do
        [ ${COUNT} -gt 1 ] && break
        [ "${ENTRY}" = "." ] && continue
        [ "${ENTRY}" = ".." ] && continue
        [ -e "${ENTRY}" ] && { let COUNT++;}
        [ -f "${ENTRY}" ] && { FILES=1; break;}
    done
    if [ "${COUNT}" = 1 ] && [ "${FILES}" = 0 ]
    then
        _RECURSE_REVERSE_CD "${1}/.."
    else
        _CHDIR_ALL_THE_THINGS_CD "${1}"
    fi
}


function _RECURSE_CD
{
    if [ "${_CATT_LASTLASTPWD}" = "${PWD}" ]
    then
        _CATT_LASTLASTPWD="///"
        _CATT_LASTPWD="//"
        _CHDIR_ALL_THE_THINGS_CD "${1}"
        return $?
    fi
    if [ "$1" = ".." ]
    then
        _CHDIR_ALL_THE_THINGS_CD "$1"
        return $?
    fi
    case "${1}" in
    "../"?*) _CHDIR_ALL_THE_THINGS_CD "${1}";return
    esac
    local COUNT=0
    local DIRS=0
    local DIRENTRY
    for ENTRY in "${1}"/*
    do
        [ ${COUNT} -gt 1 ] && break
        [ "${ENTRY}" = "." ] && continue
        [ "${ENTRY}" = ".." ] && continue
        [ -e "${ENTRY}" ] && let COUNT++ 
        [ -d "${ENTRY}" ] && { DIRENTRY="${ENTRY}"; let DIRS++;}
    done
    if [ "${COUNT}" = 1 ] && [ "${DIRS}" = 1 ]
    then
        _CHDIR_ALL_THE_THINGS_CD "${DIRENTRY}"
    else
        _CHDIR_ALL_THE_THINGS_CD "${1}"
    fi
}

function _TMP_ALL_THE_THINGS
{
    local CHAR1
    local CHAR2
    local CHAR3
    local ENTRY
    local FOUND=0
    for CHAR3 in "" {a..z} {A..Z}
    do
        for CHAR2 in "" {a..z} {A..Z}
        do
            for CHAR1 in {a..z} {A..Z}
            do
                for ENTRY in "${CHAR1}${CHAR2}${CHAR3}"*
                do
                    if [ -e "${ENTRY}" ]
                    then
                        :
                    else
                        FOUND=1
                        break
                    fi
                done
                [ ${FOUND} = 1 ] && break
            done
            [ ${FOUND} = 1 ] && break
        done
        [ ${FOUND} = 1 ] && break
    done
    \echo -n "${CHAR1}${CHAR2}${CHAR3}_tmp_$(date +%Y-%m-%d_%H-%M-%S)"
    \echo -n "_"
    if [ -z "$*" ]
    then
        \echo $(gzip -cd /usr/share/ispell/american.mwl.gz |\iconv -f ISO8859-15 -t UTF-8|\cut -d/ -f1|\tail -n$RANDOM|\head -n1)-$(\gzip -cd /usr/share/ispell/american.mwl.gz |iconv -f ISO8859-15 -t UTF-8|cut -d/ -f1|tail -n$RANDOM|head -n1)-$(gzip -cd /usr/share/ispell/american.mwl.gz |iconv -f ISO8859-15 -t UTF-8|cut -d/ -f1|tail -n$RANDOM|head -n1)
    else
    echo "$*"
    fi
}

function _CHDIR_ALL_THE_THINGS_CD ()
{
local COUNT=0
local RETURN_VALUE
local FILE
if [ -n "$1" ]
then
for FILE in "${PWD}"/* "${PWD}"/.*
do
[ -e "${FILE}" ] && ((COUNT++));
done
_CATT_LASTLASTPWD="${_CATT_LASTPWD}"
_CATT_LASTPWD="${PWD}"
builtin cd "$1"
RETURN_VALUE=$?
[ -w "${_CATT_LASTPWD}" ] && [ ! -L "${_CATT_LASTPWD}" ] && rm -d "${_CATT_LASTPWD}" &>/dev/null
else
_CATT_LASTPWD="${PWD}"
builtin cd
RETURN_VALUE=$?
[ -w "${_CATT_LASTPWD}" ] && [ ! -L "${_CATT_LASTPWD}" ]  && rm -d "${_CATT_LASTPWD}" &>/dev/null
fi
return ${RETURN_VALUE}
}

# chdir(2) ALL THE THINGS
function _CHDIR_ALL_THE_THINGS () 
{ 
    local _KEEP
    if [ "$1" = '-k' ] || [ "$1" = '--keep' ]
    then
        _KEEP=1
        shift
    else
        _KEEP=0
    fi

    [ ${#@} -gt 1 ] && {
        local FILE
        local ALL_THE_FILES=1
        for FILE in "$@"
        do
            [ -f "${FILE}" ] || ALL_THE_FILES=0
        done
        if [ "${ALL_THE_FILES}" = 1 ]
        then
            for FILE in "${@}"
            do
                (_CHDIR_ALL_THE_THINGS "${FILE}";)
            done
            return 0
        else
            local ARG=""
            local FIRST=1
            for FILE in "$@"
            do
                if [ "${FIRST}" = 1 ]
                then
                    ARG="${FILE}"
                    FIRST=0
                else
                    ARG="${ARG} ${FILE}"
                fi
            done
            _CHDIR_ALL_THE_THINGS "${ARG}"
            return 0
        fi
    }
    local CATT_OLDPWD
    CATT_OLDPWD="$(pwd)"
    local ARG="${*}";
    if [ "${1}" = "-" ]
    then
        builtin cd -
        return 0
    elif [ -f "${2}" ]
    then
        local CATT_ARG
        for CATT_ARG in "${@}"
        do
            ( _CHDIR_ALL_THE_THINGS "${CATT_ARG}"; )
        done
        if [ -n "${ARG%/*}" ]
        then
            builtin cd "${ARG%/*}"
        fi
        return 0
    fi
    case "${ARG}" in
    *'$')
        _SPINNER_START
    	_CHDIR_ALL_THE_THINGS $(\fdfind "${ARG}"|\head -n1)
        _SPINNER_STOP
	return $?
    ;;
    */*)
    case $(\file --mime-type -L "${ARG}" 2>/dev/null) in
    *" "application/x-7z*|*" "application/x-xz|*" "application/x-rar|*" "application/x-tar|*" "application/x-bz2|*" "application/zstd) :;;
    *" "application/x-*|*" "application/vnd.openxmlformats*)
        if [ -n "${ARG%/*}" -a "${ARG%/*}" != "${ARG}" ]
        then
            builtin cd "${ARG%/*}"
            return 0
        else
            _NO
            return 42
        fi
        ;;
    esac
    esac
    if [ -L "${ARG}" ];then
        local LINKARG=$(readlink "${ARG}")
        if [ -d "${LINKARG}" ]
        then
            builtin cd "${ARG}"

        else
            _CHDIR_ALL_THE_THINGS "${LINKARG}"
        fi
        return 0
    elif [ -f "${ARG}" ]; then
        case "${ARG,,}" in 
            *.zip|*.7z|*.lzh|*.lha|*.arj|*.rar|*.exe)
            local RETRY=1;;
        *) local RETRY=0;;
        esac
        local ORIG_FILE="${ARG}";
        local DEST_DIR;
        case "${ORIG_FILE,,}" in 
            *.tar.*)
                DEST_DIR="${ORIG_FILE%.*}";
                DEST_DIR="${DEST_DIR%.*}";
            ;;
            *)
                DEST_DIR="${ORIG_FILE%.*}"
            ;;
        esac;
        if [ ! -s "${ORIG_FILE}" ]
        then
            DEST_DIR="${ORIG_FILE%/*}"
        elif mkdir "${DEST_DIR}" &> /dev/null; then
            :;
        elif DEST_DIR=$(mktemp -d "${DEST_DIR}.XXXXXXX" 2>/dev/null) &>/dev/null; then :
        elif DEST_DIR=$(mktemp -d "/tmp/${DEST_DIR}.XXXXXXX" 2>/dev/null) &>/dev/null; then :
        elif DEST_DIR=$(mktemp -d 2>/dev/null) &>/dev/null; then :
        else
            _NO
            return 42
        fi
        
        case "${ORIG_FILE}" in 
            /*)
            ;;
            *)
                ORIG_FILE="${PWD}/${ORIG_FILE}"
            ;;
        esac;
        # shellcheck disable=SC2164
        _CHDIR_ALL_THE_THINGS_CD "${DEST_DIR}"
        local SPINNER_PID_FILE
        _SPINNER_START
        local SUCCESS=1;
        # some files can be decompressed with Info-Zip, others with 7z
        type -p unzip &>/dev/null || { \echo "missing unzip" 2>&1| \tee >/dev/null;}
        type -p unar &>/dev/null || { \echo "missing unar" 2>&1| \tee >/dev/null;}
        type -p 7z &>/dev/null || { \echo "missing 7z" 2>&1| \tee >/dev/null;}
        chrt -i 0 tar xf "${ORIG_FILE}" &>/dev/null || chrt -i 0 unzip -X -o "${ORIG_FILE}" &>/dev/null || chrt -i 0 unsquashfs -no-xattrs "${ORIG_FILE}" &>/dev/null || chrt -i 0 7z x -pDUMMY_PASSWORD -y "${ORIG_FILE}" &>/dev/null || chrt -i 0 unar -force-rename -no-directory -password DUMMY_PASSWORD "${ORIG_FILE}" &>/dev/null || { chrt -i 0 simg2img "${ORIG_FILE}" "${ORIG_FILE}.temp" &>/dev/null && chrt -i 0 7z x "${ORIG_FILE}.temp" &>/dev/null;} || { chrt -i 0 zstd -d "${ORIG_FILE}" -o "${ORIG_FILE}".temp &>/dev/null && chrt -i 0 7z x ${ORIG_FILE}.temp;   } ||SUCCESS=0;
        [ -f "${ORIG_FILE}.temp" ] && \rm -f "${ORIG_FILE}.temp"  &>/dev/null
	_SPINNER_STOP
        if [ ${SUCCESS} = 0 ]
        then
            if pdftk "${ORIG_FILE}" unpack_files &>/dev/null
            then
                SUCCESS=1
            else
                SUCCESS=0
            fi
        fi
        if [ ${SUCCESS} = 0 ] && [ ${RETRY} = 1 ]; then
            chrt -i 0 7z x -y "${ORIG_FILE}";
        fi;
        local FILE="";
        local LAST_ENTRY="";
        for FILE in .* *;
        do
            case "${FILE}" in 
                ".." | ".")

                ;;
                *)
                    LAST_ENTRY="${FILE}"
                ;;
            esac;
        done;
        case "${LAST_ENTRY,,}" in 
            *.tar)
                7z x -pDUMMY_PASSWORD -y "${LAST_ENTRY}" &> /dev/null || 7z x -y "${LAST_ENTRY}";
                rm -f "${LAST_ENTRY}" &> /dev/null
            ;;
        esac;
        local COUNT=0;
        for FILE in .* *;
        do
            case "${FILE,,}" in 
            thumbs.db|__macosx|.ds_store) $(type -P rm) -rf "${FILE}" ;;
            ".." | ".") ;;
            *)
                if [ -e "${FILE}" ]
                then
                    ((COUNT++));
                    LAST_ENTRY="${FILE}"
                fi
            ;;
            esac;
        done;
        if [ ${COUNT} -eq 1 ] && [ -d "${LAST_ENTRY}" ]; then
            local TEMPDIR=$(mktemp -u -d _C_XXXXXXXX);
            mv "${LAST_ENTRY}" "${TEMPDIR}";
            for FILE in "${TEMPDIR}"/.* "${TEMPDIR}"/*;
            do
                case "${FILE,,}" in 
                    */"." | */"..") ;;
                    */thumbs.db|*/__macosx|*/.ds_store) $(type -P rm) -rf "${FILE}";;
                    *)
                        mv "${FILE}" . &> /dev/null;
                    ;;
                esac;
            done;
            $(type -P rm) -r "${TEMPDIR}" &> /dev/null;
        fi;
        if [ ${COUNT} = 0 ]; then
            $(type -P rm) -rf "${TEMPDIR}" &> /dev/null;
            # shellcheck disable=SC2164
            _CHDIR_ALL_THE_THINGS_CD "${ORIG_FILE%/*}" &>/dev/null
            if [ "${CATT_OLDPWD}" = "$(pwd)" ]
            then
                _NO
                return 1
            fi
        elif [ "${_KEEP}" = 0 ];then
            gio trash "${ORIG_FILE}" &>/dev/null
            gvfs-trash "${ORIG_FILE}" &>/dev/null
        fi
    elif [ -d "${ARG}" ] && [ -x "${ARG}" ]; then
        _CHDIR_ALL_THE_THINGS_CD "${ARG}"
        return
    elif [ -e "${ARG}" ]; then
        _NO
        return 1
    elif [ -n "${ARG}" ]; then
        case "${ARG}" in
        "git clone "*|git://*|https://*|http://*|ssh://*)
        _SPINNER_START
        git clone --depth=1 --recursive "${ARG/git clone }" &>/dev/null
	_SPINNER_STOP
        local XARG="${ARG##*/}"
        _CHDIR_ALL_THE_THINGS_CD "${XARG%.git}" &>/dev/null
        ;;
        tmp)

        _CHDIR_ALL_THE_THINGS $(_TMP_ALL_THE_THINGS)
        return $?
        ;;
        //*) local DIR="${*:2}"
            local SERVER="${DIR%%/*}"
            local SHARE="${DIR#*/}"
            local SHARE="${SHARE%%/*}"
            local DIR="${DIR#*/}"
            local DIR="${DIR#*/}"
            test -d "/run/user/${UID}/gvfs/smb-share\:server\=${SERVER}\,share\=${SHARE}/" || \gio mount "smb://${SERVER}/${SHARE}"
            _CHDIR_ALL_THE_THINGS "/run/user/${UID}/gvfs/smb-share\:server\=${SERVER}\,share\=${SHARE}/${DIR}"
            return 0
        ;;
        /*|./*|../*)
            _NO
            return 1
            ;;
        *)
        local COUNT=0
        for i in "${ARG}"*
        do
            [ -e "$i" ] && ((COUNT++))
        done
        if [ ${COUNT} -gt 0 ]
        then
            _NO
            return 1
        else
            local BOOKMARKDIR=~/.config/bookmark-all-the-things/
            if [ -d "${1%%/*}" ]
            then
                \mkdir -p "${1}" || { 
                    _NO
                    return 1
                }
                _CHDIR_ALL_THE_THINGS_CD "${1}" &>/dev/null
            elif [ -L "${BOOKMARKDIR}/${1}" ]
            then
                _CHDIR_ALL_THE_THINGS_CD $(readlink "${BOOKMARKDIR}/${1}") &>/dev/null || { 
                    _NO
                    return 1
                }
            else

                local XDIR
                # replace slash(solidus) with division slash
                XDIR="${*//\//∕}"
                # replace typewriter apostrophe with typographic apostrophe
                # as ls will put directory in quotation marks elsewise
                #XDIR=${XDIR//\'/’}
                # replace space with THREE-PER-EM space to avoid quotation marks in             # ls
                #XDIR=${XDIR// / }
                # replace space with underline to fix buggy scripts
                XDIR="${XDIR// /_}"
                # delete all non-printing characters
                #XDIR=$(echo "${XDIR}"|tr -dc '[:print:]')
                \mkdir "${XDIR}" &>/dev/null
                _CHDIR_ALL_THE_THINGS_CD "${XDIR}" &>/dev/null
            fi
        fi
        esac
    else
        _CHDIR_ALL_THE_THINGS_CD "${ARG}" &>/dev/null
    fi
    return 0
}
function bookmark ()
{
local BOOKMARKDIR=~/.config/bookmark-all-the-things/
mkdir -p "${BOOKMARKDIR}"
case "${1}" in
-d"")
rm -f "${BOOKMARKDIR}${2##*/}"
;;
"")
for FILE in ${BOOKMARKDIR}/*
do
if [ -L "${FILE}" ]
then
echo -e "${FILE##*/}\t->\t$(readlink ${FILE})"
fi
done
;;
-d)
rm "${BOOKMARKDIR}${2##*/}" 2>/dev/null
;;
*)
rm -f "${BOOKMARKDIR}${1##*/}"
ln -s "${PWD}" "${BOOKMARKDIR}${1##*/}"
esac
}

#function _CATT_BOOKMARK_INIT ()
#{
#local BOOKMARK
#local BOOKMARKDIR=~/.config/bookmark-all-the-things/
#for BOOKMARK in "${BOOKMARKDIR}"/*
#do
#eval "${BOOKMARK##*/}="${BOOKMARK}"
#eval "${BOOKMARK##*/} () { local DIR=\"\$(redlink '${BOOKMARK}')\"; if [ -n \"\$1\" ]; then ( cd \"$DIR\" || { _NO; exit 42;}; \"$@\";); else cd \"\$DIR\"fi;}"
#
#done
#unset -f function _CATT_BOOKMARK_INIT
#}

if [[ -t 0 || -p /dev/stdin ]]
then
:
else
#if [ -z "${1}"]
#then
#zenity --info --ellipsize --icon-name=package-x-generic --text "Select an archive to decompress" || exit 42
#FILE=$(zenity --file-selection)
#test -z "${FILE}" && exit 1
#_CHDIR_ALL_THE_THINGS "${FILE}"
#xdg-open .
#else
#_CHDIR_ALL_THE_THINGS "${1}"
#xdg-open .
#fi
:
fi
