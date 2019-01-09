EXEs := $(patsubst %.go,%,$(wildcard *.go))

all:	$(EXEs)

%:%.go
	go build $<

clean:
	/bin/rm -f $(EXEs) core.* 1 2

run:
	for i in 0 1 2 crash; do echo "--------$$i----------"; GOTRACEBACK=$$i ./coredump; done > 1 2>&1; vim 1
