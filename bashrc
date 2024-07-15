#!/bin/bash
{
function _dotfiles_main ()
{
if [ -n "$PS1" ]
then
if [ -n "${TMUX}" ]
then
(
setup_tmux ()
{
export LC_ALL=C 
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

LC_ALL=${OLD_LC_ALL} tmux -L ${NUM} attach-session || LC_ALL=${OLD_LC_ALL} tmux -L ${NUM}
sleep 30
clear
\printf "\e7\n"
\printf "\e8................                              \n"
sleep 0.1
\printf "\e8...............                              \n"
sleep 0.1
\printf "\e8..............                              \n"
sleep 0.1
\printf "\e8.............                              \n"
sleep 0.1
\printf "\e8............                              \n"
sleep 0.1
\printf "\e8...........                              \n"
sleep 0.1
\printf "\e8..........                              \n"
sleep 0.1
\printf "\e8.........                              \n"
sleep 0.1
\printf "\e8........                              \n"
sleep 0.1
\printf "\e8.......                              \n"
sleep 0.1
\printf "\e8......                              \n"
sleep 0.1
\printf "\e8.....                              \n"
sleep 0.1
\printf "\e8....                              \n"
sleep 0.1
\printf "\e8...                              \n"
sleep 0.1
\printf "\e8..                              \n"
sleep 0.1
\printf "\e8.                              \n"
sleep 0.1
exit 1
fi
TTY=$(tty)
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
_SOURCED=1
shopt -s globstar
export BAT_THEME=GitHub

PATH=${PATH}:~/.local/share/ParaView/bin:~/.local/share/android-studio/bin:~/.local/bin:/usr/share/code-insiders/resources/app/node_modules.asar.unpacked/vscode-ripgrep/bin/

DOTFILESDIR=$(readlink "${HOME}/.bashrc")
DOTFILESDIR=${DOTFILESDIR%/*}
export GOPATH=${HOME}/.local/share/go

export VIM=${DOTFILESDIR}/vim
export VIMRUNTIME=${DOTFILESDIR}/vim
BGCOLOR="FFFAF1"
FGCOLOR="312D2A"
. "${HOME}/.bashrc.colors"
. "${DOTFILESDIR}"/prompt/prompt.sh
. "${DOTFILESDIR}"/chdir-all-the-things/chdir-all-the-things.sh
. "${DOTFILESDIR}"/can-opener/can-opener.sh
. "${DOTFILESDIR}"/git-prompt/git-prompt.sh
. "${DOTFILESDIR}"/shabacus/shabacus.sh
. "${DOTFILESDIR}"/uber-for-mv/uber-for-mv.sh
. "${DOTFILESDIR}"/bash-preexec/bash-preexec.sh
. "${DOTFILESDIR}"/emojify/emojify.sh
. "${DOTFILESDIR}"/moar/moar.sh
. "${DOTFILESDIR}"/ermahgerd/ermahgerd.sh
. "${DOTFILESDIR}"/i-like-to-move-it/i-like-to-move-it.sh
. "${DOTFILESDIR}"/fuuuu/fuuuu.sh
. "${DOTFILESDIR}"/stawkastic/stawkastic.sh
. "${DOTFILESDIR}"/zipit/zipit.sh
. "${DOTFILESDIR}"/dogeview/dogeview.sh

if type -P nvim
then
EDITOR="nvim"
else
EDITOR="vim"
fi

alias nvim='XDG_DATA_HOME="${VIM}" _NO_MEASURE _ICON 📝 nvim -u "${VIM}"/nvimrc -p '
alias ivm='nvim'
alias vi='nvim'
alias vim='nvim'
alias im='nvim'
alias v='nvim'
alias nano='nvim'

export EDITOR
_NO_MEASURE ()
{
    _MEASURE=0
    "$@"
}
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
    XDG_DATA_HOME="${VIM}" $(type -P "nvim" 2>/dev/null||type -P "vim" 2>/dev/null ||type -P "vi" 2>/dev/null ) -u "${VIM}"/nvim.vim -p "${@}"
}

[ -x ~/.local/share/android-studio/bin/studio.sh ] && alias studio='o _BATCH_PRIO ~/.local/share/android-studio/bin/studio.sh'
[ -x ~/.local/bin/PabloDraw.exe ] && alias pablodraw='o mono ~/.local/bin/PabloDraw.exe'
[ -x  ~/.local/share/ghidra/ghidraRun ] && alias ghidra='o ~/.local/share/ghidra/ghidraRun'
alias clang='_ICON 🛠️ _LOG clang'
alias gcc='_ICON 🛠️ _LOG gcc'
alias g++='_ICON 🛠️ _LOG g++'
alias snapcraft='_ICON 🛠️ _LOG snapcraft --verbose'
alias ninja='_ICON 🛠️ _LOG ninja'
alias make='_ICON 🛠️ _LOG make -j$(nproc)'
alias cat="_ICON 🐱 _MOAR cat"
alias delta='_BATCH_PRIO delta --light'
alias cp='_ICON 💽 _BATCH_PRIO cp --reflink=auto'
alias dd='_ICON 💽 _BATCH_PRIO dd status=progress'
alias dl=_UBER_FOR_MV
alias octave=octave-cli
alias excel='o localc --norestore --view'
alias word='o lowriter --norestore --view'
alias localc='o localc --norestore --view'
alias loimpress='o loimpress --norestore --view'
alias lowriter='o lowriter --norestore --view'
alias powerpoint='o loimpress --norestore --view'
alias visio='o lodraw --norestore --view'
alias tar='_ICON 📼 _BATCH_PRIO tar'
alias scrcpy='_RETRY scrcpy'
alias adb='_NO_MEASURE  _ICON 🤖 _RETRY adb'
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
_MOAR git "$@"
esac
}
alias it="_GIT"
alias git="_GIT"
alias gd='git diff --color-moved --no-prefix'
alias gc='git commit -p --verbose'
alias gca='git commit --amend -p --verbose'
type -P fdfind && alias fdfind='_ICON 🔎 _MOAR fdfind -H -I'
type -P fdfind && alias fd='_ICON 🔎 _MOAR fdfind -H -I'
alias find='_ICON 🔎 _MOAR find'
alias rga='_ICON 🔎 _MOAR rga --color=always'
alias rg='_ICON 🔎 _MOAR rg'
alias top='_NO_MEASURE _ICON 📈 top'
alias ntop='_NO_MEASURE _ICON 📈 ntop'
alias htop='_NO_MEASURE _ICON 📈 htop'
alias nload='_NO_MEASURE _ICON 📈 nload'
rm()
{
    _ICON ♻️  _BATCH_PRIO rm "$@"
}
alias rm='_ICON ♻️  _ERMAHGERD'
alias trash='_ICON ♻️  gio trash'
alias jdupes='_ICON ♻️  jdupes --dedupe -R'
alias hog='~/.config/dotfiles/hog/hog.sh'
alias g="_ICON 🔎 egrep"
alias gv="_ICON 🔎 grep -v"
timer ()
{
local time=$(($1 * 60))
while sleep 1
do
let time--
local minutes=$((time / 60))
local seconds=$((time % 60))
if [ ${#seconds} = 1 ]
then
seconds=0${seconds}
fi
clear
printf "\033]0;⏲️  ${minutes}:${seconds}\007\033[?25l

    ${minutes}:${seconds}"
if [ ${time} -le 0 ]
then
mplayer "${DOTFILESDIR}"/kitchen_timer.ogg &>/dev/null
printf '\033]0;⏲️  Time is up!\007Time is up! Press key to continue'
read -n1
return 0
fi
done
}
function fclones
{
[ -z "$(type -P fclones)" ] && { _NO; return 255;}
if [ -z "$1" ]
then
_ICON ♻️  _BATCH_PRIO $(type -P fclones) group "$PWD" | _BATCH_PRIO $(type -P fclones) dedupe
else
_ICON ♻️  _BATCH_PRIO $(type -P fclones) "$@"
fi
}
_BATCH_PRIO ()
{
ionice --class idle nice -n 19 "$@"
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
alias repo="_ICON 🪣 _BATCH_PRIO repo"

export LESS='-Q -R'
alias gl="LESS='-Q -R --pattern ^(commit|diff)' git log -p"
alias ga='git add -p'
alias gr='git reflog'
alias gx='git checkout'
alias grc='git rebase --continue'
alias gbl='git blame'
alias gmt='git mergetool'
alias gdt='git difftool'
alias gxp='git checkout -p'
alias rd='repo diff'
alias rud='repo upload -d'
alias ru='repo upload'
alias rb='repo branch'
alias r='repo status'
alias -- -='c -'
alias ..='c ..'
alias rud='repo upload -d'
alias man='MANWIDTH=$((COLUMNS > 80 ? 80 : COLUMNS)) _NO_MEASURE _ICON 📓 man'
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
{
\git rev-parse --show-toplevel &>/dev/null || { _NO; return 1;}
_title "🐙  Branchy McBranchFace"
BRANCH=$({ \git branch -a|\cut -c3-1024; \git reflog;}|fzf --no-mouse)||exit 1
\git checkout ${BRANCH%% *}
}
alias b=_BRANCHY_MCBRANCHFACE

alias ll='ls -al --color=always'
alias l='_LS_HIDDEN -C'
alias ls='_LS_HIDDEN -C'
alias task_flash='task "⚡ FLASH ⚡"'
alias task_bake='task "🍞 Bake"'
alias task_bug="🐛 Bug"
alias xargs="xargs -d'\n'"
alias mosh="MOSH_TITLE_NOPREFIX=1 _NO_MEASURE mosh"
alias tmp=_TMP_ALL_THE_THINGS
#alias y=_YANKY
#alias p=_PANKY
alias grep="_ICON 🔎 _MOAR grep -a"
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
alias ssh="_NO_MEASURE ssh"
unalias google-chrome
unalias chrome
pidof chrome || /bin/rm -rf "${DIR}" "~/.cache/google-chrome-beta" "~/.cache/google-chrome"  "~/.config/google-chrome-beta" "~/.config/google-chrome"

function _CHROME-POLISHER
{
if [ -n "$WAYLAND_DISPLAY" ]
then
local WAYLAND_OPTS="--enable-features=UseOzonePlatform --ozone-platform=wayland"
fi
    local DIR=/run/user/${UID}/_CHROME-POLISHER-${USER}
    pidof chrome &>/dev/null || /bin/rm -rf "${DIR}" "~/.cache/google-chrome-beta" "~/.cache/google-chrome"  "~/.config/google-chrome-beta" "~/.config/google-chrome" &>/dev/null
    \mkdir -p "${DIR}" &>/dev/null
    _CAN_OPENER google-chrome-beta ${WAYLAND_OPTS} --disable-notifications --disable-features=Translate --disable-features=TranslateUI --no-default-browser-check --no-first-run -user-data-dir="${DIR}/chrome" "${*}"
}
function _CHROME-POLISHER-tmp
{
if [ -n "$WAYLAND_DISPLAY" ]
then
local WAYLAND_OPTS="--enable-features=UseOzonePlatform --ozone-platform=wayland"
fi
    local DIR="/run/user/${UID}/_CHROME-POLISHER-${USER}/${1}"
    pidof chrome &>/dev/null || /bin/rm -rf "${DIR}"
    \mkdir -p ${DIR}
    shift
    _CAN_OPENER google-chrome-beta ${WAYLAND_OPTS} --disable-notifications --disable-features=TranslateUI --no-default-browser-check --no-first-run -user-data-dir="${DIR}" --app="${*}"
}
alias chromium=_CHROME-POLISHER
alias google-chrome=_CHROME-POLISHER
alias chrome=_CHROME-POLISHER
alias dos="bash ${DOTFILESDIR}/dos/sh-dos.sh"
alias sudo="\printf \"\e]10;#DD2222\a\e]11;#000000\a\e]12;#DD2222\a\";_ICON ⚠️  sudo"
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
test -z "${SERVER}" && { \echo "missing server argument"; return; }
/usr/bin/scp "${@}"
}
alias scp=_SCP

function _DEDUPE ()
{
    \yes 1 | \jdupes --delete --omit-first "${XDG_DOWNLOAD_DIR-/dev/null}" ~/Downloads
}

function c ()
{
    _CHDIR_ALL_THE_THINGS "$@" && {
        local TMP="/run/user/${UID}/ls-${RANDOM}.txt"
        local FILE
        for FILE in README.md README.txt README README.doc README.rst README.android README.* "READ *" "Read *" "Read *"
        do
        if [ -f "${FILE}" ]
        then
        \printf "\n   \e[1;4m"
        \sed -e '/^=.*/d' -e 's/^[[:space:]]*//g' -e '/^!.*/d' -e '/^\[!.*/d' -e 's/# //g' -e 's/<[^>]*>//g' -e '/^[[:space:]]*$/d' "${FILE}" | \head -n1
        \printf "\e[0m\n"
        break
        fi
        done
        if [ -d .git ]; then
        local MAXLINES=$((LINES - 8))
        else
        local MAXLINES=$((LINES - 6))
        fi
        _LS_HIDDEN -C -w${COLUMNS} | \tee "${TMP}" | \head -n${MAXLINES}
        local LS_LINES=$(wc -l < $TMP) 
        [ ${LS_LINES} -gt ${MAXLINES} ] && \printf "...\n"
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
        _LS_HIDDEN -A -C -w${COLUMNS} | \tee "${TMP}" | \tee "${TMP}" | \head -n${MAXLINES}
        local LS_LINES=$(wc -l < $TMP) 
        [ ${LS_LINES} -gt ${MAXLINES} ] && \printf "...\n"
        else
        \printf "<empty>\n"
        fi
        fi
        [ -d ".git" ] && { \printf "\n";PAGER= $(type -P git) log --oneline -1 --color=never 2>/dev/null;}
        ( /bin/rm -f "${TMP}" &>/dev/null & )
    }
    ( _DEDUPE &>/dev/null & )
}

function untilfail
{
    if [ "${#@}" = 0 ] 
    then
        _NO
        return 255
    fi
    local COUNT=0
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
}

function _RETRY
{
    if [ "${#@}" = 0 ] 
    then
        _NO
        return 255
    fi
    \printf '\n\e7' >&2 | \tee >&2
    local a=0
    until "$@"
    do
        {
        \printf '\e[?25l\e8\e[2A'
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
        \printf '\e[?25h'
        } >&2 | \tee >&2
    done
}

alias retry=_RETRY

function _NO
{
    \printf "\r\e[JCOMPUTER SAYS NO\n" >&2 | \tee >/dev/null
}

# loop is an xscreensaver module 
unalias loop
function _LOOP
{
    if [ "${#@}" = 0 ] 
    then
        _NO
        return 255
    fi
    \printf '\n\e7' >&2 | \tee >&2
    local a=0
    while true
    do
        {
        \printf '\e[?25l\e8\e[2A'
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
        \printf '\e[?25h'
        } >&2 | \tee >&2
    done
}
alias loop=_LOOP

function now
{
    \date +%Y-%m-%d_%H-%M-%S
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

function front
{
    if [ "${#@}" = 0 ]
    then
    return 1
    fi
    local FILE
    for FILE in "$@"
    do
        \printf "${FILE}"
        break
    done
}
function back
{
    if [ "${#@}" = 0 ]
    then
    return 1
    fi
    local FILE
    for FILE in "$@"
    do
        :
    done
    \printf "${FILE}"
}

function _LOG
{
local LOGFILE="${TTY//\//_}"
local LOGDIR="${HOME}/.cache/logs"
\mkdir -p "${LOGDIR}";
local LOG="${_LOGFILE-${LOGDIR}/${LOGFILE}}"
local ARG
local TEMP=$(\mktemp)
for ARG in "exec" "-a" "$1" "ionice" "--class" "idle" "nice" "-n" "19" "$@"
do
\echo -n "\"${ARG}\" " >>"${TEMP}"
done
script -q -e -a -c "bash \"${TEMP}\"" "${LOG}"
local RETURN=$?
\sed -i -e 's/\x1b\[[0-9;]*[a-zA-Z]//g' -e 's/\r/\n/g' "${LOG}"
/bin/rm -f "${TEMP}"
return ${RETURN}
}

local FILE
for FILE in /*
do
eval "function $FILE { echo \"C-comment paste detected. Press CTRL+C to continue\";cat;}"
break;
done

_SPINNER_START ()
{
_SPINNER_PID_FILE=$(mktemp)                         
(
SPINNER ()
{
{
\printf "\\e[?25l"
while sleep 0.04 && [ -f "${_SPINNER_PID_FILE}" ]; do
\printf "\\r\\e[J"
sleep 0.04
[ -f "${_SPINNER_PID_FILE}" ] && \printf "\\r\\e[J  ."
sleep 0.04
[ -f "${_SPINNER_PID_FILE}" ] && \printf "\\r\\e[J .."
sleep 0.04
[ -f "${_SPINNER_PID_FILE}" ] && \printf "\\r\\e[J..."
sleep 0.04
[ -f "${_SPINNER_PID_FILE}" ] && \printf "\\r\\e[J.. "
sleep 0.04
[ -f "${_SPINNER_PID_FILE}" ] && \printf "\\r\\e[J.  "
done
} >&2 | tee 2>/dev/null
}
SPINNER &
\echo $! > "${_SPINNER_PID_FILE}"                               
)
}
_SPINNER_STOP ()
{
{
kill -9 $(<${_SPINNER_PID_FILE})
( /bin/rm -f ${_SPINNER_PID_FILE} & )
unset _SPINNER_PID_FILE
} &>/dev/null
\printf "\\r\\e[J" >&2 | tee 2>/dev/null
}

# https://stackoverflow.com/questions/51653450/show-call-stack-in-bash
function _STACKTRACE { 
   local i=1 line file func
   while read -r line func file < <(caller $i); do
      echo >&2 "[$i] $file:$line $func(): $(sed -n ${line}p $file)"
      ((i++))
   done
}
. ~/.bashrc.local
unset _SOURCED
bind 'set completion-ignore-case on'
bind 'set bell-style none'
fi

(
function ignore_chrome_crash
{
exec sed -i 's/"exited_cleanly": false/"exited_cleanly": true/' \
    ~/.config/google-chrome/Default/Preferences \
    ~/.config/google-chrome-beta/Default/Preferences
}
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
    /bin/rm -rf ~/.cache/tracker* ~/.local/share/tracker*
}
# try to run one thread for non-blocking background tasks such that CPU 
# and IO is not stressed at shell startup, this way we will get to prompt 
# faster
function background_startup_tasks
{
ignore_chrome_crash
kill_tracker
# mount shares can wait for network I/O quite some time, do this late to not block other tasks
bash ~/.config/dotfiles/deal-with-it/deal-with-it.sh &
mkdir -p ~/.cache/vim/backup/ ~/.cache/vim/swp/ ~/.cache/vim/undo/ "${GOPATH}"

# hide files from nautilus and ls
ln -sf "${DOTFILESDIR}/home.hidden" ~/.hidden
ln -sf "${DOTFILESDIR}/home.xscreensaver" ~/.xscreensaver
mount_shares
rm -f "~/.cache/logs/${TTY//\//_}"
}
background_startup_tasks &
)
unset -f _dotfiles_main
}
} &>/dev/null

OLD_LC_ALL=${LC_ALL}
if ! shopt -q login_shell
then
if [ -f ~/.bashrc.statistics ]
then
time LC_ALL=C _dotfiles_main &>/dev/null
elif [ -f ~/.bashrc.debug ]
then
set -x
export PS4='+ $EPOCHREALTIME ($LINENO) '
LC_ALL=C _dotfiles_main
unset PS4
else
LC_ALL=C _dotfiles_main &>/dev/null
fi
elif [ -z "${DISPLAY}${WAYLAND_DISPLAY}" ]
then
LC_ALL=C _dotfiles_main &>/dev/null
else
unset OLD_LC_ALL
fi
