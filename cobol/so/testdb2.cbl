      * ---------------------------------------------------
      *   Module Name: COBOLDB2.cbl
      *
      *   Description: Sample COBOL with DB2 program.
      *
      *   Purpose: Performs a Select on the employee table
      *   in the Sample database shipped with DB2.
      *
      *   COMPLILER OPTIONS (be sure to change the USERNAME and PASSWORD):
      *   DATA,EXIT(ADEXIT(FTTDBKW)),sql('database sample user USERNAME using PASSWORD')
      *
      *   SYSLIB:
      *   C:\Program Files\IBM\SQLLIB\INCLUDE\COBOL_A
      *
      *   ILINK OPTIONS:
      *   /de db2api.lib
      *
      * ---------------------------------------------------
       Identification Division.
       Program-ID.  COBOLDB2.

       Data Division.

      *Make sure you have SQLCA included in Working-Storage
       Working-Storage Section.

       01  SQLDA-ID pic 9(4) comp-5.
       01  SQLDSIZE pic 9(4) comp-5.
       01  SQL-STMT-ID pic 9(4) comp-5.
       01  SQLVAR-INDEX pic 9(4) comp-5.
       01  SQL-DATA-TYPE pic 9(4) comp-5.
       01  SQL-HOST-VAR-LENGTH pic 9(9) comp-5.
       01  SQL-S-HOST-VAR-LENGTH pic 9(9) comp-5.
       01  SQL-S-LITERAL pic X(258).
       01  SQL-LITERAL1 pic X(130).
       01  SQL-LITERAL2 pic X(130).
       01  SQL-LITERAL3 pic X(130).
       01  SQL-LITERAL4 pic X(130).
       01  SQL-LITERAL5 pic X(130).
       01  SQL-LITERAL6 pic X(130).
       01  SQL-LITERAL7 pic X(130).
       01  SQL-LITERAL8 pic X(130).
       01  SQL-LITERAL9 pic X(130).
       01  SQL-LITERAL10 pic X(130).
       01  SQL-IS-LITERAL pic 9(4) comp-5 value 1.
       01  SQL-IS-INPUT-HVAR pic 9(4) comp-5 value 2.
       01  SQL-CALL-TYPE pic 9(4) comp-5.
       01  SQL-SECTIONUMBER pic 9(4) comp-5.
       01  SQL-INPUT-SQLDA-ID pic 9(4) comp-5.
       01  SQL-OUTPUT-SQLDA-ID pic 9(4) comp-5.
       01  SQLA-PROGRAM-ID.
           05 SQL-PART1 pic 9(4) COMP-5 value 172.
           05 SQL-PART2 pic X(6) value "AEANAI".
           05 SQL-PART3 pic X(24) value "aBtIBEJe01111 2         ".
           05 SQL-PART4 pic 9(4) COMP-5 value 8.
           05 SQL-PART5 pic X(8) value "DB2INST2".
           05 SQL-PART6 pic X(120) value LOW-VALUES.
           05 SQL-PART7 pic 9(4) COMP-5 value 8.
           05 SQL-PART8 pic X(8) value "TESTDB2 ".
           05 SQL-PART9 pic X(120) value LOW-VALUES.
                               

       
      *EXEC SQL BEGIN DECLARE SECTION END-EXEC.
      *Data structure to store the Firstname of the employee
       01 Program-pass-fields.
          05 gdgbasename Pic x(30).
          05 gdgbasecount Pic x(4).
       
      *EXEC SQL END DECLARE SECTION END-EXEC
                                             

       
      *EXEC SQL INCLUDE SQLCA END-EXEC
      * SQL Communication Area - SQLCA
       COPY 'sqlca.cbl'.

                                       
      *EXEC SQL INCLUDE COURSERCD EXEC-EXEC.

       Procedure Division.
      *A Connection to the database must be made!
      *  EXEC SQL CONNECT TO db2linux user db2svr using db2svr END-EXEC.

      *Performs a SQL SELECT to get the firstname of the employee
      *with the employee number of 10.
      *    EXEC SQL SELECT TOP 1 GDG_BASE_NAME INTO :gdgbasename
           
      *EXEC SQL SELECT COUNT(GDG_BASE_NAME) INTO :gdgbasecount
      *     FROM gdg_define 
      *     END-EXEC
           CALL "sqlgstrt" USING
              BY CONTENT SQLA-PROGRAM-ID
              BY VALUE 0
              BY REFERENCE SQLCA
           CALL "sqlgmf" USING
              BY VALUE 0

           MOVE 1 TO SQL-STMT-ID 
           MOVE 1 TO SQLDSIZE 
           MOVE 3 TO SQLDA-ID 

           CALL "sqlgaloc" USING
               BY VALUE SQLDA-ID 
                        SQLDSIZE
                        SQL-STMT-ID
                        0

           MOVE 4 TO SQL-HOST-VAR-LENGTH
           MOVE 452 TO SQL-DATA-TYPE
           MOVE 0 TO SQLVAR-INDEX
           MOVE 3 TO SQLDA-ID

           CALL "sqlgstlv" USING 
            BY VALUE SQLDA-ID
                     SQLVAR-INDEX
                     SQL-DATA-TYPE
                     SQL-HOST-VAR-LENGTH
            BY REFERENCE GDGBASECOUNT
            OF
            PROGRAM-PASS-FIELDS
            BY VALUE 0
                     0

           MOVE 3 TO SQL-OUTPUT-SQLDA-ID 
           MOVE 0 TO SQL-INPUT-SQLDA-ID 
           MOVE 1 TO SQL-SECTIONUMBER 
           MOVE 24 TO SQL-CALL-TYPE 

           CALL "sqlgcall" USING
            BY VALUE SQL-CALL-TYPE 
                     SQL-SECTIONUMBER
                     SQL-INPUT-SQLDA-ID
                     SQL-OUTPUT-SQLDA-ID
                     0

           CALL "sqlgstop" USING
            BY VALUE 0
                   .

      *Displays the firstname we pulled from the Sample database.
           Display "Firstname"
           Display "========="
           Display gdgbasename
           Display gdgbasecount
           Display "========="
           Display " "
      *Displays the status of the SQL statements
           Display SQLCA
           Display "========="
           Display SQLCODE of SQLCA
           Display SQLERRMC of SQLCA
           Display SQLSTATE of SQLCA
           Display SQLERRMC of SQLCA

           Goback.
