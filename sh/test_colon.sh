#!/bin/pdksh

: echo "start"

#set the default value: i can't understand it
: ${a:=yes}

#who make no sense??
: ${b:-yes}
: ${c:+yes}

echo a=$a
echo b=$b
echo c=$c

# comment out a source code block
: '
echo aaaaaaaaaaaaaaaaaa
echo bbbbbbbbbbbbbbbbbb
'

: <<-EOF
echo aaaaaaaaaaaaaaaaaa
echo bbbbbbbbbbbbbbbbbb
EOF
