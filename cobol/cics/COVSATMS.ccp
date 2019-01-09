        IDENTIFICATION DIVISION.
        PROGRAM-ID. COVSATMS.
        AUTHOR. TUXEDO DEVELOPMENT.
        ENVIRONMENT DIVISION.
        CONFIGURATION SECTION.
        DATA DIVISION.
      **=============================================================**
        WORKING-STORAGE SECTION.
      **=============================================================**
      * subprogram definitions
        01  FILLER.
            03  DSPMSG PIC X(8) VALUE "DSPMSG".
            03  DSPERR PIC X(8) VALUE "DSPERR".
            03  DUMPHEX PIC X(8) VALUE "DUMPHEX".
            03  LOG-TEXT PIC X(50) VALUE SPACES.
            03  LOG-ROUTINE PIC X(14) VALUE SPACES.

        01  FILLER.
            03  TP-STATUS PIC S9(8) COMP.
            03  TP-STATUS2 PIC S9(8) COMP.

        01  FILLER.
            03  WS-NETID PIC X(8) VALUE SPACES.
            03  WS-CONVID PIC X(4) VALUE SPACES.
            03  WS-STATE PIC S9(8) COMP.
            03  WS-SYNCLVL PIC S9(4) COMP.
                88 SYNC-NONE VALUE 0.
                88 SYNC-CONFIRM VALUE 1.
                88 SYNC-SYNCPT  VALUE 2.
            03  WS-BUFLEN PIC S9(9) COMP VALUE 0.
            03  DSP-BUFLEN PIC 9(5).
            03  DUM-LEN PIC S9(9) COMP VALUE 0.

      **=============================================================**
        01  WS-BUFFER.
            COPY BUFCPY.

        01  FILLER.
            03  DSP-SH PIC 9(4).
            03  DSP-LO PIC +9(18).
            03  DSP-ECA PIC X(40).
            03  AX PIC S9(4) COMP.
            03  OP PIC X(1).
            03  FILLER PIC X(1).
                88  LONG-32 VALUE '1'.
                88  LONG-64 VALUE '2'.

      **=============================================================**
        LINKAGE SECTION.
      **=============================================================**
        01  DUMMY PIC X(100).
      * 01  WS-BUFFER PIC X(50).
      **=============================================================**
        PROCEDURE DIVISION.
      **=============================================================**
        MAIN.
            PERFORM START-PROGRAM.
            PERFORM DO-PROGRAM.
            PERFORM EXIT-PROGRAM.

      **=============================================================**
        START-PROGRAM.
            DISPLAY "COVSATMS zzy start".
            MOVE "Started" TO LOG-TEXT.
            CALL DSPMSG USING
                DFHEIBLK
                DFHCOMMAREA
                LOG-TEXT.

      **=============================================================**
        DO-PROGRAM.
            MOVE EIBTRMID TO WS-CONVID.

            EXEC CICS EXTRACT PROCESS
                CONVID(WS-CONVID)
                SYNCLEVEL(WS-SYNCLVL)
                RESP(TP-STATUS) RESP2(TP-STATUS2)
            END-EXEC.
            IF TP-STATUS NOT = DFHRESP(NORMAL)
                MOVE "CICS EXTRACT" TO LOG-ROUTINE
                CALL DSPERR USING
                    DFHEIBLK
                    DFHCOMMAREA
                    LOG-ROUTINE
                    TP-STATUS
                    TP-STATUS2
                EXEC CICS RETURN END-EXEC
            END-IF.

            PERFORM RECEIVE-ONCE
                TEST AFTER UNTIL EIBRECV EQUAL LOW-VALUES.

            IF WS-BUFLEN = 0
                MOVE "No data" TO LOG-ROUTINE
                CALL DSPERR USING
                    DFHEIBLK
                    DFHCOMMAREA
                    LOG-ROUTINE
                    TP-STATUS
                    TP-STATUS2
                EXEC CICS RETURN END-EXEC
            END-IF.

            PERFORM DISPLAY-BUFFER.
            PERFORM PROCESS-BUFFER.

            DISPLAY "COVSATMS zzy begin send".
            EXEC CICS SEND
                CONVID(WS-CONVID)
                STATE(WS-STATE)
                FROM(WS-BUFFER) FLENGTH(WS-BUFLEN)
                RESP(TP-STATUS) RESP2(TP-STATUS2)
            END-EXEC
            IF TP-STATUS NOT = DFHRESP(NORMAL)
                MOVE "CICS SEND" TO LOG-ROUTINE
                CALL DSPERR USING
                    DFHEIBLK
                    DFHCOMMAREA
                    LOG-ROUTINE
                    TP-STATUS
                    TP-STATUS2
                EXEC CICS RETURN END-EXEC
            END-IF.
            DISPLAY "COVSATMS zzy after send".

            EVALUATE TRUE
                WHEN SYNC-NONE
                    EXEC CICS SEND
                        LAST WAIT
                    END-EXEC
                WHEN SYNC-CONFIRM
                    EXEC CICS SEND
                        LAST CONFIRM
                    END-EXEC
                    IF EIBERR = HIGH-VALUES
                        PERFORM EXIT-ERROR
                    END-IF
                WHEN SYNC-SYNCPT
                    EXEC CICS SEND
                        CONFIRM INVITE
                    END-EXEC
      *             EXEC CICS SYNCPOINT END-EXEC
      *             IF EIBERR = HIGH-VALUES
      *                 PERFORM EXIT-ERROR
      *             END-IF
                    PERFORM RECEIVE-ONCE
            END-EVALUATE.

            EXEC CICS FREE
                CONVID(WS-CONVID)
                STATE(WS-STATE)
            END-EXEC.

      **=============================================================**
        RECEIVE-ONCE.
            DISPLAY "COVSATMS zzy begin receive".
            EXEC CICS RECEIVE
                CONVID(WS-CONVID)
                STATE(WS-STATE)
                SET(ADDRESS OF DUMMY) FLENGTH(DUM-LEN)
                NOTRUNCATE
                RESP(TP-STATUS) RESP2(TP-STATUS2)
            END-EXEC.
            DISPLAY "COVSATMS zzy begin receive" TP-STATUS.
            DISPLAY "COVSATMS zzy begin receive" DFHRESP(EOC).
            IF TP-STATUS NOT = DFHRESP(EOC) AND 
				TP-STATUS NOT = DFHRESP(NORMAL)
                MOVE "CICS RECEIVE" TO LOG-ROUTINE
                CALL DSPERR USING
                    DFHEIBLK
                    DFHCOMMAREA
                    LOG-ROUTINE
                    TP-STATUS
                    TP-STATUS2
                PERFORM EXIT-ERROR
            END-IF.

            IF WS-STATE = DFHVALUE(ROLLBACK) OR EIBERR = HIGH-VALUES
                MOVE "CICS RECEIVE1" TO LOG-ROUTINE
                CALL DSPERR USING
                    DFHEIBLK
                    DFHCOMMAREA
                    LOG-ROUTINE
                    TP-STATUS
                    TP-STATUS2
                PERFORM EXIT-ERROR
            END-IF.
            DISPLAY "COVSATMS zzy after receive".

            INITIALIZE LOG-TEXT.
            EVALUATE WS-STATE
                WHEN DFHVALUE(SYNCFREE)
                    MOVE "Received SYNCPOINT and LAST" TO LOG-TEXT
                    EXEC CICS SYNCPOINT END-EXEC
                WHEN DFHVALUE(SYNCRECEIVE)
                    MOVE "Received SYNCPOINT" TO LOG-TEXT
                WHEN DFHVALUE(SYNCSEND)
                    MOVE "Received SYNCPOINT and INVITE" TO LOG-TEXT
                WHEN DFHVALUE(CONFFREE)
                    MOVE "Received CONFIRM and LAST" TO LOG-TEXT
                WHEN DFHVALUE(CONFRECEIVE)
                    MOVE "Received CONFIRM" TO LOG-TEXT
                WHEN DFHVALUE(CONFSEND)
                    MOVE "Received CONFIRM and INVITE" TO LOG-TEXT
                WHEN DFHVALUE(FREE)
                    MOVE "Received LAST or FREE" TO LOG-TEXT
                WHEN DFHVALUE(SEND)
                    MOVE "Received INVITE" TO LOG-TEXT
                WHEN DFHVALUE(RECEIVE)
                    MOVE "No state change. Check EIBCOMPL" TO LOG-TEXT
                WHEN OTHER
                    MOVE "Logic error, never happen" TO LOG-TEXT
            END-EVALUATE.
            CALL DSPMSG USING
                DFHEIBLK
                DFHCOMMAREA
                LOG-TEXT.

            IF DUM-LEN > 0
                MOVE DUM-LEN TO WS-BUFLEN
                MOVE DUMMY(1 : WS-BUFLEN) TO WS-BUFFER
            END-IF.

      **=============================================================**
        DISPLAY-BUFFER.
            INITIALIZE LOG-TEXT.
            STRING 'ACH(', ACH,
                ')' DELIMITED BY SIZE INTO LOG-TEXT.
            CALL DSPMSG USING
                DFHEIBLK
                DFHCOMMAREA
                LOG-TEXT.

            INITIALIZE LOG-TEXT.
            MOVE BSH TO DSP-SH.
            STRING 'BSH(', DSP-SH,
                ')' DELIMITED BY SIZE INTO LOG-TEXT.
            CALL DSPMSG USING
                DFHEIBLK
                DFHCOMMAREA
                LOG-TEXT.

            INITIALIZE LOG-TEXT.
            STRING 'CSTR(', CSTR DELIMITED BY SIZE,
                ')' DELIMITED BY SIZE INTO LOG-TEXT.
            CALL DSPMSG USING
                DFHEIBLK
                DFHCOMMAREA
                LOG-TEXT.

            PERFORM VARYING AX FROM LENGTH OF CSTR BY -1
                UNTIL CSTR(AX : 1) > SPACES OR AX = 0
            END-PERFORM.
            IF CSTR(AX : 1) NOT = '1'
                SET LONG-32 TO TRUE
            ELSE
                SET LONG-64 TO TRUE
            END-IF.

            INITIALIZE LOG-TEXT.
            IF LONG-32
                MOVE DLO32 TO DSP-LO
            ELSE
                MOVE DLO64 TO DSP-LO
            END-IF.
            STRING 'DLO(', DSP-LO,
                ')' DELIMITED BY SIZE INTO LOG-TEXT.
            CALL DSPMSG USING
                DFHEIBLK
                DFHCOMMAREA
                LOG-TEXT.

            INITIALIZE LOG-TEXT.
            IF LONG-32
                MOVE LENGTH OF ECA TO AX
                CALL DUMPHEX USING
                    ECA
                    AX
                    DSP-ECA
            ELSE
                MOVE LENGTH OF ECA1 TO AX
                CALL DUMPHEX USING
                    ECA1
                    AX
                    DSP-ECA
            END-IF.
            STRING 'ECA(', DSP-ECA DELIMITED BY SIZE,
                ')' DELIMITED BY SIZE INTO LOG-TEXT.
            CALL DSPMSG USING
                DFHEIBLK
                DFHCOMMAREA
                LOG-TEXT.

      **=============================================================**
        PROCESS-BUFFER.
            MOVE ACH TO OP.

            COMPUTE AX = FUNCTION ORD(ACH) -
                FUNCTION ORD('1') + FUNCTION ORD('A').
            MOVE FUNCTION CHAR(AX) TO ACH.

            ADD LENGTH OF FFI TO WS-BUFLEN.
            MOVE WS-BUFLEN TO BSH.

            INITIALIZE CSTR.
            INSPECT CSTR REPLACING ALL SPACE BY ACH.

            IF LONG-32
                ADD 1 TO DLO32
                INITIALIZE ECA
                INSPECT ECA REPLACING ALL SPACE BY OP
                INITIALIZE FFI
                MOVE "0123456789" TO FFI
                MOVE "0123456789" TO FFI(LENGTH OF FFI - 9 : 10)
            ELSE
                ADD 1 TO DLO64
                INITIALIZE ECA1
                INSPECT ECA1 REPLACING ALL SPACE BY OP
                INITIALIZE FFI1
                MOVE "0123456789" TO FFI1
                MOVE "0123456789" TO FFI1(LENGTH OF FFI1 - 9 : 10)
            END-IF.

      **=============================================================**
        EXIT-ERROR.
            IF EIBSYNRB EQUAL HIGH-VALUES
                EXEC CICS
                    SYNCPOINT ROLLBACK
                END-EXEC
            END-IF.

            EXEC CICS RETURN END-EXEC.

      **=============================================================**
        EXIT-PROGRAM.
            DISPLAY "COVSATMS end".
            MOVE "Ended" TO LOG-TEXT.
            CALL DSPMSG USING
                DFHEIBLK
                DFHCOMMAREA
                LOG-TEXT.

            EXEC CICS RETURN END-EXEC.
