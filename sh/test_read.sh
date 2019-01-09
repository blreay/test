#!/bin/pdksh

#set -vx

printf aa > in1
while read line; do
  #e=$lineval echo $$line >> /tmp/2
	echo aaa
	eval echo "\"$line\""
done < in1

echo aa > in
while read line; do
	echo bbb
	eval echo "\"$line\""
done < in

while read line; do
  #e=$lineval echo $$line >> /tmp/2
	echo aaa
	eval echo "\"$line\"" 
done <<-EOF
SORT FIELDS=(1,2,A,5,3,A),FORMAT=BI
EOF
