_LINEAR_SRGB_TO_OKLAB()
{
    local DEF_CBRT="define cbrt(x){return e(l(x)/3)}"

    local l=$(\echo "$DEF_CBRT;cbrt(0.4122214708 * $r/255.0 + 0.5363325363 * $g/255.0 + 0.0514459929 * $b/255.0)"|bc -l);
    local m=$(\echo "$DEF_CBRT;cbrt(0.2119034982 * $r/255.0 + 0.6806995451 * $g/255.0 + 0.1073969566 * $b/255.0)"|bc -l);
    local s=$(\echo "$DEF_CBRT;cbrt(0.0883024619 * $r/255.0 + 0.2817188376 * $g/255.0 + 0.6299787005 * $b/255.0)"|bc -l);

    L=$(\echo "0.2104542553*$l + 0.7936177850*$m - 0.0040720468*$s"|bc -l)
    a=$(\echo "1.9779984951*$l - 2.4285922050*$m + 0.4505937099*$s"|bc -l)
    b=$(\echo "0.0259040371*$l + 0.7827717662*$m - 0.8086757660*$s"|bc -l)
}

_OKLAB_TO_LINEAR_SRGB() 
{
    local l=$(\echo "($L + 0.3963377774 * $a + 0.2158037573 * $b)^3"|bc -l)
    local m=$(\echo "($L - 0.1055613458 * $a - 0.0638541728 * $b)^3"|bc -l)
    local s=$(\echo "($L - 0.0894841775 * $a - 1.2914855480 * $b)^3"|bc -l)

    R=$(\echo "255.0 * ( 4.0767416621 * $l - 3.3077115913 * $m + 0.2309699292 * $s)"|bc -l)
    G=$(\echo "255.0 * (-1.2684380046 * $l + 2.6097574011 * $m - 0.3413193965 * $s)"|bc -l)
    B=$(\echo "255.0 * (-0.0041960863 * $l - 0.7034186147 * $m + 1.7076147010 * $s)"|bc -l)
}

# 0 ffaa33  10 ffbbcc
main ()
{
local ARG
for ARG in "$@"
do
shift 2
done
}
main "$@"
true <<EOF
int main(int argc, char *argv[])
{
using namespace std;
RGB rgbA; 
RGB rgbB; 
rgbA.r = atoi(argv[1])/255.0f;
rgbA.g = atoi(argv[2])/255.0f;
rgbA.b = atoi(argv[3])/255.0f;

rgbB.r = atoi(argv[4])/255.0f;
rgbB.g = atoi(argv[5])/255.0f;
rgbB.b = atoi(argv[6])/255.0f;

auto labA = linear_srgb_to_oklab(rgbA); 
auto labB = linear_srgb_to_oklab(rgbB); 
const int kLutSize = 256;
float deltaL;
float deltaA;
float deltaB;


deltaL = abs(labA.L - labB.L)/ kLutSize;
deltaA = abs(labA.a - labB.a)/ kLutSize;
deltaB = abs(labA.b - labB.b)/ kLutSize;

if (labA.L > labB.L)
{
deltaL *= -1.0f;
}

if (labA.a > labB.a)
{
deltaA *= -1.0f;
}

if (labA.b > labB.b)
{
deltaB *= -1.0f;
}


for (int i=0; i < kLutSize; i++) {

Lab dstLab;
dstLab.L = labA.L + deltaL * i;
dstLab.a = labA.a + deltaA * i;
dstLab.b = labA.b + deltaB * i;
RGB dst = oklab_to_linear_srgb(dstLab);
int r = min(255.0f,roundf(dst.r * 255.0f));
int g = min(255.0f,roundf(dst.g * 255.0f));
int b = min(255.0f,roundf(dst.b * 255.0f));
printf("_PROMPT_LUT[%d]=\"%d;%d;%d\"\n", i, r, g, b);
}
}
EOF

# gradient [start_color index] 
_main ()
{

local L
local a
local b
local SRC_L=""
local SRC_a=""
local SRC_b=""
local DST_L=""
local DST_a=""
local DST_b=""
local INDEX=0
while [ -n "${1}" ]
do
local STEPS=${1}
[ "$STEPS" -lt 1 ] && STEPS=1
if [ "$STEPS" -gt 100 ]
then
echo "STEPS must be in range 1-100"
exit 42
fi
local COLOR=$2
shift 2
local R="$((0x${COLOR:0:2}))"
local G="$((0x${COLOR:2:2}))"
local B="$((0x${COLOR:4:2}))"
_LINEAR_SRGB_TO_OKLAB
DST_L=$L
DST_a=$a
DST_b=$b
[ -z "${SRC_L}" ] && SRC_L=${DST_L}
[ -z "${SRC_a}" ] && SRC_a=${DST_a}
[ -z "${SRC_b}" ] && SRC_b=${DST_b}
DELTA_L=$(echo "($DST_L - $SRC_L)/$STEPS | bc -l")
DELTA_a=$(echo "($DST_a - $SRC_a)/$STEPS | bc -l")
DELTA_b=$(echo "($DST_b - $SRC_b)/$STEPS | bc -l")

# 0...50...100
# TODO: multiply with 2
DST_INDEX=$((INDEX + STEPS))

local I=0
while [ $I -lt $STEPS ]
do

DST_L=$((SRC_L + DELTA_L * $I))
DST_a=$((SRC_a + DELTA_a * $I))
DST_b=$((SRC_b + DELTA_b * $I))
_OKLAB_TO_LINEAR_SRGB

DEF_ROUND="define int(x){auto s;s=scale;scale=0;x/=1;scale=s;return x};define round(x){return int(x+1/2)}"
R=$(echo "$DEF_ROUND;round($r * 255)"|bc -l)
G=$(echo "$DEF_ROUND;round($g * 255)"|bc -l)
B=$(echo "$DEF_ROUND;round($b * 255)"|bc -l)
echo _PROMPT_LUT[$INDEX]="$R;$G;$B"
let INDEX++
#echo "R=${R}, G=${G}, B=${B}"
let INDEX++
done

SRC_L=${DST_L}
SRC_a=${DST_a}
SRC_b=${DST_b}
# TODO: draw the rest of the f-ing owl
done
}


