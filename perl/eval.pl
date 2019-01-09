#!/usr/bin/perl
use strict;
use Data::Dumper;

my $a="b";
my $c="a";
my $t;
my $i=1;
my $z_1="0";

eval '$t=$'."$c";
print "t=$t\n";

eval '$z_'."$i=\"aaa\"";
print "z_1=$z_1\n";
