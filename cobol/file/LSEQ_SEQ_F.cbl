       IDENTIFICATION   DIVISION.
       PROGRAM-ID.      WriteFile.
       AUTHOR.          mnie.
       ENVIRONMENT      DIVISION.
       INPUT-OUTPUT     SECTION.
       FILE-CONTROL.
           SELECT FSEQFile ASSIGN TO EXTERNAL FIX_SEQ
               FILE STATUS IS FSEQstatus.
           
           SELECT LSEQFile ASSIGN TO EXTERNAL LSEQ
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT LSEQFile2 ASSIGN TO EXTERNAL LSEQ2
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
           FD FSEQFile
              LABEL RECORD STANDARD
              DATA RECORD FSEQDetails.
           01 FSEQDetails.
           COPY DATADEFINE.
           
           FD LSEQFile.
           COPY LSEQFILE.

           FD LSEQFile2.
           COPY LSEQFILE2.
       WORKING-STORAGE SECTION.
           01 FSEQstatus          PIC X(2).
       PROCEDURE DIVISION.
       P-START.
           OPEN OUTPUT FSEQFile.
           OPEN INPUT  LSEQFile2.
           OPEN INPUT  LSEQFile.
           READ LSEQFile 
                AT END SET EndOfFile TO TRUE
           END-READ
           PERFORM UNTIL EndOfFile
              MOVE StudentDetailsLseq TO FSEQDetails
              WRITE FSEQDetails
              END-WRITE

              READ LSEQFile 
                   AT END SET EndOfFile TO TRUE
              END-READ
           END-PERFORM
           DISPLAY "close FSEQFile".
           CLOSE FSEQFile.
*          DISPLAY "close LSEQFile".
*          CLOSE LSEQFile.
           display "here".
           DISPLAY "close LSEQFile2.
           CLOSE LSEQFile2.
           display "here2".
           P-GOBACK.
             GOBACK.

