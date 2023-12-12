#include <algorithm>
#include <cstdio>
#include <cmath>

struct Lab {float L; float a; float b;};
struct RGB {float r; float g; float b;};

Lab linear_srgb_to_oklab(RGB c) 
{
    float l = 0.4122214708f * c.r + 0.5363325363f * c.g + 0.0514459929f * c.b;
    float m = 0.2119034982f * c.r + 0.6806995451f * c.g + 0.1073969566f * c.b;
    float s = 0.0883024619f * c.r + 0.2817188376f * c.g + 0.6299787005f * c.b;

    float l_ = cbrtf(l);
    float m_ = cbrtf(m);
    float s_ = cbrtf(s);

    return {
        0.2104542553f*l_ + 0.7936177850f*m_ - 0.0040720468f*s_,
        1.9779984951f*l_ - 2.4285922050f*m_ + 0.4505937099f*s_,
        0.0259040371f*l_ + 0.7827717662f*m_ - 0.8086757660f*s_,
    };
}

RGB oklab_to_linear_srgb(Lab c) 
{
    float l_ = c.L + 0.3963377774f * c.a + 0.2158037573f * c.b;
    float m_ = c.L - 0.1055613458f * c.a - 0.0638541728f * c.b;
    float s_ = c.L - 0.0894841775f * c.a - 1.2914855480f * c.b;

    float l = l_*l_*l_;
    float m = m_*m_*m_;
    float s = s_*s_*s_;

    return {
        +4.0767416621f * l - 3.3077115913f * m + 0.2309699292f * s,
        -1.2684380046f * l + 2.6097574011f * m - 0.3413193965f * s,
        -0.0041960863f * l - 0.7034186147f * m + 1.7076147010f * s,
    };
}
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

