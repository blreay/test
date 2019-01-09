       IDENTIFICATION DIVISION.
       PROGRAM-ID. WRITEINDEXV14.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       SELECT MW-SORTIE
              ASSIGN TO DATAIDX
              ORGANIZATION IS INDEXED
              ACCESS IS DYNAMIC
              RECORD KEY IS S-ID
              FILE STATUS IS IO-STATUS.
      
       DATA DIVISION.
       FILE SECTION.
      
       FD  MW-SORTIE
           LABEL RECORD STANDARD
           RECORDING MODE IS V
           RECORD IS VARYING IN SIZE FROM 2 TO 14
           DEPENDING ON MW-SORTIE-REC-LEN
           DATA RECORD MW-SORTIE-REC.
       01  MW-SORTIE-REC.
           02 DATAV14.
              04 S-ID                 PIC X(02).
              04 S-NAME               PIC X(04).
              04 S-VALUE              PIC X(08).

       WORKING-STORAGE SECTION.

       01  MW-SORTIE-REC-LEN          PIC X(4) COMP-X.

       01  IO-STATUS                  PIC XX.
       01  NB-RECS                    PIC 9(9) VALUE 0.
      
 
       PROCEDURE DIVISION.
       P-START.
           OPEN OUTPUT MW-SORTIE
           IF IO-STATUS NOT = "00"
             DISPLAY "FILELD-0202: OUTPUT FAILED"
             DISPLAY "ASSIGN: SORTIE"
             DISPLAY "IO-STATUS =" IO-STATUS
             GO TO FIN-ERREUR
           END-IF.
      
       WRITE-1.
           MOVE SPACES      TO MW-SORTIE-REC.
           MOVE "11"        TO S-ID.
           MOVE "AAAA"      TO S-NAME.
           MOVE "aaaaaaaa"  TO S-VALUE.
           MOVE 14          TO MW-SORTIE-REC-LEN.
           WRITE MW-SORTIE-REC
            INVALID KEY
             DISPLAY "ERROR:"
 Error       DISPLAY "FILELD-0203: WRITE FAILED"
 Error       DISPLAY "ASSIGN: SORTIE"
             DISPLAY "IO-STATUS =" IO-STATUS
             GO TO FIN-ERREUR
           END-WRITE.
           ADD 1 TO NB-RECS.

        WRITE-2.
           MOVE SPACES      TO MW-SORTIE-REC.
           MOVE "22"        TO S-ID.
           MOVE "BBBB"      TO S-NAME.
           MOVE "bbbbbbbb"  TO S-VALUE.
           MOVE 14          TO MW-SORTIE-REC-LEN.
           WRITE MW-SORTIE-REC
            INVALID KEY
             DISPLAY "ERROR:"
 Error       DISPLAY "FILELD-0203: WRITE FAILED"
 Error       DISPLAY "ASSIGN: SORTIE"
             DISPLAY "IO-STATUS =" IO-STATUS
             GO TO FIN-ERREUR
           END-WRITE.
           ADD 1 TO NB-RECS.

        WRITE-3.
           MOVE SPACES      TO MW-SORTIE-REC.
           MOVE "33"        TO S-ID.
           MOVE "CCCC"      TO S-NAME.
           MOVE "cccccccc"  TO S-VALUE.
           MOVE 14          TO MW-SORTIE-REC-LEN.
           WRITE MW-SORTIE-REC
            INVALID KEY
             DISPLAY "ERROR:"
 Error       DISPLAY "FILELD-0203: WRITE FAILED"
 Error       DISPLAY "ASSIGN: SORTIE"
             DISPLAY "IO-STATUS =" IO-STATUS
             GO TO FIN-ERREUR
           END-WRITE.
           ADD 1 TO NB-RECS.
      
       WRITE-4.
           MOVE SPACES      TO MW-SORTIE-REC.
           MOVE "44"        TO S-ID.
           MOVE "DDDD"      TO S-NAME.
           MOVE "dddddddd"  TO S-VALUE.
           MOVE 14          TO MW-SORTIE-REC-LEN.
           WRITE MW-SORTIE-REC
            INVALID KEY
             DISPLAY "ERROR:"
 Error       DISPLAY "FILELD-0203: WRITE FAILED"
 Error       DISPLAY "ASSIGN: SORTIE"
             DISPLAY "IO-STATUS =" IO-STATUS
             GO TO FIN-ERREUR
           END-WRITE.
           ADD 1 TO NB-RECS.

        WRITE-5.
           MOVE SPACES      TO MW-SORTIE-REC.
           MOVE "55"        TO S-ID.
           MOVE "EEEE"      TO S-NAME.
           MOVE "eeeeeeee"  TO S-VALUE.
           MOVE 14          TO MW-SORTIE-REC-LEN.
           WRITE MW-SORTIE-REC
            INVALID KEY
             DISPLAY "ERROR:"
 Error       DISPLAY "FILELD-0203: WRITE FAILED"
 Error       DISPLAY "ASSIGN: SORTIE"
             DISPLAY "IO-STATUS =" IO-STATUS
             GO TO FIN-ERREUR
           END-WRITE.
           ADD 1 TO NB-RECS.
 
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
      
       END-COMMON-DISPLAY.
           CLOSE MW-SORTIE.
      
