#!/bin/bash

    # dos builtin commands
    function type ()
    {
        cat "$@" 2>/dev/null || echo "File $1 not found."
    }
    function cls ()
    {
        clear
    }

    function ver ()
    {
        printf "\nSH-DOS version 6.22\n\n\n"
    }

    function rem ()
    {
        return 0
    }

    function cd ()
    {

            if [ "$1" = "" ]
            then
                echo "C:${PWD//\//\\}"
            else
                builtin cd "${@}" 2>/dev/null || { echo -e "Invalid directory\n"; return 1; }
            fi
    }


    function dir ()
    {
        echo ""
        echo " Volume in drive C is TOO LOUD"
        echo " Volume Serial Number is BAAD-F00D"
        echo " Directory of C:${PWD_BACKSLASH}"
        echo " "
        let FILES=0
        let DIRS=0
        for FILE in *
        do
            BASE="${FILE%.*}"
            BASE="${BASE^^}"
            if [ -d "${FILE}" ]
            then
                let DIRS++
                local METADATA="<DIR>"
            else
                let FILES++
                # on macosx: stat -f%z
                local METADATA="\t"$(stat --printf="%s" "${FILE}")
            fi
            # MYDIR        <DIR>         20-20-20    6.22
            # MYFILE   EXT       123 456 21-03-01    6.22
            # MYFILE33 SH        123 456 21-03-01   17.40
            #         45 file(es)      883 936 byte
            #                           83 936 byte free
            case "${FILE}" in
            *"."*) EXT="${FILE##*.}"; EXT="${EXT^^}"; EXT="${EXT:0:3}";;
            *) EXT=""
            esac
            FILL=" "
            BASE=${BASE:0:8}
            BASE=${BASE%%.*}
            COUNT=${#BASE}
            while [ $COUNT -lt 8 ]
            do
                FILL="${FILL} "
                let COUNT++
            done

            printf "${BASE}${FILL}${EXT}\t${METADATA}\033[10D\033[20C\n"
        done

        echo "     $FILES file(s)"
    }
    
    # SH-DOS internal commands
    function abort-retry-fail ()
    {
        local DRIVE="${1:0:1}"
        DRIVE=${DRIVE^}
        while sleep 1
        do
            echo    "Not ready reading drive ${DRIVE}"
            echo -n "Abort, Retry, Fail?"
            read -n1 ANSWER
            case "$ANSWER" in
            a|A|f|F) echo "";return;;
            esac
        done
    }

function convert_path()
{
    local DRIVE
    local DIR
    case "${1}" in
        //*)
            [ ! -e "${1}" ] || \
                if type -p gio &>/dev/null
                then
                    gio mount -a "smb:${1}" 2>/dev/null ||
                        xdg-open "smb:${1}" 2>/dev/null
                else
                    gvfs-mount -a "smb:${1}" 2>/dev/null ||
                        xdg-open -a "smb:${1}" 2>/dev/null
                fi
            local SHARE="${1:2}"
            SHARE="${SHARE,,}"
            local SERVER="${SHARE%%/*}"
            SHARE="${SHARE#*/}"
            DIR="/var/run/user/$(id -u)/gvfs/smb-share:server=${SERVER},share=${SHARE}/"
        ;;
        [A-Za-z]":"*)
            DRIVE=${1:0:1}
            DRIVE=${DRIVE,,}
            DRIVE=$(printf "%d" \'${DRIVE})
            DIR="${DRIVES[${DRIVE}]}${1:2}"
            DIR="${DIR//\\/\/}"
            DIR="${DIR/\/\//\/}"
            ;;
        *)
            DIR="${1//\\/\/}"
    esac
    NEWPATH="${DIR}"
}

function is_accessible ()
{
    case "${1}" in
        [A-Za-z]:*)
            local DRIVE=${1:0:1}
            DRIVE=${DRIVE,,}

            if [ -n "${DRIVES[$(printf "%d" \'${DRIVE})]}" ]
            then
                return 0
            else
                return 1
            fi
            ;;
        *)
            return 0
    esac
}

    trap "" INT
    bind -u complete 2>/dev/null
    while true
    do
        SMB_PREFIX="/var/run/user/$(id -u)/gvfs/smb-share:server="
        if [ "${PWD:0:${#SMB_PREFIX}}" = "${SMB_PREFIX}" ]
        then
            PWD_UPPER="${PWD^^}"
            PWD_BACKSLASH="${PWD_UPPER//\//\\}"
            SERVER="${PWD_BACKSLASH:${#SMB_PREFIX}}"
            SERVER="${SERVER%%,*}"
            SHARE="${PWD_BACKSLASH#*,SHARE=}"
            read -p "\\\\${SERVER}\\${SHARE}> " -e -r CMD
        else
            PWD_UPPER="${PWD^^}"
            PWD_BACKSLASH="${PWD_UPPER//\//\\}"
            read -p "C:${PWD_BACKSLASH}> " -e -r CMD
        fi
        CMD0=${CMD%% *}
        CMDLOW=${CMD0,,}
        if builtin type -a ${CMDLOW} &>/dev/null
        then
            case "${CMD}" in
            *" "*) CMDALL=${CMDLOW}" "${CMD#* };;
            *) CMDALL=${CMDLOW};;
            esac

            unset ARGV
            let i=0
            for ARG in ${CMDALL}
            do
                convert_path "${ARG}"
                ARGV[$i]="${NEWPATH}"
                let i++
            done
            eval ${ARGV[@]}
        elif builtin type -a ${CMD0} &>/dev/null
        then
            eval ${CMD}
        elif [ "${CMDLOW}" = "a:" -o "${CMDLOW}" = "b:" ]
        then
            abort-retry-fail
        else
            echo "Bad command or file name"
        fi
    done

