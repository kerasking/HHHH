/*
*
*/

#ifndef NDCONSOLE_H
#define NDCONSOLE_H

#include "NDObject.h"
#include "define.h"
#include "BaseType.h"
#include "pthread.h"
#include "semaphore.h"
#include "Singleton.h"

BEGIN_ND_NAMESPACE

class NDConsole:
	public NDObject,
	public TSingleton<NDConsole>
{
	DECLARE_CLASS(NDConsole);

public:

	NDConsole();
	NDConsole(LPCTSTR lpszTitle, SHORT ConsoleHeight = 300,
		SHORT ConsoleWidth = 80);
	virtual ~NDConsole();

	void Attach(SHORT ConsoleHeight, SHORT ConsoleWidth);
	void BeginReadLoop();
	void StopReadLoop();

	CC_SYNTHESIZE(void*,m_hOutputHandle,OutputHandle);
	CC_SYNTHESIZE(void*,m_hInputHandle,InputHandle);

protected:

	static void* ReadGameConsole(void* pData);

	static bool ms_bIsExistent;
	static sem_t ms_pkSemT;
	static pthread_mutex_t ms_pkAsyncStructQueueMutex;
	static pthread_t ms_pkReadConsoleThread;
	static bool ms_bContinueThread;
	static char* ms_pszBuffer;

	void* m_lpReadBuffer;

private:
};

END_ND_NAMESPACE
#endif