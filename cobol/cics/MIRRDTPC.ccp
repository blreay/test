      ****************************************************************
      * MIRRDTPC.cbl
      *  BEA TMA SNA example and verification CICS
      *    client
      *
      * Notes
      *  <Etc...>
      *
      * [Distributed]
      * @(#)SNA $Source: /repos/tma/sample/snasnt/MF/cics/MIRRDTPC.cob,v $
      *         $Revision: 1.1 $   $Author: xixisun $
      *         $Date: 2014/02/19 05:29:57 $   $State: Exp $
      * Copyright 1997, BEA Systems, Inc., all rights reserved.
      ****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. MIRRDTPC.
       DATE-COMPILED.
      *REMARKS.
      ***************************************************************
      *                                                             *
      *   PROGRAM MIRRDTPC.                                         *
      *                                                             *
      *   SAMPLE COBOL PROGRAM. THIS PROGRAM IS A CICS DTP CLIENT.  *
      *   AS A SIMPLE REQUEST/RESPONSE THE PROGRAM WILL SEND A      *
      *   STRING ENTERED FROM THE TN3270 TERMINAL TO THE TUXEDO     *
      *   SERVER. THE SERVER WILL REVERSE THE STRING TO SHOW ITS    *
      *   "MIRROR IMAGE". THIS MIRROR IMAGE WILL BE DISPLAYED ON    *
      *   THE TN3270 TERMINAL DISPLAY.                              *
      *                                                             *
      *   THIS DEMONSTRATES A CICS CLIENT USING CPIC VERBS TO       *
      *   COMMUNICATE WITH THE TUXEDO CLIENT. THE SAMPLE            *
      *   MAY RUN AS A SIMPLE RR OR A TRANSACTIONAL RR SERVER.      *
      *                                                             *
      ***************************************************************
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

      ***************************************************************
      *   CPIC PSEUDO FILES COPYBOOKS FOUND IN CICS.SDFHCOB         *
      ***************************************************************
           COPY CMCOBOL.
           COPY SRRCOBOL.
      ***************************************************************
       01  SCREEN-BUFFER.
           05  SCREEN-TRAN                   PIC  X(4).
           05  FILLER                        PIC  X(1).
           05  MESSAGE-STRING                PIC  X(1915).

       01  WS-CONSTANTS.
           05  CH-PARTNER-ID                 PIC  X(8)
                  VALUE 'MIRRDTPS'.
           05  ERROR-MESSAGE-REQUIRED        PIC  X(80)
                  VALUE 'ERROR >> PLEASE ENTER A MESSAGE'.
           05  ERROR-UNABLE-TO-ALLOCATE      PIC  X(80)
                  VALUE 'ERROR >> UNABLE TO INITIATE CONVERSATION'.
           05  ERROR-TRANSID-NOT-VALID       PIC  X(80)
                  VALUE 'ERROR >> INVALID TRANSID - SEE DOCUMENTATION'.
           05  ERROR-UNEXPECTED-RESULT       PIC  X(80)
                  VALUE 'ERROR >> ABEND OR UNEXPECTED RESPONSE'.
       01  WS-CONVERSATION.
           05  RECEIVE-FLAG                  PIC  X(1).
               88  CONTINUE-RECEIVE   VALUE 'Y'.
               88  SEND-STATE         VALUE 'N'.
           05  SCREEN-LEN                    PIC S9(4)  COMP.
           05  MESSAGE-LEN                   PIC S9(9)  COMP.
           05  HOLD-RECEIVE-LEN              PIC S9(9)  COMP.
           05  RECEIVE-LEN                   PIC S9(9)  COMP.
           05  RESP-CODE                     PIC S9(4)  COMP.
           05  HOLD-REVERSE-CHAR             PIC  X(1).
      *
            05  IX PIC S9(4) COMP.
            05  JX PIC S9(4) COMP.

       LINKAGE SECTION.
       PROCEDURE DIVISION.
       100-MAINLINE SECTION.
      ***************************************************************
      *   PERFORM THE SERVER REQUEST RESPONSE PROTOCOL              *
      ***************************************************************
           PERFORM 200-SCREEN-RECEIVE

           PERFORM 300-ALLOCATE-CONVERSATION

           PERFORM 400-SEND-STRING
           PERFORM 500-RECEIVE-STRING

           PERFORM 600-END-CONVERSATION

           PERFORM 999-RETURN.

       100-EXIT.
           EXIT.

       200-SCREEN-RECEIVE SECTION.
      ***************************************************************
      *   RECEIVE THE SCREEN OF DATA. THIS IS NOT MAPPED TEXT BUT   *
      *   STRING DATA RECEIVED FROM THE 3270. THE PORTION OF THE    *
      *   TEXT AFTER THE TRANSACTION ID WILL BE SENT TO THE TUXEDO  *
      *   SERVER. IF NO TEXT WAS ENTERED, RETURN A MESSAGE TO THE   *
      *   SCREEN.                                                   *
      ***************************************************************

           EXEC CICS RECEIVE                  INTO(SCREEN-BUFFER)
                                              LENGTH(SCREEN-LEN)
                                              MAXLENGTH(1920)
           END-EXEC

      *     display "screen-len(" screen-len ")".
            PERFORM VARYING IX FROM 5 BY 1
                UNTIL SCREEN-BUFFER(IX:1) NOT = SPACE
                    OR IX > SCREEN-LEN
            END-PERFORM.
            MOVE IX TO JX.
            PERFORM VARYING IX FROM IX BY 1
                UNTIL SCREEN-BUFFER(IX:1) = SPACE
                    OR IX > SCREEN-LEN
            END-PERFORM.

            SUBTRACT JX FROM IX GIVING PARTNER-LU-NAME-LENGTH.
      *     display "ix(" ix ")jx(" jx ")".
      *     display "lu-len(" partner-lu-name-length ")".
            IF PARTNER-LU-NAME-LENGTH = 0
                MOVE ERROR-MESSAGE-REQUIRED TO SCREEN-BUFFER
                MOVE LENGTH OF ERROR-MESSAGE-REQUIRED TO SCREEN-LEN
                PERFORM 999-RETURN
            END-IF.
            MOVE SCREEN-BUFFER(JX:PARTNER-LU-NAME-LENGTH)
                TO PARTNER-LU-NAME.

            PERFORM VARYING IX FROM IX BY 1
                UNTIL SCREEN-BUFFER(IX:1) NOT = SPACE
                    OR IX > SCREEN-LEN
            END-PERFORM.
            MOVE IX TO JX.
            PERFORM VARYING IX FROM IX BY 1
                UNTIL IX > SCREEN-LEN
            END-PERFORM.
      *     display "ix(" ix ")jx(" jx ")".
      *     display "msg-len(" message-len ")".
            SUBTRACT JX FROM IX GIVING MESSAGE-LEN.
            IF MESSAGE-LEN = 0
                MOVE ERROR-MESSAGE-REQUIRED TO SCREEN-BUFFER
                MOVE LENGTH OF ERROR-MESSAGE-REQUIRED TO SCREEN-LEN
                PERFORM 999-RETURN
            END-IF.

            SUBTRACT 5 FROM JX.

       200-EXIT.
           EXIT.

       300-ALLOCATE-CONVERSATION SECTION.
      ***************************************************************
      *   ALLOCATE THE CONVERSATION WITH THE TUXEDO SERVER.         *
      *   BASED ON THE TRAN ID THAT INVOKED THIS PROGRAM, ALLOCATE  *
      *   THE CONVERSATION AS EITHER "RR" OR "TRANSACTIONAL RR"     *
      ***************************************************************

      ***************************************************************
      * THE CPIC SIDE INFORMATION FILE IS CONTAINED IN THE PARTNER  *
      * RDO DEFINITION. THE SYM-DEST-NAME IS THE PARTNER ID. THE    *
      * SIDE INFORMATION CONTAINS THE REMOTE SYSID AND PROGRAM NAME *
      *                                                             *
      * INITIALIZE THE CONVERSATION AND RECEIVE A VALID ID TO       *
      * IDENTIFY THE CONVERSATION ON EACH REQUEST.                  *
      ***************************************************************
           MOVE CH-PARTNER-ID                 TO SYM-DEST-NAME

           CALL 'CMINIT'                USING CONVERSATION-ID
                                              SYM-DEST-NAME
                                              CM-RETCODE

           IF CM-OK
              CONTINUE
           ELSE
              MOVE ERROR-UNABLE-TO-ALLOCATE   TO SCREEN-BUFFER
              MOVE LENGTH OF ERROR-UNABLE-TO-ALLOCATE
                                              TO SCREEN-LEN
              PERFORM 999-RETURN
           END-IF

      ***************************************************************
      **   Using screen input LU name And Set                         *
      **   Partner LU Name subroutine to override the                 *
      **   information contained in the Side Information profile.     *
      ***************************************************************

           CALL 'CMSPLN' USING CONVERSATION-ID
                               PARTNER-LU-NAME
                               PARTNER-LU-NAME-LENGTH
                               CM-RETCODE.

           IF CM-OK
              CONTINUE
           ELSE
              MOVE ERROR-UNABLE-TO-ALLOCATE   TO SCREEN-BUFFER
              MOVE LENGTH OF ERROR-UNABLE-TO-ALLOCATE
                                              TO SCREEN-LEN
              PERFORM 999-RETURN
           END-IF.

      ***************************************************************
      *   EXPLICITLY SET THE SYNCPOINT LEVEL OF THE CONVERSATION    *
      *     IF '0' IN SECOND POSITION OF TRANID (H0TP) "RR"         *
      *     IF '2' IN SECOND POSITION OF TRANID (H2TP) "TRANSACTION"*
      ***************************************************************
           EVALUATE EIBTRNID (2:1)
              WHEN '0'
                SET CM-NONE                   TO TRUE
              WHEN '2'
                SET CM-SYNC-POINT             TO TRUE
              WHEN OTHER
                MOVE ERROR-TRANSID-NOT-VALID  TO SCREEN-BUFFER
                MOVE LENGTH OF ERROR-TRANSID-NOT-VALID
                                              TO SCREEN-LEN
                PERFORM 999-RETURN
           END-EVALUATE

           CALL 'CMSSL'                 USING CONVERSATION-ID
                                              SYNC-LEVEL
                                              CM-RETCODE

      ***************************************************************
      *   THE DEFAULT CHARACTERISTICS OF THE ALLOCATED CONVERSATION *
      *        CM-MAPPED-CONVERSATION                               *
      *        CM-WHEN-SESSION-ALLOCATED                            *
      *        CM-DEALLOCATE-SYNC-LEVEL                             *
      *        CM-BUFFER-DATA                                       *
      *   CAN BE EXPLICITLY MANIPULATED WITH SET CONVERSATION VERBS *
      *   HOWEVER, WE WILL USE THE DEFAULST AND ALLOCATE THE CONV   *
      ***************************************************************

           CALL 'CMALLC'                USING CONVERSATION-ID
                                              CM-RETCODE

           IF CM-OK
              CONTINUE
           ELSE
              MOVE ERROR-UNABLE-TO-ALLOCATE   TO SCREEN-BUFFER
              MOVE LENGTH OF ERROR-UNABLE-TO-ALLOCATE
                                              TO SCREEN-LEN
              PERFORM 999-RETURN
           END-IF.

       300-EXIT.
           EXIT.

       400-SEND-STRING SECTION.
      ***************************************************************
      *   SEND THE MESSAGE STRING TO THE TUXEDO SERVER (RR)         *
      *   TURN THE CONVERSATION AROUND AND PREPARE TO RECEIVE       *
      *   THE CONVERTED STRING.                                     *
      ***************************************************************

      *  SAVE OFF THE FIRST CHARACTER FOR VALIDATION OF RESULTS
           MOVE MESSAGE-STRING (JX:1)          TO HOLD-REVERSE-CHAR

      *  SET THE SEND TYPE (SEND, FLUSH AND PREPARE TO RECEIVE)
           SET CM-SEND-AND-PREP-TO-RECEIVE    TO TRUE
           CALL 'CMSST'                 USING CONVERSATION-ID
                                              SEND-TYPE
                                              CM-RETCODE

      *  SET THE PREPARE TO RECEIVE TYPE (EXECUTED ON SEND)
           SET CM-PREP-TO-RECEIVE-FLUSH       TO TRUE
           CALL 'CMSPTR'                USING CONVERSATION-ID
                                              PREPARE-TO-RECEIVE-TYPE
                                              CM-RETCODE

      *  SEND THE STRING TO TUXEDO SERVER
            CALL 'CMSEND' USING CONVERSATION-ID
                MESSAGE-STRING(JX:MESSAGE-LEN)
                MESSAGE-LEN
                REQUEST-TO-SEND-RECEIVED
                CM-RETCODE
           IF CM-OK
              CONTINUE
           ELSE
              PERFORM 900-END-ERROR
           END-IF.

       400-EXIT.
           EXIT.

       500-RECEIVE-STRING SECTION.
      ***************************************************************
      *   RECEIVE THE CONVERTED STRING.                             *
      *                                                             *
      *   IF THE CONVERSATION IS A SIMPLE "RR" THE CONVERSATION     *
      *   PROBABLY BE IN DEALLOCATED STATE ON LAST RECEIVE          *
      *                                                             *
      *   IF THE CONVERSATION IS A TRANSACTIONAL "RR" A CONFIRMED   *
      *   WILL HAVE BEEN SHIPPED.                                   *
      ***************************************************************
           INITIALIZE MESSAGE-STRING.
           SET CONTINUE-RECEIVE           TO TRUE

           PERFORM UNTIL SEND-STATE

              MOVE ZEROES                 TO HOLD-RECEIVE-LEN

              CALL 'CMRCV'              USING CONVERSATION-ID
                                              MESSAGE-STRING
                                              MESSAGE-LEN
                                              DATA-RECEIVED
                                              HOLD-RECEIVE-LEN
                                              STATUS-RECEIVED
                                              REQUEST-TO-SEND-RECEIVED
                                              CM-RETCODE

              EVALUATE TRUE
               WHEN CM-DEALLOCATED-NORMAL OR CM-SEND-RECEIVED
                  SET SEND-STATE          TO TRUE
               WHEN NOT CM-OK
                  PERFORM 900-END-ERROR
               WHEN CM-CONFIRM-RECEIVED
                  PERFORM 800-CONFIRMED
               WHEN CM-CONFIRM-SEND-RECEIVED
                  PERFORM 800-CONFIRMED
                  SET SEND-STATE          TO TRUE
              END-EVALUATE

              IF HOLD-RECEIVE-LEN > 0
                 MOVE HOLD-RECEIVE-LEN    TO RECEIVE-LEN
              END-IF

           END-PERFORM

      *  MAKE SURE THAT ALL EXPECTED RESULTS!
           IF MESSAGE-LEN               EQUAL RECEIVE-LEN  AND
              HOLD-REVERSE-CHAR         EQUAL
                         MESSAGE-STRING (MESSAGE-LEN:1)
              CONTINUE
           ELSE
              PERFORM 900-END-ERROR
           END-IF.

           MOVE MESSAGE-LEN TO SCREEN-LEN.

       500-EXIT.
           EXIT.

       600-END-CONVERSATION SECTION.
      ***************************************************************
      *   DEPENDING ON HOW THE CONVERSATION WAS INITIATED           *
      *   "RR" OR "TRANSACTIONAL RR"                                *
      *   DIFFERENT PROTOCOL IS USED TO END THE CONVERSATION.       *
      *   THE FOLLOWING DEMONSTRATES EXPLICIT CONVERSATION VERBS    *
      ***************************************************************

           SET RR-OK                          TO TRUE

           EVALUATE TRUE
             WHEN CM-NONE

      ***************************************************************
      *   THIS IS SYNCLEVEL 0. IF THE CONVERSATION DEALLOCATE WAS   *
      *   NOT RECEIVED ON THE SEND, THEN DEALLOCATE IT.             *
      ***************************************************************
               IF CM-DEALLOCATED-NORMAL
                  SET CM-OK                   TO TRUE
               ELSE
                  CALL 'CMDEAL'         USING CONVERSATION-ID
                                              CM-RETCODE
               END-IF

             WHEN CM-SYNC-POINT

      ***************************************************************
      *   THIS IS SYNCLEVEL 2.                                      *
      *   DEALLOCATE AND PERFORM SYNCPOINT.                         *
      ***************************************************************
               CALL 'CMDEAL'            USING CONVERSATION-ID
                                              CM-RETCODE
               IF CM-OK
                  CALL 'SRRCMIT'        USING RR-SYNCPOINT-RETURN-CODES
               END-IF

           END-EVALUATE

           IF CM-OK  AND  RR-OK
              CONTINUE
           ELSE
              PERFORM 900-END-ERROR
           END-IF.

       600-EXIT.
           EXIT.

       800-CONFIRMED SECTION.
      ***************************************************************
      *   RESPOND TO THE CONFIRM REQUEST WITH A POSTIVE CONFIRMED   *
      ***************************************************************

           CALL 'CMCFMD'                USING CONVERSATION-ID
                                              CM-RETCODE

           IF CM-OK
              CONTINUE
           ELSE
              PERFORM 900-END-ERROR
           END-IF.

       800-EXIT.
           EXIT.

       900-END-ERROR SECTION.
      ***************************************************************
      *   PERFORM A SYNCPOINT ROLLBACK AND THEN PERFORM RETURN      *
      ***************************************************************

           CALL 'SRRBACK'               USING RR-SYNCPOINT-RETURN-CODES

           MOVE ERROR-UNEXPECTED-RESULT       TO SCREEN-BUFFER
           MOVE LENGTH OF ERROR-UNEXPECTED-RESULT
                                              TO SCREEN-LEN.

       900-EXIT.
           EXIT.

       999-RETURN.
      ***************************************************************
      *   RETURN TO CLIENT.                                         *
      ***************************************************************

      *    display "message(" message-len ")(" message-string ")".
           EXEC CICS SEND
               FROM(MESSAGE-STRING)
               LENGTH(SCREEN-LEN)
               ERASE
           END-EXEC.

           EXEC CICS RETURN END-EXEC.
           GOBACK.
       999-EXIT.
           EXIT.
