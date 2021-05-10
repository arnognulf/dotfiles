#!/bin/bash
shopt -s checkwinsize 
LINES=$(stty size|cut -d" " -f1)
COLUMNS=$(stty size|cut -d" " -f2)
echo ${COLUMNS}
printf "\033[?25l"
printf ""
printf "\033[48;2;0;0;0m"
PRE_LEN=$(($((COLUMNS / 2 )) - $(($((16 * 3)) / 2))))
PRE=""
POST_LEN=$((COLUMNS - PRE_LEN - $(($((16 * 3)))) ))
echo $PRE_LEN
echo $POST_LEN
read
POST=""
P=0
while [ ${P} -lt ${PRE_LEN} ]
do
PRE="${PRE} "
let P++
done
Q=0
POST=""
while [ ${Q} -lt ${POST_LEN} ]
do
POST="${POST} "
let Q++
done
while sleep 0.2
do
BUF="\033[0;0H"
i=0
j=0
while [ $j -lt $(($LINES - 1)) ]
do
BUF="${BUF}${PRE}"
while [ $i -lt 16 ]
do
XRANDOM=${RANDOM}
if [ ${XRANDOM:$((${#XRANDOM} - 1)):1} -gt 4 ]
then
BUF="${BUF} \033[38;2;255;64;32m▆▆"
else
BUF="${BUF} \033[38;2;96;32;16m▆▆"
fi
let i++
done
let j++
i=0
if [ $j -ne $((${LINES} - 1 )) ]
then
BUF="${BUF}${POST}
"
fi
done
j=0
echo -ne "${BUF}"
done

#printf "\033[25h"
