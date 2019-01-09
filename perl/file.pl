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
	open(FILE_TO, "> aaa") || die("Could not open /aaa $!\n") && exit 900;		
	print FILE_TO "aaa";
	close(FILE_TO);
	exit 0;
}
