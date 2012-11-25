/*
*
*/

#ifndef NDCONSOLE_H
#define NDCONSOLE_H

#include <string>
#include <map>
#include "NDObject.h"
#include "define.h"
#include "BaseType.h"
#include "pthread.h"
#include "semaphore.h"
#include "Singleton.h"
#include "CCPlatformConfig.h"

BEGIN_ND_NAMESPACE

using namespace std;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

class NDConsoleListener
{
public:
	NDConsoleListener(){};
	virtual ~NDConsoleListener(){};

	virtual bool processConsole(const char* pszInput) = 0;
	virtual bool processPM(const char* pszCmd) = 0;

protected:
private:
};

class NDConsole:
	public NDObject,
	public TSingleton<NDConsole>
{
	DECLARE_CLASS(NDConsole);

public:

	typedef map<string,NDConsoleListener*> MAP_LISTENER;
	typedef map<string,const char*> MAP_STRING;

	NDConsole();
	NDConsole(LPCTSTR lpszTitle, SHORT ConsoleHeight = 300,
		SHORT ConsoleWidth = 80);
	virtual ~NDConsole();

	void Attach(SHORT ConsoleHeight, SHORT ConsoleWidth);
	void BeginReadLoop();
	void StopReadLoop();
	bool RegisterConsoleHandler(NDConsoleListener* pkListener,const char* pszKeyword);
	const char* GetSpecialCommand(const char* pszCommand);
	bool ClearSpecialCommand(const char* pszCommand);

	CC_SYNTHESIZE(void*,m_hOutputHandle,OutputHandle);
	CC_SYNTHESIZE(void*,m_hInputHandle,InputHandle);

protected:

	static void* ReadGameConsole(void* pData);

	void ProcessInput(const char* pszInput);
	void PM(const char* pszInput);

	static bool ms_bIsExistent;
	static sem_t ms_pkSemT;
	static pthread_mutex_t ms_pkAsyncStructQueueMutex;
	static pthread_t ms_pkReadConsoleThread;
	static bool ms_bContinueThread;
	static char* ms_pszBuffer;

	MAP_LISTENER m_kListenerMap;
	MAP_STRING* m_pkStringMap;

private:
};

#endif

END_ND_NAMESPACE
#endif