#!/usr/bin/ksh
m_JobBegin -j TESTJOB -s START -v 2.0
while true ;
do
       m_PhaseBegin
       case ${CURRENT_LABEL} in
(START)
	env >/tmp/1.1
	m_FileDelete /tmp/22.out
	m_FileAssign -d SHR,KEEP,KEEP SYSIN /tmp/22.in
#m_FileAssign -d NEW,KEEP,KEEP SYSOUT /tmp/22.out
       m_ProgramExec indd_outdd
	env >/tmp/1.2
       JUMP_LABEL=STEP1
	;;
(STEP1)
       #m_ProgramExec -b PGMTEST aaabbb
       #m_ProgramExec  -b runcso BBBDEEE
	m_FileDelete /tmp/23.out
	m_FileAssign -i SYSIN
7777777777777777
_end
	m_FileAssign -d NEW,KEEP,KEEP SYSOUT /tmp/23.out
       m_ProgramExec indd_outdd
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

