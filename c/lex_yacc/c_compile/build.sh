bison -d lexya_e.y
flex -d lexya_e.l
gcc -g -o parser lex.yy.c lexya_e.tab.c parser.c
#gcc -g -o parser lexya_e.tab.c parser.c
./parser < input
