rm -rf idea.o artencrypt
gcc -c idea.c  -o idea.o
gcc -g artencrypt.c idea.o -o artencrypt
