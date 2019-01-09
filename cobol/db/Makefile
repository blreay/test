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

all: cblopedb.gnt

############################################################################
cblopedb.gnt: cblopedb.pco
	case "${MT_DB}" in \
		DB_ORACLE) ${ORACLE_HOME}/bin/procob ${PCOOPT} iname=$< oname=cblopedb.cob;; \
		DB_DB2LUW) $(DB2) connect to ${MT_DB_LOGIN}; \
			$(DB2) prep cblopedb.sqb ACTION REPLACE BINDFILE DEFERRED_PREPARE NO DEGREE 1 DISCONNECT EXPLICIT DYNAMICRULES RUN EXPLAIN NO ISOLATION CS SQLRULES DB2 VALIDATE RUN VERSION REF CALL_RESOLUTION DEFERRED DATETIME ISO NOREOPT VARS TARGET MFCOB; \
			$(DB2) bind cblopedb.bnd; \
			$(DB2) connect reset; \
			$(DB2) terminate; \
			mv cblopedb.cbl cblopedb.cob;; \
		*) echo "DB type ${MT_DB} unknown"; exit 1;; \
	esac

	COBCPY=$(COBCPY); export COBCPY;\
	cob -u ${COBOPT} cblopedb.cob 

%.gnt: %.pco %.sqb
	case "${MT_DB}" in \
		DB_ORACLE) ${ORACLE_HOME}/bin/procob ${PCOOPT} iname=$< oname=$(*).cob;; \
		DB_DB2LUW) $(DB2) connect to ${MT_DB_LOGIN}; \
			$(DB2) prep $(*).sqb ACTION REPLACE BINDFILE DEFERRED_PREPARE NO DEGREE 1 DISCONNECT EXPLICIT DYNAMICRULES RUN EXPLAIN NO ISOLATION CS SQLRULES DB2 VALIDATE RUN VERSION REF CALL_RESOLUTION DEFERRED DATETIME ISO NOREOPT VARS TARGET MFCOB; \
			$(DB2) bind $(*).bnd; \
			$(DB2) connect reset; \
			$(DB2) terminate; \
			mv $(*).cbl $(*).cob;; \
		*) echo "DB type ${MT_DB} unknown"; exit 1;; \
	esac

	COBCPY=$(COBCPY); export COBCPY;\
	cob -u ${COBOPT} $(*).cob 

clean:
	rm -rf *.so *.o *.idy *.int *.gnt *.bnd *.lis

test: cblopedb.gnt
	runb cblopedb.gnt

%.aaa: cblopedb.sqb
	echo "$*"
	
############################################################################

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
