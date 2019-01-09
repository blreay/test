#!/bin/bash

b=1;
l=100;
e=$(( b + l ))
echo $e

typeset i=$b
while [[ $i -le $e ]]; do
	echo "$i" | ./JCLExecutor -c exec -j $(printf "%08d" $i) -p $(( 310 + $i)); 
	(( i = i + 1 ))
done  2>&1 |grep je_enc_key

b=888888
l=100
e=$(( b + l ))
i=$b
while [[ $i -le $e ]]; do
	echo "$i" | ./JCLExecutor -c exec -j $(printf "%08d" $i) -p $(( 310 + $i - $b)); 
	(( i = i + 1 ))
done  2>&1 |grep je_enc_key
