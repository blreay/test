#!/bin/pdksh

set -vx
str1="aaa"
counter=0
function test1 {
typeset i
typeset i1
typeset i2
typeset i3
typeset i4
typeset i5
typeset i6
for i in $(seq 100);do
	#str1=${str1}::MT_GDG_MaxGen__testarea_zhaozhan_work_batchrt_mf_data_ORACLE_DEMO_GDGF_$i::
	typeset str1
	str1=bbb
	i1=${counter}
	i2=${counter}
	i3=${counter}
	i4=${counter}
	i5=${counter}
	i6=${counter}
	eval  MT_GDG_MaxGen__testarea_zhaozhan_work_batchrt_mf_data_ORACLE_DEMO_GDGF_${counter}=$str1
	eval  MM_GDG_MaxGen__testarea_zhaozhan_work_batchrt_mf_data_ORACLE_DEMO_GDGF_${counter}=$str1
	(( counter=counter+1 ))
	set > tmp/test_variables_result_${counter}
	test1
done
}

test1

#unset MT_GDG_MaxGen__testarea_zhaozhan_work_batchrt_mf_data_ORACLE_DEMO_GDGF_90
#unset MT_GDG_MaxGen__testarea_zhaozhan_work_batchrt_mf_data_ORACLE_DEMO_GDGF_91
#unset MT_GDG_MaxGen__testarea_zhaozhan_work_batchrt_mf_data_ORACLE_DEMO_GDGF_92

set > test_variables_result_2
