#!/bin/sh
user="WEIGZHU"
passwd="WEIGZHU"
machine="wasa.us.oracle.com"
job_file="${job_file:-RUNSLEEP.jcl}"
job_name="WEIGZHUZ"


######################################
#new_job_file="${job_file}.submit"
wait_time=5 # sleep time for each check, this is used for waiting the end of the job.
job_id_prompt="Hi, job_id is" # this is used in ftp script.
job_id=""
ftp_log="ftp.log"
new_job_file="${job_file}.submit"

./00_clean.sh

# generate new job file
python  02_job_modify.py ${job_file}  ${job_name}

# submit the job and get back job log
./03_ftp_expect.exp  "$user" "$passwd" "$machine" "$new_job_file" "$job_name" "$job_id_prompt" "$wait_time"  > "$ftp_log"

# get the job id.

while read line
do
  job_id="$line"
  break
done <<- EOF
`grep "$job_id_prompt" "$ftp_log" | awk -F":" '{print $2}'`
EOF

./04_job_summary.sh "$job_id.log"  "$job_name"  "$job_id"


