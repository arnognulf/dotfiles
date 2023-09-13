#!/bin/bash
#
# Copyright (c) 2022 Thomas Eriksson <thomas.eriksson@gmail.com>
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
#
# "Never wrestle with a pig. You just get dirty and the pig enjoys it - George Bernard Shaw"

set -meou pipefail
stderr ()
{
    echo "$*" 1>&2| tee 1>/dev/null
}

stdout ()
{
    echo "$*"
}

error ()
{
    stderr "ERROR: $*"
    exit 42
}
print_objects ()
{
    REPO_DIR=../.${NAME}/${PWD##*}/
    COMMIT_DIRS=""
    for COMMIT_DIR in "${REPO_DIR}/objects"/*
    do
        COMMIT_DIRS="${COMMIT_DIR} ${COMMIT_DIRS}"
    done

    for COMMIT_DIR in ${COMMIT_DIRS}
    do
    [ ! -d "${COMMIT_DIR}" ] && { stdout "<EMPTY REPOSITORY>" ; exit 0; }
    echo -e "${COLOR_SET}commit ${COMMIT_DIR##*/}${COLOR_RESET}"
    echo -e "Date:\t $(date --date=@${COMMIT_DIR##*/})"
    echo ""
    cat "${COMMIT_DIR}/message"
    echo ""
    done 
}

goto_repo_dir ()
{
    REPO_DIR=../.${NAME}/${PWD##*}/
    while [ ! -d "${REPO_DIR}" ] && [ "$OLDPWD" != "${PWD}" ]
    do
        cd ..
        REPO_DIR=../.${NAME}/${PWD##*}/
    done
    if  [ ! -d "${REPO_DIR}" ]
    then
        error "not a ${NAME} repository"
        return 1
    fi
    chmod +r "${REPO_DIR}"
    chmod +w "${REPO_DIR}"
    chmod +x "${REPO_DIR}"
    return 0
}
NAME=hog

trap "goto_repo_dir &>/dev/null && chmod -r \".hog\" 2>/dev/null" EXIT

REPO_DIR=../${NAME}/${PWD##*}/

case "${1-}" in
init)
if [ "${2-}" = "-f" ]
then
chmod +r "${REPO_DIR}"
chmod +w "${REPO_DIR}"
chmod +x "${REPO_DIR}"
rm -rf "${REPO_DIR}"
mkdir -p "${REPO_DIR}"
fi
mkdir "${REPO_DIR}" &>/dev/null || error "repository alread initialized"
echo 1 > "${REPO_DIR}"/version
if cp --reflink=always -rdf "${REPO_DIR}"/version "${REPO_DIR}"/reflink_supported &>/dev/null 
then
:
elif [ "${2-}" != "-f" ]
then
        rm -rf "${REPO_DIR}"
        error "reflinks are not supported on this filesystem, use a filesystem such as XFS, BTRFS, F2FS, or BCACHEFS, or use -f to force creation using non-reflink files"
fi
stdout "Initialized empty ${NAME} repository in ${REPO_DIR}/"
;;
commit)
goto_repo_dir
COMMIT_DIR="${REPO_DIR}/objects/$(date +%s)/"
if [ "${2-}" = "-m" ]
then
if [ -z "${3-}" ]
then
error "empty commit message"
else
mkdir -p "${COMMIT_DIR}" || error "couldn\'t create dir"
echo "${3-}" > "${COMMIT_DIR}/message"
fi
else
TEMP=$(mktemp)
"${EDITOR}" "${TEMP}"
mkdir -p "${COMMIT_DIR}" || error "couldn\'t create dir"
[ ! -s "${TEMP}" ] && error "empty commit message"
cp "${TEMP}" "${COMMIT_DIR}"/message || { rm -rf "${COMMIT_DIR}"; error "couldn\'t write commit message";}
rm "${TEMP}" &>/dev/null
fi
SNAPSHOT_DIR="${COMMIT_DIR}/snapshot"
mkdir -p "${SNAPSHOT_DIR}" || error "couldn\'t create dir"
START="${SECONDS}"
for ITEM in * .*
do
    [ "${ITEM}" = "." ] && continue
    [ "${ITEM}" = ".." ] && continue
    cp --preserve=all --reflink=auto -rdf "${ITEM}" "${SNAPSHOT_DIR}" &
done
while fg &>/dev/null
do
:
done
END="${SECONDS}"
echo $((${END} - ${START})) > "${COMMIT_DIR}"/commit_duration
;;
checkout)
goto_repo_dir
[ ! -d "${REPO_DIR}/objects/${2-}" ] && error "no such commit"
COMMIT_DIR="${REPO_DIR}/objects/${2-}"
SNAPSHOT_DIR="${COMMIT_DIR}/snapshot"
mkdir -p "${REPO_DIR}/tmp" || error "couldn\'t create temp dir=${REPO_DIR}/tmp"
for ITEM in * .*
do
    case "${ITEM}" in
    "."|".."|*"/."|*"/..") :;;
    *)
    mv "${ITEM}" "${REPO_DIR}/tmp" || true 
    ( exec rm -rf "${REPO_DIR}/tmp/${ITEM}" &>/dev/null & )
    esac
done

for ITEM in "${SNAPSHOT_DIR}"/* "${SNAPSHOT_DIR}"/.*
do
    case "${ITEM}" in
    *"/."|*"/..") :;;
    *)
    cp --preserve=all --reflink=auto -rdf "${ITEM}" . &
    esac
done
while fg &>/dev/null
do
:
done
;;
log)
goto_repo_dir
if [ -t 1 ]
then
    COLOR_SET="\033[33m"
    COLOR_RESET="\033[0m"
    print_objects | less -X -Q -F -j0 -R
else
    COLOR_SET=""
    COLOR_RESET=""
    print_objects
fi
;;
delete)
goto_repo_dir
[ ! -d "${REPO_DIR}/objects/${2-}" ] && error "no such commit"
COMMIT_DIR="${REPO_DIR}/objects/${2-}"
rm -rdf "${COMMIT_DIR}" || error "couldn\'t remove COMMIT_DIR=${COMMIT_DIR}"
;;
*)
stderr "Hog: multi-gigabyte version control tool."
stderr ""
stderr "Usage:"
stderr "    hog init"
stderr "    hog commit"
stderr "    hog checkout"
stderr "    hog delete"
stderr "    hog log"
esac
