SH-ABACUS
=========

Turn Bash/Zsh into a calculator by intercepting command_not_found_handle(r).   
Uses bc(1) syntax with a couple of replacement macros.   
Does not work with the version of bash shipped in OSX.

# Usage

    $ . ./shabacus.sh
    $ 1 + 2 + 3
    6
    # the glob wildcard is collapsed into a multiplication operator
    # "Works Almost Every Time(tm)"
    $ 16 * 12 
    192
    $ 2982 / 3
    994
    # using the (integer) modulo operator does not need extra setup
    # but cannot be combined with decimal values/variables/math functions
    $ 2982 % 13
    5
    $ 2 ^ 4
    16
    # hex can be used, but must be UPPERCASE
    $ 0x3C + 0xF3
    0x12F
    $ 0xBAADF00D in dec
    3131961357
    $ 0b111 + 0b11
    0b1010
    $ 5 lb in g
    2.2675
    # Paranthesises will be added when there are no spaces around terms 
    $ 3+3 / 3
    2
    $ sin pi/2
    1
    $ MEANING_OF_LIFE=$(8.4 * 5)
    $ echo ${MEANING_OF_LIFE}
    42
    $ SHABACUS_TRACE=1 1+2
    scale=4;obase=10;ibase=10;pi=4*a(1);(1+2)
    3
    $ SHABACUS_DECIMALS=64 pi
    3.1415926535897932384626433832795028841971693993751058209749445923
    $ lg 64
    6
    $ 100!
    93326215443944152681699238856266700490715968264381621468592963895217599993229915608941463976156518286253697920827223758251185210916864000000000000000000000000
    $ 1 / 3 * 3
    1