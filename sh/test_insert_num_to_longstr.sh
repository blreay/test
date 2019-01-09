#!/bin/pdksh

function insert_one_GN {
	typeset strListName=$1
	typeset insertVal=$2
	typeset tmplist=
	typeset tmplistOut=
	eval tmplist=\$$strListName
	tmplistOut=$(echo $tmplist|awk -F, -v invalue=$insertVal '{
		for (i=1;i<=NF;i++) {
			if (strtonum($i) > strtonum(invalue) && flag!=1) {
				printf(",%s",invalue);
				flag=1;
			}
			printf(",%s",$i);
		}
		if (flag != 1) printf(",%s",invalue);
	}')
	eval $strListName=\$\{tmplistOut##,\}
}

function remove_one_GN {
        typeset strListName=$1
        typeset insertVal=$2
        typeset tmplist=
        typeset tmplistOut=
        eval tmplist=\$$strListName
        tmplistOut=$(echo $tmplist|awk -F, -v invalue=$insertVal '{
                for (i=1;i<=NF;i++) {
                        if (strtonum($i) != strtonum(invalue)) {
                        	printf(",%s",$i);
                        }
                }
        }')
        eval $strListName=\$\{tmplistOut##,\}
}

list1=1,3,4,7,10
echo $list1
insert_one_GN "list1" 5
echo $list1
insert_one_GN "list1" 9
echo $list1
insert_one_GN "list1" 0
echo $list1
insert_one_GN "list1" 11
echo $list1
remove_one_GN "list1" 5
echo $list1
remove_one_GN "list1" 0
echo $list1
remove_one_GN "list1" 11
echo $list1
list1=
echo $list1
insert_one_GN "list1" 5
echo $list1
insert_one_GN "list1" 9
echo $list1
insert_one_GN "list1" 0
echo $list1
insert_one_GN "list1" 11
echo $list1
remove_one_GN "list1" 5
echo $list1
remove_one_GN "list1" 0
echo $list1
remove_one_GN "list1" 11
echo $list1
