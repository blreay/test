LEX=flex
YACC=bison
CC=gcc -g
OBJECT=parser
####################################
run: $(OBJECT)
#	@echo "step1=zzysubmit(\"bbbb\"); step2=zzysubmit(\"ccc\"); step3=(step1.job.rc==1?zzysubmit(\"ddd\"));" | ./$(OBJECT)
	#@echo "step1=submit(\"bbbb\"); step2=( submit(\"ccc\")); " | ./$(OBJECT)
	#echo "step1=submit(\"bbbb\"); step2=(submit(\"ccc\")); step3=(step1.job.rc==1?zzysubmit(\"ddd\"));" | ./$(OBJECT)
	#echo "step1.job.rc=1; step3=(step1.job.rc==1?submit(\"ddd\"):submit(\"ccc\"));" | ./$(OBJECT)
	#echo "step1.job.rc=1; step3=(step1.job.rc==1?submit(\"ddd\"):submit(\"ccc\"));" | ./$(OBJECT)
	#echo "a=submit(\"bbb\"); b=(submit(\"ccc\")); " | ./$(OBJECT)
	#echo "step1.job.jobid=199; print(step1.job.jobid); step3=(step1.job.jobid==198?submit(\"ddd\"):submit(\"ccc\"));" | ./$(OBJECT)
	#echo "step1=submit(\"aaa\"); print(step1.job.rc);" | ./$(OBJECT)
	#echo "step1=submit(\"aaa\"); print(step1.job.rc); step2=submit(\"eee\");step3=(step1.job.rc!=198?submit(\"ddd\"):submit(\"ccc\"));print(step2.job.rc);print(step1.job.rc);print(step3.job.rc);" | ./$(OBJECT)
	#echo "a=199; print(a);" | ./$(OBJECT)
	cat inputjes | ./$(OBJECT)

$(OBJECT): lexya_e.tab.o lex.yy.o parser.o prntree.o
	$(CC) -o $@ $^

lexya_e.tab.c lexya_e.tab.h: lexya_e.y
	$(YACC) -o $@ -d $< 

lex.yy.c: lexya_e.l
	$(LEX) -o $@ -d $<

clean:
	@rm -f $(OBJECT)  *.o yacc.tab.* lex.yy.* lexya_e.tab.* core.*

