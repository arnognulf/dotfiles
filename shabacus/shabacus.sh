#!/bin/bash
#
# Copyright (c) 2021 Thomas Eriksson <thomas.eriksson@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

function _shabacus ()
{
local INDEX=0
local EXPR=""
local MATHTERM=""
local IFS=""
local FIRSTGLOB=""
local LASTGLOB=""
local GLOB=0
local BASE=10
local OBASE
unset OBASE
local COMMAND=""
local RESULT=""
local FORMATTED_RESULT=""
local FUNCTION_CALLS=0
local NUM_ARGS="${#@}"
local NUM_GLOB=0
local SHABACUS_DEFAULT_DECIMALS=4

if [ "${2}" = "in" ]
then
case "${3}" in
hex) OBASE=16;;
dec) OBASE=10;;
oct) OBASE=8;;
bin) OBASE=2;;
in) :;;
*)
echo "${FUNCNAME[0]}: unsupported conversion base: ${3}" >&2 | tee /dev/null >/dev/null; return 1;;
esac
fi

for MATHTERM in *
do
[ -z "${FIRSTGLOB}" ] && FIRSTGLOB="${MATHTERM}"
LASTGLOB="${MATHTERM}"
NUM_GLOB=$((NUM_GLOB + 1))
done
for MATHTERM in "${@}"
do
case "${MATHTERM}" in
*--help|*-h)

echo "\
SHABACUS: infix shell decimal calculator
========================================
Mathematical operators
----------------------
x + y    - addition
x - y    - subtraction
x * y    - multiplication
x / y    - division
x ^ y    - integer power
pow x y  - decimal power (NOT IMPLEMENTED)
x % y    - integer modulo of x and y
mod x y  - integer modulo of x and y (NOT IMPLEMENTED)
x!       - faculty of x
e x      - natural exponent
int x    - integer part of x
max x y  - maximum of x and y
min x y  - minimum of x and y

Trigonometric functions
-----------------------
tan x    - tangent for angle x in radians
cos x    - cosine for angle x in radians
sin x    - sine for angle x in radians
cot x    - cotangent for angle x in radians
arctan x - arcus tangent for x
arccsc x - arcus cosecant for x
arcsec x - arcus secant for x
arccot x - arcus cotangent for x
arccos x - arcus cosine for x
arcsin x - arcus sine for x

Hyperbolic functions
--------------------
sinh x    - hyperbolic sine for x
cosh x    - hyperbolic cosine for x
tanh x    - hyperbolic tangent for x
sech x    - hyperbolic tangent for x
csch x    - hyperbolic cosecant for x
coth x    - hyperbolic cotangent for x
arcsinh x - hyperbolic arcus sine for x
arccosh x - hyperbolic arcus cosine for x
arctanh x - hyperbolic arcus tangent for x

Logarithms
==========
ln x     - natural logarithm
log10 x  - logarithm to the base 10
log x    - logarithm to the base 10
log2 x   - logarithm to the base 2
lb x     - logarithm to the base 2
lg x     - logarithm to the base 2

Logical functions
-----------------
lsl x n  - logical shift left by n places
lsr x n  - logical shift right by n places
and x y  - bitwise AND of x and y
or x y   - bitwise OR of x and y
xor x y  - bitwise XOR of x and y
not x    - bitwise NOT of x
bitrev x - bitwise reverse x

Mass conversions
----------------
x UNIT in UNIT - where UNIT are any of [kg,lb,g,oz]

Velocity conversions
--------------------
x UNIT in UNIT - where UNIT are any of [mph,km/h,m/s]

Angle conversions
-----------------
x UNIT in UNIT - where UNIT are any of [deg,rad]

Temperature conversions
-----------------------
x UNIT in UNIT - where UNIT are any of [F,C,K]

Distance conversions
--------------------
x UNIT in UNIT - where UNIT are any of [cm,m,km,ft,in,yd]
" 1>&2 | tee /dev/null 1>/dev/null
return 1
esac

if [ "${GLOB}" = 1 ] && \
   [ "${MATHTERM}" = "${LASTGLOB}" ]
then
EXPR="${EXPR} *"
GLOB=0
# calculations in /proc may fail if we do not allow for
# parameter glob to be off by one to calculated glob
elif [ "${GLOB}" = 0 ] && \
     [ "${INDEX}" -lt $((NUM_ARGS - NUM_GLOB + 1)) ] && \
     [ "${INDEX}" -gt 0 ] && \
     [ "${MATHTERM}" = "${FIRSTGLOB}" ] && \
     [ -e "${MATHTERM}" ]
then
GLOB=1
elif [ "${GLOB}" = 0 ]
then

case "${MATHTERM}" in
-0.*|0.*|0) :;;
*[\%\-\(\+\/\ \*]0[1-8]*|0[1-8]*) [ "${BASE}" = 10 -o "${BASE}" = 8 ] || { echo "${FUNCNAME[0]}: only one base supported" >&2 | tee /dev/null >/dev/null; return 1;}; BASE=8;;
*0b*) [ "${BASE}" = 10 -o "${BASE}" = 2 ] || { echo "${FUNCNAME[0]}: only one base supported" >&2 | tee /dev/null >/dev/null; return 1;}; BASE=2;;
*0x*) [ "${BASE}" = 10 -o "${BASE}" = 16 ] || { echo "${FUNCNAME[0]}: only one base supported" >&2 | tee /dev/null >/dev/null; return 1;}; BASE=16;;
esac

MATHTERM="${MATHTERM//0b/}"
MATHTERM="${MATHTERM//0x/}"

local OLD_EXPR=''
case "${MATHTERM}" in
e|l|a|c|s|j|sqrt|length|tan|fac|t|cos|sin|arctan|arccsc|arcsec|arccot|arccos|arcsin|ln|log10|log|log2|lb|lg|sinh|cosh|tanh|sech|csch|coth|arcsinh|arccosh|arctanh|cot)

eval "MATHTERM_NEXT=\${$((INDEX + 2))}"

FUNCTION_CALLS=$((FUNCTION_CALLS + 1))
MATHTERM="${MATHTERM}("
;;
*!)
MATHTERM="${MATHTERM/*!/fac(${MATHTERM/!/})}"
;;
*)
while [ "${FUNCTION_CALLS}" -gt 0 ]
do
FUNCTION_CALLS="$((FUNCTION_CALLS - 1))"
MATHTERM="${MATHTERM})"
done
esac

case "${MATHTERM}" in
'.'[0-9A-F]*[0-9A-F]|[0-9A-F]*[0-9A-F]'.'|[0-9A-F]*[0-9A-F])
EXPR="${EXPR}(${MATHTERM})";;
*)
EXPR="${EXPR}${MATHTERM}"
esac
fi
INDEX=$((INDEX + 1))
done

while [ "${FUNCTION_CALLS}" -gt 0 ]
do
FUNCTION_CALLS="$((FUNCTION_CALLS - 1))"
EXPR="${EXPR})"
done
EXPR=${EXPR//indec/}
EXPR=${EXPR//inbin/}
EXPR=${EXPR//inoct/}
EXPR=${EXPR//inhex/}

[ "${GLOB}" = 1 ] && { echo "${FUNCNAME[0]}: ambiguos globbing error: try performing the calculation in another directory" >&2 | tee /dev/null >/dev/null; return 1; }

# unit conversion
if [ "${3}" = "in" ]
then

case "${2}" in
F|K|C)
case "${2}" in
F) EXPR="5/9*(${1}-32)-273.15";;
K) EXPR="${1}";;
C) EXPR="${1}-273.15";;
esac
case "${4}" in
F) EXPR="(9/5*${EXPR}+32)+273.15";;
K) EXPR="${EXPR}";;
C) EXPR="${EXPR}+273.15";;
*) echo "FUNCNAME[0]}: unsupported conversion from ${2} to ${4}" >&2 | tee /dev/null >/dev/null; return 1
esac
;;

kg|g|lb|oz)
case "${2}" in
kg) EXPR="${1}";;
g) EXPR="${1}*1000";;
lb) EXPR="${1}/2.205";;
oz) EXPR="${1}/35.274";;
esac
case "${4}" in
kg) EXPR="${EXPR}";;
g) EXPR="${EXPR}/1000";;
lb) EXPR="${EXPR}*2.205";;
oz) EXPR="${EXPR}*35.274";;
*) echo "FUNCNAME[0]}: unsupported conversion from ${2} to ${4}" >&2 | tee /dev/null >/dev/null; return 1
esac
;;

cm|m|km|ft|in|yd)
case "${2}" in
mm) EXPR="${1}/1000";; 
cm) EXPR="${1}/100";; 
km) EXPR="${1}*1000";; 
m) EXPR="${1}";; 
ft) EXPR="${1}/3.281";; 
in) EXPR="${1}/39.37";; 
yd) EXPR="${1}/1.094";; 
esac
case "${4}" in
mm) EXPR="${EXPR}*1000";; 
cm) EXPR="${EXPR}*100";; 
km) EXPR="${EXPR}/1000";; 
m) EXPR="${EXPR}";; 
ft) EXPR="${EXPR}*3.281";; 
in) EXPR="${EXPR}*39.37";; 
yd) EXPR="${EXPR}*1.094";; 
*) echo "FUNCNAME[0]}: unsupported conversion from ${2} to ${4}" >&2 | tee /dev/null >/dev/null; return 1
esac
;;

km/h|mph|m/s)
case "${2}" in
km/h) EXPR="${1}/3.6";;
mph) EXPR="${1}/2.237";;
m/s) EXPR="${1}";;
esac
case "${4}" in
km/h) EXPR="${EXPR}*3.6";;
mph) EXPR="${EXPR}*2.237";;
m/s) EXPR="${EXPR}";;
*) echo "FUNCNAME[0]}: unsupported conversion from ${2} to ${4}" >&2 | tee /dev/null >/dev/null; return 1
esac
;;

deg|rad)
case "${2}" in
deg) EXPR="${1}*pi/180";;
rad) EXPR="${1}";;
esac
case "${4}" in
deg) EXPR="${EXPR}/pi*180";;
rad) EXPR="${EXPR}";;
*) echo "FUNCNAME[0]}: unsupported conversion from ${2} to ${4}" >&2 | tee /dev/null >/dev/null; return 1
esac
;;

*)
echo "FUNCNAME[0]}: unsupported conversion from ${2} to ${4}" >&2 | tee /dev/null >/dev/null; return 1
esac
fi
case "${EXPR}" in
*'%'*)
SHABACUS_DECIMALS=0;
case "${EXPR}" in
*[a-z]*|*'.'*|*'/'*)
echo "FUNCNAME[0]}: modulo operator (%): not supported in decimal mode" >&2 | tee /dev/null >/dev/null; return 1
esac
esac

function _shabacus_cmd ()
{
# http://phodd.net/gnu-bc/code/logic.bc
# https://unix.stackexchange.com/questions/44226/bc-doesnt-support-log-and-factorial-calculation
# the variables two,three,four are defined as sums of 1, as these cannot be set in base-10 when operating in base-2 (or base-3, or 4)
COMMAND="scale=${SHABACUS_DECIMALS-${SHABACUS_DEFAULT_DECIMALS}}
obase=${OBASE-${BASE}}
ibase=${BASE}
two=(1+1)
three=(two+1)
four=(three+1)
pi=four*a(1)
define shabacus_c(){auto s;s=scale;scale=0;bitwidth/=1;scale=s;if(bitwidth<0){bitwidth=0};return 0}
define max(x,y){if(x>y)return x;return y}
define min(x,y){if(x<y)return x;return y}
define mod(x,n){auto s,r;s=scale;scale=0;r=x%n;scale=s;return r}
define bitrev(x){auto s,z,w,h;x+=shabacus_c();s=scale;scale=0;x/=1;w=bitwidth;if(x<0){if(w==0){scale=s;return -1};scale=s;return -bitrev(-x-1)-1;};if(w)x%=two^w;z=0;for(.=.;x||w>0;w--){h=x/two;z+=z+x-h-h;x=h};scale=s;return z}
define lsr(x,n){auto s;if(n<0){return shl(x,-n);};s=scale;scale=0;x/=two^(n/1);scale=s;return x}
define lsl(x,n){auto s,w,z;x+=shabacus_c();if(n<0){return shr(x,-n);};s=1;if(x<0){s=-1;x=-x};z=scale;scale=0;x/=1;x*=two^(n/1);if(bitwidth){if(x>=(w=two^bitwidth)){x%=w;};};scale=z;return s*x}
define or(x,y){auto z,t,a,b,c,s,qx,qy;s=scale;scale=0;x/=1;y/=1;if(x<0||y<0){scale=s;return -1-and(-1-x,-1-y)};z=0;t=1;while(x||y){qx=x/four;qy=y/four;if((c=a=x-four*qx)!=(b=y-four*qy))if((c+=b)>three)c=three;z+=t*c;t*=four;x=qx;y=qy;};scale=s;return z}
define xor(x,y){auto n,z,t,a,b,c,s,qx,qy;s=scale;scale=0;n=0;x/=1;y/=1;if(x<0){x=-1-x;n=!n};if(y<0){y=-1-y;n=!n};z=0;t=1;while(x||y){qx=x/four;qy=y/four;c=(a=x-four*qx)+(b=y-four*qy);if(!c%two)c=a+four-b;z+=t*(c%four);t*=four;x=qx;y=qy;};if(n)z=-1-z;scale=s;return z}
define and(x,y){auto n,z,t,a,b,c,s,qx,qy;s=scale;scale=0;n=0;x/=1;y/=1;if(x<0){if(y<0){scale=s;return -1-or(-1-x,-1-y)};x=-1-x;n=1;};if(y<0){t=-1-y;y=x;x=t;n=1};z=0;t=1;while(x||y){qx=x/four;qy=y/four;a=x-four*qx;if(n){a=three-a;};if((c=a)!=(b=y-four*qy)){if((c+=b-three)<0){c=0;};};z+=t*c;t*=four;x=qx;y=qy;};scale=s;return z}
define fac(n){if(n<0){halt;};r=1;for(;n>1;n--){r*=n;};return r}
define tan(x){return s(x)/c(x)}
define cos(x){return c(x)}
define sin(x){return s(x)}
define cot(x){return c(x)/s(x)}
define arctan(x){return a(x)}
define arccsc(x){return a(1/sqrt(x^two-1))}
define arcsec(x){return a(sqrt(x^two-1))}
define arccot(x){return pi/two-a(x)}
define arccos(x){return a(sqrt(1-x^two)/x)}
define arcsin(x){return a(x/sqrt(1-x^two))}
define ln(x){return l(x)}
define log10(x){return l(x)/l(10)}
define log(x){return log10(x)}
define log2(x){return l(x)/l(two)}
define lb(x){return log2(x)}
define lg(x){return log2(x)}
define sinh(x){return (e(x)-e(-x))/two}
define cosh(x){return (e(x)+e(-x))/two}
define tanh(x){return (e(x)-e(-x))/(e(x)+e(-x))}
define sech(x){return two/(e(x)+e(-x))}
define csch(x){return two/(e(x)-e(-x))}
define coth(x){return (e(x)+e(-x))/(e(x)-e(-x))}
define arcsinh(x){return l(x+sqrt(x^two+1))}
define arccosh(x){return l(x+sqrt(x^two-1))}
define arctanh(x){return 1/two*l((1+x)/(1-x))}
define int(x){auto s;s=scale;scale=0;x/=1;scale=s;return x}
define pow(x,y){if(y==int(y)){return (x^y);};return e(y*l(x))}
${EXPR}"
}
_shabacus_cmd
RESULT=$(echo "${COMMAND}"| BC_LINE_LENGTH=0 BC_ENV_ARGS="" bc -l 2>/dev/null)
[ -n "${SHABACUS_TRACE}" ] && echo "shabacus: bc program listing:
${COMMAND}" >&2 | tee /dev/null >/dev/null;
# reduce the numeric error especially with logarithms: eg. log2 2^9999 or log 10^999
local HIGHER_PRECISION_RESULT
case "${RESULT}" in
*.*)
SHABACUS_DECIMALS=$((${SHABACUS_DECIMALS-${SHABACUS_DEFAULT_DECIMALS}} + 4)) _shabacus_cmd
HIGHER_PRECISION_RESULT=$(echo "${COMMAND}"| BC_LINE_LENGTH=0 BC_ENV_ARGS="" bc -l 2>/dev/null)
SHABACUS_DECIMALS=$((${SHABACUS_DECIMALS-${SHABACUS_DEFAULT_DECIMALS}})) _shabacus_cmd
local HIGHER_PRECISION_FRACTION=${HIGHER_PRECISION_RESULT#*.}
EXPR="-(${RESULT})"+${HIGHER_PRECISION_RESULT%.*}.${HIGHER_PRECISION_FRACTION:0:${SHABACUS_DECIMALS-${SHABACUS_DEFAULT_DECIMALS}}}+${EXPR}
_shabacus_cmd
[ -n "${SHABACUS_TRACE}" ] && echo "shabacus: compensating numerical error: ${EXPR}" >&2 | tee /dev/null >/dev/null;
RESULT=$(echo "${COMMAND}"| BC_LINE_LENGTH=0 BC_ENV_ARGS="" bc -l 2>/dev/null)
esac
case "${RESULT}" in
-*.*9)
case "${HIGHER_PRECISION_RESULT:7:1}" in
[5-9])
EXPR="-1/(10^${SHABACUS_DECIMALS-${SHABACUS_DEFAULT_DECIMALS}})+${EXPR}"
_shabacus_cmd
[ -n "${SHABACUS_TRACE}" ] && echo "shabacus: rounding down value: ${EXPR}" >&2 | tee /dev/null >/dev/null;
RESULT=$(echo "${COMMAND}"| BC_LINE_LENGTH=0 BC_ENV_ARGS="" bc -l 2>/dev/null)
esac
;;
*.*9)
case "${HIGHER_PRECISION_RESULT:6:1}" in
[5-9])
EXPR="1/(10^${SHABACUS_DECIMALS-${SHABACUS_DEFAULT_DECIMALS}})+${EXPR}"
_shabacus_cmd
[ -n "${SHABACUS_TRACE}" ] && echo "shabacus: rounding up value: ${EXPR}" >&2 | tee /dev/null >/dev/null;
RESULT=$(echo "${COMMAND}"| BC_LINE_LENGTH=0 BC_ENV_ARGS="" bc -l)
esac
esac
if [ -z "${RESULT}" ] 
then
echo -n "shabacus: "
local ERROR=$(echo "${COMMAND}"| BC_LINE_LENGTH=0 BC_ENV_ARGS="" bc -l 2>&1)
if [ "x${ERROR}" = x ]
then
echo "Runtime error: expression did not result in a value"
else
echo "${ERROR}"
fi
echo "main(): ${EXPR}" >&2 | tee /dev/null >/dev/null
return 1
fi
[ "${SHABACUS_DECIMALS-${SHABACUS_DEFAULT_DECIMALS}}" = ${SHABACUS_DEFAULT_DECIMALS} ] && RESULT="${RESULT/.0000/}"
[ "${RESULT:0:1}" = '-' ] && FORMATTED_RESULT="-"
[ "${OBASE-${BASE}}" = 2 ] && FORMATTED_RESULT="0b"
[ "${OBASE-${BASE}}" = 8 ] && FORMATTED_RESULT="0"
[ "${OBASE-${BASE}}" = 16 ] && FORMATTED_RESULT="0x"
if [ "${RESULT:0:1}" = '-' ] 
then
FORMATTED_RESULT="${FORMATTED_RESULT}${RESULT:1}"
else
FORMATTED_RESULT="${FORMATTED_RESULT}${RESULT}"
fi
echo "${FORMATTED_RESULT}"
}

function _shabacus_command_not_found ()
{
   _SOURCED=1
if [ -n "${ZSH_VERSION}" ]
then
exec zsh -s -c "${@}"
else
# command_not_found_handle() is run in a subshell
# unset so the localized error-string can be printed 
unset -f command_not_found_handle
"${@}"
return 127
fi
}

function command_not_found_handle ()
{
   local ARGS=""
   for ARG in "${@}"
   do
      ARGS="${ARGS}${ARG} "
   done

case "${ARGS}" in
..*|*[a-d]|*[f-h]|*[j-zG-Z])
_shabacus_command_not_found "${@}"
return $?
;;
e" ")
_shabacus e 1
;;
log10" "*|log2" "*|lg" "*|0b[.0-9]*|0o[.0-9]*|0x*[.0-9A-F]*|j" "*|cos" "*|arctan" "*|sin" "*|e" "*|tan" "*|length" "*|sqrt" "*|log10" "*|log" "*|pi*|ln" "*|√[.0-9]*|s'('*|c'('*|a'('*|l'('*|e'('*|j'('*|[.0-9]*|'-'[0-9]*|sqrt"("*|'('*|fac" "*|t" "*|tan" "*|arccsc" "*|arcsec" "*|arccot" "*|arccos" "*|arcsin" "*|lb" "*|sinh" "*|cosh" "*|tanh" "*|sech" "*|csch" "*|coth" "*|arcsinh" "*|arccosh" "*|arctanh" "*|cot" "*)
if [ "${#@}" -gt 1 ]
then
_shabacus "${@}"
else
case ${1} in
[1-9]*)
echo "$(date -d @$(_shabacus $1 in dec)) as UNIX timestamp"
esac
DEC=$(_shabacus ${1} in dec) 
if [ ${DEC} -gt 127 ] &>/dev/null && [ ${DEC} -lt 256 ]
then
echo "$(_shabacus -${DEC} + 127) as int8"
fi
if [ ${DEC} -gt 32767 ] &>/dev/null && [ ${DEC} -lt 65536 ]
then
echo "$(_shabacus -${DEC} + 32767) as int16"
fi
if [ ${DEC} -gt 2147483647 ] &>/dev/null && [ ${DEC} -lt 4294967296 ]
then
echo "$(_shabacus -${DEC} + 2147483647) as int32"
fi
case ${1} in
-*|0[0-9]*) : ;;
*) echo "$(_shabacus $1 in oct) in octal"
esac
case ${1} in
-*|0b*) : ;;
*) echo "$(_shabacus $1 in bin) in binary"
esac
case ${1} in
-*|0x*) : ;;
*) echo "$(_shabacus $1 in hex) in hexadecimal"
esac
case ${1} in
-*|[1-9]*) : ;;
*) echo "$(_shabacus $1 in dec) in decimal"
esac
fi
;;
*)
_shabacus_command_not_found "${@}"
return $?
esac
}

ln ()
{
if [ -e "${1}" ]
then
"$(which ln)" "${@}"
else
case "${*}" in
e) _shabacus "l(e(1))";;
e" "*|-[0-9]*|[0-9]*) _shabacus ln "${@}";;
*) "$(which ln)" "${@}"
esac
fi
}

function command_not_found_handler ()
{
command_not_found_handle "${@}"
}

