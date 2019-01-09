       IDENTIFICATION DIVISION.                                         
       PROGRAM-ID. runb.                                                
       working-storage section.                                         
       77  VERS-NB PIC X(120) value                                     
           "@(#) VERSION: 1.0 Jun 15 2000: Master program to run batch c
      -    "obol programs \".                                           
                                                                        
          copy "mtdata".                                                
                                                                        
       01 programme-name           pic x(30).                           
	   01 programme-name1          pic x(30) value z"Hello world".           
	   01 programme-param          pic x(30) value z"Hello world".           
	   01 str
		   03 str-text  pic x(80).
		   03 filler   pic x value x"00". 	   
	   01 counter pic 9(8) comp-5 value zero.
       
	   01 my-c-string          pic x(80) value z"Hello world".
	   01 my-c-string3         pic x(100) value z"Hello world".
       01 my-c-len             pic s9(9) comp-5.
	   01 my-c-len2            pic s9(9) comp-5.
	   01 my-c-string2         pic x(80) value z"Hello world".

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
		 display "RUNB BEGIN :"                   

         display "runcso...MY C PROGRAM BEGIN 0011 :"                                         
           move "dlopen"        to programme-name1    
		   move z"/nfs/users/zhaozhan/test/c/pro_c/libuser_dyn.so" 
		     to programme-param
           call programme-name1 using 
		           by reference programme-param,
				   by value 1 size 4,
		           returning my-c-len2
			end-call
         display "runcso...MY C PROGRAM END. status-code=" my-c-len2.
		 
		  move z"/nfs/users/zhaozhan/test/c/pro_c/12.so"
		     to my-c-string3
	     call "load_so_file" using 
		                by reference my-c-string3, 
						returning my-c-len
          end-call

		 
		 move z"/nfs/users/zhaozhan/test/c/pro_c/libuser_dyn.so" 
		     to my-c-string
	     call "load_so_file" using 
		                by reference my-c-string, 
						returning my-c-len
          end-call

		  
		 move "libuser_dyn_main1"        to programme-name                     
		 call programme-name returning status-code.
		 
         display "runcso...MY C PROGRAM END. my-c-len=" my-c-len.

	     call "strlen" using 
		                by reference my-c-string, 
						returning my-c-len
          end-call

         display "my-c-string is " my-c-len " chars long"
         display "my-c-string is: " my-c-string(1:my-c-len)

		 
           move "runbatch"        to programme-name                     
           call programme-name using cmd-line returning status-code.    
         display "RUNB END :"                                           
       stop run returning 0.
