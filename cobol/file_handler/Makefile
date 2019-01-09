GNTS =   \
	ARTEXTFH.gnt \
    READIDXV14.gnt \
    WRITEIDXV14.gnt \
    READIDXF16.gnt \
    WRITEIDXF16.gnt \
    READSEQF16.gnt  \
    READSEQV.gnt  \
    WRITEBINARY.gnt \
    READRELF16.gnt  \
    WRITESEQF16.gnt \
    WRITESEQV14.gnt \
    WRITERELF16.gnt \
    OPENINPUTEXTEND.gnt \
    OPENLOOP.gnt \
    OPEN2.gnt \
    WRITESEQV4092.gnt \
    READCUSTOMER.gnt \
    NOCLOSE.gnt \

all:	$(GNTS)

APPHOME=$$PWD

#export COBCPY=/newspace/shenhui/wb/bugs/STFILEORA/trf/reload/copy

.SUFFIXES:	.cbl .gnt

ARTEXTFH.gnt: ARTEXTFH.cbl
ifneq "$(COB)" "COBOL-IT"
	cob -ug $*.cbl -C "use($(APPHOME)/opt.dir)" -C "list($*.lst)" -C XREF -C SETTINGS
else
	cobc -std=mf -m -t ./lst -fmf-gnt $<
endif

.cbl.gnt:
ifneq "$(COB)" "COBOL-IT"
	cob -ug $*.cbl -C "use($(APPHOME)/opt.dir)" -C "list($*.lst)" -C XREF -C SETTINGS
else
	cobc -m -g -G -fmf-gnt $*.cbl -fmem-info -Wall -fixed -lcitextfh -t $*.lst -conf=$(APPHOME)/cit.conf
endif

clean:
	-rm -rf c *.lst *.lis *.int *.idy $(GNTS)

## how to run
## cobrun TEST
