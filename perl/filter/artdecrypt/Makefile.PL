use ExtUtils::MakeMaker;

WriteMakefile(
	NAME      => 'Filter::artdecrypt',
	VERSION_FROM   => 'artdecrypt.pm',

	# The line below disables both the dynamic link test and the
	# test for DEBUGGING.
	# It is only enabled here to allow the decrypt test harness
	# to run without having to build statically.
	DEFINE	  => "-DBYPASS",
	MYEXTLIB => "idea.o",
);
