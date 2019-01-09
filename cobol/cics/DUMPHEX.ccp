        IDENTIFICATION DIVISION.
        PROGRAM-ID. DUMPHEX.
        AUTHOR. TUXEDO DEVELOPMENT.
        ENVIRONMENT DIVISION.
        CONFIGURATION SECTION.
        DATA DIVISION.

      **=============================================================**
        WORKING-STORAGE SECTION.
        01  HEXTAB PIC X(16) VALUE "0123456789abcdef".
        01  IX PIC 9(4) COMP.
        01  JX PIC 9(4) COMP.
        01  DI PIC 9(4) COMP.
        01  FILLER REDEFINES DI.
            05  BYTE1 PIC X.
            05  BYTE2 PIC X.
        01  QU PIC 9(4) COMP.
        01  RE PIC 9(4) COMP.
        01  FILLER PIC X(1).
            88  BIG-ENDIAN VALUE '1'.
            88  SMALL-ENDIAN VALUE '2'.

      **=============================================================**
        LINKAGE SECTION.
        01  BUF PIC X.
        01  LEN PIC S9(4) COMP.
        01  HEXS PIC X.

      **=============================================================**
        PROCEDURE DIVISION USING BUF, LEN, HEXS.

        DUMP-HEX.
            MOVE 0 TO DI.
            MOVE X'01' TO BYTE1.
            IF DI = 256
                SET BIG-ENDIAN TO TRUE
            ELSE
                SET SMALL-ENDIAN TO TRUE
            END-IF.

            PERFORM VARYING IX FROM 1 BY 1 UNTIL IX > LEN
                COMPUTE JX = 2 * IX - 1
                MOVE 0 TO DI
                IF BIG-ENDIAN
                    MOVE BUF(IX : 1) TO BYTE2
                ELSE
                    MOVE BUF(IX : 1) TO BYTE1
                END-IF
                DIVIDE DI BY 16 GIVING QU REMAINDER RE
      *         display "dumphex(" di "," qu "," re ")"
                MOVE HEXTAB(QU + 1 : 1) TO HEXS(JX : 1)
                MOVE HEXTAB(RE + 1 : 1) TO HEXS(JX + 1 : 1)
            END-PERFORM.

            EXIT PROGRAM.
