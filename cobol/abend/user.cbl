       IDENTIFICATION DIVISION.                                                 
       PROGRAM-ID. user.                                                        
                                                                                
       ENVIRONMENT DIVISION.                                                    
                                                                                
       DATA DIVISION.                                                           
       Working-storage section.                                                 
       01 rt-param             PIC  9(9) comp-5  value zero.                    
                                                                                
       PROCEDURE DIVISION.                                                      
       PROGRAM-BGEIN.                                                           
           DISPLAY "USER: Hello USER".                                          
                                                                                
           move  8  to  rt-param.                                               
*         call "ILBOABNO" using  rt-param.                                      
           call "hello" using  rt-param.                                       
           DISPLAY "USER: Can't reach here when ILBOABNO is called".            
                                                                                
       PROGRAM-DONE.                                                            
           DISPLAY "USER: Bye   USER".                                          
*          EXIT PROGRAM RETURNING 5.                                            
           GOBACK RETURNING 3.                                                  
*          STOP RUN RETURNING 9.                                                
* <user.cbl>                                                                    
