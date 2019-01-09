        IDENTIFICATION DIVISION.
        PROGRAM-ID. DSPMSG.
        AUTHOR. TUXEDO DEVELOPMENT.
        ENVIRONMENT DIVISION.
        CONFIGURATION SECTION.
        DATA DIVISION.
        WORKING-STORAGE SECTION.

      **=============================================================**
      * Log messages definitions
      **=============================================================**
        01  LOGQUEUE PIC X(8) VALUE "LOGQ    ".
        01  LOGTIME PIC S9(15) COMP-3.

        01  DSPAREA.
            05  DSPTRAN PIC X(4).
            05  FILLER PIC X(1) VALUE " ".
            05  DSPDATE PIC X(8).
            05  FILLER PIC X(1) VALUE " ".
            05  DSPTIME PIC X(8).
            05  FILLER PIC X(1) VALUE " ".
            05  DSPTEXT PIC X(50).

        LINKAGE SECTION.
        77  TXT PIC X(50).

      **=============================================================**
        PROCEDURE DIVISION USING TXT.
      **=============================================================**
        DSP-MSG.
            MOVE EIBTRNID TO DSPTRAN.
            MOVE TXT TO DSPTEXT.
            EXEC CICS ASKTIME
                ABSTIME(LOGTIME)
            END-EXEC.
            EXEC CICS FORMATTIME
                ABSTIME(LOGTIME)
                DATESEP('/') MMDDYY(DSPDATE)
                TIMESEP(':') TIME(DSPTIME)
            END-EXEC.
            MOVE EIBTRNID TO LOGQUEUE(5 : 4).
      * for chained transaction 
            IF LOGQUEUE(8 : 1) >= '0' AND <= '9'
                MOVE 'X' TO LOGQUEUE(8 : 1).
            EXEC CICS WRITEQ TS
                QUEUE(LOGQUEUE)
                FROM(DSPAREA)
                LENGTH(LENGTH OF DSPAREA)
            END-EXEC.

            EXIT PROGRAM.
