#!/usr/bin/python
import sys
import re

helpinfo = ("========Ver: 1.0==========",
            "Usage:",
            "       Two parameters are necessary: filepath jobname",
            "       filepath: specify the JOB File",
            "       jobname : a new job name (8 characters at most)")


if (3 <> len(sys.argv)):
   for line in helpinfo:
       print line
   sys.exit()


if (8 < len(sys.argv[2])):
   print "Err: the value for jobname is too long!"
   for line in helpinfo:
       print line
   sys.exit()

try:
   inF = open (sys.argv[1])
except IOError:
   print "Err: Fail to operate input file: ", sys.argv[1], "!"
   sys.exit()   

target_file = ''.join ( [sys.argv[1], '.submit'] )

try:
   outF = open (target_file, 'w')
except IOError:
   print "Err: Fail to operate output file: ", sys.argv[2], "!"
   inF.close() # close the input file
   sys.exit()   


r_comment = re.compile('^\/\/\*')
r_job_match = re.compile('^\/\/(\w+)(\s+JOB)\s+')
r_job_replace = re.compile('^\/\/\w+')
r_job_continue_match = re.compile(',\s*$')


comment_str='//*******************************************************'
hold_str   ='//HOLD     OUTPUT JESDS=ALL,DEFAULT=Y,OUTDISP=(HOLD,HOLD)'

flag_job_done = 'N'  # N: not done, Y: done
flag_job_end = 'N'

try:
   for line in inF:
       line = line[0:(len(line)-1)]  # remove the last '\n'
       if not r_comment.match(line): # skip comment line

         if 'N' == flag_job_done :
            # cut off the data beyond col:72
            if 72 < len(line):
               line = line[0:71]
            # process the JOB statement
            r1 = r_job_match.match(line)
            if r1 :
               line = r_job_replace.sub(''.join(['//',sys.argv[2]]),line) 
               flag_job_done = 'Y'  # set flag.

         if 'N' == flag_job_end :
            # cut off the data beyond col:72
            if 72 < len(line):
               line = line[0:71]
            # .match does NOT work, do NOT know why??? Have to use .search!!!
            r1 = r_job_continue_match.search(line)
            if not r1 :
               # add new line
               delimiter = '\n'
               line_list = [ line, comment_str, hold_str, comment_str]
               line = delimiter.join(line_list)
               flag_job_end = 'Y' # set flag.
             
       outF.write(line)
       outF.write('\n') # add the last '\n'

finally:
   inF.close()
   outF.close()
