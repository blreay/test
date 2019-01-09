       IDENTIFICATION DIVISION.
       PROGRAM-ID. GEN3DIFF.
       AUTHOR. WEIGZHU.
       ENVIRONMENT DIVISION.
      *
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT MY-FILE
              ASSIGN TO INOUTF
              ACCESS IS SEQUENTIAL
              FILE STATUS IS IO-STATUS.

       DATA DIVISION.

       FILE SECTION.
       FD  MY-FILE
           RECORDING MODE IS F
           LABEL RECORD STANDARD
           DATA RECORD IS MY-FILE-REC.
       01  MY-FILE-REC.
           05 S-NAME    PIC X(8).
           05 S-ID      PIC S9(4).
           05 SCORE-X   PIC X(4).
           05 SCORE-N REDEFINES SCORE-X
                        PIC 9(4).
           05 SCORE-C REDEFINES SCORE-X
                        PIC 9(4).
           05 SCORE-C3 REDEFINES SCORE-X
                        PIC 9(7) COMP-3.
           05 SCORE-C5 REDEFINES SCORE-X
                        PIC 9(7) COMP-5.
           05 S-L     REDEFINES SCORE-X
                        PIC S9(4) SIGN LEADING.
           05 S-T     REDEFINES SCORE-X
                        PIC S9(4) SIGN TRAILING.
           05 S-L-S   REDEFINES SCORE-X
                        PIC S9(3) SIGN LEADING SEPARATE.
           05 S-T-S   REDEFINES SCORE-X
                        PIC S9(3) SIGN TRAILING SEPARATE.

       WORKING-STORAGE SECTION.
       01  IO-STATUS            PIC XX.
       01  MYVALUE              PIC X(2).

       PROCEDURE DIVISION.
	DISPLAY "Please input myvalue:"
	ACCEPT MYVALUE	
	DISPLAY "myvalue=" MYVALUE
           OPEN OUTPUT MY-FILE.
           IF IO-STATUS NOT = "00"
             DISPLAY "---- ERROR: OPEN FILE FAILED! -----"
             DISPLAY "IO-STATUS =" IO-STATUS
             GO TO FIN-ERREUR
           END-IF.

      * REC-1
           MOVE "ORACLE" TO S-NAME.
           MOVE 1 TO S-ID.
           MOVE "1234" TO SCORE-X.
           PERFORM WRITE-REC THRU E-WRITE-REC.

      * REC-2
           MOVE "IBM" TO S-NAME.
           MOVE 2 TO S-ID.
           MOVE 2345 TO SCORE-N.
           PERFORM WRITE-REC THRU E-WRITE-REC.

      * REC-3
           MOVE "HP" TO S-NAME.
           MOVE 3 TO S-ID.
           MOVE 3456 TO SCORE-C.
           PERFORM WRITE-REC THRU E-WRITE-REC.



           CLOSE MY-FILE.

           EXIT PROGRAM.
           STOP RUN.


       FIN-ERREUR.
           EXIT PROGRAM.
           STOP RUN.

       WRITE-REC.
           DISPLAY "-----WRITE FILE!------".
           WRITE MY-FILE-REC.
           IF IO-STATUS NOT = "00"
             DISPLAY "ERROR: WRITE FAILED!"
             DISPLAY "IO-STATUS =" IO-STATUS
             CLOSE MY-FILE
             GO TO FIN-ERREUR
           END-IF.
       E-WRITE-REC.
           EXIT.

