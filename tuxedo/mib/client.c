 /*	Copyright (c) 1997 BEA Systems, Inc.  */
 /*     All Rights Reserved  */

 /*    THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF  */
 /*    BEA Systems, Inc.  */
 /*    The copyright notice above does not evidence any  */
 /*    actual or intended publication of such source code.  */
 /*    ident "@(#) qa/sanity_tests/apps/admapp/client.c	$Revision: 1.1.1.1 $"  */
                                                         
/*
client.c
	client program which uses FML32 buffer as databuffer. 
        Build TUXCONFIG fron scratch using TM_MIB 
        Boot the application adn shutdown the application 
*/

#include <stdio.h>
#include <stdlib.h>
#include <atmi.h>
#include <userlog.h>
#include <fml32.h>
#include <fml.h>
#include <tpadm.h>


#define BUFLEN 2048

#ifdef _TMPROTOTYPES
main(int argc, char *argv[])
#else
main(argc, argv)
int	argc;
char	*argv[];
#endif
{
	FBFR32	*fmlptr;
        char    *rcvbuf,*sendbuf; 
	long    rlen,flag,rcvlen,sendlen;
	long    sz = 1024;
	long    ipk = 46754;
	long    no = 1;
        char    *ta_status;
        TPINIT  *tpinfo;

        char *str;


	/* allocate for databuffer */

	if ( (fmlptr = (FBFR32 *) tpalloc("FML32", NULL, BUFLEN)) == NULL ) {
		userlog("ERROR: tpalloc failed. %s: \n", tpstrerror(tperrno));
		return(-1);
	}

         str = ( char *) malloc(80);

         str = getenv("TUXCONFIG");

	/* fill all the fileds */

	Fchg32(fmlptr, TA_CLASS, 0, "T_DEVICE", 0); 
	Fchg32(fmlptr, TA_OPERATION, 0, "SET", 0);
	Fchg32(fmlptr, TA_STATE, 0, "NEW", 0);
	Fchg32(fmlptr, TA_LMID, 0, "L1", 0);
	Fchg32(fmlptr, TA_CFGDEVICE, 0, str, 0);
	Fchg32(fmlptr, TA_DEVICE, 0, str, 0);
	Fchg32(fmlptr, TA_DEVSIZE, 0, (char *)&sz, 0);
 
	if ( tpadmcall(fmlptr, &fmlptr, 0) == -1 ) {
	        userlog("ERROR : tpadmcall failed (DEVICE) %s \n", tpstrerror(tperrno));
		exit(1);
	}
        userlog("INFO: **** T_DEVICE is created successfully");
        puts("**** T_DEVICE is created successfully");
	tpfree((char *)fmlptr);


	if ( (fmlptr = (FBFR32 *) tpalloc("FML32", NULL, BUFLEN)) == NULL ) {
		userlog("ERROR: tpalloc failed. %s: \n", tpstrerror(tperrno));
		return(-1);
	}

	Fchg32(fmlptr, TA_CLASS, 0, "T_DOMAIN", 0); 
	Fchg32(fmlptr, TA_OPERATION, 0, "SET", 0);
	Fchg32(fmlptr, TA_STATE, 0, "NEW", 0);
	Fchg32(fmlptr, TA_MASTER, 0, "L1", 0);
	Fchg32(fmlptr, TA_IPCKEY, 0, (char *)&ipk, 0);
	Fchg32(fmlptr, TA_MODEL, 0, "SHM", 0);
	Fchg32(fmlptr, TA_LMID, 0, "L1", 0);

	Fchg32(fmlptr, TA_TUXCONFIG, 0, str, 0);
        str = getenv("TUXDIR");
	Fchg32(fmlptr, TA_TUXDIR, 0, str, 0);
        str = getenv("APPDIR");
	Fchg32(fmlptr, TA_APPDIR, 0, str, 0);


	if ( tpadmcall(fmlptr, &fmlptr, 0) == -1 ) {
		userlog("ERROR : tpadmcall failed (MACHINE) %s \n", tpstrerror(tperrno));
		exit(1);
	}
        userlog("INFO: **** T_DOMAIN and T_MACHINE created successfully");
        puts("**** T_DOMAIN and T_MACHINE created successfully");
	tpfree((char *)fmlptr);



	if ( (fmlptr = (FBFR32 *) tpalloc("FML32", NULL, BUFLEN)) == NULL ) {
		userlog("ERROR: tpalloc failed. %s: \n", tpstrerror(tperrno));
		return(-1);
	}

	Fchg32(fmlptr, TA_OPERATION, 0, "SET", 0);
	Fchg32(fmlptr, TA_CLASS, 0, "T_GROUP", 0); 
	Fchg32(fmlptr, TA_STATE, 0, "NEW", 0);
	Fchg32(fmlptr, TA_SRVGRP, 0, "GROUP1", 0);
	Fchg32(fmlptr, TA_GRPNO, 0, (char *)&no, 0);
	Fchg32(fmlptr, TA_LMID, 0, "L1", 0);

	if ( tpadmcall(fmlptr, &fmlptr, 0) == -1 ) {
		userlog("ERROR: tpadmcall failed (GROUP) %s \n", tpstrerror(tperrno));
		exit(1);
	}

        userlog("INFO: **** T_GROUP is  created successfully");
        puts("**** T_GROUP is  created successfully");

	tpfree((char *)fmlptr);

	if ( (fmlptr = (FBFR32 *) tpalloc("FML32", NULL, BUFLEN)) == NULL ) {
		userlog("ERROR: tpalloc failed. %s: \n", tpstrerror(tperrno));
		return(-1);
	}

	Fchg32(fmlptr, TA_CLASS, 0, "T_SERVER", 0); 
	Fchg32(fmlptr, TA_OPERATION, 0, "SET", 0);
	Fchg32(fmlptr, TA_STATE, 0, "NEW", 0);
	Fchg32(fmlptr, TA_SRVGRP, 0, "GROUP1", 0);
	Fchg32(fmlptr, TA_SRVID, 0, (char *)&no, 0);
	Fchg32(fmlptr, TA_SERVERNAME, 0, "simpserv", 0);

	if ( tpadmcall(fmlptr, &fmlptr, 0) == -1 ) {
		userlog("ERROR: tpadmcall failed (SERVER) %s \n", tpstrerror(tperrno));
		exit(1);
	}

        userlog("INFO: **** T_SERVER is  created successfully");
        puts("**** T_SERVER is  created successfully");
	tpfree((char *)fmlptr);

        fmlptr = (FBFR32 *) tpalloc("FML32", NULL, BUFLEN); 

	Fchg32(fmlptr, TA_CLASS, 0, "T_SERVICE", 0); 
	Fchg32(fmlptr, TA_OPERATION, 0, "SET", 0);
	Fchg32(fmlptr, TA_STATE, 0, "NEW", 0);
	Fchg32(fmlptr, TA_SERVICENAME, 0, "TOUPPER", 0);

	if ( tpadmcall(fmlptr, &fmlptr, 0) == -1 ) {
		userlog("ERROR: tpadmcall failed (SERVICE) %s \n", tpstrerror(tperrno));
		exit(1);
	}

        userlog("INFO: **** T_SERVICE is  created successfully");
        puts("**** T_SERVICE is  created successfully");
	tpfree((char *)fmlptr);


        if ( (fmlptr = (FBFR32 *) tpalloc("FML32", NULL, BUFLEN)) == NULL ) {
                userlog("ERROR: tpalloc failed. %s: \n", tpstrerror(tperrno));
                return(-1);
        }

        Fchg32(fmlptr, TA_CLASS, 0, "T_DOMAIN", 0);
        Fchg32(fmlptr, TA_OPERATION, 0, "SET", 0);
        Fchg32(fmlptr, TA_STATE, 0, "ACT", 0);

	if ( tpadmcall(fmlptr, &fmlptr, 0) == -1 ) {
		userlog("ERROR: tpadmcall failed (ACT DOMAIN) %s \n", tpstrerror(tperrno));
		exit(1);
	}
        userlog("INFO: **** DOMAIN is  booteed successfully");
        puts("**** DOMAIN is  booteed successfully");
	tpfree((char *)fmlptr);

        tpinfo = ( TPINIT *) tpalloc ("TPINIT", NULL, TPINITNEED(0));
        sprintf(tpinfo->usrname, "appadmin");
        sprintf(tpinfo->cltname, "tpsysadm");

        if ( tpinit(tpinfo) < 0 )
        {
           userlog("ERROR: tpinit() failed : %s \n", tpstrerror(tperrno)); 
           puts("tpinit() failed : unable to join as Administrator");
           exit(1);
         }


       if ( (fmlptr = (FBFR32 *) tpalloc("FML32", NULL, BUFLEN)) == NULL ) {
                userlog("ERROR: tpalloc failed. %s: \n", tpstrerror(tperrno));
                return(-1);
        }

        Fchg32(fmlptr, TA_OPERATION, 0, "SET", 0);
        Fchg32(fmlptr, TA_STATE, 0, "ACT", 0);
        Fchg32(fmlptr, TA_CLASS, 0, "T_GROUP", 0);
        Fchg32(fmlptr, TA_SRVGRP, 0, "GROUP1", 0);
        Fchg32(fmlptr, TA_GRPNO, 0, (char *)&no, 0);
        Fchg32(fmlptr, TA_LMID, 0, "L1", 0);

	tpcall(".TMIB", (char *) fmlptr, 0, (char **)&fmlptr, &rlen, 0); 
        userlog("INFO: **** SERVER is  booteed successfully");
        puts("**** SERVER is  booteed successfully");
	tpfree((char *)fmlptr);

        fmlptr = (FBFR32 *) tpalloc("FML32", NULL, BUFLEN); 

        Fchg32(fmlptr, TA_OPERATION, 0, "GET", 0);
        Fchg32(fmlptr, TA_CLASS, 0, "T_SERVER", 0);
        flag=MIB_LOCAL;
        Fchg32(fmlptr, TA_FLAGS, 0, (char *)&flag, 0);
        Fchg32(fmlptr, TA_SRVID, 0, (char *)&no, 0);
        Fchg32(fmlptr, TA_SRVGRP, 0, "GROUP1", 0);

	tpcall(".TMIB", (char *) fmlptr, 0, (char **)&fmlptr, &rlen, 0); 

        ta_status = Ffind32(fmlptr, TA_STATE, 0 , NULL );
        printf("**** The server state  : %s \n",ta_status);
        userlog("INFO: **** SERVER state is accessed successfully");


	sendlen = strlen("admcall sanity test");

	/* Allocate STRING buffers for the request and the reply */

	if((sendbuf = (char *) tpalloc("STRING", NULL, sendlen+1)) == NULL) {
		fprintf(stderr,"Error allocating send buffer\n");
		tpterm();
		exit(1);
	}

	if((rcvbuf = (char *) tpalloc("STRING", NULL, sendlen+1)) == NULL) {
		fprintf(stderr,"Error allocating receive buffer\n");
		tpfree(sendbuf);
		tpterm();
		exit(1);
	}

	strcpy(sendbuf, "admcall sanity test");

	/* Request the service TOUPPER, waiting for a reply */
	if ( tpcall("TOUPPER", sendbuf, 0, &rcvbuf, &rcvlen, (long)0) < 0 )
	{
           userlog("ERROR:tpcall failed while requesting to service TOUPPER\n");
		tpfree(sendbuf);
		tpfree(rcvbuf);
		tpterm();
		exit(1);
	}

	printf("**** Returned string is: %s\n", rcvbuf);

	/* Free Buffers & Detach from System/T */
	tpfree(sendbuf);
	tpfree(rcvbuf);


        fmlptr = (FBFR32 *) tpalloc("FML32", NULL, BUFLEN); 

        Fchg32(fmlptr, TA_OPERATION, 0, "SET", 0);
        Fchg32(fmlptr, TA_STATE, 0, "INA", 0);
        Fchg32(fmlptr, TA_CLASS, 0, "T_GROUP", 0);
        Fchg32(fmlptr, TA_SRVGRP, 0, "GROUP1", 0);
        Fchg32(fmlptr, TA_GRPNO, 0, (char *)&no, 0);
        Fchg32(fmlptr, TA_LMID, 0, "L1", 0);


	tpcall(".TMIB", (char *) fmlptr, 0, (char **)&fmlptr, &rlen, 0); 
        userlog("INFO: **** SERVER is  shutdown successfully");
        puts("**** SERVER is  shutdown successfully");
	tpfree((char *)fmlptr);

        fmlptr = (FBFR32 *) tpalloc("FML32", NULL, BUFLEN); 

        Fchg32(fmlptr, TA_OPERATION, 0, "GET", 0);
        Fchg32(fmlptr, TA_CLASS, 0, "T_SERVER", 0);
        flag=MIB_LOCAL;
        Fchg32(fmlptr, TA_FLAGS, 0, (char *)&flag, 0);
        Fchg32(fmlptr, TA_SRVID, 0, (char *)&no, 0);
        Fchg32(fmlptr, TA_SRVGRP, 0, "GROUP1", 0);

	tpcall(".TMIB", (char *) fmlptr, 0, (char **)&fmlptr, &rlen, 0);
        ta_status = Ffind32(fmlptr, TA_STATE, 0 , NULL );
        printf("**** The server state  : %s \n",ta_status);
        userlog("INFO: **** SERVER state is accessed successfully");

        tpterm();

/*
* This is to avoid problem seen on solaris 2.51 (lcsol5).
*/
	sleep(10);

	if ( (fmlptr = (FBFR32 *) tpalloc("FML32", NULL, BUFLEN)) == NULL ) {
		userlog("ERROR: tpalloc failed. %s: \n", tpstrerror(tperrno));
		return(-1);
	}

	Fchg32(fmlptr, TA_CLASS, 0, "T_DOMAIN", 0); 
	Fchg32(fmlptr, TA_OPERATION, 0, "SET", 0);
	Fchg32(fmlptr, TA_STATE, 0, "INA", 0);

/*
*        Fprint(fmlptr);
*/

	if ( tpadmcall(fmlptr, &fmlptr, 0) == -1 ) {
		userlog("ERROR: tpadmcall failed %s \n", tpstrerror(tperrno));
		exit(1);
	}
        userlog("INFO: **** DOMAIN is  shutdown successfully");
        puts("**** DOMAIN is  shutdown successfully");

	tpfree((char *)fmlptr);


        exit(0);
}
