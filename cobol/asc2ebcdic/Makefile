CC = gcc
CXX = g++
CFLAGS = -g -O0
LDFLAGS =
DB2=db2

UNAME := $(shell uname)
ifeq ($(UNAME), AIX)
export CC=xlc
export CXX=xlC
endif

ifeq ($(UNAME), SunOS)
export CC=cc
export CXX=CC
endif

export COBCPY:=$(COBCPY):$(DB2DIR)/include/cobol_mf

GNTS = 	FR011.gnt \
	FR012.gnt \


all: $(GNTS) CPROGRAM

CPROGRAM: CPROGRAM.cpp
	$(CXX) $(CFLAGS) $(LDFLAGS) $< -o $@

.SUFFIXES: .sqb .pco .cbl .gnt
.PRECIOUS: %.cbl

%.cbl: 
	case "${MT_DB}" in \
		DB_ORACLE) ${ORACLE_HOME}/bin/procob ${PCOOPT} iname=$(*).pco oname=$(*).cbl;; \
		DB_DB2LUW) $(DB2) connect to ${MT_DB_LOGIN}; \
			$(DB2) prep $(*).sqb ACTION REPLACE BINDFILE DEFERRED_PREPARE NO DEGREE 1 DISCONNECT EXPLICIT DYNAMICRULES RUN EXPLAIN NO ISOLATION CS SQLRULES DB2 VALIDATE RUN VERSION REF CALL_RESOLUTION DEFERRED DATETIME ISO NOREOPT VARS TARGET MFCOB; \
			$(DB2) bind $(*).bnd; \
			$(DB2) connect reset; \
			$(DB2) terminate;; \
		*) echo "DB type ${MT_DB} unknown"; exit 1;; \
	esac

	#COBCPY=$(COBCPY); export COBCPY;\
	#cob -u ${COBOPT} $(*).cob 

.pcoXXX.cbl:
	procob $(PCCINCLUDE) iname='$*.pco' lname='$*.lis' oname='$*.cbl' release_cursor=no hold_cursor=no mode=oracle sqlcheck=syntax common_parser=yes declare_section=no picx=char

.sqbXXX.cbl:
	db2 connect to $(DB2BASE) user $(DBUSER) using $(DBPASSWD)
	db2 prep '$*.sqb' BINDFILE PACKAGE USING '$(notdir $<)' VERSION $(firstword $(shell echo `uname -n`:$(CURDIR)/'$<'|md5sum ))
	db2 bind '$*.bnd'


.cbl.gnt:
ifeq "$(MT_COBOL)" "COBOL_MF"
	cob -ug $*.cbl -C "use(opt.dir)" -C "list($*.lst)" -C XREF -C SETTINGS
else
	cobc -fthread-safe -m -g -G -fmf-gnt $*.cbl -w -fixed -ffcdreg -lcitextfh -t $*.lst -conf=cit.conf
endif

clean:
	-rm -rf c *.lst *.lis *.int *.idy *.bnd *.mfconf CPROGRAM SELECTORA.cbl SELECTDB2.cbl $(GNTS)
	-for i in `ls *.sqb *.pco`; do echo $${i};done
	-for i in `ls *.sqb *.pco`; do echo $${i}; fn=$${i%.*}.cbl; [[ -f $$fn ]] && echo $$fn && /bin/rm $$fn || true; done

