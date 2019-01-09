gcc -ggdb -O -c -DMAIN testNFS.c -o testNFS.o
gcc testNFS.o -o testNFS
scp testNFS nfs.sh zhaozhan@bjlinux34:/testarea/zhaozhan/art/install/art11gR1/Batch_RT/sample/simpjob
scp testNFS nfs.sh zhaozhan@bjlinux16:/testarea/zhaozhan/art/install/art11gR1/Batch_RT/sample/simpjob
scp testNFS nfs.sh zhaozhan@bej301184:/testarea/zhaozhan/art/install/art11gR1/Batch_RT/sample/simpjob
