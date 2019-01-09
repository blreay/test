$str1="loadtables-00a.kshabb.ksh";
@lastLabel =$str1=~/^loadtables-(.*).ksh$/i;
#print "$lastLabel:$1\n";
print "@lastLabel[1]\n";
