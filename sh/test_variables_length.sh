#!/bin/pdksh

set -vx
str1="999"
function test2 {
typeset i
for i in $(seq 9999);do
	str2=$str2,$i
done
}

####################
typset str2=
test2

set > test_variables_result_2
