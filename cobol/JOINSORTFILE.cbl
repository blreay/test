      $set sourceformat(free)
       IDENTIFICATION   DIVISION.
       PROGRAM-ID.      READVSEQ.
       ENVIRONMENT      DIVISION.
       INPUT-OUTPUT     SECTION.
       FILE-CONTROL.
        SELECT INPUTFILE_F1 ASSIGN TO SORT_OUT_JOIN_F1
        ORGANIZATION IS SEQUENTIAL
        ACCESS MODE IS SEQUENTIAL
        FILE STATUS IS IO-STATUS.

        SELECT INPUTFILE_F2 ASSIGN TO SORT_OUT_JOIN_F2
        ORGANIZATION IS SEQUENTIAL
        ACCESS MODE IS SEQUENTIAL
        FILE STATUS IS IO-STATUS.

        SELECT OUTPUTFILE_JOIN ASSIGN TO SORT_OUT_JOIN_OUTPUT
        ORGANIZATION IS SEQUENTIAL
        ACCESS IS SEQUENTIAL
        FILE STATUS IS IO-STATUS.

       DATA DIVISION.
       FILE SECTION.
         FD  INPUTFILE_F1
             LABEL RECORD STANDARD
             RECORD is VARYING in SIZE from 1 to 4095
             DEPENDING ON DATA_REC_F1_LEN.
         01  DATA_REC_F1     PIC X(4095).
         FD  INPUTFILE_F2
             LABEL RECORD STANDARD
             RECORD is VARYING in SIZE from 1 to 4095
             DEPENDING ON DATA_REC_F2_LEN.
         01  DATA_REC_F2     PIC X(4095).
         FD  OUTPUTFILE_JOIN
             LABEL RECORD STANDARD
             RECORD is VARYING in SIZE from 1 to 4095
             DEPENDING ON DATA_REC_OUT_LEN.
         01  DATA_REC_OUT     PIC X(4095).

       WORKING-STORAGE SECTION.
         01  MT_BATCH_JOIN_METHOD PIC X(4000).
         01  MT_BATCH_JOINKEYS_F1 PIC X(4000).
         01  MT_BATCH_JOINKEYS_F2 PIC X(4000).
         01  MT_BATCH_JOINKEYS_FORMAT PIC X(4000).
         01  MT_BATCH_JOINKEYS_FILL   PIC X(4000).
         01  MT_LENGTH     PIC 9(6).
         01  MT_START      PIC 9(6).
         01  MT_COUNT      PIC 9(6).
         01  MT_COUNT_ALL  PIC 9(6).
         01  MT_FILENAME   PIC X(256).
         
         01  DATA_REC_F1_LEN  PIC 9(6).
         01  DATA_REC_F2_LEN  PIC 9(6).
         01  DATA_REC_OUT_LEN PIC 9(6).
         
         01  REC_JOIN_F1        PIC X(4095).
         01  REC_JOIN_F1_LEN    PIC 9(6).
         01  REC_JOIN_F2        PIC X(4095).
         01  REC_JOIN_F2_LEN    PIC 9(6).

         01  NB_RECS_F1      PIC 9(9) VALUE 0.
         01  NB_RECS_F2      PIC 9(9) VALUE 0.
         01  NB-RECS_OUTPUT  PIC 9(9) VALUE 0.

         01 IO-STATUS.
          05 status-key-1        pic x.
          05 status-key-2        pic x.
          05 binary-status redefines status-key-2 pic 99 comp-x.
         01  join-lg       pic s9(9) comp-5.

        01 KEY-F1.
            03 KEY_ARY_LEN_F1 PIC 99999.
            03 KEY_ARY_IDX_F1 PIC 99999.
            03 KEY_ARY_F1 OCCURS 1 TO 1000 TIMES DEPENDING ON KEY_ARY_LEN_F1.
                05 KEY_START   PIC 9(6).
                05 KEY_LENGTH  PIC 9(6).
                05 KEY_ORDER   PIC X(1).
                
        01 KEY-F2.
            03 KEY_ARY_LEN_F2 PIC 99999.
            03 KEY_ARY_IDX_F2 PIC 99999.
            03 KEY_ARY_F2 OCCURS 1 TO 1000 TIMES DEPENDING ON KEY_ARY_LEN_F2.
                05 KEY_START   PIC 9(6).
                05 KEY_LENGTH  PIC 9(6).
                05 KEY_ORDER   PIC X(1).
        01 OUTFORMAT.
            03 ARY_LEN_OUTFORMAT PIC 99999.
            03 ARY_IDX_OUTFORMAT PIC 99999.
            03 ARY_OUTFORMAT OCCURS 1 TO 1000 TIMES DEPENDING ON ARY_LEN_OUTFORMAT.
                05 FILE_NAME   PIC X(256).
                05 KEY_START   PIC 9(6).
                05 KEY_LENGTH  PIC 9(6).
        
        01 IDX PIC 9(4) COMP VALUE 100.
        01 STRING-PTR PIC 9(4).
        01 STEXT1 PIC XXX OCCURS 5 TO 1200 TIMES DEPENDING ON MT_LENGTH.

       PROCEDURE   DIVISION.
       
           MOVE 10 to MT_LENGTH
           MOVE 'bbb' to STEXT1(900)
           DISPLAY "zhangzy: STEXT="  STEXT1(900)
           MOVE '25' to KEY_START of KEY_ARY_F1(2)
           DISPLAY "zhangzy: KEY_START of KEY_ARY_F1(2)="  KEY_START of KEY_ARY_F1(2)
           ADD 1 to KEY_START of KEY_ARY_F1(2)
           DISPLAY "zhangzy: KEY_START of KEY_ARY_F1(2)="  KEY_START of KEY_ARY_F1(2)
            
            PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > MT_LENGTH
                 MOVE IDX to KEY_START of KEY_ARY_F1(IDX)
                 MOVE IDX to KEY_LENGTH of KEY_ARY_F1(IDX)
             END-PERFORM
            PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > MT_LENGTH
                 DISPLAY KEY_ARY_F1(IDX)
             END-PERFORM

** Analyze JOINKEYS statement for F1
           MOVE ZEROS TO MT_BATCH_JOINKEYS_F1
           MOVE SPACES TO MT_BATCH_JOINKEYS_F1
           DISPLAY "MT_BATCH_JOINKEYS_F1" UPON environment-name               
           ACCEPT MT_BATCH_JOINKEYS_F1 FROM environment-value
            move 1 to MT_LENGTH.
              perform until MT_BATCH_JOINKEYS_F1(MT_LENGTH:1) = space or LOW-VALUE
                add 1 to MT_LENGTH
            end-perform
           DISPLAY "MT_BATCH_JOINKEYS_F1=" MT_BATCH_JOINKEYS_F1(1:MT_LENGTH)
           
            Move ZEROS TO MT_COUNT_ALL
            INSPECT MT_BATCH_JOINKEYS_F1
                TALLYING MT_COUNT_ALL FOR ALL ','.
            DISPLAY 'HOW MANY comma:' MT_COUNT_ALL.
            ADD 1 to MT_COUNT_ALL
            DIVIDE MT_COUNT_ALL by 3 GIVING MT_COUNT
            DISPLAY 'HOW MANY comma:' MT_COUNT.
            MOVE MT_COUNT to KEY_ARY_LEN_F1

            MOVE 1 TO STRING-PTR. 
            MOVE 1 TO MT_COUNT.
            PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > MT_COUNT_ALL 
                UNSTRING MT_BATCH_JOINKEYS_F1 DELIMITED BY ',' 
                   INTO KEY_START of KEY_ARY_F1(MT_COUNT)
                   WITH POINTER STRING-PTR 
                ADD 1 to IDX
                UNSTRING MT_BATCH_JOINKEYS_F1 DELIMITED BY ',' 
                   INTO KEY_LENGTH of KEY_ARY_F1(MT_COUNT)
                   WITH POINTER STRING-PTR 
                ADD 1 to IDX
                UNSTRING MT_BATCH_JOINKEYS_F1 DELIMITED BY ',' 
                   INTO KEY_ORDER of KEY_ARY_F1(MT_COUNT)
                   WITH POINTER STRING-PTR 
                DISPLAY "KEY_ARY_F1(" MT_COUNT ")=" KEY_ARY_F1(MT_COUNT)
                ADD 1 TO MT_COUNT
            END-PERFORM. 
            
** Analyze JOINKEYS statement for F2
           MOVE ZEROS TO MT_BATCH_JOINKEYS_F2
           MOVE SPACES TO MT_BATCH_JOINKEYS_F2
           DISPLAY "MT_BATCH_JOINKEYS_F2" UPON environment-name               
           ACCEPT MT_BATCH_JOINKEYS_F2 FROM environment-value
            move 1 to MT_LENGTH.
              perform until MT_BATCH_JOINKEYS_F2(MT_LENGTH:1) = space or LOW-VALUE
                add 1 to MT_LENGTH
            end-perform
           DISPLAY "MT_BATCH_JOINKEYS_F2=" MT_BATCH_JOINKEYS_F2(1:MT_LENGTH)
           
            Move ZEROS TO MT_COUNT_ALL
            INSPECT MT_BATCH_JOINKEYS_F2
                TALLYING MT_COUNT_ALL FOR ALL ','.
            DISPLAY 'HOW MANY comma:' MT_COUNT_ALL.
            ADD 1 to MT_COUNT_ALL
            DIVIDE MT_COUNT_ALL by 3 GIVING MT_COUNT
            DISPLAY 'HOW MANY comma:' MT_COUNT.
            MOVE MT_COUNT to KEY_ARY_LEN_F2

            MOVE 1 TO STRING-PTR. 
            MOVE 1 TO MT_COUNT.
            PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > MT_COUNT_ALL 
                UNSTRING MT_BATCH_JOINKEYS_F2 DELIMITED BY ',' 
                   INTO KEY_START of KEY_ARY_F2(MT_COUNT)
                   WITH POINTER STRING-PTR 
                ADD 1 to IDX
                UNSTRING MT_BATCH_JOINKEYS_F2 DELIMITED BY ',' 
                   INTO KEY_LENGTH of KEY_ARY_F2(MT_COUNT)
                   WITH POINTER STRING-PTR 
                ADD 1 to IDX
                UNSTRING MT_BATCH_JOINKEYS_F2 DELIMITED BY ',' 
                   INTO KEY_ORDER of KEY_ARY_F2(MT_COUNT)
                   WITH POINTER STRING-PTR 
                DISPLAY "KEY_ARY_F2(" MT_COUNT ")=" KEY_ARY_F2(MT_COUNT)
                ADD 1 TO MT_COUNT
            END-PERFORM. 

** Analyze JOIN statement
           MOVE ZEROS TO MT_BATCH_JOIN_METHOD
           MOVE SPACES TO MT_BATCH_JOIN_METHOD
           DISPLAY "MT_BATCH_JOIN_METHOD" UPON environment-name               
           ACCEPT MT_BATCH_JOIN_METHOD FROM environment-value
            move 1 to join-lg.
              perform until MT_BATCH_JOIN_METHOD(join-lg:1) = space or LOW-VALUE
                add 1 to join-lg
            end-perform
           DISPLAY "MT_BATCH_JOIN_METHOD=" MT_BATCH_JOIN_METHOD(1:join-lg)
           
           EVALUATE TRUE 
            WHEN MT_BATCH_JOIN_METHOD EQUAL TO "UNPAIRED,F1"
                  DISPLAY "Supported:" MT_BATCH_JOIN_METHOD(1:join-lg)
            WHEN OTHER
                  DISPLAY "NOT Supported JOIN-STATEMENG:" MT_BATCH_JOIN_METHOD(1:join-lg)
                  GO TO FIN-REL
           END-EVALUATE 

** Analyze REFORMAT statement
           MOVE ZEROS TO MT_BATCH_JOINKEYS_FORMAT
           MOVE SPACES TO MT_BATCH_JOINKEYS_FORMAT
           DISPLAY "MT_BATCH_JOINKEYS_FORMAT" UPON environment-name               
           ACCEPT MT_BATCH_JOINKEYS_FORMAT FROM environment-value
            move 1 to MT_LENGTH.
              perform until MT_BATCH_JOINKEYS_FORMAT(MT_LENGTH:1) = space or LOW-VALUE
                add 1 to MT_LENGTH
            end-perform
           DISPLAY "MT_BATCH_JOINKEYS_FORMAT=" MT_BATCH_JOINKEYS_FORMAT(1:MT_LENGTH)
           
            Move ZEROS TO MT_COUNT_ALL
            INSPECT MT_BATCH_JOINKEYS_FORMAT
                TALLYING MT_COUNT_ALL FOR ALL ':' ALL ','.
            DISPLAY 'HOW MANY colon:' MT_COUNT_ALL.
            ADD 1 to MT_COUNT_ALL
            DIVIDE MT_COUNT_ALL by 3 GIVING MT_COUNT
            DISPLAY 'HOW MANY colon:' MT_COUNT.
            MOVE MT_COUNT to ARY_LEN_OUTFORMAT

            MOVE 1 TO STRING-PTR. 
            MOVE 1 TO MT_COUNT.
            PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > MT_COUNT_ALL 
                UNSTRING MT_BATCH_JOINKEYS_FORMAT DELIMITED BY ',' OR ':'
                   INTO FILE_NAME of ARY_OUTFORMAT(MT_COUNT)
                   WITH POINTER STRING-PTR 
                ADD 1 to IDX
                UNSTRING MT_BATCH_JOINKEYS_FORMAT DELIMITED BY ',' OR ':'
                   INTO KEY_START of ARY_OUTFORMAT(MT_COUNT)
                   WITH POINTER STRING-PTR 
                ADD 1 to IDX
                UNSTRING MT_BATCH_JOINKEYS_FORMAT DELIMITED BY ',' OR ':'
                   INTO KEY_LENGTH of ARY_OUTFORMAT(MT_COUNT)
                   WITH POINTER STRING-PTR 
                DISPLAY "ARY_OUTFORMAT(" MT_COUNT ")=" ARY_OUTFORMAT(MT_COUNT)
                ADD 1 TO MT_COUNT
            END-PERFORM. 
            
** Read F1 and F2
            OPEN INPUT INPUTFILE_F1.
            IF IO-STATUS NOT = "00"
               DISPLAY "READ OPEN FAILED: INPUTFILE_F1"
               DISPLAY "IO-STATUS =" IO-STATUS
               IF Status-Key-1 = '9'
                  DISPLAY "FILE ERROR, STATUS: 9/" binary-status
               ELSE
                  DISPLAY "FILE ERROR, STATUS: " IO-STATUS
               END-IF
               GO TO FIN-REL
            END-IF.

           OPEN OUTPUT OUTPUTFILE_JOIN
           IF IO-STATUS NOT = "00"
               DISPLAY "WRITE OPEN FAILED: OUTPUTFILE_JOIN"
               DISPLAY "IO-STATUS =" IO-STATUS
               IF Status-Key-1 = '9'
                  DISPLAY "FILE ERROR, STATUS: 9/" binary-status
               ELSE
                  DISPLAY "FILE ERROR, STATUS: " IO-STATUS
               END-IF
               GO TO FIN-REL
           END-IF.

        READ-LOOP.
            CLOSE INPUTFILE_F2.
            OPEN INPUT INPUTFILE_F2.
            IF IO-STATUS NOT = "00"
               DISPLAY "READ OPEN FAILED: INPUTFILE_F2"
               DISPLAY "IO-STATUS =" IO-STATUS
               IF Status-Key-1 = '9'
                  DISPLAY "FILE ERROR, STATUS: 9/" binary-status
               ELSE
                  DISPLAY "FILE ERROR, STATUS: " IO-STATUS
               END-IF
               GO TO FIN-REL
            END-IF.

            MOVE ZEROS TO DATA_REC_F1_LEN.
            MOVE SPACES TO DATA_REC_F1.
            READ INPUTFILE_F1 NEXT
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

            ADD 1 TO NB_RECS_F1.

            DISPLAY "**INPUTFILE_F1 RECORD[" NB_RECS_F1
                    "]: LEN=[" DATA_REC_F1_LEN
                    "],DATA=[" DATA_REC_F1(1:DATA_REC_F1_LEN) "]".
** generate REC_JOIN_F1, to compare
        MOVE SPACES TO REC_JOIN_F1.
        MOVE ZEROS TO REC_JOIN_F1_LEN.
        PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > KEY_ARY_LEN_F1
            MOVE KEY_START of KEY_ARY_F1(IDX)  TO MT_START
            MOVE KEY_LENGTH of KEY_ARY_F1(IDX) TO MT_LENGTH
            STRING
                DATA_REC_F1(MT_START:MT_LENGTH) DELIMITED BY SIZE
                REC_JOIN_F1(1:REC_JOIN_F1_LEN)  DELIMITED BY SIZE
            INTO REC_JOIN_F1
            ADD MT_LENGTH TO REC_JOIN_F1_LEN
            DISPLAY "REC_JOIN_F1(1:" REC_JOIN_F1_LEN ")=" REC_JOIN_F1(1:REC_JOIN_F1_LEN)
        END-PERFORM.


            MOVE 0 TO NB_RECS_F2.
        READ-LOOP2.
            MOVE ZEROS TO DATA_REC_F2_LEN.
            MOVE SPACES TO DATA_REC_F2.
            READ INPUTFILE_F2 NEXT
              AT END GO TO READ-LOOP
            END-READ.
            IF IO-STATUS NOT = "00"
               DISPLAY "READ INPUT FAILED: INPUTFILE_F2"
               IF Status-Key-1 = '9'
                  DISPLAY "FILE ERROR, STATUS: 9/" binary-status
               ELSE
                  DISPLAY "FILE ERROR, STATUS: " IO-STATUS
               END-IF
               GO TO FIN-REL
            END-IF.

            ADD 1 TO NB_RECS_F2.

            DISPLAY "INPUTFILE_F2: RECORD[" NB_RECS_F2
                    "]: LEN=[" DATA_REC_F2_LEN
                    "],DATA=[" DATA_REC_F2(1:DATA_REC_F2_LEN) "]".

** generate REC_JOIN_F2, to compare
        MOVE SPACES TO REC_JOIN_F2.
        MOVE ZEROS TO REC_JOIN_F2_LEN.
        PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > KEY_ARY_LEN_F2
            MOVE KEY_START of KEY_ARY_F2(IDX)  TO MT_START
            MOVE KEY_LENGTH of KEY_ARY_F2(IDX) TO MT_LENGTH
            STRING
                DATA_REC_F2(MT_START:MT_LENGTH) DELIMITED BY SIZE
                REC_JOIN_F2(1:REC_JOIN_F2_LEN)  DELIMITED BY SIZE
            INTO REC_JOIN_F2
            ADD MT_LENGTH TO REC_JOIN_F2_LEN
            DISPLAY "REC_JOIN_F2(1:" REC_JOIN_F2_LEN ")=" REC_JOIN_F2(1:REC_JOIN_F2_LEN)
        END-PERFORM.

           EVALUATE TRUE 
            WHEN MT_BATCH_JOIN_METHOD EQUAL TO "UNPAIRED,F1"
                DISPLAY "Begin to handle:" MT_BATCH_JOIN_METHOD(1:join-lg)
                IF REC_JOIN_F1 EQUAL TO REC_JOIN_F2 THEN
                    DISPLAY "OK"                    
*Generate output record
                    MOVE SPACES TO DATA_REC_OUT
                    MOVE ZEROS TO DATA_REC_OUT_LEN
                    PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > ARY_LEN_OUTFORMAT
                        DISPLAY "ARY_OUTFORMAT(" IDX ")=" ARY_OUTFORMAT(IDX)
                        MOVE FILE_NAME of ARY_OUTFORMAT(IDX)  TO MT_FILENAME
                        MOVE KEY_START of ARY_OUTFORMAT(IDX)  TO MT_START
                        MOVE KEY_LENGTH of ARY_OUTFORMAT(IDX) TO MT_LENGTH
                        EVALUATE TRUE 
                        WHEN MT_FILENAME EQUAL TO "F1"
                            STRING
                                DATA_REC_F1(MT_START:MT_LENGTH) DELIMITED BY SIZE
                                DATA_REC_OUT(1:DATA_REC_OUT_LEN)  DELIMITED BY SIZE
                            INTO DATA_REC_OUT
                            DISPLAY "Append F1:" DATA_REC_F1(MT_START:MT_LENGTH)
                        WHEN MT_FILENAME EQUAL TO "F2"
                            STRING
                                DATA_REC_F2(MT_START:MT_LENGTH) DELIMITED BY SIZE
                                DATA_REC_OUT(1:DATA_REC_OUT_LEN)  DELIMITED BY SIZE
                            INTO DATA_REC_OUT
                            DISPLAY "Append F2:" DATA_REC_F2(MT_START:MT_LENGTH)
                        WHEN OTHER
                            DISPLAY "NOT Supported FILE_NAME:" MT_FILENAME
                            GO TO FIN-REL
                        END-EVALUATE
                        ADD MT_LENGTH TO DATA_REC_OUT_LEN
                        DISPLAY "DATA_REC_OUT(1:" DATA_REC_OUT_LEN ")=" DATA_REC_OUT(1:DATA_REC_OUT_LEN)
                    END-PERFORM
                    
                    WRITE DATA_REC_OUT
                   IF IO-STATUS NOT = "00"
                       DISPLAY "WRITE RECORD FAILED: OUTPUTFILE_JOIN" DATA_REC_F1
                       DISPLAY "IO-STATUS =" IO-STATUS
                       IF Status-Key-1 = '9'
                          DISPLAY "FILE ERROR, STATUS: 9/" binary-status
                       ELSE
                          DISPLAY "FILE ERROR, STATUS: " IO-STATUS
                       END-IF
                       GO TO FIN-REL
                   END-IF
                ELSE
                    DISPLAY "NG"
                END-IF
           WHEN OTHER
                  DISPLAY "NOT Supported JOIN-STATEMENG:" MT_BATCH_JOIN_METHOD(1:join-lg)
                  GO TO FIN-REL
           END-EVALUATE 

           GO TO READ-LOOP2.            
           GO TO READ-LOOP.

       FIN-REL.
            CLOSE INPUTFILE_F1.
            CLOSE INPUTFILE_F2.
            CLOSE OUTPUTFILE_JOIN.
      
            EXIT PROGRAM.
            STOP RUN.
