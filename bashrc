#!/bin/bash
if [ -n "$PS1" ]
then
_SOURCED=1
shopt -s globstar
function . { _SOURCED=1 command . "$@";}
function source { _SOURCED=1 command . "$@";}
PATH=${PATH}:~/.local/share/ParaView/bin:~/.local/share/android-studio/bin:~/.local/bin:/usr/share/code-insiders/resources/app/node_modules.asar.unpacked/vscode-ripgrep/bin/

DOTFILESDIR=$(readlink "${HOME}/.bashrc")
DOTFILESDIR=${DOTFILESDIR%/*}
export VIM=${DOTFILESDIR}/vim
. "${DOTFILESDIR}"/prompt/prompt.sh
. "${DOTFILESDIR}"/chdir-all-the-things/chdir-all-the-things.sh
. "${DOTFILESDIR}"/can-opener/can-opener.sh
. "${DOTFILESDIR}"/git-prompt/git-prompt.sh
. "${DOTFILESDIR}"/shabacus/shabacus.sh
#. "${DOTFILESDIR}"/markdown-writer/markdown-writer.sh
. "${DOTFILESDIR}"/uber-for-mv/uber-for-mv.sh
#. "${DOTFILESDIR}"/archivr/archivr.sh
. "${DOTFILESDIR}"/bash-preexec/bash-preexec.sh
. "${DOTFILESDIR}"/emojify/emojify.sh
. "${DOTFILESDIR}"/moar/moar.sh
. "${DOTFILESDIR}"/ermahgerd/ermahgerd.sh
#. "${DOTFILESDIR}"/yankypanky/yankypanky.sh
. "${DOTFILESDIR}"/i-like-to-move-it/i-like-to-move-it.sh
. "${DOTFILESDIR}"/fuuuu/fuuuu.sh
. "${DOTFILESDIR}"/stawkastic/stawkastic.sh

EDITOR="vim"
[ -z "$SSH_CLIENT" ] && if [ "${UID}" -gt 0 -o -n "${DISPLAY}" ]
then
type -P code-insiders &>/dev/null && EDITOR="code-insiders"
fi
export EDITOR

function _EDITOR
{
    local FILE
    for FILE in "$@"
    do
        case "${FILE,,}" in
        -*) :;;
        *.kt|*.java) type -P studio.sh &>/dev/null && o studio.sh "${PWD}/${FILE}" ; return
        esac
    done
    $(type -P "${EDITOR}"||type -P "vim" ||type -P "vi") "${@}"
}

#alias a=_ARCHIVR
alias pablodraw='o mono ~/.local/bin/PabloDraw.exe'
alias ghidra='~/.local/share/ghidra/ghidraRun'
alias dd='dd status=progress'
alias m=_UBER_FOR_MV
alias octave=octave-cli
alias excel='o localc'
alias word='o lowriter'
alias chrome='o google-chrome'
alias code=_EDITOR
alias gd='git diff --color-moved --no-prefix'
alias gc='git commit -p --verbose'
alias gca='git commit --amend -p --verbose'
function g
{
    if [ "${#@}" = 0 ]
    then
        git status
    else
        egrep "$@"
    fi
}

function repo
{
    if [ -z "$SSH_AUTH_SOCK" ]
    then
        eval $(ssh-agent)
        ssh-add
    fi
    command repo "$@"
}

function s
{
    if [ -t 0 ]
    then
        command echo "USAGE: cmd|s"
        command echo "if no arg then sort"
        command echo "if arg then sort|grep arg"
        return 1
    fi
    if [ -n "$1" ]
    then
        command sort|command uniq|grep "$@"
    else
        command sort|command uniq
    fi
}

function x
{
    if [ -t 0 ]
    then
        if [ -z "${1}" ]
        then
            if [ -f README.md ]
            then
            cat README.md
            elif [ -f README.txt ]
            then
            cat README.txt
            elif [ -f README ]
            then
            cat README
            fi
        else
            cat "${@}"
        fi
    else
        command grep -v "$@"
    fi
}

alias gl="LESS='-R --pattern ^(commit|diff)' git log -p"
alias ga='git add -p'
alias gr='git reflog'
alias gx='git checkout'
alias gxp='git checkout -p'
alias rd='repo diff'
alias rud='repo upload -d'
alias ru='repo upload'
alias rb='repo branch'
alias r='repo status'
alias -- -='c -'
alias ..ls='c ..'
alias ..='c ..'
alias ...='c ..'
alias ....='c ..'
alias .....='c ..'
alias ......='c ..'
alias rud='repo upload -d'
alias vim=_EDITOR
alias vi=_EDITOR
alias v=_EDITOR
alias cd='c'
alias keepass='o keepassxc'
alias kp=keepassxc
alias ls='_MOAR ls -C --color=always'
alias ll='ls -al --color=always'
alias l='ls -C --color=always'
alias task_flash='task "⚡ FLASH ⚡"'
alias task_bake='task "🍞 Bake"'
alias task_bug="🐛 Bug"
alias trash="gio trash"
#alias cp='rsync --append-verify --checksum --info=progress2'
alias xargs="xargs -d'\n'"
alias noless="command /bin/cat"
alias mosh="MOSH_TITLE_NOPREFIX=1 mosh"
alias tmp=_TMP_ALL_THE_THINGS
alias y=_YANKY
alias p=_PANKY
alias grep="grep -a"
alias willys="google-chrome-beta -user-data-dir=${HOME}/.config/willys --no-default-browser-check --no-first-run --app=https://willys.se"
alias dn="google-chrome-beta -user-data-dir=${HOME}/.config/dn --no-default-browser-check --no-first-run --app=https://dn.se"
alias gmail="google-chrome-beta -user-data-dir=${HOME}/.config/gmail --no-default-browser-check --no-first-run --app=https://mail.google.com"
alias facebook="google-chrome-beta -user-data-dir=${HOME}/.config/facebook --no-default-browser-check --no-first-run --app=https://facebook.com"
alias lwn="google-chrome-beta -user-data-dir=${HOME}/.config/lwn --no-default-browser-check --no-first-run --app=https://lwn.net"
alias linkedin="google-chrome-beta -user-data-dir=${HOME}/.config/linkedin --no-default-browser-check --no-first-run --app=https://linkedin.com"
alias newsy="chrome-polisher-tmp newsy https://news.ycombinator.com"
alias youtube="chrome-polisher-tmp youtube https://youtube.com"
alias lobste.rs="chrome-polisher-tmp lobste.rs https://lobste.rs"
alias svtplay="chrome-polisher-tmp lobste.rs https://svtplay.se"

unalias google-chrome &>/dev/null
unalias chrome &>/dev/null
pidof chrome &>/dev/null || command rm -rf "${DIR}" "~/.cache/google-chrome-beta" "~/.cache/google-chrome"  "~/.config/google-chrome-beta" "~/.config/google-chrome" &>/dev/null
function chrome-polisher
{
    local DIR=/tmp/chrome-polisher-${USER}
    pidof chrome &>/dev/null || command rm -rf "${DIR}" "~/.cache/google-chrome-beta" "~/.cache/google-chrome"  "~/.config/google-chrome-beta" "~/.config/google-chrome" &>/dev/null
    command mkdir -p "${DIR}" &>/dev/null
    _CAN_OPENER google-chrome-beta --disable-notifications --disable-features=TranslateUI --no-default-browser-check --no-first-run -user-data-dir="${DIR}/chrome" "${*}"
}
function chrome-polisher-tmp
{
    local DIR="/tmp/chrome-polisher-${USER}/${1}"
    pidof chrome &>/dev/null || command rm -rf "${DIR}"
    command mkdir -p ${DIR}
    shift
    _CAN_OPENER google-chrome-beta --disable-notifications --disable-features=TranslateUI --no-default-browser-check --no-first-run -user-data-dir="${DIR}" --app="${*}"
}
alias chromium=chrome-polisher
alias google-chrome=chrome-polisher
alias chrome=chrome-polisher
alias dos="bash ${DOTFILESDIR}/dos/sh-dos.sh"

function scp
{
local ARG
local SERVER
SERVER=""
for ARG in "${@}"
do
case "${ARG}"
in
*:*)
SERVER=${ARG%%:*}
SERVER=${SERVER#*@}
until ping -c 1 "${SERVER}" &>/dev/null; do echo -n .;sleep 0.5; done
esac
done
test -z "${SERVER}" && { echo "missing server argument"; return; }
/usr/bin/scp "${@}"
}

function c ()
{
    if [ -n "${_SOURCED}" ]
    then
    command cd "$@"
    return $?
    fi
    _CHDIR_ALL_THE_THINGS "$@" && {
        local TMP=$(mktemp)
        local MAXLINES=$((LINES - 5))
        /bin/ls -C -w${COLUMNS} --color=always | command tee "${TMP}" | command head -n${MAXLINES}
        local LS_LINES=$(wc -l < $TMP) 
        [ ${LS_LINES} -gt ${MAXLINES} ] && command echo "..."
        if [ ${LS_LINES} = 0 ]
        then
        local COUNT=0
        local FILES
        for FILES in .*
        do
        let COUNT++
        done
        if [ ${COUNT} -gt 2 ]
        then
        /bin/ls -A -C -w${COLUMNS} --color=always | command tee "${TMP}" | command head -n${MAXLINES}
        else
        command echo "<empty>"
        fi
        fi
        $(type -P rm) -f "${TMP}"
    }
}

function dowhile
{
    while "$@"
    do
    sleep 1
    done
}

function dountil
{
    until "$@"
    do
    sleep 1
    done
}

function loop
{
    while sleep 1
    do
    "${@}"
    done
}

function now
{
    date +%Y-%m-%d_%H-%M-%S
}
function jetzt
{
    now
}

function /sbin/reboot
{
    echo "COMPUTER SAYS NO"
    return 255
}

function reboot
{
    echo "COMPUTER SAYS NO"
    return 255
}

function shutdown
{
    echo "COMPUTER SAYS NO"
    return 255
}

function /sbin/shutdown
{
    echo "COMPUTER SAYS NO"
    return 255
}
function //
{
    :
}
for FILE in /*
do
eval "function $FILE { echo \"C-comment paste detected. Press CTRL+C to continue\";cat;}"
break;
done

function cp
{
    if [ -t 1 ] && [ -t 2 ] && [ -z "${_SOURCED}" ]
    then
        {
        ( command cp "$@" &>/tmp/.cp-out.$USER.$! & progress -qmp $!;)
        command cat /tmp/.cp-out.${USER}.*
        command rm /tmp/.cp-out.${USER}.*
        } 2>/dev/null
    else
        cp "$@"
    fi
}

LS_COLORS='di=01';
export LS_COLORS
test -f ~/.bashrc.local && . ~/.bashrc.local
unset _SOURCED
if [ -n "${TMUX}" ]
then
tmux set -g status off
tmux bind -n S-Pageup copy-mode -u
tmux set-option -g set-titles on
tmux set-option -g set-titles-string "#T"
tmux set-window-option -g mode-keys vi
tmux bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
tmux bind-key -T copy-mode-vi 'y' send-keys -X copy-selection-and-cancel
tmux bind-key p paste-buffer
# C-B+] to paste

elif [ "${SSH_CLIENT}" ]
then
tmux -L ssh attach-session || tmux -L ssh
clear
command printf "\0337\n"
command printf "\0338................                              \n"
sleep 0.1
command printf "\0338...............                              \n"
sleep 0.1
command printf "\0338..............                              \n"
sleep 0.1
command printf "\0338.............                              \n"
sleep 0.1
command printf "\0338............                              \n"
sleep 0.1
command printf "\0338...........                              \n"
sleep 0.1
command printf "\0338..........                              \n"
sleep 0.1
command printf "\0338.........                              \n"
sleep 0.1
command printf "\0338........                              \n"
sleep 0.1
command printf "\0338.......                              \n"
sleep 0.1
command printf "\0338......                              \n"
sleep 0.1
command printf "\0338.....                              \n"
sleep 0.1
command printf "\0338....                              \n"
sleep 0.1
command printf "\0338...                              \n"
sleep 0.1
command printf "\0338..                              \n"
sleep 0.1
command printf "\0338.                              \n"
sleep 0.1







exit 1
fi
fi
