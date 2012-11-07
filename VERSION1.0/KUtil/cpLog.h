#ifndef __KT_CPLOG_H
#define __KT_CPLOG_H

#include <stdarg.h>
#include "KData.h"
//#include "KNetworkAddress.h"
//#include "KUdpStack.h"


#define SIZE_PER_LOGFILE 6291456

#define LOG_EMERG       0					
#define LOG_ALERT       1				
#define LOG_CRIT        2					
#define LOG_ERR         3					
#define LOG_WARNING     4					
#define LOG_NOTICE      5					
#define LOG_INFO        6					
#define LOG_DEBUG       7
#define LOG_DEBUG_STACK	8

#define LAST_PRIORITY LOG_DEBUG_STACK

extern bool g_bCpLogEnable;

typedef void (*LogFunc)( KData& logKData, int priority );

typedef struct logpack
{
	long lLogMsgSize;
	char strLogMsg[ 512 ];
} LogPack;

void vCpLog( int pri, const char* file, int line, const char* fmt, va_list ap );

void cpLogEnable( bool bEnable );


void cpLog( int pri, const char *fmt, ... );

void cpLogSetPriority( int pri );

int cpLogGetPriority();


void cpLogShow( void );

//logging to the Unix syslog facility, rather than to a file */
void cpLogOpenSyslog();

int cpLogOpen( const char* filename );

int cpLogStrToPriority( const char* priority );

const char* cpLogPriorityToStr( int priority );

void cpLogSetLogFunc( LogFunc func );

void cpLogConnServer( KNetworkAddress& addr );

void cpLogClose();

class cpLogDisableHelper
{
public:
	cpLogDisableHelper()
	{
		m_bEnable = g_bCpLogEnable;
		cpLogEnable( false );
	}
	~cpLogDisableHelper()
	{
		cpLogEnable( m_bEnable );
	}
private:
	bool m_bEnable;
};

#endif
