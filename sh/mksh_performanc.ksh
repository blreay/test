#!/bin/mksh

cnt=1
a="b"
LOOP=300000

while [[ $cnt -lt $LOOP ]];
#while [[ ${#a}  -lt $LOOP ]];
do
#       echo "$cnt / $LOOP" >>mksh.log
		alias ls="ls -l"
        (( cnt = cnt + 1 ))
		#a="${a}b"
		#echo $a
done 
