#/bin/bash
{
	_dotfiles_main() {
	    if [[ $TERM = dumb ]] || [[ $TERM = vt50 ]]; then
			stty iuclc
		fi
		if [ -n "${TMUX}" ]; then
			(
				setup_tmux() {
					tmux set -g status off
					tmux set-option -g set-titles-string "#T"
					tmux set-option -g set-titles on
					tmux bind -n S-Pageup copy-mode -u
					tmux bind -n S-Up copy-mode -u
					tmux set-window-option -g mode-keys vi
					tmux bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
					tmux bind-key -T copy-mode-vi 'y' send-keys -X copy-selection-and-cancel
					tmux bind-key p paste-buffer
					for i in $(seq 1 9); do
						tmux bind-key -n M-$i select-window -t $i
					done
				}
				setup_tmux &
			)
		elif [ -z "${WAYLAND_DISPLAY}" ] && [ -z "${DISPLAY}" ] && [ -z "${SCHROOT_SESSION_ID}" ] && [ -x "/usr/bin/tmux" ]; then
			read NUM </run/user/${UID}/tmux-session
			NUM=${NUM-0}
			NUM=$((NUM + 1))
			NUM=$((NUM % 3))
			\echo ${NUM} >/run/user/${UID}/tmux-session
			\cat >~/.tmux.conf <<EOF
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

			LC_ALL=${ORIG_LC_ALL} tmux -L ${NUM} attach-session || LC_ALL=${ORIGF_LC_ALL} tmux -L ${NUM}
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
		export HISTSIZE=100000     # big big history
		export HISTFILESIZE=100000 # big big history
		shopt -s globstar
		export BAT_THEME=GitHub

		PATH=${PATH}:~/.local/share/ParaView/bin:~/.local/share/android-studio/bin:~/.local/bin:/usr/share/code-insiders/resources/app/node_modules.asar.unpacked/vscode-ripgrep/bin/

		DOTFILESDIR=$(readlink "${HOME}/.bashrc")
		DOTFILESDIR=${DOTFILESDIR%/*}
		[[ -z $DOTFILESDIR ]] && DOTFILESDIR=$HOME/.local/share/dotfiles
		export GOPATH=${HOME}/.local/share/go

		export VIM=${DOTFILESDIR}/vim
		export VIMRUNTIME=${DOTFILESDIR}/vim
		BGCOLOR="FFFAF1"
		FGCOLOR="312D2A"
		. "${DOTFILESDIR}"/monorail/monorail.sh
		. "${DOTFILESDIR}"/chdir-all-the-things/chdir-all-the-things.sh
		. "${DOTFILESDIR}"/can-opener/can-opener.sh
		. "${DOTFILESDIR}"/shabacus/shabacus.sh
		. "${DOTFILESDIR}"/uber-for-mv/uber-for-mv.sh
		. "${DOTFILESDIR}"/moar/moar.sh
		. "${DOTFILESDIR}"/ermahgerd/ermahgerd.sh
		. "${DOTFILESDIR}"/i-like-to-move-it/i-like-to-move-it.sh
		. "${DOTFILESDIR}"/fuuuu/fuuuu.sh
		. "${DOTFILESDIR}"/stawkastic/stawkastic.sh
		. "${DOTFILESDIR}"/zipit/zipit.sh
		. "${DOTFILESDIR}"/quacklook/quacklook.sh

        _DOTFILES_COLOR ()
        {
        if [[ $NO_COLOR = 1 ]]
        then
            \echo "never"
        else
            \echo "always"
        fi
        }

        if _MONORAIL_DUMB_TERMINAL
        then
            NO_COLOR=1
        fi

		if type -P nvim; then
			EDITOR="nvim"
			alias nvim='XDG_DATA_HOME="${VIM}" _NO_MEASURE _ICON 📝 $EDITOR -u "${VIM}"/nvimrc -p '
			alias vim='XDG_DATA_HOME="${VIM}" _NO_MEASURE _ICON 📝 $EDITOR -u "${VIM}"/nvimrc -p '
		else
			EDITOR="vim"
			alias nvim='XDG_DATA_HOME="${VIM}" _NO_MEASURE _ICON 📝 $EDITOR -u "${VIM}"/nvimrc -p '
		fi
		alias ivm=$EDITOR
		alias vi=$EDITOR
		alias vim=$EDITOR
		alias im=$EDITOR
		alias v=$EDITOR
		alias nano=$EDITOR

		# set some fallback defaults if xdg-user-dirs are not available
		XDG_DESKTOP_DIR="$HOME/"
		XDG_DOWNLOAD_DIR="$HOME/Downloads"
		XDG_TEMPLATES_DIR="$HOME/Templates"
		XDG_PUBLICSHARE_DIR="$HOME/Public"
		XDG_DOCUMENTS_DIR="$HOME/Documents"
		XDG_MUSIC_DIR="$HOME/Music"
		XDG_PICTURES_DIR="$HOME/Pictures"
		XDG_VIDEOS_DIR="$HOME/Videos"
		# set the correct xdg user dir defaults
		[[ -f ~/.config/user-dirs.dirs ]] || xdg-user-dirs-update
		. ~/.config/user-dirs.dirs

		export EDITOR
		_EDITOR() {
			_MEASURE=0
			local FILE
			for FILE in "$@"; do
				case "${FILE,,}" in
				-*) : ;;
				*.kt | *.java)
					type -P studio.sh &>/dev/null && _CAN_OPENER studio.sh "${PWD}/${FILE}"
					return
					;;
				esac
			done
			XDG_DATA_HOME="${VIM}" $(type -P "nvim" 2>/dev/null || type -P "vim" 2>/dev/null || type -P "vi" 2>/dev/null) -u "${VIM}"/nvim.vim -p "${@}"
		}

		[ -x ~/.local/share/android-studio/bin/studio.sh ] && alias studio='o _LOW_PRIO ~/.local/share/android-studio/bin/studio.sh'
		[ -x ~/.local/bin/PabloDraw.exe ] && alias pablodraw='o mono ~/.local/bin/PabloDraw.exe'
		[ -x ~/.local/share/ghidra/ghidraRun ] && alias ghidra='o ~/.local/share/ghidra/ghidraRun'
		alias shellcheck='_ICON 🛠️ _LOG shellcheck'
		alias clang='_ICON 🛠️ _LOG clang'
		alias gcc='_ICON 🛠️ _LOG gcc'
		alias g++='_ICON 🛠️ _LOG g++'
		alias snapcraft='_ICON 🛠️ _LOG snapcraft --verbose'
		alias ninja='_ICON 🛠️ _LOG ninja'
		alias make='_ICON 🛠️ _LOG make -j$(nproc)'
		alias bitbake='_ICON 🛠️ _LOG bitbake'
		alias just='_ICON 🛠️ _LOG just'
		alias jhbuild='_ICON 🛠️ _LOG jhbuild'
		alias bash='_ICON 🐚 _LOG bash'
		alias zsh='_ICON 🐚 _LOG zsh'
		alias ksh='_ICON 🐚 _LOG ksh'
		alias sh='_ICON 🐚 _LOG sh'
		alias cat="_ICON 🐱 _MOAR cat"
		alias delta='_ICON Δ _LOW_PRIO delta --light'
		_DONT_COPY_THAT_FLOPPY() {
			
			if [ "${#@}" = 2 ]; then
				if [[ -d "${2}" ]]; then
					DEST=${2}/$(basename "${1}")
				else
					DEST=${2}
				fi
				(
                    [[ -e "${1}" ]] || { echo "ERROR: source is missing"; exit 42;}
                    [[ -e "${DEST}" ]] && { echo "ERROR: will not overwrite existing file"; exit 42;}
                    if ! _LOW_PRIO cp --reflink=always "$1" "$DEST" 2>/dev/null
                    then
					    chrt -i 0 pv "${1}" >"${DEST}"
                    fi
				)
			else
				chrt -i 0 cp --reflink=auto "$@"
			fi
		}
		alias cp='_ICON 💽 _DONT_COPY_THAT_FLOPPY'
		alias dd='_ICON 💽 _LOW_PRIO dd status=progress'
		alias dl="${DOTFILESDIR}/uber-for-mv/dl.sh $(xdg-user-dir DOWNLOAD)"
		alias octave=octave-cli
		alias excel='o localc --norestore --view'
		alias word='o lowriter --norestore --view'
		alias localc='o localc --norestore --view'
		alias loimpress='o loimpress --norestore --view'
		alias lowriter='o lowriter --norestore --view'
		alias powerpoint='o loimpress --norestore --view'
		alias visio='o lodraw --norestore --view'
		alias scrcpy='_RETRY scrcpy'
		alias adb='_NO_MEASURE _ICON 🤖 _RETRY adb'
		if [ -n "$WAYLAND_DISPLAY" ]; then
			local WAYLAND_OPTS="--enable-features=UseOzonePlatform --ozone-platform=wayland"
		fi
		alias chrome='o google-chrome-beta ${WAYLAND_OPTS}'
		alias code-insiders='o code-insiders'
		alias code='o code-insiders'
		_GIT() {
            local TERM
            _MONORAIL_DUMB_TERMINAL && export TERM=dumb

			# avoid printing title if using completion
			case "${*}" in
			*'--git-dir='*) : ;;
			*)
				_TITLE "🪣  $*"
				;;
			esac
			case "$1" in
			clone | push)
				_LOG \git "$@"
				;;
			log | show | diff)
				_MEASURE=0
				\git "$@"
				;;
			*)
				_MEASURE=0

                _MOAR git "$@"
				;;
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
		alias rga="_ICON 🔎 _MOAR rga --color=$(_DOTFILES_COLOR)"
		alias rg='_ICON 🔎 _MOAR rg'
		alias strace='_ICON 👣 _LOG strace'
		alias top='_NO_MEASURE _ICON 📈 top'
		alias ntop='_NO_MEASURE _ICON 📈 ntop'
		alias htop='_NO_MEASURE _ICON 📈 htop'
		alias nload='_NO_MEASURE _ICON 📈 nload'
		alias rm='_ICON ♻️  _ERMAHGERD'
		alias trash='_ICON ♻️  gio trash'
		alias jdupes='_ICON ♻️  jdupes --dedupe -R'
		alias hog="${DOTFILESDIR}"/hog/hog.sh
		alias g="_ICON 🔎 egrep"
		alias gv="_ICON 🔎 grep -v"
		_TIMER() {
_NO_MEASURE
			local time=$(($1 * 60))
			while sleep 1; do
				let time--
				local minutes=$((time / 60))
				local seconds=$((time % 60))
				if [ ${#seconds} = 1 ]; then
					seconds=0${seconds}
				fi
				clear
				printf "\033]0;⏲️  ${minutes}:${seconds}\007\033[?25l

    ${minutes}:${seconds}"
				if [ ${time} -le 0 ]; then
                    clear
					mplayer "${DOTFILESDIR}"/kitchen_timer.ogg &>/dev/null
					printf '\033]0;⏲️  Time is up!\007Time is up! Press key to continue'
					read -n1
					return 0
				fi
			done
		}
		alias timer=_TIMER
		_FCLONES() {
			[ -z "$(type -P fclones)" ] && _NO
			if [ -z "$1" ]; then
				_LOW_PRIO $(type -P fclones) group "$PWD" | _LOW_PRIO $(type -P fclones) dedupe
			else
				_LOW_PRIO $(type -P fclones) "$@"
			fi
		}
		alias fclones="_ICON ♻️  _FCLONES"
		_REPO() {
			if [ -z "$SSH_AUTH_SOCK" ]; then
				eval $(ssh-agent)
				ssh-add
			fi
			\repo "$@"
		}
		alias repo="_ICON 🪣 _REPO"

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

		_LS_HIDDEN() {
			case "${PWD}" in
			${HOME}/Network/* | /run/user/*/gvfs/* | /mnt/* | /media/*)
				# do not print colors on network drives
				# this is faster since `ls(1)` do not need to run statx(2) or getdents64(2)
				# on listed files
				_MOAR ls -C "$@"
				;;
			*)
				local hide=()
				if [ -f .hidden ]; then
					while IFS="
" read -r line; do
						hide+=("--hide=${line}")
					done <.hidden
				fi
				_MOAR ls "${hide[@]}" --color=$(_DOTFILES_COLOR) "$@"
				;;
			esac
		}

		_BRANCHY_MCBRANCHFACE() {
			\git rev-parse --show-toplevel &>/dev/null || _NO
			_TITLE "🐙  Branchy McBranchFace"
			BRANCH=$({
				\git branch -a | \cut -c3-1024
				\git reflog
			} | fzf --no-mouse) || return 1
			\git checkout ${BRANCH%% *}
		}
		alias b=_BRANCHY_MCBRANCHFACE

		_FUZZY_FD() {
			f=$(fd "$@" | fzf --no-mouse)
			[ -n "$f" ] && \echo "f=$f"
		}
		alias fz=_FUZZY_FD

		alias ll="\ls -al --color=$(_DOTFILES_COLOR)"
		alias l='_LS_HIDDEN -v -C'
		alias ls='_LS_HIDDEN -v -C'
		alias sl=ls
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
		pidof chrome || /bin/rm -rf "${DIR}" "~/.cache/google-chrome-beta" "~/.cache/google-chrome" "~/.config/google-chrome-beta" "~/.config/google-chrome"

		_CHROME-POLISHER() {
			if [ -n "$WAYLAND_DISPLAY" ]; then
				local WAYLAND_OPTS="--enable-features=UseOzonePlatform --ozone-platform=wayland"
			fi
			local DIR=/run/user/${UID}/_CHROME-POLISHER-${USER}
			pidof chrome &>/dev/null || /bin/rm -rf "${DIR}" "~/.cache/google-chrome-beta" "~/.cache/google-chrome" "~/.config/google-chrome-beta" "~/.config/google-chrome" &>/dev/null
			\mkdir -p "${DIR}" &>/dev/null
			_CAN_OPENER google-chrome-beta ${WAYLAND_OPTS} --disable-notifications --disable-features=Translate --disable-features=TranslateUI --no-default-browser-check --no-first-run -user-data-dir="${DIR}/chrome" "${*}"
		}
		_CHROME-POLISHER-tmp() {
			if [ -n "$WAYLAND_DISPLAY" ]; then
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
		alias sudo="\printf \"\e]10;#DD2222\a\e]11;#000000\a\e]12;#DD2222\a\";_ICON ⚠️  _LOG sudo"
		alias su="\printf \"\e]10;#DD2222\a\e]11;#000000\a\e]12;#DD2222\a\";_ICON ⚠️  _LOG su"
		_SCP() {
			local ARG
			local SERVER
			SERVER=""
			for ARG in "${@}"; do
				case "${ARG}" in
				*:*)
					SERVER=${ARG%%:*}
					SERVER=${SERVER#*@}
					;;
				esac
			done
			test -z "${SERVER}" && {
				\echo "missing server argument"
				return
			}
			/usr/bin/scp "${@}"
		}
		alias scp=_SCP

		c() {
			_CHDIR_ALL_THE_THINGS "$@" && {
				local TMP FILE
				if [[ -w "/run/user/${UID}" ]]; then
					TMP="/run/user/${UID}/ls-${RANDOM}.txt"
				else
					TMP="/tmp/ls-${RANDOM}.txt"
				fi
				for FILE in README.md README.txt README README.doc README.rst README.android README.* "READ *" "Read *" "Read *" "readme"*; do
					if [ -f "${FILE}" ]; then
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
				_LS_HIDDEN -v -C -w${COLUMNS} | \tee "${TMP}" | \head -n${MAXLINES}
				local LS_LINES=$(wc -l <$TMP)
				[ ${LS_LINES} -gt ${MAXLINES} ] && \printf "...\n"
				if [ ${LS_LINES} = 0 ]; then
					local COUNT=0
					local FILES
					for FILES in .*; do
						let COUNT++
					done
					if [ ${COUNT} -gt 2 ]; then
						_LS_HIDDEN -v -A -C -w${COLUMNS} | \tee "${TMP}" | \tee "${TMP}" | \head -n${MAXLINES}
						local LS_LINES=$(wc -l <$TMP)
						[ ${LS_LINES} -gt ${MAXLINES} ] && \printf "...\n"
					else
						\printf "<empty>\n"
					fi
				fi
				[ -d ".git" ] && {
					\printf "\n"
					PAGER= $(type -P git) log --oneline -1 --color=never 2>/dev/null
				}
				(/bin/rm -f "${TMP}" &>/dev/null &)
			}
		}

		untilfail() {
			if [ "${#@}" = 0 ]; then
				_NO
				return 255
			fi
			local COUNT=0
			while "$@"; do
				sleep 1
				let COUNT=1+${COUNT}
				if [ ${COUNT} -gt 10 ]; then
					echo "=== "$(LC_ALL=C date +%H:%M:%S)" ==="
					COUNT=0
				fi
			done
		}

		_RETRY() {
			if [ "${#@}" = 0 ]; then
				_NO
				return 255
			fi
			\printf '\n\e7' >&2 | \tee >&2
			local a=0
			until "$@"; do
				{
					\printf '\e[?25l\e8\e[2A'
					case $a in
					0) \printf '.  ' ;;
					1) \printf '.. ' ;;
					2) \printf '...' ;;
					3) \printf ' ..' ;;
					4) \printf '  .' ;;
					5) \printf '   ' ;;
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

        _BLANK ()
        {
            _NO_MEASURE
            _TITLE_RAW " "
            printf "\033[?25l"
            clear
            while sleep 100000000000000000
            do
                true
            done
        }
        alias blank=_BLANK

		_NO() {
			\printf "\r\e[JCOMPUTER SAYS NO\n" >&2 | \tee >/dev/null
			return 255
		}

		# loop is an xscreensaver module
		unalias loop
		_LOOP() {
			if [ "${#@}" = 0 ]; then
				_NO
				return 255
			fi
			\printf '\n\e7' >&2 | \tee >&2
			local a=0
			while true; do
				{
					\printf '\e[?25l\e8\e[2A'
					"$@"
					case $a in
					0) \printf ' .   ' ;;
					1) \printf ' ..  ' ;;
					2) \printf ' ... ' ;;
					3) \printf '  .. ' ;;
					4) \printf '   . ' ;;
					5) \printf '     ' ;;
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

		now() {
			LC_ALL=C \date +%Y-%m-%d_%H-%M-%S
		}

		jetzt() {
			now
		}

		/sbin/reboot() {
			_NO
			return 255
		}

		alias reboot=_NO
		alias shutdown=_NO

		/sbin/shutdown() {
			_NO
			return 255
		}

		//() {
			:
		}

		_CP_LAST_ITEM() {
			if [ "${#@}" -lt 2 ]; then
				echo "usage: cplast [<FLAGS>] [SOURCE]... [DESTINATION]
only the last SOURCE is copied
will not overwrite destination
" 1>&2 | tee 1>/dev/null

				return 1
			fi
			local FILE
			local LAST_ITEM
			local SECOND_LAST_ITEM
			for FILE in "$@"; do
				if [[ -f "${FILE}" ]]; then
					SECOND_LAST_ITEM="${LAST_ITEM}"
				fi
				LAST_ITEM="${FILE}"
			done
			if [[ -e "${LAST_ITEM}" ]]; then
				echo "cplast: will not overwrite existing file ${LAST_ITEM}" 1>&2 | tee 1>/dev/null
				return 1
			fi
			cp -r --update=none "${SECOND_LAST_ITEM}" "${LAST_ITEM}"
		}
		alias cplast=_CP_LAST_ITEM

		_LOG() {
			if [ -t 1 ]; then
				local LOGFILE="${TTY//\//_}"
				local LOGDIR="${HOME}/.cache/logs"
				\mkdir -p "${LOGDIR}"
				local LOG="${_LOGFILE-${LOGDIR}/${LOGFILE}}"
				local ARG
				local TEMP=$(\mktemp)
				for ARG in "exec" "-a" "$1" "chrt" "-i" "0" "$@"; do
					\echo -n "\"${ARG}\" " >>"${TEMP}"
				done
				\echo "$*" >"${LOG}"
				script -a -q -e -c "bash \"${TEMP}\"" "${LOG}"
				local RETURN=$?
				{
					\sed -i -e 's/\x1b\[[0-9;]*[a-zA-Z]//g' -e "s/$'\x0d'/\n/g" -e "s/$'\x0a'$'\x0a'/\n/g" "${LOG}"
					/bin/rm -f "${TEMP}"
				} &>/dev/null
				return ${RETURN}
			else
				"$@"
			fi
		}

		local FILE
		for FILE in /*; do
			eval "$FILE () { echo \"C-comment paste detected. Press CTRL+C to continue\";cat;}"
			break
		done

		_SPINNER_START() {
			kill -9 ${_SPINNER_PID} &>/dev/null
			unset _SPINNER_PID
			_SPINNER_PID_FILE=$(mktemp)
			(
				SPINNER() {
					{
						\echo $! >"${_SPINNER_PID_FILE}"
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
			)
			while [[ -n ${_SPINNER_PID} ]]; do
				sleep 0.1
				read _SPINNER_PID <_SPINNER_PID_FILE
			done
		}

		_SPINNER_STOP() {
			{
				/bin/rm -f ${_SPINNER_PID_FILE}
				kill -9 ${_SPINNER_PID}
				unset _SPINNER_PID_FILE _SPINNER_PID
			} &>/dev/null
			\printf "\\r\\e[J" >&2 | tee 2>/dev/null
		}

		# https://stackoverflow.com/questions/51653450/show-call-stack-in-bash
		_STACKTRACE() {
			local i=1 line file func
			while read -r line func file < <(caller $i); do
				echo >&2 "[$i] $file:$line $func(): $(sed -n ${line}p $file)"
				((i++))
			done
		}
		. ~/.bashrc.local
		bind 'set completion-ignore-case on'
		bind 'set bell-style none'
		#https://stackoverflow.com/questions/6250698/how-to-decode-url-encoded-string-in-shell
		urldecode() {
			: "${*//+/ }"
			echo -e "${_//%/\\x}"
		}

		update_recent() {
			\mkdir -p ~/Recent
			\rm -f ~/Recent/*
			local ITEM
			local IFS="
"
			for ITEM in $(\gio tree recent:// | \grep ' file://'); do
				ITEM=${ITEM:47}
				ITEM=$(urldecode "${ITEM}")
				ITEM=${ITEM//%20/ }
				SRC_ITEM=${ITEM}
				ITEM=${ITEM##*/}
				\echo "## ${SRC_ITEM} -> ${ITEM} ##\n"
				\ln -s "${SRC_ITEM}" "${HOME}/Recent/${ITEM}"
			done
		}
		(
			ignore_chrome_crash() {
				exec sed -i 's/"exited_cleanly": false/"exited_cleanly": true/' \
					~/.config/google-chrome/Default/Preferences \
					~/.config/google-chrome-beta/Default/Preferences
			}
			mount_shares() {
				local item
				for item in $(\cat ~/.config/gtk-3.0/bookmarks | \grep -v file:// | \cut -d" " -f1); do
					gio mount "${item}" &
				done
			}

			kill_tracker() {
				systemctl --user mask tracker-store.service tracker-miner-fs.service tracker-miner-rss.service tracker-extract.service tracker-miner-apps.service tracker-writeback.service
				tracker3 daemon -k
				tracker daemon -k
				/bin/rm -rf ~/.cache/tracker* ~/.local/share/tracker*
			}
			# try to run one thread for non-blocking background tasks such that CPU
			# and IO is not stressed at shell startup, this way we will get to prompt
			# faster
			background_startup_tasks() {
				mkdir -p ~/.cache/vim/backup/ ~/.cache/vim/swp/ ~/.cache/vim/undo
				update_recent
				ignore_chrome_crash
				kill_tracker
				gsettings set org.gnome.settings-daemon.plugins.power idle-brightness 100
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

# Avoid starting dotfiles if login shell. unless...
[[ ${PS1} ]] && if ! shopt -q login_shell; then
	# print startup statistics
	if [ -f ~/.bashrc.statistics ]; then
		time ORIG_LC_MESSAGES="$LC_MESSAGES" ORIG_LC_ALL="$LC_ALL" LC_MESSAGES=C LC_ALL=C _dotfiles_main &>/dev/null
	# enable debugging
	elif [ -f ~/.bashrc.debug ]; then
		set -x
		export PS4='+ $EPOCHREALTIME ($LINENO) '
		ORIG_LC_MESSAGES="$LC_MESSAGES" ORIG_LC_ALL="$LC_ALL" LC_MESSAGES=C LC_ALL=C _dotfiles_main
		unset PS4
	else
		# normal case
		# most programs run faster if not needing to parse UTF-8
		# by only redirecting stdout and stderr to /dev/null once we get significant
		# startup speedup
		ORIG_LC_MESSAGES="$LC_MESSAGES" ORIG_LC_ALL="$LC_ALL" LC_MESSAGES=C LC_ALL=C _dotfiles_main &>/dev/null
	fi
# if linux/bsd console, start dotfiles function anyway
elif [ -z "${DISPLAY}${WAYLAND_DISPLAY}" ]; then
	ORIG_LC_MESSAGES="$LC_MESSAGES" ORIG_LC_ALL="$LC_ALL" LC_MESSAGES=C LC_ALL=C _dotfiles_main &>/dev/null
else
	unset OLD_LC_ALL
fi
