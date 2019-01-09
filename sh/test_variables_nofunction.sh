#!/bin/pdksh

set -vx
str1="aaa"

for i in $(seq 100000);do
	#str1=${str1}::MT_GDG_MaxGen__testarea_zhaozhan_work_batchrt_mf_data_ORACLE_DEMO_GDGF_$i::
	eval  MT_GDG_MaxGen__testarea_zhaozhan_work_batchrt_mf_data_ORACLE_DEMO_GDGF_$i=$str1
	set > test_variables_result
done

#unset MT_GDG_MaxGen__testarea_zhaozhan_work_batchrt_mf_data_ORACLE_DEMO_GDGF_90
#unset MT_GDG_MaxGen__testarea_zhaozhan_work_batchrt_mf_data_ORACLE_DEMO_GDGF_91
#unset MT_GDG_MaxGen__testarea_zhaozhan_work_batchrt_mf_data_ORACLE_DEMO_GDGF_92

set > test_variables_result_2
