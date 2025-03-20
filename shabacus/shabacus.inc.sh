#!/bin/bash

if ! [[ $_SHABACUS_DIR ]]; then
	if [[ ${BASH_ARGV[0]} != "/"* ]]; then
		_SHABACUS_DIR=$PWD/${BASH_ARGV[0]}
	else
		_SHABACUS_DIR="${BASH_ARGV[0]}"
	fi

	_SHABACUS_DIR="${_SHABACUS_DIR%/*}"
fi


function command_not_found_handle ()
{
   local ARGS=""
   for ARG in "${@}"
   do
      ARGS="${ARGS}${ARG} "
   done

case "${ARGS}" in
..*|*[a-d]|*[f-h]|*[j-zG-Z])
_SHABACUS_command_not_found "${@}"
return $?
;;
e" ")
_SHABACUS_DIR=${_SHABACUS_DIR} ${_SHABACUS_DIR}/shabacus.sh e 1
;;
log10" "*|log2" "*|lg" "*|0b[.0-9]*|0o[.0-9]*|0x*[.0-9A-F]*|j" "*|cos" "*|arctan" "*|sin" "*|e" "*|tan" "*|length" "*|sqrt" "*|cbrt" "*|round" "*|log10" "*|log" "*|pi*|ln" "*|√[.0-9]*|s'('*|c'('*|a'('*|l'('*|e'('*|j'('*|[.0-9]*|'-'[0-9]*|sqrt"("*|'('*|fac" "*|t" "*|tan" "*|arccsc" "*|arcsec" "*|arccot" "*|arccos" "*|arcsin" "*|lb" "*|sinh" "*|cosh" "*|tanh" "*|sech" "*|csch" "*|coth" "*|arcsinh" "*|arccosh" "*|arctanh" "*|cot" "*)
${_SHABACUS_DIR}/shabacus.sh "${@}"
;;
*)
_SHABACUS_command_not_found "${@}"
return $?
esac
}

ln ()
{
if [ -e "${1}" ]
then
"$(type -P ln)" "${@}"
else
case "${*}" in
e) ${_SHABACUS_DIR}/shabacus.sh "l(e(1))";;
e" "*|-[0-9]*|[0-9]*)  ${_SHABACUS_DIR}/shabacus.sh ln "${@}";;
*) "$(type -P ln)" "${@}"
esac
fi
}

log ()
{
case "$1" in
-*|[0-9]*)
${_SHABACUS_DIR}/shabacus.sh log "$@"
;;
*)
local _LOGFILE="${1}-$(now).log"
_LOG "$@"
esac
}
if [ -n "${ZSH_VERSION}" ]; then
function _SHABACUS_command_not_found ()
{
exec zsh -s -c "${@}"
}
else
function _SHABACUS_command_not_found ()
{
# command_not_found_handle() is run in a subshell
# unset so the localized error-string can be printed 
unset -f command_not_found_handle
"${@}"
return 127
}
fi

if [ -n "$ZSH_NAME" ]
then
function command_not_found_handler ()
{
command_not_found_handle "${@}"
}
fi

alias shabacus="${_SHABACUS_DIR}/shabacus.sh"

