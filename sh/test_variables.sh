#!/bin/pdksh

set -vx
str1="aaa"
function test2 {
typeset i
for i in $(seq 100);do
	#str1=${str1}::MT_GDG_MaxGen__testarea_zhaozhan_work_batchrt_mf_data_ORACLE_DEMO_GDGF_$i::
	eval  MT_GDG_MaxGen__testarea_zhaozhan_work_batchrt_mf_data_ORACLE_DEMO_GDGF_$i=$str1
	set > test_variables_result
done
}

test2
#unset MT_GDG_MaxGen__testarea_zhaozhan_work_batchrt_mf_data_ORACLE_DEMO_GDGF_90
#unset MT_GDG_MaxGen__testarea_zhaozhan_work_batchrt_mf_data_ORACLE_DEMO_GDGF_91
#unset MT_GDG_MaxGen__testarea_zhaozhan_work_batchrt_mf_data_ORACLE_DEMO_GDGF_92

set > test_variables_result_2
