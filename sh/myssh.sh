#!/bin/ksh

function show_usage {
	echo "Usage: ${0##*/} user@hostname"
}

#set -vh
#########################################################################
## Check Paramter ##
while getopts :d:g:m: name; do
	case $name in
	  d)  use_db_direct=1; export g_MaxGen=$OPTARG;;
	  g)  gflag=1; maxgen=$OPTARG;;
	  m)  mflag=1; gennumlist=$OPTARG ;;
	  ?)  show_usage; echo aaa; exit 1 ;;
	esac
done

if [[ -z $MYPWD ]]; then
	echo "MYPWD is not set"
	exit 1
fi

set -vx
cmd="${@}"
#remote-exec.sh """$cmd""" $MYPWD
#./ssh2.sh """ssh $cmd""" $MYPWD
./ssh2.sh """ssh $cmd""" "IGNORE"
d
