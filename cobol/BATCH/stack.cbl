        IDENTIFICATION DIVISION.
        PROGRAM-ID. SYSABEND.

        ENVIRONMENT DIVISION.

        DATA DIVISION.

        WORKING-STORAGE SECTION.
       01 rt-param             PIC 9(9) comp-5  value zero.
       01 ccount                PIC 9(9) comp-5  value zero.
       01 ccountmax             PIC 9(9) comp-5  value 99999.
       01 BUF                  PIC X(99) .

        LINKAGE SECTION.
        01 CMD-LINE.
           02 CMD-LEN      PIC 9(4) COMP-x.
           02 CMD-DATA.
              03 CMD-CHAR  PIC X OCCURS 1 TO 999 DEPENDING ON CMD-LEN.


        PROCEDURE DIVISION USING CMD-LINE.
             DISPLAY "longueur=" CMD-LEN.
             DISPLAY "ABENDCODE=" CMD-DATA.
             MOVE CMD-DATA(1:CMD-LEN) TO rt-param
             DISPLAY "ABEND-DISPLAY2=" rt-param.
             PERFORM 350-MODIFY-RTN THRU 370-MR-EXIT 999 times.
      *      PERFORM 350-MODIFY-RTN 999 times.
           EXIT PROGRAM RETURNING rt-param.                                     

       350-MODIFY-RTN. 
           MOVE CMD-DATA TO BUF.
           ADD 1 TO ccount.
           PERFORM 420-MASTER-WRITE.                                      
       370-MR-EXIT.                                                             
           DISPLAY '370 ccount=' ccount.                             
           EXIT.                                                                
       420-MASTER-WRITE.                                                           
           DISPLAY '420 ccount=' ccount.                             
           GO TO 370-MR-EXIT.
      *    PERFORM 370-MR-EXIT.
      
