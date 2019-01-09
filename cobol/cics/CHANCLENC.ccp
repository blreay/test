        IDENTIFICATION DIVISION.
        PROGRAM-ID. CHANCONC.
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
            03  WS-PROC PIC X(8) VALUE SPACES.
            03  WS-NUM PIC 9(1) VALUE 0.
            03  WS-APPEND PIC X(1) VALUE SPACE.
                88  NO-APPEND VALUE '0'.
                88  HAS-APPEND VALUE '1'.
            03  WS-TIMES PIC 9(4) VALUE 0.

            03  WS-CHAN PIC X(16) VALUE 'MYCHAN'.
            03  WS-CONT PIC X(16) VALUE 'CONTAINER'.
            03  WS-TOKEN PIC S9(9) COMP VALUE 0.
            03  WS-BUFLEN PIC S9(9) COMP VALUE 0.
            03  IDX PIC 9(4).
            03  JDX PIC 9(1).
            03  IX PIC S9(9) COMP.
            03  JX PIC S9(9) COMP.
            03  QU PIC 9(1).
            03  RE PIC 9(1).
            03  FILLER PIC X(1).
                88  HAS-NEXT VALUE '0'.
                88  IS-END VALUE '1'.

      **=============================================================**
        01  WS-BUFFER.
            COPY CHANCPY.

        01  FILLER.
            03  AX PIC S9(4) COMP.
            03  MY-CURS PIC S9(4) COMP VALUE 0.
            03  DSP-INT PIC +9(9).
            03  DSP-LO PIC +9(18).
            03  DSP-ECA PIC X(40).
            03  PART-LEN  PIC S9(09)  COMP VALUE 0.

      **=============================================================**
        LINKAGE SECTION.
      **=============================================================**
      **=============================================================**
        PROCEDURE DIVISION.
      **=============================================================**
        MAIN.
            PERFORM START-PROGRAM.

            PERFORM DO-PROGRAM VARYING IDX FROM 1 BY 1
                UNTIL IDX = WS-TIMES + 1.

            PERFORM EXIT-PROGRAM.

      **=============================================================**
        START-PROGRAM.
            MOVE "Started" TO LOG-TEXT.
            CALL DSPMSG USING
                DFHEIBLK
                DFHCOMMAREA
                LOG-TEXT.

            IF EIBTRNID(4 : 1) NOT = 0 AND 1
                MOVE "Invalid TranID" TO LOG-ROUTINE
                CALL DSPERR USING
                    DFHEIBLK
                    DFHCOMMAREA
                    LOG-ROUTINE
                    TP-STATUS
                    TP-STATUS2
                EXEC CICS RETURN END-EXEC
            END-IF.

            CALL RCVSCR USING
                DFHEIBLK
                DFHCOMMAREA
                TMP-LINE.

            UNSTRING TMP-LINE DELIMITED BY ' ' INTO
                WS-SYSID WS-PROC WS-NUM WS-APPEND WS-TIMES.

            IF WS-NUM IS NOT NUMERIC OR WS-NUM < 1 OR WS-NUM > 3
                PERFORM DSP-USAGE
            END-IF.

            IF WS-APPEND NOT = '0' AND '1'
                PERFORM DSP-USAGE
            END-IF.

            IF WS-TIMES IS NOT NUMERIC OR WS-TIMES < 1
                MOVE 1 TO WS-TIMES
            END-IF.

      **=============================================================**
        DO-PROGRAM.
            PERFORM PUT-BUFFER.

            EVALUATE EIBTRNID(4 : 1)
                WHEN '0'
                    EXEC CICS LINK PROGRAM(WS-PROC)
                        CHANNEL(WS-CHAN)
                        SYSID(WS-SYSID)
                        SYNCONRETURN
                        RESP(TP-STATUS) RESP2(TP-STATUS2)
                    END-EXEC
                WHEN '1'
                    EXEC CICS LINK PROGRAM(WS-PROC)
                        CHANNEL(WS-CHAN)
                        SYSID(WS-SYSID)
                        TRANSID('MIRR')
                        RESP(TP-STATUS) RESP2(TP-STATUS2)
                    END-EXEC
            END-EVALUATE.
            IF TP-STATUS NOT = DFHRESP(NORMAL)
                MOVE 'CICS LINK' TO LOG-ROUTINE
                CALL DSPERR USING
                    DFHEIBLK
                    DFHCOMMAREA
                    LOG-ROUTINE
                    TP-STATUS
                    TP-STATUS2
                EXEC CICS RETURN END-EXEC
            END-IF.

            PERFORM GET-BUFFER.

      **=============================================================**
        DSP-USAGE.
            INITIALIZE TMP-LINE.
            STRING 'USAGE: ', EIBTRNID,
                ' RMTSYS RMTPGM NUM(1-3) APPEND(0|1)'
                DELIMITED BY SIZE
                INTO TMP-LINE.
            CALL DSPLINE USING
                DFHEIBLK
                DFHCOMMAREA
                TMP-LINE
                MY-CURS.
            EXEC CICS RETURN END-EXEC.

      **=============================================================**
        PUT-BUFFER.
            PERFORM VARYING JDX FROM 1 BY 1
                UNTIL JDX = WS-NUM + 1 OR JDX = 0
                INITIALIZE WS-BUFFER

                MOVE JDX TO ACH
                MOVE EIBTRNID TO CSTR
                MOVE LENGTH OF HEAD TO BINT

                MOVE -999999999 TO DLO32
                MOVE ALL X"01" TO ECA

                IF HAS-APPEND
                    ADD LENGTH OF APPEND TO BINT
                    INITIALIZE FFI
      * Add tag to buffer
                    PERFORM VARYING IX FROM 0 BY 1000
                        UNTIL IX >= LENGTH OF FFI
                        DIVIDE IX BY 1000 GIVING JX
                        ADD 1 TO JX
                        DIVIDE JX BY 10 GIVING QU REMAINDER RE
                        MOVE QU TO FFI(IX + 1 : 1)
                        MOVE RE TO FFI(IX + 2 : 1)
                    END-PERFORM
      * Set last char to make GWSNAX happy
                    MOVE "9" TO FFI(LENGTH OF FFI : 1)
                END-IF

                MOVE BINT TO WS-BUFLEN
      *-test for send part of copybook data
                MOVE JDX  TO  ACH
                MOVE ACH TO WS-CONT(10 : 1)
                INITIALIZE  WS-BUFFER
                MOVE  0  TO  WS-BUFLEN
                MOVE  'A'  TO  ACH
                MOVE 111111111  TO BINT
                MOVE ALL 'B'  TO CSTR
                MOVE 222222222  TO  DLO32
                MOVE  ALL 'C'  TO  ECA
                COMPUTE PART-LEN = JDX * 100
                MOVE ALL 'D'  TO  FFI(1:PART-LEN)
                COMPUTE WS-BUFLEN  =  PART-LEN + LENGTH OF HEAD
                IF  JDX  =  1
                  INITIALIZE  ECA
                  MOVE  ALL 'C'  TO  ECA(1:10)
                  MOVE 59  TO  WS-BUFLEN
                END-IF
                DISPLAY  'WS-BUFLEN:'  WS-BUFLEN
      **-- test for part data end
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

                INITIALIZE TMP-LINE
                STRING IDX DELIMITED BY SIZE, ' PUT ',
                    WS-CONT DELIMITED BY SIZE
                    INTO TMP-LINE
                CALL DSPLINE USING
                    DFHEIBLK
                    DFHCOMMAREA
                    TMP-LINE
                    MY-CURS
      *         PERFORM DISPLAY-BUFFER

            END-PERFORM.

      **=============================================================**
        GET-BUFFER.
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

            SET HAS-NEXT TO TRUE.
            PERFORM UNTIL IS-END
                EXEC CICS GETNEXT CONTAINER(WS-CONT)
                    BROWSETOKEN(WS-TOKEN)
                    RESP(TP-STATUS) RESP2(TP-STATUS2)
                END-EXEC
                IF TP-STATUS NOT = DFHRESP(NORMAL) AND DFHRESP(END)
                    MOVE "CICS GETNEXT" TO LOG-ROUTINE
                    CALL DSPERR USING
                        DFHEIBLK
                        DFHCOMMAREA
                        LOG-ROUTINE
                        TP-STATUS
                        TP-STATUS2
                    EXEC CICS RETURN END-EXEC
                END-IF

                IF TP-STATUS NOT = DFHRESP(END)
                    INITIALIZE WS-BUFFER
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

                    INITIALIZE TMP-LINE
                    STRING IDX DELIMITED BY SIZE, ' GET ',
                        WS-CONT DELIMITED BY SIZE
                        INTO TMP-LINE
                    CALL DSPLINE USING
                        DFHEIBLK
                        DFHCOMMAREA
                        TMP-LINE
                        MY-CURS
                    PERFORM DISPLAY-BUFFER
                ELSE
                    SET IS-END TO TRUE
                END-IF
            END-PERFORM.

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
        DISPLAY-BUFFER.
            INITIALIZE TMP-LINE.
            STRING 'CH(', ACH DELIMITED BY SIZE,
                ')' DELIMITED BY SIZE INTO TMP-LINE.
            CALL DSPLINE USING DFHEIBLK DFHCOMMAREA TMP-LINE MY-CURS.

            INITIALIZE TMP-LINE.
            MOVE BINT TO DSP-INT.
            STRING 'INT(', DSP-INT,
                ')' DELIMITED BY SIZE INTO TMP-LINE.
            CALL DSPLINE USING DFHEIBLK DFHCOMMAREA TMP-LINE MY-CURS.

            INITIALIZE TMP-LINE.
            STRING 'STR(', CSTR DELIMITED BY SIZE,
                ')' DELIMITED BY SIZE INTO TMP-LINE.
            CALL DSPLINE USING DFHEIBLK DFHCOMMAREA TMP-LINE MY-CURS.

            INITIALIZE TMP-LINE.
            MOVE DLO32 TO DSP-LO.
            STRING 'LO(', DSP-LO,
                ')' DELIMITED BY SIZE INTO TMP-LINE.
            CALL DSPLINE USING DFHEIBLK DFHCOMMAREA TMP-LINE MY-CURS.

            INITIALIZE TMP-LINE.
            MOVE LENGTH OF ECA TO AX.
            CALL DUMPHEX USING ECA AX DSP-ECA.
            STRING 'CA(', DSP-ECA DELIMITED BY SIZE,
                ')' DELIMITED BY SIZE INTO TMP-LINE.
            CALL DSPLINE USING DFHEIBLK DFHCOMMAREA TMP-LINE MY-CURS.

            INITIALIZE TMP-LINE.
            STRING 'FI(',
                FFI(1 : 10) DELIMITED BY SIZE,
                ' ... ' DELIMITED BY SIZE,
                FFI(LENGTH OF FFI - 9 : 10) DELIMITED BY SIZE,
                ')' DELIMITED BY SIZE
                INTO TMP-LINE.
            CALL DSPLINE USING DFHEIBLK DFHCOMMAREA TMP-LINE MY-CURS.

      **=============================================================**
        EXIT-PROGRAM.
            MOVE "Ended" TO LOG-TEXT.
            CALL DSPMSG USING
                DFHEIBLK
                DFHCOMMAREA
                LOG-TEXT.

            EXEC CICS RETURN END-EXEC.
