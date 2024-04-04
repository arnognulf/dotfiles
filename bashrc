#!/bin/bash
function _dotfiles_main ()
{
if [ -n "$PS1" ]
then
if [ -n "${TMUX}" ]
then
(
setup_tmux ()
{
tmux set -g status off
tmux set-option -g set-titles-string "#T"
tmux set-option -g set-titles on
tmux bind -n S-Pageup copy-mode -u
tmux bind -n S-Up copy-mode -u
tmux set-window-option -g mode-keys vi
tmux bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
tmux bind-key -T copy-mode-vi 'y' send-keys -X copy-selection-and-cancel
tmux bind-key p paste-buffer
for i in $(seq 1 9)
do
tmux bind-key -n M-$i select-window -t $i
done
}
setup_tmux &
)
elif [ -z "${WAYLAND_DISPLAY}" ] && [ -z "${DISPLAY}" ] && [ -z "${SCHROOT_SESSION_ID}" ] && [ -x "/usr/bin/tmux" ]
then
read NUM < /run/user/${UID}/tmux-session
NUM=${NUM-0}
NUM=$((NUM + 1))
NUM=$((NUM % 3))
\echo ${NUM} > /run/user/${UID}/tmux-session
\cat >~/.tmux.conf << EOF
set-option -g history-limit 10000
set -g status off
bind -n S-Pageup copy-mode -u
bind -n S-Up copy-mode -u
set-option -g set-titles on
set-option -g set-titles-string "#T"
set-window-option -g mode-keys vi
bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
bind-key -T copy-mode-vi 'y' send-keys -X copy-selection-and-cancel
bind-key p paste-buffer
set -g status off
EOF

tmux -L ${NUM} attach-session || tmux -L ${NUM}
sleep 30
clear
\echo -ne "\0337\n"
\echo -ne "\0338................                              \n"
sleep 0.1
\echo -ne "\0338...............                              \n"
sleep 0.1
\echo -ne "\0338..............                              \n"
sleep 0.1
\echo -ne "\0338.............                              \n"
sleep 0.1
\echo -ne "\0338............                              \n"
sleep 0.1
\echo -ne "\0338...........                              \n"
sleep 0.1
command echo -ne "\0338..........                              \n"
sleep 0.1
command echo -ne "\0338.........                              \n"
sleep 0.1
command echo -ne "\0338........                              \n"
sleep 0.1
command echo -ne "\0338.......                              \n"
sleep 0.1
command echo -ne "\0338......                              \n"
sleep 0.1
command echo -ne "\0338.....                              \n"
sleep 0.1
command echo -ne "\0338....                              \n"
sleep 0.1
command echo -ne "\0338...                              \n"
sleep 0.1
command echo -ne "\0338..                              \n"
sleep 0.1
command echo -ne "\0338.                              \n"
sleep 0.1
exit 1
fi
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
_SOURCED=1
shopt -s globstar
#function . { _SOURCED=1 command . "$@";}
export BAT_THEME=GitHub

#function source { _SOURCED=1 command . "$@";}
PATH=${PATH}:~/.local/share/ParaView/bin:~/.local/share/android-studio/bin:~/.local/bin:/usr/share/code-insiders/resources/app/node_modules.asar.unpacked/vscode-ripgrep/bin/

local DOTFILESDIR=$(readlink "${HOME}/.bashrc")
DOTFILESDIR=${DOTFILESDIR%/*}
export GOPATH=${HOME}/.local/share/go

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


EDITOR="vim"
export EDITOR

function _EDITOR
{
    _MEASURE=0
    local FILE
    for FILE in "$@"
    do
        case "${FILE,,}" in
        -*) :;;
        *.kt|*.java) type -P studio.sh &>/dev/null && _CAN_OPENER studio.sh "${PWD}/${FILE}" ; return
        esac
    done
    $(type -P "vim" ||type -P "vi") -p "${@}"
}

[ -x ~/.local/share/android-studio/bin/studio.sh ] && alias studio='o ~/.local/share/android-studio/bin/studio.sh'
[ -x ~/.local/bin/PabloDraw.exe ] && alias pablodraw='o mono ~/.local/bin/PabloDraw.exe'
[ -x  ~/.local/share/ghidra/ghidraRun ] && alias ghidra='o ~/.local/share/ghidra/ghidraRun'
alias clang='_ICON 🛠️ _LOG ionice --class idle nice -n 19 clang'
alias gcc='_ICON 🛠️ _LOG ionice --class idle nice -n 19 gcc'
alias g++='_ICON 🛠️ _LOG ionice --class idle nice -n 19 g++'
alias ninja='_ICON 🛠️ _LOG ionice --class idle nice -n 19 ninja'
alias make='_ICON 🛠️ _LOG ionice --class idle nice -n 19 make -j$(nproc)'
alias vim='_ICON 📝 vim -p'
alias v='_ICON 📝  vim -p'
alias cat="_ICON 🐱  _MOAR cat"
alias delta='delta --light'
alias cp='_ICON 💽 ionice --class idle nice -n 19 cp --reflink=auto'
alias dd='_ICON 💽 ionice --class idle nice -n 19 dd status=progress'
alias dl=_UBER_FOR_MV
alias octave=octave-cli
alias excel='o localc --norestore --view'
alias word='o lowriter --norestore --view'
alias localc='o localc --norestore --view'
alias loimpress='o loimpress --norestore --view'
alias lowriter='o lowriter --norestore --view'
alias powerpoint='o loimpress --norestore --view'
alias visio='o lodraw --norestore --view'
alias tar='_ICON 📼 ionice --class idle nice -n 19 tar'
alias scrcpy='_RETRY scrcpy'
alias adb='_MEASURE=0 _ICON 🤖 _RETRY _LOG adb'
if [ -n "$WAYLAND_DISPLAY" ]
then
local WAYLAND_OPTS="--enable-features=UseOzonePlatform --ozone-platform=wayland"
fi
alias chrome='o google-chrome-beta ${WAYLAND_OPTS}'
alias code-insiders='o code-insiders'
alias code='o code-insiders'
_GIT ()
{
_ICON 🪣
case "$1" in
clone|push)
_LOG \git "$@"
;;
*)
_MEASURE=0
_LOG _MOAR git "$@"
esac
}
alias git="_GIT"
alias gd='git diff --color-moved --no-prefix'
alias gc='git commit -p --verbose'
alias gca='git commit --amend -p --verbose'
type -P fdfind && alias fd='_ICON 🔎 _MOAR fdfind -H -I'
alias find=' _ICON 🔎 _LOG _MOAR find'
alias rga='_ICON 🔎 _LOG _MOAR rga --color=always'
alias rg='_ICON 🔎 _LOG _MOAR rg'
alias top='_ICON 📈 top'
alias ntop='_ICON 📈 ntop'
alias htop='_ICON 📈 htop'
alias nload='_ICON 📈 nload'
alias rm='_ICON ♻️   ionice --class idle nice -n 19 rm'
alias trash='_ICON ♻️   gio trash'
alias jdupes='_ICON ♻️   ionice --class idle nice -n 19 jdupes --dedupe -R'
alias hog='~/.config/dotfiles/hog/hog.sh'
alias g="egrep"
alias gv="grep -v"
function fclones
{
[ -z "$(type -P fclones)" ] && { _NO; return 255;}
if [ -z "$1" ]
then
_ICON ♻️  ionice -c idle nice -n 19 $(type -P fclones) group "$PWD" | ionice -c idle nice -n 19 $(type -P fclones) dedupe
else
_ICON ♻️  ionice -c idle nice -n 19 $(type -P fclones) "$@"
fi
}
function _REPO
{
    if [ -z "$SSH_AUTH_SOCK" ]
    then
        eval $(ssh-agent)
        ssh-add
    fi
    \repo "$@"
}
alias repo="_ICON 🪣 _LOG repo"

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
alias man='_MEASURE=0;MANWIDTH=$((COLUMNS > 80 ? 80 : COLUMNS)) _ICON 📓 man'
alias v=_EDITOR
alias keepass='o keepassxc'
alias kp=keepassxc

_LS_HIDDEN ()
{
case "${PWD}" in
${HOME}/Network/*|/run/user/*/gvfs/*)
_MOAR ls -C "$@"
;;
*)
local hide=()
if [ -f .hidden ]
then
while IFS="
" read -r line
do
hide+=("--hide=${line}")
done < .hidden
fi
_MOAR ls "${hide[@]}" --color=always "$@"
esac
}

_BRANCHY_MCBRANCHFACE ()
(
\git rev-parse --show-toplevel &>/dev/null || { _NO; return 1;}
_title "🐙  Branchy McBranchFace"
BRANCH=$({ \git branch -a|cut -c3-1024; \git reflog;}|fzf)||exit 1
\git checkout ${BRANCH%% *}
)
alias b=_BRANCHY_MCBRANCHFACE

alias ll='ls -al --color=always'
alias l='_LS_HIDDEN -C'
alias ls='_LS_HIDDEN -C'
alias task_flash='task "⚡ FLASH ⚡"'
alias task_bake='task "🍞 Bake"'
alias task_bug="🐛 Bug"
alias xargs="xargs -d'\n'"
alias mosh="_MEASURE=0; MOSH_TITLE_NOPREFIX=1 mosh"
alias tmp=_TMP_ALL_THE_THINGS
#alias y=_YANKY
#alias p=_PANKY
alias grep="_MOAR grep -a"
alias willys="o google-chrome-beta  ${WAYLAND_OPTS} -user-data-dir=${HOME}/.config/willys --no-default-browser-check --no-first-run --app=https://willys.se"
alias hbo="google-chrome-beta ${WAYLAND_OPTS} -user-data-dir=${HOME}/.config/hbo --no-default-browser-check --no-first-run --app=https://www.hbomax.com"
alias dn="google-chrome-beta ${WAYLAND_OPTS} -user-data-dir=${HOME}/.config/dn --no-default-browser-check --no-first-run --app=https://dn.se"
alias gmail="google-chrome-beta ${WAYLAND_OPTS} -user-data-dir=${HOME}/.config/gmail --no-default-browser-check --no-first-run --app=https://mail.google.com"
alias facebook="google-chrome-beta ${WAYLAND_OPTS} -user-data-dir=${HOME}/.config/facebook --no-default-browser-check --no-first-run --app=https://facebook.com"
alias lwn="google-chrome-beta ${WAYLAND_OPTS} -user-data-dir=${HOME}/.config/lwn --no-default-browser-check --no-first-run --app=https://lwn.net"
alias linkedin="google-chrome-beta ${WAYLAND_OPTS} -user-data-dir=${HOME}/.config/linkedin --no-default-browser-check --no-first-run --app=https://linkedin.com"
alias newsy="_CHROME-POLISHER-tmp newsy https://news.ycombinator.com"
alias youtube="_CHROME-POLISHER-tmp youtube https://youtube.com"
alias lobste.rs="_CHROME-POLISHER-tmp lobste.rs https://lobste.rs"
alias svtplay="_CHROME-POLISHER-tmp lobste.rs https://svtplay.se"
alias which="command -v"
alias ssh="_MEASURE=0;ssh"
unalias google-chrome
unalias chrome
pidof chrome || command rm -rf "${DIR}" "~/.cache/google-chrome-beta" "~/.cache/google-chrome"  "~/.config/google-chrome-beta" "~/.config/google-chrome"

function _CHROME-POLISHER
{
if [ -n "$WAYLAND_DISPLAY" ]
then
local WAYLAND_OPTS="--enable-features=UseOzonePlatform --ozone-platform=wayland"
fi
    local DIR=/run/user/${UID}/_CHROME-POLISHER-${USER}
    pidof chrome &>/dev/null || command rm -rf "${DIR}" "~/.cache/google-chrome-beta" "~/.cache/google-chrome"  "~/.config/google-chrome-beta" "~/.config/google-chrome" &>/dev/null
    command mkdir -p "${DIR}" &>/dev/null
    _CAN_OPENER google-chrome-beta ${WAYLAND_OPTS} --disable-notifications --disable-features=Translate --disable-features=TranslateUI --no-default-browser-check --no-first-run -user-data-dir="${DIR}/chrome" "${*}"
}
function _CHROME-POLISHER-tmp
{
if [ -n "$WAYLAND_DISPLAY" ]
then
local WAYLAND_OPTS="--enable-features=UseOzonePlatform --ozone-platform=wayland"
fi
    local DIR="/run/user/${UID}/_CHROME-POLISHER-${USER}/${1}"
    pidof chrome &>/dev/null || command rm -rf "${DIR}"
    command mkdir -p ${DIR}
    shift
    _CAN_OPENER google-chrome-beta ${WAYLAND_OPTS} --disable-notifications --disable-features=TranslateUI --no-default-browser-check --no-first-run -user-data-dir="${DIR}" --app="${*}"
}
alias chromium=_CHROME-POLISHER
alias google-chrome=_CHROME-POLISHER
alias chrome=_CHROME-POLISHER
alias dos="bash ${DOTFILESDIR}/dos/sh-dos.sh"
alias sudo="\echo -ne \"\033]10;#DD2222\007\033]11;#000000\007\033]12;#DD2222\007\";_ICON ⚠️  sudo"
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
(
    command yes 1 | command jdupes --delete --omit-first "${XDG_DOWNLOAD_DIR-/dev/null}" ~/Downloads
)

function c ()
{
    _CHDIR_ALL_THE_THINGS "$@" && {
        local TMP="/run/user/${UID}/ls-${RANDOM}.txt"
        local FILE
        for FILE in README.md README.txt README README.doc README.rst README.android README.* "READ *" "Read *" "Read *"
        do
        if [ -f "${FILE}" ]
        then
        \echo -ne "\n   \033[1;4m"
        \grep -v ^$ "${FILE}" | command sed -e 's/# //g' | command head -n1
        command echo -e "\033[0m"
        break
        fi
        done
        if [ -d .git ]; then
        local MAXLINES=$((LINES - 8))
        else
        local MAXLINES=$((LINES - 6))
        fi
        _LS_HIDDEN -C -w${COLUMNS} | \tee "${TMP}" | command head -n${MAXLINES}
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
        _LS_HIDDEN -A -C -w${COLUMNS} | \tee "${TMP}" | \tee "${TMP}" | command head -n${MAXLINES}
        local LS_LINES=$(wc -l < $TMP) 
        [ ${LS_LINES} -gt ${MAXLINES} ] && command echo "..."
        else
        command echo "<empty>"
        fi
        fi
        [ -d ".git" ] && { builtin echo ""; PAGER= $(type -P git) log --oneline -1 --color=never 2>/dev/null;}
        ( command rm -f "${TMP}" &>/dev/null & )
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

function _RETRY
(
    if [ "${#@}" = 0 ] 
    then
        _NO
        return 255
    fi
    \printf '\n\0337' 1>&2 | \tee 1>&2
    local a=0
    until "$@"
    do
        {
        \printf '\033[?25l\0338\033[2A'
        case $a in
        0) \printf '.  ';;
        1) \printf '.. ';;
        2) \printf '...';;
        3) \printf ' ..';;
        4) \printf '  .';;
        5) \printf '   ';;
        esac
        \printf '\n'
        let a++
        [ $a -gt 5 ] && a=0
        sleep 0.25
        \printf '\033[?25h'
        } 1>&2 | \tee 1>&2
    done
)

alias retry=_RETRY

function _NO
(
    \echo "COMPUTER SAYS NO" 1>&2 | \tee 1>/dev/null
)

# loop is an xscreensaver module 
unalias loop
function _LOOP
{
    if [ "${#@}" = 0 ] 
    then
        _NO
        return 255
    fi
    \printf '\n\0337' 1>&2 | \tee 1>&2
    local a=0
    while true
    do
        {
        \printf '\033[?25l\0338\033[2A'
        "$@"
        case $a in
        0) \printf ' .   ';;
        1) \printf ' ..  ';;
        2) \printf ' ... ';;
        3) \printf '  .. ';;
        4) \printf '   . ';;
        5) \printf '     ';;
        esac
        \printf '\n'
        let a++
        sleep 0.25
        [ $a -gt 5 ] && a=0
        \printf '\033[?25h'
        } 1>&2 | \tee 1>&2
    done
}
alias loop=_LOOP

function now
(
    command date +%Y-%m-%d_%H-%M-%S
)

function jetzt
(
    now
)

function /sbin/reboot
(
    _NO
    return 255
)

function reboot
(
    _NO
    return 255
)

function shutdown
(
    _NO
    return 255
)

function /sbin/shutdown
(
    _NO
    return 255
)

function //
(
    :
)

function front
(
    if [ "${#@}" = 0 ]
    then
    return 1
    fi
    for FILE in "$@"
    do
        command echo "${FILE}"
        break
    done
)
function back
(
    if [ "${#@}" = 0 ]
    then
    return 1
    fi
    for FILE in "$@"
    do
        :
    done
    command echo "${FILE}"
)

function _LOG
{
local LOG="${TTY//\//_}"
local LOGDIR="${HOME}/.cache/logs"
\mkdir -p "${LOGDIR}"; 
LOG="${LOGDIR}/${LOG}"
local ARG
local TEMP=$(\mktemp)
for ARG in "$@"
do
\echo -n "\"${ARG}\" " >>"${TEMP}"
done
script -q -e -c "bash \"${TEMP}\"" "${LOG}"
local RETURN=$?
\rm -f "${TEMP}"
return ${RETURN}
}

local FILE
for FILE in /*
do
eval "function $FILE { echo \"C-comment paste detected. Press CTRL+C to continue\";cat;}"
break;
done

LS_COLORS='di=01';
export LS_COLORS
. ~/.bashrc.local
unset _SOURCED
bind 'set bell-style none'
BGCOLOR="#FFFAF1"
FGCOLOR="#312D2A"
fi

(
function ignore_chrome_crash
(
exec sed -i 's/"exited_cleanly": false/"exited_cleanly": true/' \
    ~/.config/google-chrome/Default/Preferences \
    ~/.config/google-chrome-beta/Default/Preferences
)
function mount_shares
{
local item
for item in $(\cat ~/.config/gtk-3.0/bookmarks | \grep -v file:// | \cut -d" " -f1)
do
gio mount "${item}" &
done
}

function kill_tracker 
{
    systemctl --user mask tracker-store.service tracker-miner-fs.service tracker-miner-rss.service tracker-extract.service tracker-miner-apps.service tracker-writeback.service
    tracker3 daemon -k
    tracker daemon -k
    command rm -rf ~/.cache/tracker* ~/.local/share/tracker*
}
# try to run one thread for non-blocking background tasks such that CPU and IO is not
# stressed at shell startup, this way we will get to prompt faster
function background_startup_tasks
{
ignore_chrome_crash
kill_tracker
# mount shares can wait for network I/O quite some time, do this late to not block other tasks
bash ~/.config/dotfiles/deal-with-it/deal-with-it.sh &
mkdir -p ~/.cache/vim/backup/ ~/.cache/vim/swp/ ~/.cache/vim/undo/
mkdir -p "${GOPATH}"

# hide files from nautilus and ls
ln -sf "${DOTFILESDIR}/home.hidden" ~/.hidden
ln -sf "${DOTFILESDIR}/home.xscreensaver" ~/.xscreensaver
mount_shares
}
background_startup_tasks &
)
}
if [ -f ~/.bashrc.statistics ]
then
time _dotfiles_main &>/dev/null
elif [ -f ~/.bashrc.debug ]
then
_dotfiles_main
else
_dotfiles_main &>/dev/null
fi
unset -f _dotfiles_main
