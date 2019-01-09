#include <stdio.h>
#include <errno.h>
#include <fcntl.h>
#include <time.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
/******************************************************************************/
static unsigned char * customized_base64_encode(char *seed, const unsigned char *cptr, unsigned char **rptr, int len)
{
    unsigned char *res = NULL;
    int i = 0;
    int clen = 0;
    char *base64_seed = seed;

    clen = len / 3;
    if (cptr == NULL || (res = (unsigned char *)malloc(clen + 3 * 2 + len + 64)) == NULL) {
        *rptr = NULL;
        return NULL;
    }
    for (*rptr = res; clen--;) {
        *res++ = *cptr >> 2 & 0x3f;
        *res = *cptr++ << 4 & 0x30;
        *res++ |= *cptr >> 4;
       *res = (*cptr++ & 0x0f) << 2;
        *res++ |= *cptr >> 6;
        *res++ = *cptr++ & 0x3f;
    }
    if ((i = len % 3)) {
        if (i == 1) {
            *res++ = *cptr >> 2 & 0x3f;
            *res++ = *cptr << 4 & 0x30;
            *res++ = 64;
            *res++ = 64;
        } else {
            *res++ = *cptr >> 2 & 0x3f;
            *res = *cptr++ << 4 & 0x30;
            *res++ |= *cptr >> 4;
            *res++ = (*cptr & 0x0f) << 2;
            *res++ = 64;
        }
    }
    *(res++) = 65;
    *res = 0x0;
    for (res = *rptr; *res != 65; res++)
        *res = base64_seed[*res];
    rptr[0][strlen((char *)*rptr) - 1] = '\0';
    return *rptr;
}

static char * je_reshuffle_seed(char *seedin, int factor, char **seedout)
{
    int sl = strlen(seedin);
    int m = factor % sl;
    int i = 0;
    int BUFLEN = strlen(seedin) + 32;
    *seedout = (char *)malloc(BUFLEN);
    if (NULL == *seedout) {
        return NULL;
    }
    memset(*seedout, 0x0, BUFLEN);
    while (i < sl) {
        *(*seedout + i) = *(seedin + (i - m + sl) % sl);
        i++;
    }
    return *seedout;
}

static unsigned char *je_gen_key(const char * key, int factor, unsigned char **newkey)
{
    int BASE = '0';
    int i = 0;
    int j = 0;
    char b[64] = { '\0' };

    char * a = (char *)malloc(strlen(key) + 32);
    if (NULL == a) {
        return NULL;
    }
    strcpy(a, key);
    int al = strlen(a);
    sprintf(b, "%d", factor);
    int bl = strlen(b);

    if (((*(a + al - 1) - BASE) % 2) != 0)
        i = 1;
    while (i < al - 1) {
        *(a + i) = ((*(a + i) - BASE) + (*(b + j) - BASE)) % 10 + BASE;
        i = i + 2;
        j++;
    }

    *newkey = (unsigned char *)a;
    return *newkey;
}

static int je_enc_key(const char * key, int factor, unsigned char **enckey)
{
    int ret = -1;
    char * newseed = NULL;
    static char *base64_seed = "R3bHPFK2aEQp!@#$%^&*()_+6XLWc=ejNlB~||{}d4I8sAyC15OfrwhuqS+TvonDG";

    /* generate new key according to key and factor */
    char *newkey = NULL;
    if (NULL == je_gen_key(key, factor, (unsigned char **)&newkey)) {
        ret = -1;
        goto __END__;
    }

    /* generate new base64 seed */
    if (NULL == je_reshuffle_seed(base64_seed, factor, &newseed)) {
        ret = -2;
        goto __END__;
    }

    /* encode new key with new seed */
    if (NULL == customized_base64_encode(newseed, (unsigned char *)newkey, enckey, strlen(newkey))) {
        ret = -3;
        goto __END__;
    }
    ret = 0;

  __END__:
    if (NULL != newkey)
        free(newkey);
    if (NULL != newseed)
        free(newseed);

    return ret;
}


/******************************************************************************/
int main(int argc, char *argv[])
{
    char cmd[32] = { '\0' };
    char jobid[32] = { '\0' };
    int pid = 0;
	int ret = 1;
	int output = 0;

    /* print command line arguments */
    int i = 0;
    for (i = 0; i < argc; i++) {
        fprintf(stderr, "ARG[%d]=%s\n", i, argv[i]);
    }

    /* parse command line */
    int cmd_opt = 0;
    while (1) {
        fprintf(stderr, "proces index:%d\n", optind);
        cmd_opt = getopt(argc, argv, "aoc:j:p:e::");

        /* End condition always first */
        if (cmd_opt == -1) {
            break;
        }

        /* Print option when it is valid */
        if (cmd_opt != '?') {
            fprintf(stderr, "option:-%c\n", cmd_opt);
        }

        /* Lets parse */
        switch (cmd_opt) {
            /* No args */
        case 'a':
        case 'o':
			output = 1;
            break;
            /* Single arg */
        case 'c':
            strcpy(cmd, optarg);
            fprintf(stderr, "command:%s\n", cmd);
            break;
        case 'j':
            strcpy(jobid, optarg);
            fprintf(stderr, "jobid:%s\n", jobid);
            break;
        case 'p':
            pid = atoi(optarg);
            fprintf(stderr, "pid:%d\n", pid);
            break;
            /* Optional args */
        case 'e':
            if (optarg) {
                fprintf(stderr, "option arg:%s\n", optarg);
            }
            break;
            /* Error handle: Mainly missing arg or illegal option */
        case '?':
            fprintf(stderr, "Illegal option:-%c\n", isprint(optopt) ? optopt : '#');
            break;
        default:
            fprintf(stderr, "Not supported option\n");
            break;
        }
    }

    /* Do we have args? */
    if (argc > optind) {
        int i = 0;
        for (i = optind; i < argc; i++) {
            fprintf(stderr, "argv[%d] = %s\n", i, argv[i]);
        }
    }

	if (1 == output) {
        char *enckey = NULL;
		if (0 != je_enc_key(jobid, pid, &enckey)) {
			printf("Failed to encrypt key: %s", pid);
			return -1;
		}
        //fprintf(stderr, "%s\n", enckey);
		printf("%s\n", enckey); 
		free(enckey);
		return 0;
	}

    /* read key from stdin and verify it */
    int time_start = time(NULL);
    FILE *fp = fdopen(STDIN_FILENO, "r");
    if (fp > 0) {
        char key[2048] = { '\0' };
        while (1) {
            if (fgets(key, sizeof(key), fp) == NULL) {
                printf("file end\n");
                return 0;
            } else {
                /* remove \n */
                *(key + strlen(key) - 1) = 0;
                printf("read buff [%s]\n", key);
                char *enckey = NULL;
                if (0 == pid)
                    pid = getpid();
                if (0 != je_enc_key(jobid, pid, &enckey)) {
                    printf("Failed to encrypt key: %s", key);
                    return -1;
                }
                printf("je_enc_key: %s  %d  %s\n", jobid, pid, enckey);
                printf("total costed time %d sec\n", time(NULL) - time_start);
                if (0 == strcmp(key, enckey)) {
                    printf("OK\n");
					ret = 0;
                } else {
                    printf("NG\n");
					ret = 1;
                }
                if (NULL != enckey)
                    free(enckey);
                fclose(fp);
                return ret;
            }
        }
    }
    return 0;
}
