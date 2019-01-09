#PJROOT=/nfs/users/zhaozhan/test
PJROOT=$(PWD)/..
DIR_C_SO=$(PJROOT)/so
DIR_KSH_JOB=$(PJROOT)/job
DIR_C_PROC=$(PJROOT)/c
DIR_COBOL_SO=$(PJROOT)/cobol/so

DYNLIBNAME=${DIR_C_SO}/test_iscics.so
GNTNAME=${DIR_C_SO}/runiscics.gnt

MFCINC = -I$(COBDIR)/include
MFCLIB = -L$(COBDIR)/lib

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
DB_USED_DB2LUW=../DB_DB2LUW
SORT_USED_MF=../SORT_MicroFocus
SORT_USED_SYNCSORT=../SORT_SyncSort
GENERATION_USED_FILE=../GENERATION_FILE

ifneq "$(MT_COBOL)" "COBOL_IT"
        COBOL_USED=$(COBOL_USED_MF)
else
        COBOL_USED=$(COBOL_USED_IT)
endif


VPATH=.:${PLATFORM_FIXED}:${COBOL_USED}:${DB2DIR}/include/cobol_mf
COBCPY=$(VPATH)

SETENV=export COBPATH=$$COBPATH:${DIR_C_SO}:${PJROOT}/c/pro_c:${PJROOT}/cobol/so; \
	export LD_LIBRARY_PATH=${DIR_C_SO}:${PJROOT}/c/so:$$LD_LIBRARY_PATH:$$PWD; \
	export COB_LIBRARY_PATH=${DIR_C_SO}:${PJROOT}/c/so:$$LD_LIBRARY_PATH:$$PWD 
SETENV_RUNONLY_ES51=export COBPATH=$$COBPATH:${DIR_COBOL_SO}/$(OUTPUTDIR).mf5.1; \
	export LD_LIBRARY_PATH=$$LD_LIBRARY_PATH:${DIR_COBOL_SO}/$(OUTPUTDIR).mf5.1
SETENV_RUNONLY_VC21=export COBPATH=$$COBPATH:${DIR_COBOL_SO}/$(OUTPUTDIR).visualcobol; \
	export LD_LIBRARY_PATH=$$LD_LIBRARY_PATH:${DIR_COBOL_SO}/$(OUTPUTDIR).visualcobol
ACT_RECOVER_RUNB=cp $(MT_ROOT)/COBOL_MF/runb.orig $(MT_ROOT)/COBOL_MF/runb

ALLJOB=${DIR_KSH_JOB}/job_so_none.ksh

all: clean ${DYNLIBNAME} ${GNTNAME}

${DYNLIBNAME}: ${DIR_C_PROC}/test_iscics.c
	#cob -Z $< -o $@
	#cob -ug $*.cob -C "use(./opt)" -C "list($*.lst)" -C XREF -C SETTINGS
	#cob -z -g $< -C "use(./opt)" -C "list($*.lst)" -C XREF -C SETTINGS -o $@
	echo COBOL=$(COBOL_USED)
	case "${COBOL_USED}" in \
		$(COBOL_USED_MF)) cob -z -g $< -C "use(./opt)" -C "list($*.lst)" -C XREF -C SETTINGS -o $@;; \
		$(COBOL_USED_IT)) cobc -m -g -G -fmf-gnt $< -Wall -fixed -lcitextfh -t $*.lst  -conf=./cit.conf -o $@;; \
	*) echo "Cobol type ${COBOL_USED} unknown"; exit 1;; \
	esac

${GNTNAME}: ${DIR_C_PROC}/runiscics.cbl
	echo COBOL=$(COBOL_USED)
	case "${COBOL_USED}" in \
		$(COBOL_USED_MF)) cob -z -g $< -C "use(./opt)" -C "list($*.lst)" -C XREF -C SETTINGS -o $@;; \
		$(COBOL_USED_IT)) cobc -m -g -G -fmf-gnt $< -Wall -fixed -lcitextfh -t $*.lst  -conf=./cit.conf -o $@;; \
	*) echo "Cobol type ${COBOL_USED} unknown"; exit 1;; \
	esac

############################################################################
test: clean test_iscics

run: test_iscics

test_iscics: $(DYNLIBNAME) ${GNTNAME}
	$(SETENV); \
	EJR -v $(DIR_KSH_JOB)/test_iscics.ksh
############################################################################
clean:
	rm -rf main
	rm -rf main_use_objectfile
	rm -rf *.so *.o *.idy *.int *.gnt
	cd ${DIR_C_SO}; rm -rf *.so *.o *.idy *.int *.gnt
	cd ${DIR_C_PROC}; rm -rf *.so *.o *.idy *.int *.gnt
	#for i in $$(ls ${DIR_C_PROC}/*.pc);do j=$${i%pc};echo $${j}c;rm -f $${j}c;done
	#for i in $$(ls ${DIR_COBOL_SO}/*.pco);do j=$${i%pco};echo $${j}cob;rm -f $${j}cob;done

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
