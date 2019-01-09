#@(#)---------------------------------------------------------------------------------------------
#@(#)- SYSIN IN ARTIBMP issue                                                                    -
#@(#)---------------------------------------------------------------------------------------------
m_JobBegin -j TSTBATCH -s STEP001 -v 2.0
print "MT_KSH=${MT_KSH}"
while true ;
do
       m_PhaseBegin
       case ${CURRENT_LABEL} in
(STEP001)
       m_OutputAssign -c "*" SYSPRINT
       m_OutputAssign -c "*" SYSOUT
       m_OutputAssign -c "*" LOGUSR
       m_ProgramExec -b TSTCPGM
       JUMP_LABEL=END_JOB
       ;;
(STEP002)
       m_OutputAssign -c "*" SYSPRINT
       m_OutputAssign -c "*" SYSOUT
       m_OutputAssign -c "*" LOGUSR
       m_FileAssign -i SYSIN
STEP002 LINE 3
STEP002 LINE 4
_end
       m_ProgramExec -b -n TSTBATC2
       JUMP_LABEL=END_JOB
       ;;

(END_JOB)
       break
       ;;
(*)
       m_RcSet ${MT_RC_ABORT:-S999} "Label inconnu : ${CURRENT_LABEL}"
       break
       ;;
esac
m_PhaseEnd
done
m_JobEnd
#@(#)---------------------------------------------------------------------------------------------

