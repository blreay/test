        IDENTIFICATION DIVISION.
        PROGRAM-ID. RCVSCR.
        AUTHOR. TUXEDO DEVELOPMENT.
        ENVIRONMENT DIVISION.
        CONFIGURATION SECTION.
        DATA DIVISION.
        WORKING-STORAGE SECTION.

      **=============================================================**
      * Log messages definitions
      **=============================================================**
        01  LOG-ROUTINE PIC X(14) VALUE SPACES.
        01  DSPERR PIC X(8) VALUE "DSPERR".

        01  TP-STATUS PIC S9(8) COMP.
        01  TP-STATUS2 PIC S9(8) COMP.

        01  SCR-LEN PIC S9(9) COMP.
        01  IX PIC S9(4) COMP.
        01  JX PIC S9(4) COMP.

      **=============================================================**
        LINKAGE SECTION.
      **=============================================================**
        01  BUFFER PIC X(80).
        01  SCR-BUF PIC X(80).

      **=============================================================**
        PROCEDURE DIVISION USING BUFFER.
      **=============================================================**
        RCV-SCR.
            EXEC CICS RECEIVE
                SET(ADDRESS OF SCR-BUF)
                FLENGTH(SCR-LEN)
                MAXFLENGTH(LENGTH OF SCR-BUF)
                RESP(TP-STATUS) RESP2(TP-STATUS2)
            END-EXEC.

            PERFORM VARYING IX FROM 1 BY 1
                UNTIL SCR-BUF(IX : 1) = SPACE
                    OR IX > SCR-LEN
            END-PERFORM.
            IF (IX - 1) > 4
                MOVE "Invalid TranNM" TO LOG-ROUTINE
                CALL DSPERR USING
                    DFHEIBLK
                    DFHCOMMAREA
                    LOG-ROUTINE
                    TP-STATUS
                    TP-STATUS2
                EXEC CICS RETURN END-EXEC
            END-IF.

            PERFORM VARYING IX FROM IX BY 1
                UNTIL SCR-BUF(IX : 1) NOT = SPACE
                    OR IX > SCR-LEN
            END-PERFORM.
            MOVE IX TO JX.
            PERFORM VARYING IX FROM IX BY 1
      *         UNTIL SCR-BUF(IX : 1) = SPACE
      *             OR IX > SCR-LEN
                UNTIL IX > SCR-LEN
            END-PERFORM.
            IF IX > JX
                MOVE SCR-BUF(JX : IX - JX) TO BUFFER
            ELSE
                INITIALIZE BUFFER
            END-IF.

            EXIT PROGRAM.
