#!/bin/bash

# this file is sourced from my regular system installed .bashrc on osx and linux

# Please don't spawn a Jupiter-sized python interpreter process on me when I misspel 'ls'
unset -f command_not_found_handle 1>/dev/null 2>/dev/null

# add stuff to path
export PATH=${HOME}/Unix/bin:/var/lib/gems/1.8/bin:$PATH:${HOME}/Unix/share/sunstudio12.1/bin

# various aliases
alias vim='vim -p'

# handy for running old school vi
TERMCAP="vt102|$TERM|dec vt102:"'\
        :do=^J:co#80:li#24:cl=50\E[;H\E[2J:\
        :le=^H:bs:cm=5\E[%i%d;%dH:nd=2\E[C:up=2\E[A:\
        :ce=3\E[K:cd=50\E[J:so=2\E[7m:se=2\E[m:us=2\E[4m:ue=2\E[m:\
        :md=2\E[1m:mr=2\E[7m:mb=2\E[5m:me=2\E[m:is=\E[1;24r\E[24;1H:\
        :rs=\E>\E[?3l\E[?4l\E[?5l\E[?7h\E[?8h:ks=\E[?1h\E=:ke=\E[?1l\E>:\
        :ku=\EOA:kd=\EOB:kr=\EOC:kl=\EOD:kb=^H:\
        :ho=\E[H:k1=\EOP:k2=\EOQ:k3=\EOR:k4=\EOS:pt:sr=5\EM:vt#3:\
        :sc=\E7:rc=\E8:cs=\E[%i%d;%dr:vs=\E[?7l:ve=\E[?7h:\
        :mi:al=\E[L:dc=\E[P:dl=\E[M:ei=\E[4l:im=\E[4h:'
export TERMCAP

# paint it black
export GREP_COLORS="ms=01:mc=01:sl=:cx=:fn=01:ln=01:bn=01:se=01"
export LS_COLORS='rs=0:di=01:ln=01:pi=01:so=01:do=01:bd=01:cd=01:or=01:su=01:sg=01:ca=01:tw=01:ow=01:st=01:ex=01:'
#export LS_COLORS='rs=0:di=01:ln=01:hl=01:pi=01:so=01:do=01:bd=01:cd=01:or=01:su=01:sg=01:ca=01:tw=01:ow=01:st=01:ex=01:'

# teh linux superpatch
if [ -t 0 -a "$OSTYPE" = linux-gnu ] ; then 
    mkdir -m 0700 /dev/cgroup/cpu/user/$$
    echo $$ > /dev/cgroup/cpu/user/$$/tasks
fi
export EDITOR=vim
