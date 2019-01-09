#include "mi_ConcurrentAccessManagement.h"


/* Locked resources files (AccLock) */
ResT AccLock;
/* Waiting for lock ressources file (AccWait) */
ResT AccWait;

/* The list of resources in MT_ACC_LIST */
char *ResList;


/* Global Error : code + msg  */
ErrorT Error;

/* List Type for action ACT_LIST */
int ListType;

int AccStatus;
/* needed Action + option - command line analyse's result */
ActionT AccAct;


ResRefT ResRequest[RESTAB_SZ];	/* list of Resources to lock (param ou MT_ACC_LIST) */
int NbResRequest;            	/* number of Resources to lock                         */

ResRefT ResLocked[RESTAB_SZ];
int NbResLocked;

int TrcSwitch; /* ON=1 - OFF=0 */
int TrcLevel; /* 0/1/2/3 */


size_t  nbl;

int FirstTime;

time_t datej;
char g_szHostName[1024];
int GetHostName(char* hostname);

/* =========================================================================== */
/* <concacc> module is generated in two forms OBJ et EXE                       */
/* "-D MAIN" compilation command allow inclusion of entry point "main"         */
/* --------------------------------------------------------------------------- */
/* IN  - argc : parameters number                                              */
/*       argv : Array of pointers to input parameters                          */
/* OUT - RC : global exit status                                               */
/* =========================================================================== */
#ifdef MAIN
int main(int argc, char *argv[]) {
	int i;
	int rc;
	char *p[MAX_PARAMS];					/* Input parameters list      */


	i = 0;

	if (argc !=3){
		printf("useage: testNFS <filepath> <sleep_seconds>\n");
		return 1;
	}

	for (i=0; i<MAX_PARAMS; i++) {
		p[i]=NULL;
	}

	for (i=1; i<argc; i++) {
		/* we don't pass the program name */
		p[i-1] = argv[i];
		/* printf("MAIN/ARG(%d)=%s\n", i, argv[i]); */
	}

	//rc=concacc(argc-1, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9]);
	
	time_t accTimeStart;		/* Start Time of Tempos management process         */
	time_t accTimeCurrent;    /* Current time used for defining MAX Time         */
	long timeExec;
	
	GetHostName(g_szHostName);
	
	FcdT a;
	strcpy(a.fName, argv[1]);
	
	// file lock
	time(&accTimeStart);
	Trace(L_DEBUG, "(LOCK): StartTIME   : %s", ctime(&accTimeStart));
	FileOpen(&a, O_RDWR);
	time(&accTimeCurrent);
	Trace(L_DEBUG, "(LOCK): CurrentTIME : %s", ctime(&accTimeCurrent));	
	timeExec=difftime(accTimeCurrent, accTimeStart);
	Trace(L_MAX, "(LOCK): file lock use <%ld> secondes \n", timeExec);
	
	FileRead1(a.hFile, 0);
	sleep(atoi(argv[2]));
	FileWrite1(a.hFile);

	// file unlock
	time(&accTimeStart);
	Trace(L_DEBUG, "(UNLOCK): StartTIME   : %s", ctime(&accTimeStart));
	FileClose(&a);
	time(&accTimeCurrent);
	Trace(L_DEBUG, "(UNLOCK): CurrentTIME : %s", ctime(&accTimeCurrent));
	timeExec=difftime(accTimeCurrent, accTimeStart);
	Trace(L_MAX, "(UNLOCK): file unlock use <%ld> secondes \n", timeExec);

	exit(rc);
}

#endif

/* =========================================================================== */
/*  Opening resources descriptions file (AccLock/AccWait)                      */
/* --------------------------------------------------------------------------- */
/* IN  -  fcd : File Control Descriptor                                        */
/* OUT -  mode : opening mode                                                  */
/* =========================================================================== */
int FileOpen(FcdT * fcd, int mode)
{
	if (fcd->status == F_OPEN)
		return RC_DONE;

	/* Opening file and creating a lock   */
	//Trace(L_DEBUG, "(ACC): Opening file <%s> \n",  fcd->fName);

	fcd->hFile = open(fcd->fName, mode);
	if (fcd->hFile == -1) {
		fprintf(stderr, "Can't open file <%s> (non-created ? or right RW ?) \n", fcd->fName);
		fcd->status = F_ERROR;
		Error.type = ERR_FILE_OPEN;
		return(RC_ERROR);
	}
	/* F_LOCK : blocking call */
	if (lockf(fcd->hFile, F_LOCK, 0) == -1) {
		fprintf(stderr, "Lock attenpt failed for file <%s> \n", fcd->fName);
		Error.type = ERR_FILE_LOCK;
		return(RC_ERROR);

	}

	fcd->status = F_OPEN;
	//Trace(L_DEBUG, "(ACC): DEBUG: END opening function  \n");
	return (RC_DONE);
}

/* =========================================================================== */
/*  Opening resources descriptions file (AccLock/AccWait)       */
/* --------------------------------------------------------------------------- */
/* IN  -                                                                       */
/* OUT -                                                                       */
/* =========================================================================== */
int FileClose(FcdT * fcd)
{
	if (fcd->status == F_CLOSE)
		return RC_DONE;

	/* release the lock and closing file  */

	//Trace(L_DEBUG, "(ACC): CloseFile of file >%s< \n",  fcd->fName);

	if (lseek(fcd->hFile, 0, SEEK_SET) == -1) {
		fprintf(stderr, "attempt to access file begining failed \n");
		Error.type = ERR_FILE_SEEK;
		return(RC_ERROR);
	}
	if (lockf(fcd->hFile, F_ULOCK, 0) == -1) {
		fprintf(stderr, "attempt release lock failed\n");
		Error.type = ERR_FILE_LOCK;
		return(RC_ERROR);
	}

	close(fcd->hFile);
	fcd->status = F_CLOSE;
	return(RC_DONE);
}

/* =========================================================================== */
/*  Reading resources descriptions file (AccLock/AccWait)                      */
/*  loading DATA in the table <ResDesc>                                        */
/* --------------------------------------------------------------------------- */
/*  if <ResDesc> table must be extended for insertions                         */
/*  <extent> is different from ZERO                                             */
/* --------------------------------------------------------------------------- */
/* IN  -                                                                       */
/* OUT -                                                                       */
/* =========================================================================== */
int FileRead1(int res, int extent)
{
	char fileHeader[256];
	int i;
	int nbByte = 0;



	if (lseek(res, 0, SEEK_SET) == -1) {
		fprintf(stderr, "(ACC): attempt to access file begining failed \n");
		Error.type = ERR_FILE_SEEK;
		return(RC_ERROR);
	} 
	nbByte = read(res, fileHeader, sizeof(fileHeader));
	if (nbByte < 0) {
		Error.type = ERR_FILE;
		return(RC_ERROR);
		/* Erreur */
	} /* if (nbByte < 0) */
	else if (nbByte == 0) {
	} /* if (nbByte == 0) */
	else {
		// Trace(L_DEBUG, "(ACC): A Allocated %d bytes for %d records in <%s>\n",sizeof(ResDescT)*(res->nbDescEntry+NbResRequest), (res->nbDescEntry+NbResRequest), res->name);
		
	}
	return(RC_DONE);
}

/* =========================================================================== */
/*  writing resources descriptions file (AccLock/AccWait)                      */
/*  writing DATA from table <ResDesc>                                          */
/* --------------------------------------------------------------------------- */
/* IN  -                                                                       */
/* OUT -                                                                       */
/* =========================================================================== */
int FileWrite1(int res)
{
	char fileHeader[HEADER_SZ];

	/* writing head and bloc assign */

	if (lseek(res, 0, SEEK_SET)==-1) {
		fprintf(stderr, "<%s> attempt to access file begining failed \n", res);
		fflush(stdout);
		Error.type = ERR_FILE_SEEK;
		return(RC_ERROR);
	}
	sprintf(fileHeader,"%010d","65565");
	//Trace(L_MAX, "(ACC): <%s> nb elem. <%s>\n", res->name, fileHeader);

	write(res, fileHeader, sizeof(fileHeader));

	//Trace(L_DEBUG, "(ACC): A --- nbre elem=%d written size = %d \n", res->nbDescEntry, sizeof(ResDescT)*res->nbDescEntry);

	return(RC_DONE);
}


/* =========================================================================== */
/* Trace function                                                              */
/* --------------------------------------------------------------------------- */
/* IN  - lvl : trace level L_MIN/L_MAX/L_DEBUG                                 */
/*       mess : printf mask to format trace message                            */ 
/* OUT - NULL                                                                  */
/* =========================================================================== */
void Trace(int lvl, char * mess, ...)
{
	va_list trcParams;
	char logHeader[512]={0};

	// if (TrcSwitch == OFF)
		// return;
	// if (lvl > TrcLevel)
		// return;
	sprintf(logHeader, "(%s)(%ul): ", g_szHostName, getpid());
	fprintf(stderr, logHeader);
	va_start(trcParams, mess);
	vfprintf (stderr, mess, trcParams);
	va_end(trcParams);
	fflush(stderr);
}

int GetHostName(char* hostname)
{
    FILE *fstream=NULL;
    char buff[1024];
    memset(buff,0,sizeof(buff));
	if (NULL == hostname) {
		return -1;
	}
    if (NULL == (fstream=popen("uname -n","r"))) {
        printf("execute command(uname -n) failed: %s", strerror(errno));
        return -1;
    }

	if (NULL != fscanf(fstream, "%s", buff)) {
        sprintf(hostname, "%s", buff);
    } else {
        pclose(fstream);
        return -1;
    }
    pclose(fstream);
    return 0;
}
