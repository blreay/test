#!/usr/bin/perl
use strict;
use Data::Dumper;

my %HoH = (
flintstones => {
husband => "fred",
pal => "barney",
},
jetsons => {
husbands => "george",
wife => "jane",
"his boy" =>"elroy",
},
simpsons => {
husband => "homer",
wife => "marge",
kid => {
	a => "aa",
	b => "bb",
	c => "cc",
},
},
);

debug_dump_hash(\%HoH);
print STDERR "****************************************\n";
debug_dump_hash($HoH{"simpsons"});

my $ref=$HoH{"simpsons"};
print STDERR "****************************************\n";
print STDERR ref($ref);
debug_dump_hash($ref);

my $ref2=$HoH{"simpsons"}{"kid"};
print STDERR "****************************************\n";
print STDERR ref($ref2);
debug_dump_hash($ref2);

my $ref3=$HoH{"simpsons"}{"kid"};
my $ref4=$HoH{"jetsons"};
print STDERR "****************************************\n";
print STDERR ref($ref3);
$ref4->{"zzy"} = ( $ref3 );
debug_dump_hash($ref4);

sub debug_dump_hash {                                                                 
    my ($myhash, $mysuffix, $myheader, $myfooter ) = @_;                              
    if ("" ne $myheader) { print STDERR "#$mysuffix: $myheader\n";}                   
    for my $k (keys %$myhash) {                                                       
        my $v=${$myhash}{$k};                                                         
        print STDERR "#$mysuffix: $k--->$v\n";                                        
        for (ref($v)){                                                                
            if (/HASH/)     { debug_dump_hash(\%$v, $mysuffix.": $k--->$v", "", "")}  
            elsif (/ARRAY/) { debug_dump_array(\@$v, $mysuffix.": $k--->$v", "", "")} 
            else {};                                                                  
        }                                                                             
    }                                                                                 
    if ("" ne $myfooter) { print STDERR "#$mysuffix: $myfooter\n"; }                  
}                                                                                     
