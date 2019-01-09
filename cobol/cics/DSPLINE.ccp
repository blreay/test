        IDENTIFICATION DIVISION.
        PROGRAM-ID. DSPLINE.
        AUTHOR. TUXEDO DEVELOPMENT.
        ENVIRONMENT DIVISION.
        CONFIGURATION SECTION.
        DATA DIVISION.
        WORKING-STORAGE SECTION.
      **=============================================================**
        LINKAGE SECTION.
        77  TXT PIC X(80).
        77  CURS PIC S9(4) COMP.

      **=============================================================**
        PROCEDURE DIVISION USING TXT, CURS.
      **=============================================================**
        DSP-LINE.
            IF EIBTRMID NOT = X'00000000'
            THEN
                IF CURS = 0
                    EXEC CICS SEND
                        FROM(TXT) LENGTH(LENGTH OF TXT)
                        ERASE
                    END-EXEC
                ELSE
                    EXEC CICS SEND
                        FROM(TXT) LENGTH(LENGTH OF TXT)
                    END-EXEC
                END-IF
                ADD 80 TO CURS
      * Cannot exceed 24 rows
                IF CURS = 1920
                    MOVE 0 TO CURS
                END-IF
                EXEC CICS SEND CONTROL
                    CURSOR(CURS)
                END-EXEC
            END-IF.

            EXIT PROGRAM.
