ALL=TSTCPGM.so CBLPGM.gnt main

all: $(ALL) 

.SUFFIXES: .cbl .cob .c .o .gnt .sqb .bnd .a1 .so
ECHO_CMD=echo
ECHO_END=\c

VPATH=.:${PLATFORM_FIXED}:${COBOL_USED}
COBCPY=$(VPATH)

UPPEROPT=-C 'CONSTANT UPPER-CALL "1"'
CBLOPT=-C "sourceformat=fixed XREF COMP-6=2 IBMCOMP COPYEXT=cpy FILESHARE PERFORM-TYPE=OSVS SIGN=ASCII MFSYNC" ${UPPEROPT}
COBOPT=-C "sourceformat=fixed XREF COMP-6=2 IBMCOMP COPYEXT=cpy,COB,cob SIGN=ASCII" ${UPPEROPT}


.cbl.gnt:
	${ECHO_CMD} "$@ ... ${ECHO_END}"
	COBCPY=$(COBCPY); export COBCPY;\
	if [ -z "${MT_COBOL}" ]; then \
		echo "MT_COBOL not set. See make.sh" ; \
		exit 1; \
	fi; \
	case "${MT_COBOL}" in \
		COBOL_MF) cob -u ${COBOPT} -C "use(./opt.dir)" -C list=$(*F).lst $<;; \
		COBOL_IT) cobc -std=mf -m -t ./lst -fmf-gnt -Wall -fixed -lcitextfh -t $*.lst -conf=$$PWD/cit.conf $<;; \
		*) echo "Cobol type $${MT_COBOL} unknown"; exit 1;; \
	esac
	@${ECHO_CMD} " Done"


.c.so:
	${ECHO_CMD} "$@ ... ${ECHO_END}"
	COBCPY=$(COBCPY); export COBCPY;\
	if [ -z "${MT_COBOL}" ]; then \
		echo "MT_COBOL not set. See make.sh" ; \
		exit 1; \
	fi; \
	case "${MT_COBOL}" in \
		COBOL_MF) cob -z ${COBOPT} -C "use(./opt.dir)" -C list=$(*F).lst $<;; \
		COBOL_IT) cobc -std=mf -m -t ./lst -fmf-gnt -Wall -fixed -lcitextfh -t $*.lst -conf=$$PWD/cit.conf $<;; \
		*) echo "Cobol type $${MT_COBOL} unknown"; exit 1;; \
	esac
	@${ECHO_CMD} " Done"

main: TSTCPGM.c
	gcc -D_MAIN_ENTRY_ -g -o $@ $<

clean:
	rm -f *.o *.so *.int *.gnt $(ALL) ULOG.* access.*

