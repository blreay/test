       IDENTIFICATION DIVISION.
       PROGRAM-ID. WRITESEQV4092.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       SELECT MW-SORTIE
              ASSIGN TO DATAFILE
              ORGANIZATION IS RECORD SEQUENTIAL
              FILE STATUS IS IO-STATUS.
      
       DATA DIVISION.
       FILE SECTION.
      
       FD  MW-SORTIE
           LABEL RECORD STANDARD
           RECORDING MODE IS V
           RECORD IS VARYING IN SIZE FROM 1 TO 4092
           DEPENDING ON MW-ENTREE-REC-LEN
           DATA RECORD MW-SORTIE-REC.
       01  MW-SORTIE-REC  PIC X(4092).

       WORKING-STORAGE SECTION.
       01  MW-ENTREE-REC-LEN          PIC X(4) COMP-X.

       01  IO-STATUS            PIC XX.
       01  D-NB-RECS            PIC 9(9) VALUE 0.
       01  MW-NB-INSERT         PIC 9(9) VALUE 0.
      
      
       PROCEDURE DIVISION.
       P-START.
      
           OPEN OUTPUT MW-SORTIE
           IF IO-STATUS NOT = "00"
             DISPLAY "FILELD-0202: OUTPUT DS01 FAILED"
             DISPLAY "ASSIGN: SORTIE"
             DISPLAY "IO-STATUS =" IO-STATUS
             GO TO FIN-ERREUR
           END-IF.
      
      *    PERFORM 524290 TIMES
           PERFORM 1 TIMES
             ADD 1 TO D-NB-RECS

             MOVE HIGH-VALUES TO MW-SORTIE-REC
             MOVE 4092 TO MW-ENTREE-REC-LEN
             WRITE MW-SORTIE-REC
             IF IO-STATUS NOT = "00"
               DISPLAY "ERROR:"
 Error         DISPLAY "FILELD-0203: WRITE DS01 FAILED"
 Error         DISPLAY "ASSIGN: SORTIE"
               DISPLAY "IO-STATUS =" IO-STATUS
               GO TO FIN-ERREUR
             END-IF
      
             ADD 1 TO MW-NB-INSERT
             IF MW-NB-INSERT >= 20000
               MOVE 0 TO MW-NB-INSERT
               DISPLAY "written: " D-NB-RECS
             END-IF
           END-PERFORM.
      
       FIN-REL.
           DISPLAY "RELOADING TERMINATED OK".
           PERFORM END-COMMON-DISPLAY.
      
           EXIT PROGRAM.
           STOP RUN.
      
       FIN-ERREUR.
           DISPLAY "RELOADING FAILED".
           PERFORM END-COMMON-DISPLAY.
      
           EXIT PROGRAM.
           STOP RUN RETURNING 1.
      
       END-COMMON-DISPLAY.
           DISPLAY "Nb rows reloaded: " D-NB-RECS.
      
           CLOSE MW-SORTIE.
      
