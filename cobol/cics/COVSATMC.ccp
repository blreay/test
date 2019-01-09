        IDENTIFICATION DIVISION.
        PROGRAM-ID. COVSATMC.
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
            03  DSPLINE PIC X(8) VALUE "DSPLINE".
            03  RCVSCR PIC X(8) VALUE "RCVSCR".
            03  DUMPHEX PIC X(8) VALUE "DUMPHEX".
            03  LOG-TEXT PIC X(50) VALUE SPACES.
            03  LOG-ROUTINE PIC X(14) VALUE SPACES.
            03  TMP-LINE PIC X(80) VALUE SPACES.

        01  FILLER.
            03  TP-STATUS PIC S9(8) COMP.
            03  TP-STATUS2 PIC S9(8) COMP.

        01  FILLER.
            03  WS-SYSID PIC X(4) VALUE SPACES.
            03  WS-CONSTS PIC S9(8) COMP.
            03  WS-CONVID PIC X(4) VALUE SPACES.
            03  WS-PROC PIC X(6) VALUE SPACES.
            03  WS-PIP.
                04  PIP-L1 PIC X VALUE 0.
                04  PIP-L2 PIC X VALUE 0.
                04  PIP-L3 PIC X VALUE 9.
                04  PIP-L4 PIC X VALUE 9.
                04  PIP-L5 PIC X VALUE 7.
                04  PIP-L6 PIC X VALUE 7.
                04  PIP-L7 PIC X VALUE 7.
                04  PIP-L8 PIC X VALUE 7.
                04  PIP-L9 PIC X VALUE 7.
                04  PIP-LA PIC X VALUE 7.
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
            03  AX PIC S9(4) COMP.
            03  MY-CURS PIC S9(4) COMP VALUE 0.
            03  DSP-SH PIC 9(5).
            03  DSP-LO PIC +9(18).
            03  DSP-ECA PIC X(40).
            03  FILLER PIC X(1).
                88  LONG-32 VALUE '1'.
                88  LONG-64 VALUE '2'.

      **=============================================================**
        LINKAGE SECTION.
        01  DUMMY PIC X(100).
      **=============================================================**
      **=============================================================**
        PROCEDURE DIVISION.
      **=============================================================**
        MAIN.
            DISPLAY "zzy COVSATMC".
			MOVE X'0A' TO PIP-L1.
			MOVE X'00' TO PIP-L2.
            PERFORM START-PROGRAM.
            PERFORM DO-PROGRAM.
            PERFORM EXIT-PROGRAM.

      **=============================================================**
        START-PROGRAM.
            MOVE "Started" TO LOG-TEXT.
            DISPLAY "COVSATMC:" LOG-TEXT.
            CALL DSPMSG USING
                DFHEIBLK
                DFHCOMMAREA
                LOG-TEXT.

            DISPLAY "COVSATMC: after DSPMSG is "  EIBTRNID(4 : 1).
            IF EIBTRNID(4 : 1) NOT = 0 AND 1 AND 2
                MOVE "Invalid TranID" TO LOG-ROUTINE
                CALL DSPERR USING
                    DFHEIBLK
                    DFHCOMMAREA
                    LOG-ROUTINE
                    TP-STATUS
                    TP-STATUS2
                EXEC CICS RETURN END-EXEC
            END-IF.

            SET LONG-32 TO TRUE.
            DISPLAY "COVSATMC: after set LONG-32".

      **=============================================================**
        DO-PROGRAM.
            CALL RCVSCR USING
                DFHEIBLK
                DFHCOMMAREA
                TMP-LINE.

            UNSTRING TMP-LINE DELIMITED BY ' ' INTO
                WS-SYSID WS-PROC.
            IF WS-PROC = SPACES
                MOVE "No proc" TO LOG-ROUTINE
                CALL DSPERR USING
                    DFHEIBLK
                    DFHCOMMAREA
                    LOG-ROUTINE
                    TP-STATUS
                    TP-STATUS2
                EXEC CICS RETURN END-EXEC
            END-IF.

            DISPLAY "COVSATMC: before allocate: WS-SYSID=" WS-SYSID.

            EXEC CICS ALLOCATE
                SYSID(WS-SYSID)
                RESP(TP-STATUS) RESP2(TP-STATUS2)
            END-EXEC.
            IF TP-STATUS NOT = DFHRESP(NORMAL)
                MOVE "CICS ALLOCATE" TO LOG-ROUTINE
                CALL DSPERR USING
                    DFHEIBLK
                    DFHCOMMAREA
                    LOG-ROUTINE
                    TP-STATUS
                    TP-STATUS2
                EXEC CICS RETURN END-EXEC
            END-IF.

            DISPLAY "COVSATMC: after allocate".

            MOVE EIBRSRCE TO WS-CONVID.
            MOVE EIBTRNID(4 : 1) TO WS-SYNCLVL.

            EXEC CICS CONNECT PROCESS
                CONVID(WS-CONVID)
                STATE(WS-STATE)
                PROCNAME(WS-PROC)
                PROCLENGTH(LENGTH OF WS-PROC)
      *         PIPLENGTH(LENGTH of WS-PIP)
      *         PIPLIST(WS-PIP)
                SYNCLEVEL(WS-SYNCLVL)
                RESP(TP-STATUS) RESP2(TP-STATUS2)
            END-EXEC.
            IF TP-STATUS NOT = DFHRESP(NORMAL)
                MOVE "CICS CONNECT" TO LOG-ROUTINE
                CALL DSPERR USING
                    DFHEIBLK
                    DFHCOMMAREA
                    LOG-ROUTINE
                    TP-STATUS
                    TP-STATUS2
                EXEC CICS RETURN END-EXEC
            END-IF.

            PERFORM PREPARE-BUFFER.
            DISPLAY "COVSATMC: after connect".

            MOVE "SEND:" TO TMP-LINE.
            CALL DSPLINE USING
                DFHEIBLK
                DFHCOMMAREA
                TMP-LINE
                MY-CURS.
            PERFORM DISPLAY-BUFFER.

            EXEC CICS SEND
                CONVID(WS-CONVID)
                STATE(WS-STATE)
                FROM(WS-BUFFER) FLENGTH(WS-BUFLEN)
                INVITE WAIT
                RESP(TP-STATUS) RESP2(TP-STATUS2)
            END-EXEC.
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

            DISPLAY "COVSATMC: after send".
            PERFORM RECEIVE-ONCE
                TEST AFTER UNTIL WS-STATE NOT = DFHVALUE(RECEIVE) AND
                    DFHVALUE(CONFRECEIVE) AND DFHVALUE(SYNCRECEIVE).

            MOVE "RECV:" TO TMP-LINE.
            CALL DSPLINE USING
                DFHEIBLK
                DFHCOMMAREA
                TMP-LINE
                MY-CURS.
            PERFORM DISPLAY-BUFFER.

            IF SYNC-SYNCPT AND WS-STATE = DFHVALUE(SEND)
                EXEC CICS SEND LAST
                    CONVID(WS-CONVID)
                    STATE(WS-STATE)
                END-EXEC
                EXEC CICS SYNCPOINT END-EXEC
            END-IF.

            EXEC CICS FREE
                CONVID(WS-CONVID)
                STATE(WS-STATE)
            END-EXEC.
            DISPLAY "COVSATMC: after free".

      **=============================================================**
        RECEIVE-ONCE.
            DISPLAY "COVSATMC: begin receive".
            EXEC CICS RECEIVE
                CONVID(WS-CONVID)
                STATE(WS-STATE)
                SET(ADDRESS OF DUMMY) FLENGTH(DUM-LEN)
                NOTRUNCATE
                RESP(TP-STATUS) RESP2(TP-STATUS2)
            END-EXEC.
            DISPLAY "COVSATMC: after receive 00:" TP-STATUS.
            DISPLAY "COVSATMC: after receive 11:" DFHRESP(EOC).
            DISPLAY "COVSATMC: after receive 33 DFHRESP(NORMAL):" 
						DFHRESP(NORMAL).
            IF TP-STATUS NOT = DFHRESP(EOC)
			AND TP-STATUS NOT = DFHRESP(NORMAL)
                MOVE "CICS RECEIVE" TO LOG-ROUTINE
                CALL DSPERR USING
                    DFHEIBLK
                    DFHCOMMAREA
                    LOG-ROUTINE
                    TP-STATUS
                    TP-STATUS2
                PERFORM EXIT-ERROR
            END-IF.
            DISPLAY "COVSATMC: after receive".

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
                    EXEC CICS ISSUE CONFIRMATION
                        CONVID(WS-CONVID)
                        STATE(WS-STATE)
                    END-EXEC
                WHEN DFHVALUE(CONFRECEIVE)
                    MOVE "Received CONFIRM" TO LOG-TEXT
                    EXEC CICS ISSUE CONFIRMATION
                        CONVID(WS-CONVID)
                        STATE(WS-STATE)
                    END-EXEC
                WHEN DFHVALUE(CONFSEND)
                    MOVE "Received CONFIRM and INVITE" TO LOG-TEXT
                    EXEC CICS ISSUE CONFIRMATION
                        CONVID(WS-CONVID)
                        STATE(WS-STATE)
                    END-EXEC
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
        PREPARE-BUFFER.
            INITIALIZE WS-BUFFER.

            MOVE "2" TO ACH.
            MOVE EIBTRNID TO CSTR.
            MOVE LENGTH OF HEAD TO BSH.
            IF LONG-32
                ADD LENGTH OF DLO32, LENGTH OF ECA TO BSH
                MOVE -999999999 TO DLO32
                MOVE ALL X"01" TO ECA
            ELSE
                ADD LENGTH OF DLO64, LENGTH OF ECA1 TO BSH
                MOVE -999999999999999999 TO DLO64
                MOVE ALL X"01" TO ECA1
            END-IF.

            MOVE BSH TO WS-BUFLEN.

      **=============================================================**
        DISPLAY-BUFFER.
            INITIALIZE TMP-LINE.
            STRING 'CH(', ACH DELIMITED BY SIZE,
                ')' DELIMITED BY SIZE INTO TMP-LINE.
            CALL DSPLINE USING
                DFHEIBLK
                DFHCOMMAREA
                TMP-LINE
                MY-CURS.

            INITIALIZE TMP-LINE.
            MOVE BSH TO DSP-SH.
            STRING 'SH(', DSP-SH,
                ')' DELIMITED BY SIZE INTO TMP-LINE.
            CALL DSPLINE USING
                DFHEIBLK
                DFHCOMMAREA
                TMP-LINE
                MY-CURS.

            INITIALIZE TMP-LINE.
            STRING 'STR(', CSTR DELIMITED BY SIZE,
                ')' DELIMITED BY SIZE INTO TMP-LINE.
            CALL DSPLINE USING
                DFHEIBLK
                DFHCOMMAREA
                TMP-LINE
                MY-CURS.

            IF LONG-32
                INITIALIZE TMP-LINE
                MOVE DLO32 TO DSP-LO
                STRING 'LO(', DSP-LO,
                    ')' DELIMITED BY SIZE INTO TMP-LINE
                CALL DSPLINE USING
                    DFHEIBLK
                    DFHCOMMAREA
                    TMP-LINE
                    MY-CURS

                INITIALIZE TMP-LINE
                MOVE LENGTH OF ECA TO AX
                CALL DUMPHEX USING
                    ECA
                    AX
                    DSP-ECA
                STRING 'CA(', DSP-ECA DELIMITED BY SIZE,
                    ')' DELIMITED BY SIZE INTO TMP-LINE
                CALL DSPLINE USING
                    DFHEIBLK
                    DFHCOMMAREA
                    TMP-LINE
                    MY-CURS

                INITIALIZE TMP-LINE
                STRING 'FI(',
                    FFI(1 : 10) DELIMITED BY SIZE,
                    ' ... ' DELIMITED BY SIZE,
                    FFI(LENGTH OF FFI - 9 : 10) DELIMITED BY SIZE,
                    ')' DELIMITED BY SIZE
                    INTO TMP-LINE
                CALL DSPLINE USING
                    DFHEIBLK
                    DFHCOMMAREA
                    TMP-LINE
                    MY-CURS
            ELSE
                INITIALIZE TMP-LINE
                MOVE DLO64 TO DSP-LO
                STRING 'LO(', DSP-LO,
                    ')' DELIMITED BY SIZE INTO TMP-LINE
                CALL DSPLINE USING
                    DFHEIBLK
                    DFHCOMMAREA
                    TMP-LINE
                    MY-CURS

                INITIALIZE TMP-LINE
                MOVE LENGTH OF ECA1 TO AX
                CALL DUMPHEX USING
                    ECA1
                    AX
                    DSP-ECA
                STRING 'CA(', DSP-ECA DELIMITED BY SIZE,
                    ')' DELIMITED BY SIZE INTO TMP-LINE
                CALL DSPLINE USING
                    DFHEIBLK
                    DFHCOMMAREA
                    TMP-LINE
                    MY-CURS

                INITIALIZE TMP-LINE
                STRING 'FI(',
                    FFI1(1 : 10) DELIMITED BY SIZE,
                    ' ... ' DELIMITED BY SIZE,
                    FFI1(LENGTH OF FFI1 - 9 : 10) DELIMITED BY SIZE,
                    ')' DELIMITED BY SIZE
                    INTO TMP-LINE
                CALL DSPLINE USING
                    DFHEIBLK
                    DFHCOMMAREA
                    TMP-LINE
                    MY-CURS
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
            MOVE "Ended" TO LOG-TEXT.
            CALL DSPMSG USING
                DFHEIBLK
                DFHCOMMAREA
                LOG-TEXT.
            DISPLAY "COVSATMC: after CICS RETURN".  
            EXEC CICS RETURN END-EXEC.
