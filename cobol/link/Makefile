# Makefile for Oracle Runtime build
#
#
COBOL_USED=../COBOL_MF
.SUFFIXES: .cbl .cob .c .o .gnt .sqb .bnd .a1

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

COBOL_USED_MF=../COBOL_MF
COBOL_USED_IT=../COBOL_IT
COBOL_USED_NONE=../COBOL_NONE
DB_USED_ORACLE=../DB_ORACLE
DB_USED_DB2LUW=../DB_DB2LUW
SORT_USED_MF=../SORT_MicroFocus
SORT_USED_SYNCSORT=../SORT_SyncSort
GENERATION_USED_FILE=../GENERATION_FILE

VPATH=.:${PLATFORM_FIXED}:${COBOL_USED}
COBCPY=$(VPATH)

UPPEROPT=-C 'CONSTANT UPPER-CALL "1"'
CBLOPT=-C "sourceformat=fixed XREF COMP-6=2 IBMCOMP COPYEXT=cpy FILESHARE PERFORM-TYPE=OSVS SIGN=ASCII MFSYNC" ${UPPEROPT}
COBOPT=-C "sourceformat=fixed XREF COMP-6=2 IBMCOMP COPYEXT=cpy,COB,cob SIGN=ASCII" ${UPPEROPT}

.cbl.gnt:
	@${ECHO_CMD} "$@ ... ${ECHO_END}"
	@COBCPY=$(COBCPY); export COBCPY;\
	if [ -z "${COBOL_USED}" ]; then \
		echo "MT_COBOL not set. See make.sh" ; \
		exit 1; \
	fi; \
	case "${COBOL_USED}" in \
		$(COBOL_USED_MF)) cob -u ${COBOPT} -C "use(./opt.dir)" -C list=$(*F).lst $<;; \
		$(COBOL_USED_IT)) cobc -std=mf -m -t ./lst -fmf-gnt $<;; \
		*) echo "Cobol type $${MT_COBOL} unknown"; exit 1;; \
	esac
	@${ECHO} " Done"

all: JOINSORTFILE.gnt test.gnt indd_outdd.gnt LSEQ_SEQ_F.gnt

clean:
	rm -f *.gnt *.int *.lst *.o *.idy
	rm -f $$DATA/OUT

run: clean all
	runb JOINSORTFILE
	@echo "----------------------------------------------------"
	hexdump -C $$DATA/OUT

trace:
	cob -u ${COBOPT} -C list=$(*F).lst mw_trace.cbl

run2: mytrace.cbl
	if [ -z "${COBOL_USED}" ]; then \
		echo "MT_COBOL not set. See make.sh" ; \
		exit 1; \
	fi; \
	case "${COBOL_USED}" in \
		$(COBOL_USED_MF)) cob -u ${COBOPT} -C list=$(*F).lst $<;; \
		$(COBOL_USED_IT)) cobc -std=mf -m -t ./lst -fmf-gnt $<;; \
		*) echo "Cobol type $${MT_COBOL} unknown"; exit 1;; \
	esac
run3: 1.cbl
	if [ -z "${COBOL_USED}" ]; then \
		echo "MT_COBOL not set. See make.sh" ; \
		exit 1; \
	fi; \
	case "${COBOL_USED}" in \
		$(COBOL_USED_MF)) cob -u ${COBOPT} -C list=$(*F).lst $<;; \
		$(COBOL_USED_IT)) cobc -std=mf -m -t ./lst -fmf-gnt $<;; \
		*) echo "Cobol type $${MT_COBOL} unknown"; exit 1;; \
	esac

run4: JOINSORTFILE.cbl
	if [ -z "${COBOL_USED}" ]; then \
		echo "MT_COBOL not set. See make.sh" ; \
		exit 1; \
	fi; \
	case "${COBOL_USED}" in \
		$(COBOL_USED_MF)) cob -u ${COBOPT} -C list=$(*F).lst $<;; \
		$(COBOL_USED_IT)) cobc -std=mf -m -t ./lst -fmf-gnt $<;; \
		*) echo "Cobol type $${MT_COBOL} unknown"; exit 1;; \
	esac
	runb JOINSORTFILE
