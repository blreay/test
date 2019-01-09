        IDENTIFICATION DIVISION.
        PROGRAM-ID. DSPERR.
        AUTHOR. TUXEDO DEVELOPMENT.
        ENVIRONMENT DIVISION.
        CONFIGURATION SECTION.
        DATA DIVISION.
        WORKING-STORAGE SECTION.
      **=============================================================**
      * Log messages definitions
      **=============================================================**
        01  LOGQUEUE PIC X(8) VALUE "LOGQ    ".

        01  FACILITY PIC X(1).

        01  DSPAREA.
            05  DSPTRAN PIC X(4).
            05  FILLER PIC X(1) VALUE " ".
            05  DSPROUTINE PIC X(14).
            05  FILLER PIC X(8) VALUE " FAILED(".
            05  DSPSTATUS PIC 9(8).
            05  FILLER PIC X(01) VALUE ",".
            05  DSPSTATUS2 PIC 9(8).
            05  FILLER PIC X(01) VALUE ")".

        LINKAGE SECTION.
        77  STR PIC X(14).
        77  STA PIC S9(8) COMP.
        77  STA2 PIC S9(8) COMP.

      **=============================================================**
        PROCEDURE DIVISION USING STR, STA, STA2.
      **=============================================================**
        DSP-ERR.
            MOVE EIBTRNID TO DSPTRAN.
            MOVE STR TO DSPROUTINE.
            MOVE STA TO DSPSTATUS.
            MOVE STA2 TO DSPSTATUS2.

      *     EXEC CICS ASSIGN
      *         DS3270(FACILITY)
      *     END-EXEC

      *     IF FACILITY = X'FF'
            IF EIBTRMID NOT = X'00000000'
                EXEC CICS SEND TEXT
                    FROM(DSPAREA)
                    LENGTH(LENGTH OF DSPAREA)
      *             ERASE TERMINAL FREEKB CURSOR(0)
                END-EXEC
            ELSE
                MOVE EIBTRNID TO LOGQUEUE(5:4)
                IF LOGQUEUE(8 : 1) >= '0' AND <= '9'
                    MOVE 'X' TO LOGQUEUE(8 : 1)
                END-IF
                EXEC CICS WRITEQ TS
                    QUEUE(LOGQUEUE)
                    FROM(DSPAREA)
                    LENGTH(LENGTH OF DSPAREA)
                END-EXEC
            END-IF.

            EXIT PROGRAM.
