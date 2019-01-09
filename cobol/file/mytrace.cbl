        $set sourceformat(free)
    IDENTIFICATION DIVISION.
    PROGRAM-ID. DBG.
    working-storage section.
       copy "ctypes".

    01 programme-name           pic x(30).
    01 status-code              pic 9(4) comp value zero.
    01 status-code-n            pic 9(4).
    01 MT_LENGTH                pic 9(4).
***** constants
 78  NB-MAX-MSG          value 256.  *> Max nb of masks read from file
* For hextrace:
 78  CHAR-PER-LINE       value 16.   *> nb of char displayed on each line
 78  MAX-HEXA-SIZE       value 4000. *> max nb of char displayed in total message
 78  NON-PRINTABLE-CHAR  value ".".  *> character printed in place of non printable char
* For progtree:
 78  TREE-LIMIT          value 50.   *> maximum depth of program tree
***** end constants

*** data to load mask file
 01  maskfile-name       pic x(256).
 01  maskfile-st         pic x(2).
 01  maskfile-lg         pic s9(9) comp-5. *> length of filename for debugging traces

*** data for mwtrace
 01  NB-DEF-MSG          pic s9(9) comp-5 value zero. *> init vl: force file loading at 1st call
     88  mask-file-to-load value zero.

 01  Mask-Array.
     02  mask-struct pic x(770) occurs 0 to NB-MAX-MSG depending on NB-DEF-MSG
                                indexed by mask-i.

 01  Mask-Impl. *> if msg not found (only 1st param is printed)
     02 filler pic x(770) value "????????0ueo 1........: ERROR mw_trace: Unknown msg mask".

 01  Mask-To-Find        pic x(255).
 01  Mask-Found.
     03  mask-id         pic x(255).
     03  mask-function   pic x(255).
     03  mask-lvl        pic x.
     03  mask-typ        pic x(3).
     03  mask-header     pic x.
       88 header-to-add    value "1".
     03  mask-mask       pic x(255).
** data for message header
01  mask-printf             pic x(255).
 01  ws-header-message.
     02  tmsg-user           pic x(32).
     02  tmsg-phas           pic x(32).
     02  tmsg-prog           pic x(13).
     02  ws-date-time-syst.
       03  ws-ymd            pic 9(8).
       03  ws-hms            pic 9(6).
       03  ws-c              pic 9(2).
       03  filler            pic x(5).
 01  FormatedMsg-Display.
     02  HeaderDisplay.
         03  HeaderDisp-hms  pic 9(6)B.
     02  FormatedMsg-Ulog    pic x(1000). *> USERLOG prints time itself
   01  FormatedMsg-Ulog2    pic x(1000). *> USERLOG prints time itself

** for hextrace: mask-mask-end (mask-mask saved for last line)
 01  mask-mask-end           pic x(255).
** end for hextrace
** misc data
 01  nbr                     pic s9(5) usage binary.

** data for hexa conversion
 01  xx0f                    pic x value x"0F".
 01  x0f redefines xx0f      pic x comp-x.
 01  xxf0                    pic x value x"F0".
 01  xf0 redefines xxf0      pic x comp-x.
 01  xx10                    pic x value x"10".
 01  x10 redefines xx10      pic x comp-x.
 01  x1                      pic x(4) comp-5 value 1.
 01  x                       pic x.
     88 x-is-not-printable values x"00" thru x"1f",
                                  x"7f",
                                  x"80" thru x"8f",
                                  x"ff".
 01  y redefines x           pic x comp-x.
 01  printed-i.
     02 filler               pic x value space.
     02 i                    pic 99999.
     02 filler               pic x(2) value ": ".
 01  j                       pic 99999.
 01  cod-hex                 pic x(16) value "0123456789abcdef".
 01  tab-length              pic s9(9) usage binary.
 01  disp-hexa.
     05 t occurs MAX-HEXA-SIZE.
        10 t1                pic x.
        10 t2                pic x.
        10 t3                pic x value ' '.
        10 t4                pic x value ' '.
 01  disp-char               pic x(MAX-HEXA-SIZE).
       01 code-value-sprintf.
        02 code-value-c         pic 9(4).
        02 filler               pic X value low-value.
      01 code-type-sprintf.
        02 code-type-c          pic x(1).
        02 filler               pic X value low-value.
01  counti                      pic 9(9) comp-5 value 1.
01  curpos                      pic 9(9) comp-5 value 0.
 		
 linkage section.
*** lk for mwtrace
 01  lk-id     pic x(128).
 01  P1 usage pointer.      *> Message parameters
 01  P2 usage pointer.
 01  P3 usage pointer.
 01  P4 usage pointer.
 01  P5 usage pointer.
 01  P6 usage pointer.
 01  P7 usage pointer.
 01  P8 usage pointer.
 01  P9 usage pointer.
*** lk for hextrace
 01  lk-length usage long.
 01  lk-string.
     05 filler pic x occurs 0 to 66000 depending lk-length.


    procedure division using lk-id P1 P2 P3 P4 P5 P6 P7 P8 P9.
    debut.    
    
TheMain section.
  MainEntry.
    perform mw-trace
    exit program returning 0.
    
*hextrace section.
 hextraceEntry.
    entry "hextrace" using lk-id lk-length lk-string P1 P2 P3 P4 P5 P6 P7 P8 P9.
    perform hextrace-sub
    exit program returning 0.
    
 mw-trace section.
*** prints standard messages
 mw-trace-beg.
* look for mask
*     perform Find-Mask.
* test level of msg
     perform Prepare-Mask.
* mask is ready, build and print the message
	move x'00' to FormatedMsg-Ulog
     call "sprintf" using FormatedMsg-Ulog, 
                          mask-printf
                          P1 P2 P3 P4 P5 P6 P7 P8 P9.

*	call "printf" using "%s"&x"0a00" FormatedMsg-Ulog					  
	perform Print-Message.
mw-trace-end.


 hextrace-sub section.
*** prints hexa mode with header like main entry
 hextrace-beg.
* look for mask (the mask is for heading banner)
* test level of msg
*  save mask for last-line message & length of data to be printed is too big?
     if lk-length > MAX-HEXA-SIZE
        move MAX-HEXA-SIZE to tab-length
        string "END (trunc) " delimited by size
              mask-mask       delimited by size
            into mask-mask-end
      else
        move lk-length to tab-length
        string "END "         delimited by size
              mask-mask       delimited by size
            into mask-mask-end
     end-if

** 1st line
* add header if needed and a null char at end of mask
     perform Prepare-Mask.
* mask is ready, build the 1st line message
	move x'00' to FormatedMsg-Ulog
     move function current-date to ws-date-time-syst
     move ws-hms            to HeaderDisp-hms
     call "sprintf" using FormatedMsg-Ulog, 
                          mask-printf
                          P1 P2 P3 P4 P5 P6 P7 P8 P9.
*	display FormatedMsg-Ulog
     perform Print-Message.

** loop (body of the message)
* translate characters into hexa
     move spaces    to disp-hexa
     move lk-string(1:tab-length) to disp-char
     perform varying i from 1 by 1
                       until i > tab-length
        move lk-string(i:1) to x
        if x-is-not-printable
           move NON-PRINTABLE-CHAR to disp-char(i:1)
        end-if
        call "CBL_AND" using x0f x by value x1
        add 1 to y
        move cod-hex(y:1) to t2(i)
        move lk-string(i:1) to x
        call "CBL_AND" using xf0 x by value x1
        divide x10 into y
        add 1 to y
        move cod-hex(y:1) to t1(i)
*		display "zzy102->" t1(i) "->" t2(i)
     end-perform.

		move x'00' to FormatedMsg-Ulog
		move x'00' to mask-mask
		move 1 to curpos
     perform varying counti from 1 by 1 until counti > CHAR-PER-LINE
	  call "sprintf" using mask-mask "%02d  "&x"00" by value counti
        move mask-mask(1:4) to FormatedMsg-Ulog2(curpos:4)
		compute curpos = curpos + 4
     end-perform.
        string printed-i                      delimited by size
               FormatedMsg-Ulog2(1:curpos)    delimited by size
			   x'00' delimited by size
           into FormatedMsg-Ulog
        move function current-date to ws-date-time-syst
        move ws-hms            to HeaderDisp-hms
        perform Print-Message.

* prints both characters and hexa
     move 1 to j
     perform varying i from 1 by CHAR-PER-LINE
                       until i > tab-length
		move x'00' to mask-mask
        string printed-i                      delimited by size
               disp-hexa(j:CHAR-PER-LINE * 4) delimited by size
               " |"                            delimited by size
               disp-char(i:CHAR-PER-LINE)     delimited by size
               "|" & x'00'                          delimited by size
           into mask-mask
	 move 1 to nbr

        move function current-date to ws-date-time-syst
        move ws-hms            to HeaderDisp-hms
        move mask-mask       to FormatedMsg-Ulog
        perform Print-Message
        add CHAR-PER-LINE CHAR-PER-LINE to j 
     end-perform.

** last line
     move mask-mask-end to mask-mask
* add header if needed and a null char at end of mask
     perform Prepare-Mask.
     move function current-date to ws-date-time-syst
     move ws-hms            to HeaderDisp-hms
     call "sprintf" using FormatedMsg-Ulog, 
                          mask-printf
                          P1 P2 P3 P4 P5 P6 P7 P8 P9.
     perform Print-Message.
 hextrace-end.
     exit.    

prepare-mask.	 
	move x'00' to mask-printf
     move function current-date to ws-date-time-syst
     move ws-hms            to HeaderDisp-hms
	 move 1 to nbr
	perform until lk-id(nbr:1) = low-value   *> cherche 1er x"00"
		move lk-id(nbr:1) to mask-printf(nbr:1)
		add 1 to nbr
*		display "nbr=" nbr
	end-perform.
	move low-value to mask-printf(nbr:1).
	
Print-Message section.
*** print the message from "FormatedMsg" according to mask-typ
    PrintMsgBeg.
* look for end of message (x"00" position in the string returned by sprintf)
    move low-value to FormatedMsg-Ulog(length of FormatedMsg-Ulog:1) *> au moins un x"00"
    move 1 to nbr
    perform until FormatedMsg-Ulog(nbr:1) = low-value   *> cherche 1er x"00"
        add 1 to nbr
    end-perform.
    call "printf" using "%s"&x"0a00" FormatedMsg-Display
    exit.
	 
	END PROGRAM DBG.
