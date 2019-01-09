my $rdo_src_dir="/tmp/aaa";
print "hello\n"  if -d $rdo_src_dir && (<$rdo_src_dir/*>);

