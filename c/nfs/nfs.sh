#!/bin/ksh
for i in `seq $1`
do
  ./testNFS /nfs/users/zhaozhan/acc/AccTest $2&
done
