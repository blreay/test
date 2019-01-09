       IDENTIFICATION   DIVISION.
       PROGRAM-ID.      READVSEQ.
       ENVIRONMENT      DIVISION.
       INPUT-OUTPUT     SECTION.
       FILE-CONTROL.
         SELECT INPUTFILE ASSIGN TO DATAFILE
         ORGANIZATION IS SEQUENTIAL
         ACCESS MODE IS SEQUENTIAL
         FILE STATUS IS IO-STATUS.
       DATA DIVISION.
       FILE SECTION.
         FD  INPUTFILE
             LABEL RECORD STANDARD
             RECORD is VARYING in SIZE from 1 to 65535
             DEPENDING ON DATA-REC-LEN.
         01  DATA-REC     PIC X(65535).

       WORKING-STORAGE SECTION.
         01  DATA-REC-LEN PIC 9(6).

         01  NB-RECS      PIC 9(9) VALUE 0.

         01 IO-STATUS.
          05 status-key-1        pic x.
          05 status-key-2        pic x.
          05 binary-status redefines status-key-2 pic 99 comp-x.


       PROCEDURE   DIVISION.
            OPEN INPUT INPUTFILE.
            IF IO-STATUS NOT = "00"
               DISPLAY "READ OPEN FAILED"
               DISPLAY "IO-STATUS =" IO-STATUS
               GO TO FIN-REL
            END-IF.

          READ-LOOP.
            MOVE ZEROS TO DATA-REC-LEN.
            MOVE SPACES TO DATA-REC.
            READ INPUTFILE NEXT
              AT END GO TO FIN-REL
            END-READ.
            IF IO-STATUS NOT = "00"
               DISPLAY "READ INPUT FAILED"
               IF Status-Key-1 = '9'
                  DISPLAY "FILE ERROR, STATUS: 9/" binary-status
               ELSE
                  DISPLAY "FILE ERROR, STATUS: " IO-STATUS
               END-IF
               GO TO FIN-REL
            END-IF.

            ADD 1 TO NB-RECS.

      *     DISPLAY "RECORD[" NB-RECS
      *             "]: LEN=[" DATA-REC-LEN
      *             "]"
            DISPLAY "RECORD[" NB-RECS
                    "]: LEN=[" DATA-REC-LEN
                    "],DATA=[" DATA-REC(1:DATA-REC-LEN) "]".

            GO TO READ-LOOP.

       FIN-REL.

            CLOSE INPUTFILE.
      
            EXIT PROGRAM.
            STOP RUN.
