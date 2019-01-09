#!/bin/bash

PJDIR=$PWD

false && while true; do 
	echo "--------------------------------------------"
	./ma1 
	./cs.sh
	sleep ${1:-2}
 done

typeset NODEPID=

##node app.js &
./startup.sh &
NODEPID=$!

while true; do
  #inotifywait -e modify $PWD/jessrv/jobadmsrv.c
  #inotifywait -e modify -r $PJDIR/jessrv $PJDIR/lib $PJDIR/include $PJDIR/jescmd
  #inotifywait -e modify $PJDIR/jessrv $PJDIR/lib $PJDIR/include $PJDIR/jescmd
  #inotifywait -e modify -r -c $PJDIR --exclude cscope
  inotifywait -e modify -r  --exclude '(cscope.out|tags|test.sh)'  $PWD
    echo "========================================="
  # Do something *after* a write occurs, e.g. copy the file
  echo "changed $(date)"
	[[ -n "$NODEPID" ]] && kill -9 $NODEPID
	#node app.js &
	./startup.sh &
    NODEPID=$!
    echo "========================================="
done
