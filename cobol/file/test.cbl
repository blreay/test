      $set sourceformat(free)
      IDENTIFICATION DIVISION. 
       PROGRAM-ID. ASCHEXCONV. 

       ENVIRONMENT DIVISION. 
       CONFIGURATION SECTION. 

       DATA DIVISION. 
       WORKING-STORAGE SECTION. 
        
       01  WORK-AREA. 
           05  WS-TXT-SUB         PIC S9(04)  VALUE ZERO COMP.   
           05  WS-TXT-SUB-01      PIC S9(04)  VALUE ZERO COMP.   
           05  WS-TXT-SUB-02      PIC S9(04)  VALUE ZERO COMP. 
           05  WS-CONV-BYTE-NUM. 
               10  FILLER         PIC  X(01)  VALUE LOW-VALUES. 
               10  WS-CONV-BYTE   PIC  X(01). 
           05  WS-CONV-NUM        REDEFINES WS-CONV-BYTE-NUM 
                                               PIC  9(04)  COMP. 
           05  WS-CONV-ZONE       PIC  X(20) VALUE SPACE. 
           05  WS-HEX-CHARS       PIC  X(16)  VALUE '0123456789ABCDEF'. 
           05  FILLER             REDEFINES WS-HEX-CHARS. 
               10  WS-X           PIC  X(01)  OCCURS 16 TIMES. 
                
       01 INPUT-AREA-01. 
* 05  SOURCE-INPUT-FIELD PIC  X(10)  VALUE 'ehstenf241'. 
           05  SOURCE-INPUT-FIELD PIC  X(10)  VALUE 'BBB'. 
           05  FILLER             REDEFINES SOURCE-INPUT-FIELD. 
               10   SOURCE-FIELD  PIC  X(01)  OCCURS 10 TIMES. 
                
       77  WS-QUOTIENT            PIC S9(04) VALUE ZERO COMP. 
       77  WS-REMAINDER           PIC S9(04) VALUE ZERO COMP.       
        
       01  INPUT-TEXT              PIC X(1). 
       01  myx              PIC X(1). 
       01 ord-ws pic 9(3) value 66. 
01   WS-FIELD-BIN    PIC S9(5) COMP VALUE ZERO. 
01    FILLER REDEFINES WS-FIELD-BIN. 
   03  FILLER PIC X. 
   03  WS-BYTE        PIC X. 
01  Input-1-byte  Pic X. 
01  Input-2-byte  Pic XX. 
01  my2byte  Pic XX. 
01  Output-Num  Pic 999. 
01  Output-Num2  Pic 999. 
        
       PROCEDURE DIVISION. 
        
       INITIALIZE  WS-CONV-ZONE. 
       PERFORM VARYING  WS-TXT-SUB FROM 1 BY 1 
               UNTIL    WS-TXT-SUB GREATER 10 
           MOVE SOURCE-FIELD(WS-TXT-SUB) TO WS-CONV-BYTE 
           COMPUTE  WS-QUOTIENT = WS-CONV-NUM / 16 
           COMPUTE  WS-REMAINDER = WS-CONV-NUM - WS-QUOTIENT * 16 
           COMPUTE  WS-TXT-SUB-01 = (WS-TXT-SUB - 1) * 2 + 1 
           COMPUTE  WS-TXT-SUB-02 =  WS-TXT-SUB * 2 
           MOVE WS-X(WS-QUOTIENT + 1)  TO WS-CONV-ZONE(WS-TXT-SUB-01:1) 
           MOVE WS-X(WS-REMAINDER + 1) TO WS-CONV-ZONE(WS-TXT-SUB-02:1) 
       END-PERFORM. 
        
       DISPLAY 'HEXADECIMAL ='  WS-CONV-ZONE.   

       display "Character at ordinal position ", 
               ord-ws, " in the". 
       display "program collating sequence is: ", 
               function char(ord-ws).
	  move 10 to ord-ws
        move function char(ord-ws) to myx
       display "program collating sequence is: " myx
               
	MOVE 'B' TO WS-BYTE. 
       display "program collating sequence is: " WS-FIELD-BIN
	MOVE '43' to my2byte
	MOVE 'E1' to my2byte
	MOVE my2byte(1:1) to Input-1-byte
Compute Output-Num = (Function Ord (Input-1-Byte)) - 1 
	if Output-Num <= 57 then
		compute Output-Num = Output-Num - 48
	end-if
	if Output-Num >= 65 then
		compute Output-Num = Output-Num - 65 + 10
	end-if
		compute Output-Num = Output-Num * 16 
       display "Value of " Input-1-byte "="  Output-Num
	MOVE my2byte(2:1) to Input-1-byte
Compute Output-Num2 = (Function Ord (Input-1-Byte)) - 1 
	if Output-Num2 <= 57 then
		compute Output-Num2 = Output-Num2 - 48 
	end-if
	if Output-Num2 >= 65 then
		compute Output-Num2 = Output-Num2 - 65 + 10 
	end-if
		compute Output-Num = Output-Num + Output-Num2 + 1
		
       display "Value of " Input-1-byte "="  Output-Num2
       display "Value of " my2byte "="  Output-Num
	move function char(Output-Num) to myx
       display "program collating sequence is: " myx.
