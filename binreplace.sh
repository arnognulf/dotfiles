#!/bin/bash
PATTERN=$(echo -n "${2}" | hexdump -ve '1/1 "%.2X"')
REPLACEMENT=$(echo -n "${3}" | hexdump -ve '1/1 "%.2X"')
PATTERN16=$(echo -n "${2}" | iconv -f UTF-8 -t UTF-16BE | hexdump -ve '1/1 "%.2X"')
REPLACEMENT16=$(echo -n "${3}" | iconv -f UTF-8 -t UTF-16BE | hexdump -ve '1/1 "%.2X"')
OUTFILE_BASE="${1%.*}"
OUTFILE_BASE="${OUTFILE_BASE/${2}/${3}}"
OUTFILE_EXT="${1#*.}"
hexdump -ve '1/1 "%.2X"' "${1}" | \
sed "s/${PATTERN}/${REPLACEMENT}/g" | \
sed "s/${PATTERN16}/${REPLACEMENT16}/g" | \
xxd -r -p > "${OUTFILE_BASE}-patched.${OUTFILE_EXT}"
