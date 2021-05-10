#!/bin/bash

markdown_writer()
{
local INPUT
INPUT="${1}"
INPUT_LOWERCASE="${INPUT,,}"
INPUT_LOWERCASE_BASE="${INPUT_LOWERCASE##*/}"
case "${INPUT_LOWERCASE}" in
*.pdf|*.doc|*.docx|*.rtf|*.fodt|*.odt|.ott|*.pdb|*.psw|*.rtf|*.sdw|*.stw|*.sxw|*.uot|*.vor|*.wps)
local TEMP
TEMP="$(mktemp -d)"
cp "${INPUT}" "${TEMP}/temp.${INPUT_LOWERCASE_BASE##*.}"
local OUTPUT
local INPUT_BASE
local INPUT_BASE=${INPUT##*/}
local INTERMEDIATE
case "${INPUT_LOWERCASE}" in
*.pdf)
pdftohtml -s -p "${TEMP}/temp.${INPUT_LOWERCASE_BASE##*.}" &>/dev/null
INTERMEDIATE="${TEMP}/temp-html.html"
;;
*)
unoconv -f html "${TEMP}/temp.${INPUT_LOWERCASE_BASE##*.}" &>/dev/null
INTERMEDIATE="${TEMP}/temp.html"
esac
OUTPUT="${TEMP}/${INPUT_BASE%.*}".md 
pandoc -f html -t markdown -o "${OUTPUT}" "${INTERMEDIATE}" &>/dev/null
# remove empty \ line breaks
sed -i '/^::: {#page/d' "${OUTPUT}"
# remove background images
sed -i '/!\[background image\]/d' "${OUTPUT}"
# remove .western css markup
sed -i 's/{#.* .western}$//g' "${OUTPUT}"
# remove linebreaks in pdfs
sed -i -e ':a' -e 'N' -e '$!ba' -e 's/-\\\n//g' "${OUTPUT}"
sed -i -e ':a' -e 'N' -e '$!ba' -e 's/\\\n/ /g' "${OUTPUT}" 
# allow at most two newlines
sed -i -e ':a' -e 'N' -e '$!ba' -e 's/\n\n\n\n/\n\n/g' "${OUTPUT}" 
sed -i -e ':a' -e 'N' -e '$!ba' -e 's/\n\n\n/\n\n/g' "${OUTPUT}" 
sed -i 's/\\...//g' "${OUTPUT}" 
MD5=$(md5sum "${OUTPUT}")
MD5=$(md5sum "${OUTPUT}")
"${EDITOR-vim}" "${OUTPUT}"
MD5_NEW=$(md5sum "${OUTPUT}")
;;
*)
"${EDITOR-vim}" "$@"
esac
}

