gmake -f Makefile.AIX

cd $MT_ROOT/SOURCE
rm -f ./runb.* ../COBOL_MF/runb ../COBOL_MF/runcso.gnt 

#./make.sh ../DB_ORACLE/runb RUNB_ADD_OPT="-L/nfs/users/zhaozhan/test/c/pro_c -luser_dyn"
if [[ $? -ne 0 ]]; then
exit 2
fi

cd ..
./make.sh RUNB_ADD_OPT="-L/nfs/users/zhaozhan/test/c/pro_c -luser_dyn"
if [[ $? -ne 0 ]]; then
exit 3
fi
cd SOURCE

#./make.sh ../COBOL_MF/runbatch.gnt
if [[ $? -ne 0 ]]; then
exit 3
fi

#./make.sh ../COBOL_MF/runcso.gnt
if [[ $? -ne 0 ]]; then
exit 4
fi
#./make.sh bsoruncso.so
if [[ $? -ne 0 ]]; then
exit 5
fi

#./make.sh ../DB_ORACLE/mw_dblink.gnt
if [[ $? -ne 0 ]]; then
exit 3
fi

echo "============================================="
set -vx
#runb $@ aaa1234
export COBPATH=$COBPATH:/nfs/users/zhaozhan/test/c/so:/nfs/users/zhaozhan/test/c/pro_c:/nfs/users/zhaozhan/test/cobol/so
EJR -v /nfs/users/zhaozhan/test/c/so/TESTJOB.ksh
