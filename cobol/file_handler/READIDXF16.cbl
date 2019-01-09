       IDENTIFICATION   DIVISION.
       PROGRAM-ID.      READIDXF16.
       ENVIRONMENT      DIVISION.
       INPUT-OUTPUT     SECTION.
       FILE-CONTROL.
         SELECT MW-ENTREE ASSIGN TO KSDSFILE
            ORGANIZATION IS INDEXED
      *     ACCESS MODE IS RANDOM          
            ACCESS MODE IS DYNAMIC
            RECORD KEY IS S-ID
            FILE STATUS IS IO-STATUS.

       DATA DIVISION.
       FILE SECTION.
         FD  MW-ENTREE
             LABEL RECORD STANDARD
             DATA RECORD DATAF16-REC.
         COPY DATAF16.

       WORKING-STORAGE SECTION.
         01  IO-STATUS PIC XX.

       PROCEDURE DIVISION.
            OPEN INPUT MW-ENTREE.
            IF IO-STATUS NOT = "00"
                DISPLAY "OPEN INPUT FAILED"
                DISPLAY "IO-STATUS =" IO-STATUS
                GO TO FIN-REL
            END-IF.

         DISPLAY "------------READ SEQUENTIAL------------".
         READ-SEQUENTIAL.
            MOVE SPACES TO DATAF16-REC.
            READ MW-ENTREE NEXT
              AT END GO TO READ-KEY
            END-READ.
            PERFORM DISPLAY-RECORD THRU E-DISPLAY-RECORD.
            GO TO READ-SEQUENTIAL.

         READ-KEY.
            MOVE SPACES TO DATAF16-REC.
            MOVE "22" TO S-ID
            DISPLAY "------------READ KEY(" S-ID ")------------".
            READ MW-ENTREE
            IF IO-STATUS NOT = "00"
               DISPLAY "READ FAILED"
               DISPLAY "IO-STATUS =" IO-STATUS
               GO TO FIN-REL
            END-IF.
            PERFORM DISPLAY-RECORD THRU E-DISPLAY-RECORD.
 
         FIN-REL.
            CLOSE MW-ENTREE.
      
            EXIT PROGRAM.
            STOP RUN.

         DISPLAY-RECORD.
           DISPLAY "RECORD" ": S-ID=" S-ID
                            ", S-NAME=" S-NAME
                            ", S-VALUE=" S-VALUE.
         E-DISPLAY-RECORD.
           EXIT.
