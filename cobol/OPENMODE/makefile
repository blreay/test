GNTS =   \
    READINTERACT.gnt \
    WRITEIDXV14.gnt \

all:	$(GNTS)

APPHOME=./

.SUFFIXES:	.cbl .gnt

.cbl.gnt:
ifneq "$(COB)" "COBOL-IT"
	cob -ug $*.cbl -C "use($(APPHOME)/opt.dir)" -C "list($*.lst)" -C XREF -C SETTINGS
else
	cobc -m -g -G -fmf-gnt $*.cbl -Wall -fixed -lcitextfh -t $*.lst -conf=$(APPHOME)/cit.conf
#	cobc -m -g -G -fautolock -fmf-gnt $*.cbl -Wall -fixed -lcitextfh -t $*.lst -conf=$(APPHOME)/cit.conf
#	cobc -m -g -G -fmanuallock -fmf-gnt $*.cbl -Wall -fixed -lcitextfh -t $*.lst -conf=$(APPHOME)/cit.conf
endif

clean:
	-rm -rf c *.lst *.lis *.int *.idy $(GNTS)



## how to run
## cobrun TEST
