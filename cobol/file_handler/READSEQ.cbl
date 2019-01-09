       IDENTIFICATION   DIVISION.
       PROGRAM-ID.      TEST.
       ENVIRONMENT      DIVISION.
       INPUT-OUTPUT     SECTION.
       FILE-CONTROL.
         SELECT IN-FIXED-FILE
            ASSIGN TO "TEST.DATA.F".
         SELECT IN-VARYING-FILE
            ASSIGN TO "TEST.DATA.V".
       DATA DIVISION.
       FILE SECTION.
         FD  IN-FIXED-FILE
             LABEL RECORD STANDARD
             DATA RECORD FIXED-FILE-REC.
         01  FIXED-FILE-REC.
             03 GOODS-NAME-FIXED  PIC X(09).
         FD  IN-VARYING-FILE
             LABEL RECORD STANDARD
             DATA RECORD VARYING-FILE-REC
             RECORD is VARYING in SIZE from 1 to 9.
         01  VARYING-FILE-REC.
             03 GOODS-NAME-VARYING  PIC X(09).

       PROCEDURE   DIVISION.
            OPEN INPUT IN-FIXED-FILE.
            OPEN INPUT IN-VARYING-FILE. 

          READ-LOOP.
            MOVE SPACES TO FIXED-FILE-REC.
            READ IN-FIXED-FILE NEXT
              AT END GO TO FIN-REL
            END-READ.
            DISPLAY GOODS-NAME-FIXED.


            
            MOVE SPACES TO VARYING-FILE-REC.
            READ IN-VARYING-FILE NEXT
              AT END GO TO FIN-REL
            END-READ.
            DISPLAY GOODS-NAME-VARYING.

            GO TO READ-LOOP.

       FIN-REL.
            DISPLAY "Done".

            CLOSE IN-FIXED-FILE.
            CLOSE IN-VARYING-FILE.
      
            EXIT PROGRAM.
            STOP RUN.
