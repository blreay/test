#gcc -O -c -DMAIN mi_ConcurrentAccessManagement.c -o mi_ConcurrentAccessManagement.o
gcc -O -c -DCLEAN_LOCK_MAIN mi_ConcurrentAccessManagement.c -o mi_ConcurrentAccessManagement.o
gcc mi_ConcurrentAccessManagement.o -o artjescleanlock
cp artjescleanlock ../../bin
#scp mi_ConcurrentAccessManagement tuxqa@bjlinux12:/testarea/zhaozhan/art/install/art11gR1/Batch_RT/ejr/COMMON
if [[ $1 == "1" ]]; then
scp artjescleanlock zhaozhan@bej301184:/testarea/zhaozhan/art/install/art11gR1/Batch_RT/bin
scp artjescleanlock zhaozhan@bjlinux34:/testarea/zhaozhan/art/install/art11gR1/Batch_RT/bin
scp artjescleanlock zhaozhan@bej301358:/testarea/zhaozhan/art/install/art11gR1/Batch_RT/bin
scp artjescleanlock zhaozhan@bej301359:/testarea/zhaozhan/art/install/art11gR1/Batch_RT/bin
fi
