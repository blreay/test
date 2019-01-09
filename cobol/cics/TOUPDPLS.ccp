        IDENTIFICATION DIVISION.
        PROGRAM-ID. TOUPDPLS.
        AUTHOR. TUXEDO DEVELOPMENT.
        ENVIRONMENT DIVISION.
        CONFIGURATION SECTION.
        DATA DIVISION.
        WORKING-STORAGE SECTION.
      *****************************************************
      * Log messages definitions
      *****************************************************
        01  LOGQUEUE PIC X(8) VALUE "TMASNAQ".
        01  LOGTIME PIC S9(15) COMP-3.

        01  LOGMSG.
            05  FILLER PIC X(09) VALUE "TOUPDPLS:".
            05  LOG-DATE PIC X(8).
            05  FILLER PIC X(1) VALUE " ".
            05  LOG-TIME PIC X(8).
            05  FILLER PIC X(1) VALUE " ".
            05  LOG-TEXT PIC X(50).

        01  LOGERR.
            05  FILLER PIC X(09) VALUE "TOUPDPLS ".
            05  LOG-ROUTINE PIC X(14).
            05  FILLER PIC X(8) VALUE " FAILED(".
            05  LOG-TP-STATUS PIC 9(8).
            05  FILLER PIC X(01) VALUE ",".
            05  LOG-TP-STATUS2 PIC 9(8).
            05  FILLER PIC X(01) VALUE ")".

        LINKAGE SECTION.
      *****************************************************
        01  DFHCOMMAREA.
            05  FILLER PIC X(1920).
      ******************************************************
        PROCEDURE DIVISION.
      ******************************************************
        MAIN.
            PERFORM START-PROGRAM.
            PERFORM DO-PGM.
            PERFORM EXIT-PROGRAM.

      ******************************************************
      * Start program with command line args
      ******************************************************
        START-PROGRAM.
            DISPLAY "TOUPDPLS: zzy0: start"
            MOVE "Started" TO LOG-TEXT.
            PERFORM DO-USERLOG.

      *****************************************************
      *  Issue a TPCALL
      *****************************************************
        DO-PGM.
            MOVE DFHCOMMAREA TO LOG-TEXT.
            PERFORM DO-USERLOG.
            DISPLAY "TOUPDPLS: zzy0: data:" DFHCOMMAREA.
            IF EIBCALEN > ZERO
                INSPECT DFHCOMMAREA CONVERTING
                    'abcdefghijklmnopqrstuvwxyz' TO
                    'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
            END-IF.

            IF DFHCOMMAREA (1:7) = 'TIMEOUT'
                EXEC CICS DELAY
                    INTERVAL(100)
                END-EXEC
            END-IF.
            DISPLAY "TOUPDPLS: zzy0: after:" DFHCOMMAREA.

      *****************************************************
      * Log messages to the userlog
      *****************************************************
        DO-USERLOG.
            EXEC CICS ASKTIME
                ABSTIME(LOGTIME)
            END-EXEC.
            EXEC CICS FORMATTIME
                ABSTIME(LOGTIME)
                DATESEP('/') MMDDYY(LOG-DATE)
                TIMESEP(':') TIME(LOG-TIME)
            END-EXEC.
            EXEC CICS WRITEQ TS
                QUEUE(LOGQUEUE)
                FROM(LOGMSG)
                LENGTH(LENGTH OF LOGMSG)
            END-EXEC.

        DO-LOG-ERR.
            EXEC CICS SEND TEXT
                FROM(LOGERR)
                LENGTH(LENGTH OF LOGERR)
      *         ERASE TERMINAL FREEKB CURSOR(0)
            END-EXEC.
            EXEC CICS RETURN
            END-EXEC.

      *****************************************************
      *Leave Application
      *****************************************************
        EXIT-PROGRAM.
            MOVE "Ended" TO LOG-TEXT.
            PERFORM DO-USERLOG.
            EXEC CICS RETURN END-EXEC.
