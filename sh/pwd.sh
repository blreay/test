#!/bin/bash
echo '$0: '$0
echo "pwd: "`pwd`
echo "scriptPath1: "$(cd `dirname $0`; pwd)
echo "scriptPath2: "$(pwd)
echo "scriptPath3: "$(dirname $(readlink -f $0))
echo BASH_SOURCE=$BASH_SOURCE
echo "\$0=$0"
echo "\$1=$1"
echo "scriptPath4: "$(cd $(dirname ${BASH_SOURCE:-$0});pwd)
