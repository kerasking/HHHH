#include "CCPlatformConfig.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

#include "NDConsole.h"
#include <io.h>
#include <windows.h>
#include <winbase.h>
#include <fcntl.h>
#include "NDDebugOpt.h"

BEGIN_ND_NAMESPACE

IMPLEMENT_CLASS(NDConsole, NDObject);

bool NDConsole::ms_bIsExistent = false;
pthread_mutex_t NDConsole::ms_pkAsyncStructQueueMutex = 0;
sem_t NDConsole::ms_pkSemT = 0;
pthread_t NDConsole::ms_pkReadConsoleThread =
{ 0 };
bool NDConsole::ms_bContinueThread = false;
char* NDConsole::ms_pszBuffer = 0;

NDConsole::NDConsole() :
m_hOutputHandle(0),
m_hInputHandle(0),
m_pkStringMap(0)
{
	if (ms_bIsExistent)
	{
		return;
	}

	AllocConsole();
	Attach(300, 120);
	ms_bIsExistent = TRUE;
	m_pkStringMap = new MAP_STRING;
}

NDConsole::NDConsole(LPCTSTR lpszTitle, SHORT ConsoleHeight /*= 300*/,
		SHORT ConsoleWidth /*= 80*/) :
		m_hOutputHandle(0)
{
	if (ms_bIsExistent)
	{
		return;
	}

	AllocConsole();
	SetConsoleTitle(lpszTitle);
	Attach(ConsoleHeight, ConsoleWidth);
	ms_bIsExistent = true;
}

NDConsole::~NDConsole()
{
	ms_bContinueThread = false;

	if (ms_bIsExistent)
	{
		FreeConsole();
	}

	ms_bIsExistent = false;

	SAFE_DELETE(m_pkStringMap);
}

void NDConsole::Attach(SHORT ConsoleHeight, SHORT ConsoleWidth)
{
	int nFD = 0;
	FILE* pkFile = 0;

	m_hInputHandle = GetStdHandle(STD_INPUT_HANDLE);
	nFD = _open_osfhandle(reinterpret_cast<intptr_t>(m_hInputHandle), _O_TEXT);
	pkFile = _fdopen(nFD, "r");
	setvbuf(pkFile, NULL, _IONBF, 0);
	*stdin = *pkFile;

	m_hOutputHandle = GetStdHandle(STD_OUTPUT_HANDLE);
	COORD kSize =
	{ 0 };
	kSize.X = ConsoleWidth;
	kSize.Y = 2000;//ConsoleHeight;
	SetConsoleScreenBufferSize(m_hOutputHandle, kSize);
	nFD = _open_osfhandle(reinterpret_cast<intptr_t>(m_hOutputHandle), _O_TEXT);
	pkFile = _fdopen(nFD, "w");
	setvbuf(pkFile, NULL, _IONBF, 0);
	*stdout = *pkFile;

	m_hOutputHandle = GetStdHandle(STD_ERROR_HANDLE);
	nFD = _open_osfhandle(reinterpret_cast<intptr_t>(m_hOutputHandle), _O_TEXT);
	pkFile = _fdopen(nFD, "w");
	setvbuf(pkFile, NULL, _IONBF, 0);
	*stderr = *pkFile;
}

void NDConsole::BeginReadLoop()
{
	ms_bContinueThread = true;
	pthread_mutex_init(&ms_pkAsyncStructQueueMutex, 0);
	sem_init(&ms_pkSemT, 0, 0);
	pthread_create(&ms_pkReadConsoleThread, 0, NDConsole::ReadGameConsole, 0);
	ms_pszBuffer = new char[2048];
	memset(ms_pszBuffer, 0, sizeof(char) * 2048);
}

void* NDConsole::ReadGameConsole(void* pData)
{
	while (true)
	{
		pthread_mutex_lock (&ms_pkAsyncStructQueueMutex);

		if (false == ms_bContinueThread)
		{
			break;
		}

		DWORD dwReadCount = 0;
		CONSOLE_READCONSOLE_CONTROL kControl =
		{ 0 };
		ReadConsoleA(NDConsole::GetSingletonPtr()->getInputHandle(),
				(void*) ms_pszBuffer, 2048, &dwReadCount, &kControl);
		pthread_mutex_unlock(&ms_pkAsyncStructQueueMutex);

		if (*ms_pszBuffer)
		{
			NDConsole::GetSingletonPtr()->ProcessInput(ms_pszBuffer);
			memset(ms_pszBuffer, 0, sizeof(char) * 2048);
		}
	}

	return 0;
}

void NDConsole::StopReadLoop()
{
	ms_bContinueThread = false;
}

bool NDConsole::RegisterConsoleHandler(NDConsoleListener* pkListener,
		const char* pszKeyword)
{
	if (0 == pszKeyword || !*pszKeyword || 0 == pkListener)
	{
		return false;
	}

	string strValue = pszKeyword;
	m_kListenerMap.insert(make_pair(strValue, pkListener));

	return true;
}

void NDConsole::ProcessInput(const char* pszInput)
{
	if (0 == pszInput || !*pszInput)
	{
		return;
	}

	string strInput = pszInput;

	for (MAP_LISTENER::iterator it = m_kListenerMap.begin();
			it != m_kListenerMap.end(); it++)
	{
		string strListenerKey = it->first;
		NDConsoleListener* pkListener = 0;
		int nPos = -1;

		if (0 == (nPos = strInput.find(strListenerKey)))
		{
			pkListener = it->second;

			if (pkListener)
			{
				char* pszTemp = new char[2048];
				memset(pszTemp,0,sizeof(char) * 2048);
				string strResult = strInput.substr(strListenerKey.length(),
						strInput.length());
				strcpy_s(pszTemp,2048,strResult.c_str());
				m_pkStringMap->insert(make_pair(strListenerKey,pszTemp));
				pkListener->processConsole(strResult.c_str());
			}
		}
	}

	if (pszInput[0] == '/')
	{
		PM(pszInput);
	}
}

//@pm
void NDConsole::PM(const char* pszInput)
{	
	// remove slash & lf
	char cmd[100] = {0};
	strncpy( cmd, pszInput + 1, sizeof(cmd) - 1 );
	char* p = strstr( cmd, "\r\n" ); if (p) *p = 0;

	// publish to all listener
	for (MAP_LISTENER::iterator it = m_kListenerMap.begin();
		it != m_kListenerMap.end(); it++)
	{
		NDConsoleListener* pkListener = it->second;

		if (pkListener)
		{
			pkListener->processPM( cmd );
		}
	}
}

const char* NDConsole::GetSpecialCommand( const char* pszCommand )
{
	if (0 == m_pkStringMap->size())
	{
		return 0;
	}

	string strCmd = pszCommand;
	const char* pszRes = (*m_pkStringMap)[strCmd];

	if (pszRes && *pszRes)
	{
		int a = 10;
	}

	return pszRes;
}

bool NDConsole::ClearSpecialCommand( const char* pszCommand )
{
	if (0 == pszCommand || !*pszCommand)
	{
		return false;
	}

	string strValue = pszCommand;

	MAP_STRING::iterator it = m_pkStringMap->find(strValue);

	if (m_pkStringMap->end() == it)
	{
		return false;
	}

	SAFE_DELETE_ARRAY(it->second);
	m_pkStringMap->erase(it);

	return true;
}

END_ND_NAMESPACE

#endif