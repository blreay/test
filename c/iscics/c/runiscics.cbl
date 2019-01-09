       IDENTIFICATION DIVISION.                                         
       PROGRAM-ID. runiscics.                                                
       working-storage section.                                         
       77  VERS-NB PIC X(120) value                                     
           "@(#) VERSION: 1.0 Jun 15 2000: Master program to run  c
      -    " so programs \".                                           
                                                                        
       01 programme-name           pic x(30).                           
       01 status-code              pic 9(4) comp value zero.            
       01 status-code-n            pic 9(4).                            
       01 mw_set_all_areas_for_update pic x.                            
          88 set_all_areas_for_update value "Y" "y".                    
                                                                        
       linkage section.                                                 
       01 cmd-line.                                                     
          02 cmd-len        pic 9(4) comp-x.                            
          02 cmd-data.                                                  
             03 cmd-char pic x occurs 1 TO 999 depending on cmd-len.    
                                                                        
       procedure division using cmd-line.                               
       debut.                                                           
*     * ========================================================  
*     *   USER COBOL PROGRAM CALL                                 
*     * ========================================================  
       display "*********************************"
       display "ENTER runiscics"

       display "runiscics...MY C PROGRAM BEGIN CALL iscics :"                                         
       move "iscics"        to programme-name                     
       call programme-name using cmd-line returning status-code.    
       display "runiscics...MY C PROGRAM END CALL iscics :"  status-code                                      

       display "EXIT runiscics"
       EXIT.
