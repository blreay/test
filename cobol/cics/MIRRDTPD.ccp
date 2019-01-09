        IDENTIFICATION DIVISION.
        PROGRAM-ID. MIRRDTPD.
        AUTHOR. TUXEDO DEVELOPMENT.
        ENVIRONMENT DIVISION.
        CONFIGURATION SECTION.
        DATA DIVISION.
        WORKING-STORAGE SECTION.
      *****************************************************
      * Log messages definitions
      *****************************************************
        01  LOG-QUEUE PIC X(8) VALUE "LOGQ".

        01  LOGMSG.
            05  FILLER PIC X(09) VALUE "MIRRDTPD:".
            05  LOGMSG-TEXT PIC X(50).

        01  LOGERR.
            05  FILLER PIC X(09) VALUE "MIRRDTPD ".
            05  LOG-ERR-ROUTINE PIC X(12).
            05  FILLER PIC X(08) VALUE " FAILED(".
            05  LOG-STATUS1 PIC 9(8).
            05  FILLER PIC X(01) VALUE ",".
            05  LOG-STATUS2 PIC 9(8).
            05  FILLER PIC X(01) VALUE ")".
      *****************************************************
        01  SCREEN-LEN PIC S9(4) COMP-5.

        01  FILLER.
            02  WS-CONVID PIC X(4).
            02  WS-RESP1 PIC S9(8) COMP.
            02  WS-RESP2 PIC S9(8) COMP.
            02  WS-STATE PIC S9(8) COMP.
      *     02  WS-SYSID PIC X(4) VALUE 'CICA'.
      *     02  WS-PROC PIC X(4) VALUE 'DTPS'.
            02  WS-PARTNER PIC X(8) VALUE 'MIRRDTPS'.
            02  WS-SYNC-LVL PIC S9(4)  COMP.
                88 SYNC-NONE                    VALUE 0.
                88 SYNC-CONFIRM                 VALUE 1.
                88 SYNC-SYNCPT                  VALUE 2.
            02  RECEIVE-FLAG PIC X(1).
                88 CONTINUE-RECEIVE VALUE 'Y'.
                88 SEND-STATE VALUE 'N'.

        01 FILLER.
            02  WS-SEND-BUF PIC X(40).
            02  WS-SEND-LEN PIC S9(4) COMP-5 VALUE 0.
            02  WS-RCVD-BUF PIC X(40).
            02  WS-RCV-LEN PIC S9(4) COMP-5 VALUE 0.
            02  WS-RCVD-LEN PIC S9(4) COMP-5 VALUE 0.
            02  WS-MAX-LEN PIC S9(4) COMP-5 VALUE 40.

        LINKAGE SECTION.
      *****************************************************
        01  SCREEN-BUF.
            05  FILLER PIC X(5).
            05  SCREEN-MSG PIC X(40).

      *    ...
        PROCEDURE DIVISION.
        START-PROGRAM.
            MOVE "Started" TO LOGMSG-TEXT.
            PERFORM DO-USERLOG.

            PERFORM DO-PGM.
            PERFORM EXIT-PROGRAM.

      *****************************************************
      *  Issue a TPCALL
      *****************************************************
        DO-PGM.
            EXEC CICS RECEIVE
                SET(ADDRESS OF SCREEN-BUF)
                LENGTH(SCREEN-LEN)
                MAXLENGTH(LENGTH OF SCREEN-BUF)
                RESP(WS-RESP1)
                RESP2(WS-RESP2)
            END-EXEC.
            IF WS-RESP1 NOT = DFHRESP(EOC)
                MOVE "CICS RECEIVE" TO LOG-ERR-ROUTINE
                MOVE WS-RESP1 TO LOG-STATUS1
                MOVE WS-RESP2 TO LOG-STATUS2
                PERFORM DO-LOG-ERR
            END-IF.

            IF SCREEN-LEN < 6
                MOVE "No request string" TO LOGMSG-TEXT
                EXEC CICS SEND TEXT
                    FROM(LOGMSG)
                    LENGTH(LENGTH OF LOGMSG)
      *             ERASE TERMINAL FREEKB CURSOR(0)
                END-EXEC
                PERFORM EXIT-PROGRAM
            END-IF.

            SUBTRACT 5 FROM SCREEN-LEN GIVING WS-SEND-LEN.
            MOVE SCREEN-MSG (1:WS-SEND-LEN) TO WS-SEND-BUF.

            EXEC CICS ALLOCATE
                PARTNER(WS-PARTNER)
                RESP(WS-RESP1) RESP2(WS-RESP2)
            END-EXEC.
      *         SYSID(WS-SYSID)
            IF WS-RESP1 NOT = DFHRESP(NORMAL)
                MOVE "CICS ALLOCATE" TO LOG-ERR-ROUTINE
                MOVE WS-RESP1 TO LOG-STATUS1
                MOVE WS-RESP2 TO LOG-STATUS2
                PERFORM DO-LOG-ERR
            END-IF.

            MOVE EIBRSRCE TO WS-CONVID.

            MOVE EIBTRNID (2:1) TO WS-SYNC-LVL.
            IF WS-SYNC-LVL NOT = 0 AND 2
                MOVE "Invaild trancation id" TO LOGMSG-TEXT
                EXEC CICS SEND TEXT
                    FROM(LOGMSG)
                    LENGTH(LENGTH OF LOGMSG)
                    ERASE TERMINAL FREEKB CURSOR(0)
                END-EXEC
                PERFORM EXIT-PROGRAM
            END-IF.

            EXEC CICS CONNECT PROCESS
                CONVID(WS-CONVID)
                STATE(WS-STATE)
                PARTNER(WS-PARTNER)
                SYNCLEVEL(WS-SYNC-LVL)
            END-EXEC.
      *         PROCNAME(WS-PROC)
      *         PROCLENGTH(4)

            EXEC CICS SEND
                CONVID(WS-CONVID)
                STATE(WS-STATE)
                FROM(WS-SEND-BUF) LENGTH(WS-SEND-LEN)
                INVITE WAIT
                RESP(WS-RESP1) RESP2(WS-RESP2)
            END-EXEC.
            IF WS-RESP1 NOT = DFHRESP(NORMAL)
                MOVE "CICS SEND" TO LOG-ERR-ROUTINE
                MOVE WS-RESP1 TO LOG-STATUS1
                MOVE WS-RESP2 TO LOG-STATUS2
                PERFORM DO-LOG-ERR
            END-IF.

      *     IF WS-STATE NOT = DFHVALUE(RECEIVE)
      *         MOVE "No receive state" TO LOGMSG-TEXT
      *         EXEC CICS SEND TEXT
      *             FROM(LOGMSG)
      *             LENGTH(LENGTH OF LOGMSG)
      *             ERASE TERMINAL FREEKB CURSOR(0)
      *         END-EXEC
      *         PERFORM EXIT-PROGRAM
      *     END-IF.

            MOVE SPACES TO WS-RCVD-BUF.
            SET CONTINUE-RECEIVE TO TRUE.
            PERFORM UNTIL SEND-STATE
                EXEC CICS RECEIVE
                    CONVID(WS-CONVID)
                    STATE(WS-STATE)
                    INTO(WS-RCVD-BUF) LENGTH(WS-RCV-LEN)
                    MAXLENGTH(WS-MAX-LEN)
                    NOTRUNCATE
                    RESP(WS-RESP1) RESP2(WS-RESP2)
                END-EXEC
                IF WS-RESP1 NOT = DFHRESP(EOC) AND DFHRESP(NORMAL)
                    MOVE "CICS RECEIVE" TO LOG-ERR-ROUTINE
                    MOVE WS-RESP1 TO LOG-STATUS1
                    MOVE WS-RESP2 TO LOG-STATUS2
                    PERFORM DO-LOG-ERR
                END-IF

                IF EIBERR = LOW-VALUES
                THEN
                    ADD WS-RCV-LEN TO WS-RCVD-LEN
                    EVALUATE WS-STATE
                        WHEN DFHVALUE(SYNCFREE)
                            MOVE "Partner issued SYNCPOINT and LAST"
                                TO LOGMSG-TEXT
                        WHEN DFHVALUE(SYNCRECEIVE)
                            MOVE "Partner issued SYNCPOINT"
                                TO LOGMSG-TEXT
                        WHEN DFHVALUE(SYNCSEND)
                            MOVE "Partner issued SYNCPOINT and INVITE"
                                TO LOGMSG-TEXT
                        WHEN DFHVALUE(CONFFREE)
                            MOVE "Partner issued CONFIRM and LAST"
                                TO LOGMSG-TEXT
                        WHEN DFHVALUE(CONFRECEIVE)
                            MOVE "Partner issued CONFIRM"
                                TO LOGMSG-TEXT
                            EXEC CICS ISSUE CONFIRMATION
                                CONVID(WS-CONVID)
                                STATE(WS-STATE)
                            END-EXEC
                        WHEN DFHVALUE(CONFSEND)
                            MOVE "Partner issued CONFIRM and INVITE"
                                TO LOGMSG-TEXT
                            EXEC CICS ISSUE CONFIRMATION
                                CONVID(WS-CONVID)
                                STATE(WS-STATE)
                            END-EXEC
                            SET SEND-STATE TO TRUE
      *                     EXEC CICS SEND LAST
      *                         CONVID(WS-CONVID)
      *                         STATE(WS-STATE)
      *                     END-EXEC
                        WHEN DFHVALUE(FREE)
                            MOVE "Partner issued LAST or FREE"
                                TO LOGMSG-TEXT
                            SET SEND-STATE TO TRUE
                        WHEN DFHVALUE(SEND)
                            MOVE "Partner issued INVITE"
                                TO LOGMSG-TEXT
                            SET SEND-STATE TO TRUE
                        WHEN DFHVALUE(RECEIVE)
                            MOVE "No state change, check EIBCOMPL"
                                TO LOGMSG-TEXT
                        WHEN OTHER
                            MOVE "Logic error, should never happen"
                                TO LOGMSG-TEXT
                    END-EVALUATE
                ELSE
                    EVALUATE WS-STATE
                        WHEN DFHVALUE(ROLLBACK)
                            MOVE "ROLLBACK received"
                                TO LOGMSG-TEXT
                        WHEN DFHVALUE(RECEIVE)
                            MOVE "ISSUE ERROR received, check EIBERRCD"
                                TO LOGMSG-TEXT
                        WHEN OTHER
                            MOVE "Logic error, should never happen"
                                TO LOGMSG-TEXT
                    END-EVALUATE
                END-IF

      *         PERFORM VARYING WS-RCV-LEN
      *               FROM LENGTH OF WS-RCVD-BUF BY -1
      *                 UNTIL WS-RCVD-BUF (WS-RCV-LEN:1) > SPACES
      *                     OR WS-RCV-LEN = 0
      *         END-PERFORM
            END-PERFORM.

            IF SYNC-SYNCPT
                EXEC CICS SEND LAST
                    CONVID(WS-CONVID)
                    STATE(WS-STATE)
                END-EXEC
                EXEC CICS FREE
                    CONVID(WS-CONVID)
                    STATE(WS-STATE)
                END-EXEC
            END-IF.

            EXEC CICS SEND TEXT
                FROM(WS-RCVD-BUF)
                LENGTH(WS-RCVD-LEN)
      *         ERASE TERMINAL FREEKB CURSOR(0)
            END-EXEC.

      *****************************************************
      * Log messages to the userlog
      *****************************************************
        DO-USERLOG.
            EXEC CICS WRITEQ TS
                QUEUE(LOG-QUEUE)
                FROM(LOGMSG)
                LENGTH(LENGTH OF LOGMSG)
            END-EXEC.

        DO-LOG-ERR.
            EXEC CICS SEND TEXT
                FROM(LOGERR)
                LENGTH(LENGTH OF LOGERR)
       *        ERASE TERMINAL FREEKB CURSOR(0)
            END-EXEC.
            EXEC CICS RETURN END-EXEC.

      *****************************************************
      *Leave Application
      *****************************************************
        EXIT-PROGRAM.
            MOVE "Ended" TO LOGMSG-TEXT.
            PERFORM DO-USERLOG.
            EXEC CICS RETURN END-EXEC.
