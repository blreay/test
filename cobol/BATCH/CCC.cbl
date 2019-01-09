       IDENTIFICATION DIVISION.
       PROGRAM-ID. CCC.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       SELECT MW-SORTIE
              ASSIGN TO INOUTF
              ORGANIZATION IS RELATIVE
              ACCESS IS DYNAMIC
              RELATIVE KEY IS REL-KEY
              FILE STATUS IS IO-STATUS.
      
       DATA DIVISION.
       FILE SECTION.
      
       FD  MW-SORTIE
           LABEL RECORD STANDARD
           DATA RECORD DATAF16-REC.
       COPY DATAF16.

       WORKING-STORAGE SECTION.

       01  IO-STATUS                  PIC XX.
       01  REL-KEY                    PIC 9(8).
      
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
           MOVE 1 TO REL-KEY.
           MOVE SPACES      TO DATAF16-REC.
           MOVE "55"        TO S-ID.
           MOVE "EEEE"      TO S-NAME.
           MOVE "eeeeeeeeee"  TO S-VALUE.
           WRITE DATAF16-REC
            INVALID KEY
             DISPLAY "ERROR:"
 Error       DISPLAY "FILELD-0203: WRITE FAILED"
 Error       DISPLAY "ASSIGN: SORTIE"
             DISPLAY "IO-STATUS =" IO-STATUS
             GO TO FIN-ERREUR
           END-WRITE.

       WRITE-2.
           MOVE 2 TO REL-KEY.
           MOVE SPACES      TO DATAF16-REC.
           MOVE "44"        TO S-ID.
           MOVE "DDDD"      TO S-NAME.
           MOVE "dddddddddd"  TO S-VALUE.
           WRITE DATAF16-REC
            INVALID KEY
             DISPLAY "ERROR:"
 Error       DISPLAY "FILELD-0203: WRITE FAILED"
 Error       DISPLAY "ASSIGN: SORTIE"
             DISPLAY "IO-STATUS =" IO-STATUS
             GO TO FIN-ERREUR
           END-WRITE.
 
       WRITE-3.
           MOVE 3 TO REL-KEY.
           MOVE SPACES      TO DATAF16-REC.
           MOVE "33"        TO S-ID.
           MOVE "CCCC"      TO S-NAME.
           MOVE "cccccccccc"  TO S-VALUE.
           WRITE DATAF16-REC
            INVALID KEY
             DISPLAY "ERROR:"
 Error       DISPLAY "FILELD-0203: WRITE FAILED"
 Error       DISPLAY "ASSIGN: SORTIE"
             DISPLAY "IO-STATUS =" IO-STATUS
             GO TO FIN-ERREUR
           END-WRITE.

       WRITE-4.
           MOVE 4 TO REL-KEY.
           MOVE SPACES      TO DATAF16-REC.
           MOVE "22"        TO S-ID.
           MOVE "BBBB"      TO S-NAME.
           MOVE "bbbbbbbbbb"  TO S-VALUE.
           WRITE DATAF16-REC
            INVALID KEY
             DISPLAY "ERROR:"
 Error       DISPLAY "FILELD-0203: WRITE FAILED"
 Error       DISPLAY "ASSIGN: SORTIE"
             DISPLAY "IO-STATUS =" IO-STATUS
             GO TO FIN-ERREUR
           END-WRITE.
      
       WRITE-5.
           MOVE 5 TO REL-KEY.
           MOVE SPACES      TO DATAF16-REC.
           MOVE "11"        TO S-ID.
           MOVE "AAAA"      TO S-NAME.
           MOVE "aaaaaaaaaa"  TO S-VALUE.
           WRITE DATAF16-REC
            INVALID KEY
             DISPLAY "ERROR:"
 Error       DISPLAY "FILELD-0203: WRITE FAILED"
 Error       DISPLAY "ASSIGN: SORTIE"
             DISPLAY "IO-STATUS =" IO-STATUS
             GO TO FIN-ERREUR
           END-WRITE.

       FIN-REL.
           DISPLAY "WRITE CCC DONE".
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
      
