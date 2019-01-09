all: basic sscanf test_sscanf

basic: basic.c
	gcc -g -o $@ $<

test_sscanf: test_sscanf.c
	gcc -g -o $@ $<

sscanf: sscanf.c
	gcc -g -o $@ $<

clean:
	rm -f *.o basic sscanf

test:basic
	#./basic "^[[:space:]]*m_JobBegin" < in.txt
	./basic "[[:space:]]*m_JobBegin[[:space:]]+([[:alnum:]]+)([[:space:]]+([0-9]+))*" < in.txt

testsscanf:sscanf
	./sscanf < in2.txt |grep Result

run:test_sscanf
	./test_sscanf
