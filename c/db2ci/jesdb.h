#ifndef JESDB_H
#define JESDB_H

#define JES_NO_DATA 1
#define JES_JOBRC_LEN 5

/*Define structure for output data on select operation.*/
#define MAX_SEL_COLUMNS 50
typedef struct _jes_sel_rowbuf {
    char *colbuf[MAX_SEL_COLUMNS];
    char *colname[MAX_SEL_COLUMNS];
    int colnum;
    signed short indicator[MAX_SEL_COLUMNS];
} JES_SEL_ROWBUF;

#ifndef JES_SELSQL_STACK_SIZE
#define JES_SELSQL_STACK_SIZE 3
#endif
typedef struct _JES_OCI_Handle {
    char dbtype[32];            /*DB type: ORACLE or BDB or DB2 */
    void *p_env;                /*the OCI environment handle */
    void *p_err;                /*the error handle */
    void *p_srv;                /*the server handle */
    void *p_svc;                /*the service context handle */
    void *p_usr;                /*the user session context handle */
    void *p_nonsel_sql;         /*the non-select statement handle */
    void *p_sel_buf[JES_SELSQL_STACK_SIZE]; /*the result for select query: only BDB need it */
    void *p_sel_sql[JES_SELSQL_STACK_SIZE]; /*the select statement handle */
    JES_SEL_ROWBUF *rowbuf[JES_SELSQL_STACK_SIZE];
} JES_OCI_Handle;

/*Define structure for error message.*/
#define MAX_ERRMSG_LEN 1024
typedef struct _jes_err_msg {
    char errmsg[MAX_ERRMSG_LEN];    /* information of an error */
    int len;                    /* maximum length of error message */
    int errcode;                /* error code */
} JES_ERR_MSG;

/*Define structure for job management data.*/
typedef struct _jes2_db_jobparam {
    int jobid;
    char jobname[128 + 1];
    char jobclass;
    short prty;
    char status[64 + 1];
    long submittime;
    char typrun[32 + 1];
    char owner[128 + 1];
    char jobtype[32];
    char execgrp[256 + 1];
    long machine;
    long grpid;
    long srvid;
    long srvpid;
    long exectime;
    long endtime;
    pid_t jobpid;               /*job pid */
    char jobrc[JES_JOBRC_LEN + 1];  /*EJR return code */
    long u_sec;
    long u_usec;
    long s_sec;
    long s_usec;
    char jobscript[2048 + 1];
    char ejroption[256 + 1];
    char shelloption[256 + 1];
    int inputtype;              /*How job is input to JES. 0:by file; 1:by buffer */
    char clientmode[32 + 1];
    long cltiddata1;
    long cltiddata2;
    long cltiddata3;
    long cltiddata4;
    char profileContent[1024 + 1];  /*jes security profile content string */
    char jobenv[1024 + 1];      /*environment variables to be set when executing a job */
} JES2_DB_JOBPARAM;

/* this structure is used to store SQL query result for BDB and DB2, ORACLE DB don't need it */
typedef struct _JES_DB_SEL_BUF {
    int rownum;                 /* The total row number */
    int colnum;                 /* The total colum number in one row */
    int currow;                 /* Current row number: for fetch operation */
    char **table;               /* The result retrun by sqlite3_get_table */
    JES_SEL_ROWBUF *rowbuf;     /* Formatted data used for fetch */
} JES_DB_SEL_BUF;

#define NC(x) ((x) == NULL ? "NULL" : (x))

/*SQL operation*/
#define JES_SELECT_JOB  1
#define JES_UPDATE_JOB  2
#define JES_INSERT_JOB  3
#define JES_DELETE_JOB  4
#define JES_LOCK_TABLE  5
#define JES_CHECK_TABLE 6

#endif
