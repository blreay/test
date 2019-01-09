UTINAME=testproc
UTINAME_LD=testproc_dynamic
SHRLIBNAME=libuser_main.so
DYNLIBNAME=libuser_dyn.so
DYNLIBNAME_TOSO=libuser_linkedtoso.so

CGFLAG=-brtl -D_LARGE_FILES -D_TMNOLICENSE -D_THREAD_SAFE_ERRNO -brtl -qlanglvl=extended -D_AIX_LARGE_MSGQUEUES -D_TMAIX4 -q64 -D_LARGE_FILES -D__XCOFF32__ -D__XCOFF64__ -D_GPTHREADS_RFUNCS0 -D_THREAD_SAFE -DIOP_THREAD_SAFE -DOBB_ANSI_PROTO -DORB_ANSI_PROTO -Daix -DIOP_THREAD_SAFE  -O -DXPATH -DNOWHAT    -D_TMXPG3INTL -D_TMXDRLIB -D_GPTHREADS -DOPEN_LDAP -DCERTC_SW_PLATFORM=9 -DCERTC_HW_PLATFORM=11

.SUFFIXES: .cbl .cob .c .o .gnt .sqb .bnd .a .pc

all: clean  ${DYNLIBNAME} ${DYNLIBNAME_TOSO} ${UTINAME} ${UTINAME_LD}
	@echo "build DONE"	

${SHRLIBNAME}: user_main.c
	gcc -g $< -fPIC -shared -o $@ -lstdc++  -I $(ORACLE_HOME)/precomp/public -L$(ORACLE_HOME)/lib -lclntsh

${DYNLIBNAME}: user_dyn.c
	gcc -g $< -fPIC -shared -o $@ -lstdc++  -I $(ORACLE_HOME)/precomp/public -L$(ORACLE_HOME)/lib -lclntsh

${DYNLIBNAME_TOSO}: user_linkedtoso.c
	gcc -g $< -fPIC -shared -o $@ -lstdc++  -I $(ORACLE_HOME)/precomp/public -L$(ORACLE_HOME)/lib -lclntsh

.pc.c:
	proc iname=$< oname=$@

main.c1: main.pc1
	proc main.pc

${UTINAME}: main.c ${SHRLIBNAME}
	gcc -o $@ $< -I $(ORACLE_HOME)/precomp/public -L $(ORACLE_HOME)/lib -lclntsh  -L$(PWD) -luser_main

${UTINAME_LD}: main_dynamic.c ${SHRLIBNAME}
	gcc -o $@ $< -I $(ORACLE_HOME)/precomp/public -L $(ORACLE_HOME)/lib -lclntsh

clean:
	rm -rf testproc main.c  main.lis user_main.c libuser_main.so *.o

run: all
	@echo "Begin to run ${UTINAME}"
	@echo "====================================="	
	@./${UTINAME}
	@echo "====================================="	
	
	#mv ${SHRLIBNAME} 1.so

	@echo "Begin to run ${UTINAME_LD}"
	@echo "====================================="	
	@./${UTINAME_LD}
	@echo "====================================="	
	#mv 1.so ${SHRLIBNAME}
