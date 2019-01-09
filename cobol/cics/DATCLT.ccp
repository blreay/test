        IDENTIFICATION DIVISION.
        PROGRAM-ID. DATCLT.
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
        01  FILLER.
            03  WS-SYSID PIC X(4) VALUE SPACES.
            03  WS-PROC PIC X(8) VALUE SPACES.
            03  WS-NUM PIC 9(1) VALUE 0.
            03  WS-TIMES PIC 9(4) VALUE 0.

        01  FILLER.
            03  COMM-LEN PIC S9(4) COMP-5.
            03  IX PIC S9(4) COMP.

        01  FILLER.
            03  MY-CURS PIC S9(04) COMP VALUE 0.
            03  DSP-SH PIC 9(05).
            03  DSP-LO PIC +9(18).
            03  DSP-HEX PIC X(40).

      **=============================================================**
        LINKAGE SECTION.
      **=============================================================**
        01  COMMAREA.
            COPY DATCPY.

      **=============================================================**
        PROCEDURE DIVISION.
      **=============================================================**
        MAIN.
            PERFORM START-PROGRAM.
            PERFORM DO-PROGRAM.
            PERFORM EXIT-PROGRAM.

      **=============================================================**
      * Start program with command line args
      **=============================================================**
        START-PROGRAM.
            MOVE "Started" TO LOG-TEXT.
            CALL DSPMSG USING DFHEIBLK DFHCOMMAREA LOG-TEXT.

            CALL RCVSCR USING DFHEIBLK DFHCOMMAREA TMP-LINE.
            UNSTRING TMP-LINE DELIMITED BY ' ' INTO
                WS-SYSID WS-PROC WS-TIMES.

            IF WS-PROC = SPACES
                PERFORM DSP-USAGE
            END-IF.

            IF WS-TIMES IS NOT NUMERIC OR WS-TIMES < 1
                MOVE 1 TO WS-TIMES
            END-IF.

      **=============================================================**
        DSP-USAGE.
            INITIALIZE TMP-LINE.
            STRING 'USAGE: ', EIBTRNID,
                ' RMTSYS RMTPGM' DELIMITED BY SIZE INTO TMP-LINE.
            CALL DSPLINE USING DFHEIBLK DFHCOMMAREA TMP-LINE MY-CURS.
            EXEC CICS RETURN END-EXEC.

      **=============================================================**
      *  Issue a TPCALL
      **=============================================================**
        DO-PROGRAM.
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

            MOVE "1" TO A-CHAR.
            MOVE EIBTRNID TO C-STRING.
            MOVE LENGTH OF COMMAREA TO B-SHORT.
            MOVE 999999999 TO D-LONG32.
            MOVE ALL X"01" TO E-CARRAY.
            MOVE 12345.67 TO F-ZONED.
            MOVE 1234567.89 TO G-FLOAT.
            MOVE -1234567.89 TO H-DOUBLE.
            MOVE 1234567.89 TO I-PACKED.

            MOVE "SEND:" TO TMP-LINE.
            CALL DSPLINE USING DFHEIBLK DFHCOMMAREA TMP-LINE MY-CURS.
            PERFORM DISP-COMMAREA.

            MOVE LENGTH OF COMMAREA TO COMM-LEN.
            EXEC CICS LINK
                PROGRAM(WS-PROC)
                LENGTH(COMM-LEN)
                DATALENGTH(B-SHORT)
                COMMAREA(COMMAREA)
                SYNCONRETURN
                RESP(TP-STATUS)
                RESP2(TP-STATUS2)
            END-EXEC
      *         SYSID(WS-SYSID)
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
      *     DISPLAY 'DATCLT:CHAR(' A-CHAR ')'.
            INITIALIZE TMP-LINE.
            STRING 'CHAR(', A-CHAR DELIMITED BY SIZE,
                ')' DELIMITED BY SIZE INTO TMP-LINE.
            CALL DSPLINE USING DFHEIBLK DFHCOMMAREA TMP-LINE MY-CURS.

      *     DISPLAY 'DATCLT:SHORT(' B-SHORT ')'.
            INITIALIZE TMP-LINE.
            MOVE B-SHORT TO DSP-SH.
            STRING 'SHORT(', DSP-SH,
                ')' DELIMITED BY SIZE INTO TMP-LINE.
            CALL DSPLINE USING DFHEIBLK DFHCOMMAREA TMP-LINE MY-CURS.

      *     DISPLAY 'DATCLT:STRING(' C-STRING ')'.
            INITIALIZE TMP-LINE.
            STRING 'STRING(', C-STRING DELIMITED BY SPACE,
                ')' DELIMITED BY SIZE INTO TMP-LINE.
            CALL DSPLINE USING DFHEIBLK DFHCOMMAREA TMP-LINE MY-CURS.

      *     DISPLAY 'DATCLT:LONG32(' D-LONG32 ')'.
            INITIALIZE TMP-LINE.
            MOVE D-LONG32 TO DSP-LO.
            STRING 'LONG32(', DSP-LO,
                ')' DELIMITED BY SIZE INTO TMP-LINE.
            CALL DSPLINE USING DFHEIBLK DFHCOMMAREA TMP-LINE MY-CURS.

      *     DISPLAY 'DATCLT:CARRAY(' E-CARRAY ')'.
            INITIALIZE TMP-LINE.
            MOVE LENGTH OF E-CARRAY TO IX.
            CALL DUMPHEX USING E-CARRAY IX DSP-HEX.
            STRING 'CARRAY(', DSP-HEX DELIMITED BY SIZE,
                ')' DELIMITED BY SIZE INTO TMP-LINE.
            CALL DSPLINE USING DFHEIBLK DFHCOMMAREA TMP-LINE MY-CURS.

      *     DISPLAY 'DATCLT:ZONED(' LENGTH OF F-ZONED ':' F-ZONED ')'.
            INITIALIZE TMP-LINE.
            STRING 'ZONED(', X-ZONED DELIMITED BY SIZE,
                ')' DELIMITED BY SIZE INTO TMP-LINE.
            CALL DSPLINE USING DFHEIBLK DFHCOMMAREA TMP-LINE MY-CURS.

      *     DISPLAY 'DATCLT:FLOAT(' LENGTH OF G-FLOAT ':' G-FLOAT ')'.
            INITIALIZE TMP-LINE DSP-HEX.
            MOVE LENGTH OF X-FLOAT TO IX.
            CALL DUMPHEX USING X-FLOAT IX DSP-HEX.
            STRING 'FLOAT(', DSP-HEX DELIMITED BY SPACE,
                ')' DELIMITED BY SIZE INTO TMP-LINE.
            CALL DSPLINE USING DFHEIBLK DFHCOMMAREA TMP-LINE MY-CURS.

      *     DISPLAY 'DATCLT:DOUBLE(' LENGTH OF H-DOUBLE ':'
      *         H-DOUBLE ')'.
            INITIALIZE TMP-LINE DSP-HEX.
            MOVE LENGTH OF X-DOUBLE TO IX.
            CALL DUMPHEX USING X-DOUBLE IX DSP-HEX.
            STRING 'DOUBLE(', DSP-HEX DELIMITED BY SPACE,
                ')' DELIMITED BY SIZE INTO TMP-LINE.
            CALL DSPLINE USING DFHEIBLK DFHCOMMAREA TMP-LINE MY-CURS.

      *     DISPLAY 'DATCLT:PACKED(' LENGTH OF I-PACKED ':'
      *         I-PACKED ')'.
            INITIALIZE TMP-LINE DSP-HEX.
            MOVE LENGTH OF X-PACKED TO IX.
            CALL DUMPHEX USING X-PACKED IX DSP-HEX.
            STRING 'PACKED(', DSP-HEX DELIMITED BY SPACE,
                ')' DELIMITED BY SIZE INTO TMP-LINE.
            CALL DSPLINE USING DFHEIBLK DFHCOMMAREA TMP-LINE MY-CURS.

      **=============================================================**
      *Leave Application
      **=============================================================**
        EXIT-PROGRAM.
            MOVE "Ended" TO LOG-TEXT.
            CALL DSPMSG USING DFHEIBLK DFHCOMMAREA LOG-TEXT.
            EXEC CICS RETURN
            END-EXEC.
