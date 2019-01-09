#!/bin/sh
# \
exec expect -- "$0" ${1+"$@"}
# ssh-exec host user password command
# execute command on remote host
exp_version -exit 5.0
set ERR_PERMISSION_DENIED 1
set ERR_DIR_OR_FILE_NOT_EXIST 2
set ERR_TIMEOUT 3
set ERR_CONNECTION_REFUSED 4
set ERR_INVALID_ARGUMENT 5
set autosh "/nfs/users/zhaozhan/autorun"

proc auth_trans {password} {
	upvar #0 ERR_PERMISSION_DENIED ERR_PERMISSION_DENIED
	upvar #0 ERR_DIR_OR_FILE_NOT_EXIST ERR_DIR_OR_FILE_NOT_EXIST
	send "$password\r"
	expect {
		#password not correct
		"Permission denied, please try again." {
		exit $ERR_PERMISSION_DENIED
	}
	# ...transmission goes after...
	-re "Is a directory|No such file or directory" {
	exit $ERR_DIR_OR_FILE_NOT_EXIST
}
-re "KB/s|MB/s" {
set timeout -1
expect eof
}
}
}
proc auth_trans2 {password} {
	upvar #0 ERR_PERMISSION_DENIED ERR_PERMISSION_DENIED
	upvar #0 ERR_DIR_OR_FILE_NOT_EXIST ERR_DIR_OR_FILE_NOT_EXIST
	send "$password\r"
}
proc login_post {password} {
	expect -re "(*$*)|(*>*)"
	send ". /nfs/users/zhaozhan/autorun.sh \r"
	interact
}
if {$argc!=2} {
send_user "usage: remote-exec command password\n"
send_user " command should be quoted.\n"
send_user " Eg. remote-exec \"ssh ls\\; echo done\" password\n"
send_user " or: remote-exec \"scp /local-file :/remote-file\" password\n"
exit $ERR_INVALID_ARGUMENT
}
set cmd [lindex $argv 0]
#set password [lindex $argv 1]
set password $env(MYPWD)
eval spawn $cmd
#timeout in sec, default 10
set timeout 99999999
expect {
#first connect, no public key in ~/.ssh/known_hosts
"Are you sure you want to continue connecting (yes/no)?" {
send "yes\r"
expect "assword:"
auth_trans2 $password
#expect "*$*"
login_post $password
}
#already has public key in ~/.ssh/known_hosts
"assword:" {
auth_trans2 $password
login_post $password
}
#user equivalence already established, no password is necessary
-re "kB/s|MB/s" {
set timeout -1
expect eof
}
-re "Is a directory|No such file or directory" {
expect eof
exit $ERR_DIR_OR_FILE_NOT_EXIST
}
"Connection refused" {
expect eof
exit $ERR_CONNECTION_REFUSED
}
#connetion error
timeout {
send_user "timeout!!!"
exit $ERR_TIMEOUT
}
}
