#!/bin/ksh

function getins_mf_nodb {
    while IFS="=" read name value; do
        echo name=$name
        echo value=$value
    done <<-EOF
    `env | egrep "mf_mfsort_nodb_[0-9]+"`
EOF
}
export mf_mfsort_nodb_1="a;b;c"
export mf_mfsort_nodb_2="aa;bb;cc"
export mf_mfsort_nodb_20="aa;bb;cc"
export mf_mfsort_nodb_a="aa;bb;cc"

getins_mf_nodb
