## This gdb script is used to run a program continuously until 
## segfalut occured, it make gdb stop so that you can interact 
## with gdb to do debug 

set pagination off
set breakpoint pending on
set logging file gdb.log
set logging overwrite
set logging on

#load program
start

# maybe some program doesn't link exit, it may link _exit()
break exit
continue

# record the nomal end point
set $end=$pc

run
while 1
	if $pc != $end
		echo "program stoped, but it doesnot reach the normal end point"
		# following statement make gdb stop there
		this_is_a_invalid_func
	end
	shell sleep $(($RANDOM % 2))
	run
end
