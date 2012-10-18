#include "NDConsole.h"
#include <io.h>
#include <windows.h>
#include <winbase.h>
#include <fcntl.h>

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
		m_hOutputHandle(0), m_hInputHandle(0)
{
	if (ms_bIsExistent)
	{
		return;
	}

	AllocConsole();
	Attach(300, 80);
	ms_bIsExistent = TRUE;
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
	if (ms_bIsExistent)
	{
		FreeConsole();
	}

	ms_bIsExistent = false;
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
	kSize.Y = ConsoleHeight;
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
	}

	return 0;
}

void NDConsole::StopReadLoop()
{
	ms_bContinueThread = false;
}

END_ND_NAMESPACE