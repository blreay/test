       IDENTIFICATION DIVISION.
       PROGRAM-ID. HELLO.
       DATA DIVISION.
       FILE SECTION.
       WORKING-STORAGE SECTION.
       01 WS-MESSAGE PIC X(40).
       01 WS-LENGTH  PIC S9(4) COMP.
       PROCEDURE DIVISION.
       A000-MAIN-PARA.
          display "HELLO zzy BEGIN"                                         
          MOVE 'Hello World' TO WS-MESSAGE
		  call "printf" using "%s"&x"0a00" "function zzy"
		  call "system" using "env"&x"0a00"
          MOVE '+12' TO WS-LENGTH
          EXEC CICS SEND TEXT 
             FROM (WS-MESSAGE)
             LENGTH(WS-LENGTH)  
          END-EXEC
          EXEC CICS RETURN
          END-EXEC.	 
