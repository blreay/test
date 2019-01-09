#!/bin/sh
# Three parameters are necessary for this script
# 1. File name for JOB log.
# 2. JOB name.
# 3. JOB ID.

# Result:
# Given the file name for JOB log is JOB12345.log
# Gererate a summary with name as: "JOB12345.log.summary"

# not check the input parameters yet.

JOB_log="$1"
JOB_name="$2"
JOB_ID="$3"

summary_file="${JOB_log}.summary"

rm -f "${summary_file}"

echo "Input param: job log: $JOB_log, job name: $JOB_name, job id: $JOB_ID."

if [[ ! -f "${JOB_log}" ]]; then
   echo "Err: ${JOB_log} is NOT a file"
fi

# Get start/end time for JOB

echo "JOB START TIME:" `grep "${JOB_name} \- STARTED \- TIME"  "${JOB_log}" |  awk '{print $8}' | awk -F"=" '{print $2}'` > "${summary_file}"

echo "JOB END   TIME:" `grep "${JOB_name} \- ENDED \- TIME"  "${JOB_log}" |  awk '{print $8}' | awk -F"=" '{print $2}'` >> "${summary_file}"

echo "" >> "${summary_file}"


# Get Step RC

while read line 
do
   echo "${line}" >>  "${summary_file}"
   break
done <<- EOF
`grep "${JOB_ID}  \-JOBNAME  STEPNAME PROCSTEP" "${JOB_log}"` 
EOF

while read line 
do
   echo "${line}" >>  "${summary_file}"
done <<- EOF1
`grep "${JOB_ID}  \-${JOB_name}" "${JOB_log}"| grep -v "${JOB_ID}  \-${JOB_name} ENDED" `
EOF1


# the following version could NOT get the "step name and proc step name".
#while read line
#do
#   echo "STEP INFO: ${line}" >>  "${summary_file}"
#done <<- EOF
#`grep "${JOB_ID}  \-${JOB_name}" "${JOB_log}"| grep -v "${JOB_ID}  \-${JOB_name} ENDED" | awk '{print $4"  "$5}'`
#EOF
