GNTS =   \
     hello.gnt \
     user.gnt \
     userabend.gnt \
     ILBOABNO.gnt \
	 GENABEND.gnt

all:	$(GNTS)

APPHOME=$$PWD

.SUFFIXES:	.cbl .gnt

.cbl.gnt:
ifneq "$(COBOL_COMPILER)" "COBOL-IT"
	cob -ug $*.cbl -C "use($(APPHOME)/opt.dir)" -C "list($*.lst)" -C XREF -C SETTINGS
else
	cobc -m -g -G -fmf-gnt $*.cbl -Wall -fixed -lcitextfh -t $*.lst -conf=$(APPHOME)/cit.conf
endif

clean:
	-rm -rf c *.lst *.lis *.int *.idy *.gnt
