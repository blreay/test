#!/bin/pdksh

set -A ary1 "aa" "bb" "cc"
echo ${ary1[*]}
echo ${ary1[2]}
echo ${ary1[1]}
echo ${ary1[0]}
