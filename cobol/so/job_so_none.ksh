#!/usr/bin/ksh
m_JobBegin -j TESTJOB -s START -v 2.0
while true ;
do
       m_PhaseBegin
       case ${CURRENT_LABEL} in
(START)
       m_ProgramExec PGMTEST C
       JUMP_LABEL=STEP1
	;;
(STEP1)
       m_ProgramExec -b PGMTEST aaabbb
       #m_ProgramExec  -b runcso BBBDEEE
       JUMP_LABEL=STEP2
       ;;
(STEP2)
       #m_ProgramExec  -b bsoruncso BBBDEEE
       JUMP_LABEL=END_JOB
       ;;
(END_JOB)
       #m_ProgramExec  -b csorunbso BBBDEEE
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

