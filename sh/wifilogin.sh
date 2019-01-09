#!/bin/bash

typeset txturl="https://gmp.oracle.com/captcha/files/airespace_pwd_apac.txt"
typeset myusername="zhaoyong.zhang@oracle.com"
typeset mypwd="AQG9aPQG001"
typeset cookiefn=mycookie
typeset useragent="Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.97 Safari/537.36"
#typeset useragent="Mozilla/5.0 aaa"
typeset curlcmd="curl -v -L -A \"${useragent}\" --insecure -c $cookiefn -b $cookiefn "

#############################
## First page, return the auto submit page
set -vx
rm -f $cookiefn 1 2 3 4 5 6
echo $curlcmd
eval ${curlcmd} $txturl -o 1
#exit 1

############################
cat 1 | sed 's/</\n</g' > 2
cat 2 | awk -F "\"" '/input.*name=/ {print $4"="$6 }' | tr "\n" "&" > 3
#cat 2 | awk -F "\"" '/input.*name=/ {print $4"="$6 }' | tr "\n" ";" > 3
formdata1=$(cat 3| sed 's/&$//g')
echo "formdata1=[$formdata1]"

##submit auto submit page, return the real login page
set -vx
eval $curlcmd -d \"${formdata1}\" https://login.oracle.com/mysso/signon.jsp -o 4
#exit 1
cat 4 | awk -F "\"" '/input.*name=/ {print $4"="$6 }' | tr "\n" "&" > 5

formdata2=$(cat 5| sed 's/&$//g')
echo "formdata2=[$formdata2]"

############################
cat 4 |grep "name="| egrep -v "(<meta|<form)" | awk '{match($0,/name="[^"]*"/); s = substr($0,RSTART, RLENGTH); gsub(/["]/, "", s); print s}' > name
cat 4 |grep "value="| egrep -v "(<meta|<form)" | awk '{match($0,/value="[^"]*"/); s = substr($0,RSTART, RLENGTH); gsub(/["]/, "", s); print s}' > value
cat name | wc -l
cat value | wc -l
formdata3=""
for i in $(seq 7); do
	typeset n1=$(cat name| awk -F "=" 'NR=='"$i"'{print $2}')
	typeset n2=$(cat value| awk -F "=" 'NR=='"$i"'{print $2}')
	[[ $n1 == "ssousername" ]] && n2="$myusername"
	[[ $n1 == "password" ]] && n2="$mypwd"
	n22="$(php -r "echo rawurlencode('$n2');")"
	formdata3="${formdata3}&${n1}=${n22}"
done
echo "formdata3=$formdata3" | tee d3

###!!!!! important: following is the full format, maybe will be used in the future !!!!
##******************************************
#eval $curlcmd --data-binary \"${formdata3#&}\" -H \'Origin: https://login.oracle.com\' -H \'Accept-Encoding: gzip, deflate\' -H \'Accept-Language: en-US,en\;q=0.8,zh-CN\;q=0.6,zh\;q=0.4\' -H \'Upgrade-Insecure-Requests: 1\' -H \'User-Agent: Mozilla/5.0 \(Windows NT 6.1\; WOW64\) AppleWebKit/537.36 \(KHTML, like Gecko\) Chrome/48.0.2564.97 Safari/537.36\' -H \'Content-Type: application/x-www-form-urlencoded\' -H \'Accept: text/html,application/xhtml+xml,application/xml\;q=0.9,image/webp,*/*\;q=0.8\' -H \'Cache-Control: max-age=0\' -H \'Referer: https://login.oracle.com/mysso/signon.jsp\' -H \'Connection: keep-alive\' https://login.oracle.com/oam/server/sso/auth_cred_submit -o 6
##******************************************
eval $curlcmd --data-binary \"${formdata3#&}\"  https://login.oracle.com/oam/server/sso/auth_cred_submit -o 6

cat 6
