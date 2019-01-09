LEX=flex
YACC=bison
CC=gcc
OBJECT=mycc
####################################
run: $(OBJECT)
	@./$(OBJECT)

$(OBJECT): lex.yy.c  y.tab.c
	$(CC) y.tab.c -ll -o $@

y.tab.c: c.y
	#$(YACC) -o $@ -dv $< 
	$(YACC) -o $@ -dv $< 

lex.yy.c:c.l
	#$(LEX) -o $@ -d $<
	$(LEX) -o $@  -d $<

clean:
	@rm -f $(OBJECT)  *.o c.tab.c  lex.yy.c  y.tab.c y.tab.h y.output c.output c.tab.h

