my $path="/tmp";
my @a=("1\n", "", "2\n", "\n","3\n");
my $str="";
print $#a;
my @b=();
my $Lig="1a2a3aa5a";

my $Lig2="\n\n"; 
my @JCLEX2 = split /\n/, $Lig2; 
print "count of JCLEX2=$#JCLEX2\n";
foreach my $str (@JCLEX2) {
	print "onlynewline<$str> $#JCLEX2\n";
}
my $Lig1="1\n2\n3\n\n5\n";
my @JCLEX = split /\n/, $Lig1; 
open(FILEIN,"sysin") or die $!;
my @JCL=<FILEIN>;
while (my $str = shift @JCL) {
#while ($str = shift @JCLEX ) {
	print "sysin<$str> $#JCL\n";
}

print "all=".join("-",@JCLEX)."\n";
foreach my $str (@JCLEX) {
#while (my $str = shift @JCLEX || $#JCLEX != -1) {
#while ($str = shift @JCLEX ) {
	print "aa<$str> $#JCLEX\n";
}
while (my $str = shift @JCLEX || $#JCLEX != -1) {
#while ($str = shift @JCLEX ) {
	print "<$str> $#JCLEX\n";
}
print "b=$#b";
#exit;
while ($str = shift @a || $#a != -1) {
	print $str;
}
