        IDENTIFICATION DIVISION.
        PROGRAM-ID. CASE1.  
        ENVIRONMENT DIVISION.  
        DATA DIVISION.

        WORKING-STORAGE SECTION.
       01 ccount                PIC 9(9) comp-5  value zero.

        PROCEDURE DIVISION .
           DISPLAY "BEGIN ccount=" ccount.
           PERFORM AA THRU DD 5000 times.
           EXIT PROGRAM RETURNING 0.  
       AA. 
           ADD 1 TO ccount.
           DISPLAY 'AA ccount=' ccount.                             
           PERFORM BB.                                      
       BB.                                                        
           DISPLAY 'BB ccount=' ccount.                             
           GO TO DD.
       CC.                                                             
           DISPLAY 'CC ccount=' ccount.                             
       DD.                                                             
           DISPLAY 'DD ccount=' ccount.                             
      
