       IDENTIFICATION DIVISION.                                                 
       PROGRAM-ID. ILBOABNO.                                                    
                                                                                
       ENVIRONMENT DIVISION.                                                    
                                                                                
       DATA DIVISION.                                                           
       WORKING-STORAGE SECTION.                                                 
                                                                                
       LINKAGE SECTION.                                                         
       01  ABEND-CODE   PIC S9(9) COMP-5.                                       
                                                                                
       PROCEDURE DIVISION USING ABEND-CODE.                                     
           STOP RUN RETURNING ABEND-CODE.                                       
