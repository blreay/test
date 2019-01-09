#!/usr/bin/ksh
#@(#)---------------------------------------------------------------------------------------------
#@(#)-                                                                                           -
#@(#)- SCRIPT NAME    ==  FDMSIXM.ksh                       --- VERSION DU 18/12/2014 14:36
#@(#)-                                                                                           -
#@(#)- AUTHOR         ==                                                                         -
#@(#)-                                                                                           -
#@(#)- TREATMENT      ==                                                                         -
#@(#)-                                                                                           -
#@(#)-                                                                                           -
#@(#)- OBSERVATIONS   ==  MAINFRAME MIGRATION                                                    -
#@(#)-                                                                                           -
#@(#)-                                                                                           -
#@(#)---------------------------------------------------------------------------------------------
#@(#)- NDLR         ==                                                                           -
#@(#)-              ==                                                                           -
#@(#)-              ==                                                                           -
#@(#)- ..                                                                                        -
#@(#)-                                                                                           -
#@(#)-                                                                                           -
#@(#)-                                                                                           -
#@(#)-                                                                                           -
#@(#)---------------------------------------------------------------------------------------------
m_JobBegin -j TEDIT2F -s START -v 2.0 -c C
while true ;
do
       m_PhaseBegin
       case ${CURRENT_LABEL} in
(START)
#                                                                              
        JUMP_LABEL=HDRUPD
       ;;
(HDRUPD)
# ----------------------------------------------------------------------
#                     UPDATE HEADER MASTER FILE
# ----------------------------------------------------------------------
#
       m_OutputAssign -c "*" SYSOUT
       #m_FileAssign -d SHR IN1 ${DATA}/OFM.HAS.FDMSV3P0.FARS0200.N2.OHEADER
       m_FileAssign -d MOD IN1 ${DATA}/OFM.HAS.FDMSV3P0.FARS0200.N2.OHEADER
       #m_FileAssign -d OLD,KEEP,KEEP IN2 ${TMP}/SFHDTRAN_FDMEDIT2_24871               
       m_FileAssign -d MOD,KEEP,KEEP IN2 ${TMP}/SFHDTRAN_FDMEDIT2_24871               
#       m_FileAssign -d OLD,KEEP,KEEP IN2 ${TMP}/EDIT2_TRANS_SPLITaa                   
       #m_FileAssign -d SHR IN3 ${DATA}/OFM.HAS.FDMSV3P0.LICPDS.PARMLIB/PHSSFDTH
       m_FileAssign -d MOD IN3 ${DATA}/OFM.HAS.FDMSV3P0.LICPDS.PARMLIB/PHSSFDTH
       m_FileAssign -d MOD,KEEP OUT1 ${DATA}/OFM.HAS.FDMSV3P0.FARS0200.N2.NHEADER
       m_FileAssign -d MOD,KEEP,KEEP OUT2 ${TMP}/ERTRANS_FDMEDIT2_24871                
       m_FileAssign -d NEW,KEEP,KEEP -r 128 -t LSEQ OUT3 ${TMP}/HCHGS_${MT_JOB_NAME}_${MT_JOB_PID}
       m_OutputAssign -c "*" PRINTR1
		bash --noprofile --norc
       #m_ProgramExec BDMS0201 "080115Y"

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
#@(#)---------------------------------------------------------------------------------------------

