#!/bin/mksh_r51

function mif_ExitTrap {
    if [[ "$1" != 0 ]]; then
        echo "Trap EXIT $1"
    fi
}

trap 'mif_ExitTrap $?' EXIT
#trap 'echo error================== $?' ERR
#asfa

#[[ 8 -eq 9 ]

mt_Expression="[[ "9" -le 8 ]]"
echo $mt_Expression

if eval $mt_Expression; then
    echo "End -if then."
else
    echo "End -if else."
fi

echo "End..."
exit 1
