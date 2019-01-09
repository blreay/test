        IDENTIFICATION DIVISION.
        PROGRAM-ID. CHANCONS.
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
            03  WS-CHAN PIC X(16) VALUE 'MYCHAN'.
            03  WS-CONT PIC X(16) VALUE SPACES.
            03  WS-TOKEN PIC S9(9) COMP VALUE 0.
            03  WS-BUFLEN PIC S9(9) COMP VALUE 0.
            03  FILLER PIC X(1).
                88  HAS-NEXT VALUE '0'.
                88  IS-END VALUE '1'.

      **=============================================================**
        01  WS-BUFFER.
            COPY CHANCPY.

        01  FILLER.
            03  DSP-INT PIC +9(9).
            03  DSP-LO PIC +9(18).
            03  DSP-ECA PIC X(40).
            03  AX PIC S9(4) COMP.
            03  OP PIC X(1).

      **=============================================================**
        LINKAGE SECTION.
      **=============================================================**
      **=============================================================**
        PROCEDURE DIVISION.
      **=============================================================**
        MAIN.
            PERFORM START-PROGRAM.
            PERFORM DO-PROGRAM.
            PERFORM EXIT-PROGRAM.

      **=============================================================**
        START-PROGRAM.
            MOVE "Started" TO LOG-TEXT.
            CALL DSPMSG USING
                DFHEIBLK
                DFHCOMMAREA
                LOG-TEXT.

            SET HAS-NEXT TO TRUE.

      **=============================================================**
        DO-PROGRAM.
            EXEC CICS STARTBROWSE CONTAINER
                CHANNEL(WS-CHAN)
                BROWSETOKEN(WS-TOKEN)
                RESP(TP-STATUS) RESP2(TP-STATUS2)
            END-EXEC.
            IF TP-STATUS NOT = DFHRESP(NORMAL)
                MOVE "CICS STARTBR" TO LOG-ROUTINE
                CALL DSPERR USING
                    DFHEIBLK
                    DFHCOMMAREA
                    LOG-ROUTINE
                    TP-STATUS
                    TP-STATUS2
                EXEC CICS RETURN END-EXEC
            END-IF.

            PERFORM PROCESS-ONCE UNTIL IS-END.

            EXEC CICS ENDBROWSE CONTAINER
                BROWSETOKEN(WS-TOKEN)
                RESP(TP-STATUS) RESP2(TP-STATUS2)
            END-EXEC.
            IF TP-STATUS NOT = DFHRESP(NORMAL)
                MOVE "CICS ENDBR" TO LOG-ROUTINE
                CALL DSPERR USING
                    DFHEIBLK
                    DFHCOMMAREA
                    LOG-ROUTINE
                    TP-STATUS
                    TP-STATUS2
                EXEC CICS RETURN END-EXEC
            END-IF.

      **=============================================================**
        PROCESS-ONCE.
            EXEC CICS GETNEXT CONTAINER(WS-CONT)
                BROWSETOKEN(WS-TOKEN)
                RESP(TP-STATUS) RESP2(TP-STATUS2)
            END-EXEC.
            IF TP-STATUS NOT = DFHRESP(NORMAL) AND DFHRESP(END)
                MOVE "CICS GETNEXT" TO LOG-ROUTINE
                CALL DSPERR USING
                    DFHEIBLK
                    DFHCOMMAREA
                    LOG-ROUTINE
                    TP-STATUS
                    TP-STATUS2
                EXEC CICS RETURN END-EXEC
            END-IF.

            IF TP-STATUS NOT = DFHRESP(END)
                MOVE LENGTH OF WS-BUFFER TO WS-BUFLEN
                EXEC CICS GET CONTAINER(WS-CONT)
                   CHANNEL(WS-CHAN)
                   INTO(WS-BUFFER)
                   FLENGTH(WS-BUFLEN)
                   RESP(TP-STATUS) RESP2(TP-STATUS2)
                END-EXEC
                IF TP-STATUS NOT = DFHRESP(NORMAL)
                    CALL DSPERR USING
                        DFHEIBLK
                        DFHCOMMAREA
                        LOG-ROUTINE
                        TP-STATUS
                        TP-STATUS2
                    EXEC CICS RETURN END-EXEC
                END-IF

                INITIALIZE LOG-TEXT
                STRING 'GET - ', WS-CONT DELIMITED BY SIZE
                    INTO LOG-TEXT
                CALL DSPMSG USING
                    DFHEIBLK
                    DFHCOMMAREA
                    LOG-TEXT
                PERFORM DISPLAY-BUFFER

                PERFORM PROCESS-BUFFER

                EXEC CICS PUT CONTAINER(WS-CONT)
                    CHANNEL(WS-CHAN)
                    FROM(WS-BUFFER)
                    FLENGTH(WS-BUFLEN)
                    RESP(TP-STATUS) RESP2(TP-STATUS2)
                END-EXEC
                IF TP-STATUS NOT = DFHRESP(NORMAL)
                    MOVE "CICS PUT" TO LOG-ROUTINE
                    CALL DSPERR USING
                        DFHEIBLK
                        DFHCOMMAREA
                        LOG-ROUTINE
                        TP-STATUS
                        TP-STATUS2
                    EXEC CICS RETURN END-EXEC
                END-IF

                INITIALIZE LOG-TEXT
                STRING 'PUT - ', WS-CONT DELIMITED BY SIZE
                    INTO LOG-TEXT
                CALL DSPMSG USING
                    DFHEIBLK
                    DFHCOMMAREA
                    LOG-TEXT
                PERFORM DISPLAY-BUFFER
            ELSE
                SET IS-END TO TRUE
            END-IF.

      **=============================================================**
        PROCESS-BUFFER.
            MOVE ACH TO OP.

            COMPUTE AX = FUNCTION ORD(ACH) -
                FUNCTION ORD('1') + FUNCTION ORD('A').
            MOVE FUNCTION CHAR(AX) TO ACH.

      *     display "buflen1(" WS-BUFLEN ")".
            MOVE WS-BUFLEN TO BINT.

            INITIALIZE CSTR.
            INSPECT CSTR REPLACING ALL SPACE BY ACH.

            ADD 1 TO DLO32.
            INITIALIZE ECA.
            INSPECT ECA REPLACING ALL SPACE BY OP.
      *     INITIALIZE FFI.
            MOVE "0123456789" TO FFI.
            MOVE "0123456789" TO FFI(LENGTH OF FFI - 9 : 10).

      **=============================================================**
        DISPLAY-BUFFER.
            INITIALIZE LOG-TEXT.
            STRING 'ACH(', ACH,
                ')' DELIMITED BY SIZE INTO LOG-TEXT.
            CALL DSPMSG USING DFHEIBLK DFHCOMMAREA LOG-TEXT.

            INITIALIZE LOG-TEXT.
            MOVE BINT TO DSP-INT.
            STRING 'BINT(', DSP-INT,
                ')' DELIMITED BY SIZE INTO LOG-TEXT.
            CALL DSPMSG USING DFHEIBLK DFHCOMMAREA LOG-TEXT.

            INITIALIZE LOG-TEXT.
            STRING 'CSTR(', CSTR DELIMITED BY SIZE,
                ')' DELIMITED BY SIZE INTO LOG-TEXT.
            CALL DSPMSG USING DFHEIBLK DFHCOMMAREA LOG-TEXT.

            PERFORM VARYING AX FROM LENGTH OF CSTR BY -1
                UNTIL CSTR(AX : 1) > SPACES OR AX = 0
            END-PERFORM.

            INITIALIZE LOG-TEXT.
            MOVE DLO32 TO DSP-LO.
            STRING 'DLO(', DSP-LO,
                ')' DELIMITED BY SIZE INTO LOG-TEXT.
            CALL DSPMSG USING DFHEIBLK DFHCOMMAREA LOG-TEXT.

            INITIALIZE LOG-TEXT.
            MOVE LENGTH OF ECA TO AX.
            CALL DUMPHEX USING ECA AX DSP-ECA.
            STRING 'ECA(', DSP-ECA DELIMITED BY SIZE,
                ')' DELIMITED BY SIZE INTO LOG-TEXT.
            CALL DSPMSG USING DFHEIBLK DFHCOMMAREA LOG-TEXT.

      **=============================================================**
        EXIT-PROGRAM.
            MOVE "Ended" TO LOG-TEXT.
            CALL DSPMSG USING
                DFHEIBLK
                DFHCOMMAREA
                LOG-TEXT.

            EXEC CICS RETURN END-EXEC.
