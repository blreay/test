PJROOT=/nfs/users/zhaozhan/test
DIR_C_SO=$(PJROOT)/c/so
DIR_C_PROC=$(PJROOT)/c/pro_c
DIR_COBOL_SO=$(PJROOT)/cobol/so

SHRLIBNAME=libuser_main.so
DYNLIBNAME=${DIR_C_PROC}/libuser_dyn.so
DYNLIBNAME_TOSO=${DIR_C_PROC}libuser_linkedtoso.so

MFCINC = -I$(COBDIR)/include
MFCLIB = -L$(COBDIR)/lib
#MFCLIB += -lcobrts64 -lcobcrtn64 -lcobmisc64 -lcobscreen64
#MFCLIB += -lcobrts64 

### COPY from Makefile of BatchRT ###
STRIP = strip
RM = rm -f
RMDIR = rmdir
CP = cp -p
MV = mv
CHMOD_EXECUTABLE = chmod -R a+rx
CHMOD_NON_EXECUTABLE = chmod -R a-x
PERLCC = perlcc -B
TOUCH = touch
DB2 = db2
ECHO = echo
ECHO_CMD = $(ECHO)
ECHO_END = \c
OUTPUTDIR=output.$$(uname)

COBOL_USED_MF=../COBOL_MF
COBOL_USED_IT=../COBOL_IT
COBOL_USED_NONE=../COBOL_NONE
DB_USED_ORACLE=../DB_ORACLE
DB_USED_DB2LUW=$(PWD)
SORT_USED_MF=../SORT_MicroFocus
SORT_USED_SYNCSORT=../SORT_SyncSort
GENERATION_USED_FILE=../GENERATION_FILE

VPATH=.:${PLATFORM_FIXED}:${COBOL_USED}:${DB2DIR}/include/cobol_mf
COBCPY=$(VPATH)

SETENV=export COBPATH=$$COBPATH:${PJROOT}/c/so:${PJROOT}/c/pro_c:${PJROOT}/cobol/so; \
	export LD_LIBRARY_PATH=${PJROOT}/c/pro_c:${PJROOT}/c/so:$$LD_LIBRARY_PATH:$$PWD 
SETENV_RUNONLY_ES51=export COBPATH=$$COBPATH:${DIR_COBOL_SO}/$(OUTPUTDIR).mf5.1; \
	export LD_LIBRARY_PATH=$$LD_LIBRARY_PATH:${DIR_COBOL_SO}/$(OUTPUTDIR).mf5.1
SETENV_RUNONLY_VC21=export COBPATH=$$COBPATH:${DIR_COBOL_SO}/$(OUTPUTDIR).visualcobol; \
	export LD_LIBRARY_PATH=$$LD_LIBRARY_PATH:${DIR_COBOL_SO}/$(OUTPUTDIR).visualcobol
ACT_RECOVER_RUNB=cp $(MT_ROOT)/COBOL_MF/runb.orig $(MT_ROOT)/COBOL_MF/runb

ALLJOB=job_so_none.ksh \
	job_gnt_cso.ksh \
	job_gnt_cso_func.ksh \
	job_bso_cso.ksh \
	job_cso_bso.ksh \
	job_cso_bso.ksh \
	job_bso_none_db.ksh 

all: clean main main_use_objectfile bsoruncso.so csorunbso.so runcso.so ${DIR_COBOL_SO}/cblopedb.so ${DIR_COBOL_SO}/libcblopedb.so ${DIR_COBOL_SO}/runcsofunc.gnt ${DIR_C_SO}/PGMTEST.so ${DIR_COBOL_SO}/runcso.gnt
	if [ -d ${DIR_COBOL_SO}/$(OUTPUTDIR) ]; then rm -rf ${DIR_COBOL_SO}/$(OUTPUTDIR); fi
	mkdir ${DIR_COBOL_SO}/$(OUTPUTDIR)
	cp ${DIR_C_SO}/*.so ${DIR_COBOL_SO}/*.so ${DIR_COBOL_SO}/*.gnt ${DIR_C_PROC}/*.so ${DIR_COBOL_SO}/$(OUTPUTDIR)
	echo "all done"

libuser_dyn.so: ${DYNLIBNAME}

${DYNLIBNAME}: ${DIR_C_PROC}/user_dyn.pc
	case "${MT_DB}" in \
		DB_ORACLE) proc iname=$< oname=${DIR_C_PROC}/user_dyn.c; \
			cob -Z "${DIR_C_PROC}/user_dyn.c" -CC -I${ORACLE_HOME}/precomp/public -L${ORACLE_HOME}/lib -o $@ -lclntsh;; \
		DB_DB2LUW) $(DB2) connect to ${MT_DB_LOGIN}; \
			$(DB2) prep $< ACTION REPLACE BINDFILE DEFERRED_PREPARE NO DEGREE 1 DISCONNECT EXPLICIT DYNAMICRULES RUN EXPLAIN NO ISOLATION CS SQLRULES DB2 VALIDATE RUN VERSION REF CALL_RESOLUTION DEFERRED DATETIME ISO NOREOPT VARS TARGET C; \
			$(DB2) bind ${DIR_C_PROC}/user_dyn.bnd; \
			$(DB2) connect reset; \
			$(DB2) terminate; \
			cob -Z "${DIR_C_PROC}/user_dyn.c" -CC -I${DB2DIR}/include -L${DB2DIR}/lib64 -ldb2 -o $@;; \
		*) echo "DB type ${MT_DB} unknown"; exit 1;; \
	esac

	#gcc -g $< -fPIC -shared -o $@ -lstdc++  -I $(ORACLE_HOME)/precomp/public -L$(ORACLE_HOME)/lib -lclntsh
	#gcc -maix64 -I$(ORACLE_HOME)/precomp/public -L$(ORACLE_HOME)/lib ${DIR_C_PROC}/user_dyn.c -o $@ -lclntsh -shared


main: bsoruncso.so ${DYNLIBNAME}
	#gcc -ldl $(MFCINC) $(MFCLIB) -L${PWD} -lbsoruncso -L${PJROOT}/c/pro_c -luser_dyn main.c -o $@ 
	cob main.c -ldl -CC $(MFCINC) $(MFCLIB) -L${PWD} -lbsoruncso -L${PJROOT}/c/pro_c -luser_dyn -o $@ 

main_use_objectfile:
	#gcc -ldl -L${PJROOT}/c/pro_c -luser_dyn $(MFCINC) $(MFCLIB) bsoruncso.o main_use_objectfile.c -o $@ 
	cob main_use_objectfile.c -ldl -CC $(MFCINC) $(MFCLIB) -L${PWD} -lbsoruncso -L${PJROOT}/c/pro_c -luser_dyn -o $@ 

bsoruncso.so: bsoruncso.cbl
	cob -z $<
	cob -Z $<

csorunbso.so: csorunbso.c $(DIR_COBOL_SO)/libcblopedb.so
	#cob -Z $<  -L${PWD} -lbsoruncso -lcblopedb
	cob -z $<  -L${PWD} -lbsoruncso -lcblopedb

runcso.so: runcso.cbl
	#cob -u $<  -L${PWD} -lbsoruncso
	cob -Z $<  -L${PWD} -lbsoruncso

newrunb: ${DYNLIBNAME}
	cd $(MT_ROOT); \
	if test ! -f COBOL_MF/runb.orig; then cp COBOL_MF/runb COBOL_MF/runb.orig; echo "runb is backuped"; fi;\
	rm -f COBOL_MF/runb; \
	./make.sh RUNB_ADD_OPT="-L${PJROOT}/c/pro_c -luser_dyn"; \
	if test "$$?" != "0"; then \
		echo "ERROR: rebuild newrunb"; \
		exit 3; \
	fi; \
	export COBPATH=$(COBPATH):${PJROOT}/c/so:${PJROOT}/c/pro_c:${PJROOT}/cobol/so 

recoverrunb:
	${ACT_RECOVER_RUNB}

############################################################################
test: newrunb test_gnt_cso_func test_bso_cso test_so_none test_gnt_cso test_cso_bso test_bso_none_db recoverrunb

testdumy: newrunb
	$(SETENV); \
	#EJR -v ${PJROOT}/c/so/TESTJOB.ksh

test_so_none: ${DIR_C_SO}/PGMTEST.so 
	$(SETENV); \
	EJR -v job_so_none.ksh

test_gnt_cso: ${DIR_COBOL_SO}/runcso.gnt ${DYNLIBNAME}
	$(SETENV); \
	EJR -v job_gnt_cso.ksh 

.IGNORE: test_gnt_cso_func
test_gnt_cso_func: ${DIR_COBOL_SO}/runcsofunc.gnt
	$(SETENV); \
	EJR -v job_gnt_cso_func.ksh 

test_bso_cso: ${DIR_COBOL_SO}/bsoruncso.so
	$(SETENV); \
	EJR -v job_bso_cso.ksh

test_cso_bso1111: ${DIR_COBOL_SO}/libbsoruncso.so ${DIR_COBOL_SO}/csorunbso.so 
	$(SETENV); \
	EJR -v job_cso_bso.ksh

#test_cso_bso: $(DIR_COBOL_SO)/libcblopedb.so ${DIR_COBOL_SO}/cblopedb.so ${DIR_COBOL_SO}/csorunbso.so 
test_cso_bso: $(DIR_COBOL_SO)/libcblopedb.so ${DIR_COBOL_SO}/csorunbso.so 
	$(SETENV); \
	EJR -v job_cso_bso.ksh

#test_bso_none_db: clean_cblopedb $(DIR_COBOL_SO)/cblopedb.so cblopedb.so
test_bso_none_db: $(DIR_COBOL_SO)/cblopedb.so 
	$(SETENV); \
	EJR -v job_bso_none_db.ksh

clean_cblopedb:
	rm -f $(DIR_COBOL_SO)/cblopedb.so

############################################################################
${DIR_COBOL_SO}/runcso.gnt: ${DIR_COBOL_SO}/runcso.cbl
	cob -u $< -o $@ 

${DIR_COBOL_SO}/runcsofunc.gnt: ${DIR_COBOL_SO}/runcsofunc.cbl
	cob -u $< -o $@ 

${DIR_C_SO}/PGMTEST.so:${DIR_C_SO}/PGMTEST.c
	#gcc -maix64 -I$(ORACLE_HOME)/precomp/public -L$(ORACLE_HOME)/lib $< -o $@ -lclntsh -shared
	cob -Z $< -CC -I$(ORACLE_HOME)/precomp/public -L$(ORACLE_HOME)/lib -o $@ -lclntsh 

${DIR_COBOL_SO}/bsoruncso.so:${DIR_COBOL_SO}/bsoruncso.cbl
	cob -z $< -o $@

${DIR_COBOL_SO}/libbsoruncso.so:${DIR_COBOL_SO}/bsoruncso.cbl
	cob -Z $< -o $@

${DIR_COBOL_SO}/csorunbso.so: ${DIR_COBOL_SO}/csorunbso.c
	cob -z $< -L${DIR_COBOL_SO} -lcblopedb -o $@
	#gcc -maix64 -I$(ORACLE_HOME)/precomp/public -L$(ORACLE_HOME)/lib $< -o $@ -lclntsh -shared -L${DIR_COBOL_SO} -lcblopedb

$(DIR_COBOL_SO)/cblopedb.so: $(DIR_COBOL_SO)/cblopedb.pco
	case "${MT_DB}" in \
		DB_ORACLE) ${ORACLE_HOME}/bin/procob ${PCOOPT} iname=$< oname=$(DIR_COBOL_SO)/cblopedb.cob;; \
		DB_DB2LUW) $(DB2) connect to ${MT_DB_LOGIN}; \
			$(DB2) prep $< ACTION REPLACE BINDFILE DEFERRED_PREPARE NO DEGREE 1 DISCONNECT EXPLICIT DYNAMICRULES RUN EXPLAIN NO ISOLATION CS SQLRULES DB2 VALIDATE RUN VERSION REF CALL_RESOLUTION DEFERRED DATETIME ISO NOREOPT VARS TARGET MFCOB; \
			$(DB2) bind $(DIR_COBOL_SO)/cblopedb.bnd; \
			$(DB2) connect reset; \
			$(DB2) terminate; \
			mv $(DIR_COBOL_SO)/cblopedb.cbl $(DIR_COBOL_SO)/cblopedb.cob;; \
		*) echo "DB type ${MT_DB} unknown"; exit 1;; \
	esac

	COBCPY=$(COBCPY); export COBCPY;\
	cob -z ${COBOPT} $(DIR_COBOL_SO)/cblopedb.cob 

cblopedb.so:$(DIR_COBOL_SO)/cblopedb.so
libcblopedb.so:$(DIR_COBOL_SO)/libcblopedb.so

$(DIR_COBOL_SO)/libcblopedb.so: $(DIR_COBOL_SO)/cblopedb.pco
	case "${MT_DB}" in \
		DB_ORACLE) ${ORACLE_HOME}/bin/procob ${PCOOPT} iname=$< oname=$(DIR_COBOL_SO)/cblopedb.cob;; \
		DB_DB2LUW) $(DB2) connect to ${MT_DB_LOGIN}; \
			$(DB2) prep $< ACTION REPLACE BINDFILE DEFERRED_PREPARE NO DEGREE 1 DISCONNECT EXPLICIT DYNAMICRULES RUN EXPLAIN NO ISOLATION CS SQLRULES DB2 VALIDATE RUN VERSION REF CALL_RESOLUTION DEFERRED DATETIME ISO NOREOPT VARS TARGET MFCOB; \
			$(DB2) bind $(DIR_COBOL_SO)/cblopedb.bnd; \
			$(DB2) connect reset; \
			$(DB2) terminate; \
			mv $(DIR_COBOL_SO)/cblopedb.cbl $(DIR_COBOL_SO)/cblopedb.cob;; \
		*) echo "DB type ${MT_DB} unknown"; exit 1;; \
	esac
    #About cob -y,U,CC
	#Compile to Self-contained Callable Shared Object (-y[,U][,CC])
	#Processes a source file to a self-contained callable shared object. We recommend that you use this only for creating DB2 stored procedures.
	#The U option specifies that an error message should be issued if there are any unresolved symbols.
	#The CC option to the -y flag enables you to link COBOL and C++ objects into a self-contained callable shared object. If C++ source files (.C) are specified, the C++ compiler is invoked to compile them to object code first.
	# if Dont need self-contained: use cob -Z $(DIR_COBOL_SO)/cblopedb.cob -o $@ 
	case "${MT_COBOL}" in \
		COBOL_MF) COBCPY=$(COBCPY); export COBCPY;\
				  cob -y,U,CC $(DIR_COBOL_SO)/cblopedb.cob  ${ORACLE_HOME}/precomp/lib/cobsqlintf.o  -L${ORACLE_HOME}/lib -lclntsh -o $@;; \
		COBOL_IT) COBCPY=$(COBCPY); export COBCPY;\
				  cobc -b $(DIR_COBOL_SO)/cblopedb.cob  ${ORACLE_HOME}/precomp/lib/cobsqlintf.o  -L${ORACLE_HOME}/lib -lclntsh -o $@;; \
		*) echo "Cobol type ${COBOL_USED} unknown"; exit 1;; \
	esac

clean:
	rm -rf main
	rm -rf main_use_objectfile
	rm -rf *.so *.o *.idy *.int *.gnt
	cd ${DIR_C_SO}; rm -rf *.so *.o *.idy *.int *.gnt
	cd ${DIR_C_PROC}; rm -rf *.so *.o *.idy *.int *.gnt
	cd ${DIR_COBOL_SO}; rm -rf *.so *.o *.idy *.int *.gnt *.lis *.lst
	for i in $$(ls ${DIR_C_PROC}/*.pc);do j=$${i%pc};echo $${j}c;rm -f $${j}c;done
	for i in $$(ls ${DIR_COBOL_SO}/*.pco);do j=$${i%pco};echo $${j}cob;rm -f $${j}cob;done

run: all
	export LD_LIBRARY_PATH=/nfs/users/zhaozhan/test/c/pro_c:/nfs/users/zhaozhan/test/c/so:$$LD_LIBRARY_PATH:$$PWD; \
	./main; \
	./main_use_objectfile

test.so: $(DIR_COBOL_SO)/test.so

$(DIR_COBOL_SO)/test.so: $(DIR_COBOL_SO)/test.pco
	case "${MT_DB}" in \
		DB_ORACLE) ${ORACLE_HOME}/bin/procob ${PCOOPT} iname=$< oname=$(DIR_COBOL_SO)/test.cob;; \
		DB_DB2LUW) $(DB2) connect to ${MT_DB_LOGIN}; \
			$(DB2) prep $< ACTION REPLACE BINDFILE DEFERRED_PREPARE NO DEGREE 1 DISCONNECT EXPLICIT DYNAMICRULES RUN EXPLAIN NO ISOLATION CS SQLRULES DB2 VALIDATE RUN VERSION REF CALL_RESOLUTION DEFERRED DATETIME ISO NOREOPT VARS TARGET MFCOB; \
			$(DB2) connect reset; \
			$(DB2) terminate; \
			mv $(DIR_COBOL_SO)/test.cbl $(DIR_COBOL_SO)/test.cob;; \
		*) echo "DB type ${MT_DB} unknown"; exit 1;; \
	esac

	#cob -Z $(DIR_COBOL_SO)/test.cob -o $@
	COBCPY=$(COBCPY); export COBCPY;\
	cob -z $(DIR_COBOL_SO)/test.cob -o $@

run_es:
	$(SETENV_RUNONLY_ES51); \
	for i in $(ALLJOB);do \
		echo "============Begin to run $$i"; \
		EJR -v $$i; \
	done
run_vc:
	$(SETENV_RUNONLY_VC21); \
	for i in $(ALLJOB);do \
		echo "==========Begin to run $$i"; \
		EJR -v $$i; \
	done

testdb2.gnt: testdb2.sqb
	@${ECHO_CMD} "$@ ..."
	@$(DB2) connect to ${MT_DB_LOGIN}
	@$(DB2) prep $< ACTION REPLACE BINDFILE DEFERRED_PREPARE NO DEGREE 1 DISCONNECT EXPLICIT DYNAMICRULES RUN EXPLAIN NO ISOLATION CS SQLRULES DB2 VALIDATE RUN VERSION REF CALL_RESOLUTION DEFERRED DATETIME ISO NOREOPT VARS TARGET MFCOB
	@$(DB2) bind testdb2.bnd; 
	@$(DB2) connect reset
	@$(DB2) terminate
	COBCPY=$(COBCPY); export COBCPY;\
	if [ -z "${MT_COBOL}" ]; then \
		echo "MT_COBOL not set. See make.sh"; \
		exit 1; \
	fi; \
	case "${MT_COBOL}" in \
		COBOL_MF) COBCPY=$(COBCPY):${DB2PATH}/include/cobol_mf; export COBCPY; \
                          cob -u $< -o $@ ${CBLOPT} -C "COPYEXT=cpy,cbl" -L${DB2PATH}/lib64 -ldb2 -ldb2gmf;; \
		COBOL_IT) COBCPY=$(COBCPY):${DB2PATH}/include/cobol_a; export COBCPY; \
                          cobc -o $@  testdb2.cbl;; \
		*) echo "Cobol type ${COBOL_USED} unknown"; exit 1;; \
	esac
	@${ECHO} " Done"
