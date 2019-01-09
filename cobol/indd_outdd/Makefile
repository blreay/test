# Makefile for Oracle Runtime build
#
#
GNTS = \
	indd_outdd.gnt \

.SUFFIXES: .cbl .cob .c .o .gnt .sqb .bnd .a1
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
	env > /tmp/22; \
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

all: $(GNTS)

clean:
	-rm -rf c *.lst *.lis *.int *.idy $(GNTS) INOUTF INOUTV

run: clean all
	DD_INOUTF=$$PWD/INOUTF; export DD_INOUTF; \
	DD_SYSIN=/tmp/22.in; export DD_SYSIN; \
	DD_SYSOUT=/tmp/22.out; export DD_SYSOUT; \
	rm /tmp/22.out; echo "---" > /tmp/22.out; \
	rm /tmp/22.in; echo "" > /tmp/22.in; \
	export PATH=$$PATH:$$MT_ROOT/$$MT_COBOL; \
	RUNBTRACE=yes; \
	export COBPATH=$$COBPATH:$$MT_ROOT/$$MT_COBOL; \
	echo $$PATH; \
	which runb; \
	case "${MT_COBOL}" in \
		COBOL_MF) runb ./indd_outdd.gnt;; \
		COBOL_IT) runb ./indd_outdd.gnt;; \
		*) echo "Cobol type $${MT_COBOL} unknown"; exit 1;; \
	esac
	@echo "----------------------------------------------------"
	cat /tmp/22.out
	hexdump -C $$PWD/INOUTF

