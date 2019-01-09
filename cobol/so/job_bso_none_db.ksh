#!/usr/bin/ksh
m_JobBegin -j TESTJOB -s START -v 2.0
while true ;
do
       m_PhaseBegin
       case ${CURRENT_LABEL} in
(START)
       JUMP_LABEL=STEP1
	;;
(STEP1)
       m_ProgramExec -b cblopedb BBBDEEE
       JUMP_LABEL=STEP2
       ;;
(STEP2)
       #m_ProgramExec  csorunbso BBBDEEE
       JUMP_LABEL=END_JOB
       ;;
(END_JOB)
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

