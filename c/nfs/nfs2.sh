#!/bin/ksh
for i in `seq $1`
do
  ./testNFS /local/home/zhaozhan/mnt/AccTest $2&
done
