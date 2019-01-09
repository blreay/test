      **=============================================================**
      ** Server BUFSRV From Client(bufclt) On Tuxedo
      **=============================================================**
        IDENTIFICATION DIVISION.
        PROGRAM-ID. BUFSRV.
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
        01  FILLER PIC X(1).
            88  LONG-32 VALUE '1'.
            88  LONG-64 VALUE '2'.

        77  OP PIC X(1).
        77  AX PIC S9(4) COMP.
        77  IX PIC S9(4) COMP.
        77  JX PIC S9(4) COMP.
        77  DSP-SH PIC 9(4).
        77  DSP-LO PIC +9(18).
        77  DSP-ECA PIC X(40).

      **=============================================================**
        LINKAGE SECTION.
      **=============================================================**
        01  DFHCOMMAREA.
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
                MOVE LENGTH OF ECA TO IX
                CALL DUMPHEX USING ECA IX DSP-ECA
            ELSE
                MOVE LENGTH OF ECA1 TO IX
                CALL DUMPHEX USING ECA1 IX DSP-ECA
            END-IF.
            STRING 'ECA(', DSP-ECA DELIMITED BY SIZE,
                ')' DELIMITED BY SIZE INTO LOG-TEXT.
            CALL DSPMSG USING
                DFHEIBLK
                DFHCOMMAREA
                LOG-TEXT.

      **=============================================================**
      * Process program
      **=============================================================**
        DO-PGM.
            MOVE ACH TO OP.

            COMPUTE AX = FUNCTION ORD(ACH) -
                FUNCTION ORD('1') + FUNCTION ORD('A').
            MOVE FUNCTION CHAR(AX) TO ACH.

            MOVE EIBCALEN TO BSH.

            INITIALIZE CSTR.
            INSPECT CSTR REPLACING ALL SPACE BY ACH.

            IF LONG-32
                SUBTRACT 1 FROM DLO32
            ELSE
                SUBTRACT 1 FROM DLO64
            END-IF.

            EVALUATE OP
                WHEN '1'
                WHEN '3'
                WHEN '4'
                    IF LONG-32
                        INITIALIZE ECA
                        INSPECT ECA REPLACING ALL SPACE BY OP
                    ELSE
                        INITIALIZE ECA1
                        INSPECT ECA1 REPLACING ALL SPACE BY OP
                    END-IF
                WHEN '2'
                WHEN '5'
                WHEN '6'
                    PERFORM VARYING IX FROM 1 BY 1 UNTIL IX > 2
                        IF LONG-32
                            MULTIPLY 2 BY EBSH(IX)
                            INSPECT ECED(IX) CONVERTING
                                'abcdefghijklmnopqrstuvwxyz' TO
                                'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                        ELSE
                            MULTIPLY 2 BY EBSH1(IX)
                            INSPECT ECED1(IX) CONVERTING
                                'abcdefghijklmnopqrstuvwxyz' TO
                                'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                        END-IF
                    END-PERFORM

            END-EVALUATE.

            IF LONG-32
      *         MOVE ALL "0123456789" TO FFI1
                INITIALIZE FFI
                MOVE "0123456789" TO FFI
                MOVE "0123456789" TO FFI(LENGTH OF FFI - 9 : 10)
            ELSE
      *         MOVE ALL "0123456789" TO FFI
                INITIALIZE FFI1
                MOVE "0123456789" TO FFI1
                MOVE "0123456789" TO FFI1(LENGTH OF FFI1 - 9 : 10)
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
