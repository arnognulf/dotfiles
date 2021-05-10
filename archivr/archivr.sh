#!/bin/bash

_ARCHIVR ()
{
if [ ${#@} -gt 1 ]
then
for ITEM in "${@}"
do
_ARCHIVR "${ITEM}"
done
return 0
fi
if [ ${#@} = 0 ]
then
echo "archivr: need at least one file as argument"
return 1
fi
if [ ! -f "${1}" ]
then
echo "archivr: ${1}: not a file; not archiving"
return 1
fi
local DIR
case "${1,,}" in
*.dotx|*.dotm|*.xlt|*.xltm|*.pot|*.potx|*.ott|*.oth|*.ots|*.ots|*.otg|*.otp)
DIR=$(xdg-user-dir TEMPLATES)
;;
*.doc|*.docb|*.docm|*.docx|*.rtf|*.odt|*.pptm|*.txt|*.html|*.htm|*.pptx|*.ppt|*.xls|*.xlsm|*.ods|*.odp|*.pps|*.ppsx|*.pdf|*.xps|*.ps)
DIR=$(xdg-user-dir DOCUMENTS)
;;
*.otf|*.ttf|*.ttc|*.afm|*.pfa)
DIR="${HOME}/.local/share/fonts"
;;
*.jpg|*.jpeg|*.tif|*.tiff|*.bmp|*.png|*.xcf|*.svg|*.gif)
DIR=$(xdg-user-dir PICTURES)
;;
*.wmv|*.mp4|*.avi|*.mpg|*.mpeg)
DIR=$(xdg-user-dir VIDEOS)
esac
if [ -z ${DIR} ]
then
echo "Where should I file this?"
else
mkdir -p "${DIR}"
echo "${1} 🡺> ${DIR}"
mv "${1}" "${DIR}"
fi
}
