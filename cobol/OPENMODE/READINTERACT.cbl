       IDENTIFICATION   DIVISION.
       PROGRAM-ID.      READINTERACT.
       ENVIRONMENT      DIVISION.
       INPUT-OUTPUT     SECTION.
       FILE-CONTROL.
         SELECT MW-ENTREE ASSIGN TO DATAIDX
            ORGANIZATION IS INDEXED
      *     ACCESS MODE IS RANDOM          
            ACCESS MODE IS DYNAMIC
            RECORD KEY IS S-ID
            FILE STATUS IS IO-STATUS.

       DATA DIVISION.
       FILE SECTION.
         FD  MW-ENTREE
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
    
         01  INPUT-COMMAND PIC X(20).

       PROCEDURE DIVISION.
            PERFORM UNTIL INPUT-COMMAND= 'QUIT' OR 'quit'
                DISPLAY "Enter Command:-> " WITH NO ADVANCING
                ACCEPT INPUT-COMMAND

                IF INPUT-COMMAND = "OPEN" OR "open"
                   PERFORM OPEN-FILE THRU E-OPEN-FILE
                END-IF
                IF INPUT-COMMAND = "CLOSE" OR "close"
                   PERFORM CLOSE-FILE THRU E-CLOSE-FILE
                END-IF

                IF INPUT-COMMAND = "READ-SEQ" OR "read-seq"
                   PERFORM READ-SEQUENTIAL THRU E-READ-SEQUENTIAL
                END-IF

                IF INPUT-COMMAND = "READ-NEXT" OR "read-next"
                   PERFORM READ-NEXT THRU E-READ-NEXT
                END-IF

                IF INPUT-COMMAND = "READ-START" OR "read-start"
                   PERFORM READ-START THRU E-READ-START
                END-IF

                IF INPUT-COMMAND = "READ-KEY" OR "read-key"
                   PERFORM READ-KEY THRU E-READ-KEY
                END-IF

                IF INPUT-COMMAND = "DELETE-KEY" OR "delete-key"
                   PERFORM DELETE-KEY THRU E-DELETE-KEY
                END-IF

            END-PERFORM.

            EXIT PROGRAM.
            STOP RUN.

         OPEN-FILE.
            OPEN I-O MW-ENTREE.
            IF IO-STATUS NOT = "00"
                DISPLAY "OPEN INPUT FAILED"
                DISPLAY "IO-STATUS =" IO-STATUS
                GO TO E-OPEN-FILE
            END-IF.
         E-OPEN-FILE.

         READ-SEQUENTIAL.
            MOVE SPACES TO DATAV14-REC.
            READ MW-ENTREE NEXT
              AT END GO TO E-READ-SEQUENTIAL
            END-READ.
            IF IO-STATUS NOT = "00"
                DISPLAY "READ FAILED"
                DISPLAY "IO-STATUS =" IO-STATUS
                GO TO E-READ-SEQUENTIAL
            ELSE
                PERFORM DISPLAY-RECORD THRU E-DISPLAY-RECORD
            END-IF.
            GO TO READ-SEQUENTIAL.
         E-READ-SEQUENTIAL.

         READ-NEXT.
            MOVE SPACES TO DATAV14-REC.
            READ MW-ENTREE NEXT
              AT END GO TO E-READ-NEXT
            END-READ.
            IF IO-STATUS NOT = "00"
                DISPLAY "READ FAILED"
                DISPLAY "IO-STATUS =" IO-STATUS
                GO TO E-READ-NEXT
            ELSE
                PERFORM DISPLAY-RECORD THRU E-DISPLAY-RECORD
            END-IF.
         E-READ-NEXT.

         READ-START.
              DISPLAY "Enter Start Key:-> " WITH NO ADVANCING.
              ACCEPT S-ID.
              START MW-ENTREE KEY
                    GREATER THAN OR EQUAL TO S-ID
              END-START.
         E-READ-START.

         READ-KEY.
              DISPLAY "Enter Key:-> " WITH NO ADVANCING.
              ACCEPT S-ID.
              READ MW-ENTREE.
              IF IO-STATUS NOT = "00"
                DISPLAY "READ FAILED"
                DISPLAY "IO-STATUS =" IO-STATUS
                GO TO E-READ-KEY
              END-IF.
              PERFORM DISPLAY-RECORD THRU E-DISPLAY-RECORD.
         E-READ-KEY.
 
         DELETE-KEY.
              DISPLAY "Enter Delete Key:-> " WITH NO ADVANCING.
              ACCEPT S-ID.
              DELETE MW-ENTREE RECORD.
              IF IO-STATUS NOT = "00"
                DISPLAY "DELETE FAILED"
                DISPLAY "IO-STATUS =" IO-STATUS
                GO TO E-DELETE-KEY
              END-IF.
         E-DELETE-KEY.
 
         CLOSE-FILE.
            CLOSE MW-ENTREE.
         E-CLOSE-FILE
      
         DISPLAY-RECORD.
           DISPLAY "RECORD" ": S-ID=" S-ID
                            ", S-NAME=" S-NAME
                            ", S-VALUE=" S-VALUE.
         E-DISPLAY-RECORD.
           EXIT.
