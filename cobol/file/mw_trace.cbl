      $set sourceformat(free)
 identification division.
 program-id. mwtrace.
*********
*     * Trace functions
*     *  main entry     formatted trace according to level
*     *     call "mw_trace" using "MsgIdent"  other-param
*     *  hextrace       formatted trace with hexa/char format print
*     *     call "hextrace" using "MsgIdent" length-of-string string other-param
*     *  progtree       program call tree
*     *     call "progtree" using "MsgIdent" 
*     *   with:
*     *     MsgIdent: Message identifier (key in Mask-Definition): 8 char
*     *       for progtree, MsgIdent must refer to a message with 3 param: %2d %s %s
*     *     length-of-string: length of the "string" var ("length of" def: s9(9) usage comp-5)
*     *     string: the string to be displayed in hexa/char formats
*     *     other-param: parameter for the message with printf compatibility:
*     *       by ref. and null-terminated if "%s" in the mask
*     *       by value and binary-type if "%d" in the mask
*     *
*     * 1st time mw_trace is called the mask file (env var TRACE_MASK) is loaded
*     * use constraints: mw_trace must be called before hextrace or progtree
*********
 input-output section.
 file-control.
 select maskfile assign maskfile-name
    organization line sequential
    file status maskfile-st.
 data division.
 file section.
 fd  maskfile.
 01  maskfile-rec        pic x(512).

 working-storage section.
       copy "ctypes".
 77  VERS-NB PIC X(80) value
     "@(#) VERSION: 2.3 Dec 05 2006: Trace subprograms\".
*    "@(#) HISTORY: 2.3 Dec 05 2006: Message key becomes case insensitive for script compatibility\".
*    "@(#) HISTORY: 2.2 Aug 31 2006: Masks are loaded from a file for batch compatibility\".
*    "@(#) HISTORY: 2.1 Jul 12 2006: Debug mode added\".
*    "@(#) HISTORY: 2.0 Aug 31 2005: name changed into mw_trace, include hextrace\".
*    "@(#) HISTORY: 1.0 Mar 22 2001: tuxtrace: ulog, stderr and stdout trace\".

 01  MT-CURRENT-PROGRAM   pic x(12)  EXTERNAL.
 01  MT-CURRENT-PHASE     pic x(12)  EXTERNAL.
 01  MT-CURRENT-USER      pic x(12)  EXTERNAL.
 01  MT-DISPLAY-LEVEL     pic x(1)   EXTERNAL.

***** constants
 78  NB-MAX-MSG          value 256.  *> Max nb of masks read from file
* For hextrace:
 78  CHAR-PER-LINE       value 20.   *> nb of char displayed on each line
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

** for hextrace: mask-mask-end (mask-mask saved for last line)
 01  mask-mask-end           pic x(255).
** end for hextrace

** for progtree, program tree info (max depth of the tree: TREE-LIMIT)
 01 tree-pfunction       pic x(4) comp-5.
 01 tree-pparam-block.
    05 cblte-gpi-size    pic x(4) comp-5.
    05 cblte-gpi-flags   pic x(4) comp-5.
    05 cblte-gpi-handle  pointer.
    05 cblte-gpi-prog-id pointer.
    05 cblte-gpi-attrs   pic x(4) comp-5.
 01 tree-pname-buf       pic x(256).
 01 tree-pname-len       pic x(4) comp-5.
 01 tree-pstatus-code    pic x(2) comp-5.
 01 tree-wname-buf       pic x(256).
 01 tree-wname-len       pic x(4) comp-5.
 01 tree-num             usage long.
 01 tree-num-pt redefines tree-num usage is pointer.
 01 tree-i               pic 99.
 01 tree-nb-prog         pic 99.
 01 tree-tab-prog.
    05 filler occurs 0 to TREE-LIMIT depending on tree-nb-prog.
      10 tree-prog-lname pic x(32).
      10 tree-prog-pname pic x(256).
** end program tree info

 01  mask-printf             pic x(255).

 01  FormatedMsg-Display.
     02  HeaderDisplay.
         03  HeaderDisp-hms  pic 9(6)B.
     02  FormatedMsg-Ulog    pic x(1000). *> USERLOG prints time itself

** data for message header
 01  ws-header-message.
     02  tmsg-user           pic x(32).
     02  tmsg-phas           pic x(32).
     02  tmsg-prog           pic x(13).
     02  ws-date-time-syst.
       03  ws-ymd            pic 9(8).
       03  ws-hms            pic 9(6).
       03  ws-c              pic 9(2).
       03  filler            pic x(5).

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
 01  disp-char               pic x(MAX-HEXA-SIZE).

 linkage section.
*** lk for mwtrace
 01  lk-id     pic x(255).
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
 TheMain section.
 MainEntry.
	display "zzy"
     if mask-file-to-load
	display "zzy1"
        perform load-mask-file
     end-if
     if address of lk-id not = null
        move lk-id to Mask-To-Find
	INSPECT Mask-To-Find replacing characters by space after initial low-value
	display "zzy2  Mask-To-Find="  Mask-To-Find
	INSPECT Mask-To-Find replacing all low-value by space
	display "zzy2  Mask-To-Find="  Mask-To-Find
        perform mw-trace
     end-if
     exit program returning 0.

 hextraceEntry.
    entry "hextrace" using lk-id lk-length lk-string P1 P2 P3 P4 P5 P6 P7 P8 P9.
     move lk-id to Mask-To-Find.
     perform hextrace
     exit program returning 0.

 progtreeEntry.
    entry "progtree" using lk-id.
     move lk-id to Mask-To-Find.
     perform pgm-call-tree-info
     exit program returning 0.

 mw-trace section.
*** prints standard messages
 mw-trace-beg.
* look for mask
     perform Find-Mask.
* test level of msg
	display "zzy10 mask-lvl=" mask-lvl 
     if mask-lvl > 0 and mask-lvl > MT-DISPLAY-LEVEL
	display "zzy3"
        go to mw-trace-end
     end-if
* add header if needed and a null char at end of mask
     perform Prepare-Mask.
* mask is ready, build and print the message
     move function current-date to ws-date-time-syst
     move ws-hms            to HeaderDisp-hms
     call "sprintf" using FormatedMsg-Ulog, 
                          mask-printf
                          P1 P2 P3 P4 P5 P6 P7 P8 P9.
	display "zzy4".
     perform Print-Message.
	display "zzy5".
 mw-trace-end.
      exit.

 hextrace section.
*** prints hexa mode with header like main entry
 hextrace-beg.
* look for mask (the mask is for heading banner)
     perform Find-Mask.
* test level of msg
     if mask-lvl > 0 and mask-lvl > MT-DISPLAY-LEVEL
        go to hextrace-end
     end-if
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
     move function current-date to ws-date-time-syst
     move ws-hms            to HeaderDisp-hms
     call "sprintf" using FormatedMsg-Ulog, 
                          mask-printf
                          P1 P2 P3 P4 P5 P6 P7 P8 P9.
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
     end-perform.
* prints both characters and hexa
     move 1 to j
     perform varying i from 1 by CHAR-PER-LINE
                       until i > tab-length
        string printed-i                      delimited by size
               disp-hexa(j:CHAR-PER-LINE * 2) delimited by size
               " "                            delimited by size
               disp-char(i:CHAR-PER-LINE)     delimited by size
           into mask-mask
        perform Prepare-Mask
        move function current-date to ws-date-time-syst
        move ws-hms            to HeaderDisp-hms
        move mask-printf       to FormatedMsg-Ulog
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

 Find-Mask section.
*** look for a mask in mask table
*** input: Mask-To-Find, result: Mask-Found
 FindMskBeg.
	 display "zzy14 Mask-To-Find=" Mask-To-Find 
     set mask-i      to 1.
     search mask-struct
       at end
          move mask-impl          to Mask-Found
          move Mask-To-Find       to mask-id, mask-mask
*       when function UPPER-CASE(Mask-To-Find) = function UPPER-CASE(mask-struct(mask-i)(1:255))
*          move mask-struct(mask-i) to Mask-Found
*          display "zzy13 mask-lvl=" mask-lvl.
	when not function UPPER-CASE(Mask-To-Find) = function UPPER-CASE(mask-struct(mask-i)(1:255))
		display "zzy16 Mask-Found=" mask-struct(mask-i)
     end-search.
	display "zzy11 Mask-Found=" Mask-Found.
	display "zzy12 mask-lvl=" mask-lvl.
 FindMskEnd.
     exit.

 Prepare-Mask section.
*** add a header in the message if needed and a "\0" at end of mask
*** the header will be "MaskId (<phase>:<prog>@[<user>]) "
*** input: Mask-Found,  result: mask-printf
 AddHdrBeg.
     move spaces            to mask-printf
     if header-to-add
        move MT-CURRENT-USER  to tmsg-user
        move MT-CURRENT-PHASE to tmsg-phas
        move MT-CURRENT-PROGRAM  to tmsg-prog
        inspect tmsg-user converting low-value to spaces
        inspect tmsg-phas converting low-value to spaces
        inspect tmsg-prog converting low-value to spaces
        move 1  to nbr
        string  mask-id     delimited by space
             into mask-printf
             with pointer nbr
        string  " ("        delimited by size
                tmsg-phas   delimited by space
             into mask-printf
             with pointer nbr
        if tmsg-prog not = spaces
          string ":"        delimited by size
                 tmsg-prog  delimited by space
             into mask-printf
             with pointer nbr
        end-if
        if tmsg-user not = spaces
          string "@"        delimited by size
                  tmsg-user delimited by space
               into mask-printf
               with pointer nbr
        end-if
        string  ") "        delimited by size
                mask-mask   delimited by size
             into mask-printf
             with pointer nbr
      else
        move mask-mask      to mask-printf
     end-if
* Last char: low-value
     if not (mask-printf(length of mask-printf:1) = low-value or space)
        move low-value to mask-printf(length of mask-printf:1)
     end-if
     move length of mask-printf to nbr
     perform until (nbr = 0) or not (mask-printf(nbr:1) = low-value or space)
       move low-value       to mask-printf(nbr:1)
       subtract 1         from nbr
     end-perform.
 AddHdrEnd.
     exit.

 Print-Message section.
*** print the message from "FormatedMsg" according to mask-typ
 PrintMsgBeg.
* look for end of message (x"00" position in the string returned by sprintf)
     move low-value to FormatedMsg-Ulog(length of FormatedMsg-Ulog:1) *> au moins un x"00"
     move 1 to nbr
     perform until FormatedMsg-Ulog(nbr:1) = low-value   *> cherche 1er x"00"
       add 1 to nbr
     end-perform.
	display "zzy6" mask-typ
* prints the message (output according to mask-typ)
*      no userlog in this case, "u" message will be redirected to stderr
        inspect mask-typ replacing all "u" by "o"
	display "zzy7" mask-typ(1:1)
     if mask-typ(1:1) = "e" or mask-typ(2:1) = "e" or mask-typ(3:1) = "e"
	display "zzy8"
        display FormatedMsg-Display(1:(nbr - 1 + length of HeaderDisplay)) upon syserr
     end-if
     if mask-typ(1:1) = "o" or mask-typ(2:1) = "o" or mask-typ(3:1) = "o"
	display "zzy9"
        call "printf" using "%s"&x"0a00" FormatedMsg-Display
     end-if.
 PrintMsgEnd.
     exit.

 pgm-call-tree-info section.
 pgm-call-tree-beg.
      move low-value to tree-pparam-block.
      move 3 to cblte-gpi-flags
      move zero to tree-pfunction
      move length of tree-pname-buf to tree-pname-len
      move space to tree-pname-buf
      move length of tree-pparam-block to cblte-gpi-size
      call "CBL_GET_PROGRAM_INFO"
                  using by value     tree-pfunction
                  by reference tree-pparam-block
                  by reference tree-pname-buf
                  by reference tree-pname-len
                  returning    tree-pstatus-code
      end-call
      if tree-pstatus-code not = zero
         display "ERROR progtree " tree-pfunction " status=" tree-pstatus-code upon syserr
      end-if

      move zero to tree-nb-prog
      .
 pgm-call-tree-loop.
      move 2 to tree-pfunction
      move 3 to cblte-gpi-flags
      move length of tree-pname-buf to tree-pname-len
      move space to tree-pname-buf
      call "CBL_GET_PROGRAM_INFO"
                  using by value     tree-pfunction
                  by reference tree-pparam-block
                  by reference tree-pname-buf
                  by reference tree-pname-len
                  returning    tree-pstatus-code
      end-call
      if tree-pstatus-code not = zero
         if tree-pstatus-code not = 500
            display "ERROR progtree " tree-pfunction " status=" tree-pstatus-code upon syserr
         end-if
         go to pgm-call-tree-end
      end-if
      move length of tree-wname-buf to tree-wname-len
      move tree-pname-buf(1:tree-pname-len) to tree-wname-buf

      move 7 to tree-pfunction
      move length of tree-pname-buf to tree-pname-len
      move space to tree-pname-buf
      call "CBL_GET_PROGRAM_INFO"
                  using by value     tree-pfunction
                  by reference tree-pparam-block
                  by reference tree-pname-buf
                  by reference tree-pname-len
                  returning    tree-pstatus-code
      end-call
      if tree-pstatus-code not = zero
         display "ERROR progtree " tree-pfunction " status=" tree-pstatus-code upon syserr
      end-if

      if tree-nb-prog < TREE-LIMIT
         add 1 to tree-nb-prog
*******  move tree-wname-buf(1:tree-wname-len) to tree-prog-lname(tree-nb-prog)
         string tree-wname-buf(1:tree-wname-len) delimited by space
                x"00" delimited by size into tree-prog-lname(tree-nb-prog)
*******  move tree-pname-buf(1:tree-pname-len) to tree-prog-pname(tree-nb-prog)
         string tree-pname-buf(1:tree-pname-len) delimited by space
                x"00" delimited by size into tree-prog-pname(tree-nb-prog)
      else
         go pgm-call-tree-end
      end-if

      move 3 to tree-pfunction
      move length of tree-pparam-block to cblte-gpi-size
      call "CBL_GET_PROGRAM_INFO"
                  using by value     tree-pfunction
                  by reference tree-pparam-block
                  by reference tree-wname-buf
                  by reference tree-wname-len
                  returning    tree-pstatus-code
      end-call
      if tree-pstatus-code not = zero
         display "ERROR progtree " tree-pfunction " status=" tree-pstatus-code upon syserr
      end-if
      move length of tree-wname-buf to tree-wname-len
      move low-value to tree-pparam-block.
      move 3 to cblte-gpi-flags
      move 1 to tree-pfunction
      move length of tree-pparam-block to cblte-gpi-size
      call "CBL_GET_PROGRAM_INFO"
                  using by value     tree-pfunction
                  by reference tree-pparam-block
                  by reference tree-wname-buf
                  by reference tree-wname-len
                  returning    tree-pstatus-code
      end-call
      if tree-pstatus-code not = zero
         display "ERROR progtree " tree-pfunction " status=" tree-pstatus-code upon syserr
      end-if
      if tree-pstatus-code = zero
         go pgm-call-tree-loop
      else
         go pgm-call-tree-end
      end-if
      .

 pgm-call-tree-end.
      move 3 to tree-pfunction
      move length of tree-pparam-block to cblte-gpi-size
      call "CBL_GET_PROGRAM_INFO"
                  using by value     tree-pfunction
                  by reference tree-pparam-block
                  by reference tree-wname-buf
                  by reference tree-wname-len
                  returning    tree-pstatus-code
      end-call.
      if tree-pstatus-code not = zero
         display "ERROR progtree " tree-pfunction " status=" tree-pstatus-code upon syserr
      end-if

******* display the result
      move zero to tree-num
      perform varying tree-i from tree-nb-prog by -1 until tree-i = zero
         add 1 to tree-num
         set address of P1 to tree-num-pt *> trick to pass tree-num by value
         set address of P2 to address of tree-prog-lname(tree-i)
         set address of P3 to address of tree-prog-pname(tree-i)
         perform mw-trace
      end-perform
      .
 pgm-call-tree-real-end. exit.

 load-mask-file section.
      display "MT_DISPLAY_LEVEL" upon environment-name
      accept MT-DISPLAY-LEVEL    from environment-value
      if MT-DISPLAY-LEVEL not numeric
         move "2"                 to MT-DISPLAY-LEVEL
      end-if
      .
 load-file.
*** load the mask file into memory (only at 1st call)
      move zero        to NB-DEF-MSG
      move spaces      to maskfile-name
      display "MT_DISPLAY_MESSAGE_FILE"  upon environment-name
      accept maskfile-name    from environment-value
      move 1 to maskfile-lg
      perform until maskfile-name(maskfile-lg:1) = space or low-value
        add 1 to maskfile-lg
      end-perform
      open input maskfile
      if maskfile-st not = zero
         display "ERROR mw_trace: open file " maskfile-name(1:maskfile-lg) " st=" maskfile-st upon syserr
         go to load-end
      end-if
      .
 load-loop.
      read maskfile
         at end go to load-endloop
      end-read
      if maskfile-st not = zero
         display "ERROR mw_trace: read file " maskfile-name(1:maskfile-lg) " st=" maskfile-st upon syserr
         go to load-end
      end-if
	display "zzy100:"  maskfile-rec
      if maskfile-rec(1:1) = "#"  *> discard commented lines
         go to load-loop
      end-if
      move spaces      to Mask-Found
      unstring maskfile-rec delimited ";"
          into mask-id     mask-function mask-lvl    mask-typ
               mask-header mask-mask
	display "zzy101:"  mask-id     mask-function mask-lvl    mask-typ mask-header mask-mask
	display "zzy102:"  mask-typ 
      add 1            to nb-def-msg
      if nb-def-msg > NB-MAX-MSG
         display "ERROR mw_trace: file" maskfile-name(1:maskfile-lg) " table overloaded" upon syserr
         go to load-end
      end-if
      move Mask-Found  to Mask-Struct(nb-def-msg)
      go to load-loop.
      .
 load-endloop.
      close maskfile
      .
 load-end.
      if NB-DEF-MSG =  zero
*** nothing loaded, put one not to try to load at each call
         add 1          to NB-DEF-MSG
         move Mask-Impl to Mask-Struct(NB-DEF-MSG)
      end-if
      .
