        IDENTIFICATION DIVISION.
        PROGRAM-ID.    ARTEXTFH.
        DATA DIVISION.
        WORKING-STORAGE SECTION.
        01  MT-DD-NAME                       PIC X(1024).
        01  MT-DD-NAME-C                     PIC X(1024).
        01  MT-DD-DISP-NAME                  PIC X(512).
        01  MT-DD-DISP-VALUE                 PIC X(4096).
        01  MT-DD-DISP-VALUE-C               PIC X(4096).
        01  MT-VAR-LEN                       pic s9(4) comp-5.
        01  MT-VAL-LEN                       pic s9(4) comp-5.
        01  COUNT_MOD                        pic s9(9) comp-5.
        01  RET_CODE                         pic s9(9) comp-5.

        LINKAGE SECTION.
        01  Action-Code.
            03  Action-Type                  PIC X(01).
            03  Cobol-Op                     PIC X(01).
                78  Open-Output              value x'01'.
                78  Open-Extend              value x'03'.
                78  close-file               value x'80'.
        01  FCD-Area.
            COPY "XFHFCD.CPY".
        01  FILE-DD-NAME                     PIC X ANY LENGTH.
        
        $set sourceformat(free)

        PROCEDURE DIVISION USING Action-Code FCD-Area.
           MOVE SPACES TO MT-DD-NAME
           SET ADDRESS OF FILE-DD-NAME TO FCD-FILENAME-ADDRESS
           MOVE FILE-DD-NAME(1:FCD-Name-Length) TO MT-DD-NAME(1:FCD-Name-Length)
           MOVE x"00" to MT-DD-NAME(FCD-Name-Length + 1:1)
           call "DBGLOG" using "IN ART FILE HANDLER(%s) Cobol-Op=%x"&x"00" 
                MT-DD-NAME, by value Cobol-Op

*           *if open lseq or open seq and file disp=mod, change open mode to extend
*           *  FCD-Organization  0: line seqential   1:sequential               
            IF Cobol-Op = close-file
                AND (FCD-Organization = 0 OR FCD-Organization = 1 )               
                call "DBGLOG" using "DD=%s"&x"00" MT-DD-NAME(1:FCD-Name-Length)
                
*               *Contruct environment variable name
                move spaces to MT-DD-DISP-NAME
                STRING  
                    "MT_INTRDR_DSNLIST" DELIMITED BY SIZE
                    x"00" DELIMITED BY SIZE
                INTO MT-DD-DISP-NAME
				call "DBGLOG" using "MT-DD-DISP-NAME=%s"&x"00" MT-DD-DISP-NAME
                
                MOVE 1 TO MT-VAR-LEN
                PERFORM UNTIL MT-DD-DISP-NAME(MT-VAR-LEN:1) = SPACE OR LOW-VALUE
                    ADD 1 TO MT-VAR-LEN
                END-PERFORM
                
*               *Get environment value of MT_INTRDR_DSNLIST
                MOVE all x"00" TO MT-DD-DISP-VALUE
                DISPLAY MT-DD-DISP-NAME(1:MT-VAR-LEN - 1) UPON ENVIRONMENT-NAME
                ACCEPT MT-DD-DISP-VALUE FROM ENVIRONMENT-VALUE
                MOVE 1 TO MT-VAL-LEN
                PERFORM UNTIL MT-DD-DISP-VALUE(MT-VAL-LEN:1) = SPACE OR LOW-VALUE
                    ADD 1 TO MT-VAL-LEN
                END-PERFORM
                MOVE x"00" to MT-DD-DISP-VALUE(MT-VAL-LEN + 1:1)
                call "DBGLOG" using "ENV: %s=%s"&x"00" MT-DD-DISP-NAME MT-DD-DISP-VALUE
               
*               *contruct 2 string to compare ";file;" and ";file1;file2;file3;"
                move ";" to MT-DD-DISP-VALUE-C(1:1)
                move  MT-DD-DISP-VALUE(1:MT-VAL-LEN) to MT-DD-DISP-VALUE-C(2:MT-VAL-LEN)
                move  ";" to MT-DD-DISP-VALUE-C(MT-VAL-LEN + 1:1)
                MOVE x"00" to MT-DD-DISP-VALUE-C(MT-VAL-LEN + 2:1)

                move ";" to MT-DD-NAME-C(1:1)
                move  MT-DD-NAME(1:FCD-Name-Length) to MT-DD-NAME-C(2:FCD-Name-Length)
                move  ";" to MT-DD-NAME-C(FCD-Name-Length + 2:1)
                MOVE x"00" to MT-DD-NAME-C(FCD-Name-Length + 3:1)
                call "DBGLOG" using "*MT-DD-NAME-C=%s"&x"00" MT-DD-NAME-C
                call "DBGLOG" using "*MT-DD-DISP-VALUE-C=%s"&x"00" MT-DD-DISP-VALUE-C

*               *Check if current file exist in MT_INTRDR_DSNLIST
                move 0 to COUNT_MOD
                inspect MT-DD-DISP-VALUE-C tallying COUNT_MOD for all  
                        MT-DD-NAME-C(1:FCD-Name-Length + 2)
                IF COUNT_MOD NOT = 0
*                   *This file appeared in INTRDR list
                    call "DBGLOG" using "Call art_submit_job():%s"&x"00" MT-DD-NAME
                    call "art_submi_job" using MT-DD-NAME(1:FCD-Name-Length)
                        returning RET_CODE
                    call "DBGLOG" using "art_submit_job() return %d"&x"00" 
                        by value RET_CODE
*               *   MOVE Open-Extend TO Cobol-Op
                END-IF   
            END-IF.

*           *Return to the normal caller
            CALL "EXTFH" USING ACTION-CODE FCD-AREA.
            EXIT PROGRAM.
