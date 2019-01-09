#!/usr/bin/perl
use strict;
use Data::Dumper;

my $JCLLIB           = "";
my $G_DEBUG          = $ENV{'MT_ICETOOL_DEBUG'};
my $G_OPE_SELECT     = "SELECT";

######## MAIN ########
{
	my ( $filepathTOOLIN ) = @ARGV;
	my %hash_test;
	open(FILE_TO, "> /aaa") || die("Could not open /aaa $!\n") && exit 900;};		
	
	debug_dump_Obj(\%hash_test, "aa", "++++++++++++++", "++++++++++++");
	exit 0;
}

sub debug_dump_Obj {
	#return if ($G_DEBUG ne "yes");
	my ($myhash, $mysuffix, $myheader, $myfooter ) = @_;
	
	my $objtype=ref($myhash);
	if ("" ne $myheader) { print STDERR "#$mysuffix: $myheader [$objtype]\n";}
	if ($objtype eq "HASH") {
		for my $k (keys %$myhash) {
			my $v=${$myhash}{$k};
			print STDERR "#$mysuffix: $k--->$v\n";
			for (ref($v)){
				if (/HASH/)     { debug_dump_Obj(\%$v, $mysuffix.": $k--->$v", "", "")}
				elsif (/ARRAY/) { debug_dump_Obj(\@$v, $mysuffix.": $k--->$v", "", "")}
				else {};
			}
		}
	} elsif ($objtype eq "ARRAY") {
		foreach my $var1 (@{$myhash}) {
			print STDERR "#$mysuffix: $var1\n";
			for (ref($var1)){
				if (/HASH/)     { debug_dump_Obj(\%$var1, $mysuffix.": $var1", "", "")}
				elsif (/ARRAY/) { debug_dump_Obj(\@$var1, $mysuffix.": $var1", "", "")}
				else {};
			}
		};
	}
	if ("" ne $myfooter) { print STDERR "#$mysuffix: $myfooter [$objtype]\n"; }
}
