/****************************************************************************
** (c) Copyright IBM Corp. 2009 All rights reserved.
**
** The following sample of source code ("Sample") is owned by International
** Business Machines Corporation or one of its subsidiaries ("IBM") and is
** copyrighted and licensed, not sold. You may use, copy, modify, and
** distribute the Sample in any form without payment to IBM, for the purpose of
** assisting you in the development of your applications.
**
** The Sample code is provided to you on an "AS IS" basis, without warranty of
** any kind. IBM HEREBY EXPRESSLY DISCLAIMS ALL WARRANTIES, EITHER EXPRESS OR
** IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
** MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. Some jurisdictions do
** not allow for the exclusion or limitation of implied warranties, so the above
** limitations or exclusions may not apply to you. IBM shall not be liable for
** any damages you suffer as a result of using, copying, modifying or
** distributing the Sample, even if IBM has been advised of the possibility of
** such damages.
*****************************************************************************
**
** SOURCE FILE NAME: tbread.c
**
** SAMPLE: How to read data from tables
**
** DB2CI FUNCTIONS USED:
**         OCIHandleAlloc -- Allocate Handle
**         OCIDefineByPos -- Bind a Column to an Application Variable or
**                       LOB locator
**         OCIBindByPos -- Bind a Parameter Marker to a Buffer or
**                             LOB locator
**         OCIAttrGet -- Return a Column Attribute
**         OCIStmtPrepare -- Prepare a statement
**         OCIStmtExecure -- Execute a Statement
**         OCIStmtFetch -- Fetch Next Row.
**         OCIStmtFetch2 - Fetch next rowset.
**         OCIHandleFree -- Free Handle Resources
**
** OUTPUT FILE: tbread.out (available in the online documentation)
*****************************************************************************
**
** For more information on the sample programs, see the README file.
**
** For information on using SQL statements, see the SQL Reference.
**
** For the latest information on programming, building, and running DB2
** applications, visit the DB2 application development website:
**     http://www.software.ibm.com/data/db2/udb/ad
****************************************************************************/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <db2ci.h>
#include "utilci.h" /* Header file for DB2CI sample code */
#include "jesdb.h"

#define ROWSET_SIZE 5
#define _db_selectRowFree //sss
#define JES_DUMP printf

int TbBasicSelectUsingFetch( OCIEnv * envhp, OCISvcCtx * svchp, OCIError * errhp );
int TbSelectWithParam( OCIEnv * envhp, OCISvcCtx * svchp, OCIError * errhp );
int TbSelectWithUnknownOutCols( OCIEnv * envhp, OCISvcCtx * svchp, OCIError * errhp );

int main(int argc, char *argv[])
{
  sb4 ciRC = OCI_SUCCESS;
  int rc = 0;
  OCIEnv * envhp; /* environment handle */
  OCISvcCtx * svchp; /* connection handle */
  OCIError * errhp; /* error handle */

  char dbAlias[SQL_MAX_DSN_LENGTH + 1];
  char user[MAX_UID_LENGTH + 1];
  char pswd[MAX_PWD_LENGTH + 1];

  /* check the command line arguments */
  rc = CmdLineArgsCheck1(argc, argv, dbAlias, user, pswd);
  if (rc != 0)
  {
    return rc;
  }

  printf("\nTHIS SAMPLE SHOWS HOW TO READ TABLES.\n");

  /* initialize the DB2CI application by calling a helper
     utility function defined in utilci.c */
  rc = CIAppInit(dbAlias,
                  user,
                  pswd,
                  &envhp,
                  &svchp,
                  &errhp );
  if (rc != 0)
  {
    return rc;
  }

	int i=0;
	int maxcount = 1000000;
	//int maxcount = 1;
	for (i=0; i<maxcount; i++) {
  printf("\nzzy: i=%d\n", i);
  /* basic SELECT */
  rc = TbBasicSelectUsingFetch( envhp, svchp, errhp );
	if (rc != 0) {
		printf("error occured!\n");
		break;
	} 

  /* SELECT with parameter markers */
  //rc = TbSelectWithParam( envhp, svchp, errhp );

  /* SELECT with unknown output columns */
  //rc = TbSelectWithUnknownOutCols(envhp, svchp, errhp );
	}

  /* terminate the DB2CI application by calling a helper
     utility function defined in utilci.c */
  rc = CIAppTerm(&envhp, &svchp, errhp, dbAlias);

  return rc;
} /* main */

/* perform a basic SELECT operation using OCIDefineByPos */
int TbBasicSelectUsingFetch( OCIEnv * envhp, OCISvcCtx * svchp, OCIError * errhp )
{
  sb4 ciRC = OCI_SUCCESS;
  int rc = 0;
  OCIStmt * hstmt; /* statement handle */
  OCIDefine * defnhp1 = NULL; /* define handle */
  OCIDefine * defnhp2 = NULL; /* define handle */
  /* SQL SELECT statement to be executed */
  //char *stmt = (char *)"SELECT deptnumb, location FROM org";
  //char *stmt = (char *)"select CLASS,  JOBNAME from JES2_JOB_PARAM where JOBID = 00108170";
  char *stmt = (char *)"select JOBID,  JOBNAME,    CLASS,  PRTY,   STATUS from JES2_JOB_PARAM where JOBID = 00108170";

  struct
  {
    sb2 ind;
    sb2 val;
    ub2 length;
    ub2 rcode;
    char val1[15];
  }
  deptnumb; /* variable to be bound to the DEPTNUMB column */

  struct
  {
    sb2 ind;
    char val[15];
    ub2 length;
    ub2 rcode;
  }
  location; /* variable to be bound to the LOCATION column */

  printf("\n-----------------------------------------------------------");
  printf("\nUSE THE DB2CI FUNCTIONS\n");
  printf("  OCIHandleAlloc\n");
  printf("  OCIStmtPrepare\n");
  printf("  OCIStmtExecute\n");
  printf("  OCIDefineByPos\n");
  printf("  OCIStmtFetch\n");
  printf("  OCIHandleFree\n");
  printf("TO PERFORM A BASIC SELECT USING OCIDefineByPos:\n");

  /* allocate a statement handle */
  ciRC = OCIHandleAlloc( (dvoid *)envhp, (dvoid **)&hstmt, OCI_HTYPE_STMT, 0, NULL );
  ERR_HANDLE_CHECK(errhp, ciRC);

  printf("\n  Directly execute the statement\n");
  printf("    %s\n", stmt);

  /* directly execute the statement */
  ciRC = OCIStmtPrepare(
      hstmt,
      errhp,
      (OraText *)stmt,
      strlen( stmt ),
      OCI_NTV_SYNTAX,
      OCI_DEFAULT );
  ERR_HANDLE_CHECK(errhp, ciRC);

#ifdef SAMPLE
  ciRC = OCIStmtExecute(
      svchp,
      hstmt,
      errhp,
      0,
      0,
      NULL,
      NULL,
      OCI_DEFAULT );
#else
  printf("\n  Directly execute the statement with OCI_STMT_SCROLLABLE_READONLY\n");
 ciRC = OCIStmtExecute(
	svchp,
	hstmt,
	errhp,
	(ub4) 0, 
	(ub4) 0,  
    (CONST OCISnapshot *) NULL, 
	(OCISnapshot *) NULL, 
	OCI_STMT_SCROLLABLE_READONLY);             
#endif

  ERR_HANDLE_CHECK(errhp, ciRC);

#ifdef SAMPLE

  /* define column 1 to variable */
  ciRC = OCIDefineByPos(
      hstmt,
      &defnhp1,
      errhp,
      1,
      deptnumb.val1,
      sizeof( sb2 ),
      SQLT_STR,
      &deptnumb.ind,
      &deptnumb.length,
      &deptnumb.rcode,
      OCI_DEFAULT );
  ERR_HANDLE_CHECK(errhp, ciRC);

  /* define column 2 to variable */
  ciRC = OCIDefineByPos(
      hstmt,
      &defnhp2,
      errhp,
      2,
      location.val,
      sizeof( location.val ),
      SQLT_STR,
      &location.ind,
      &location.length,
      &location.rcode,
      OCI_DEFAULT );
  ERR_HANDLE_CHECK(errhp, ciRC);

  printf("\n  Fetch each row and display.\n");
  printf("    DEPTNUMB LOCATION     \n");
  printf("    -------- -------------\n");


//zzy begin

//zzy ben
  /* fetch each row and display */
  ciRC = OCIStmtFetch(
      hstmt,
      errhp,
      1,
      OCI_FETCH_NEXT,
      OCI_DEFAULT );
  ERR_HANDLE_CHECK(errhp, ciRC);

  if (ciRC == OCI_NO_DATA )
  {
    printf("\n  Data not found.\n");
  }
  while (ciRC != OCI_NO_DATA )
  {
    printf("    %-8d %-14.14s \n", deptnumb.val, location.val);

    /* fetch next row */
    ciRC = OCIStmtFetch(
        hstmt,
        errhp,
        1,
        OCI_FETCH_NEXT,
        OCI_DEFAULT );
    ERR_HANDLE_CHECK(errhp, ciRC);
  }
#else
            /* for DB2, fetch all the rows to local memory */
        OCIDefine *p_dfn = (OCIDefine *) 0;
        OCIBind *p_bnd = (OCIBind *) 0;
        OCIParam *p_param = (OCIParam *) 0;
        OCIStmt *p_sql = (OCIStmt *) 0;
        ub2 collen[MAX_SEL_COLUMNS];
        ub4 col_num = 2;
        ub4 row_num = 0;
        char *namep = NULL;
        ub4 sizep = 0;
		JES_SEL_ROWBUF rowbufobj;
        JES_SEL_ROWBUF *rowbuf = &rowbufobj;
        JES_DB_SEL_BUF *out = NULL;
        int j = 0;
        char *result = NULL;
        char **table = NULL;
        //char **p = NULL;
		int ret = 0;
		JES_ERR_MSG errobj;
		JES_ERR_MSG * err=&errobj;
		JES_OCI_Handle ociobj;
		JES_OCI_Handle *p_oci= &ociobj;
		int idxobj = 1;
		int* idx=&idxobj;
		int i=0;
			

			p_sql = hstmt;
			p_oci->p_err = errhp;
			//////////////////////////

            JES_DUMP("Get the number of columns in the select list");
            ret = OCIAttrGet((OCIStmt *) p_sql, OCI_HTYPE_STMT, &col_num, 0, OCI_ATTR_PARAM_COUNT, (OCIError *) p_oci->p_err);
            if (ret != OCI_SUCCESS) {
                check_db_err((OCIError *) p_oci->p_err, ret, err);
                return -1;
            }

            JES_DUMP("Get describe information for each column. col_num=%d", col_num);
            p_oci->rowbuf[*idx] = (JES_SEL_ROWBUF *) calloc(1, sizeof(JES_SEL_ROWBUF));
            rowbuf = p_oci->rowbuf[*idx];
            rowbuf->colnum = col_num;
            for (i = 0; i < (int)col_num; i++) {
                ret = OCIParamGet((OCIStmt *) p_sql, OCI_HTYPE_STMT, (OCIError *) p_oci->p_err, (void **)&p_param, (ub4) i + 1);
                if (ret != OCI_SUCCESS) {
                    check_db_err((OCIError *) p_oci->p_err, ret, err);
                    _db_selectRowFree(p_oci, *idx, err);
                    return -1;
                }
                JES_DUMP("Get the attributes for each column");
                ret = OCIAttrGet((dvoid *) p_param, (ub4) OCI_DTYPE_PARAM, (dvoid *) & collen[i], (ub4 *) 0, OCI_ATTR_DATA_SIZE, (OCIError *) p_oci->p_err);
                if (ret != OCI_SUCCESS) {
                    check_db_err((OCIError *) p_oci->p_err, ret, err);
                    _db_selectRowFree(p_oci, *idx, err);
                    return -1;
                }
                ret = OCIAttrGet((dvoid *) p_param, OCI_DTYPE_PARAM, (dvoid *) & namep, (ub4 *) & sizep, OCI_ATTR_NAME, (OCIError *) p_oci->p_err);
                if (ret != OCI_SUCCESS) {
                    check_db_err((OCIError *) p_oci->p_err, ret, err);
                    _db_selectRowFree(p_oci, *idx, err);
                    return -1;
                }

                JES_DUMP("The maximum size(bytes) of the column(%d) is %d", i + 1, collen[i]);
                rowbuf->colbuf[i] = (char *)malloc((int)collen[i] + 1);
                memset(rowbuf->colbuf[i], 0, (int)collen[i] + 1);

                rowbuf->colname[i] = (char *)malloc((int)sizep + 1);
                memset(rowbuf->colname[i], 0, (int)sizep + 1);
                strncpy((char *)rowbuf->colname[i], (char *)namep, (size_t) sizep);
                rowbuf->colname[i][sizep] = '\0';
                JES_DUMP("The colum name is (%s), length is %d", rowbuf->colname[i], sizep);
            }

            JES_DUMP("Associates all items in a select-list with the type and output data buffer. colnum=%d", col_num);
            for (i = 0; i < (int)col_num; i++) {
                JES_DUMP("Associates one item(%d/%d)", i + 1, col_num);
                ret = OCIDefineByPos((OCIStmt *) p_sql, &p_dfn, (OCIError *) p_oci->p_err, i + 1, (dvoid *) rowbuf->colbuf[i], (sword) collen[i] + 1,
                                     SQLT_STR, (dvoid *) & (rowbuf->indicator[i]), (ub2 *) 0, (ub2 *) 0, OCI_DEFAULT);
                if (ret != OCI_SUCCESS) {
                    check_db_err((OCIError *) p_oci->p_err, ret, err);
                    _db_selectRowFree(p_oci, *idx, err);
                    return -1;
                }
            }

            printf("Get the row number returned by select: do fetch2 first\n");
            ret = OCIStmtFetch2((OCIStmt *) p_sql, (OCIError *) errhp, 1, OCI_FETCH_LAST, 0, OCI_DEFAULT);
            if (ret != OCI_SUCCESS && ret != OCI_NO_DATA) {
                check_db_err((OCIError *) errhp, ret, err);
                //_db_selectRowFree(p_oci, *idx, err);
                return -1;
            }
            printf("read row number\n");
            ret = OCIAttrGet((OCIStmt *) p_sql, OCI_HTYPE_STMT, &row_num, 0, OCI_ATTR_ROW_COUNT, (OCIError *) errhp);
            if (ret != OCI_SUCCESS) {
                check_db_err((OCIError *) errhp, ret, err);
                //_db_selectRowFree(p_oci, *idx, err);
                return -1;
            }

#if 0
            (p_oci->p_sel_buf)[*idx] = calloc(1, sizeof(JES_DB_SEL_BUF));
            if ((p_oci->p_sel_buf)[*idx] == NULL) {
                printf("no enougth memory to allocate (%d) bytes for p_sel_buf", sizeof(JES_DB_SEL_BUF));
                //_db_selectRowFree(p_oci, *idx, err);
                return -1;
            }
            out = (JES_DB_SEL_BUF *) (p_oci->p_sel_buf)[*idx];

            printf("row number is %d\n", row_num);
            table = (char **)calloc(1, sizeof(void *) * col_num * (row_num + 1));
            out->table = table;
            out->currow = 0;
            out->rownum = row_num;
            out->colnum = col_num;
            out->rowbuf = (JES_SEL_ROWBUF *) calloc(1, sizeof(JES_SEL_ROWBUF) * (row_num + 1));
            if (out->rowbuf == NULL) {
                sprintf(err->errmsg, "no enougth memory to allocate (%d) bytes for out->rowbuf", sizeof(JES_SEL_ROWBUF) * (row_num + 1));
                printf(err->errmsg);
                //_db_selectRowFree(p_oci, *idx, err);
                return -1;
            }
            /* fill table header */
			rowbuf->colname[0] = "aa";
			rowbuf->colname[1] = "bb";
            for (i = 0; i < (int)col_num; i++) {
                printf("The colum name is (%s)\n", rowbuf->colname[i]);
                table[i] = strdup(rowbuf->colname[i]);
            }
            for (j = 1; j <= (int)row_num; j++) {
                printf("Begin. Fetch a row from a query. *idx = %d\n", *idx);
                //p_sql = (OCIStmt *) p_oci->p_sel_sql[*idx];
                ret = OCIStmtFetch2((OCIStmt *) p_sql, (OCIError *) errhp, 1, OCI_FETCH_ABSOLUTE, j, OCI_DEFAULT);
                if (ret != OCI_SUCCESS && ret != OCI_NO_DATA) {
                    check_db_err((OCIError *) errhp, ret, err);
                    //_db_selectRowFree(p_oci, *idx, err);
                    return -1;
                }
				rowbuf->colbuf[0]=deptnumb.val1;
				rowbuf->colbuf[1]=location.val;
                for (i = 0; i < (int)col_num; i++) {
                    table[j * col_num + i] = strdup(rowbuf->colbuf[i]);
                    //printf("j=%d i=%d get one column: %s tp=%p bp=%p\n", j, i, table[j * col_num + i], rowbuf->colbuf[i], table[j * col_num + i]);
                    printf("j=%d i=%d get one column %s\n", j, i, rowbuf->colbuf[i]);
                }
                printf("End. Fetch a row");
            }

            printf("cancel the cursor\n");
            ret = OCIStmtFetch2((OCIStmt *) p_sql, (OCIError *) errhp, 0, OCI_DEFAULT, 0, OCI_DEFAULT);
            if (ret != OCI_SUCCESS && ret != OCI_NO_DATA) {
                check_db_err((OCIError *) errhp, ret, err);
                //_db_selectRowFree(p_oci, *idx, err);
                return -1;
            }
            for (i = 0; i < (row_num + 1) * (col_num); i++) {
				if (NULL != table[i]) {
                	free(table[i]);
				}
            }
			JES_DB_SEL_BUF *p = (JES_DB_SEL_BUF *) (p_oci->p_sel_buf[*idx]);
			free(table);
            free(p->rowbuf);
        	free((p_oci->p_sel_buf)[*idx]);
#endif

#if 1
            /* DB2: fetch all the rows and store it to local memory */
            (p_oci->p_sel_buf)[*idx] = calloc(1, sizeof(JES_DB_SEL_BUF));
            if ((p_oci->p_sel_buf)[*idx] == NULL) {
                printf("no enougth memory to allocate (%d) bytes for p_sel_buf", sizeof(JES_DB_SEL_BUF));
                //_db_selectRowFree(p_oci, *idx, err);
                return -1;
            }
            out = (JES_DB_SEL_BUF *) (p_oci->p_sel_buf)[*idx];

            j = 0;
            printf("begin to fetch all the rows to local memory col_num=%d row_num=%d\n", col_num, row_num);
            result = (char **)calloc(1, sizeof(void *) * col_num * (row_num + 1));
            if (NULL == result) {
                sprintf(err->errmsg, "no enougth memory to allocate (%d) bytes for result", sizeof(void *) * col_num * (row_num + 1));
                printf(err->errmsg);
                //_db_selectRowFree(p_oci, *idx, err);
                return -1;
            }
            out->table = result;
            out->currow = 0;
            out->rownum = row_num;
            out->colnum = col_num;
            out->rowbuf = (JES_SEL_ROWBUF *) calloc(1, sizeof(JES_SEL_ROWBUF) * (row_num + 1));
            if (out->rowbuf == NULL) {
                sprintf(err->errmsg, "no enougth memory to allocate (%d) bytes for out->rowbuf", sizeof(JES_SEL_ROWBUF) * (row_num + 1));
                printf(err->errmsg);
                //_db_selectRowFree(p_oci, *idx, err);
                return -1;
            }
            table = out->table;

            /* fill table header */
			//rowbuf->colname[0] = "aa";
			//rowbuf->colname[1] = "bb";
            for (i = 0; i < (int)col_num; i++) {
                printf("The colum name is (%s)\n", rowbuf->colname[i]);
                table[i] = strdup(rowbuf->colname[i]);
            }
            /* fill rows */
            for (j = 1; j <= (int)row_num; j++) {
                printf("Begin. Fetch a row from a query. *idx = %d\n", *idx);
                //p_sql = (OCIStmt *) p_oci->p_sel_sql[*idx];
                ret = OCIStmtFetch2((OCIStmt *) p_sql, (OCIError *) errhp, 1, OCI_FETCH_ABSOLUTE, j, OCI_DEFAULT);
                if (ret != OCI_SUCCESS && ret != OCI_NO_DATA) {
                    check_db_err((OCIError *) errhp, ret, err);
                    //_db_selectRowFree(p_oci, *idx, err);
                    return -1;
                }
				//rowbuf->colbuf[0]=deptnumb.val1;
				//rowbuf->colbuf[1]=location.val;
                for (i = 0; i < (int)col_num; i++) {
                    table[j * col_num + i] = strdup(rowbuf->colbuf[i]);
                    //printf("j=%d i=%d get one column: %s tp=%p bp=%p\n", j, i, table[j * col_num + i], rowbuf->colbuf[i], table[j * col_num + i]);
                    printf("j=%d i=%d get one column: %s\n", j, i, table[j * col_num + i]);
                }
                printf("End. Fetch a row");
            }
            /* dump table in debug mode */
            printf("\n========== DUMP TABLE BEGIN ================\n");
            for (j = 0; j <= (int)row_num; j++) {
            	for (i = 0; i < (int)col_num; i++) {
                	printf("%s\t", table[j*col_num+i]);
				}
				printf("\n");
            }
            printf("\n========== DUMP TABLE END ================\n");

            /* release the cursor: this is mandatory, otherwise, lock deadlock may occur */
            printf("cancel the cursor\n");
            //p_sql = (OCIStmt *) p_oci->p_sel_sql[*idx];
            ret = OCIStmtFetch2((OCIStmt *) p_sql, (OCIError *) errhp, 0, OCI_DEFAULT, 0, OCI_DEFAULT);
            if (ret != OCI_SUCCESS && ret != OCI_NO_DATA) {
                check_db_err((OCIError *) errhp, ret, err);
                //_db_selectRowFree(p_oci, *idx, err);
                return -1;
            }
            /* release the temp memory */
        JES_DB_SEL_BUF *p = (JES_DB_SEL_BUF *) (p_oci->p_sel_buf[*idx]);
        if (NULL == p) {
            printf("do nothing to free\n");
            return -1;
        }
        printf("p_oci->p_sel_buf[%d]=%p ->table=%p ->rowbuf=%p\n", *idx, p, p->table, p->rowbuf);
        if (NULL != p->table) {
            printf("free table: %p\n", p->table);
            int i = 0;
            for (i = 0; i < (p->rownum + 1) * (p->colnum); i++) {
                free(p->table[i]);
            }
            free(p->table);
            p->table = NULL;
        }
        if (NULL != p->rowbuf) {
            printf("free rowbuf: %p\n", p->rowbuf);
            free(p->rowbuf);
            p->rowbuf = NULL;
        }
        printf("free p_sel_buf: %p\n", (p_oci->p_sel_buf)[*idx]);
        free((p_oci->p_sel_buf)[*idx]);
        (p_oci->p_sel_buf)[*idx] = NULL;

        printf("free p_oci->rowbuf[%d]=%p\n", *idx, p_oci->rowbuf[*idx]);
        if (p_oci->rowbuf[*idx]) {
            for (i = 0; i < (int)col_num; i++) {
        		printf("free p_oci->rowbuf[%d]->colname[%d]=%p\n", *idx, i, p_oci->rowbuf[*idx]->colname[i]);
				free(p_oci->rowbuf[*idx]->colname[i]);
        		printf("free p_oci->rowbuf[%d]->colbuf[%d]=%p\n", *idx, i, p_oci->rowbuf[*idx]->colbuf[i]);
				free(p_oci->rowbuf[*idx]->colbuf[i]);
			}
			free(p_oci->rowbuf[*idx]);
            p_oci->rowbuf[*idx] = NULL;
        }
            //printf("release temp memory. idx = %d, colnum=%d, rowbuf=%p", *idx, rowbuf->colnum, rowbuf);
			/*
            for (i = 0; i < (int)rowbuf->colnum; i++) {
                if (rowbuf->colbuf[i]) {
                    free(rowbuf->colbuf[i]);
                    rowbuf->colbuf[i] = NULL;
                }
                if (rowbuf->colname[i]) {
                    free(rowbuf->colname[i]);
                    rowbuf->colname[i] = NULL;
                }
            }
            printf("for free p_oci->rowbuf[%d]=%p", *idx, p_oci->rowbuf[*idx]);
            if (p_oci->rowbuf[*idx]) {
                free(p_oci->rowbuf[*idx]);
            }
			*/
#ifndef DEBUG
#endif /* End of DEBUG branch */
#endif
#endif

  /* free the statement handle */
  ciRC = OCIHandleFree( hstmt, OCI_HTYPE_STMT );
  ERR_HANDLE_CHECK(errhp, ciRC);

  return rc;
} /* TbBasicSelectUsingFetch */

/* perform a SELECT that contains parameter markers */
int TbSelectWithParam( OCIEnv * envhp, OCISvcCtx * svchp, OCIError * errhp )
{
  sb4 ciRC = OCI_SUCCESS;
  int rc = 0;
  OCIStmt * hstmt; /* statement handle */
  OCIDefine * defnhp1 = NULL; /* define handle */
  OCIDefine * defnhp2 = NULL; /* define handle */
  OCIBind * hBind = NULL; /* bind handle */

  //char *stmt = (char *) "SELECT deptnumb, location FROM org WHERE division = :1";
	//zzy
  char *stmt = (char *)"select JOBID,  JOBNAME from JES2_JOB_PARAM where JOBID = :1";

  char divisionParam[15];

  struct
  {
    sb2 ind;
    sb2 val;
    ub2 length;
    ub2 rcode;
  }
  deptnumb; /* variable to be bound to the DEPTNUMB column */

  struct
  {
    sb2 ind;
    char val[15];
    ub2 length;
    ub2 rcode;
  }
  location; /* variable to be bound to the LOCATION column */

  printf("\n-----------------------------------------------------------");
  printf("\nUSE THE DB2CI FUNCTIONS\n");
  printf("  OCIHandleAlloc\n");
  printf("  OCIStmtPrepare\n");
  printf("  OCIStmtExecute\n");
  printf("  OCIBindByPos\n");
  printf("  OCIDefineByPos\n");
  printf("  OCIStmtFetch\n");
  printf("  OCIHandleFree\n");
  printf("TO PERFORM A SELECT WITH PARAMETERS:\n");

  /* allocate a statement handle */
  ciRC = OCIHandleAlloc( (dvoid *)envhp, (dvoid **)&hstmt, OCI_HTYPE_STMT, 0, NULL );
  ERR_HANDLE_CHECK(errhp, ciRC);

  printf("\n  Prepare the statement\n");
  printf("    %s\n", stmt);

  /* prepare the statement */
  ciRC = OCIStmtPrepare(
      hstmt,
      errhp,
      (OraText *)stmt,
      strlen( stmt ),
      OCI_NTV_SYNTAX,
      OCI_DEFAULT );
  ERR_HANDLE_CHECK(errhp, ciRC);

  printf("\n  Bind divisionParam to the statement\n");
  printf("    %s\n", stmt);

  /* bind divisionParam to the statement */
  ciRC = OCIBindByPos(
      hstmt,
      &hBind,
      errhp,
      1,
      divisionParam,
      sizeof( divisionParam ),
      SQLT_STR,
      NULL,
      NULL,
      NULL,
      0,
      NULL,
      OCI_DEFAULT );
  ERR_HANDLE_CHECK(errhp, ciRC);

  /* execute the statement for divisionParam = Eastern */
  printf("\n  Execute the prepared statement for\n");
  printf("    divisionParam = 'Eastern'\n");
  strcpy(divisionParam, "Eastern");

  /* execute the statement */
  ciRC = OCIStmtExecute(
      svchp,
      hstmt,
      errhp,
      0,
      0,
      NULL,
      NULL,
      OCI_DEFAULT );
  ERR_HANDLE_CHECK(errhp, ciRC);

  /* bind column 1 to variable */
  ciRC = OCIDefineByPos(
      hstmt,
      &defnhp1,
      errhp,
      1,
      &deptnumb.val,
      sizeof( sb2 ),
      SQLT_INT,
      &deptnumb.ind,
      &deptnumb.length,
      &deptnumb.rcode,
      OCI_DEFAULT );
  ERR_HANDLE_CHECK(errhp, ciRC);

  /* bind column 2 to variable */
  ciRC = OCIDefineByPos(
      hstmt,
      &defnhp2,
      errhp,
      2,
      location.val,
      sizeof( location.val ),
      SQLT_STR,
      &location.ind,
      &location.length,
      &location.rcode,
      OCI_DEFAULT );
  ERR_HANDLE_CHECK(errhp, ciRC);

  printf("\n  Fetch each row and display.\n");
  printf("    DEPTNUMB LOCATION     \n");
  printf("    -------- -------------\n");

  /* fetch each row and display */
  ciRC = OCIStmtFetch(
      hstmt,
      errhp,
      1,
      OCI_FETCH_NEXT,
      OCI_DEFAULT );
  ERR_HANDLE_CHECK(errhp, ciRC);

  if (ciRC == OCI_NO_DATA )
  {
    printf("\n  Data not found.\n");
  }
  while (ciRC != OCI_NO_DATA )
  {
    printf("    %-8d %-14.14s \n", deptnumb.val, location.val);

    /* fetch next row */
    ciRC = OCIStmtFetch(
        hstmt,
        errhp,
        1,
        OCI_FETCH_NEXT,
        OCI_DEFAULT );
    ERR_HANDLE_CHECK(errhp, ciRC);
  }

  /* free the statement handle */
  ciRC = OCIHandleFree( hstmt, OCI_HTYPE_STMT );
  ERR_HANDLE_CHECK(errhp, ciRC);

  return rc;
} /* TbSelectWithParam */

/* perform a SELECT where the number of columns in the
   result set is not known */
int TbSelectWithUnknownOutCols( OCIEnv * envhp, OCISvcCtx * svchp, OCIError * errhp )
{
  sb4 ciRC = OCI_SUCCESS;
  int rc = 0;
  OCIStmt * hstmt; /* statement handle */
  /* SQL SELECT statement to be executed */
  //char *stmt = (char *)"SELECT * FROM org";
	//zzy
  char *stmt = (char *)"select JOBID,  JOBNAME from JES2_JOB_PARAM where JOBID = 00108170";

  ub4 i, j; /* indices */
  ub4 nResultCols;
  void * hCol;
  char * colName;
  ub4 colNameLen;
  ub2 colSize;
  ub2 colDisplaySize[MAX_COLUMNS];

  struct
  {
    OCIDefine * defnhp;
    char *buff;
    sb2 ind;
    ub2 length;
    ub2 rcode;
  }
  outData[MAX_COLUMNS]; /* variable to read the results */

  memset( outData, 0, sizeof( outData ));

  printf("\n-----------------------------------------------------------");
  printf("\nUSE THE DB2CI FUNCTIONS\n");
  printf("  OCIHandleAlloc\n");
  printf("  OCIStmtPrepare\n");
  printf("  OCIStmtExecute\n");
  printf("  OCIAttrGet\n");
  printf("  OCIParamGet\n");
  printf("  OCIDefineByPos\n");
  printf("  OCIStmtFetch\n");
  printf("  OCIHandleFree\n");
  printf("TO PERFORM A SELECT WITH UNKNOWN OUTPUT COLUMNS\n");
  printf("AT COMPILE TIME:\n");

  /* allocate a statement handle */
  ciRC = OCIHandleAlloc( (dvoid *)envhp, (dvoid **)&hstmt, OCI_HTYPE_STMT, 0, NULL );
  ERR_HANDLE_CHECK(errhp, ciRC);

  printf("\n  Directly execute the statement\n");
  printf("    %s.\n", stmt);

  /* directly execute the statement */
  ciRC = OCIStmtPrepare(
      hstmt,
      errhp,
      (OraText *)stmt,
      strlen( stmt ),
      OCI_NTV_SYNTAX,
      OCI_DEFAULT );
  ERR_HANDLE_CHECK(errhp, ciRC);
  ciRC = OCIStmtExecute(
      svchp,
      hstmt,
      errhp,
      0,
      0,
      NULL,
      NULL,
      OCI_DEFAULT );
  ERR_HANDLE_CHECK(errhp, ciRC);

  printf("\n  Identify the output columns, then \n");
  printf("  fetch each row and display.\n");

  /* identify the number of output columns */
  ciRC = OCIAttrGet( hstmt, OCI_HTYPE_STMT, (dvoid *)&nResultCols, NULL, OCI_ATTR_PARAM_COUNT, errhp );
  ERR_HANDLE_CHECK(errhp, ciRC);

  printf("    ");
  for (i = 0; i < nResultCols; i++)
  {
    /* return a set of attributes for a column */
    ciRC = OCIParamGet( hstmt, OCI_HTYPE_STMT, errhp, &hCol, i + 1 );
    ERR_HANDLE_CHECK(errhp, ciRC);

    ciRC = OCIAttrGet( hCol, OCI_DTYPE_PARAM, &colName, &colNameLen, OCI_ATTR_NAME, errhp );
    ERR_HANDLE_CHECK(errhp, ciRC);

    ciRC = OCIAttrGet( hCol, OCI_DTYPE_PARAM, &colSize, NULL, OCI_ATTR_DATA_SIZE, errhp );
    ERR_HANDLE_CHECK(errhp, ciRC);
    colSize = max( colSize, 32 );

    /* set "column display size" to the larger of "column data display size"
       and "column name length" and add one space between columns. */
    colDisplaySize[i] = max(colSize, colNameLen) + 1;

    /* print the column name */
    printf("%-*.*s",
           (int)colDisplaySize[i], (int)colDisplaySize[i], colName);

    /* set "output data buffer length" to "column data display size"
       and add one byte for null the terminator */
    outData[i].length = colDisplaySize[i];

    /* allocate memory to bind a column */
    outData[i].buff = (char *)malloc((int)outData[i].length);

    /* bind columns to program variables, converting all types to CHAR */
    ciRC = OCIDefineByPos(
        hstmt,
        &outData[i].defnhp,
        errhp,
        i + 1,
        outData[i].buff,
        outData[i].length,
        SQLT_STR,
        &outData[i].ind,
        &outData[i].length,
        &outData[i].rcode,
        OCI_DEFAULT );
    ERR_HANDLE_CHECK(errhp, ciRC);
  }

  printf("\n    ");
  for (i = 0; i < nResultCols; i++)
  {
    for (j = 1; j < (int)colDisplaySize[i]; j++)
    {
      printf("-");
    }
    printf(" ");
  }
  printf("\n");

  /* fetch each row and display */
  ciRC = OCIStmtFetch(
      hstmt,
      errhp,
      1,
      OCI_FETCH_NEXT,
      OCI_DEFAULT );
  ERR_HANDLE_CHECK(errhp, ciRC);

  if (ciRC == OCI_NO_DATA )
  {
    printf("\n  Data not found.\n");
  }
  while (ciRC != OCI_NO_DATA )
  {
    printf("    ");
    for (i = 0; i < nResultCols; i++) /* for all columns in this row  */
    { /* check for NULL data */
      if (outData[i].ind == -1 )
      {
        printf("%-*.*s",
               (int)colDisplaySize[i], (int)colDisplaySize[i], "NULL");
      }
      else
      { /* print outData for this column */
        printf("%-*.*s",
               (int)colDisplaySize[i],
               (int)colDisplaySize[i],
               outData[i].buff);
      }
    }
    printf("\n");

    /* fetch next row */
    ciRC = OCIStmtFetch(
        hstmt,
        errhp,
        1,
        OCI_FETCH_NEXT,
        OCI_DEFAULT );
    ERR_HANDLE_CHECK(errhp, ciRC);
  }

  /* free data buffers */
  for (i = 0; i < nResultCols; i++)
  {
    free(outData[i].buff);
  }

  /* free the statement handle */
  ciRC = OCIHandleFree( hstmt, OCI_HTYPE_STMT );
  ERR_HANDLE_CHECK(errhp, ciRC);

  return rc;
} /* TbSelectWithUnknownOutCols */

    void check_db_err(OCIError * errhp, sword status, JES_ERR_MSG * err) {
        char errbuf[MAX_ERRMSG_LEN] = { '\0' };
        sb4 errcode = 0;

        printf("Begin. status=%d. p_err=%p", status, errhp);
        if (status == OCI_SUCCESS)
            return;
        if (err == NULL) {
            printf("invalid input parameter(err is NULL)");
            return;
        }

        switch (status) {
        case OCI_SUCCESS_WITH_INFO:
            (void)OCIErrorGet((dvoid *) errhp, (ub4) 1, (text *) NULL, &errcode, (OraText *) errbuf, (ub4) sizeof(errbuf), OCI_HTYPE_ERROR);
            if (strlen(errbuf) > 0)
                errbuf[strlen(errbuf) - 1] = '\0';
            printf("OCI_SUCCESS_WITH_INFO - %s", errbuf);
            err->errcode = errcode;
            snprintf(err->errmsg, MAX_ERRMSG_LEN, "Error - OCI_SUCCESS_WITH_INFO: %s ", errbuf);
            break;
        case OCI_NEED_DATA:
            printf("Error - OCI_NEED_DATA");
            snprintf(err->errmsg, MAX_ERRMSG_LEN, "Error - OCI_NEED_DATA");
            break;
        case OCI_NO_DATA:
            printf("Error - OCI_NO_DATA");
            snprintf(err->errmsg, MAX_ERRMSG_LEN, "Error - OCI_NO_DATA");
            break;
        case OCI_ERROR:
            (void)OCIErrorGet((dvoid *) errhp, (ub4) 1, (text *) NULL, &errcode, (OraText *) errbuf, (ub4) sizeof(errbuf), OCI_HTYPE_ERROR);
            if (strlen(errbuf) > 0)
                errbuf[strlen(errbuf) - 1] = '\0';
            printf("OCI_ERROR - %s", errbuf);
            err->errcode = errcode;
            snprintf(err->errmsg, MAX_ERRMSG_LEN, "Error - %s", errbuf);
            break;
        case OCI_INVALID_HANDLE:
            printf("Error - OCI_INVALID_HANDLE");
            snprintf(err->errmsg, MAX_ERRMSG_LEN, "Error - OCI_INVALID_HANDLE");
            break;
        case OCI_STILL_EXECUTING:
            printf("Error - OCI_STILL_EXECUTE");
            snprintf(err->errmsg, MAX_ERRMSG_LEN, "Error - OCI_STILL_EXECUTE");
            break;
        case OCI_CONTINUE:
            printf("Error - OCI_CONTINUE");
            snprintf(err->errmsg, MAX_ERRMSG_LEN, "Error - OCI_CONTINUE");
            break;
        default:
            printf("Undefined error. status = %d", status);
            snprintf(err->errmsg, MAX_ERRMSG_LEN, "Error - status = %d", status);
            break;
        }

        printf("End. Check DB error.");
        return;
    }
