#!/bin/sh
function ExitFunc {
        echo "Call ExitFunc"
}
trap 'ExitFunc' EXIT

function func2 {
echo "In here"
function ExitFunc2 {
        echo "Call ExitFunc2"
}
trap 'ExitFunc2' EXIT
return 0
}

#. ./testtrap2
func2
echo "result " $?

exit 0

