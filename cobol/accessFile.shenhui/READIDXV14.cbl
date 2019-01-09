       IDENTIFICATION   DIVISION.
       PROGRAM-ID.      READINDEXV14.
       ENVIRONMENT      DIVISION.
       INPUT-OUTPUT     SECTION.
       FILE-CONTROL.
         SELECT INDEX-FILE ASSIGN TO KSDSFILE

            ORGANIZATION IS INDEXED
      *     ACCESS MODE IS RANDOM          
      *     ACCESS MODE IS RANDOM          
            ACCESS MODE IS DYNAMIC
            RECORD KEY IS S-ID
            FILE STATUS IS IO-STATUS.

       DATA DIVISION.
       FILE SECTION.
         FD  INDEX-FILE
             LABEL RECORD STANDARD
             RECORDING MODE IS V
             RECORD is VARYING in SIZE from 2 to 14
             DEPENDING ON REC-LEN
             DATA RECORD DATAV14-REC.
         01 DATAV14-REC.
             03 S-ID     PIC X(02).
             03 S-NAME   PIC X(04).
             03 S-VALUE  PIC X(08).

       WORKING-STORAGE SECTION.
         01  REC-LEN   PIC 9(4) COMP.
         01  IO-STATUS PIC XX.

       PROCEDURE DIVISION.
            OPEN INPUT INDEX-FILE.
            IF IO-STATUS NOT = "00"
                DISPLAY "OPEN INPUT FAILED"
                DISPLAY "IO-STATUS =" IO-STATUS
                GO TO FIN-REL
            END-IF.

         DISPLAY "------------READ SEQUENTIAL------------".
         READ-SEQUENTIAL.
            MOVE SPACES TO DATAV14-REC.
            READ INDEX-FILE NEXT
              AT END GO TO READ-KEY
            END-READ.
            PERFORM DISPLAY-RECORD THRU E-DISPLAY-RECORD.
            GO TO READ-SEQUENTIAL.

         READ-KEY.
              MOVE "22" TO S-ID
              DISPLAY "------------READ KEY(" S-ID ")------------".
              READ INDEX-FILE
              IF IO-STATUS NOT = "00"
                DISPLAY "READ FAILED"
                DISPLAY "IO-STATUS =" IO-STATUS
                GO TO FIN-REL
              END-IF.
              PERFORM DISPLAY-RECORD THRU E-DISPLAY-RECORD.
 
         FIN-REL.
      *     DISPLAY "Done".

            CLOSE INDEX-FILE.
      
            EXIT PROGRAM.
            STOP RUN.

         DISPLAY-RECORD.
           DISPLAY "RECORD" ": S-ID=" S-ID
                            ", S-NAME=" S-NAME
                            ", S-VALUE=" S-VALUE.
         E-DISPLAY-RECORD.
           EXIT.
