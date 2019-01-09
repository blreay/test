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
DB2 = db2
ECHO = echo 

VPATH=.:${PLATFORM_FIXED}:${COBOL_USED}:${DB2DIR}/include/cobol_mf
COBCPY=$(VPATH) 

.IGNORE: test_gnt_cso_func 
libcblopedb.so: cblopedb.pco 
	MT_DB="DB_ORACLE"; \
	case "${MT_DB}" in \
		DB_ORACLE) ${ORACLE_HOME}/bin/procob ${PCOOPT} iname=$< oname=cblopedb.cob;; \
		DB_DB2LUW) $(DB2) connect to ${MT_DB_LOGIN}; \
			$(DB2) prep $< ACTION REPLACE BINDFILE DEFERRED_PREPARE NO DEGREE 1 DISCONNECT EXPLICIT DYNAMICRULES RUN EXPLAIN NO ISOLATION CS SQLRULES DB2 VALIDATE RUN VERSION REF CALL_RESOLUTION DEFERRED DATETIME ISO NOREOPT VARS TARGET MFCOB; \
			$(DB2) bind cblopedb.bnd; \
			$(DB2) connect reset; \
			$(DB2) terminate; \
			mv $(DIR_COBOL_SO)/cblopedb.cbl $(DIR_COBOL_SO)/cblopedb.cob;; \
		*) echo "DB type ${MT_DB} unknown"; exit 1;; \
	esac
    #About cob -y,U,CC
	#Compile to Self-contained Callable Shared Object (-y[,U][,CC])
	MT_COBOL="COBOL_IT"; \
	case "${MT_COBOL}" in \
		COBOL_MF) COBCPY=$(COBCPY); export COBCPY;\
				  cob -y,U,CC cblopedb.cob  ${ORACLE_HOME}/precomp/lib/cobsqlintf.o  -L${ORACLE_HOME}/lib -lclntsh -o $@;; \
		COBOL_IT) COBCPY=$(COBCPY); export COBCPY;\
				  cobc -b cblopedb.cob  ${ORACLE_HOME}/precomp/lib/cobsqlintf.o  -L${ORACLE_HOME}/lib -lclntsh -o $@;; \
		*) echo "Cobol type ${COBOL_USED} unknown"; exit 1;; \
	esac

clean:
	rm -rf *.so *.o *.idy *.int *.gnt *.cob *.lst *.lis

