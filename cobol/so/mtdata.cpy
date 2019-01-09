*     * GLOBAL Runtime Batch variables
*     *
*     * Environment DATA / KSH
*     *
       01 MT-ENV-DATA EXTERNAL.
           05 MT-ENV-DB-LOGIN             PIC X(60).
           05 MT-ENV-DB-USER              PIC X(30).
           05 MT-ENV-DB-PWD               PIC X(30).
           05 MT-ENV-DBACS-TRACE          PIC 9.
*     *
*     * DATA Context
*     *
       01 MT-CONTEXT  EXTERNAL.
           05 MT-CTX-DB-USE               PIC X.
           05 MT-CTX-RTEXIT-CALL          PIC X(5).
           05 MT-CTX-RTEXIT-NAME          PIC X(30).
*     * For Abend or not
       01 MT-STRING-STATUS                PIC X EXTERNAL.
*     *
*     * for program
*     *
       01 MT-CURRENT-PROGRAM              PIC X(12) EXTERNAL.
       01 MT-PROGRAM-PARAMETERS           PIC X(256) EXTERNAL.
*     *
*     * for message displaying
*     *
       01 MT-DISPLAY-LEVEL                PIC X EXTERNAL.

