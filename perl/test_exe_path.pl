#!/usr/bin/perl

sub TracePrint {
        printf STDERR "($$)";
        printf STDERR @_;
        printf STDERR "\n";
}

TracePrint "process id is  $$";
$a=`which perl`;
TracePrint "result of (which perl) is $a";
TracePrint "run: ls -alrt /proc/$$";
$b=`ls -alrt /proc/$$`;
TracePrint "$b";
