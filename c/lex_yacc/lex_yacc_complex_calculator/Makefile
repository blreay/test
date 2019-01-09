LEX=flex
YACC=bison
CC=g++
OBJECT=main

$(OBJECT): yacc.cpp lex.c
	#$(CC) lex.yy.o yacc.tab.o -o $(OBJECT)
	$(CC) -o $@ $<
	@./$(OBJECT)

lex.yy.o: lex.yy.c  yacc.tab.h  main.h
	$(CC) -c lex.yy.c

yacc.tab.o: yacc.tab.c  main.h
	$(CC) -c yacc.tab.c

yacc.c: yacc.y
	$(YACC) -o $@ -d yacc.y
yacc.cpp: yacc.c
	mv $< $@

lex.c: lex.l
	$(LEX)  -o $@ $<

clean:
	@rm -f $(OBJECT)  *.o yacc.cpp lex.c yacc.c yacc.h
