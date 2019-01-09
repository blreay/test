        IDENTIFICATION DIVISION.
        PROGRAM-ID. RETVAL.

        ENVIRONMENT DIVISION.

        DATA DIVISION.

        WORKING-STORAGE SECTION.
        01 rt-param             PIC 9(9) comp-5  value zero.

        LINKAGE SECTION.
        01 CMD-LINE.
           02 CMD-LEN      PIC S9(4) COMP-5.
           02 CMD-DATA.
              03 CMD-CHAR  PIC X OCCURS 999 DEPENDING ON CMD-LEN.

        PROCEDURE DIVISION USING CMD-LINE.
             DISPLAY "longueur=" CMD-LEN.
             DISPLAY "ABENDCODE=" CMD-DATA.
             MOVE CMD-DATA(1:CMD-LEN) TO rt-param
             DISPLAY "ABEND-DISPLAY2=" rt-param.
*            CALL "ILBOABN0" USING rt-param.
           EXIT PROGRAM RETURNING rt-param.                                     
*          GOBACK RETURNING 3.                                                  
*          STOP RUN RETURNING 9.                                                

