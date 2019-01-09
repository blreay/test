       IDENTIFICATION   DIVISION.
       PROGRAM-ID.      READRELF16.
       ENVIRONMENT      DIVISION.
       INPUT-OUTPUT     SECTION.
       FILE-CONTROL.
         SELECT REL-FILE ASSIGN TO RELFILE
            ORGANIZATION IS RELATIVE 
      *     ACCESS MODE IS RANDOM          
            ACCESS MODE IS DYNAMIC
            RELATIVE KEY REL-KEY
            FILE STATUS IS IO-STATUS.

       DATA DIVISION.
       FILE SECTION.
         FD  REL-FILE
             LABEL RECORD STANDARD
             DATA RECORD DATAF16-REC.
         01 DATAF16-REC.
             03 S-ID     PIC X(02).
             03 S-NAME   PIC X(04).
             03 S-VALUE  PIC X(10).

       WORKING-STORAGE SECTION.
         01  IO-STATUS   PIC XX.
         01  REL-KEY  PIC 9(8).

       PROCEDURE DIVISION.
            OPEN INPUT REL-FILE.
            IF IO-STATUS NOT = "00"
                DISPLAY "OPEN INPUT FAILED"
                DISPLAY "IO-STATUS =" IO-STATUS
                GO TO FIN-REL
            END-IF.

         DISPLAY "------------READ SEQUENTIAL------------".
         READ-SEQUENTIAL.
            MOVE SPACES TO DATAF16-REC.
            READ REL-FILE NEXT
              AT END GO TO READ-KEY
            END-READ.
            PERFORM DISPLAY-RECORD THRU E-DISPLAY-RECORD.
            GO TO READ-SEQUENTIAL.

         READ-KEY.
              MOVE 2 TO REL-KEY.
              DISPLAY "------------READ RRN(" REL-KEY ")------------".
              READ REL-FILE
              IF IO-STATUS NOT = "00"
                DISPLAY "READ FAILED"
                DISPLAY "IO-STATUS =" IO-STATUS
                GO TO FIN-REL
              END-IF.
              PERFORM DISPLAY-RECORD THRU E-DISPLAY-RECORD.
 
         FIN-REL.
      *     DISPLAY "Done".

            CLOSE REL-FILE.
      
            EXIT PROGRAM.
            STOP RUN.

         DISPLAY-RECORD.
           DISPLAY "RECORD" ": S-ID=" S-ID
                            ", S-NAME=" S-NAME
                            ", S-VALUE=" S-VALUE.
         E-DISPLAY-RECORD.
           EXIT.
