        $set sourceformat(free)
*********************************************************************
* JOINKEYS utility
*   Support: only variable length seqential file 
*            only JOIN=UNPAIRED,F1
*
*  Interface: Following environment variables is necessary:
*   DD_SORT_OUT_JOIN_F1
*   DD_SORT_OUT_JOIN_F2
*   DD_SORT_OUT_JOIN_OUTPUT
*   MT_BATCH_JOINKEYS_F1     : 1,3,A,5,1,A,8,3,A
*   MT_BATCH_JOINKEYS_F2     : 1,3,A,5,1,A,8,3,A
*   MT_BATCH_JOIN_METHOD     : UNPAIRED,F1
*   MT_BATCH_JOINKEYS_FORMAT : F1:1,5,F2:1,5,F1:2,3,F2:1,3
*   MT_BATCH_JOINKEYS_FILL   : X'C0' or C'B' 
*********************************************************************
***** This is a typical JCL JOINKETYS sample 
*   //SYSIN    DD *
*    JOINKEYS FILE=F1,FIELDS=(5,4,A,9,10,A,19,2,A,21,4,A,35,2,A)
*    JOINKEYS FILE=F2,FIELDS=(3,4,A,17,10,A,7,2,A,13,4,A,27,2,A)
*    JOIN UNPAIRED,F1
*    REFORMAT FIELDS=(F1:1,147,F2:39,4,F2:29,2,F2:52,2,F1:148,45),
*    FILL=X'00'
*    SORT FIELDS=COPY
*   /*
*********************************************************************
        IDENTIFICATION   DIVISION.
        PROGRAM-ID.      JOINKEYSUTIL.
        ENVIRONMENT      DIVISION.
        INPUT-OUTPUT     SECTION.
        FILE-CONTROL.
**** File F1 ****
        SELECT INPUTFILE_F1 ASSIGN TO SORT_OUT_JOIN_F1
        ORGANIZATION IS SEQUENTIAL
        ACCESS MODE IS SEQUENTIAL
        FILE STATUS IS IO-STATUS.

**** File F1 ****
        SELECT INPUTFILE_F2 ASSIGN TO SORT_OUT_JOIN_F2
        ORGANIZATION IS SEQUENTIAL
        ACCESS MODE IS SEQUENTIAL
        FILE STATUS IS IO-STATUS.

**** File OUTPUT ****
        SELECT OUTPUTFILE_JOIN ASSIGN TO SORT_OUT_JOIN_OUTPUT
        ORGANIZATION IS SEQUENTIAL
        ACCESS IS SEQUENTIAL
        FILE STATUS IS IO-STATUS.

        DATA DIVISION.
        
        FILE SECTION.
        FD  INPUTFILE_F1
            LABEL RECORD STANDARD
            RECORD is VARYING in SIZE from 1 to 4094
            DEPENDING ON DATA_REC_F1_LEN.
            01  DATA_REC_F1     PIC X(4094).
        FD  INPUTFILE_F2
            LABEL RECORD STANDARD
            RECORD is VARYING in SIZE from 1 to 4094
            DEPENDING ON DATA_REC_F2_LEN.
            01  DATA_REC_F2     PIC X(4094).
        FD  OUTPUTFILE_JOIN
            LABEL RECORD STANDARD
            RECORD is VARYING in SIZE from 1 to 4094
            DEPENDING ON DATA_REC_OUT_LEN.
            01  DATA_REC_OUT     PIC X(4094).

        WORKING-STORAGE SECTION.
        01  result PIC 9(9) binary VALUE 0.
        01  bitpos PIC 99.
        01  MT_BATCH_JOIN_METHOD PIC X(4000).
        01  MT_BATCH_JOINKEYS_F1 PIC X(4000).
        01  MT_BATCH_JOINKEYS_F2 PIC X(4000).
        01  MT_BATCH_JOINKEYS_FORMAT PIC X(4000).
        01  MT_BATCH_JOINKEYS_FILL   PIC X(4000).
        01  MT_LENGTH     PIC 9(6).
        01  MT_START      PIC 9(6).
        01  MT_COUNT      PIC 9(6).
        01  MT_COUNT_ALL  PIC 9(6).
        01  MT_POS        PIC 9(6).
        01  MT_FILENAME   PIC X(256).
        01  MT_FILL_CHAR  PIC X.
        01  MT_FILL_CHAR_TMP   PIC X.
        01  MT_FILL_CHAR_TYPE  PIC X(1).
        01  MT_FILL_CHAR_STR   PIC X(2).
        01  MT_FILL_CHAR_STR2  PIC 99.
        01  MT_COUNT_PAIRED  PIC 9(6).

        01  DATA_REC_F1_LEN  PIC 9(6).
        01  DATA_REC_F2_LEN  PIC 9(6).
        01  DATA_REC_OUT_LEN PIC 9(6).
        01  DATA_REC_OUT_POS PIC 9(6).

        01  REC_JOIN_F1        PIC X(4094).
        01  REC_JOIN_F1_LEN    PIC 9(6).
        01  REC_JOIN_F2        PIC X(4094).
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
            03 KEY_ARY_LEN_F1 PIC 9(6).
            03 KEY_ARY_IDX_F1 PIC 9(6).
            03 KEY_ARY_F1 OCCURS 1 TO 1000 TIMES DEPENDING ON KEY_ARY_LEN_F1.
                05 KEY_START   PIC 9(6).
                05 KEY_LENGTH  PIC 9(6).
                05 KEY_ORDER   PIC X(1).                
        01 KEY-F2.
            03 KEY_ARY_LEN_F2 PIC 9(6).
            03 KEY_ARY_IDX_F2 PIC 9(6).
            03 KEY_ARY_F2 OCCURS 1 TO 1000 TIMES DEPENDING ON KEY_ARY_LEN_F2.
                05 KEY_START   PIC 9(6).
                05 KEY_LENGTH  PIC 9(6).
                05 KEY_ORDER   PIC X(1).
        01 OUTFORMAT.
            03 ARY_LEN_OUTFORMAT PIC 9(6).
            03 ARY_IDX_OUTFORMAT PIC 9(6).
            03 ARY_OUTFORMAT OCCURS 1 TO 1000 TIMES DEPENDING ON ARY_LEN_OUTFORMAT.
                05 FILE_NAME   PIC X(256).
                05 KEY_START   PIC 9(6).
                05 KEY_LENGTH  PIC 9(6).
        
        01  IDX             PIC 9(4) COMP.
        01  STRING-PTR      PIC 9(4).
        01  Input-1-byte    Pic X. 
        01  Input-2-byte    Pic XX. 
        01  Output-Num      Pic 9(4). 
        01  Output-Num2     Pic 9(4). 
        01  status-code     pic 9(4) comp value zero.
        01  status-code-n   pic 9(4).
        01  pgm_return_code pic 9(4) value 1.
        01  programme-name  pic x(30).

        PROCEDURE DIVISION.
******* Analyze JOINKEYS statement for F1 ***
        MOVE SPACES TO MT_BATCH_JOINKEYS_F1
        DISPLAY "MT_BATCH_JOINKEYS_F1" UPON ENVIRONMENT-NAME
        ACCEPT MT_BATCH_JOINKEYS_F1 FROM ENVIRONMENT-VALUE
        MOVE 1 TO MT_LENGTH.
        PERFORM UNTIL MT_BATCH_JOINKEYS_F1(MT_LENGTH:1) = SPACE OR LOW-VALUE
            ADD 1 TO MT_LENGTH
        END-PERFORM
        DISPLAY "MT_BATCH_JOINKEYS_F1=" MT_BATCH_JOINKEYS_F1(1:MT_LENGTH)
        Move ZEROS TO MT_COUNT_ALL
        INSPECT MT_BATCH_JOINKEYS_F1 TALLYING MT_COUNT_ALL FOR ALL ','
        ADD 1 to MT_COUNT_ALL
        DIVIDE MT_COUNT_ALL by 3 GIVING MT_COUNT
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
            ADD 1 TO MT_COUNT
        END-PERFORM. 
            
******* Analyze JOINKEYS statement for F2 ***
        MOVE SPACES TO MT_BATCH_JOINKEYS_F2
        DISPLAY "MT_BATCH_JOINKEYS_F2" UPON ENVIRONMENT-NAME               
        ACCEPT MT_BATCH_JOINKEYS_F2 FROM ENVIRONMENT-VALUE
        MOVE 1 TO MT_LENGTH.
        PERFORM UNTIL MT_BATCH_JOINKEYS_F2(MT_LENGTH:1) = SPACE OR LOW-VALUE
            ADD 1 TO MT_LENGTH
        END-PERFORM
        DISPLAY "MT_BATCH_JOINKEYS_F2=" MT_BATCH_JOINKEYS_F2(1:MT_LENGTH)
           
        Move ZEROS TO MT_COUNT_ALL
        INSPECT MT_BATCH_JOINKEYS_F2 TALLYING MT_COUNT_ALL FOR ALL ','.
        ADD 1 to MT_COUNT_ALL
        DIVIDE MT_COUNT_ALL by 3 GIVING MT_COUNT
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
            ADD 1 TO MT_COUNT
        END-PERFORM.

** Analyze JOIN statement
        MOVE SPACES TO MT_BATCH_JOIN_METHOD
        DISPLAY "MT_BATCH_JOIN_METHOD" UPON ENVIRONMENT-NAME
        ACCEPT MT_BATCH_JOIN_METHOD FROM ENVIRONMENT-VALUE
        MOVE 1 TO JOIN-LG.
        PERFORM UNTIL MT_BATCH_JOIN_METHOD(JOIN-LG:1) = SPACE OR LOW-VALUE
            ADD 1 TO JOIN-LG
        END-PERFORM
        DISPLAY "MT_BATCH_JOIN_METHOD=" MT_BATCH_JOIN_METHOD(1:JOIN-LG)

        EVALUATE TRUE 
            WHEN MT_BATCH_JOIN_METHOD EQUAL TO "UNPAIRED,F1"
                DISPLAY "SUPPORTED JOIN METHOD:" MT_BATCH_JOIN_METHOD(1:JOIN-LG)
            WHEN OTHER
                DISPLAY "NOT SUPPORTED JOIN-STATEMENG:" MT_BATCH_JOIN_METHOD(1:JOIN-LG)
                GO TO FIN-REL
        END-EVALUATE 

** Analyze REFORMAT statement
        MOVE SPACES TO MT_BATCH_JOINKEYS_FORMAT
        DISPLAY "MT_BATCH_JOINKEYS_FORMAT" UPON ENVIRONMENT-NAME               
        ACCEPT MT_BATCH_JOINKEYS_FORMAT FROM ENVIRONMENT-VALUE
        MOVE 1 TO MT_LENGTH.
        PERFORM UNTIL MT_BATCH_JOINKEYS_FORMAT(MT_LENGTH:1) = SPACE OR LOW-VALUE
            ADD 1 TO MT_LENGTH
        END-PERFORM
        MOVE ',' TO MT_BATCH_JOINKEYS_FORMAT(MT_LENGTH:1)
        DISPLAY "MT_BATCH_JOINKEYS_FORMAT=" MT_BATCH_JOINKEYS_FORMAT(1:MT_LENGTH)

        MOVE ZEROS TO MT_COUNT_ALL
        INSPECT MT_BATCH_JOINKEYS_FORMAT TALLYING MT_COUNT_ALL FOR ALL ':' ALL ','.
        ADD 1 TO MT_COUNT_ALL
        DIVIDE MT_COUNT_ALL BY 3 GIVING MT_COUNT
        MOVE MT_COUNT TO ARY_LEN_OUTFORMAT

        MOVE 1 TO STRING-PTR. 
        MOVE 1 TO MT_COUNT.
        PERFORM VARYING MT_COUNT FROM 1 BY 1 UNTIL MT_COUNT > ARY_LEN_OUTFORMAT 
            UNSTRING MT_BATCH_JOINKEYS_FORMAT DELIMITED BY ',' OR ':'
                INTO FILE_NAME of ARY_OUTFORMAT(MT_COUNT)
                WITH POINTER STRING-PTR 
            UNSTRING MT_BATCH_JOINKEYS_FORMAT DELIMITED BY ',' OR ':'
                INTO KEY_START of ARY_OUTFORMAT(MT_COUNT)
                WITH POINTER STRING-PTR 
            UNSTRING MT_BATCH_JOINKEYS_FORMAT DELIMITED BY ',' OR ':'
                INTO KEY_LENGTH of ARY_OUTFORMAT(MT_COUNT)
                WITH POINTER STRING-PTR 
        END-PERFORM.             
            
** Analyze FILL char in REFORMAT statement
        MOVE SPACES TO MT_BATCH_JOINKEYS_FILL
        DISPLAY "MT_BATCH_JOINKEYS_FILL" UPON ENVIRONMENT-NAME               
        ACCEPT MT_BATCH_JOINKEYS_FILL FROM ENVIRONMENT-VALUE
        MOVE 1 TO MT_LENGTH.
        PERFORM UNTIL MT_BATCH_JOINKEYS_FILL(MT_LENGTH:1) = SPACE OR LOW-VALUE
            ADD 1 TO MT_LENGTH
        END-PERFORM
        DISPLAY "MT_BATCH_JOINKEYS_FILL=" MT_BATCH_JOINKEYS_FILL(1:MT_LENGTH)
        UNSTRING MT_BATCH_JOINKEYS_FILL(1:MT_LENGTH) DELIMITED BY X'27'
            INTO MT_FILL_CHAR_TYPE MT_FILL_CHAR_STR.

        EVALUATE TRUE 
            WHEN MT_FILL_CHAR_TYPE EQUAL TO "C"
                MOVE MT_FILL_CHAR_STR TO MT_FILL_CHAR
                DISPLAY "FILL WITH CHAR: MT_FILL_CHAR=" MT_FILL_CHAR_STR
            WHEN MT_FILL_CHAR_TYPE EQUAL TO "X"
** Convert HEX char to ASC CODE
                MOVE FUNCTION UPPER-CASE(MT_FILL_CHAR_STR) TO MT_FILL_CHAR_STR
                MOVE MT_FILL_CHAR_STR(1:1) TO INPUT-1-BYTE
                COMPUTE OUTPUT-NUM = (FUNCTION ORD (INPUT-1-BYTE)) - 1 
                IF OUTPUT-NUM <= 57 AND OUTPUT-NUM >= 48 THEN
                    COMPUTE OUTPUT-NUM = OUTPUT-NUM - 48
                ELSE 
                IF OUTPUT-NUM >= 65 AND OUTPUT-NUM <= 90 THEN
                    COMPUTE OUTPUT-NUM = OUTPUT-NUM - 65 + 10
                END-IF
                END-IF
                COMPUTE OUTPUT-NUM = OUTPUT-NUM * 16 
                MOVE MT_FILL_CHAR_STR(2:1) TO INPUT-1-BYTE
                COMPUTE OUTPUT-NUM2 = (FUNCTION ORD (INPUT-1-BYTE)) - 1 
                IF OUTPUT-NUM2 <= 57 AND OUTPUT-NUM2 >= 48 THEN
                    COMPUTE OUTPUT-NUM2 = OUTPUT-NUM2 - 48 
                ELSE 
                IF OUTPUT-NUM2 >= 65 AND OUTPUT-NUM2 <= 90 THEN
                    COMPUTE OUTPUT-NUM2 = OUTPUT-NUM2 - 65 + 10 
                END-IF
                END-IF
                COMPUTE OUTPUT-NUM = OUTPUT-NUM + OUTPUT-NUM2 + 1                
                MOVE FUNCTION CHAR(OUTPUT-NUM) TO MT_FILL_CHAR_TMP
                MOVE MT_FILL_CHAR_TMP TO MT_FILL_CHAR
            WHEN OTHER
                DISPLAY "NOT SUPPORTED FILL CHAR:" MT_BATCH_JOINKEYS_FILL(1:MT_LENGTH)
                GO TO FIN-REL
        END-EVALUATE

** Read F1 and F2
        OPEN INPUT INPUTFILE_F1.
        IF IO-STATUS NOT = "00"
            DISPLAY "READ OPEN FAILED: INPUTFILE_F1"
            DISPLAY "IO-STATUS =" IO-STATUS
            IF STATUS-KEY-1 = '9'
                DISPLAY "FILE ERROR, STATUS: 9/" BINARY-STATUS
            ELSE
                DISPLAY "FILE ERROR, STATUS: " IO-STATUS
            END-IF
            GO TO FIN-REL
        END-IF.

        OPEN OUTPUT OUTPUTFILE_JOIN
        IF IO-STATUS NOT = "00"
            DISPLAY "WRITE OPEN FAILED: OUTPUTFILE_JOIN"
            DISPLAY "IO-STATUS =" IO-STATUS
            IF STATUS-KEY-1 = '9'
                DISPLAY "FILE ERROR, STATUS: 9/" BINARY-STATUS
            ELSE
                DISPLAY "FILE ERROR, STATUS: " IO-STATUS
            END-IF
            GO TO FIN-REL
        END-IF.

    READ-LOOP-F1.
        MOVE ZEROS TO DATA_REC_F1_LEN.
        MOVE SPACES TO DATA_REC_F1.
        INSPECT DATA_REC_F1 REPLACING CHARACTERS BY MT_FILL_CHAR.
        
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
******** generate REC_JOIN_F1, to compare
        MOVE SPACES TO REC_JOIN_F1.
        MOVE 0 TO REC_JOIN_F1_LEN.
        MOVE 1 TO MT_POS.
        PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > KEY_ARY_LEN_F1
            MOVE KEY_START of KEY_ARY_F1(IDX)  TO MT_START
            MOVE KEY_LENGTH of KEY_ARY_F1(IDX) TO MT_LENGTH
            MOVE DATA_REC_F1(MT_START:MT_LENGTH) TO REC_JOIN_F1(MT_POS:MT_LENGTH)
            ADD MT_LENGTH TO REC_JOIN_F1_LEN
            ADD MT_LENGTH TO MT_POS
        END-PERFORM.

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

        MOVE 0 TO NB_RECS_F2.
        MOVE 0 TO MT_COUNT_PAIRED.       
        
    READ-LOOP-F2.
        MOVE ZEROS TO DATA_REC_F2_LEN.
        MOVE SPACES TO DATA_REC_F2.
        INSPECT DATA_REC_F2 REPLACING CHARACTERS BY MT_FILL_CHAR.

        READ INPUTFILE_F2 NEXT
            AT END
            IF MT_COUNT_PAIRED = 0
                MOVE SPACES TO DATA_REC_F2
                INSPECT DATA_REC_F2 REPLACING CHARACTERS BY MT_FILL_CHAR
                PERFORM WRITE-OUTPUT-FILE
            END-IF
            GO TO READ-LOOP-F1
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

** generate REC_JOIN_F2, to compare
        MOVE SPACES TO REC_JOIN_F2.
        MOVE 0 TO REC_JOIN_F2_LEN.
        MOVE 1 TO MT_POS.
        PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > KEY_ARY_LEN_F2
            MOVE KEY_START of KEY_ARY_F2(IDX)  TO MT_START
            MOVE KEY_LENGTH of KEY_ARY_F2(IDX) TO MT_LENGTH
            MOVE DATA_REC_F2(MT_START:MT_LENGTH) TO REC_JOIN_F2(MT_POS:MT_LENGTH)
            ADD MT_LENGTH TO REC_JOIN_F2_LEN
            ADD MT_LENGTH TO MT_POS
        END-PERFORM.

        EVALUATE TRUE 
            WHEN MT_BATCH_JOIN_METHOD EQUAL TO "UNPAIRED,F1"
                MOVE SPACES TO DATA_REC_OUT
                INSPECT DATA_REC_OUT REPLACING CHARACTERS BY MT_FILL_CHAR
                IF REC_JOIN_F1 EQUAL TO REC_JOIN_F2 THEN
                    ADD 1 TO MT_COUNT_PAIRED
                    PERFORM WRITE-OUTPUT-FILE
                ELSE
                    MOVE SPACES TO DATA_REC_F2
                    INSPECT DATA_REC_F2 REPLACING CHARACTERS BY MT_FILL_CHAR
                END-IF     
            WHEN OTHER
                DISPLAY "NOT Supported JOIN-STATEMENG:" MT_BATCH_JOIN_METHOD(1:join-lg)
                GO TO FIN-REL
        END-EVALUATE 

        GO TO READ-LOOP-F2.
        GO TO READ-LOOP-F1.
        
******** Write output file procedure **********************
    WRITE-OUTPUT-FILE.
        MOVE ZEROS TO DATA_REC_OUT_LEN
        MOVE 1 TO DATA_REC_OUT_POS
        PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > ARY_LEN_OUTFORMAT
            MOVE FILE_NAME of ARY_OUTFORMAT(IDX)  TO MT_FILENAME
            MOVE KEY_START of ARY_OUTFORMAT(IDX)  TO MT_START
            MOVE KEY_LENGTH of ARY_OUTFORMAT(IDX) TO MT_LENGTH
            EVALUATE TRUE 
            WHEN MT_FILENAME EQUAL TO "F1"
                MOVE DATA_REC_F1(MT_START:MT_LENGTH) TO DATA_REC_OUT(DATA_REC_OUT_POS:MT_LENGTH)
            WHEN MT_FILENAME EQUAL TO "F2"
                MOVE DATA_REC_F2(MT_START:MT_LENGTH) TO DATA_REC_OUT(DATA_REC_OUT_POS:MT_LENGTH)
            WHEN OTHER
                DISPLAY "NOT Supported FILE_NAME:" MT_FILENAME
                GO TO FIN-REL
            END-EVALUATE
            ADD MT_LENGTH TO DATA_REC_OUT_LEN
            ADD MT_LENGTH TO DATA_REC_OUT_POS
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
        END-IF.
        
******** successfully finished.        
        MOVE 0 to pgm_return_code.
        
******** Final processing **********************
    FIN-REL.
        CLOSE INPUTFILE_F1.
        CLOSE INPUTFILE_F2.
        CLOSE OUTPUTFILE_JOIN.
        IF pgm_return_code = 0
            EXIT PROGRAM returning 0
        ELSE
            EXIT PROGRAM returning 1
        END-IF

        STOP RUN.
******** END **********************
