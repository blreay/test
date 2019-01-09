#!/usr/bin/ksh

#for i in (1 2 3 2 10); do

#for (( i=0; i++; i<100 )); do
#	echo $i\n
#done

min=1
max=100
while [ $min -le $max ]; do
       echo $min
       min=`expr $min + 1`
		echo $min
		sleep 1
done

