//RUNSLEEP JOB  CLASS=2,MSGCLASS=X,MSGLEVEL=(1,1),NOTIFY=&SYSUID
//***************************************************************
//PROCLIB  JCLLIB ORDER=WEIGZHU.TEST.PROCF1
//***************************************************************
//STEP0    EXEC RUNPROC
//SYSPRINT DD SYSOUT=X
//SYSOUT   DD SYSOUT=X
//***************************************************************
//STEP1    EXEC PGM=SLEEPZWG
//STEPLIB  DD DSN=WEIGZHU.TEST.LOAD,DISP=SHR
//SYSPRINT DD SYSOUT=X
//SYSOUT  DD   SYSOUT=X
//***************************************************************
//STEP1    EXEC PGM=NOPGM
//STEPLIB  DD DSN=WEIGZHU.TEST.LOAD,DISP=SHR
//SYSPRINT DD SYSOUT=X
//SYSOUT  DD   SYSOUT=X
//
