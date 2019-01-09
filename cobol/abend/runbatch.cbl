       IDENTIFICATION DIVISION.
       PROGRAM-ID. runbatch.                                        
*     *                                                   
*     * ========================================================
*     *
       WORKING-STORAGE SECTION.                                         
       77  VERS-NB PIC X(80) value                                      
          "@(#) VERSION: 1.0 Nov 03 2009: Master program to run cobol\".
          copy "mtdata".                                              
       01 code-value             pic X(4).
       01 code-type              pic X(1).
       01 code-value-num         pic 9(4).
       01 code-value-sprintf.
         02 code-value-c         pic 9(4).
         02 filler               pic X value low-value.
       01 code-type-sprintf.
         02 code-type-c          pic x(1).
         02 filler               pic X value low-value.
       01 string-return-code     pic x(5).
       01 install-flag           pic x comp-x value zero.               
       01 install-addrs          usage procedure-pointer.               
       01 status-code            pic S9(9) comp-5 value zero. 
       01 status-code-prg        pic S9(9) comp-5 value zero.           
                                                                        
       01 x                      pic 9(4) comp-5.                       
       01 y                      pic 9(4) comp-5.                       
       01 msg-identifier         pic x(255).
       01 abort-type             pic x.
       01 abort-value            pic x(4).
       01 abend-value            pic x(4).
 
       01 commande-line.                                                 
          02 command-len         pic 9(4) comp-x.                       
          02 command-data.                                              
             03 command-char  pic x occurs 999 depending on command-len.
*     *
       01 reception.                                                    
          02 programme-name      pic x(30).                             
          02 longueur            pic s9(4) comp-5.                      
          02 param               pic x(256).                            
       01 exit-name              pic x(50).                             
       01 err-mes                pic x(512).                            
       01 err-mes-len            pic s9(9) comp-5.                      
       01 sqlcoded               pic s9(9) sign leading separate.       
*     *
*     * ========================================================
*     *
       LINKAGE SECTION.                                          
       01 cmd-line.                                                     
          02 cmd-len             pic 9(4) comp-x.                       
          02 cmd-data.                                                  
             03 cmd-char         pic x occurs 999 depending on cmd-len.
       01  ABEND-CODE   PIC S9(9) COMP-5.                                       

*     *
*     * ========================================================
*     *                                                              
       PROCEDURE DIVISION using cmd-line.                               
       DEBUT.                                                           
*     * Environment variables reading                                   
          display "RUNBATCH BEGIN :"
          call "mw_getenv".                                             
          call "mw_abort".
FGT       call "meta_sig_int".
*     *   move "D"     to MT-CTX-DB-STATE.
*     *           
*     * STANDARD ERROR procedure installation
*     *                      
          move "C" to MT-STRING-STATUS
          set install-addrs to entry "std_proc_error".                 
          call "CBL_ERROR_PROC" using install-flag                     
               install-addrs                    
               returning status-code.                             
          if status-code not zero then                                 
             display "ERROR Standard proc_error" upon syserr            
          end-if                                                       
          move cmd-line to commande-line.                               
          move 0 to x.                                                 
*     *                                                            
*     * Extraction of the program name from the command line       
*     *                                                                 
       LOOP-NAME.                                                       
          add 1 to x                                                    
          if x > command-len                                            
             move command-data (1:command-len) to programme-name    
             move 0 to longueur                                     
             go start-programme
          end-if.                                       
          if command-data (x:1) = space
*     *                                 
*     * If blanc separator found : Program name END
*     *              
             move x to y                                                
             subtract 1 from y                                          
             move command-data (1:y) to programme-name                  
             subtract x from command-len giving longueur                
             add 1 to x                                                 
             move command-data (x:longueur) to param                    
             move param to MT-PROGRAM-PARAMETERS
             go start-programme
          end-if.                                           
          go loop-name.
*     *
*     * ========================================================
       START-PROGRAMME.
*     * ========================================================
*     *                                              
*     * Loading ENTRYs for managing Accessors' STATs
           call "mw_dbstat"                                       
           if  MT-CTX-DB-USE = "Y"                                     
              call "mw_dblink"
           end-if.
           move programme-name to MT-CURRENT-PROGRAM.                  
*     * ========================================================  
*     *   Connect DataBase                                        
*     * ======================================================== 
           if  MT-CTX-DB-USE = "Y"                                     
              call "do_connect" returning status-code
              if status-code not zero then                              
                  move "DatabaseNotConnected" to msg-identifier
                  call "mw_trace" using msg-identifier
                  move "ProgramTreeCobol" to msg-identifier
                  call "progtree" using msg-identifier
                  move "U" to abort-type
                  move "0430" to abort-value
                  call "ba_abort" using abort-type abort-value
                  exit program returning 1                         
              end-if                                                    
*     * Database Error procedure Installation                   
              set install-addrs to entry "dba_proc_error"               
              call "CBL_ERROR_PROC" using install-flag                
                   install-addrs                                  
                   returning status-code                  
              if status-code not zero then                            
                 display "ERROR DataBase proc_error" upon sysout 
              end-if                                                  
           end-if                                                      
*     * ========================================================  
*     *   CALL lock file
*     * ========================================================  
*     *    call "mw_lock" using programme-name.
*     *
*     * ========================================================  
*     *   CALL UserRoutine BEGIN (MT_RTEXIT_BEGIN)                
*     * ========================================================  
           if MT-CTX-RTEXIT-CALL = "BOTH" or "BEGIN"                   
              move spaces to exit-name                                
              string "RTEX-"                                          
                     MT-CTX-RTEXIT-NAME delimited by space            
                     "-Begin"    into exit-name                       
              display ">> Execute RunTime UserRoutine BEGIN : "       
              exit-name                                                
              call exit-name                                          
           end-if                                                      
*     * ========================================================  
*     *   USER COBOL PROGRAM CALL                                 
*     * ========================================================  
           display ">> Program BEGIN : " programme-name.                
           call programme-name  using longueur                         
                param returning status-code-prg. 
           display ">> Program END : " programme-name.                  

       PROGRAM-DONE.                                                            
           CALL "ART_BATCH_EXIT" USING 0 .                                      
           EXIT PROGRAM RETURNING 0.                                            

       ENTRY "ART_BATCH_EXIT" USING ABEND-CODE.                                 

*     * ========================================================  
*     *   CALL User Routine END (MT_RTEXIT_END)                   
*     * ========================================================  
           if MT-CTX-RTEXIT-CALL = "BOTH" or "END"                     
              move spaces to exit-name                                
              string "RTEX-"                                          
                     MT-CTX-RTEXIT-NAME delimited by space            
                     "-End"    into exit-name                         
              display ">> Execute RunTime UserRoutine END : "         
                      exit-name                                      
              call exit-name                                          
           end-if                                                      
*     * ========================================================  
*     *   Disconnect DataBase                                     
*     * ========================================================
       IF ABEND-CODE NOT = 0 THEN                                               
*          DISPLAY "CIT: ABEND LEADS DB ROLLBACK! " ABEND-CODE                  
*          MOVE "U" TO MT-STRING-STATUS                                         
           move "0000" to abend-value                                           
           call "abend" using abend-value                                       
       END-IF.                                                                  

*     * Disconnection from ORACLE DATABASE and STAT printing  
           if MT-CTX-DB-USE = "Y"                                      
              if MT-STRING-STATUS = "C"
                      call "do_commit"
              else
                      call "do_rollback"
              end-if
              call "db_statprint"                                  
              call "do_disconnect" returning status-code              
           end-if                                                      
FGT       call "meta_sig_exit".
           move MT-STRING-STATUS to code-type-c
           move status-code-prg to code-value-c
           move spaces to string-return-code
           if MT-STRING-STATUS = "C"
              call "mw_trace" using "CobolNormalEnd" code-type-sprintf
              code-value-sprintf
           end-if
           if code-value = "S"
              call "sprintf" using
              string-return-code "%1s%-3.3s"&x"00" code-type-sprintf
              code-value-sprintf
           else
              call "sprintf" using
                    string-return-code "%1s%-4.4s"&x"00"
                    code-type-sprintf code-value-sprintf
           end-if
           display string-return-code upon syserr.
           exit program returning 0.                                   
*          stop run.
