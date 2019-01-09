        IDENTIFICATION DIVISION.
        PROGRAM-ID. RECCLT.
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

      **=============================================================**

        01  REMOTE-SYS PIC X(4) VALUE SPACES.
        01  REMOTE-SVC PIC X(16) VALUE SPACES.
        01  SCREEN-LEN PIC S9(4) COMP-5.
        01  COMM-LEN PIC S9(4) COMP-5.
      * 01  RESPONSE-LEN PIC S9(4) COMP-5.

        01  FILLER PIC X(1).
            88  LONG-32 VALUE '1'.
            88  LONG-64 VALUE '2'.

        77  IX PIC S9(4) COMP.
        77  JX PIC S9(4) COMP.
        77  MY-CURS PIC S9(4) COMP VALUE 0.
        77  DSP-SH PIC 9(5).
        77  DSP-LO PIC +9(18).
        77  DSP-ECA PIC X(40).

      **=============================================================**
        LINKAGE SECTION.
      **=============================================================**
        01  SCREEN-BUF.
            05  FILLER PIC X(5).
            05  REQUEST-MSG PIC X(40).
        01  COMMAREA.
            COPY BUFCPY.

      **=============================================================**
        PROCEDURE DIVISION.
      **=============================================================**
        MAIN.
            PERFORM START-PROGRAM.
            PERFORM DO-PGM.
            PERFORM EXIT-PROGRAM.

      **=============================================================**
      * Start program with command line args
      **=============================================================**
        START-PROGRAM.
            MOVE "Started" TO LOG-TEXT.
            CALL DSPMSG USING
                DFHEIBLK
                DFHCOMMAREA
                LOG-TEXT.

            IF EIBTRNID(4 : 1) NOT = '1'
                SET LONG-32 TO TRUE
            ELSE
                SET LONG-64 TO TRUE
            END-IF.

            EXEC CICS RECEIVE
                SET(ADDRESS OF SCREEN-BUF)
                LENGTH(SCREEN-LEN)
                MAXLENGTH(LENGTH OF SCREEN-BUF)
                RESP(TP-STATUS)
                RESP2(TP-STATUS2)
            END-EXEC.
            IF EIBRESP NOT = DFHRESP(EOC)
                MOVE "CICS RECEIVE" TO LOG-ROUTINE
                CALL DSPERR USING
                    DFHEIBLK
                    DFHCOMMAREA
                    LOG-ROUTINE
                    TP-STATUS
                    TP-STATUS2
                EXEC CICS RETURN
                END-EXEC
            END-IF.

            PERFORM VARYING IX FROM 5 BY 1
                UNTIL SCREEN-BUF(IX : 1) NOT = SPACE
                    OR IX > SCREEN-LEN
            END-PERFORM.
            MOVE IX TO JX.
            PERFORM VARYING IX FROM IX BY 1
                UNTIL SCREEN-BUF(IX : 1) = SPACE
                    OR IX > SCREEN-LEN
            END-PERFORM.
            IF IX = JX
                MOVE "NO remote sys" TO LOG-ROUTINE
                CALL DSPERR USING
                    DFHEIBLK
                    DFHCOMMAREA
                    LOG-ROUTINE
                    TP-STATUS
                    TP-STATUS2
                EXEC CICS RETURN
                END-EXEC
            END-IF.
            MOVE SCREEN-BUF(JX : IX - JX) TO REMOTE-SYS.

            PERFORM VARYING IX FROM IX BY 1
                UNTIL SCREEN-BUF(IX : 1) NOT = SPACE
                    OR IX > SCREEN-LEN
            END-PERFORM.
            MOVE IX TO JX.
            PERFORM VARYING IX FROM IX BY 1
                UNTIL IX > SCREEN-LEN
            END-PERFORM.
            IF IX = JX
                MOVE "NO remote svc" TO LOG-ROUTINE
                CALL DSPERR USING
                    DFHEIBLK
                    DFHCOMMAREA
                    LOG-ROUTINE
                    TP-STATUS
                    TP-STATUS2
                EXEC CICS RETURN
                END-EXEC
            END-IF.
            MOVE SCREEN-BUF(JX : IX - JX) TO REMOTE-SVC.

      **=============================================================**
      *  Issue a TPCALL
      **=============================================================**
        DO-PGM.
            EXEC CICS GETMAIN
                SET(ADDRESS OF COMMAREA)
                FLENGTH(LENGTH OF COMMAREA)
                RESP(TP-STATUS)
                RESP2(TP-STATUS2)
            END-EXEC.
            IF EIBRESP NOT = DFHRESP(NORMAL)
                MOVE "CICS GETMAIN" TO LOG-ROUTINE
                CALL DSPERR USING
                    DFHEIBLK
                    DFHCOMMAREA
                    LOG-ROUTINE
                    TP-STATUS
                    TP-STATUS2
                EXEC CICS RETURN
                END-EXEC
            END-IF.

            INITIALIZE COMMAREA.
            MOVE "1" TO ACH.
            MOVE EIBTRNID TO CSTR.
            MOVE LENGTH OF HEAD TO BSH.
            IF LONG-32
                ADD LENGTH OF DLO32, LENGTH OF ECA TO BSH
                MOVE -999999999 TO DLO32
      *         MOVE ALL X"01" TO ECA
      *
                PERFORM VARYING IX FROM 1 BY 1 UNTIL IX > 2
                    COMPUTE JX = IX + FUNCTION ORD('0')
                    INITIALIZE EACH(IX)
                    INSPECT EACH(IX) REPLACING ALL SPACE BY
                        FUNCTION CHAR(JX)
                    MOVE IX TO EBSH(IX)
                    INITIALIZE ECED(IX)
                    INSPECT ECED(IX) REPLACING ALL SPACE BY
                        FUNCTION CHAR(JX)
                END-PERFORM
      *
            ELSE
                ADD LENGTH OF DLO64, LENGTH OF ECA1 TO BSH
                MOVE -999999999999999999 TO DLO64
                MOVE ALL X"01" TO ECA1
            END-IF.

            MOVE "SEND:" TO TMP-LINE.
            CALL DSPLINE USING DFHEIBLK DFHCOMMAREA TMP-LINE MY-CURS.
            PERFORM DISP-COMMAREA.

            MOVE LENGTH OF COMMAREA TO COMM-LEN.
            EXEC CICS LINK
                PROGRAM(REMOTE-SVC)
                LENGTH(COMM-LEN)
                DATALENGTH(BSH)
                COMMAREA(COMMAREA)
                SYNCONRETURN
                SYSID(REMOTE-SYS)
                RESP(TP-STATUS)
                RESP2(TP-STATUS2)
            END-EXEC
      * Cannot use length of commarea because it is COMP
      *         LENGTH(LENGTH OF COMMAREA)
            IF EIBRESP NOT = DFHRESP(NORMAL)
                MOVE "CICS LINK" TO LOG-ROUTINE
                CALL DSPERR USING
                    DFHEIBLK
                    DFHCOMMAREA
                    LOG-ROUTINE
                    TP-STATUS
                    TP-STATUS2
                EXEC CICS RETURN
                END-EXEC
            END-IF.

            MOVE "RECV:" TO TMP-LINE.
            CALL DSPLINE USING DFHEIBLK DFHCOMMAREA TMP-LINE MY-CURS.
            PERFORM DISP-COMMAREA.

            EXEC CICS FREEMAIN
                DATA(COMMAREA)
                RESP(TP-STATUS)
                RESP2(TP-STATUS2)
            END-EXEC
            IF EIBRESP NOT = DFHRESP(NORMAL)
                MOVE "CICS FREEMAIN" TO LOG-ROUTINE
                CALL DSPERR USING
                    DFHEIBLK
                    DFHCOMMAREA
                    LOG-ROUTINE
                    TP-STATUS
                    TP-STATUS2
                EXEC CICS RETURN
                END-EXEC
            END-IF.

      **=============================================================**
      * Log messages to the userlog
      **=============================================================**
        DISP-COMMAREA.
            INITIALIZE TMP-LINE.
            STRING 'CH(', ACH DELIMITED BY SIZE,
                ')' DELIMITED BY SIZE INTO TMP-LINE.
            CALL DSPLINE USING DFHEIBLK DFHCOMMAREA TMP-LINE MY-CURS.

            INITIALIZE TMP-LINE.
            MOVE BSH TO DSP-SH.
            STRING 'SH(', DSP-SH,
                ')' DELIMITED BY SIZE INTO TMP-LINE.
            CALL DSPLINE USING DFHEIBLK DFHCOMMAREA TMP-LINE MY-CURS.

            INITIALIZE TMP-LINE.
            STRING 'STR(', CSTR DELIMITED BY SIZE,
                ')' DELIMITED BY SIZE INTO TMP-LINE.
            CALL DSPLINE USING DFHEIBLK DFHCOMMAREA TMP-LINE MY-CURS.

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
                MOVE LENGTH OF ECA TO IX
                CALL DUMPHEX USING
                    ECA
                    IX
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
                MOVE LENGTH OF ECA1 TO IX
                CALL DUMPHEX USING
                    ECA1
                    IX
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
      *Leave Application
      **=============================================================**
        EXIT-PROGRAM.
            MOVE "Ended" TO LOG-TEXT.
            CALL DSPMSG USING
                DFHEIBLK
                DFHCOMMAREA
                LOG-TEXT.
            EXEC CICS RETURN
            END-EXEC.
