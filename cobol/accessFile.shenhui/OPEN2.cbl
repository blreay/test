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
           OPEN I-O  MW-SORTIE.
           IF IO-STATUS = ZEROES
             DISPLAY "OPEN I-O OK"
             OPEN EXTEND WS-MW-SORTIE
             IF IO-STATUS = ZEROES
               DISPLAY "OPEN I-O OK"
             END-IF
           END-IF.

       FIN-REL.
           DISPLAY "====DONE====".
           PERFORM END-COMMON-DISPLAY.
      
           EXIT PROGRAM.
           STOP RUN.
      
       END-COMMON-DISPLAY.
           CLOSE MW-SORTIE.
           CLOSE WS-MW-SORTIE.
      
