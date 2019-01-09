memleak: memleak.c 
	gcc -g $< -o $@

mtracetest: mtracetest.c
	gcc -g $< -o $@

all: memleak mtracetest

clean:
	rm -f memleak

run:
	./mtracetest
