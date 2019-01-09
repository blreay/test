#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "cobmain.h"
#include "cobcall.h"
#include "cobtypes.h" 


main(int argc, char *argv[])
{
    printf("enter main\n");
    cobinit();
    cobfunc("secondentry", argc, argv); /* call a cobol program
                                    using cobfunc function */
    cobexit(0);               /* Cobexit - close down COBOL
                                 run-time environment */
}

