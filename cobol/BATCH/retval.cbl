        IDENTIFICATION DIVISION.
        PROGRAM-ID. RETVAL.

        ENVIRONMENT DIVISION.

        DATA DIVISION.

        WORKING-STORAGE SECTION.
       01 rt-param             PIC 9(9) comp-5  value zero.
       01 ccount                PIC 9(9) comp-5  value zero.
       01 ccountmax             PIC 9(9) comp-5  value 999999999.
       01 BUF                  PIC X(99) .

        LINKAGE SECTION.
       01 CMD-LINE.                                                     
      *****************************************************************
      *   If the gnt file will be called by runb (batchrt), the CMD-LEN 
      *       must be comp-5, because runbatch.gnt is using comp-5 to 
      *       transfer parameter
      *   If the gnt file will be called by cobrun or cobcrun,use comp-x
      *****************************************************************
      *   02 CMD-LEN             pic 9(4) comp-x.                       
          02 CMD-LEN             pic 9(4) comp-5.                       
          02 CMD-DATA.                                                  
             03 CMD-CHAR         pic x occurs 999 depending on cmd-len.

        PROCEDURE DIVISION USING CMD-LINE.
             DISPLAY "command length=" CMD-LEN.
             DISPLAY "command   data=" CMD-DATA "[END]" CMD-LEN.
             MOVE CMD-DATA(1:CMD-LEN) TO rt-param.
             DISPLAY "RETCODE=" rt-param.
           EXIT PROGRAM RETURNING rt-param.                                     
*     *    GOBACK RETURNING 3.                                                  

      *    STOP RUN RETURNING 0.                                                

