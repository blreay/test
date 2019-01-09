       IDENTIFICATION DIVISION.
       PROGRAM-ID. WRITESEQF16.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       SELECT MW-SORTIE
              ASSIGN TO ESDSFILE
              ORGANIZATION IS SEQUENTIAL
              ACCESS IS SEQUENTIAL
              FILE STATUS IS IO-STATUS.
      
       DATA DIVISION.
       FILE SECTION.
      
       FD  MW-SORTIE
           LABEL RECORD STANDARD
           DATA RECORD DATAF16-REC.
       COPY DATAF16.

       WORKING-STORAGE SECTION.

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
           MOVE SPACES      TO DATAF16-REC.
           MOVE "55"        TO S-ID.
           MOVE "EEEE"      TO S-NAME.
           MOVE "eeeeeeeeee"  TO S-VALUE.
           WRITE DATAF16-REC.
           PERFORM CHECK-IO THRU E-CHECK-IO.
           ADD 1 TO NB-RECS.

       WRITE-2.
           MOVE SPACES      TO DATAF16-REC.
           MOVE "44"        TO S-ID.
           MOVE "DDDD"      TO S-NAME.
           MOVE "dddddddddd"  TO S-VALUE.
           WRITE DATAF16-REC.
           PERFORM CHECK-IO THRU E-CHECK-IO.
           ADD 1 TO NB-RECS.
 
       WRITE-3.
           MOVE SPACES      TO DATAF16-REC.
           MOVE "33"        TO S-ID.
           MOVE "CCCC"      TO S-NAME.
           MOVE "cccccccccc"  TO S-VALUE.
           WRITE DATAF16-REC.
           PERFORM CHECK-IO THRU E-CHECK-IO.
           ADD 1 TO NB-RECS.

       WRITE-4.
           MOVE SPACES      TO DATAF16-REC.
           MOVE "22"        TO S-ID.
           MOVE "BBBB"      TO S-NAME.
           MOVE "bbbbbbbbbb"  TO S-VALUE.
           WRITE DATAF16-REC.
           PERFORM CHECK-IO THRU E-CHECK-IO.
           ADD 1 TO NB-RECS.
      
       WRITE-5.
           MOVE SPACES      TO DATAF16-REC.
           MOVE "11"        TO S-ID.
           MOVE "AAAA"      TO S-NAME.
           MOVE "aaaaaaaaaa"  TO S-VALUE.
           WRITE DATAF16-REC.
           PERFORM CHECK-IO THRU E-CHECK-IO.
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
      

       CHECK-IO.
           IF IO-STATUS NOT = "00"
             DISPLAY "FILELD-0202: OUTPUT FAILED"
             DISPLAY "ASSIGN: SORTIE"
             DISPLAY "IO-STATUS =" IO-STATUS
             GO TO FIN-ERREUR
           END-IF.
       E-CHECK-IO.

       END-COMMON-DISPLAY.
           CLOSE MW-SORTIE.
      
