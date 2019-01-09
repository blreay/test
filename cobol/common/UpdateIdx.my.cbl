       IDENTIFICATION DIVISION.
       PROGRAM-ID.  UpdateIdx.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
          SELECT VideoFile ASSIGN TO "IDXVIDEO.DAT"
                 ORGANIZATION IS INDEXED
                 ACCESS MODE IS DYNAMIC
                 RECORD KEY IS VideoCode
                 ALTERNATE RECORD KEY IS VideoTitle
                      WITH DUPLICATES
                 lock mode is automatic
                      with lock on multiple records
                 FILE STATUS IS VideoStatus.
       
       
       DATA DIVISION.
       FILE SECTION.
       FD VideoFile.
       01 VideoRecord.
          88 EndOfFile VALUE HIGH-VALUE.
          02 VideoCode               PIC 9(5).
          02 VideoTitle              PIC X(40).
          02 SupplierCode            PIC 99.
       
       WORKING-STORAGE SECTION.
       01   VideoStatus              PIC X(2).
       01   SeqNumber                PIC 99 VALUE 0.
       
       01 PrnVideoRecord.
          02 PrnVideoCode            PIC 9(5).
          02 PrnVideoTitle           PIC BBBBX(40).
          02 PrnSupplierCode         PIC BBBB99.

       01 sleep-time pic 99 value 1.
       01 begin-time pic 9(08) value zeroes.
       01 filler redefines begin-time.
          05 begin-hours pic 99.
          05 begin-minutes pic 99.
          05 begin-seconds pic 99.
          05 begin-hundredths pic 99.
       01 end-time pic 9(08) value zeroes.
       01 filler redefines end-time.
          05 end-hours pic 99.
          05 end-minutes pic 99.
          05 end-seconds pic 99.
          05 end-hundredths pic 99.
       01 elapsed-time pic 9(8).

       PROCEDURE DIVISION.
       Begin.
          OPEN I-O VideoFile.
       
          MOVE SPACES TO VideoTitle
          START VideoFile KEY IS GREATER THAN VideoTitle
             INVALID KEY  DISPLAY "VIDEO STATUS :- ", VideoStatus
          END-START
       
          READ VideoFile NEXT RECORD
      *   READ VideoFile NEXT RECORD WITH WAIT
             AT END SET EndOfFile TO TRUE
          END-READ.

          PERFORM UNTIL EndOfFile
             IF VideoStatus = '9D'
                DISPLAY "*** File locked ***"
             ELSE
                MOVE VideoCode TO PrnVideoCode
                MOVE VideoTitle TO PrnVideoTitle
                MOVE SupplierCode TO PrnSupplierCode
                DISPLAY  PrnVideoRecord
                IF SupplierCode < 99
                   COMPUTE SupplierCode = SupplierCode + 1
                END-IF
                REWRITE VideoRecord
                COMPUTE SeqNumber = SeqNumber + 1
                IF SeqNumber = 15
                   DISPLAY "*** Close and reopen the file ***"
                   DISPLAY "*** Lock released ***"
                   CLOSE VideoFile
                   MOVE 0 TO SeqNumber
                   OPEN I-O VideoFile
                   START VideoFile KEY IS GREATER THAN VideoTitle
                   INVALID KEY  DISPLAY "VIDEO STATUS :- ", VideoStatus
                   END-START
                END-IF
             END-IF
             PERFORM sleep-it
      *      READ VideoFile NEXT RECORD
             READ VideoFile NEXT RECORD WITH WAIT
                AT END SET EndOfFile TO TRUE
             END-READ
          END-PERFORM.
       
          CLOSE VideoFile.
          STOP RUN.

       sleep-it.
          accept begin-time from time
          move 0 to elapsed-time
          perform until elapsed-time > sleep-time
             accept end-time from time
             compute elapsed-time rounded =
             ( end-hours - begin-hours ) * 3600
             + ( end-minutes - begin-minutes ) * 60
             + ( end-seconds - begin-seconds )
             + ( end-hundredths - begin-hundredths ) / 100
          end-perform.
