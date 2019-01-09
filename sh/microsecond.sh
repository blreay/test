set -vx
START=`date +%s%N`;
sleep 3;
END=`date +%s%N`;
echo `expr \( $END - $START \) / 1000000`
