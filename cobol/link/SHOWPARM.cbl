       IDENTIFICATION   DIVISION.                                      
       PROGRAM-ID.      SHOWPARM.                                      
       ENVIRONMENT      DIVISION.                                      
       INPUT-OUTPUT     SECTION.                                       
       DATA DIVISION.                                                  
       WORKING-STORAGE SECTION.                                        
        01  ARG        PIC X(50) VALUE SPACES.                        
        01  IDX        PIC 9(8) COMP.
        01  COUNTMAX   PIC 9(8) COMP.

       LINKAGE SECTION.                                                
         01  PARM-BUFFER.                                              
       *     05  PARM-LENGTH    PIC S9(4)   COMP-5. *> COMP => COMP-5
             05  PARM-LENGTH    PIC S9(4)   COMP
             05  PARM-DATA      PIC X(256).                       
       PROCEDURE DIVISION USING PARM-BUFFER.                           
           IF PARM-LENGTH > 0                                          
              DISPLAY "SHOWPARM0: PARM=(" PARM-DATA(1:PARM-LENGTH) ")"            
           ELSE                                                        
              DISPLAY "SHOWPARM0: PARM=()"                                         
           END-IF.                                                      

        MOVE 5 TO COUNTMAX.
        MOVE PARM-DATA(1:PARM-LENGTH) TO COUNTMAX.
        PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > COUNTMAX
            DISPLAY "SHOWPARM0: IDX=" IDX
            CALL "SHOWPARM1" using PARM-BUFFER
        END-PERFORM. 
                                                                        
           GOBACK.                                                      
      *    STOP RUN.                                                    
                                                                        
                                                                        
