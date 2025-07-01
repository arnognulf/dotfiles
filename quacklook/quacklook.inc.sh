#!/bin/bash
if ! [[ $_QUACKLOOK_DIR ]];then
if [[ ${BASH_ARGV[0]} != "/"* ]];then
_QUACKLOOK_DIR=$PWD/${BASH_ARGV[0]}
else
_QUACKLOOK_DIR="${BASH_ARGV[0]}"
fi
_QUACKLOOK_DIR="${_QUACKLOOK_DIR%/*}"
fi
alias d="_ICON 🦆 _NO_MEASURE $_QUACKLOOK_DIR/quacklook.sh"
alias quacklook="_ICON 🦆 _NO_MEASURE $_QUACKLOOK_DIR/quacklook.sh"
_FUZZY_QUACKLOOK(){
local tmp=$($_QUACKLOOK_DIR/quacklook.sh "$@"|grep -E -v "$^"|grep -E -v "Script started"|grep -E -v "Script done"|fzf --no-mouse --tac)
f=$(for line in $tmp;do printf "%s\n" $line;done|fzf --no-mouse --tac)
[ -n "$f" ]&&\echo "f=$f"
}
alias dz="_ICON 🦆 _FUZZY_QUACKLOOK"
