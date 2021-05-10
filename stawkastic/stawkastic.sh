#!/bin/bash
function _STAWKASTIC_MAX
{
	awk '{ if( MAX == "" || $1 > MAX ) { MAX=$1+0 } }END{ print MAX }'
}
function _STAWKASTIC_MIN
{
    awk '{ if( MIN == "" || $1 < MIN ) { MIN=$1+0 } }END{ print MIN }'
}
function _STAWKASTIC_POPULATION_STDDEV
{
    awk '{x+=$0;y+=$0^2}END{print sqrt(y/NR-(x/NR)^2)}'
}
function _STAWKASTIC_SAMPLE_STDDEV
{
    awk '{sum+=$0;a[NR]=$0}END{for(i in a)y+=(a[i]-(sum/NR))^2;print sqrt(y/(NR-1))}'
}
function _STAWKASTIC_AVG ()
{
    awk '{x+=$0}END{print x/NR}'
}
function _STAWKASTIC_MEDIAN ()
{
    sort -n|awk '{a[NR]=$0}END{print(NR%2==1)?a[int(NR/2)+1]:(a[NR/2]+a[NR/2+1])/2}'
}
function _STAWKASTIC_SUM ()
{
    awk '{for (i = 1; i <= NF; i++) sum+=$i} END {print sum}' 
}
alias max=_STAWKASTIC_MAX
alias min=_STAWKASTIC_MIN
alias popstddev=_STAWKASTIC_POPULATION_STDDEV
alias stddev=_STAWKASTIC_SAMPLE_STDDEV
alias mean=_STAWKASTIC_AVG
alias avg=_STAWKASTIC_AVG
alias median=_STAWKASTIC_MEDIAN
alias sum=_STAWKASTIC_SUM
