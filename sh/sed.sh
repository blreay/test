#!/bin/ksh

function getword {
sed '
s/^.*-f \{1\}\([^ ]\{1,\}\) \{0\}.*$/\1/g
t
d
'
}

echo "EJR -f aaa" | getword
echo "EJR -f \"bb\"" | getword
echo "EJR" | getword
exit 0

cat - > /tmp/sed.tmp <<EOF
/-j /{s/^.*-j \{1\}\([0-9]\{8\}\) \{1\}.*$/\1/g};/[0-9]\{8\}/{p};/[0-9]\{8\}/!{d;p};
EOF

echo "a -j 123 c" | sed -n -f /tmp/sed.tmp
echo "a 123 c" | sed -n -f /tmp/sed.tmp
echo "a -j 12345678 hc" | sed -n -f /tmp/sed.tmp

echo "EJR -j 00000000 -m jes" | sed -n '/-j /{s/^.*-j \{1\}\([0-9]\{8\}\) \{1\}.*$/\1/g};/[0-9]\{8\}/{p};/[0-9]\{8\}/!{d};'
echo "EJR -j 00000002 -m jes" | sed '/-j /{s/^.*-j \{1\}\([0-9]\{8\}\) \{1\}.*$/\1/g};/[0-9]\{8\}/!{d};'
echo "EJR -j 0000003 -m jes" | sed '/-j /{s/^.*-j \{1\}\([0-9]\{8\}\) \{1\}.*$/\1/g};/[0-9]\{8\}/!{d};'
echo "EJR -j 0000001 -m jes" | sed '/-j /{s/^.*-j \{1\}\([0-9]\{8\}\) \{1\}.*$/\1/g};/[0-9]\{8\}/{p};/[0-9]\{8\}/!{d};'
echo "EJR -j 00000005 -m jes" | sed 's/^.*-j \{1\}\([0-9]\{8\}\) \{1\}.*$/\1/g;/[0-9]\{8\}/!{d};'
echo "EJR -j 0000006 -m jes" | sed 's/^.*-j \{1\}\([0-9]\{8\}\) \{1\}.*$/\1/g;/[0-9]\{8\}/!{d};'

## observe the count changement in log
cat 1 | sed -n ':begin; /count=11/{/count=1$/{p}; /count=11.*count=/{s/.*count=11.*\([0-9]\{8\} [0-9]\{6\} count=.*$\)/\1/g}; $!{N; b begin}}'
cat 1 | sed -n '/count=11/{N;N;N;N;N;N;/count=1$/p}'

