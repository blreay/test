/*ARTPERL.C*/
/* Wed Sep 24 21:03:56 2014 */

/*********************************************************
Usage:
*Encrypt perl script:
     artperl -e -i <srcfile> -o <targetfile> [-k <key>]
     Example:
           artperl -e -i mi_ConvertScript.pl -o enc.pl

*Decrypt perl script(available only in debug version):
    artperl -f -i <srcfile> -o <targetfile> [-k <key>]
    Example:
          artperl -f -i enc.pl -o orig.pl

*Run perl script (-m is only available in debug version):
    artperl -s <perlfile> -p <perl_option> [-m <dbgfile>] [-k <key>]
    Example:
          artperl -s mi_ConvertScript.pl -p "$APPDIR/JOBA > JOBA.out 2>/dev/null"
**********************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <sys/wait.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include "idea.h"

#define mulMod          0x10001 /* 2**16 + 1                                    */
#define ones            0xFFFF  /* 2**16 - 1                                    */

#define INBUFSIZE           50000
#define OUTBUFSIZE          50000
#define ART_MAX_KEY_LEN     48
#define ART_KEY_NAME            "ART_ENCRYPT_KEY"
#define MAX_LEN_PER_WRITE       (1024*4)
#define MAX_PIPE_READ       (1024)

#ifdef PATH_MAX
#define ART_MAX_FILE    (PATH_MAX*2)
#else
#define ART_MAX_FILE    4096
#endif
#define PARAMNUM                4

typedef u_int32_t u_int32;
typedef u_int16_t u_int16;
typedef u_int8_t u_int8;

int  inputlen                 = 0;
int  outputlen                = 0;
int  g_flag_pipe_dec          = 1;
int  g_flag_header            = 0;
int  g_flag_debug             = 0;
char inputbuf[INBUFSIZE]      = { '\0' };
char outputbuf[OUTBUFSIZE]    = { '\0' };
char g_perlfile[ART_MAX_FILE] = { '\0' };
char g_outfile[ART_MAX_FILE]  = { '\0' };
char g_infile[ART_MAX_FILE]   = { '\0' };
char g_dbgfile[ART_MAX_FILE]  = { '\0' };
char g_perlopt[ART_MAX_FILE]  = { '\0' };
char g_key[ART_MAX_KEY_LEN]   = "__Default_KEY_ART_2014_";


#ifdef TIME
#include <time.h>
#ifndef CLK_TCK
#define CLK_TCK        1000000
#endif
#endif

#define TRUE                 1 /* boolean constant for true                   */
#define FALSE                0 /* boolean constant for false                  */
#define nofTestData     163840 /* number of blocks encrypted in time test     */

#define nomode               0 /* no mode is specified                        */
#define ecb                  1 /* electronic code book mode                   */
#define cbc                  2 /* cipher block chaining mode                  */
#define cfb                  3 /* ciphertext feedback mode                    */
#define ofb                  4 /* output feedback mode                        */
#define tan                  5 /* tandem DM-scheme for hashing                */
#define abr                  6 /* abreast DM-scheme for hashing               */
#define eol              0x100 /* end of line character                       */
#define colon            0x101 /* character ':'                               */
#define error            0x102 /* unknown character                           */
#define maxInterleave     1024 /* maximal interleave factor + 1               */
#define nofChar ('~' - '!' +1) /* number of different printable characters    */
#define maxBufLen (Idea_dataSize * 1024 * 1024) /* size of input and output buffer   */

Idea_UserKey userKey;          /* user selected 128 bit key                   */
Idea_Key key;                  /* expanded key with 832 bits                  */
Idea_Data state[maxInterleave];/* state informations for interleaving modes   */
Idea_Data hashLow;             /* lower 64 bits of hash value                 */
Idea_Data hashHigh;            /* higher 64 bits of hash value                */

u_int32 inputLen    = 0;       /* current number of bytes read from 'inFile'  */
int interleave      = 0;       /* current interleave factor                   */
int time_0          = 0;       /* time for interleaving modes                 */
int time_N          = 0;       /* time-interleave for interleaving modes      */
int mode            = nomode;  /* current mode                                */

int optEncrypt      = FALSE;   /* encrypt option 'e'                          */
int optDecrypt      = FALSE;   /* decrypt option 'd'                          */
int optHash         = FALSE;   /* hash option 'h'                             */
int optCopyHash     = FALSE;   /* copy and hash option 'H'                    */
int optKeyHexString = FALSE;   /* key as hex-string option 'K'                */
int optKeyString    = FALSE;   /* key as string option 'k'                    */
int optRas          = FALSE;   /* raster file option 'r'                      */
int optTime         = FALSE;   /* measure time option 'T'                     */

int inBufLen        = maxBufLen; /* current length of data in 'inBuf'         */
int inBufPos        = maxBufLen; /* current read position of 'inBuf'          */
int outBufLen       = 0;       /* current write position of 'outBuf'          */
u_int8 inBuf[maxBufLen];       /* buffer for file read                        */
u_int8 outBuf[maxBufLen];      /* buffer for file write                       */

FILE *inFile;                  /* file with input data (plain or ciphertext)  */
FILE *outFile;                 /* file for output data (plain or ciphertext)  */
FILE *dbgFile;                 /* file for output data (plain or ciphertext)  */
FILE *hashFile;                /* 128 bit hash value is written to this file  */

void JESERR(char *fmt,...)
{
        char buf[1024];
        va_list args;
        va_start(args, fmt);
        vsprintf(buf, fmt, args);
        va_end(args);
        fprintf(stderr, "[ERR] %s\n", buf);
}
void JESTRACE(char *fmt,...)
{
        char buf[1024];
        static int trace_init = -1;
        char* jestrace;
        va_list args;
        if (trace_init == -1) {
                if ((jestrace=getenv("ARTTRACE")) != NULL ) {
                        trace_init = 1;
                }else {
                        trace_init = 0;
                }
        }
        if (trace_init == 1 ) {
                va_start(args, fmt);
                vsprintf(buf, fmt, args);
                va_end(args);
                fprintf(stderr, "[TRACE] %s\n", buf);
        }
}
void JESDEBUG(char *fmt,...)
{
        char buf[1024];
        char* jestrace;
        static int trace_init = -1;
        va_list args;

        if (trace_init == -1) {
                if ((jestrace=getenv("ARTTRACE")) != NULL && strcmp(jestrace, "debug") == 0) {
                        trace_init = 1;
                }else {
                        trace_init = 0;
                }
        }
        if (trace_init == 1 ) {
                va_start(args, fmt);
                vsprintf(buf, fmt, args);
                va_end(args);
                fprintf(stderr, "[DEBUG] %s\n", buf);
        }
}

void Init(void)
{
    int i, pos;

    for(i = Idea_userKeyLen - 1; i >= 0 ; i--)
        userKey[i] = 0;

    for(pos = maxInterleave - 1; pos >= 0 ; pos--)
        for(i = Idea_dataLen - 1; i >= 0; i--)
            state[pos][i] = 0;
} /* Init */


void UsageError(int num)
{
    JESTRACE("Usage error!");
    exit(-1);
} /* UsageError */


void Error(int num, char *str)
{
/*     fprintf(stderr, "error %d in idea: %s\n", num, str);  */
    JESERR("error %d in idea: %s", num, str);
    exit(-1);
} /* Error */

int GetData(Idea_Data data)
{
    register int i, len;
    register u_int16 h;
    register u_int8 *inPtr;

    if(inBufPos >= inBufLen)
    {
        if(inBufLen != maxBufLen)
            return 0;

        inBufLen = fread(inBuf, 1, maxBufLen, inFile);
        inBufPos = 0;
        if(inBufLen == 0)
            return 0;

        if(inBufLen % Idea_dataSize != 0)
            for(i = inBufLen; i % Idea_dataSize != 0; i++)
                inBuf[i] = 0;
    }
    inPtr = &inBuf[inBufPos];
    for(i = 0; i < Idea_dataLen; i++)
    {
        h = ((u_int16)*inPtr++ & 0xFF) << 8;
        data[i] = h | (u_int16)*inPtr++ & 0xFF;
    }
    inBufPos += Idea_dataSize;
    if(inBufPos <= inBufLen)
        len = Idea_dataSize;
    else
        len = inBufLen + Idea_dataSize - inBufPos;
    inputLen += len;
    return len;
} /* GetData */

void PutData(Idea_Data data, int len)
{
    register int i;
    register u_int16 h;
    register u_int8 *outPtr;

    outPtr = &outBuf[outBufLen];
    for(i = 0; i < Idea_dataLen; i++)
    {
        h = data[i];
        *outPtr++ = h >> 8 & 0xFF;
        *outPtr++ = h & 0xFF;
    }
    outBufLen += len;
    if(outBufLen >= maxBufLen)
    {
/*         fwrite(outBuf, 1, maxBufLen, outFile); */
        artputbuf((char*)outBuf, maxBufLen, (FILE*) outFile);
        outBufLen = 0;
    }
} /* PutData */

int artputbuf(char* outBuf, int buflen, FILE * outFile) {
        int len1 = 0;
        if (1 == g_flag_pipe_dec ) {
                if ( 1 == g_flag_debug ) {
                        fwrite(outBuf, 1, buflen, dbgFile);
                }
                while (len1 <= buflen && (buflen-len1)>MAX_LEN_PER_WRITE ) {
                        int rc = write( outFile, outBuf+len1, MAX_LEN_PER_WRITE);
                   if( rc == -1 ){
                         JESERR("Parent: write");
                         exit( 1 );
                   }
                        len1 = len1+rc;
                }
                if (len1 != buflen ) {
                        int rc = write( outFile, outBuf+len1, buflen-len1);
                   if( rc == -1 ){
                         JESERR ("Parent: write");
                         exit( 1 );
                   }
                }
        } else {
                fwrite(outBuf, 1, buflen, outFile);
        }
}

void CloseOutput(void)
{
    if(outBufLen > 0)
    {
/*         fwrite(outBuf, 1, outBufLen, outFile); */
        artputbuf(outBuf, outBufLen, outFile);
        outBufLen = 0;
    }
        if (1 == g_flag_pipe_dec ) {
        close(outFile);
        } else {
        fclose(outFile);
        }
} /* CloseOutput */

void IncTime(void)
{
    time_0 = (time_0 + 1) % maxInterleave;
    time_N = (time_N + 1) % maxInterleave;
} /* IncTime */

void EncryptData(Idea_Data data)
{
    int i;

    switch (mode)
    {
        case ecb:
            Idea_Crypt(data, data, key);
            break;

        case cbc:
            for(i = Idea_dataLen - 1; i >= 0; i--)
                data[i] ^= state[time_N][i];
            Idea_Crypt(data, data, key);
            for(i = Idea_dataLen - 1; i >= 0; i--)
                state[time_0][i] = data[i];
            IncTime();
            break;

        case cfb:
            Idea_Crypt(state[time_N], state[time_0], key);
            for(i = Idea_dataLen - 1; i >= 0; i--)
                data[i] = state[time_0][i] ^= data[i];
            IncTime();
            break;

        case ofb:
            Idea_Crypt(state[time_N], state[time_0], key);
            for(i = Idea_dataLen - 1; i >= 0; i--)
                data[i] ^= state[time_0][i];
            IncTime();
            break;

        default:
            break;
    }
} /* EncryptData */


void DecryptData(Idea_Data data)
{
    int i;

    switch(mode)
    {
        case ecb:
            Idea_Crypt(data, data, key);
            break;

        case cbc:
            for(i = Idea_dataLen - 1; i >= 0; i--)
                state[time_0][i] = data[i];
            Idea_Crypt(data, data, key);
            for(i = Idea_dataLen - 1; i >= 0; i--)
                data[i] ^= state[time_N][i];
            IncTime();
            break;

        case cfb:
            for(i = Idea_dataLen - 1; i >= 0; i--)
                state[time_0][i] = data[i];
            Idea_Crypt(state[time_N], data, key);
            for(i = Idea_dataLen - 1; i >= 0; i--)
                data[i] ^= state[time_0][i];
            IncTime();
            break;

        case ofb:
            Idea_Crypt(state[time_N], state[time_0], key);
            for(i = Idea_dataLen - 1; i >= 0; i--)
                data[i] ^= state[time_0][i];
            IncTime();
            break;

        default:
            break;
    }
} /* DecryptData */

void HashData(Idea_Data data)
{
    int i;
    Idea_UserKey userKey;
    Idea_Key key;
    Idea_Data w;

    for(i = Idea_dataLen - 1; i >= 0; i--)
    {
        userKey[i] = hashLow[i];
        userKey[i + Idea_dataLen] = data[i];
    }
    Idea_ExpandUserKey(userKey, key);
    Idea_Crypt(hashHigh, w, key);
    if(mode == abr)
    {
        for(i = Idea_dataLen - 1; i >= 0; i--)
        {
            userKey[i] = data[i];
            userKey[i + Idea_dataLen] = hashHigh[i];
            hashHigh[i] ^= w[i];
            w[i] = hashLow[i] ^ 0xFFFF;
        }
    }
    else
    {   /* mode == tan */
        for(i = Idea_dataLen - 1; i >= 0; i--)
        {
            hashHigh[i] ^= w[i];
            userKey[i] = data[i];
            userKey[i + Idea_dataLen] = w[i];
            w[i] = hashLow[i];
        }
    }
    Idea_ExpandUserKey(userKey, key);
    Idea_Crypt(w, w, key);

    for(i = Idea_dataLen - 1; i >= 0; i--)
        hashLow[i] ^= w[i];
} /* HashData */


void WriteHashValue(void)
{
    int i;

    for(i = 0; i < Idea_dataLen; i++)
        fprintf(hashFile, "%04X", hashHigh[i]);

    for(i = 0; i < Idea_dataLen; i++)
        fprintf(hashFile, "%04X", hashLow[i]);
} /* WriteHashValue */

void PlainLenToData(u_int32 value, Idea_Data data)
{
    data[3] = (u_int16)(value << 3 & 0xFFFF);
    data[2] = (u_int16)(value >> 13 & 0xFFFF);
    data[1] = (u_int16)(value >> 29 & 0x0007);
    data[0] = 0;
} /* PlainLenToData */

void DataToPlainLen(Idea_Data data, u_int32 *value)
{
    if(data[0] || data[1] > 7 || data[3] & 7)
        Error(0, "input is not a valid cryptogram");
    *value = (u_int32)data[3] >> 3 & 0x1FFF | (u_int32)data[2] << 13 |
             (u_int32)data[1] << 29;
} /* DataToPlainLen */

void CryptData(void)
{
    int t, i;
    u_int32 len;
    Idea_Data dat[4];
    Idea_Data data;

    if(optRas)
    {
        if(optEncrypt) /* encrypt rasterfile */
            while ((len = GetData(data)) == Idea_dataSize)
            {
                EncryptData(data);
                PutData(data, Idea_dataSize);
            }
        else /* decrypt rasterfile */
            while ((len = GetData(data)) == Idea_dataSize)
            {
                DecryptData(data);
                PutData(data, Idea_dataSize);
            }

        if(len)
            PutData(data, len);
        CloseOutput();
    }
    else if(optEncrypt)
    {
        /* encrypt data */
        while ((len = GetData(data)) == Idea_dataSize)
        {
            EncryptData(data);
            PutData(data, Idea_dataSize);
        }

        if(len)
        {
            EncryptData(data);
            PutData(data, Idea_dataSize);
        }

        PlainLenToData(inputLen, data);
        EncryptData(data);
        PutData(data, Idea_dataSize);
        CloseOutput();
    }
    else if(optDecrypt)
    {   /* decrypt data */
        if((len = GetData(dat[0])) != Idea_dataSize)
        {
            if(len)
                Error(2, "input is not a valid cryptogram");
            else
                Error(3, "there are no data to decrypt");
        }

        DecryptData(dat[0]);

        if((len = GetData(dat[1])) != Idea_dataSize)
        {
            if(len)
                Error(4, "input is not a valid cryptogram");

            DataToPlainLen(dat[0], &len);

            if(len)
                Error(5, "input is not a valid cryptogram");
        }
        else
        {
            DecryptData(dat[1]);
            t = 2;
            while((len = GetData(dat[t])) == Idea_dataSize)
            {
                DecryptData(dat[t]);
                PutData(dat[(t + 2) & 3], Idea_dataSize);
                t = (t + 1) & 3;
            }

            if(len)
                Error(6, "input is not a valid cryptogram");

            DataToPlainLen(dat[(t + 3) & 3], &len);
            len += 2 * Idea_dataSize;
            if(inputLen < len && len <= inputLen + Idea_dataSize)
            {
                len -= inputLen;
                PutData(dat[(t + 2) & 3], len);
            }
            else
                Error(7, "input is not a valid cryptogram");
        }
        CloseOutput();
    }
    else
    {   /* compute hash value */
        for(i = Idea_dataLen - 1; i >= 0; i--)
        {
            hashHigh[i] = userKey[i];
            hashLow[i] = userKey[i + Idea_dataLen];
        }
        if(optCopyHash)
        {
            while ((len = GetData(data)) == Idea_dataSize)
            {
                HashData(data);
                PutData(data, Idea_dataSize);
            }
            if(len)
            {
                HashData(data);
                PutData(data, len);
            }
            PlainLenToData(inputLen, data);
            HashData(data);
            CloseOutput();
        }
        else
        {   /* optHash */
            while ((len = GetData(data)) == Idea_dataSize)
                HashData(data);
            if(len)
                HashData(data);
            PlainLenToData(inputLen, data);
            HashData(data);
        }
        WriteHashValue();
    }
} /* CryptData */

void TimeTest(void)
{
#ifdef TIME
    clock_t startTime, endTime;
    float size, duration;
    Idea_Data data;
    Idea_Key key;
    int i;

    for(i = 0; i < Idea_dataLen; i++)
        data[i] = 7 * Idea_dataLen - i;

    for(i = 0; i < Idea_keyLen; i++)
        key[i] = 2 * Idea_keyLen - i;

    for(i = Idea_keyLen - Idea_dataLen; i >= 0; i -= Idea_dataLen)
        Idea_Crypt(&key[i], &key[i], key);

    if((startTime = clock()) == -1)
        JESERR("start timer");

    for(i = nofTestData; i != 0; i--)
        Idea_Crypt(data, data, key);

    if((endTime = clock()) == -1)
        JESERR("stop timer");

    size = (float)nofTestData * (float)Idea_dataSize / 131072.0;
    duration = (float)(endTime - startTime) / (float)CLK_TCK;
    fprintf(stderr,
    "time needed to encrypt %4.1f MBit of data was %4.1f seconds (%6.3f Mb/s)\n"
    , size, duration, size / duration);
#endif
} /* TimeTest */

void SetOption(int *option)
{
    if(*option)
        UsageError(10);

    *option = TRUE;
} /* SetOption */

void SetMode(int newMode, char **str)
{
    if(mode != nomode)
        UsageError(11);

    mode = newMode;
    (*str)++; (*str)++;
    if(newMode == cbc || newMode == cfb || newMode == ofb)
    {
        if('0' <= **str && **str <= '9')
        {
            interleave = 0;
            do
            {
                interleave = 10 * interleave + (**str - '0');
                if(interleave >= maxInterleave)
                    Error(12, "interleave factor is too large");
                (*str)++;
            }while ('0' <= **str && **str <= '9');

            if(interleave == 0)
                Error(13, "interleave factor is zero");
        }
        else interleave = 1;
    }
} /* SetMode */


void ReadOptions(char *str, int *readKeyString, int *readKeyHexString)
{
    char ch;

    str++;
    *readKeyString = *readKeyHexString = FALSE;
    while((ch = *str++) != '\0')
    {
        switch (ch)
        {
            case 'a':
                if(str[0] == 'b' && str[1] == 'r')
                    SetMode(abr, &str);
                else
                    UsageError(14);
                break;

            case 'c':
                if(str[0] == 'b' && str[1] == 'c')
                    SetMode(cbc, &str);
                else if(str[0] == 'f' && str[1] == 'b')
                    SetMode(cfb, &str);
                else
                    UsageError(15);
                break;

            case 'd':
                SetOption(&optDecrypt);
                break;

            case 'e':
                if(str[0] == 'c' && str[1] == 'b')
                    SetMode(ecb, &str);
                else
                    SetOption(&optEncrypt);
                break;

            case 'h':
                SetOption(&optHash);
                break;

            case 'H':
                SetOption(&optCopyHash);
                break;

            case 'o':
                if(str[0] == 'f' && str[1] == 'b')
                    SetMode(ofb, &str);
                else
                    UsageError(16);
                break;

            case 'k':
                SetOption(&optKeyString);
                *readKeyString = TRUE;
                break;

            case 'K':
                SetOption(&optKeyHexString);
                *readKeyHexString = TRUE;
                break;

            case 't':
                if(str[0] == 'a' && str[1] == 'n')
                    SetMode(tan, &str);
                else
                    UsageError(17);
                break;
#ifdef TIME
            case 'T':
                SetOption(&optTime);
                break;
#endif
            default:
                UsageError(18);
                break;
        }
    }
} /* ReadOptions */

void AdjustOptions(void)
{
    if(optTime)
    {
        if(optDecrypt || optEncrypt || optHash || optCopyHash || optKeyString ||
           optKeyHexString || optRas || mode != nomode)
            UsageError(20);
    }
    else
    {
        if(optDecrypt && optEncrypt)
            UsageError(21);

        if(optHash && optCopyHash)
            UsageError(22);

        if(optKeyString && optKeyHexString)
            UsageError(23);

        if(!optDecrypt && !optEncrypt && !optHash && !optCopyHash)
            if(mode == tan || mode == abr)
                SetOption(&optHash);
            else
                SetOption(&optEncrypt);

        if(optHash || optCopyHash)
        {
            if(optDecrypt || optEncrypt)
                UsageError(24);

            if(optRas)
                UsageError(25);

            if(mode == nomode)
                mode = tan;
            else if(mode != tan && mode != abr)
                UsageError(26);
        }
        else
        {
            if(mode == nomode)
            {
                mode = cbc;
                interleave = 1;
            }
            else if(mode != ecb && mode != cbc && mode != cfb && mode != ofb)
                UsageError(27);

            if(!optKeyString && !optKeyHexString)
                UsageError(28);
        }
        time_0 = interleave;
        time_N = 0;
    }
} /* AdjustOptions */

u_int32 HexToInt(char ch)
{
    if('0' <= ch && ch <= '9')
        return ch - '0';
    else if('a' <= ch  && ch <= 'f')
        return 10 + (ch - 'a');
    else if('A' <= ch && ch <= 'F')
        return 10 + (ch - 'A');
    else if(ch == ':')
        return colon;
    else if(ch == '\0')
        return eol;
    else
        return error;
} /* HexToInt */

u_int32 CharToInt(char ch)
{
    if('!' <= ch && ch <= '~')
        return ch - '!';
    else if(ch == '\0')
        return eol;
    else
        return error;
} /* CharToInt */

void ReadKeyHexString(char *str)
{
    int pos, i;
    u_int32 val;

    while ((val = HexToInt(*str++)) < eol)
    {
        for(i = Idea_userKeyLen - 1; i >= 0; i--)
        {
            val |= (u_int32)userKey[i] << 4;
            userKey[i] = (u_int16)(val & 0xFFFF);
            val >>= 16;
        }
        if(val) Error(29, "key value is too large");
    }
    for(pos = 0; val == colon && pos < maxInterleave; pos++)
    {
        while ((val = HexToInt(*str++)) < eol)
        {
            for(i = Idea_dataLen - 1; i >= 0; i--)
            {
                val |= (u_int32)state[pos][i] << 4;
                state[pos][i] = (u_int16)(val & 0xFFFF);
                val >>= 16;
            }
            if(val) Error(30, "initial value is too large");
        }
    }
    if(val == colon)
        Error(31, "too many initial values specified");
    if(val != eol)
        Error(32, "wrong character in initialization string");
} /* ReadKeyHexString */

void ReadKeyString(char *str)
{
    int i;
    u_int32 val;

    while ((val = CharToInt(*str++)) < eol)
    {
        for(i = Idea_userKeyLen - 1; i >= 0; i--)
        {
            val += (u_int32)userKey[i] * nofChar;
            userKey[i] = (u_int16)(val & 0xFFFF);
            val >>= 16;
        }
    }
    if(val != eol)
        Error(32, "wrong character in key string");
} /* ReadKeyString */


/*********************************************************
 Descryption
**********************************************************/
int decrypt_main(int argc, char* argv[])
{
    char *pseudo_argv[PARAMNUM] = { "-d",
                                    "-cbc8",
                                    "-k",
                                                                        g_key
                                  };

    char **argvptr = pseudo_argv;
    int readKeyString, readKeyHexString;
    char buf[MAX_PIPE_READ];
    int i;
    FILE *newOutput;
    char *inbufptr = inputbuf;
	char *pInFileName = NULL;
	char *pOutFileName = NULL;
    int readbytes = 0;
	char *enc_key;
	char cmd[4 * ART_MAX_FILE] = { '\0' };
    int pipes[ 2 ];
    int rc = 0;
	int rval=0;
	int psize = 0;
	FILE* fstream = NULL;
    pid_t pid;
	char * strFuncName = "decrypt_main";

    JESDEBUG("[%s]argc=%d g_perlfile=%s(%d)", strFuncName, argc, g_perlfile, strlen(g_perlfile));
    JESDEBUG("[%s]length of key is: %d(%c...%c)", strFuncName, strlen(g_key), g_key[0], g_key[strlen(g_key)-1]);
/*      if ((enc_key = getenv(ART_KEY_NAME)) != NULL ) {  */
/*              strncpy(g_key, enc_key, ART_MAX_KEY_LEN-1);  */
/*              JESDEBUG("[%senc_key=%s", strFuncName, g_key);  */
/*      }else {  */
/*              JESERR("-2");   */
/*              return -2;   */
/*      }  */

    if ( 1 == g_flag_pipe_dec ) {
        JESTRACE("Try to open stdin(%d)", stdin);
                /* this is for debug */
                if ( 1 == g_flag_debug ) {
                dbgFile = fopen(g_dbgfile, "w+");
                        if(dbgFile == NULL) {
                                JESERR("dbg file File %s doesn't exist!", g_dbgfile);
                                return -3;
                        }
                }
                if (strlen(g_perlfile) == 0) {
                        JESERR("perl script is not specified, please add: -s <perlscript>");
                        print_usage();
                        return -3;
                }
        inFile = fopen(g_perlfile, "rb");
                if(inFile == NULL) {
                        JESERR("open failed for infile File (%s):%s(%d) ", g_perlfile, strerror(errno), errno);
                        return -3;
                }
                  rc = pipe( pipes );
                  if( rc == -1 ){
                        JESERR( "pipe() failed:%s(%d)", strerror(errno), errno );
                        return -3;
                  }

              outFile=(FILE*)pipes[1];
                  pid = fork();
                  switch( pid ){
                  case -1:
						/* fork() failec */
                        JESERR( "fork() failed:%s(%d)", strerror(errno), errno  );
                        return -3;
                  case 0:
                        /* Child process */
                         close(pipes[1]);
                        if(pipes[0]!=STDIN_FILENO) {
                                dup2(pipes[0],STDIN_FILENO);
                        } else {
                                JESERR("do not redirect");
                        }
                        /* RUN perl in pipe mode */
                        snprintf(cmd, sizeof(cmd), "perl - %s", g_perlopt);
                        JESDEBUG("[%s] cmd=%s", strFuncName, cmd);
                        if (NULL == (fstream=popen(cmd,"r"))) {
                                JESERR("[%s] Execute command(%s) failed: %s", strFuncName, cmd, strerror(errno));
                                return -1;
                        }
                        memset(buf, 0x0, sizeof(buf));
                        while ((psize = fread(buf, 1, sizeof(buf),fstream)) != 0 ) {
                        	JESDEBUG("[%s] Read %d Byte from fstream(%08x)", strFuncName, psize, fstream);
                            printf("%s", buf);       
                        }
                		JESTRACE("[%s] fstream=%08x psize=%d buf=%s", strFuncName, fstream, psize, buf);
                        rc = pclose(fstream);
                        if (WIFEXITED(rc)) {
                                rval = WEXITSTATUS(rc);
                                JESTRACE("[%s] child process return %d", strFuncName, WEXITSTATUS(rc));
                        }
                        if (WIFSIGNALED(rc)) {
                                rval = -99;
                                JESTRACE("[%s] child process term with signal:%d", strFuncName, WTERMSIG(rc));
                        }
                        close(pipes[0]);
                        sync();
                		JESTRACE("[%s] Child process by popen() exit with %d", strFuncName, rval);
                        exit(rval);
                  default:
                        /* Parent process */
                		JESTRACE("[%s] in parent process", strFuncName);
                  }
        } else {
			pInFileName=g_infile;
			pOutFileName=g_outfile;
			JESTRACE("Try to open inFile(%s)", pInFileName);
			inFile = fopen(pInFileName, "rb");
			if(inFile == NULL)
			{
					JESERR("infile File %s doesn't exist!", pInFileName);
					return -3;
			}

			JESTRACE("Try to open outFile(%s)", pOutFileName);
			outFile = fopen(pOutFileName, "wb");
			if(outFile == NULL)
			{
				JESERR("File %s create error!", pOutFileName);
				return -4;
			}
        } 
        JESTRACE("Begin to call ReadOptions");
    for(i = 0; i < PARAMNUM; i++)
    {
        ReadOptions(*argvptr, &readKeyString, &readKeyHexString);
        argvptr++;

        if(readKeyString || readKeyHexString)
        {
            if(readKeyString)
                ReadKeyString(*argvptr);
            else
                ReadKeyHexString(*argvptr);

            argvptr++;
            i++;
        }
    }

    AdjustOptions();
    Idea_ExpandUserKey(userKey, key);

    if(optDecrypt && (mode == ecb || mode == cbc))
        Idea_InvertKey(key, key);

        JESTRACE("[%s] Begin to call CryptData() for decrypt", strFuncName);
    CryptData();
    if ( 1 == g_flag_pipe_dec ) {
                JESDEBUG("[%s] wait for child pid=%d", strFuncName, pid);
                int statloc;
                if (pid == waitpid(pid, &statloc, 0)) {
                        JESDEBUG("pid=%d, statloc=%d", pid, statloc);
                        if (WIFEXITED(statloc)) {
                                rval = WEXITSTATUS(statloc);
                                JESTRACE("[%s] fork process return %d", strFuncName, WEXITSTATUS(statloc));
                        }
                        if (WIFSIGNALED(statloc)) {
                                rval = -99;
                                JESTRACE("[%s] fork process term with signal:%d", strFuncName, WTERMSIG(statloc));
                        }
                } else {
                        JESERR("waitpid() faild");
                }
                JESDEBUG("[%s] return with %d", strFuncName, rval);
                return rval;
        } else {
                return 0;
        }
}

/*********************************************************
 Encryption
**********************************************************/
int encrypt_main(int argc, char *argv[])
{
    char *pseudo_argv[PARAMNUM] = { "-e",
                                    "-cbc8",
                                    "-k",
                                                                        g_key
                                  };

    char **argvptr = pseudo_argv;
    int readKeyString, readKeyHexString;
    char buf[256];
    int i;
        char *pInFileName = NULL;
        char *pOutFileName = NULL;
        char* strFuncName = "encrypt_main";
    JESDEBUG("[%s]encrypt_main argc=%d", strFuncName, argc);

        /* disable pipe mode in encryp */
        g_flag_pipe_dec = 0;

        pInFileName  = g_infile;
        pOutFileName = g_outfile;
    JESDEBUG("[%s]length of key is: %d(%c...%c)", strFuncName, strlen(g_key), g_key[0], g_key[strlen(g_key)-1]);
    if(strcmp(pInFileName, pOutFileName) == 0) {
        JESERR("source and destination are identical: %s", pInFileName);
        exit(-1);
    }

    JESTRACE("Try to open inFile(%s)", pInFileName);
    inFile = fopen(pInFileName, "rb");
    if(inFile == NULL) {
        JESERR("File %s doesn't exist!", pInFileName);
                return -1;
    }

    JESTRACE("Try to open outFile(%s)", pOutFileName);
    outFile = fopen(pOutFileName, "wb");
    if(outFile == NULL) {
        JESERR("File %s create error!", pOutFileName);
                return -2;
    }

        JESTRACE("Begin to call ReadOptions");
    for(i = 0; i < PARAMNUM; i++) {
        ReadOptions(*argvptr, &readKeyString, &readKeyHexString);
        argvptr++;

        if(readKeyString || readKeyHexString)
        {
            if(readKeyString)
                ReadKeyString(*argvptr);
            else
                ReadKeyHexString(*argvptr);

            argvptr++;
            i++;
        }
    }

    AdjustOptions();

        JESTRACE("Begin to call Idea_ExpandUserKey");
    Idea_ExpandUserKey(userKey, key);

    if(optDecrypt && (mode == ecb || mode == cbc))
        Idea_InvertKey(key, key);

        /* read the first line in perl script, it will not be encrypted */
/*     fgets(buf, 256, inFile); */

        if (1 == g_flag_header) {
                fputs("#!/usr/bin/perl -w\n", outFile);
                fputs("use Filter::artdecrypt;\n", outFile);
        }

        /* not necessary */
        /*
    fputc(0xff, outFile);
    fputc(0x00, outFile);
        */

        JESTRACE("Begin to call CryptData() for encrypt");
    CryptData();

    fclose(inFile);
    /*fclose(outFile);*/

    return 0;
}


int print_usage() {
        JESERR("Usage: artperl -s <perlscript> -p <perl_option>");
        return 0;
}

int main(int argc, char *argv[]) {
    int option = 0;
    int un = 0;
    int flag_enc = 0;
        int breadth = -1;
        int length  = -1;

    while ((option = getopt(argc, argv,"efk:hs:m:i:o:p:")) != -1) {
        switch (option) {
			 /* encode */
             case 'e' : flag_enc = 1;
                 break;
			 /* decode to file */
             case 'f' : g_flag_pipe_dec = 0;
                 break;
			 /* key to encrypt or decrypt */
             case 'k' : strncpy(g_key, optarg, ART_MAX_KEY_LEN);
                        un++;
                 break;
			 /* specify the encrypted perl script */
             case 's' : strncpy(g_perlfile, optarg, ART_MAX_FILE);
                        un++;
                 break;
			 /* input for encrypt or decrypt */
             case 'i' : strncpy(g_infile, optarg, ART_MAX_FILE);
                        un++;
                 break;
			 /* output for encrypt or decrypt */
             case 'o' : strncpy(g_outfile, optarg, ART_MAX_FILE);
                        un++;
                 break;
			 /* if write header "#!/usr/bin/perl" */
             case 'h' : g_flag_header = 1;
                 break;
			 /* debug mode to output the decrypted perl script(text) to one file */
             case 'm' : g_flag_debug = 1; strncpy(g_dbgfile, optarg, ART_MAX_FILE);
                 break;
			 /* specify perl option which will be used by "perl <perl_opt>*/
             case 'p' : strncpy(g_perlopt, optarg, ART_MAX_FILE);
                        un++;
                 break;
             default: print_usage();
                 exit(-1);
        }
                un++;
    }

        /* Only in debug version for internal use can accept "-m" and "-f", ONLY for debug purpose */
#ifndef _ART_DEBUG
        g_flag_pipe_dec = 1;
        g_flag_debug    = 0;
#endif

    if (flag_enc == 1) {
                /* encrypt */
        return encrypt_main(argc, argv);
    } else {
                /* decrypt */
        return decrypt_main(argc, argv);
        }
        return 0;
}

