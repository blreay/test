       IDENTIFICATION   DIVISION.                                      
       PROGRAM-ID.      SHOWPARM1.                                      
       ENVIRONMENT      DIVISION.                                      
       INPUT-OUTPUT     SECTION.                                       
       DATA DIVISION.                                                  
       WORKING-STORAGE SECTION.                                        
         01  ARG        PIC X(50) VALUE SPACES.                        
       LINKAGE SECTION.                                                
         01  PARM-BUFFER.                                              
       *     05  PARM-LENGTH    PIC S9(4)   COMP-5. *> COMP => COMP-5
             05  PARM-LENGTH    PIC S9(4)   COMP
             05  PARM-DATA      PIC X(256).                       
       PROCEDURE DIVISION USING PARM-BUFFER.                           
           IF PARM-LENGTH > 0                                          
              DISPLAY "SHOWPARM1: PARM=(" PARM-DATA(1:PARM-LENGTH) ")"            
           ELSE                                                        
              DISPLAY "SHOWPARM1: PARM=()"                                         
           END-IF.                                                      
           CALL "SHOWPARM2" using PARM-BUFFER
                                                                        
           GOBACK.                                                      
      *    STOP RUN.                                                    
                                                                        
                                                                        
