#!/bin/pdksh

#set -vx
function test2 {
typeset i
for i in $(seq 9999);do
	str2=$str2,$i
done
}

####################
typeset str2=
test2
str2=${str2##,}
echo $str2|awk -F, -v pos=9998 '{print $pos}'
set > test_variables_result_2
