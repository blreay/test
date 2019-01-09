      **=============================================================**
      ** Server BUFSRV From Client(bufclt) On Tuxedo
      **=============================================================**
        IDENTIFICATION DIVISION.
        PROGRAM-ID. DATSRV.
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
            03  DUMPHEX PIC X(8) VALUE "DUMPHEX".
            03  LOG-TEXT PIC X(50) VALUE SPACES.

      **=============================================================**
        01  FILLER.
            03  OP PIC X(1).
            03  AX PIC S9(4) COMP.
            03  IX PIC S9(4) COMP.

        01  FILLER.
            03  DSP-SH PIC 9(4).
            03  DSP-LO PIC +9(18).
            03  DSP-HEX PIC X(40).

      **=============================================================**
        LINKAGE SECTION.
      **=============================================================**
        01  DFHCOMMAREA.
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

      *     DISPLAY 'DATSRV:CHAR(' A-CHAR ')'.
            INITIALIZE LOG-TEXT.
            STRING 'CHAR(', A-CHAR,
                ')' DELIMITED BY SIZE INTO LOG-TEXT.
            CALL DSPMSG USING DFHEIBLK DFHCOMMAREA LOG-TEXT.

      *     DISPLAY 'DATSRV:SHORT(' B-SHORT ')'.
            INITIALIZE LOG-TEXT.
            MOVE B-SHORT TO DSP-SH.
            STRING 'SHORT(', DSP-SH,
                ')' DELIMITED BY SIZE INTO LOG-TEXT.
            CALL DSPMSG USING DFHEIBLK DFHCOMMAREA LOG-TEXT.

      *     DISPLAY 'DATSRV:STRING(' C-STRING ')'.
            INITIALIZE LOG-TEXT.
            STRING 'STRING(', C-STRING DELIMITED BY SPACE,
                ')' DELIMITED BY SIZE INTO LOG-TEXT.
            CALL DSPMSG USING DFHEIBLK DFHCOMMAREA LOG-TEXT.

      *     DISPLAY 'DATSRV:LONG32(' D-LONG32 ')'.
            INITIALIZE LOG-TEXT.
            MOVE D-LONG32 TO DSP-LO
            STRING 'LONG32(', DSP-LO,
                ')' DELIMITED BY SIZE INTO LOG-TEXT.
            CALL DSPMSG USING DFHEIBLK DFHCOMMAREA LOG-TEXT.

      *     DISPLAY 'DATSRV:CARRAY(' E-CARRAY ')'.
            INITIALIZE LOG-TEXT.
            MOVE LENGTH OF E-CARRAY TO IX.
            CALL DUMPHEX USING E-CARRAY IX DSP-HEX.
            STRING 'CARRAY(', DSP-HEX DELIMITED BY SIZE,
                ')' DELIMITED BY SIZE INTO LOG-TEXT.
            CALL DSPMSG USING DFHEIBLK DFHCOMMAREA LOG-TEXT.

      *     DISPLAY 'DATSRV:ZONED(' F-ZONED ')'.
            INITIALIZE LOG-TEXT.
            STRING 'ZONED(', X-ZONED DELIMITED BY SIZE,
                ')' DELIMITED BY SIZE INTO LOG-TEXT.
            CALL DSPMSG USING DFHEIBLK DFHCOMMAREA LOG-TEXT.

      *     DISPLAY 'DATSRV:FLOAT(' G-FLOAT ')'.
            INITIALIZE LOG-TEXT DSP-HEX.
            MOVE LENGTH OF X-FLOAT TO IX.
            CALL DUMPHEX USING X-FLOAT IX DSP-HEX.
            STRING 'FLOAT(', DSP-HEX DELIMITED BY SPACE,
                ')' DELIMITED BY SIZE INTO LOG-TEXT.
            CALL DSPMSG USING DFHEIBLK DFHCOMMAREA LOG-TEXT.

      *     DISPLAY 'DATSRV:DOUBLE(' H-DOUBLE ')'.
            INITIALIZE LOG-TEXT DSP-HEX.
            MOVE LENGTH OF X-DOUBLE TO IX.
            CALL DUMPHEX USING X-DOUBLE IX DSP-HEX.
            STRING 'DOUBLE(', DSP-HEX DELIMITED BY SPACE,
                ')' DELIMITED BY SIZE INTO LOG-TEXT.
            CALL DSPMSG USING DFHEIBLK DFHCOMMAREA LOG-TEXT.

      *     DISPLAY 'DATSRV:PACKED(' I-PACKED ')'.
            INITIALIZE LOG-TEXT DSP-HEX.
            MOVE LENGTH OF X-PACKED TO IX.
            CALL DUMPHEX USING X-PACKED IX DSP-HEX.
            STRING 'PACKED(', DSP-HEX DELIMITED BY SPACE,
                ')' DELIMITED BY SIZE INTO LOG-TEXT.
            CALL DSPMSG USING DFHEIBLK DFHCOMMAREA LOG-TEXT.

      **=============================================================**
      * Process program
      **=============================================================**
        DO-PROGRAM.
            MOVE A-CHAR TO OP.

            COMPUTE AX = FUNCTION ORD(A-CHAR) -
                FUNCTION ORD('1') + FUNCTION ORD('A').
            MOVE FUNCTION CHAR(AX) TO A-CHAR.

            MOVE EIBCALEN TO B-SHORT.

            INITIALIZE C-STRING.
            INSPECT C-STRING REPLACING ALL SPACE BY A-CHAR.

            SUBTRACT 1 FROM D-LONG32.

            INITIALIZE E-CARRAY.
            INSPECT E-CARRAY REPLACING ALL SPACE BY OP.

            SUBTRACT 1 FROM F-ZONED.
            SUBTRACT 1 FROM G-FLOAT.
            SUBTRACT 1 FROM H-DOUBLE.
            SUBTRACT 1 FROM I-PACKED.

      **=============================================================**
      *Leave Application
      **=============================================================**
        EXIT-PROGRAM.
            MOVE "Ended" TO LOG-TEXT.
            CALL DSPMSG USING DFHEIBLK DFHCOMMAREA LOG-TEXT.
            EXEC CICS RETURN
            END-EXEC.
