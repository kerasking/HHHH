#include <sys/types.h>
#include <sys/stat.h>
#include <sys/unistd.h>
#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <errno.h>
#include <string>
#include <map>
#include "cpLog.h"
#include "KMutex.h"
#include "KThread.h"
#include "KTimeVal.h"



#define DATEBUF_SIZE 512
#define FILEBUF_SIZE 512
#define LOG_FNAME_MAX_SIZE 512

static const char*  priName[] =
{
	"EMERG",
	"ALERT",
	"CRIT",
	"ERR",
	"WARNING",
	"NOTICE",
	"INFO",
	"DEBUG",
	"DEBUG_STACK",
	0
};

static const char* priNameShort[] =
{
	"EMRG",
	"ALRT",
	"CRIT",
	"ERR ",
	"WARN",
	"NOTC",
	"INFO",
	"DBUG",
	"DSTK",
	0
};


static char cpLogFilename[LOG_FNAME_MAX_SIZE + 1] = "";
static FILE* cpLogFd = stderr;
KMutex logMutex;
Sptr< KUdpStack > spClientSock = 0;
bool bConnServer = false;
int g_logPriority = LOG_ERR;
bool g_bCpLogEnable = false;
LogFunc	mainLogFunc = NULL;

int openTheLogFile();

int cpLogOpen( const char* filename )
{
    assert( strlen ( filename ) <= FILEBUF_SIZE );
	memset(cpLogFilename, 0, LOG_FNAME_MAX_SIZE + 1);
    strncpy( cpLogFilename, filename, FILEBUF_SIZE );
    return openTheLogFile();
}


int openTheLogFile()		
{
	if ( !( cpLogFd = fopen( cpLogFilename, "a+") ) )
    {
    	printf( "cpLog: Cannot open log file %s:  %s\n", cpLogFilename, strerror( errno ) );
        return 0;
    }
    fseek( cpLogFd, 0, SEEK_END );
    cpLog( LOG_INFO, "Opened new log file - %s", cpLogFilename );
    
	return 1;
}


void cpLogEnable( bool bEnable )
{
	g_bCpLogEnable = bEnable;
}


void cpLog( int pri, const char* fmt, ... )
{
	if ( !g_bCpLogEnable )
		return;
	logMutex.lock();

    va_list ap;
	if ( pri <= g_logPriority )
    {
        va_start( ap, fmt );
        vCpLog( pri, "", 0, fmt, ap );
        va_end( ap );
    }
	logMutex.unlock();
}


void vCpLog( int pri, const char* file, int line, const char* fmt, va_list ap )
{
    assert( pri >= 0 && pri <= LAST_PRIORITY );

    char datebuf[ DATEBUF_SIZE ];
	memset(datebuf, 0, DATEBUF_SIZE);
    int datebufCharsRemaining;

    struct timeval tv;
    struct timezone tz;
    int result = gettimeofday( &tv, &tz );
    
    if( result == -1 )
    {
	    datebuf [0] = '\0';
    }
    else
    {
		const time_t timeInSeconds = (time_t) tv.tv_sec;
		strftime( datebuf, DATEBUF_SIZE, "%m-%d %H:%M:%S", localtime ( &timeInSeconds ) );
    }
    char msbuf[10];

    sprintf( msbuf, ".%3.3d", (int)(tv.tv_usec/1000) );
    datebufCharsRemaining = DATEBUF_SIZE - strlen( datebuf );
    strncat( datebuf, msbuf, datebufCharsRemaining - 1 );
    datebuf[DATEBUF_SIZE - 1] = '\0';

	if( bConnServer )
	{
		char outBuff[2048];
		memset(outBuff, 0, 2048);
		KData ret = "[";
		ret = ret + KData(datebuf) + KData("]") + KData(priNameShort[pri]) + KData(" ");
		vsprintf( outBuff, fmt, ap );
		ret += outBuff;
		LogPack *pLogPack = (LogPack*)outBuff;
		pLogPack->lLogMsgSize = htonl( ret.length() ) ;
		strcpy( pLogPack->strLogMsg, ret.getDataBuf() );
		spClientSock->transmit( (char*)pLogPack, sizeof( long )+ret.length() );
	}

	if( mainLogFunc == NULL )
	{
		fprintf( cpLogFd, "[%s] %s: ", datebuf, priNameShort[pri] );
		vfprintf( cpLogFd, fmt, ap );
		fprintf( cpLogFd, "\n" );
		fflush( cpLogFd );
	}
	else
	{
		char outBuff[2048];
		memset(outBuff, 0, 2048);
		KData ret = "[";
		ret = ret + KData(datebuf) + "]" + priNameShort[pri] + "  ";
		vsprintf( outBuff, fmt, ap );
		ret += outBuff;
		mainLogFunc( ret, pri );
	}
}


void
cpLogSetPriority( int pri )
{
     g_logPriority = pri;
}


int
cpLogGetPriority()
{
    return g_logPriority;
}


void
cpLogShow (void)
{
    fprintf (stderr, "\tPriority : %s\n", priName[g_logPriority]);
    fprintf (stderr, "\tFile     : %s (cpLogFd = %d)\n", cpLogFilename, fileno(cpLogFd));
}


int
cpLogStrToPriority( const char* priority )
{
    string pri = priority;

    if ( pri.find("LOG_", 0) == 0 )
    {
        pri.erase( 0, 4 );
    }

    int i = 0;
    while ( priName[i] != 0 )
    {
        if ( pri == priName[i] )
        {
            return i;
        }
        i++;
    }
    return -1;  // invalid
}


const char*
cpLogPriorityToStr( int priority )
{
    int priorityCount = 0;
    while (priName[priorityCount] != 0)
    {
        priorityCount++;
    }

    if ( ( priority >= 0 ) && ( priority < priorityCount ) )
    {
        return priName[priority];
    }
    else
    {
        return 0;
    }
}


void cpLogConnServer( KNetworkAddress& addr )
{
	spClientSock = new KUdpStack;
	if ( !spClientSock->init( &addr ) )
	{
		bConnServer = false;
		spClientSock = 0;
	}
	else
	{
		bConnServer = true;
	}		
}


void cpLogSetLogFunc( LogFunc func )
{
	mainLogFunc = func;
}

void cpLogClose()
{
	if ( cpLogFd != stderr )
		fclose( cpLogFd );	
}

