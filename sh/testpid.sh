#/bin/pdksh

#set -vx

function f1 {
echo "in f1"
sleep 100
echo "out f1"
}
echo "pid=$$"
b=1;
#a=$({ { echo "b=$b";  b=2; sleep 5; }; b=3; sleep 5; }; )
#c=$({ { echo "b=$b";  b=2; echo "L1"; ps -ef|grep testpid; sleep 20; }; b=3; sleep 1; echo "L2"; ps -ef|grep testpid; })
f1
c=$({ { echo "b=$b";  b=2; echo "L1:$$"; ps -ef|grep testpid; sleep 2; } | awk '{print $0}'; })
#c=$(sleep 20)
#c=$({ sleep 10; b=3; echo "$$,">pid; }; echo "$$,"; cat pid)
#({ echo "in child"; sleep 10; b=3; eval echo "\$\$,"; }; eval echo "\$\$,"; )
echo "02 b=$b"
echo "02 c=$c"

