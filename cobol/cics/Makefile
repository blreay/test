.SUFFIXES: .cbl .cob .c .o .gnt .sqb .bnd .a1 .so .ccp
#OBJ=hello.so TOUPDTPS.so TOUPDPLS.so TOUPCONV.so
#OBJ=COVSATMC.so COVSATMS.so
#OBJ=BUFSRV.so CHANCLENC.so CHANCONC.so CHANCONS.so COVSATMC.so COVSATMS.so DATCLT.so DATSRV.so DSPERR.so DSPLINE.so DSPMSG.so DUMPHEX.so DYPSAMP.so MIRRDPLC.so MIRRDTPC.so MIRRDTPD.so RCVSCR.so RECCLT.so TOUPDPLS.so TOUPDTPS.so 
OBJ=BUFSRV.so CHANCLENC.so CHANCONC.so CHANCONS.so COVSATMC.so COVSATMS.so DATCLT.so DATSRV.so DSPERR.so DSPLINE.so DSPMSG.so DUMPHEX.so RCVSCR.so RECCLT.so TOUPDPLS.so TOUPDTPS.so UPDPLRC.so TOUPDPLC.so \
hello.so TOUPDTPS.so TOUPCONV.so TOUPDPLS.so  COVSATMP.so UPDPLC.so MIRRDPLC.so

## following files can't be built on linux
#MIRRDPLC.so MIRRDTPC.so

all: ${OBJ}

.ccp.so:
	cicstcl -l COBOLIT $< 
	#cobc -fthread-safe -fnotrunc  -febcdic-charset -preprocess=cicscit -I/opt/ibm/cics/include -m $<
	#cobc -fthread-safe -fnotrunc  -preprocess=cicscit -I/opt/ibm/cics/include -m $<
	
#test.so:test.cbl
.cbb.so:
	cobc -fthread-safe -fnotrunc -I/opt/ibm/cics/include -m $<

clean:
	/bin/rm -rf *.so *.cbl
