       IDENTIFICATION DIVISION.
       PROGRAM-ID. OPENINPUTEXTEND.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       SELECT MW-SORTIE
              ASSIGN TO ESDSFILE
              ORGANIZATION IS SEQUENTIAL
              ACCESS IS SEQUENTIAL
              LOCK MODE IS AUTOMATIC
              FILE STATUS IS IO-STATUS.
      
       SELECT WS-MW-SORTIE
              ASSIGN TO ESDSFILE
              ORGANIZATION IS SEQUENTIAL
              ACCESS IS SEQUENTIAL
              LOCK MODE IS AUTOMATIC
              FILE STATUS IS IO-STATUS.
 
       DATA DIVISION.
       FILE SECTION.
      
       FD  MW-SORTIE
           LABEL RECORD STANDARD
           DATA RECORD DATAF16-REC.
       01  DATAF16-REC.
           03 S-ID                 PIC X(02).
           03 S-NAME               PIC X(04).
           03 S-VALUE              PIC X(10).

       FD  WS-MW-SORTIE
           LABEL RECORD STANDARD
           DATA RECORD WS-DATAF16-REC.
       01  WS-DATAF16-REC.
           03 WS-S-ID                 PIC X(02).
           03 WS-S-NAME               PIC X(04).
           03 WS-S-VALUE              PIC X(10).

       WORKING-STORAGE SECTION.
       01  IO-STATUS                  PIC XX.
      
 
       PROCEDURE DIVISION.
       P-START.
           OPEN I-O MW-SORTIE
           PERFORM CHECK-IO THRU E-CHECK-IO.
      
 

           READ MW-SORTIE NEXT.
           PERFORm DISPLAY-RECORD.
           READ MW-SORTIE NEXT.
           PERFORm DISPLAY-RECORD.
           READ MW-SORTIE NEXT.
           PERFORm DISPLAY-RECORD.
           READ MW-SORTIE NEXT.
           PERFORm DISPLAY-RECORD.
           READ MW-SORTIE NEXT.
           PERFORm DISPLAY-RECORD.

           MOVE 66 TO WS-S-ID.
           PERFORM WRITE-REC THRU E-WRITE-REC.

           MOVE "RRRR" TO S-NAME.
           REWRITE DATAF16-REC.

           READ MW-SORTIE NEXT.
           PERFORm DISPLAY-RECORD.

           MOVE 77 TO WS-S-ID.
           PERFORM WRITE-REC THRU E-WRITE-REC.

           READ MW-SORTIE NEXT.
           PERFORm DISPLAY-RECORD.

       FIN-REL.
           DISPLAY "====DONE====".
           PERFORM END-COMMON-DISPLAY.
      
           EXIT PROGRAM.
           STOP RUN.
      
       FIN-ERREUR.
           DISPLAY "====ERROR====".
           PERFORM END-COMMON-DISPLAY.
      
           EXIT PROGRAM.
           STOP RUN RETURNING 1.
      
       READ-ALL.
           MOVE SPACES TO DATAF16-REC.
           READ MW-SORTIE NEXT
             AT END GO TO E-READ-ALL
           END-READ.
           PERFORM CHECK-IO THRU E-CHECK-IO.
           PERFORm DISPLAY-RECORD.
           GO TO READ-ALL.
       E-READ-ALL.
           EXIT.

       WRITE-REC.
           OPEN EXTEND WS-MW-SORTIE
           PERFORM CHECK-IO THRU E-CHECK-IO.

           MOVE "XXXX"        TO WS-S-NAME.
           MOVE "xxxxxxxxxx"  TO WS-S-VALUE.
           WRITE WS-DATAF16-REC.
           PERFORM CHECK-IO THRU E-CHECK-IO.
           CLOSE WS-MW-SORTIE.
       E-WRITE-REC.
           EXIT.

       DISPLAY-RECORD.
           DISPLAY "RECORD" ": S-ID=" S-ID
                            ", S-NAME=" S-NAME
                            ", S-VALUE=" S-VALUE.
       E-DISPLAY-RECORD.
           EXIT.

 
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
      
