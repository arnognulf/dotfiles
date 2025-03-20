#!/bin/bash
if ! [[ $_ERMAHGERD_DIR ]]; then
	if [[ ${BASH_ARGV[0]} != "/"* ]]; then
		_ERMAHGERD_DIR=$PWD/${BASH_ARGV[0]}
	else
		_ERMAHGERD_DIR="${BASH_ARGV[0]}"
	fi

	_ERMAHGERD_DIR="${_ERMAHGERD_DIR%/*}"
fi
alias rm=${_ERMAHGERD_DIR}/ermahgerd.sh
alias doh=${_ERMAHGERD_DIR}/doh.sh
unset _ERMAHGERD_DIR
