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
      
       DATA DIVISION.
       FILE SECTION.
      
       FD  MW-SORTIE
           LABEL RECORD STANDARD
           DATA RECORD DATAF16-REC.
       01  DATAF16-REC.
           03 S-ID                 PIC X(02).
           03 S-NAME               PIC X(04).
           03 S-VALUE              PIC X(10).

       WORKING-STORAGE SECTION.
       01  IO-STATUS                  PIC XX.
      
 
       PROCEDURE DIVISION.
       P-START.

       OPEN-LOOP.
           OPEN INPUT MW-SORTIE
           DISPLAY "OOOOOOOOOOOOOOOOO".
           PERFORM CHECK-IO THRU E-CHECK-IO.
           GO TO OPEN-LOOP.
      
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
      
