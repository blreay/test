#!/usr/bin/perl

use strict;
use warnings;
 
my $data = <<EOF;
aaa
bbb
ccc
EOF
$data =~ s/\n/<BR>/g;
print $data;

print "\n";
my $a="123abc456\n777888"; 
$a=~ s/^(123)(.*)\n/\1<font color=aa>\2<\/font>\n/g; 
print "$a\n";
