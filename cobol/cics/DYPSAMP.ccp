       IDENTIFICATION DIVISION.
       PROGRAM-ID. DYPSAMP.
      *****************************************************************
      *                                                               *
      * MODULE NAME = DFHDYP                                          *
      *                                                               *
      * DESCRIPTIVE NAME = CICS     SAMPLE DYNAMIC ROUTING PROGRAM    *
      *                                     (COBOL VERSION)           *
      *                                                               *
      *   @BANNER_START                           02                  *
      *   Licensed Materials - Property of IBM                        *
      *                                                               *
      *   "Restricted Materials of IBM"                               *
      *                                                               *
      *   5655-M15              DFHDYP                                *
      *                                                               *
      *   (C) Copyright IBM Corp. 1988, 2004                          *
      *                                                               *
      *   CICS                                                        *
      *   (Element of CICS Transaction Server                         *
      *     for z/OS, Version 3 Release 2)                            *
      *   @BANNER_END                                                 *
      *                                                               *
      * STATUS = 6.4.0                                                *
      *                                                               *
      * FUNCTION =                                                    *
      *                                                               *
      * To provide an example of how the routing of transactions or   *
      * DPL requests may be performed dynamically, i.e. at run time.  *
      *                                                               *
      * When invoked, the dynamic router's function depends upon the  *
      * value held in field 'DYRFUNC' of the commarea passed to it by *
      * CICS (DFHAPRT or DFHEPC).                                     *
      * It may take 1 of 5 values:                                    *
      *                                                               *
      * DYRFUNC = '0' When the router is invoked initially            *
      *         = '1' If the router has been invoked due to a route   *
      *               selection error                                 *
      *         = '2' If the router has been invoked at routed        *
      *               transaction termination                         *
      *         = '3' If the router is being invoked to notify it     *
      *               that a transaction is being statically routed   *
      *         = '4' If the router is being invoked to notify it     *
      *               that the transaction abended                    *
      *                                                               *
      * This sample router accepts the default SYSID & remote TRANID  *
      * passed to it on initial invocation and sets the return code   *
      * to zero.                                                      *
      * It chooses not to be invoked when the transaction / DPL       *
      * request terminates.                                           *
      * If invoked due to a route selection error, the router cancels *
      * the transaction / DPL request and returns control to the      *
      * caller.                                                       *
      * For DPL requests DFHEPC ends the link with a PGMIDERR         *
      * condition and EIBRESP2 set to 27.                             *
      *                                                               *
      * ------------------------------------------------------------- *
      *                                                               *
      * Linkage = From DFHAPRT or DFHEPC via DFHPC TYPE=LINK_URM      *
      *           with Commarea                                       *
      *                                                               *
      * Input   = See COMMAREA structure in copybook DFHDYPDS C       *
      *                                                               *
      * ------------------------------------------------------------- *
      *                                                               *
      * CHANGE ACTIVITY:                                              *
      *                                                               *
      *    $MOD(DFHDYP),COMP(SAMPLES),PROD(CICS    ):                 *
      *                                                               *
      *  PN= REASON REL YYMMDD HDXIII : REMARKS                       *
      * $01= A81378 640 040212 HDBGNRB: Migrate PQ81378 from SPA R630 *
      * $L0= IR1    310 880727 HD3VAO : Initial Version               *
      * $L2= 642    410 930112 HD3YIJM : Adding new parameters        *
      * $L3= 707    530 971016 HDFVGMB : Include DPL requests         *
      * $P1= M83008 410 930628 HD3YIJM : Remove references to DFHCRP  *
      * $D1= I07303 630 030113 HDFVGMB: Implement new user exits      *
      * $D2  Reserved for DCR                                         *
      * $H1  Reserved for hardware support                            *
      * $H2  Reserved for hardware support                            *
      * $L1= 549    320 900116 HD5ZJD : DFHPC LINK_URM changes        *
      * $L2  Reserved for line item                                   *
      * $P1  Reserved for PTM                                         *
      * $P2  Reserved for PTM                                         *
      *                                                               *
      *****************************************************************

       ENVIRONMENT DIVISION.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

      *****************************************************************
      * DEFINE CONSTANTS                                              *
      *****************************************************************

        01  RETURN-CODE-CONSTANTS.
            02  RETCOD0 PIC S9(8) COMP VALUE 0.
            02  RETCOD8 PIC S9(8) COMP VALUE 8.

        01  WS-QUOTIENT PIC S9(07) COMP.
        01  WS-CRM-SELE PIC 9 VALUE 0.
            88  WS-ZERO VALUE 0.
            88  WS-ONE VALUE 1.
        01  CONN-ST PIC S9(08) COMP.
        01  RMT-SYS-1 PIC X(4) VALUE 'CR09'.
        01  RMT-SYS-2 PIC X(4) VALUE 'CR10'.

       LINKAGE SECTION.

      *****************************************************************
      * INCLUDE COMMAREA RECORD                                       *
      *****************************************************************

        COPY DFHDYPDS.

       PROCEDURE DIVISION.

      *****************************************************************
      * CHECK THAT THE COMMAREA HAS ACTUALLY BEEN PASSED              *
      *****************************************************************

      * Set return code anticipating bad commarea - will be set to
      * zero value later on everything ok
      *     DISPLAY '==DFHDYP beginning=='.
            MOVE RETCOD8 TO DYRRETC.

      * Is commarea correct length? .. No, leave router if not equal
            IF EIBCALEN NOT EQUAL LENGTH OF DFHDYPDS
                DISPLAY 'EIBCALEN(' EIBCALEN ') != DFHDYPDS('
                    LENGTH OF DFHDYPDS ')'
                GO TO FINISHED
            END-IF.
      *******************************************************     @01A*
      * SET UP ADDRESSABILITY TO USER AREA                        @01A*
      *******************************************************     @01A*
      *                                                           @01A
            SET ADDRESS OF DYRUAREA TO DYRUAPTR.
      *                                                           @01A
      *****************************************************************
      * MAIN BODY OF ROUTER                                           *
      *****************************************************************

      * Select which function is required of the router
      *     DISPLAY 'DYRFUNC(' DYRFUNC ')'.

      * Initial invocation of router? .. Perform the route selection
            IF DYRFUNC = '0' GO TO RTSELECT.

      * Invoked due to routing error? .. Handle this condition
            IF DYRFUNC = '1' GO TO RTERROR.

      * Invoked after transaction end? .. Perform any housekeeping
            IF DYRFUNC = '2' GO TO TRANTERM.

      * Invoked for static route? .. Perform any housekeeping
            IF DYRFUNC = '3' GO TO RTNOTIFY.

      * Invoked after transaction abend? .. Perform any housekeeping
            IF DYRFUNC = '4' GO TO RTABEND.

      * Invalid request. Should never get this far!
            MOVE RETCOD8 TO DYRRETC.
            GO TO FINISHED.

      *****************************************************************
      * PERFORM ANY ROUTING FUNCTION REQUIRED                         *
      *****************************************************************

      * No alterations made to commarea for SYSID & remote TRANID
      * Termination option & return code set as for default

        RTSELECT.
      * Set for no re-invocation
            MOVE 'N' TO DYROPTER.
            MOVE 'N' TO DYRDTRRJ.
      *     DISPLAY 'DYRLPROG:' DYRLPROG.
      *     DISPLAY 'EIBTASKN:' EIBTASKN.
            DIVIDE EIBTASKN BY 2 GIVING WS-QUOTIENT
                REMAINDER WS-CRM-SELE.
      *     DISPLAY  'WS-CRM-SELE:' WS-CRM-SELE.
            EVALUATE TRUE
                WHEN WS-ZERO
                    MOVE RMT-SYS-1 TO DYRSYSID
                    EXEC CICS INQUIRE CONNECTION(DYRSYSID)
                        CONNSTATUS(CONN-ST)
                    END-EXEC
                    IF CONN-ST NOT = DFHVALUE(ACQUIRED)
                        MOVE RMT-SYS-2 TO DYRSYSID
                    END-IF
                WHEN WS-ONE
                    MOVE RMT-SYS-2 TO DYRSYSID
                    EXEC CICS INQUIRE CONNECTION(DYRSYSID)
                        CONNSTATUS(CONN-ST)
                    END-EXEC
                    IF CONN-ST NOT = DFHVALUE(ACQUIRED)
                        MOVE RMT-SYS-1 TO DYRSYSID
                    END-IF
            END-EVALUATE.
      *     DISPLAY 'DYRSYSID:' DYRSYSID.
      *     DISPLAY '==DFHDYP ended=='
      * Set return code to zero, (ok)
            MOVE RETCOD0 TO DYRRETC.
            GO TO FINISHED.

      *****************************************************************
      * HANDLE ANY RE-ROUTING REQUIRED AFTER A SELECTION ERROR        *
      *****************************************************************

      * Cancel the transaction / DPL request (error message
      * will be issue).

       RTERROR.
      * Set the return code to eight
           MOVE RETCOD8 TO DYRRETC.
           GO TO FINISHED.

      *****************************************************************
      * PERFORM ANY POST TRANSACTION/DPL PROCESSING                   *
      *****************************************************************

      * Should not get here in sample

       TRANTERM.
           MOVE 'N' TO DYROPTER.
           MOVE RETCOD0 TO DYRRETC.
           GO TO FINISHED.

      *****************************************************************
      * PERFORM ANY STATIC ROUTE NOTIFICATION PROCESSING              *
      *****************************************************************

      * Should not get here in sample

       RTNOTIFY.
           MOVE 'N' TO DYROPTER.
           MOVE RETCOD0 TO DYRRETC.
           GO TO FINISHED.

      *****************************************************************
      * PERFORM ANY POST TRANSACTION PROCESSING                       *
      *****************************************************************

      * Should not get here in sample

       RTABEND.
           MOVE 'N' TO DYROPTER.
           MOVE RETCOD8 TO DYRRETC.
           GO TO FINISHED.

      *****************************************************************
      * RETURN CONTROL TO CALLER                                      *
      *****************************************************************

       FINISHED.
           EXEC CICS RETURN END-EXEC.

           GOBACK.
