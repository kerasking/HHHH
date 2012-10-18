#include "NDConsole.h"
#include <io.h>
#include <windows.h>
#include <winbase.h>
#include <fcntl.h>

BEGIN_ND_NAMESPACE
IMPLEMENT_CLASS(NDConsole,NDObject);

bool NDConsole::ms_bIsExistent = false;

NDConsole::NDConsole()
{
	if (ms_bIsExistent)
	{
		return;
	}

	AllocConsole();
	Attach(300, 80);
	ms_bIsExistent = TRUE;
}

NDConsole::NDConsole( LPCTSTR lpszTitle, SHORT ConsoleHeight /*= 300*/, SHORT ConsoleWidth /*= 80*/ )
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

void NDConsole::Attach( SHORT ConsoleHeight, SHORT ConsoleWidth )
{
	HANDLE hStd = 0;
	int nFD = 0;
	FILE* pkFile = 0;

	hStd = GetStdHandle(STD_INPUT_HANDLE);
	nFD = _open_osfhandle(reinterpret_cast<intptr_t>(hStd), _O_TEXT);
	pkFile = _fdopen(nFD, "r");
	setvbuf(pkFile, NULL, _IONBF, 0);
	*stdin = *pkFile;

	hStd = GetStdHandle(STD_OUTPUT_HANDLE);
	COORD kSize = {0};
	kSize.X = ConsoleWidth;
	kSize.Y = ConsoleHeight;
	SetConsoleScreenBufferSize(hStd, kSize);
	nFD = _open_osfhandle(reinterpret_cast<intptr_t>(hStd), _O_TEXT);
	pkFile = _fdopen(nFD, "w");
	setvbuf(pkFile, NULL, _IONBF, 0);
	*stdout = *pkFile;

		// 重定向标准错误流句柄到新的控制台窗口
	hStd = GetStdHandle(STD_ERROR_HANDLE);
	nFD = _open_osfhandle(reinterpret_cast<intptr_t>(hStd), _O_TEXT);
	pkFile = _fdopen(nFD, "w");
	setvbuf(pkFile, NULL, _IONBF, 0);
	*stderr = *pkFile;
}

END_ND_NAMESPACE