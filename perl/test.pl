my $path="/tmp";
opendir(TEMPDIR, $path) or die "can't open it:$!";
#my @dir = grep -f, readdir TEMPDIR; 
my @dir = readdir TEMPDIR; 
print join "\n",@dir;
close TEMPDIR;
