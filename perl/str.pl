
my $wVal="SYSUT1 ${DATA}/../trf-jcl/JCL/GENQSAM.ksh";
my ( $Fsn, $Dsn ) = $wVal =~ /([^,-\s]+)\s+([^,-\s]+)\s*(<<.*|\#.*|)$/;
printf "wVal=$wVal;(Fsn=$Fsn, Dsn=$Dsn)\n";

my ( $Fsn, $Dsn ) = $wVal =~ /([^,-\s]+)\s+([^,-\s]+)\s*$/;
printf "wVal=$wVal;(Fsn=$Fsn, Dsn=$Dsn)\n";

my ( $Fsn, $Dsn ) = $wVal =~ /([^,-\s]+)\s+([^,-\s]+)\s*/;
printf "wVal=$wVal;(Fsn=$Fsn, Dsn=$Dsn)\n";

my ( $Fsn, $Dsn ) = $wVal =~ /([^,-\s]+)\s+([^,-\s]+)\s$/;
printf "wVal=$wVal;(Fsn=$Fsn, Dsn=$Dsn)\n";
