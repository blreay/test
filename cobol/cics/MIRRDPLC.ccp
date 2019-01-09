      ****************************************************************
      * MIRRDPLC.cbl
      *  BEA TMA SNA example and verification CICS DPL
      *  client
      *
      * Notes
      *  <Etc...>
      *
      * [Distributed]
      * Copyright 1997, BEA Systems, Inc., all rights reserved.
      * @(#)SNA $Source: /repos/tma/sample/snasnt/MF/cics/MIRRDPLC.cob,v $
      *         $Revision: 1.2 $   $Author: xixisun $
      *         $Date: 2015/03/10 08:22:21 $   $State: Exp $
      ****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. MIRRDPLC.
       DATE-COMPILED.
      *REMARKS.
      ***************************************************************
      *                                                             *
      *   PROGRAM MIRRDPLC.                                         *
      *                                                             *
      *   SAMPLE COBOL PROGRAM. THIS PROGRAM IS A CICS DPL CLIENT.  *
      *   AS A SIMPLE REQUEST/RESPONSE THE PROGRAM WILL SEND A      *
      *   STRING ENTERED FROM THE TN3270 TERMINAL TO THE TUXEDO     *
      *   SERVER. THE SERVER WILL REVERSE THE STRING FOR A          *
      *   "MIRROR IMAGE" AND CONCATENATE THE IMAGE TO THE FORWARD   *
      *   IMAGE OF THE STRING. THE RETURNED STRING WILL DISPLAY ON  *
      *   THE TN3270 TERMINAL DISPLAY.                              *
      *                                                             *
      *   THIS DEMONSTRATES A CICS CLIENT USING A LINK API TO       *
      *   COMMUNICATE WITH THE TUXEDO SERVER. THE SAMPLE            *
      *   DEMONSTRATES A DPL LINK USING THE RDO PROGRAM ENTRY       *
      *   REMOTE SYSTEM AND SERVICE NAMES. A NON-WORKING EXAMPLE    *
      *   IS INCLUDED TO SHOW HOW TO MAKE THE DPL REQUEST USING     *
      *   THE NAMES DIRECTLY ON THE LINK API. THE SAMPLE            *
      *   MAY RUN AS A SIMPLE RR OR A TRANSACTIONAL RR SERVER.      *
      *                                                             *
      ***************************************************************
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

        01  LOG-TEXT PIC X(50).
        01  DSPMSG PIC X(8) VALUE "DSPMSG".
      ***************************************************************
       01  WS-CONSTANTS.
      *    05  RDO-PGM-ID                    PIC  X(8)
      *           VALUE 'MIRRDPLS'.
      * THE FOLLOWING COULD BE USED INSTEAD OF RDO PROGRAM ENTRY
           05  REMOTE-SYSID                  PIC  X(4)
                  VALUE '    '.
           05  REMOTE-SERVICE                PIC  X(8)
                  VALUE 'MIRRDPLS'.
      *
           05  INIT-CHAR                     PIC  X(1) VALUE X'40'.
           05  ERROR-NO-SCREEN-BUF           PIC  X(80)
                  VALUE 'ERROR >> UNABLE TO RECEIVE SCREEN BUFFER'.
           05  ERROR-NO-ALLOCATE             PIC  X(80)
                  VALUE 'ERROR >> UNABLE TO ALLOCATE COMMAREA'.
           05  ERROR-TRANSID-NOT-VALID       PIC  X(80)
                  VALUE 'ERROR >> INVALID TRANSID - SEE DOCUMENTATION'.
           05  ERROR-SERVICE-ERROR.
               10 FILLER                     PIC  X(40)
                  VALUE 'ERROR >> FAILURE REMOTE SERVICE DFHRESP='.
               10 ERRCODE                    PIC  X(8).
       01  WS-CONVERSATION.
           05  RESP-CODE                     PIC S9(8) COMP.
           05  ERROR-MSG                     PIC  X(80).
           05  SCREEN-LEN                    PIC S9(9) COMP.
           05  REQUEST-LEN                   PIC S9(4) COMP.
           05  RESPONSE-LEN                  PIC S9(9) COMP.
           05  RUN-TIMES                     PIC 9(4) VALUE ZEROS.
           05  IX                            PIC 9(4).

       LINKAGE SECTION.
       01  SCREEN-BUFFER.
           05  SCREEN-TRAN                   PIC  X(4).
           05  FILLER                        PIC  X(1).
           05  REQUEST-MESSAGE               PIC  X(955).
       01  COMMAREA.
           05  RESPONSE-MESSAGE              PIC  X(1915).

       PROCEDURE DIVISION.
       100-MAINLINE SECTION.
      ***************************************************************
      *   PERFORM THE SERVER REQUEST RESPONSE PROTOCOL              *
      ***************************************************************
           PERFORM 200-SCREEN-RECEIVE

           PERFORM 300-ALLOCATE-COMMAREA

           PERFORM 400-CALL-SERVICE

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
            MOVE "Started" TO LOG-TEXT.
            CALL DSPMSG USING
                DFHEIBLK
                DFHCOMMAREA
                LOG-TEXT.

            EXEC CICS RECEIVE
                SET(ADDRESS OF SCREEN-BUFFER)
                FLENGTH(SCREEN-LEN)
                MAXFLENGTH(LENGTH OF SCREEN-BUFFER)
            END-EXEC.
      *     display "screen-buf(" SCREEN-BUFFER(1 : SCREEN-LEN) ")".

       200-EXIT.
           EXIT.

       300-ALLOCATE-COMMAREA SECTION.
      ***************************************************************
      *   ALLOCATE A DATAAREA TO HOUSE THE RESPONSE FROM THE        *
      *   TUXEDO SERVER. ON THE LINK, USE THE LENGTH OF THE INPUT   *
      *   STRING AS DATALENGTH, AND THE MAXIMUM COMMAREA SIZE       *
      *   AS THE LENGTH. THESE PARAMETERS ARE USED TO TELL CICS     *
      *   TO SEND A SMALLER PORTION OF THE COMMAREA, BUT TO RECEIVE *
      *   THE EXPECTED AREA IN RESPONSE.                            *
      *   THIS IS ONLY ONE OF THE METHODS THAT CAN BE USED ON THE   *
      *   LINK. DATALENGTH IS OPTIONAL, IF USED MUST BE SMALLER     *
      *   THAN THE LENGTH VALUE. LENGTH MIGHT ACTUALLY BE SMALLER   *
      *   THAN THE COMMAREA, BUT CANNOT BE LARGER SO THAT IT WILL   *
      *   NOT EXCEED THE COMMAREA BOUNDS.                           *
      ***************************************************************

           EXEC CICS GETMAIN              SET(ADDRESS OF COMMAREA)
                                          INITIMG(INIT-CHAR)
                                          FLENGTH(LENGTH OF COMMAREA)
                                          RESP(RESP-CODE)
           END-EXEC.
           IF RESP-CODE NOT = DFHRESP(NORMAL)
              MOVE ERROR-NO-ALLOCATE               TO ERROR-MSG
              PERFORM 900-END-ERROR
           END-IF.

            UNSTRING REQUEST-MESSAGE(1 : SCREEN-LEN - 5)
                DELIMITED BY ' ' INTO REMOTE-SYSID COMMAREA RUN-TIMES.
            IF COMMAREA = SPACES
                MOVE ERROR-NO-SCREEN-BUF TO ERROR-MSG
                PERFORM 900-END-ERROR
            END-IF.

            PERFORM VARYING REQUEST-LEN
                FROM LENGTH OF COMMAREA BY -1
                UNTIL COMMAREA(REQUEST-LEN : 1)
                    > SPACES OR REQUEST-LEN = 0
            END-PERFORM.

      *     display "commarea(" COMMAREA(1 : REQUEST-LEN) ")".
      *     display "run-times(" RUN-TIMES ")".
      *
            IF RUN-TIMES IS NUMERIC AND RUN-TIMES > 1
                ADD 4 TO REQUEST-LEN
            ELSE
                MOVE 1 TO RUN-TIMES
            END-IF.


       300-EXIT.
           EXIT.

        400-CALL-SERVICE SECTION.
      ***************************************************************
      *   THE SECOND CHARACTER OF THE TRANSACTION WILL INDICATE     *
      *   WHETHER TO EXECUTE INCLUDE THE TUXEDO SERVER IN THE       *
      *   CICS TRANSACTION. (1 IS SYNCONRETURN, 2 IS SYNCPOINT)     *
      *                                                             *
      *   THE WORKING EXAMPLE RELIES ON THE RDO PROGRAM DEFINITION  *
      *   REMOTESYSTEM AND REMOTENAME FOR THE PROGRAM ID ON THE     *
      *   LINK.                                                     *
      *                                                             *
      *   AN ADDITIONAL EXAMPLE SHOWS HOW TO CODE THE REMOTE        *
      *   SYSTEM (CONNECTION ID) AND REMOTE SERVICE NAME ON THE     *
      *   LINK ITSELF. TO MAKE IT THE WORKING EXAMPLE, CHANGE       *
      *   THE REMOTE-SYSID CONSTANT TO CONTAIN THE VALID CONNECTION *
      ***************************************************************

            PERFORM VARYING IX FROM 1 BY 1
                UNTIL IX = RUN-TIMES + 1

                IF RUN-TIMES > 1
                    MOVE IX TO COMMAREA(REQUEST-LEN - 3 : 4)
      *             IF COMMAREA(1 : REQUEST-LEN) = "DELAY0004"
      *                 EXEC CICS DELAY
      *                     INTERVAL(30)
      *                 END-EXEC
      *             END-IF
                END-IF

                EVALUATE SCREEN-TRAN(2 : 1)
                    WHEN '1'
      *  IF THE TRANSACTION WAS H1PL PERFORM SYNCONRETURN
                        EXEC CICS LINK
                            PROGRAM(REMOTE-SERVICE)
                            DATALENGTH(REQUEST-LEN)
                            LENGTH(LENGTH OF COMMAREA)
                            COMMAREA(COMMAREA)
                            SYNCONRETURN
                            SYSID(REMOTE-SYSID)
                            RESP(RESP-CODE)
                        END-EXEC

                    WHEN '2'
      *  IF THE TRANSACTION WAS H2PL PERFORM FULL SYNCLEVEL
                        EXEC CICS LINK
                            PROGRAM(REMOTE-SERVICE)
                            DATALENGTH(REQUEST-LEN)
                            LENGTH(LENGTH OF COMMAREA)
                            COMMAREA(COMMAREA)
                            SYSID(REMOTE-SYSID)
                            RESP(RESP-CODE)
                        END-EXEC

                    WHEN OTHER
                        MOVE ERROR-TRANSID-NOT-VALID TO ERROR-MSG
                        PERFORM 900-END-ERROR
                END-EVALUATE

            END-PERFORM.

      *     IF SCREEN-TRAN(2 : 1) = '2' AND
      *         COMMAREA(1 : REQUEST-LEN - 4) = "ROLLBACK"
      *         EXEC CICS SYNCPOINT
      *             ROLLBACK
      *         END-EXEC
      *     END-IF.

            IF RESP-CODE EQUAL DFHRESP(NORMAL) OR DFHRESP(EOC)
                PERFORM VARYING RESPONSE-LEN
                    FROM LENGTH OF RESPONSE-MESSAGE BY -1
                    UNTIL RESPONSE-MESSAGE(RESPONSE-LEN : 1)
                        > SPACES OR RESPONSE-LEN = 0
                END-PERFORM
            ELSE
                EVALUATE RESP-CODE
                    WHEN DFHRESP(PGMIDERR)
                       MOVE 'PGMIDERR' TO ERRCODE
                    WHEN DFHRESP(INVREQ)
                       MOVE 'INVREQ' TO ERRCODE
                    WHEN DFHRESP(LENGERR)
                       MOVE 'LENGERR' TO ERRCODE
                    WHEN DFHRESP(NOTAUTH)
                       MOVE 'NOTAUTH' TO ERRCODE
                    WHEN DFHRESP(SYSIDERR)
                       MOVE 'SYSIDERR' TO ERRCODE
                    WHEN DFHRESP(TERMERR)
                       MOVE 'TERMERR' TO ERRCODE
                    WHEN OTHER
                       MOVE 'UNKNOWN' TO ERRCODE
                END-EVALUATE
                MOVE ERROR-SERVICE-ERROR TO ERROR-MSG
                PERFORM 900-END-ERROR
            END-IF.

        400-EXIT.
            EXIT.

        900-END-ERROR SECTION.
      ***************************************************************
      *   PERFORM A SYNCPOINT ROLLBACK AND THEN PERFORM RETURN      *
      ***************************************************************
            EXEC CICS SEND
                FROM(ERROR-MSG)
                FLENGTH(LENGTH OF ERROR-MSG)
                ERASE
            END-EXEC

            MOVE "Ended" TO LOG-TEXT.
            CALL DSPMSG USING
                DFHEIBLK
                DFHCOMMAREA
                LOG-TEXT.
            EXEC CICS RETURN
            END-EXEC.
      *     GOBACK.
        900-EXIT.
            EXIT.

        999-RETURN.
      ***************************************************************
      *   RETURN TO CLIENT. IMPLICIT SYNCPOINT PERFORMED ON         *
      *   EXEC CICS RETURN. IF THE TUXEDO SERVER WAS INVOLVED       *
      *   IN THE CICS TRANSACTION, TWO PHASE COMMIT WITH THE        *
      *   REMOTE SERVER WILL OCCUR.                                 *
      ***************************************************************
            EXEC CICS SEND
                FROM(RESPONSE-MESSAGE)
                FLENGTH(RESPONSE-LEN)
                ERASE
            END-EXEC

            MOVE "Ended" TO LOG-TEXT.
            CALL DSPMSG USING
                DFHEIBLK
                DFHCOMMAREA
                LOG-TEXT.
            EXEC CICS RETURN
            END-EXEC.
      *     GOBACK.
        999-EXIT.
            EXIT.
