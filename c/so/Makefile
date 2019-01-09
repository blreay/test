ifeq (${MT_COBOL},COBOL_MF)
MFCINC = -I$(COBDIR)/include
MFCLIB = -L$(COBDIR)/lib
MFCLIB += -lcobrts64 -lcobcrtn64 -lcobmisc64 -lcobscreen64
MFCLIB += -lcobrts64
endif

libALLPGM.so: $(OBJ)
	#g++ -o $@ -shared -Wl,-G PGMTEST.c -maix64 -lstdc++
	#g++ -o $@ -shared -Wl,-G PGMTEST.c  -lstdc++
	gcc -g PGMTEST.c -fPIC -shared -o $@ -lstdc++
	gcc -g PGMTEST.c -fPIC -shared -o PGMTEST.so -lstdc++
	gcc -g PGMEXIT.c -fPIC -shared -o PGMEXIT.so -lstdc++
	cob -u STOPRUN.cbl
	#gcc -g $< -fPIC -shared -o $@ -lstdc++  -I $(ORACLE_HOME)/precomp/public -L $(ORACLE_HOME)/lib -lclntsh

clean:
	rm -rf *.so runso

all:clean libALLPGM.so liborasptest.so runso
	echo all

run:all
	export COBPATH=`pwd`; \
	EJR -v TESTJOB.ksh

runexit: TESTEXIT.ksh
	export COBPATH=`pwd`; \
	EJR -v $<

runcobol: TEST_COBOL_EXIT.ksh
	export COBPATH=`pwd`; \
	EJR -v $<

liborasptest.so:orasptest.c
	gcc -g $< -fPIC -shared -o $@ -lstdc++
	@echo "######################################"
	@echo "Please copy $@ to $$ORACLE_HOME/bin"
	@echo "######################################"

runso:runso.c liborasptest.so
	#gcc $< -L$$PWD -l orasptest -L $$PWD/../../cobol/so -l cblopedb -I${ORACLE_HOME}/precomp/public -L${ORACLE_HOME}/lib -ldl -o $@
	#gcc $< -L$$PWD -l orasptest -L $$PWD/../../cobol/so -lcblopedb -I${ORACLE_HOME}/precomp/public -L${ORACLE_HOME}/lib -ldl -L $$PWD/../pro_c -luser_dyn -o $@
	#gcc $< $(MFINC) $(MFLIB) -L$$PWD -l orasptest -L $$PWD/../../cobol/so -I${ORACLE_HOME}/precomp/public -L${ORACLE_HOME}/lib -ldl -L $$PWD/../pro_c -luser_dyn -o $@ /opt/microfocus/cobol5.1/lib/libcobstat64.a
	#gcc $< $(MFCINC) $(MFCLIB) -L$$PWD -lorasptest -L$$PWD/../../cobol/so -lcblopedb -I${ORACLE_HOME}/precomp/public -L${ORACLE_HOME}/lib -L$$PWD/../pro_c -luser_dyn -o $@ /opt/microfocus/cobol5.1/lib/libcobstat64.a ${ORACLE_HOME}/precomp/lib/cobsqlintf.o -lclntsh
	gcc $< $(MFCINC) $(MFCLIB) -L$$PWD -lorasptest -L$$PWD/../../cobol/so -lcblopedb -I${ORACLE_HOME}/precomp/public -L${ORACLE_HOME}/lib -L$$PWD/../pro_c -luser_dyn -o $@ ${ORACLE_HOME}/precomp/lib/cobsqlintf.o -lclntsh
