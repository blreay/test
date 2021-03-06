# Makefile for Oracle Runtime build
#
#
GNTS = \
	PGM_WR_SEQF.gnt \
	PGM_WR_SEQV.gnt \
	PGM_WR_IDXV.gnt \
	PGM_WR_RELV.gnt \
	BDMS0201.gnt \
	stack.gnt \
	retval.gnt \
	sample.gnt \
	case1.gnt \
	userabend.gnt \
	cobsleep.gnt \

.SUFFIXES: .cbl .cob .c .o .gnt .sqb .bnd .a1
ECHO_CMD=echo
ECHO_END=\c

VPATH=.:${PLATFORM_FIXED}:${COBOL_USED}
COBCPY=$(VPATH)

UPPEROPT=-C 'CONSTANT UPPER-CALL "1"'
CBLOPT=-C "sourceformat=fixed XREF COMP-6=2 IBMCOMP COPYEXT=cpy FILESHARE PERFORM-TYPE=OSVS SIGN=ASCII MFSYNC" ${UPPEROPT}
COBOPT=-C "sourceformat=fixed XREF COMP-6=2 IBMCOMP COPYEXT=cpy,COB,cob SIGN=ASCII" ${UPPEROPT}

all: $(GNTS)

stack.gnt: stack.cbl
	${ECHO_CMD} "$@ ... ${ECHO_END}"
	COBCPY=$(COBCPY); export COBCPY;\
	env > /tmp/22; \
	if [ -z "${MT_COBOL}" ]; then \
		echo "MT_COBOL not set. See make.sh" ; \
		exit 1; \
	fi; \
	case "${MT_COBOL}" in \
		COBOL_MF) cob -g -u ${COBOPT} -C "use(./opt.dir)" -C list=$(*F).lst $<;; \
		COBOL_IT) cobc -fthread-safe -g -G -fmf-gnt  -fsign-ebcdic -fmem-info -m -t ./lst -fmf-gnt -Wall -fixed -lcitextfh -t $*.lst -conf=$$PWD/cit.conf.noextfh $<;; \
		*) echo "Cobol type $${MT_COBOL} unknown"; exit 1;; \
	esac
	@${ECHO_CMD} " Done"

retval.gnt.profiling: retval.cbl
	${ECHO_CMD} "$@ ... ${ECHO_END}"
	COBCPY=$(COBCPY); export COBCPY;\
	env > /tmp/22; \
	if [ -z "${MT_COBOL}" ]; then \
		echo "MT_COBOL not set. See make.sh" ; \
		exit 1; \
	fi; \
	case "${MT_COBOL}" in \
		COBOL_MF) cob -u ${COBOPT} -C "use(./opt.dir)" -C list=$(*F).lst $<;; \
		COBOL_IT) cobc -fthread-safe -g -fprofiling -G -fmf-gnt  -fsign-ebcdic -fmem-info -std=mf -m -t ./lst -fmf-gnt -Wall -fixed -lcitextfh -t $*.lst -conf=$$PWD/cit.conf.noextfh $<;; \
		*) echo "Cobol type $${MT_COBOL} unknown"; exit 1;; \
	esac
	@${ECHO_CMD} " Done"

retval.gnt: retval.cbl
	${ECHO_CMD} "$@ ... ${ECHO_END}"
	COBCPY=$(COBCPY); export COBCPY;\
	env > /tmp/22; \
	if [ -z "${MT_COBOL}" ]; then \
		echo "MT_COBOL not set. See make.sh" ; \
		exit 1; \
	fi; \
	case "${MT_COBOL}" in \
		COBOL_MF) cob -u ${COBOPT} -C "use(./opt.dir)" -C list=$(*F).lst $<;; \
		COBOL_IT) cobc -fthread-safe -g -G -fmf-gnt  -fsign-ebcdic -fmem-info -std=mf -m -t ./lst -fmf-gnt -Wall -fixed -lcitextfh -t $*.lst -conf=$$PWD/cit.conf.noextfh $<;; \
		*) echo "Cobol type $${MT_COBOL} unknown"; exit 1;; \
	esac
	@${ECHO_CMD} " Done"

retval.gnt2: retval.cbl
	${ECHO_CMD} "$@ ... ${ECHO_END}"
	COBCPY=$(COBCPY); export COBCPY;\
	env > /tmp/22; \
	if [ -z "${MT_COBOL}" ]; then \
		echo "MT_COBOL not set. See make.sh" ; \
		exit 1; \
	fi; \
	case "${MT_COBOL}" in \
		COBOL_MF) cob -u ${COBOPT} -C "use(./opt.dir)" -C list=$(*F).lst $<;; \
		COBOL_IT) cobc -fthread-safe -g -G -fmf-gnt  -fsign-ebcdic -fmem-info -std=mf -m -t ./lst -fmf-gnt -Wall -fixed -lcitextfh -t $*.lst -conf=$$PWD/cit.conf.noextfh $<;; \
		*) echo "Cobol type $${MT_COBOL} unknown"; exit 1;; \
	esac
	@${ECHO_CMD} " Done"

userabend.gnt: userabend.cbl
	${ECHO_CMD} "$@ ... ${ECHO_END}"
	COBCPY=$(COBCPY); export COBCPY;\
	env > /tmp/22; \
	if [ -z "${MT_COBOL}" ]; then \
		echo "MT_COBOL not set. See make.sh" ; \
		exit 1; \
	fi; \
	case "${MT_COBOL}" in \
		COBOL_MF) cob -u ${COBOPT} -C "use(./opt.dir)" -C list=$(*F).lst $<;; \
		COBOL_IT) cobc -fthread-safe -g -G -fmf-gnt  -fsign-ebcdic -fmem-info -std=mf -m -t ./lst -fmf-gnt -Wall -fixed -lcitextfh -t $*.lst -conf=$$PWD/cit.conf.noextfh $<;; \
		*) echo "Cobol type $${MT_COBOL} unknown"; exit 1;; \
	esac
	@${ECHO_CMD} " Done"

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
		COBOL_IT) cobc -g -G  -fsign-ebcdic  -fmem-info -m -t ./lst -fmf-gnt -Wall -fixed -lcitextfh -t $*.lst -conf=$$PWD/cit.conf $<;; \
		*) echo "Cobol type $${MT_COBOL} unknown"; exit 1;; \
	esac
	@${ECHO_CMD} " Done"


clean:
	-rm -rf c *.lst *.lis *.int *.idy $(GNTS) INOUTF INOUTV

runf: clean all
	DD_INOUTF=$$PWD/INOUTF; export DD_INOUTF; \
	case "${MT_COBOL}" in \
		COBOL_MF) cobrun ./PGM_WR_SEQF.gnt;; \
		COBOL_IT) cobcrun ./PGM_WR_SEQF.gnt;; \
		*) echo "Cobol type $${MT_COBOL} unknown"; exit 1;; \
	esac
	@echo "----------------------------------------------------"
	hexdump -C $$PWD/INOUTF

runv: clean all
	DD_INOUTF=$$PWD/INOUTF; export DD_INOUTF; \
	case "${MT_COBOL}" in \
		COBOL_MF) cobrun ./PGM_WR_IDXV.gnt;; \
		COBOL_IT) cobcrun ./PGM_WR_IDXV.gnt;; \
		*) echo "Cobol type $${MT_COBOL} unknown"; exit 1;; \
	esac
	@echo "----------------------------------------------------"
	hexdump -C $$PWD/INOUTF
runs: clean stack.gnt
	DD_INOUTF=$$PWD/INOUTF; export DD_INOUTF; \
	case "${MT_COBOL}" in \
		COBOL_MF) cobrun ./stack.gnt;; \
		COBOL_IT) cobcrun ./stack.gnt;; \
		*) echo "Cobol type $${MT_COBOL} unknown"; exit 1;; \
	esac
	@echo "----------------------------------------------------"


runr: clean retval.gnt
	DD_INOUTF=$$PWD/INOUTF; export DD_INOUTF; \
	case "${MT_COBOL}" in \
		COBOL_MF) cobrun ./retval.gnt;; \
		COBOL_IT) cobcrun ./retval.gnt 55;; \
		*) echo "Cobol type $${MT_COBOL} unknown"; exit 1;; \
	esac
	@echo "----------------------------------------------------"

