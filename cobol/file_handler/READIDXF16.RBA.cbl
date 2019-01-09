       IDENTIFICATION   DIVISION.
       PROGRAM-ID.      READIDXF16.
       ENVIRONMENT      DIVISION.
       INPUT-OUTPUT     SECTION.
       FILE-CONTROL.
      $set fcdreg
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
         COPY EXTFHOPS.
         01  IO-STATUS PIC XX.

       LINKAGE SECTION.
         01 FCD.     COPY "XFHFCD.CPY".

       PROCEDURE DIVISION.
            SET ADDRESS OF FCD TO ADDRESS OF FH--FCD OF MW-ENTREE.
            MOVE Cobol-Type          TO Action-Type.

            OPEN INPUT MW-ENTREE.
            IF IO-STATUS NOT = "00"
                DISPLAY "OPEN INPUT FAILED"
                DISPLAY "IO-STATUS =" IO-STATUS
                GO TO FIN-REL
            END-IF.

      *  DISPLAY "------------READ SEQUENTIAL------------".
      *  READ-SEQUENTIAL.
      *     MOVE SPACES TO DATAF16-REC.
      *     READ MW-ENTREE NEXT
      *       AT END GO TO READ-BROWSE
      *     END-READ.
      *     PERFORM DISPLAY-RECORD THRU E-DISPLAY-RECORD.
      *     GO TO READ-SEQUENTIAL.

      *  READ-BROWSE.
      *    MOVE SPACES TO DATAF16-REC.
      *    MOVE 0    TO FCD-Reladdr-Offset.
      *    MOVE 64   TO FCD-Config-Flags.

      *    MOVE SPACES TO DATAF16-REC.
      *    MOVE "33" TO S-ID.
      *    START MW-ENTREE KEY IS GREATER THAN OR EQUAL TO S-ID.

      *  READ-BROWSE-NEXT.
      *     MOVE SPACES TO DATAF16-REC.
      *     READ MW-ENTREE NEXT
      *       AT END GO TO READ-KEY
      *     END-READ.
      *     PERFORM DISPLAY-RECORD THRU E-DISPLAY-RECORD.
      *     GO TO READ-BROWSE-NEXT.

         READ-KEY.
            MOVE SPACES TO DATAF16-REC.

            MOVE "2" TO S-ID
            MOVE 1 TO fcd-key-length.

            DISPLAY "------------READ KEY(" S-ID ")------------".

      *     MOVE Read-Random           TO Cobol-Op.
      *     PERFORM CALL-EXTFH-MODULE   THRU E-CALL-EXTFH-MODULE

      *     MOVE 34   TO FCD-Reladdr-Offset.
      *     MOVE 64   TO FCD-Config-Flags.
      *     START MW-ENTREE KEY IS GREATER THAN OR EQUAL TO S-ID.
      *     START MW-ENTREE KEY IS EQUAL TO S-ID.
            MOVE x'E9' TO Cobol-Op.
            PERFORM CALL-EXTFH-MODULE   THRU E-CALL-EXTFH-MODULE.

            MOVE Read-Seq              TO Cobol-Op.
      *     MOVE Read-Previous         TO Cobol-Op.
      *     MOVE Read-Random           TO Cobol-Op.
      *     MOVE Read-Direct           TO Cobol-Op.
      *     MOVE Read-Position         TO Cobol-Op.
      *     MOVE Step-Next             TO Cobol-Op. 
      *     MOVE x'CB' TO Cobol-Op. 
            PERFORM CALL-EXTFH-MODULE   THRU E-CALL-EXTFH-MODULE
      *     PERFORM DISPLAY-RECORD THRU E-DISPLAY-RECORD.
      *     MOVE Read-Position         TO Cobol-Op.
      *     PERFORM CALL-EXTFH-MODULE   THRU E-CALL-EXTFH-MODULE
      *     PERFORM DISPLAY-RECORD THRU E-DISPLAY-RECORD.
      *     MOVE Read-Position         TO Cobol-Op.
      *     PERFORM CALL-EXTFH-MODULE   THRU E-CALL-EXTFH-MODULE
      *     PERFORM DISPLAY-RECORD THRU E-DISPLAY-RECORD.


      *     MOVE Read-Seq              TO Cobol-Op.
      *     PERFORM CALL-EXTFH-MODULE   THRU E-CALL-EXTFH-MODULE
      *     READ MW-ENTREE
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

*     ***************************************
       CALL-EXTFH-MODULE.
           CALL "EXTFH" USING Action-Code FCD.
           MOVE FCD-File-Status TO IO-STATUS.
           IF IO-STATUS NOT = '00'
 Error         DISPLAY "ERROR:"
 Error         DISPLAY "FILEDML-2021: ASG_DATAF16. "
               IF FCD-Status-Key-1 = '9'
                   DISPLAY "FILE ERROR, STATUS: 9/" FCD-Binary 
               ELSE
 Error             DISPLAY "FILE ERROR, STATUS: " IO-STATUS
               END-IF
           END-IF.
       E-CALL-EXTFH-MODULE.
          EXIT.

         DISPLAY-RECORD.
           DISPLAY "RECORD" ": S-ID=" S-ID
                            ", S-NAME=" S-NAME
                            ", S-VALUE=" S-VALUE
                            ", RBA=" FCD-Reladdr-Offset.
         E-DISPLAY-RECORD.
           EXIT.
