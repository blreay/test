#!/usr/bin/ksh
m_JobBegin -j TESTJOB -s START -v 2.0
while true ;
do
       m_PhaseBegin
       case ${CURRENT_LABEL} in
(START)
       m_ProgramExec -b STOPRUN aaaa
       JUMP_LABEL=END_JOB2
###############################################
	;;
(END_JOB2)
       break
       ;;
(*)
       m_RcSet ${MT_RC_ABORT:-S999} "Unknown label : ${CURRENT_LABEL}"
       break
       ;;
esac
m_PhaseEnd
done
m_JobEnd

