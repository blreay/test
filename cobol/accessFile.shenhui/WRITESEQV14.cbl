       IDENTIFICATION DIVISION.
       PROGRAM-ID. WRITESEQXV14.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       SELECT MW-SORTIE
              ASSIGN TO DATAFILE
              ORGANIZATION IS SEQUENTIAL
              ACCESS IS SEQUENTIAL
              FILE STATUS IS IO-STATUS.
      
       DATA DIVISION.
       FILE SECTION.
      
       FD  MW-SORTIE
           LABEL RECORD STANDARD
           RECORDING MODE IS V
           RECORD IS VARYING IN SIZE FROM 1 TO 14
           DEPENDING ON MW-SORTIE-REC-LEN
           DATA RECORD MW-SORTIE-REC.
       01  MW-SORTIE-REC.
           02 DATAV14.
              04 S-ID                 PIC X(02).
              04 S-NAME               PIC X(04).
              04 S-VALUE              PIC X(10).

       WORKING-STORAGE SECTION.

       01  MW-SORTIE-REC-LEN          PIC X(4) COMP-X.

       01  IO-STATUS                  PIC XX.
       01  NB-RECS                    PIC 9(8) VALUE 0.
      
 
       PROCEDURE DIVISION.
       P-START.
           OPEN OUTPUT MW-SORTIE
           IF IO-STATUS NOT = "00"
             DISPLAY "FILELD-0202: OUTPUT FAILED"
             DISPLAY "ASSIGN: SORTIE"
             DISPLAY "IO-STATUS =" IO-STATUS
             GO TO FIN-ERREUR
           END-IF.
      

           PERFORM 6 TIMES
            ADD 1 TO NB-RECS

            MOVE SPACES      TO MW-SORTIE-REC
            MOVE "BB"        TO S-ID
            MOVE "bbbb"      TO S-NAME
            MOVE HIGH-VALUES TO S-VALUE
            MOVE NB-RECS     TO S-VALUE

            MOVE 14          TO MW-SORTIE-REC-LEN

            WRITE MW-SORTIE-REC
            PERFORM CHECK-IO THRU E-CHECK-IO

           END-PERFORM.
 
       FIN-REL.
           DISPLAY "WRITE DONE, ITEM: " NB-RECS.
           PERFORM END-COMMON-DISPLAY.
      
           EXIT PROGRAM.
           STOP RUN.
      
       FIN-ERREUR.
           DISPLAY "WRITE FAILED".
           PERFORM END-COMMON-DISPLAY.
      
           EXIT PROGRAM.
           STOP RUN RETURNING 1.
      

       CHECK-IO.
           IF IO-STATUS NOT = "00"
             DISPLAY "FILELD-0202: WRITE FAILED"
             DISPLAY "ASSIGN: SORTIE"
             DISPLAY "IO-STATUS =" IO-STATUS
             GO TO FIN-ERREUR
           END-IF.
       E-CHECK-IO.

       END-COMMON-DISPLAY.
           CLOSE MW-SORTIE.
      
