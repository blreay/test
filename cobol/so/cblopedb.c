static char sqla_program_id[292] = 
{
 172,0,65,69,65,78,65,73,89,66,119,70,84,75,77,100,48,49,49,49,
 49,32,50,32,32,32,32,32,32,32,32,32,8,0,68,66,50,83,86,82,
 32,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,8,0,67,66,76,79,80,69,68,66,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,0
};

#include "sqladef.h"

static struct sqla_runtime_info sqla_rtinfo = 
{{'S','Q','L','A','R','T','I','N'}, sizeof(wchar_t), 0, {' ',' ',' ',' '}};


static const short sqlIsLiteral   = SQL_IS_LITERAL;
static const short sqlIsInputHvar = SQL_IS_INPUT_HVAR;


#line 1 "cblopedb.pco"
       IDENTIFICATION DIVISION.
       PROGRAM-ID. cblopedb.
*     * ========================================================
*     * entry points:
*     *  main entry    connection to database
*     *  do_connect    connect to database
*     *  do_disconnect disconnect from database
*     *  do_rollback   rollbacks database
*     *  do_commit     commits database 
*     *  dbm_init:     init uwa and currencies
*     *  dbm_clean:    close cursors and clean cursor info
*     * ========================================================
       DATA DIVISION.
*     *
*     * ========================================================
*     *
       WORKING-STORAGE SECTION.
       77  VERS-NB PIC X(80) value
          "@(#) VERSION: 1.1 Mar 25 2010: DB Access functions\".
*     *
		01 DISPLAY-VARIABLES.
		05 D-CUSTCD PIC X(099).
		05 D-CUSTNM PIC X(035).
		01 D-USERNAME PIC X(010).
		01 D-PASSWD PIC X(010).
		01 D-DB-STRING PIC X(020).
		01 D-TOTAL-QUERIED PIC 9(4) VALUE ZERO.

       01 wcc-prog          pic x(80).
       01 prog-ret-code     pic s9(4) comp-5 value zero.
       01 mwlogin.
          02 mwlogin-len pic S9(4) comp-5.
          02 mwlogin-arr pic x(127).
*     *
*     * bug oracle if ORACLELOGIN > 127 alors @ORACLESID obligatoire
*     * dans la chaine de login
           EXEC SQL BEGIN DECLARE SECTION END-EXEC.
             01 H-SQL             PIC X(128).
             01 ORACLELOGIN       PIC X(127).
				01 USERNAME PIC X(010).
				01 PASSWD PIC X(010).
				01 DB-STRING PIC X(020).
				01 CUSTCD PIC X(099).
				01 CUSTNM PIC X(099).
           EXEC SQL END DECLARE SECTION END-EXEC.
      
           EXEC SQL INCLUDE SQLCA END-EXEC.
      
       PROCEDURE DIVISION.
       MAIN-ENTRY section.
       DEBUT.
           display "
/*
SQL0010N  The string constant beginning with "@(#) VERSION: 
1.1 Mar 25 2010: DB Access functions\"." does not have an 
ending string delimiter.

*/

#line 19 "cblopedb.pco"
