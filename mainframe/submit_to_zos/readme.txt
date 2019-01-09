
Run "01_Submit_job.sh" directly, then the JOB is submitted to mainframe and is executed.

After it it completed, the following files are generated, eg:
RUNSLEEP.jcl.submit     --- The job to be submitted to mainframe.
JOB23963.log            --- The job log
ftp.log                 --- The ftp log
JOB23963.log.summary    --- A simple summary for job log. (eg: job start/end time, and step's rc).

To clean all generated files, execute "00_clean.sh"
