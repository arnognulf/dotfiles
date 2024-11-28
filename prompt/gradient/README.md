Gradient LUT creator script
===========================

Usage: gradient [<INDEX> <HEX_COLOR>] [<INDEX> <HEX_COLOR>]...


INDEX       must be increasing integers and in the range 0...100
HEX_COLOR   is a hexadecimal RRGGBB color 




Eg. design your gradient at https://cssgradient.io/ and transfer these to gradient script, https://uigradients.com/ is also a great resource


Examples
--------
```
gradient  0 b1e874  100 00d4ff
gradient  0 020024  35 1818a1  100 00d4ff

# This script is slow due to using OKLab colorspace with BC,
# store colors in a script to make it load faster at startup
./gradient  0 b1e874  100 ff00d3 >syntwave.sh
```

