       IDENTIFICATION   DIVISION.
       PROGRAM-ID.      READCUSTOMER.
       ENVIRONMENT      DIVISION.
       INPUT-OUTPUT     SECTION.
       FILE-CONTROL.
         SELECT MW-ENTREE ASSIGN TO KSDSFILE
            ORGANIZATION IS INDEXED
      *     ACCESS MODE IS RANDOM          
            ACCESS MODE IS DYNAMIC
            RECORD KEY IS VS-CUSTIDENT
            FILE STATUS IS IO-STATUS.

       DATA DIVISION.
       FILE SECTION.
         FD  MW-ENTREE
             LABEL RECORD STANDARD
             DATA RECORD VS-ODCSF0-RECORD.
         COPY ODCSF0B.

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
            MOVE SPACES TO VS-ODCSF0-RECORD.
            READ MW-ENTREE NEXT
              AT END GO TO READ-KEY
            END-READ.
            PERFORM DISPLAY-RECORD THRU E-DISPLAY-RECORD.
            GO TO READ-SEQUENTIAL.

         READ-KEY.
            MOVE SPACES TO VS-ODCSF0-RECORD.
            MOVE "000004" TO VS-CUSTIDENT
            DISPLAY "--------READ KEY(" VS-CUSTIDENT ")--------".
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
           DISPLAY "RECORD" ": VS-CUSTIDENT=" VS-CUSTIDENT
                            ", VS-CUSTLNAME=" VS-CUSTLNAME.
         E-DISPLAY-RECORD.
           EXIT.
