#!/bin/bash
#
# Copyright (c) 2022 Thoma Eriksson <thomas.eriksson@gmail.com>
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

set -eou pipefail
trap "chmod +x \"${REPO_DIR-}\" 2>/dev/null" EXIT

NAME=hog
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
    [ -n "${COMMIT_DIR-}" ] && rm -rf "${COMMIT_DIR}"
    exit 42
}

goto_repo_dir ()
{
    while [ ! -d ".${NAME}" ] && [ "$OLDPWD" != "${PWD}" ]
    do
        cd ..
    done
    if  [ ! -d ".${NAME}" ]
    then
        error "not a ${NAME} repository"
    fi
    REPO_DIR=".${NAME}" 
    chmod +x "${REPO_DIR}"
}

REPO_DIR=".${NAME}" 

case "${1-}" in
init)
REPO_DIR=".${NAME}" 
mkdir "${REPO_DIR}" &>/dev/null || error "repository alread initialized"
echo 1 > "${REPO_DIR}"/version
if cp --reflink=always -rdf "${REPO_DIR}"/version "${REPO_DIR}"/reflink_supported &>/dev/null 
then
:
elif [ "${2-}" != "-f" ]
then
        rm -rf ".${NAME}" 
        error "reflinks are not recommended, use a supported filesystem such as XFS, BTRFS, F2FS, or BCACHEFS, or use -f to force creation"
fi
stdout "Initialized empty ${NAME} repository in $PWD/.${NAME}/"
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
echo "${3-}" > "${COMMIT_DIR}/message"
fi
else
TEMP=$(mktemp)
vi ${TEMP}
mkdir -p "${COMMIT_DIR}" || error "couldn\'t create dir"
[ ! -s "${TEMP}" ] && error "empty commit message"
cp "${TEMP}" "${COMMIT_DIR}"/message || erro "couldn\'t write commit message"
rm "${TEMP}" &>/dev/null
fi
SNAPSHOT_DIR="${COMMIT_DIR}/snapshot"
mkdir -p "${SNAPSHOT_DIR}" || error "couldn\'t create dir"
for ITEM in *
do
    [ "${ITEM}" = ".${NAME}" ] && continue
    cp --reflink=auto -rdf "${ITEM}" "${SNAPSHOT_DIR}" &
done
while fg &>/dev/null
do
:
done
;;
checkout)
goto_repo_dir
[ ! -d [ "${REPO_DIR}/$1" ] && error "no such commit"
COMMIT_DIR="${REPO_DIR}/objects/$1"
SNAPSHOT_DIR="${COMMIT_DIR}/snapshot"
mkdir -p ".${NAME}/tmp" || error "couldn\'t create temp dir=${PWD}/.${NAME}/tmp"
for ITEM in *
do
    [ "${ITEM}" = ".${NAME}"] && continue
    mv "${ITEM}" ".${NAME}/tmp" || error "can\'t move item to temp"
    ( exec rm -rf ".${NAME}/tmp/${ITEM}" &>/dev/null & )
done

for ITEM in ".${SNAPSHOT_DIR}"/*
do
    cp --reflink=auto -rdf "${ITEM}" . &
done
while fg &>/dev/null
do
:
done
;;
log)
goto_repo_dir
for COMMIT_DIR in ".${NAME}/objects"/*
do
    [ ! -d "${COMMIT_DIR}" ] && { stdout "<EMPTY REPOSITORY>" ; exit 0; }
echo -e "\033[33mcommit ${COMMIT_DIR##*/}\033[0m"
echo -e "Date:\t $(date --date=@${COMMIT_DIR##*/})"
echo ""
cat "${COMMIT_DIR}/message"
echo ""
done | less -r
;;
delete)
[ ! -d "${REPO_DIR}/${2-}" ] && error "no such commit"
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
