#!/bin/pdksh

echo "start"
trap
trap 'echo trap error $?' ERR
trap 'echo trap exit $?'  EXIT
trap "echo trap other signal $?" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64
echo "try to execute export"
trap
#export TIMESTAMP=¡®2 9:40:30.123¡¯
. ./aaa.sh
echo "ok"
sleep 1000
