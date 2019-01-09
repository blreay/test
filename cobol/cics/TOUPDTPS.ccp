      ****************************************************************
      * TOUPDTPS.cbl
      *         TMA SNA example and verification
      *          CICS server
      *
      * Notes
      *         <Etc...>
      *
      * [Distributed]
      * @(#)SNA $Source: /repos/tma/sample/snasnt/MF/cics/TOUPDTPS.cob,v $
      *         $Revision: 1.1 $   $Author: xixisun $
      *         $Date: 2014/02/19 05:29:30 $   $State: Exp $
      * Copyright 1997, BEA Systems, Inc., all rights reserved.
      ****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. TOUPDTPS.
       DATE-COMPILED.
      *REMARKS.
      ***************************************************************
      *                                                             *
      *   PROGRAM TOUPDTPS.                                         *
      *                                                             *
      *   SAMPLE COBOL PROGRAM. THIS PROGRAM IS A CICS DTP SERVER   *
      *   AS A SIMPLE REQUEST/RESPONSE THE PROGRAM WILL DEMONSTRATE *
      *   RECEIVING A CHARACTER STRING OF DATA AND SENDING THE      *
      *   CONVERTED CHARACTER STRING IN RESPONSE. THE CHARACTER     *
      *   STRING IS CONVERTED FROM MIXED-CASE TO UPPER-CASE.        *
      *                                                             *
      *   THE DEMONSTRATION SHOWS HOW TO USE CICS APPC VERBS TO     *
      *   COMMUNICATE WITH THE TUXEDO CLIENT. THE SAMPLE            *
      *   MAY RUN AS A SIMPLE RR OR A TRANSACTIONAL RR SERVER.      *
      *                                                             *
      ***************************************************************
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CONVERSATION.
           05  WS-STRING                     PIC  X(80).
           05  CONVERSATION-ID               PIC  X(4) VALUE ' '.
           05  CONVERSATION-STATE            PIC S9(9)  COMP.
           05  SYNC-LEVEL                    PIC S9(4)  COMP.
               88 SYNC-NONE                    VALUE 0.
               88 SYNC-CONFIRM                 VALUE 1.
               88 SYNC-SYNCPT                  VALUE 2.
           05  BUFF-LEN                      PIC S9(9)  COMP.
           05  DUMMY-PTR                     POINTER.
           05  DUMMY-LEN                     PIC S9(9)  COMP.
           05  RESP-CODE                     PIC S9(4)  COMP.
       LINKAGE SECTION.
       01  APPC-BUFFER.
           05  FILLER
                OCCURS 0 TO 1920 TIMES
                    DEPENDING ON BUFF-LEN    PIC  X(1).
       01  DUMMY-AREA                        PIC  X(1920).

       PROCEDURE DIVISION.
       100-MAINLINE SECTION.
      ***************************************************************
      *   PERFORM THE SERVER REQUEST RESPONSE PROTOCOL              *
      ***************************************************************
           PERFORM 200-INIT-CONVERSATION

           PERFORM 400-RECEIVE

           IF BUFF-LEN > ZEROES
              PERFORM 500-CONVERT-STRING
              PERFORM 600-SEND
           END-IF

           PERFORM 300-END-CONVERSATION

           PERFORM 999-RETURN.

       100-EXIT.
           EXIT.

       200-INIT-CONVERSATION SECTION.
      ***************************************************************
      *   EXTRACT THE SYNCPOINT LEVEL OF THE CONVERSATION           *
      *                                                             *
      *   THE CONVERSATION ID IS IN THE EIB FIELD EIBTRMID. IT IS   *
      *   USED FOR THE FOLLOWING APPC VERBS TO IDENTIFY WHICH       *
      *   CONVERSATION THE VERB IS TO USE.                          *
      ***************************************************************

           MOVE EIBTRMID             TO CONVERSATION-ID

           EXEC CICS                    EXTRACT PROCESS
                                        CONVID (CONVERSATION-ID)
                                        SYNCLEVEL (SYNC-LEVEL)
                                        RESP (RESP-CODE)
           END-EXEC

           IF  RESP-CODE = DFHRESP(NORMAL)
               CONTINUE
           ELSE
              PERFORM 900-END-ERROR
           END-IF.

       200-EXIT.
           EXIT.

       300-END-CONVERSATION SECTION.
      ***************************************************************
      *   END THE RESPONSE AND CONVERSATION BASED ON SYNCLEVEL      *
      *   TYPE.                                                     *
      *                                                             *
      *   AN IMPLICIT CONVERSATION DEALLOCATE AND (TRANSACTIONAL)   *
      *   SYNCPOINT IS PERFORMED IN THIS EXAMPLE.                   *
      *                                                             *
      ***************************************************************

           EVALUATE TRUE

              WHEN  SYNC-NONE
      *   SEND LAST FLAG
                 EXEC CICS                  SEND LAST END-EXEC

              WHEN  SYNC-CONFIRM
      *   TUXEDO CLIENT DOES NOT SUPPORT CONFIRM LEVEL
                 PERFORM 900-END-ERROR

              WHEN  SYNC-SYNCPT
      *   TURN THE CONVERSATION AROUND AND SIGNAL END WITH CONFIRM
                 EXEC CICS                  SEND CONFIRM
                                            INVITE
                 END-EXEC

                 IF EIBERR = HIGH-VALUES
                     PERFORM 900-END-ERROR
                 ELSE
                     PERFORM 400-RECEIVE
                 END-IF

           END-EVALUATE.

       300-EXIT.
           EXIT.

       400-RECEIVE SECTION.
      ***************************************************************
      *   RECEIVE AND THEN CHECK THE STATE OF THE CONVERSATION      *
      ***************************************************************

           PERFORM WITH TEST AFTER
                      UNTIL EIBRECV  EQUAL LOW-VALUES

              MOVE ZEROES                TO DUMMY-LEN

              EXEC CICS                  RECEIVE
                                         CONVID(CONVERSATION-ID)
                                         SET(ADDRESS OF DUMMY-AREA)
                                         FLENGTH(DUMMY-LEN)
                                         STATE(CONVERSATION-STATE)
              END-EXEC

              IF CONVERSATION-STATE   = DFHVALUE(ROLLBACK) OR
                 EIBERR               = HIGH-VALUES
                 PERFORM 900-END-ERROR
              END-IF

              IF DUMMY-LEN            > ZEROES
                 PERFORM 700-SAVE-BUFFER
              END-IF

           END-PERFORM.

       400-EXIT.
           EXIT.

       500-CONVERT-STRING SECTION.
      ***************************************************************
      *   TRANSLATE FROM MIXED-CASE TO UPPER-CASE                   *
      ***************************************************************

           IF  BUFF-LEN > ZERO
               INSPECT APPC-BUFFER CONVERTING
                                        'abcdefghijklmnopqrstuvwxyz'
                                    TO  'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

           END-IF.

       500-EXIT.
           EXIT.

       600-SEND SECTION.
      ***************************************************************
      *   TRANSLATE FROM MIXED-CASE TO UPPER-CASE                   *
      ***************************************************************

           EXEC CICS                    SEND
                                        CONVID (CONVERSATION-ID)
                                        FROM (APPC-BUFFER)
                                        FLENGTH (BUFF-LEN)
                                        STATE (CONVERSATION-STATE)
           END-EXEC.

           IF CONVERSATION-STATE   = DFHVALUE(ROLLBACK) OR
              EIBERR               = HIGH-VALUES
              PERFORM 900-END-ERROR
           END-IF.

       600-EXIT.
           EXIT.

       700-SAVE-BUFFER SECTION.
      ***************************************************************
      *   GET A BUFFER FOR THE LENGTH OF AREA AND SAVE IT           *
      ***************************************************************

           MOVE DUMMY-LEN               TO BUFF-LEN
           EXEC CICS                    GETMAIN
                                       SET(ADDRESS OF APPC-BUFFER)
                                       FLENGTH(BUFF-LEN)
           END-EXEC

           MOVE DUMMY-AREA(1:BUFF-LEN)  TO APPC-BUFFER.

       700-EXIT.
           EXIT.

       900-END-ERROR SECTION.
      ***************************************************************
      *   AN ERROR WAS RECEIVED ACROSS THE CONVERSATION OR AN       *
      *   UNEXPECTED REQUEST/RESPONSE RECEIVED FROM TUXEDO CLIENT   *
      ***************************************************************

      *   IF RECEIVED ROLLBACK REQUEST PERFORM ROLLBACK AND RETURN
      *   ELSE ABEND.

           IF EIBSYNRB          EQUAL HIGH-VALUES
              EXEC CICS                SYNCPOINT ROLLBACK END-EXEC
           ELSE
              EXEC CICS                ABEND              END-EXEC
           END-IF.

       900-EXIT.
           EXIT.

       999-RETURN.
      ***************************************************************
      *   RETURN TO CLIENT.                                         *
      ***************************************************************
           EXEC CICS                           RETURN   END-EXEC.
           GOBACK.
       999-EXIT.
           EXIT.
