#!/bin/bash

if [ -n "$PS1" ]
then
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
_SOURCED=1
shopt -s globstar
function . { _SOURCED=1 command . "$@";}
function source { _SOURCED=1 command . "$@";}
PATH=${PATH}:~/.local/share/ParaView/bin:~/.local/share/android-studio/bin:~/.local/bin:/usr/share/code-insiders/resources/app/node_modules.asar.unpacked/vscode-ripgrep/bin/

DOTFILESDIR=$(readlink "${HOME}/.bashrc")
DOTFILESDIR=${DOTFILESDIR%/*}
export VIM=${DOTFILESDIR}/vim
export VIMRUNTIME=${DOTFILESDIR}/vim
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
#_Z_DATA=${HOME}/.config/z
#_Z_NO_PROMPT_COMMAND=1 _Z_CMD=_Z . "${DOTFILESDIR}"/z/z.sh
. "${DOTFILESDIR}"/zipit/zipit.sh
. "${DOTFILESDIR}"/dogeview/dogeview.sh

( bash ~/.config/dotfiles/deal-with-it/deal-with-it.sh & )

EDITOR="vim"
export EDITOR

function _EDITOR
{
    local FILE
    for FILE in "$@"
    do
        case "${FILE,,}" in
        -*) :;;
        *.kt|*.java) type -P studio.sh &>/dev/null && _CAN_OPENER studio.sh "${PWD}/${FILE}" ; return
        esac
    done
    if [ -z "$SSH_CLIENT" ] && [ "${UID}" -gt 0 ] && [ -n "${DISPLAY}" ]
    then
        $(type -P "code-insiders"||type -P "vim" ||type -P "vi") "${@}"
    else
        $(type -P "vim" ||type -P "vi") "${@}"
    fi
}

[ -x ~/.local/share/android-studio/bin/studio.sh ] && alias studio='o ~/.local/share/android-studio/bin/studio.sh'
[ -x ~/.local/bin/PabloDraw.exe ] && alias pablodraw='o mono ~/.local/bin/PabloDraw.exe'
[ -x  ~/.local/share/ghidra/ghidraRun ] && alias ghidra='o ~/.local/share/ghidra/ghidraRun'
alias dd='dd status=progress'
alias dl=_UBER_FOR_MV
alias octave=octave-cli
alias excel='o localc --norestore --view'
alias word='o lowriter --norestore --view'
alias localc='o localc --norestore --view'
alias loimpress='o loimpress --norestore --view'
alias lowriter='o lowriter --norestore --view'
alias powerpoint='o loimpress --norestore --view'
alias visio='o lodraw --norestore --view'
alias chrome='o google-chrome'
alias code-insiders='o code-insiders'
alias code='o code-insiders'
alias gd='git diff --color-moved --no-prefix'
alias gc='git commit -p --verbose'
alias gca='git commit --amend -p --verbose'
type -P fdfind &>/dev/null && alias fd='fdfind'
alias hog='~/.config/dotfiles/hog/hog.sh'
function _GREP
{
    if [ "${#@}" = 0 ]
    then
        git status
    else
        egrep "$@"
    fi
}
alias g=_GREP
alias gv="grep -v"

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
        nautilus -q &>/dev/null
        if [ ${#@} = 0 ]
        then
            ( exec nautilus "$PWD" &>/dev/null & )
        else
            local FILE
            for FILE in "$@"
            do
                #( exec nautilus -s "$1" &>/dev/null & )
                :
            done
            ( exec nautilus -s "$FILE" &>/dev/null & )
        fi
    elif [ -n "$1" ]
    then
        command sort|command uniq|grep "$@"
    else
        command sort|command uniq
    fi
}

(
function _KILLTRACKER
{
    systemctl --user mask tracker-store.service tracker-miner-fs.service tracker-miner-rss.service tracker-extract.service tracker-miner-apps.service tracker-writeback.service
    tracker3 daemon -k
    tracker daemon -k
    command rm -rf ~/.cache/tracker* ~/.local/share/tracker*
}
_KILLTRACKER &>/dev/null &
)
export LESS='-Q -R'
alias gl="LESS='-Q -R --pattern ^(commit|diff)' git log -p"
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
alias ..='c ..'
alias rud='repo upload -d'
alias vim=_EDITOR
alias vi=_EDITOR
alias v=_EDITOR
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
export MOSH_TITLE_NOPREFIX=1
alias mosh="_MEASURE=0; mosh"
alias adb="_MEASURE=0;adb"
alias tmp=_TMP_ALL_THE_THINGS
#alias y=_YANKY
#alias p=_PANKY
alias grep="_MOAR grep -a"
alias willys="google-chrome-beta -user-data-dir=${HOME}/.config/willys --no-default-browser-check --no-first-run --app=https://willys.se"
alias hbo="google-chrome-beta -user-data-dir=${HOME}/.config/hbo --no-default-browser-check --no-first-run --app=https://www.hbomax.com"
alias dn="google-chrome-beta -user-data-dir=${HOME}/.config/dn --no-default-browser-check --no-first-run --app=https://dn.se"
alias gmail="google-chrome-beta -user-data-dir=${HOME}/.config/gmail --no-default-browser-check --no-first-run --app=https://mail.google.com"
alias facebook="google-chrome-beta -user-data-dir=${HOME}/.config/facebook --no-default-browser-check --no-first-run --app=https://facebook.com"
alias lwn="google-chrome-beta -user-data-dir=${HOME}/.config/lwn --no-default-browser-check --no-first-run --app=https://lwn.net"
alias linkedin="google-chrome-beta -user-data-dir=${HOME}/.config/linkedin --no-default-browser-check --no-first-run --app=https://linkedin.com"
alias newsy="chrome-polisher-tmp newsy https://news.ycombinator.com"
alias youtube="chrome-polisher-tmp youtube https://youtube.com"
alias lobste.rs="chrome-polisher-tmp lobste.rs https://lobste.rs"
alias svtplay="chrome-polisher-tmp lobste.rs https://svtplay.se"
alias which="command -v"
alias ssh="_MEASURE=0;ssh"
unalias google-chrome &>/dev/null
unalias chrome &>/dev/null
pidof chrome &>/dev/null || command rm -rf "${DIR}" "~/.cache/google-chrome-beta" "~/.cache/google-chrome"  "~/.config/google-chrome-beta" "~/.config/google-chrome" &>/dev/null
function chrome-polisher
{
    local DIR=/tmp/chrome-polisher-${USER}
    pidof chrome &>/dev/null || command rm -rf "${DIR}" "~/.cache/google-chrome-beta" "~/.cache/google-chrome"  "~/.config/google-chrome-beta" "~/.config/google-chrome" &>/dev/null
    command mkdir -p "${DIR}" &>/dev/null
    _CAN_OPENER google-chrome-beta --disable-notifications --disable-features=Translate --disable-features=TranslateUI --no-default-browser-check --no-first-run -user-data-dir="${DIR}/chrome" "${*}"
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
alias sudo="\echo -ne \"\033]10;#DD2222\007\033]11;#000000\007\033]12;#DD2222\007\";sudo"
function _SCP
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
esac
done
test -z "${SERVER}" && { echo "missing server argument"; return; }
/usr/bin/scp "${@}"
}
alias scp=_SCP

function _DEDUPE ()
{
    command yes 1 | command jdupes --delete --omit-first "${XDG_DOWNLOAD_DIR-/dev/null}" ~/Downloads &>/dev/null
}

function c ()
{
    _CHDIR_ALL_THE_THINGS "$@" && {
        local TMP=$(mktemp)
        local MAXLINES=$((LINES - 5))
        /bin/ls --hyperlink=always -C -w${COLUMNS} --color=always | command tee "${TMP}" | command head -n${MAXLINES}
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
        /bin/ls --hyperlink=always -A -C -w${COLUMNS} --color=always | command tee "${TMP}" | command head -n${MAXLINES}
        else
        command echo "<empty>"
        fi
        fi
        $(type -P rm) -f "${TMP}"
    }
    ( _DEDUPE &>/dev/null & )
}

function untilfail
(
    if [ "${#@}" = 0 ] 
    then
        _NO
        return 255
    fi
    COUNT=0
    while "$@"
    do
    sleep 1
    let COUNT=1+${COUNT}
    if [ ${COUNT} -gt 10 ]
    then
        echo "=== "$(date +%H:%M:%S)" ==="
        COUNT=0
    fi
    done
)

function retry
(
    if [ "${#@}" = 0 ] 
    then
        _NO
        return 255
    fi
    COUNT=0
    until "$@"
    do
    sleep 1
    let COUNT=1+${COUNT}
    if [ ${COUNT} -gt 10 ]
    then
        echo "=== "$(date +%H:%M:%S)" ==="
        COUNT=0
    fi
    done
)

alias brrr=retry

function _NO
{
    echo "COMPUTER SAYS NO" 1>&2 | tee 1>/dev/null
}

function loop
{
    if [ "${#@}" = 0 ] 
    then
        _NO
        return 255
    fi
    _MEASURE=0
    local COUNT=0
    while sleep 1
    do
    "${@}"
    let COUNT=1+${COUNT}
    if [ ${COUNT} -gt 10 ]
    then
        echo "=== "$(date +%H:%M:%S)" ==="
        COUNT=0
    fi
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
    _NO
    return 255
}

function reboot
{
    _NO
    return 255
}

function shutdown
{
    _NO
    return 255
}

function /sbin/shutdown
{
    _NO
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

LS_COLORS='di=01';
export LS_COLORS
test -f ~/.bashrc.local && . ~/.bashrc.local
unset _SOURCED
if [ -n "${TMUX}" ]
then
(
    export TMUX
tmux set -g status off
tmux bind -n S-Pageup copy-mode -u
tmux bind -n S-Up copy-mode -u
tmux set-option -g set-titles on
tmux set-option -g set-titles-string "#T"
tmux set-window-option -g mode-keys vi
tmux bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
tmux bind-key -T copy-mode-vi 'y' send-keys -X copy-selection-and-cancel
tmux bind-key p paste-buffer
# C-B+] to paste
)
elif [ -z "${WAYLAND_DISPLAY}" ] && [ -z "${DISPLAY}" ]
then
tmux new-session -t 0
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

(
exec sed -i 's/"exited_cleanly": false/"exited_cleanly": true/' \
    ~/.config/google-chrome/Default/Preferences \
    ~/.config/google-chrome-beta/Default/Preferences &>/dev/null &
)

bind 'set bell-style none'
