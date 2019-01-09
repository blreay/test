#!/bin/pdksh

#set -vx
function test2 {
typeset i
for i in $(seq 9999);do
	str2=$str2,$i
done
}

####################
typeset mt_ScriptName=$1
typeset mt_TAB=" 	"
cat ${mt_ScriptName} | egrep "^[${mt_TAB}]*(m_SetJobAfter|m_JobBegin)" | awk -v flag=0 '
	/m_JobBegin/{
		if (0 == flag) {
			flag=1
		}else{
			exit 0
		}
	}
	/m_SetJobAfter/{
		if (1 == flag) {
			print "zzy1"
			print $0
		}
	}
' | egrep "^[${mt_TAB}]*m_SetJobAfter[${mt_TAB}]+[^${mt_TAB}]*[${mt_TAB}]+[0-9]{8}" 2>/dev/null | awk '{print $3}'
