#!/bin/bash
# from https://raw.githubusercontent.com/liguoqinjim/github_emoji/master/github_all/README.md

_EMOJIFY_DEFINE ()
{
local TEMP=$(mktemp)
{
local IFS="
"
local ARG
echo -n "function _EMOJIFY () { command sed --unbuffered -e 's/::/__EMOJIFY_COLON_COLON__/g' "
for ARG in $(\cat ~/.config/dotfiles/emojify/README.md |\grep -v "^#"|\grep -v "|---"|\grep -v '|emoji_name'|\cut -d\| -f3-4|\sed -e 's_https://github.githubassets.com/images/icons/emoji/unicode/_\\U_g' -e 's/\.png?v8//g' -e 's/|/\//g'|\grep -v githubassets|\grep -v -)
do
\echo -ne " -e 's/${ARG}/g'"
done
echo " -e 's/__EMOJIFY_COLON_COLON__/::/g' ; }"
} > ${TEMP}
. ${TEMP}
\rm -rf "${TEMP}"
}
_EMOJIFY_DEFINE
unset -f _EMOJIFY_DEFINE
