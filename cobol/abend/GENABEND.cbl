       IDENTIFICATION   DIVISION.
       PROGRAM-ID.      GENABEND.
       ENVIRONMENT      DIVISION.
       INPUT-OUTPUT     SECTION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
         01  SOME-NUMBER PIC 9(4)  VALUE 10.
         01  RET-CODE    PIC 9(4)  VALUE 0.
       LINKAGE SECTION.
         01  PARM-BUFFER.
             05  PARM-LENGTH      PIC S9(4) COMP.
             05  PARM-DATA        PIC X(256).
       PROCEDURE DIVISION USING PARM-BUFFER.
           IF PARM-LENGTH > 0
              MOVE PARM-DATA(1:4) TO RET-CODE
              DISPLAY "PARM-LENGTH=" PARM-LENGTH
                      ",PARM-DATA=[" PARM-DATA(1:PARM-LENGTH) "]"
           ELSE
              DISPLAY "PARM-LENGTH=0"
           END-IF.

           DIVIDE SOME-NUMBER BY ZERO GIVING SOME-NUMBER.

           MOVE RET-CODE TO RETURN-CODE.
           GOBACK.
      *    STOP RUN.


