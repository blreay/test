#!/usr/bin/expect -f
set timeout 30
spawn ssh zhaozhan@bjaix8
expect "password:"
send "Zzy@126.com"
send "\r"
interact
