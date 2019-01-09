       IDENTIFICATION   DIVISION.
       PROGRAM-ID.      TEST.
       ENVIRONMENT      DIVISION.
       INPUT-OUTPUT     SECTION.
       FILE-CONTROL.
         SELECT OUT-FIXED-FILE
            ASSIGN TO "DATA.BINARY".
       DATA DIVISION.
       FILE SECTION.
         FD  OUT-FIXED-FILE
             LABEL RECORD STANDARD
             DATA RECORD FIXED-FILE-REC.
         01  FIXED-FILE-REC.
             03 GOODS-NAME        PIC X(04).
      *      03 GOODS-PRICE       PIC S99 COMP.
             03 GOODS-PRICE       PIC 99V99 COMP.
      *      03 GOODS-PRICE       PIC ZZ.ZZ.
      *      03 GOODS-PRICE       PIC ZZZZ.
             03 GOODS-DESC        PIC X(04).
       PROCEDURE   DIVISION.
            OPEN OUTPUT OUT-FIXED-FILE.

            MOVE "1111" TO GOODS-NAME.
            MOVE 11.11 TO GOODS-PRICE.
            MOVE "1111" TO GOODS-DESC.
            WRITE FIXED-FILE-REC.

            DISPLAY GOODS-PRICE.
            CLOSE OUT-FIXED-FILE.
            DISPLAY "Done".
            STOP RUN.
